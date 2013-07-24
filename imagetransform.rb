#!/ruby/bin/env ruby

#Evan Manuella
#Marsha Fletcher

# Here, we are creating a system which will allow the user to input an image and
# a function (e.g: rgb-redder). This function will be applied to every pixel in 
# the image (e.g: making the image redder). 

# Outline

# tile = PixeledTile.new(image_to_intial_tile(image)
# tile.transform!(fun)
# tile.export()
# #if tile.export() returns 0, then the image is done being processed
# #else, it repeats transform and export 

def image_compute(imageID, active_layer, function)
  tile = PixeledTile.new(image_to_initial_tile(imageID, active_layer))
  while tile
    tile.transform!(function)
    tile = tile.update()
  end
end

def set_all_pixels(imageID, active_layer, r, g, b)
  tile  = PixeledTile.new(image_to_initial_tile(imageID, active_layer))
  while tile
    tile.set_all_pixels!(r, g, b)
    tile = tile.update()
  end
end

def image_to_initial_tile(imageID, active_layer)
  streamID = $gimp_itile.tile_stream_new(imageID, active_layer)
  if tile_stream_is_valid(streamID)
    tile_array = $gimp_itile.tile_stream_get(streamID)
    $gimp_itile.tile_stream_advance(streamID)
    return [tile_array, streamID]
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

  attr_reader :size, :pixels, :width, :height, :x, :y, :row_stride, :bytes_in_pic

  def initialize (array_and_id)
    tile_array = array_and_id[0]
    @streamID = array_and_id[1] 
    size = tile_array[0]
    data = tile_array[1]
    @bytes_in_pic = tile_array[2]
    @row_stride = tile_array[3]
    @x = tile_array[4]
    @y = tile_array[5]
    @width = tile_array[6]
    @height = tile_array[7]
    data = tile_array[1]

    arr = []
    i = 0
    j = 0
    while i < @bytes_in_pic
      arr[j] = [bytes[i], 
                bytes[i+1],
                bytes[i+2]]
      j += 1
      i += 3
    end # while

    @pixels = arr

  end # init

  def validate()
    return $gimp_itile.tile_stream_is_valid(@streamID)
  end

  def set_all_pixels!(r, g, b)
    i = 0
    while i < @size do
      pixels[i] = [r, g, b]
      i += 1
      end
  end

  def transform!(fun)
    @pixels.map{|element| fun.call(element)}
  end
  
  def export() #Sends over tile, advances to the next, and recreates the instance as 
               #a the next tile

    # tile_array = [@size, @pixels, @bytes_in_pic, @row_stride, @x, @y, @width, @height]
  
    pixel_data = []
    i = 0
    j = 0

    while i < @bytes_in_pic #unflattening the array for export
      pixel_data[j] = [@pixels[i], @pixels[i+1], @pixels[i+2]]
      i += 3
      j += 1
    end
    
    $gimp.itile.tile_update(@streanID, @size, pixel_data) #give gimp newest data
    state = $gimp.itile.tile_advance(@streamID)           #Move to the next tile

    if state
      array_and_id = [$gimp_itile.tile_stream_get(@streamID), @streamID]
      tile = PixeledTile.new(array_and_id)
      return tile

    else #if there is no nex tile
      $gimp_itile.tile.stream.close(@streamID)
      return 0 
    end
  end
end # PixeledTile
