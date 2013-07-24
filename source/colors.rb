#***************************************************************
#----------                Color Class            ----------------
#***************************************************************

#Todo:
#      -Add support for additional rgb functions that are in pdb
#      -Add support for @name


require './gimptools.rb'


class Color

  @r
  @g
  @b
  @hsv
  @h
  @s
  @v
  @rgbInt
  @hex
  @name
  
  attr_reader :r, :g, :b, :rgb, :hex, :name, :h, :s, :v, :hsv

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
    
    case type
    when "rgb_array"
      @rgbInt = ((val[0] << 16) | (val[1]  << 8) | val[2])
      @r = val[0]
      @g = val[1]
      @b = val[2]
      update_hsv()
      update_hex()
    when "hsv_array"
      @h = val[0]
      @s = val[1]
      @v = val[2]
      update_rgb("hsv")
      update_hex()
    when "hex_string"
      @hex = val
      update_rgb("hex")
      update_hsv()
    else
      
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
     
      case hi
      when 0
        @r = (255 * @v).round()
        @g = (255 * t).round()
        @b = (255 * p).round()
      when 1
        @r = (255 * q).round()
        @g = (255 * @v).round()
        @b = (255 * p).round()
      when 2
        @r = (255 * p).round()
        @g = (255 * @v).round()
        @b = (255 * t).round()
      when 3 
        @r = (255 * p).round()
        @g = (255 * q).round()
        @b = (255 * @v).round()
      when 4
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
end
