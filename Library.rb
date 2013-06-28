#Evan Manuella
#The start of a ruby wrapper library for ggimp

#!/ruby/bin/env ruby

require 'dbus'
#require "test/unit"


$bus = DBus::SessionBus.instance
$gimp_service = $bus.service("edu.grinnell.cs.glimmer.GimpDBus")
$gimp_object = $gimp_service.object("/edu/grinnell/cs/glimmer/gimp")
$gimp_object.introspect
$gimp_iface = $gimp_object["edu.grinnell.cs.glimmer.pdb"]



class Image

  @width = 0
  @height = 0
  @imageID = -1

  def initialize(width, height)
    @width = width
    @height = height
    @imageID = $gimp_iface.gimp_image_new(width, height, 0)[0]
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
end

# ^^^  Tested  ^^^ #
#------------------#
# vvv Untested vvv #

#Drawings

#Todo: 1. Make Drawings.render
#      2. Make guard procs for Drawings and its subclasses
#      3. Make drawing groups
#      4. Documentation

#Big question for SamR
#       -Are guard procs sub classes of Test::Unit::TestCase, or their
#       own classes?


class Drawings
  #Add render

end
class Unitcircle < Drawings
  @radius = 0
  @x = 0
  @y = 0
  def initialize(x, y, radius)
    @x = x
    @y = y
    @radius = radius
  end
end

class Unitsquare < Drawings
  @side_len = 0
  @x = 0
  @y = 0
  def initialize(x, y, side_len)
    @x = x
    @y = y
    @side_len = side_len
  end
  def get_position
    return [x, y]
  end
end

# ^^^ Untested ^^^ #
#------------------#
# vvv  Tested  vvv #

# RGB support

#Todo:
#      -Bind @r/@g@/b between 0 and 255
#      -Add support for additional rgb functions that are in pdb


class Rgb
  @r
  @g
  @b
  @rgb
  def initialize(r, g, b) #This should check whether or not these are all integers
    @r = r
    @g = g
    @b = b
  end

  def get_r
    return @r
  end

  def set_r(r)
    @r = r
  end
   
  def get_g
    return @g
  end
  
  def set_g(g)
    @g = g
  end

  def get_b
    return @b
  end

  def set_b(b)
    @b = b
  end

  def compress_rgb()
    @rgb = ((@r << 16) | (@g << 8) | @b)
    return
  end 

  def extract_rgb()
    rOut = ((@rgb << 8) >> 24)
    gOut = ((@rgb << 16) >> 24)
    bOut = (@rgb - rOut) - gOut
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
