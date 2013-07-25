#***************************************************************
#----------            Image Class              ----------------
#***************************************************************

require './gimp_dbus_connection.rb'

class Image

  @width
  @height
  @imageID
  @active_layer

  attr_reader :width, :height, :imageID, :active_layer


  #Takes a an Image instance, and displays it in a new window
  def show
    $gimp_iface.gimp_display_new(@imageID)
  end
  
  def compute(proc)
    image_compute(@imageID, @active_layer, proc)
  end
    
  def set_color(r, g, b)
    set_all_pixels_internal_init(@imageID, @active_layer, r, g, b)
  end

  #Selects a layer to be the active drawable
  def set_active_layer(layerID)
    layerList = $gimp_iface.gimp_image_get_layers(@imageID)[1]
    if layerList.include? layerID
      @active_layer = layerID
    else
      raise Arguement "Invalide layer ID for this image: #{@imageID}"
    end
    
  end


  def fill_selection
    $gimp_iface.gimp_edit_fill(@active_layer, 0)
  end

  def stroke_selection
     $gimp_iface.gimp_edit_stroke(@active_layer)
  end

  def select_rectangle(operation, x, y, width, height)
    $gimp_iface.gimp_image_select_rectangle(@imageID, operation, 
                                            x, y, width, height)
  end

  def select_ellipse(operation, x, y, width, height)
    $gimp_iface.gimp_image_select_ellipse(@imageID, operation, 
                                          x, y, width, height)
  end

  def select_none
    $gimp_iface.gimp_selection_none(@imageID)
  end
  
  private

  #Initializes a new instance of Image, which is completely blank
  def Image.new_blank(width, height) 
    imageID = $gimp_iface.gimp_image_new(width, height, 0)[0]
    active_layer = $gimp_iface.gimp_layer_new(imageID, width,
                                              height, 0, "Background",
                                              100, 0)[0]
    $gimp_iface.gimp_image_insert_layer(imageID, active_layer, 0, 0)
    $gimp_iface.gimp_drawable_fill(active_layer, 1)
    Image.new(width, height, imageID, active_layer)
  end
  
  # Initializes a new instance of Image which loads a previously
  # saved image
  def Image.new_loaded(path)
    imageID = $gimp_iface.gimp_file_load(0, path, path)[0]
    width = $gimp_iface.gimp_image_width(imageID)
    height = $gimp_iface.gimp_image_height(imageID)
    active_layer = $gimp_iface.gimp_image_get_active_layer(imageID)
    Image.new(width, height, imageID, active_layer)
  end
  
  protected
  
  #This should only be called by new_blank and new_loaded
  def initialize(width, height, imageID, active_layer)
    @width = width
    @height = height
    @imageID = imageID
    @active_layer = active_layer
  end
end

#Evan Manuella
#Marsha Fletcher

# Here, we are creating a system which will allow the user to input an image and
# a function (e.g: rgb-redder). This function will be applied to every pixel in 
# the image (e.g: making the image redder). 

def image_compute(imageID, active_layer, function)
  tile = PixeledTile.new(image_to_initial_tile(imageID, active_layer))
  while tile
    tile.transform!(function)
    tile = tile.export()
  end
end

def set_all_pixels_internal_init(imageID, active_layer, r, g, b)
  tile  = PixeledTile.new(image_to_initial_tile(imageID, active_layer))
  while tile
    tile.set_all_pixels_internal(r, g, b)
    tile = tile.export()
  end
end

def image_to_initial_tile(imageID, active_layer)
  puts imageID
  puts active_layer
  stream_active = $gimp_itile.tile_stream_new(imageID, active_layer)[0]
  if $gimp_itile.tile_stream_is_valid(stream_active)
    tile_array = $gimp_itile.tile_stream_get(stream_active)
    return [tile_array, stream_active]
  else
    puts "StreamID #[streamID] from image #[image.ID] is invalid\n"
    #Sending this error to the top (user) layer should not happen.
  end
end


class PixeledTile
  @streamID
  @width
  @height
  @pixels
  @x
  @y
  @row_stride
  @bytes_in_pic
  @size

  attr_reader :size, :pixels, :width, :height, :x, :y, :row_stride, :bytes_in_pic
  
  def initialize (array_and_id)
    @streamID = array_and_id[1]
    tile_array = array_and_id[0] 
    @size = tile_array[0]
    data = tile_array[1]
    @bytes_per_pixel = tile_array[2]
    @row_stride = tile_array[3]
    @x = tile_array[4]
    @y = tile_array[5]
    @width = tile_array[6]
    @height = tile_array[7]
    data = tile_array[1]
    
    arr = []
    $i = 0
    $j = 0
    while $i < @size
      arr[$j] = [data[$i], 
                 data[$i+1],
                 data[$i+2]]
      $j += 1
      $i += 3
    end # while
    
    @pixels = arr
    
  end # init
  
  def validate()
    return $gimp_itile.tile_stream_is_valid(@streamID)
  end
  
  def set_all_pixels_internal(r, g, b)
    $i = 0
    while $i < @size do
      @pixels[$i] = [r, g, b]
      $i += 1
    end
  end
  
  def transform!(fun)
    @pixels.map{|element| fun.call(element)}
  end
  
  def export() #Sends over tile, advances to the next, and recreates the instance as 
               #a the next tile

    # tile_array = [@size, @pixels, @bytes_in_pic, @row_stride, @x, @y, @width, @height]
    
    pixel_data = []
    $i = 0
    $j = 0
    $num_bytes = (@size * @bytes_per_pixel)
    pixel_data = @pixels.flatten()
    
    
    $gimp_itile.tile_update(@streamID, $num_bytes, pixel_data) #give gimp newest data
    state = $gimp_itile.tile_stream_advance(@streamID)           #Move to the next tile
    puts "\n\n#{state[0].class}\n#{state[0]}\n"
    
    if (state[0] == 1)
      tile_array = $gimp_itile.tile_stream_get(@streamID)
      array_and_id = [tile_array, @streamID]
      tile = PixeledTile.new(array_and_id)
      return tile
      
    else #if there is no next tile
      $gimp_itile.tile_stream_close(@streamID)
      return false
    end
  end
end
