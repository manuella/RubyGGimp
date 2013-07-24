#!/ruby/bin/env ruby

require './gimp_dbus_connection.rb'

# These are constants to be used with the select_ellipse and 
# select_rectangle methods in the Image class.

ADD = 0
SUBTRACT = 1
REPLACE = 2
INTERSECT = 3

#A flag class used within Turtle (context-preserve)

class Flag
  @status = true
  def initialize()
    @status = true
  end
  def set_status(state)
    @status = state
  end
  def get_status()
    return @status
  end
end

$context_preserve = Flag.new()
def clamp(num, lbound, ubound)
  return [lbound, [num, ubound].min].max
end

def rgb_clamp(num)
  return clamp(num, 0, 255)
end

def image_draw_line(image, x0, y0, xf, yf)
  $gimp_iface.gimp_paintbrush(image.active_layer(), 0, 4, 
                              [x0, y0, xf, yf], 0, 0)
end

def new_layer(image)
  name = ""
  layer = $gimp_iface.gimp_layer_new(image, image.width, image.height, 0, name, 100, 0)
  return $gimp_iface.gimp_image_insert_layer(image, layer, 0, -1)
end
