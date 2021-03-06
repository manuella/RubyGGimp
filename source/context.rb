#Evan Manuella
#Marsha Fletcher

# This is a global class which emcompasses all of the contextual 
# settings of gimp.

#!/ruby/bin/env ruby

require './gimp_dbus_connection.rb'

# Note: the user could manually set fg/bgcolors in gimp, which would break
# concurency of this class.

# Note: This is to protect the user from inputing a non-extant brush. Calling
# such a brush will yield an internal error in gimp

# Note: None of this is safe



class Context
  include Singleton

  @bgcolor
  @fgcolor 
  @brush
   
  def update_displays()
    $gimp_iface.gimp_displays_flush()
  end

  def update()
    @bgcolor = $gimp_iface.gimp_context_get_background()[0]
    @fgcolor = $gimp_iface.gimp_context_get_foreground()[0]
    @brush = $gimp_iface.gimp_context_get_brush()[0]
    return 0
  end

  def set_bgcolor(rgb)
    @bgcolor = rgb
    $gimp_iface.gimp_context_set_background(rgb)
  end
  
  def set_fgcolor(rgb)
    @fgcolor = rgb
    $gimp_iface.gimp_context_set_foreground(rgb)
  end
  
  def get_bgcolor() 
    @bgcolor = $gimp_iface.gimp_context_get_background()[0]
    return $gimp_iface.gimp_context_get_background()[0]
  end
  
  def get_fgcolor()
    @fgcolor = $gimp_iface.gimp_context_get_foreground()[0]
    return @fgcolor
  end
  
  def get_brush()
    @brush = $gimp_iface.gimp_context_get_brush()[0]
    return @brush
  end
  
  def set_brush(brush_name)
    @brush = brush_name
    $gimp_iface.gimp_context_set_brush(brush_name)
  end
end
$context = Context.instance()
