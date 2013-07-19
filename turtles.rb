#Evan Manuella
#Marsha Fletcher

# A hierarchy of turtle classes. We're restructuring in order to
# show how inheritance works. We intend to make one interface.
# Under this interface, there will be the normal turtle class, and a mirror
# turtle class. They will inherit their basic traits from the interface.
# The normal turtle class and the mirror turtle class will both have sub
# classes, which are TBD.


#          ___________
#         | Interface |
#         =============
#         /          \
#        |            |
#      ______       ______
#     |Mirror|     |Normal|
#     =======      ========
#    /      \      /      \ 
#  ___       _    _      ___
# |   |     | |  | |    |   |
#  ===       =    =      ===


#!/ruby/bin/env ruby
require 'dbus'

#***************************************************************
#                       Normal Turtle                          *
#***************************************************************


#this is a mixin
module TurtleTraits
  
  attr_reader :world, :col, :row, :color, :col, :row, :angle, :pen_down

  def forward(dist)
    
    d2r = (self.angle/180.0) * Math::PI
    
    newcol = self.col + (dist * Math.cos(d2r))
    newrow = self.row + (dist * Math.sin(d2r))
    
    color_tmp = context_get_fgcolor()
    brush_tmp = context_get_brush()
    
    change_color = self.color != color_tmp
    change_brush = self.brush != brush_tmp
    
    if change_color
      context_set_fgcolor(self.color)
    end
    
    if change_brush
      context_set_brush(self.brush)
    end
    image_draw_line(self.world, self.col, self.row, newcol, newrow)
    self.col = newcol
    self.row = newrow
    
    if $context_preserve
       if change_color
         context_set_fgcolor(color_tmp)
       end
      if change_brush
        context_set_brush(brush_tmp)
      end
    end

  def clone()
    turtle = self.class.new(self.world)
    turtle.world = self.world
    turtle.brush = self.brush
    turtle.col = self.col
    turtle.row = self.row
    turtle.color = self.color
    turtle.pen_down = self.pen_down
    turtle.angle = self.angle
    return turtle
  end

  def teleport(x, y)
    self.col = x
    self.row = y
  end
  
  def turtle_turn(degrees)
   self.angle = (self.angle + degrees) % 360
  end
  
  def turtle_face(angle)
    self.angle = angle
  end

  def setPenUp()
    self.pen_down = false
  end

  def setPenDown()
    self.pen_down = true
  end 
end


#*********************************************
#
#*********************************************


class Turtle
  include TurtleTraits
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
  
  def forward(distance)
    TurtleTraits.forward(distance)
  end
end

class SaneTurtle >> Turtle
end

#*********************************************
# Mirror Turtle                              *
#*********************************************


class MirrorTurtle
  include TurtleTraits

  @world
  @brush
  @color
  @col
  @row
  @angle
  @pen_down
  @reflection_line_slope

  def initialize(image)
    @world = image
    @col = 0
    @row = 0
    @angle = 0
    @brush = "Circle (01)"
    @color = context_get_fgcolor()
    @pen_down = true
    @reflection_line_slope = 0
  end

  def forward(distance)
    line_offset = ((@reflection_line_slope - @angle).abs())

    if @angle > @reflection_line_slope
      result_angle = @reflection_line_slope - line_offset
    
    else
      result_angle = @reflection_line_slope - line_offset
    end
    
    TurtleTraits.forward(distance)

    angle_tmp = @angle
    
    @angle = result_angle
    
    TurtleTraits.forward(distance)
    
    @angle = angle_tmp
  def
end



# "Shifts" the color upon movement forward, gives one color to mirrored turtle,
# and the remaining color to the original turtle.
class ColorShiftingTurtle << MirrorTurtle
end
