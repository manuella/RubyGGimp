#!/ruby/bin/env ruby

require './images.rb'

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
  stream_active = $gimp_itile.tile_stream_new(imageID, active_layer)[0]
  puts stream_active
  puts "\n#{stream_active.is_a? Integer}\n"
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

  attr_reader :size, :pixels, :width, :height, :x, :y, :row_stride, :bytes_in_pic

  def initialize (array_and_id)
    @streamID = array_and_id[1]
    tile_array = array_and_id[0] 
    size = tile_array[0][0]
    puts "#{tile_array[0]}\n#{tile_array[0].class}"
    data = tile_array[1]
    @bytes_per_pixel = tile_array[2]
    @row_stride = tile_array[3]
    @x = tile_array[4]
    @y = tile_array[5]
    @width = tile_array[6]
    @height = tile_array[7]
    data = tile_array[1]
    
    puts "bpp: #{@bytes_per_pixel}\nrow stride: #{@row_stride}\nsize: #{@size}\n"

    arr = []
    i = 0
    j = 0
    while i < size
      arr[j] = [data[i], 
                data[i+1],
                data[i+2]]
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
