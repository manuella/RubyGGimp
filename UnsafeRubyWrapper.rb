#Evan Manuella
#Marsha Fletcher

#The start of a ruby wrapper library for ggimp


#***************************************************************
 # Things we learned from feedback
 # Technique:
 #    -Use "setters"
 #    -Classes should always be internally consistant
 #        -e.x: inputing rgb components should set the
 #         fields for the int. rgb rep and HSV representations
 #         as well
 #    -Images should use multiple constructors
 #        -Loaded image should not be a sub-class of Image
 #    -Camel Case for classes
#***************************************************************

#***************************************************************
 # Things we learned from book
 # Technique:
 #    -Use attr_reader
 #    -class.attribute = value would be creates as def attribute=(value)
 #        -or with attr_writer :attribute
 #    -Use Virtual attributes for Color
 #    -Make sure that methods which will break internal state are not
 #     available to the user. (page 38 of Programming Ruby)
 #        -These should be set as protected methods 
 #            -Setting a component without revising internal state
 #        
#***************************************************************

#***************************************************************
#--- Set up the Ruby/Dbus environment, then aquire the proxy  --
#***************************************************************

#!/ruby/bin/env ruby

require 'dbus'

$bus = DBus::SessionBus.instance
$gimp_service = $bus.service("edu.grinnell.cs.glimmer.GimpDBus")
$gimp_object = $gimp_service.object("/edu/grinnell/cs/glimmer/gimp")
$gimp_object.introspect
$gimp_iface = $gimp_object["edu.grinnell.cs.glimmer.pdb"]

$ADD = 0
$SUBTRACT = 1
$REPLACE = 2
$INTERSECT = 3

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

def flush_displays()
  $gimp_iface.gimp_displays_flush()
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


#to keep numbers within a range, esp. for rgb functions
def clamp(num, lbound, ubound)
  if num < lbound
    num = lbound
  end
  if num > ubound
    num = ubound
  end
  return num
end

def rgb_clamp(num)
  return clamp(num, 0, 255)
end
     

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
  

  attr_reader :width, :height, :imageID, :active_layer


  def show
    $gimp_iface.gimp_display_new(@imageID)
  end
  
  def set_active_layer(layerID)
    layerList = $gimp_iface.gimp_image_get_layers(@imageID)[1]
    if layerList.include? layerID
      @active_layer = layerID
    else
      puts "Invalid layer ID for this image: #{@imageID}"
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
  
  def Image.new_blank(width, height) 
    imageID = $gimp_iface.gimp_image_new(width, height, 0)[0]
    active_layer = $gimp_iface.gimp_layer_new(imageID, width,
                                              height, 0, "Background",
                                              100, 0)[0]
    $gimp_iface.gimp_image_insert_layer(imageID, active_layer, 0, 0)
    $gimp_iface.gimp_drawable_fill(active_layer, 1)
    Image.new(width, height, imageID, active_layer)
  end


  def Image.new_loaded(path)
    imageID = $gimp_iface.gimp_file_load(0, path, path)[0]
    width = $gimp_iface.gimp_image_width(imageID)
    height = $gimp_iface.gimp_image_height(imageID)
    active_layer = $gimp_iface.gimp_image_get_active_layer(imageID)
    Image.new(width, height, imageID, active_layer)
  end

  protected
  
  def initialize(width, height, imageID, active_layer)
    @width = width
    @height = height
    @imageID = imageID
    @active_layer = active_layer
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
    @r = rgb_clamp(r)
    @g = rgb_clamp(g)
    @b = rgb_clamp(b)
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end
  
  attr_reader :r, :g, :b, :rgb

  def b=(b)
    @b = b
    @rgb = (((@rgb >> 8) << 8) + b) #See set_rgb
  end

  def g=(g)
    @g = g
    @rgb = (((@rgb << 8) >> 8) + (g << 8)) #see set_rgb
  end
  
  def r=(r)
    @r = r
    @rgb = (((@rgb << 16) >> 16) + (r << 16)) #see set_rgb
  end
   
  def rgb=(rgb)
    @rgb = rgb
    @r = ((rgb << 8) >> 24) #Shift left to remove digits to the left
    @g = ((rgb << 16) >> 24) #Shift right to remove digits to the right
    @b = (rgb - @r) - @g    #All that remains is the relevent digits
  end

  def lighter()
    @r = rgb_clamp(@r + 16)
    @g = rgb_clamp(@g + 16)
    @b = rgb_clamp(@b + 16)
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end
    
  def darker
    @r = rgb_clamp(@r - 16)
    @g = rgb_clamp(@g - 16)
    @b = rgb_clamp(@b - 16)
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end

  def redder
    @r = rgb_clamp(@r + 32)
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end
  
  def greener
    @g = rgb_clamp(@g + 32)
    @rgb = ((@r << 16) | (@g << 8) | @b)
  end
  
  def bluer #ew
    @b = rgb_clamp(@b + 32)
    @rgb = ((@r << 16) | (@g << 8) | @b)
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

  attr_reader :world, :color, :angle, :pen_down, :brush

  attr_writer :color, :brush

  def teleport(x, y)
    @col = x
    @row = y
  end

  def face(degrees)
    @angle = degrees % 360
  end

  def turn(degrees)
    @angle = @angle+degrees % 360
  end

  def setPenUp()
    @pen_down = false
  end

  def setPenDown()
    @pen_down = true
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


