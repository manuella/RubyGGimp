#Evan Manuella
#Marsha Fletcher

require './gimptools.rb'
require './context.rb'

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


# Questions for Sam:
#   a. do attr_writers make sense over teleport?
#   b. Should we decentralize everything, and make libraries?



#***************************************************************
#                       Normal Turtle                          *
#***************************************************************


#this is a mixin
module TurtleTraits
 

  def self.forward(world, dist, angle, row, col, color, brush)

    d2r = (angle/180.0) * Math::PI
    
    newcol = col + (dist * Math.cos(d2r))
    newrow = row + (dist * Math.sin(d2r)) 

    color_tmp = $context.get_fgcolor()
    brush_tmp = $context.get_brush()
    color_change = (color != color_tmp)
    brush_change = (brush != brush_tmp)
    
    if color_change
      $context.set_fgcolor(color)
    end
    
    if brush_change
      $context.set_brush(brush)
    end

    image_draw_line(world, col, row, newcol, newrow)
    col = newcol
    row = newrow
    
    if $context_preserve
       if color_change
         $context.set_fgcolor(color_tmp)
       end
      if brush_change
        $context.set_brush(brush_tmp)
      end
    end  
    return [row, col]
  end  
  def clone()
    turtle = self.class.new(self.world)
    turtle.world = @world
    turtle.brush = @brush
    turtle.col = @col
    turtle.row = @row
    turtle.color = @color
    turtle.pen_down = @pen_down
    turtle.angle = @angle
   return turtle
  end
end



#*********************************************
#
#*********************************************


class Turtle
  include TurtleTraits

  attr_reader :world, :col, :row, :color, :col, :row, :angle, :pen_down, :brush

  @world = -1
  @brush = 0
  @color = 0
  @col =  0
  @row = 0
  @angle = 0
  @pen_down = true
  
  def initialize(image)
    @world = image
    @col = 0
    @row = 0
    @angle = 0
    @brush = "Circle (01)"
    @color = $context.get_fgcolor()
    @pen_down = true
  end
  
  def forward(distance)
    coord = TurtleTraits.forward(@world, distance, @angle, @row, @col, @color, @brush)
    @row = coord[0]
    @col = coord[1]
  end

  def teleport(x, y)
    @col = x
    @row = y
  end

  def turn(degrees)
   @angle = ((@angle + degrees) % 360)
  end
  
  def face(direction)
    @angle = direction
  end

  protected
  attr_writer :world, :col, :row, :color, :col, :row, :angle, :pen_down, :brush
  

end

# class SaneTurtle >> Turtle
# end

#*********************************************
# Mirror Turtle                              *
#*********************************************


class MirrorTurtle
  include TurtleTraits
  
  attr_reader :rowm, :colm, :anglem, :world, :col, :row, :color, :col, :row, :angle, :pen_down, :brush
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

  def clone()
    turtle = self.clone()
    turtle.anglem = @anglem
    turtle.rowm = @rowm
    turtle.colm = @colm
    return turtle
  end

  def forward(distance)
    
    puts @angle
    puts @anglem

    
    coord = TurtleTraits.forward(@world, distance, @angle, @row,
                                 @col, @color, @brush)
    @row = coord[0]
    @col = coord[1]

    coordm = TurtleTraits.forward(@world, distance, @anglem, @rowm,
                                  @colm, @color, @brush)
    @rowm = coordm[0]
    @colm = coordm[1]

    
  end
   
  def face(degrees)
    @angle = degrees
    @anglem = 180 - degrees
  end
  
  def teleport(x, y)
    @row, @rowm = y, y
    @col, @colm = x, x
  end

  def turn(degrees)
    @angle = (degrees + @angle) % 360
    @anglem = (180 -  @angle)
  end

  attr_writer :brush

end
