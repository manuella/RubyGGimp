#Evan Manuella
#Marsha Fletcher

#The start of a ruby wrapper library for ggimp

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

# These are constants to be used with the select_ellipse and 
# select_rectangle methods in the Image class. They should not be 
# changed,or the methods will not work as expected. Alternately, you 
# could memorize the numbers and use them as parameters in those 
# methods, but we're trying to make your life easier, here. 
ADD = 0
SUBTRACT = 1
REPLACE = 2
INTERSECT = 3



#Done: 
#      -Images
#      -Colors
#      -Turtles
#      -Context Procedures
#      -Selections

#***************************************************************
#----------            Context Tools            ----------------
#***************************************************************

#Used to call pdb functions which change context features within gimp


def context_update_displays()
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

#The following two functions should be integrated into Colors

def context_list_color_names()
  return $gimp_iface.ggimp_rgb_list()[1]
end

def color_name_to_rgb(name)
  return $gimp_iface.ggimp_rgb_parse(name)
end

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


# clamp is used keep numbers within a range, esp. for rgb functions
# Marsha came up with a better method of "Clamping", we should use that
# instead
def clamp(num, lbound, ubound)
  return [lbound, [num, ubound].min].max
end

def rgb_clamp(num)
  return clamp(num, 0, 255)
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


  #Takes a an Image instance, and displays it in a new window
  def show
    $gimp_iface.gimp_display_new(@imageID)
  end
  
  
  #Selects a layer to be the active drawable
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


#***************************************************************
#----------           Drawing Classes           ----------------
#***************************************************************
# (Untested)


#Todo:      


# The class stores the dimensions, location, type, and color. When asked
# to render, it renders it onto the active layer of the given image.

class Drawing

  @type
  @color
  @left
  @top
  @width
  @height
  
  attr_reader :x, :y, :width, :height, :type, :color
  
# Returns the bottom edge of the drawing
  def bottom()
    return @top + @height
  end

# Returns the right edge of the drawing
  def right()
    return @left + @width
  end

  def scale(factor)
    @left *= factor
    @top *= factor 
    @height *= factor
    @width *=  factor
    self
  end


  #Scale horizontally. Will scale coordinates in relation to the origin.
  def hscale(factor)
    @width *= factor
    @left *= factor
    self
  end

  #Scale vertically. Will scale coordinates in relation to the origin
  def vscale(factor)
    @height = @height * factor
    @top *= factor
    self
  end

  #Shifts the drawing horizontally by the given amount
  def hshift(amount)
    @left += amount
    self
  end
  
  # Shifts the drawing vertically by the given amount
  def vshift(amount)
    @top += amount
    self
  end

  #Changes the color of the drawing
  def recolor(color)
    @color = color
    self
  end
  
  #Renders the drawing onto the given image.
  def render(image)
    if (@type == "ellipse")
      image.select_ellipse(REPLACE, @top, @left, @width, @height)
      context_set_fgcolor(@color)
      image.fill_selection()
      image.select_none()
    elsif (@type == "rectangle")
      image.select_rectangle(REPLACE, @top, @left, @width, @height)
      context_set_fgcolor(@color)
      image.fill_selection()
      image.select_none()
    else
      puts "The drawing type #{@type} is invalid. It should be ellipse or rectangle."
    end
  end

  #Renders the drawing onto a new image of the given width and height
  def to_image(width, height)
    image = Image.new_blank(width, height)
    self.render(image)
    return image
  end

  #Checks if the drawing type is "ellipse"
  def ellipse?()
    return @type == "ellipse"
  end

  #Checks if the drawing can be defined as a circle
  def circle?()
    return (@height == @width) & (@type == "ellipse")
  end

  #Checks if the drawing type is "rectangle"
  def rectangle?()
    return @type == "rectangle"
  end

  #Checks if the drawing can be defined as a square
  def square?()
    return (@height == @width) & (@type == "rectangle")
  end
      
  protected

  def initialize(type, color, left, top, width, height)
    @type = type
    @color = color
    @left = left
    @top = top
    @width = width
    @height = height
  end

  private
  
  # Creates a new drawing ellipse, which is a unit circle. 
  # That is, a circle with diameter 1, filled in black, 
  # centered at (0,0).
  def Drawing.unit_circle()
    Drawing.new("ellipse", 0, 0, 0, 1, 1)
  end

  # Creates a new drawing rectangle, which is a unit square. 
  # That is, a square with edge-length 1, filled in black, 
  # centered at (0,0). 
  def Drawing.unit_square()
    Drawing.new("rectangle", 0, 0, 0, 1, 1)
  end

  #Creates an empty drawing. Included for the sake of completeness. 
  #Also provides a useful base case for recursion over grouped drawings. 
  def Drawing.blank()
    Drawing.new(nil, 0, 0, 0, 0, 0)
  end  
end

#********************************************
#---------       DrawingGroup     -----------
#********************************************

class DrawingGroup
  @drawingArray
  @currentIndex
  
  #initialize : make an empty array, set currentIndex to -1
  def initialize()
    @drawingArray = []
    @currentIndex = 0
  end

  attr_reader :drawingArray

  # add: Adds a drawing or drawing group to the array, set currentIndex
  def add(new_element)
    if new_element.kind_of? DrawingGroup
      @drawingArray = (@drawingArray << new_element.drawingArray).flatten
    elsif new_element.kind_of? Drawing
      @drawingArray << new_element
    else
      # Make this an error instead of a printed statement
      puts "The element is not a drawing or a drawing group."
    end
  end

  #render: given an image, renders the drawing group in that image. 
  #Any current selections are ignored 
  
  def render(image)
    i = 0
    len = @drawingArray.length()
    begin
      @drawingArray[i].render(image)
    end while i > len  
    end

  #to_image: renders the drawing group in a new image with the given 
  #width and height. Returns an imageID
  
  def to_image(width, height)
    newimage = Image.new_blank(width, height)
    len = @drawingArray.length()
    i = 0
    while i < len
      @drawingArray[i].render(newimage)
      i += 1
    end 
    return newimage
  end
  
end

#********************************************
#---------          Gimp Tools    -----------
#********************************************

def image_draw_line(image, x0, y0, xf, yf)
  $gimp_iface.gimp_paintbrush(image.active_layer(), 0, 4, [x0, y0, xf, yf], 0, 0)
end

#***************************************************************
#----------                Color Class            ----------------
#***************************************************************

#Todo:
#      -Add support for additional rgb functions that are in pdb
#      -Add support for @name



class Color

  @r
  @g
  @b
  @rgbInt
  @hex
  @name

  
  attr_reader :r, :g, :b, :rgb, :hex, :name

  def b=(b)
    @b = b
    @rgbInt = (((@rgbInt >> 8) << 8) + b) #See set_rgb
    update_hsv()
    update_hex()
  end

  def g=(g)
    @g = g
    @rgbInt = (((@rgbInt << 8) >> 8) + (g << 8)) #see set_rgb
    update_hsv()
    update_hex()
  end
  
  def r=(r)
    @r = r
    @rgbInt = (((@rgbInt << 16) >> 16) + (r << 16)) #see set_rgb
    update_hsv()
    update_hex()
  end
   
  def rgbInt=(rgb)
    @rgbInt = rgb
    @r = ((rgb << 8) >> 24) #Shift left to remove digits to the left
    @g = ((rgb << 16) >> 24) #Shift right to remove digits to the right
    @b = ((rgb - @r) - @g)    #All that remains is the relevent digits
    update_hsv()
    update_hex()
  end

  def lighter()
    @r = rgb_clamp(@r + 16)
    @g = rgb_clamp(@g + 16)
    @b = rgb_clamp(@b + 16)
    @rgbInt = ((@r << 16) | (@g << 8) | @b)
    update_hsv()
    update_hex()
  end
    
  def darker
    @r = rgb_clamp(@r - 16)
    @g = rgb_clamp(@g - 16)
    @b = rgb_clamp(@b - 16)
    @rgbInt = ((@r << 16) | (@g << 8) | @b) 
    update_hsv()
    update_hex()
  end

  def redder
    @r = rgb_clamp(@r + 32)
    @rgbInt = ((@r << 16) | (@g << 8) | @b)
    update_hsv()
    update_hex()
  end
  
  def greener
    @g = rgb_clamp(@g + 32)
    @rgbInt = ((@r << 16) | (@g << 8) | @b)
    update_hsv()
    update_hex()
  end
  
  def bluer 
    @b = rgb_clamp(@b + 32)
    @rgbInt = ((@r << 16) | (@g << 8) | @b)
    update_hsv()
    update_hex()
  end
 
  def initialize(val, type)
    if (type == "rgb_array")
      @rgbInt = ((val[0] << 16) | (val[1]  << 8) | val[2])
      @r = val[0]
      @g = val[1]
      @b = val[2]
      update_hsv()
      update_hex()
    elsif type == "hsv_array"
      @h = val[0]
      @s = val[1]
      @v = val[2]
      update_rgb("hsv")
      update_hex()
    elsif type == "hex_string"
      @hex = val
      update_rgb("hex")
      update_hsv()
    end         
  end

  protected

  def update_hsv() #rgb must be the most up-to-date value
    newR = @r/255.0
    newG = @g/255.0
    newB = @b/255.0
    max = [newR, newG, newB].max
    min = [newR, newG, newB].min
    delta = max - min
    h = 0
    s = delta / max
    v = max
    if delta == 0
      h = 0
    elsif newR.eql?(max)
      h = 60 * (((newG - newB)/delta) % 6)
    elsif newG.eql?(max)
      h = 60 * (((newB - newR)/delta) + 2)
    else
      h = 60 * (((newR - newG)/delta) + 4)
    end
    @hsv = [h, s, v]
    @h = h
    @s = s
    @v = v
  end

  def update_hex()
    puts @r
    hex_r = @r.to_s(16)
    hex_g = @g.to_s(16)
    hex_b = @b.to_s(16)
    @hex = hex_r + hex_g + hex_b
  end
  
  def update_rgb(type)
    if (type == "hex")
      @r = @hex[0, 2].hex
      @g = @hex[2, 2].hex
      @b = @hex[4, 2].hex
    elsif (type == "hsv")
      hi = (@h / 60).floor & 6
      f = (@h / 60.0) - hi
      p = @v * (1 - @s)
      q = @v * (1 - (f * @s))
      t = @v * (1 - (@s * (1 - f))) 
      if hi == 0
        @r = (255 * @v).round()
        @g = (255 * t).round()
        @b = (255 * p).round()
      elsif hi == 1
        @r = (255 * q).round()
        @g = (255 * @v).round()
        @b = (255 * p).round()
      elsif hi == 2
        @r = (255 * p).round()
        @g = (255 * @v).round()
        @b = (255 * t).round()
      elsif hi == 3
        @r = (255 * p).round()
        @g = (255 * q).round()
        @b = (255 * @v).round()
      elsif hi == 4
        @r = (255 * t).round()
        @g = (255 * p).round()
        @b = (255 * @v).round()
      else 
        @r = (255 * @v).round()
        @g = (255 * p).round()
        @b = (255 * q).round()
      end  
        
    end
    @rgbInt = ((@r << 16) | (@g << 8) | @b)
  end
  
  private

  def Color.new_rgb(r, g, b)
    r = rgb_clamp(r)
    g = rgb_clamp(g)
    b = rgb_clamp(b)
    rgb_array = [r, g, b]
    Color.new(rgb_array, "rgb_array")
  end
  
  def Color.new_hsv(h, s, v)
    hsv_array= [h, s, v]
    Color.new(hsv_array, "hsv_array")
  end
  
  def Color.new_hex(hex_string)
    Color.new(hex_string, "hex_string")
  end

  #private :new_rgb, :new_hsv, :new_hex
  #protected :update_hsv, :update_hex, :update_rgb

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

    change_color = @color != color_tmp
    change_brush = @brush != brush_tmp

    if change_color
      context_set_fgcolor(@color)
    end

    if change_brush
      context_set_brush(@brush)
    end

    image_draw_line(@world, @col, @row, newcol, newrow)
    @col = newcol
    @row = newrow

    if $context_preserve #doesn't seem to work? Setting $context_preserve to false in testing.rb does not change the brush/color back
      if change_color
        context_set_fgcolor(color_tmp)
      end
      if change_brush
        context_set_brush(brush_tmp)
      end
    end
  end
end
