#Evan Manuella
#The start of a ruby wrapper library for ggimp

#!/ruby/bin/env ruby

require 'dbus'
require "test/unit"


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


class Drawings
  def render()
  end
 # def size()
 #   if instance_of?(Unitcircle)
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

    
#Guard procedures
 
class Guard < Test::Unit::TestCase
  def test_image_exists(image)
    assert($gimp_iface.gimp_image_is_valid(@imageID), "ImageID is not valid")
  end
  def test_is_unit_circle(circle)
    assert((circle.instance_of?(Unitcircle)), "This is not a unit circle")
  end
end
