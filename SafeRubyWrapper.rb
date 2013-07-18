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

#***************************************************************
#----------            Context Tools            ----------------
#***************************************************************

# Used to call pdb functions which change or retrieve information about 
# context features within gimp

# Flushes displays so that the images displayed in windows are up to date
def context_update_displays!()
  $gimp_iface.gimp_displays_flush()
end

# context_get_bgcolor: retrieves the current background color. 
# This returns an integer, not an object
def context_get_bgcolor()
  return $gimp_iface.gimp_context_get_background()[0]
end

# context_get_fgcolor: retrieves the current foreground color. 
# This returns an integer, not an object
def context_get_fgcolor()
  return $gimp_iface.gimp_context_get_foreground()[0]
end

# context_set_bgcolor: sets the background color to rgb. 
# This does not change the color of existing images, 
# but new images will be initialized with a layer filled 
# with the background color

def _context_set_bgcolor!(rgb)
  $gimp_iface.gimp_context_set_background(rgb)
end

def context_set_bgcolor!(rgb)
  case rgb
  when Numeric
    _context_set_bgcolor!(rgb)
  when Color
    _context_set_bgcolor!(rgb.rgbInt)
  when String
    if color_name?(rgb)
      _context_set_bgcolor!(color_name_to_rgb(rgb))
    else
      raise ArgumentError, '#{rgb} is not a valid color name. Use \"context_list_colors\" to see a list of valid color names.'
    end
  else
    raise ArgumentError, 'Argument can not be represented as a color'
  end
end

# context_set_fgcolor: sets the foreground color to rgb. 
# This is the color that is used  to fill selections and draw with gimp tools

def _context_set_fgcolor!(rgb)
  $gimp_iface.gimp_context_set_foreground(rgb)
end

def context_set_fgcolor!(rgb)
  case rgb
  when Numeric
    _context_set_fgcolor!(rgb)
  when Color
    _context_set_fgcolor!(rgb.rgbInt)
  when String
    if color_name?(rgb)
      _context_set_fgcolor!(color_name_to_rgb(rgb))
    else
      raise ArgumentError, '#{rgb} is not a valid color name. Use \"context_list_colors\" to see a list of valid color names.'
    end
  else
    raise ArgumentError, 'Argument can not be represented as a color'
  end
end

# context_get_brush: Returns the current brush as a string

def context_get_brush()
  return $gimp_iface.gimp_context_get_brush()[0]
end

# context_set_brush: Takes a brush name and sets the brush accordingly

def _context_set_brush!(brush_name)
  $gimp_iface.gimp_context_set_brush(brush_name)
end

def context_set_brush!(brush_name)
  if brush_name?(brush_name)
    _context_set_brush!(brush_name)
  else
    raise ArgumentError, "#{brush_name} is not a valid brush name. Use \"context_list_brushes\" to see a list of valid brush names."
  end
end

# context-list-colors: returns an array of color names. 
# If given a string, the array only contains the names that 
# contain that string.

def context_list_colors(pattern = nil)
  if pattern == nil
    return $gimp_iface.ggimp_rgb_list()[1]
  elsif pattern.is_a? String
    names = $gimp_iface.ggimp_rgb_list()[1]
    names.select!{|element| element.include?(pattern)}
    return names
  else
    raise ArgumentError, "context_list_color_names only accepts a string as an argument"
  end
end
# context-list-brushes: returns an array of brush names. 
# If given a string, the array only contains the names that 
# contain that string.

def context_list_brushes(pattern = nil)
  if pattern == nil
    return $gimp_iface.gimp_brushes_get_list("")[1]
  elsif pattern.is_a? String
    return $gimp_iface.gimp_brushes_get_list(pattern)[1]
  else
    raise ArgumentError, "context_list_brushes only accepts a string as an argument"
  end
end

# Predicates
def color_name?(str)
  context_list_colors().include?(str)
end

def brush_name?(str)
  context_list_brushes().include?(str)
end

#This might want to be included in a Color subclass instead of being a normal method
def color_name_to_rgb(name)
  return $gimp_iface.ggimp_rgb_parse(name)[0]
end 


#Placeholder so the program compiles
class Color
  @rgbInt
  attr_reader :rgbInt
  def initialize(int)
    @rgbInt = int
  end
end

