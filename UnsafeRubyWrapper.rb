#Evan Manuella
#Marsha Fletcher

#The start of a ruby wrapper library for ggimp

#!/ruby/bin/env ruby

require 'dbus'
#require "test/unit"


$bus = DBus::SessionBus.instance
$gimp_service = $bus.service("edu.grinnell.cs.glimmer.GimpDBus")
$gimp_object = $gimp_service.object("/edu/grinnell/cs/glimmer/gimp")
$gimp_object.introspect
$gimp_iface = $gimp_object["edu.grinnell.cs.glimmer.pdb"]


#Done: 
#      -Images
#      -Basic RGB
#      -Turtles
#      -Context Procedures

#***************************************************************
#----------            Context Tools            ----------------
#***************************************************************

def context_display_flush()
  $gimp_iface.gimp_displays_flush()
end

def context_set_bgcolor(rgb)
  if rgb.instance_of? Integer
    $gimp_iface.gimp_context_set_background(rgb)
  elsif rgb.instance_of? Rgb
    $gimp_iface.gimp_context_set_background(rgb.get_rgb)
  else
    #what are you giving us? Have an error!
  end
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

#This context class is unused. We do not think modeling context
#like this makes sense, but if we're told other wise, we'll move
#back to this vvv code.

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

#***************************************************************
#----------            Image Class              ----------------
#***************************************************************

class Image

  @width
  @height
  @imageID
  @active_layer

  def initialize(width, height)
    @width = width
    @height = height
    @imageID = $gimp_iface.gimp_image_new(width, height, 0)[0]
    @active_layer = $gimp_iface.gimp_layer_new(@imageID, width,
                                               height, 0, "Background",
                                               100, 0)[0]

    $gimp_iface.gimp_image_insert_layer(@imageID, @active_layer, 0, 0)
    $gimp_iface.gimp_edit_bucket_fill(@active_layer, 1, 
                                      0, 100, 255, 0, 0, 0)

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


#***************************************************************
#----------           Drawing Classes           ----------------
#***************************************************************
# (Untested)


#Todo: 1. Complete drawings
#      


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

def image_draw_line(image, x0, y0, xf, yf)
  $gimp_iface.gimp_paintbrush(image.get_layer(), 0, 4, [x0, y0, xf, yf], 0, 0)
end

#***************************************************************
#----------                Rgb Class            ----------------
#***************************************************************

#Todo:
#      -Bind @r/@g@/b between 0 and 255
#      -Add support for additional rgb functions that are in pdb
#      -Possibly add support for html and HSV colors

class Rgb
  @r
  @g
  @b
  @rgb
  def initialize(r, g, b)
    @r = r
    @g = g
    @b = b
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end
  
  def extract()
    rgbTemp = @rgb
    rOut = ((rgbTemp << 8) >> 24)
    gOut = ((rgbTemp << 16) >> 24)
    bOut = (rgbTemp - rOut) - gOut
    return [rOut, gOut, bOut]
 end

  def get_b
    return @b
  end 

  def get_g
    return @g
  end

  def get_r
    return @r
  end 

  def get_rgb
    return @rgb
  end

  def set_b(b)
    @b = b
    @rgb = (((@rgb >> 8) << 8) + b) #See set_rgb
  end

  def set_g(g)
    @g = g
    @rgb = (((@rgb << 8) >> 8) + (g << 8)) #see set_rgb
  end

  def set_r(r)
    @r = r
    @rgb = (((@rgb << 16) >> 16) + (r << 16)) #see set_rgb
  end
   
  def set_rgb(rgb)
    @rgb = rgb
    @r = ((rgb << 8) >> 24) #Shift left to remove digits to the left
    @g = ((rgb << 16) >> 24) #Shift right to remove digits to the right
    @b = (rgb - @r) - @g    #All that remains is the relevent digits
  end
  
  def i_to_rgb(int_color) #Converts an Rgb int into an actual rgb
    i_r = (int_color << 8) >> 24
    i_g = (int_color << 16) >> 24
    i_b = (int_color << 24) >> 24
    return Rgb.new(i_r, i_g, i_b)
  end
end

#***************************************************************
#----------             Turtle Class            ----------------
#***************************************************************


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


