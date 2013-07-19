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
 #         ============
 #         /          \
 #        |            |
 #      ______       ______
 #     |Mirror|     |Normal|
 #     =======      ========
 #    /      \      /      \ 
 #  ___     _       _      ___
 # |   |   | |     | |    |   |
 #  ===    ==      ===     ===


#!/ruby/bin/env ruby
require 'dbus'

#***************************************************************
#----------             Turtle Class            ----------------
#***************************************************************


#this is a mixin
module TurtleTraits
  
  attr_reader :world, :col, :row, :color, :col, :row, :angle, :pen_down

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
    
    if $context_preserve
       if change_color
         context_set_fgcolor(color_tmp)
       end
      if change_brush
        context_set_brush(brush_tmp)
      end
    end
  end
end

class MirrorTurtle
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
  
  def forward
    #not yet implemented
  end
  
end
