#Evan Manuella
#Marsha Fletcher

# A hierarchy of turtle classes. We're restructuring in order to
# show how inheritance works. We intend to make one interface.
# Under this interface, there will be the normal turtle class, and a mirror
# turtle class. They will inherit their basic traits from the interface.
# The normal turtle class and the mirror turtle class will both have sub
# classes, which are TBD.


#     ________  _____   _________
#     |Mirror|-|mixin|- |Normal|
#     =======   =====   ========
#    /      \           /      \ 
#  ___       _          _      ___
# |   |     | |        | |    |   |
#  ===       =          =      ===


#!/ruby/bin/env ruby
require 'dbus'
require './UnsafeRubyWrapper.rb'
#cyclic dependencies

#***************************************************************
#                       Normal Turtle                          *
#***************************************************************


#this is a mixin
module TurtleTraits
  
  attr_reader :world, :col, :row, :color, :col, :row, :angle, :pen_down

  def forward(dist, angle, row, col)
    
    d2r = (angle/180.0) * Math::PI
    
    newcol = col + (dist * Math.cos(d2r))
    newrow = row + (dist * Math.sin(d2r))
    
    color_tmp = context.get_fgcolor()
    brush_tmp = context.get_brush()
    
    change_color = self.color != color_tmp
    change_brush = self.brush != brush_tmp
    
    if change_color
      $context.set_fgcolor(self.color)
    end
    
    if change_brush
      $context.set_brush(self.brush)
    end
    image_draw_line(self.world, col, row, newcol, newrow)
    col = newcol
    row = newrow
#****
    puts "col: #{col}, row: #{row}"
#****
    return [row, col]
    
    if $context_preserve
       if change_color
         $context.set_fgcolor(color_tmp)
       end
      if change_brush
        $context.set_brush(brush_tmp)
      end
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
  
  def turn(degrees, current_angle)
    return ((current_angle + degrees) % 360)
  end
  
  def face(angle)
    return (angle % 360)
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
    @color = $context.get_fgcolor()
    @pen_down = true
  end
  
  def Turtle.forward(distance)
    coord = TurtleTraits.forward(distance, @angle, @row, @col)
    @row = coord[0]
    @col = coord[1]
  end
end

# class SaneTurtle >> Turtle
# end

#*********************************************
# Mirror Turtle                              *
#*********************************************


class MirrorTurtle
  include TurtleTraits
  
  attr_reader :rowm, :colm, :anglem

  @world
  @brush
  @color
  @col
  @row
  @angle
  @pen_down
  @colm
  @rowm
  @anglem
  
  def initialize(image)
    @world = image
    @col = 0
    @row = 0
    @angle = 0
    @brush = "Circle (01)"
    @color = $context.get_fgcolor()
    @pen_down = true
    @colm = 0
    @rowm = 0
    @anglem = 180
  end

  def MirrorTurtle.forward(distance)

    coord = TurtleTraits.forward(distance, @angle, @row, @col)
    @row = coord[0]
    @col = coord[1]

    coordm = TurtleTraits.forward(distance, @anglem, @rowm, @colm)
    @rowm = coordm[0]
    @colm = coordm[1]    
  end
  
  def MirrorTurtle.turn(degrees)
    @angle = TurtleTraits.turn(degrees, @angle)
    @anglem = TurtleTraits.turn((degrees * (-1)), @anglem)
  end
   
  def MirrorTurtle.face(degrees)
    @angle = TurtleTraits.face(degrees)
    @anglem = TurtleTraits.face(360 - degrees)
  end
  
  def MirrorTurtle.teleport(x, y)
    @row, @rowm = y, y
    @col, @colm = x, x
  end
end


# "Shifts" the color upon movement forward, gives one color to mirrored turtle,
# and the remaining color to the original turtle.
# class ColorShiftingTurtle << MirrorTurtle
# end
