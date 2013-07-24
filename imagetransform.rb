#!/ruby/bin/env ruby


def image_to_tiles(image)
  streamID = $gimp_itile.tile_stream_new(image.imageID, image.active_layer)
  if tile_stream_is_valid(streamID)
    tile+array = $gimp_itile.tile_stream_get(streamID)
    $gimp_itile.tile_stream_advance(streamID)
    return tile_array
  else
    puts "StreamID #[streamID] from image #[image.ID] is invalid\n"
  end
end

class PixeledTile
  @width
  @height
  @size
  @pixels
  attr_reader :size, :pixels, :width, :height

  def initialize (tile_array)
    @width = tile_array[6]
    @height = tile_array[7]
    @size = tile_array[0] #is size in bytes or bits
    bytes = tile_array[3]
    arr = []
    i = 0
    j = 0
    while i < bytes
      arr[j] = [bytes[i], 
                bytes[i+1],
                bytes[i+2]]
      j += 1
      i += 3
    end # while
    @pixels = arr
  end # init

  def set_all_pixels!(r, g, b)
    i = 0
    while i < size do
      pixels[i] = [r, g, b]
      i += 1
      end
  end

  def transform!(fun)
    @pixels.map{|element| fun.call(element)}
  end

end # PixeledTile
