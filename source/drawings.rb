#***************************************************************
#----------           Drawing Classes           ----------------
#***************************************************************

require './images.rb'
require './context.rb'

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

    case @type
    when "ellipse"
      image.select_ellipse(REPLACE, @top, @left, @width, @height)
      $context.set_fgcolor(@color)
      image.fill_selection()
      image.select_none()

    when "rectangle"
      image.select_rectangle(REPLACE, @top, @left, @width, @height)
      $context.set_fgcolor(@color)
      image.fill_selection()
      image.select_none()

    else
      raise Argument "Field @type is invalid drawing type"
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

    case new_element
    when DrawingGroup
      @drawingArray = (@drawingArray << new_element.drawingArray).flatten
    when Drawing
      @drawingArray << new_element
    else
      raise Argument "New_element (#{@new_element}) is not a valid input"
    end
    
  end
  
  #render: given an image, renders the drawing group in that image. 
  #Any current selections are ignored 
  
  def render(image)
    i = 0
    len = @drawingArray.length()
    begin
      @drawingArray[i].render(image)
      i += 1
    end while i < len
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
