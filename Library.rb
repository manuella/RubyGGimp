#Evan Manuella
#The start of a ruby wrapper library for ggimp

#!/ruby/bin/env ruby

#require './flag.rb'
require 'dbus'
#require "test/unit"


$bus = DBus::SessionBus.instance
$gimp_service = $bus.service("edu.grinnell.cs.glimmer.GimpDBus")
$gimp_object = $gimp_service.object("/edu/grinnell/cs/glimmer/gimp")
$gimp_object.introspect
$gimp_iface = $gimp_object["edu.grinnell.cs.glimmer.pdb"]

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

class Image

  @width
  @height
  @imageID
  @active_layer

  def initialize(width, height)
    @width = width
    @height = height
    @imageID = $gimp_iface.gimp_image_new(width, height, 0)[0]
    @active_layer = $gimp_iface.gimp_layer_new(@imageID, width, height, 0, "Background", 100, 0)[0]
    $gimp_iface.gimp_image_insert_layer(@imageID, @active_layer, 0, 0)
    $gimp_iface.gimp_edit_bucket_fill(@active_layer, 1, 0, 100, 255, 0, 0, 0)

  end

  def show
    $gimp_iface.gimp_display_new(@imageID)
  end

  def get_width
    return @width
  end

  def get_height
    return @height
  end

  def get_layer
    return @active_layer
  end

  def set_active_layer(layer) #will need guard procedures
    @active_layer = layer
  end
end

# ^^^  Tested  ^^^ #
#------------------#
# vvv Untested vvv #

#Context

def context_display_flush()
  $gimp_iface.gimp_displays_flush()
end

def context_set_bgcolor(rgb)
  $gimp_iface.gimp_context_set_background(rgb)
end

def context_set_fgcolor(rgb)
  $gimp_iface.gimp_context_set_foreground(rgb)
end

def context_get_bgcolor()
  return $gimp_iface.gimp_context_get_background()[0]
end

def context_get_fgcolor()
  return $gimp_iface.gimp_context_get_foreground()[0]
end

def context_get_brush()
  return $gimp_iface.gimp_context_get_brush()[0]
end

def context_set_brush(brush_name)
  $gimp_iface.gimp_context_set_brush(brush_name)
end



class Context
  @bg
  @fg
  @brush
  def initialize()
    @bg = $gimp_iface.gimp_context_get_background()
    @fg = $gimp_iface.gimp_context_get_foreground()
    @brush =$gimp_iface. gimp_context_get_brush()
  end
  def flush_display()
    $gimp_iface.gimp_displays_flush()
  end
  def set_bg(rgb)
    @bg = rgb
   $gimp_iface. gimp_context_set_background(rgb)
  end
  def get_bg()
    @bg = $gimp_iface.gimp_context_get_background()
    return @bg
  end
  def set_fg(rgb)
    @fg = rgb
   $gimp_iface. gimp_context_set_foreground(rgb)
  end
  def get_fg
    @fg = $gimp_iface.gimp_context_get_foreground()
    return @fg
  end
  def set_brush(brush)
    @brush = brush
    $gimp_iface.gimp_context_set_brush(brush)
  end
  def get_brush()
    @brush = $gimp_iface.gimp_context_get_brush()
    return @brush
  end
end


#Drawings

#Todo: 1. Make Drawings.render
#      2. Make guard procs for Drawings and its subclasses
#      3. Make drawing groups
#      4. Documentation
#      5. Create render method


# class Drawings
#   #Add render
# end
# class Unitcircle < Drawings
#   @radius = 0
#   @x = 0
#   @y = 0
#   def initialize(x, y, radius)
#     @x = x
#     @y = y
#     @radius = radius
#   end
# end

# class Unitsquare < Drawings
#   @side_len = 0
#   @x = 0
#   @y = 0
#   def initialize(x, y, side_len)
#     @x = x
#     @y = y
#     @side_len = side_len
#   end
#   def get_position
#     return [x, y]
#   end
# end

# ^^^ Untested ^^^ #

#------------------#
# vvv  Tested  vvv #

# RGB support

#Figure out because I'm still learning ruby:
#      -How do I refer to a given instance within a method that I am defining?

#Todo:
#      -Bind @r/@g@/b between 0 and 255
#      -Add support for additional rgb functions that are in pdb


class Rgb
  @r
  @g
  @b
  @rgb
  @color_name
  def initialize(r, g, b) #This should check whether or not these are all integers
    @r = r
    @g = g
    @b = b
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end
  
  def get_rgb
    return @rgb
  end

  def set_rgb_compressed(rgb)
    @rgb = rgb
    @r = ((rgb << 8) >> 24)
    @g = ((rgb << 16) >> 24)
    @b = (rgb - @r) - @g
  end

  def get_r
    return @r
  end

  def set_r(r)
    @r = r
    @rgb = (((@rgb << 16) >> 16) + (r << 16))
  end
   
  def get_g
    return @g
  end
  
  def set_g(g)
    @g = g
    @rgb = (((@rgb << 8) >> 8) + (g << 8))
  end

  def get_b
    return @b
  end

  def set_b(b)
    @b = b
    @rgb = (((@rgb >> 8) << 8) + b)
  end

  def extract()
    rgbTemp = @rgb
    rOut = ((rgbTemp << 8) >> 24)
    gOut = ((rgbTemp << 16) >> 24)
    bOut = (rgbTemp - rOut) - gOut
    return [rOut, gOut, bOut]
  end

end
    
# ^^^  Tested  ^^^ #
#------------------#
# vvv Untested vvv #

#Guard procedures

# We're building an unsafe wrapper for now, we can implement this later
 
#class Guard < Test::Unit::TestCase
#  def test_image_exists
#    if !@imageID
#      assert(nil, "ImageID is not valid")
#    end
#    assert($gimp_iface.gimp_image_is_valid(@imageID), "ImageID is not valid")
#  end
#  def test_is_unit_circle
#    assert((Unitcircle.instance_of?(Unitcircle)), "This is not a unit circle")
#  end
#end


#Turtles

class Turtle
  @world
  @brush
  @color
  @col
  @row
  @angle
  @pen_down

  def initialize(image)
    @world = image
    @col = 0
    @row = 0
    @angle = 0
    @brush = "Circle (01)"
    @color = context_get_fgcolor()
    @pen_down = true
  end

  def get_angle
    return @angle
  end

  def teleport(x, y)
    @col = x
    @row = y
  end

  def set_color(rgb)
    @color = rgb
  end

  def set_brush(brush_name)
    @brush = brush_name
  end

  def face(degrees)
    @angle = degrees % 360
  end

  def turn(degrees)
    @angle = @angle+degrees % 360
  end

  def set_pen_up()
    @pen_down = false
  end

  def set_pen_down()
    @pen_down = true
  end

  def pen_down?()
    return @pen_down
  end

  def clone()
    turtle = self.new(@world)
    turtle.world = @world
    turtle.brush = @brush
    turtle.col = @col
    turtle.row = @row
    turtle.color = @color
    turtle.pen_down = @pen_down
    turtle.angle = @angle
    return turtle
  end

  def forward(dist)
    d2r = (@angle/180.0) * Math::PI
   
    newcol = @col + (dist * Math.cos(d2r))
    newrow = @row + (dist * Math.sin(d2r))

    color_tmp = context_get_fgcolor()
    brush_tmp = context_get_brush()
    change_color = false
    change_brush = false
    if @color != color_tmp
      change_color = true
      context_set_fgcolor(@color)
    end
    if @brush != brush_tmp
      change_brush = true
      context_set_brush(@brush)
    end
    image_draw_line(@world, @col, @row, newcol, newrow)
    @col = newcol
    @row = newrow
    if $context_preserve #doesn't seem to work? Setting $context_preserve to false in testing.rb doesn't keep from changing back
      if change_color
        context_set_fgcolor(color_tmp)
      end
      if change_brush
        context_set_brush(brush_tmp)
      end
    end
  end
end


def image_draw_line(image, x0, y0, xf, yf)
  $gimp_iface.gimp_paintbrush(image.get_layer(), 0, 4, [x0, y0, xf, yf], 0, 0)
end
