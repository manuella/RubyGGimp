#!/ruby/bin/env ruby

require 'dbus' 

def rgb_to_int(r, g, b)
   ((r << 16) | (g << 8) | b)
end

def hex_to_rgb(hex_num)
  #requires a 6 digit string in hexadecimal
  r = hex_num[0, 2].hex
  g = hex_num[2, 2].hex
  b = hex_num[4, 2].hex
end

def hsv_to_rgb(h, s, v)
  hi = (h / 60).floor & 6
  f = (h / 60.0) - hi
  p = v * (1 - s)
  q = v * (1 - (f * s))
  t = v * (1 - (s * (1 - f))) 
  if hi == 0
    return [(255 * v), (255 * t), (255 * p)]
  elsif hi == 1
    return [(255 * q), (255 * v), (255 * p)]
  elsif hi == 2
    return [(255 * p), (255 * v), (255 * t)]
  elsif hi == 3
    return [(255 * p), (255 * q), (255 * v)]
  elsif hi == 4
    return [(255 * t), (255 * p), (255 * v)]
  else 
    return [(255 * v), (255 * p), (255 * q)]
  end
  
end


class Color
  @rgbInt
  attr_reader :rgbInt

  def initialize (int)
    int = [0, ([int, 16777215].min)].max
    @rgbInt = int
  end

  def red
    (@rgbInt & 16711680) >> 16
  end

  def green
    (@rgbInt & 65280) >> 8
  end

  def blue
    @rgbInt & 255
  end

  def hue
    newR = red()/255.0
    newG = green()/255.0
    newB = blue()/255.0
    max = [newR, newG, newB].max
    delta = max - [newR, newG, newB].min

    if delta == 0
      return 0
    elsif newR.eql?(max)
      return 60 * (((newG - newB)/delta) % 6)
    elsif newG.eql?(max)
      return 60 * (((newB - newR)/delta) + 2)
    else
      return 60 * (((newR - newG)/delta) + 4)
    end
  end

  def saturation
    newR = red()/255.0
    newG = green()/255.0
    newB = blue()/255.0
    max = [newR, newG, newB].max
    delta = max - [newR, newG, newB].min
    delta / max
  end

  def value
    newR = red()/255.0
    newG = green()/255.0
    newB = blue()/255.0

    [newR, newG, newB].max
  end

  def hexValue
    @rgbInt.to_s(16)
  end

end

class RGBColor < Color
  @r
  @g
  @b

  def initialize (r, g, b)
    @r = r
    @g = g
    @b = b
    @rgbInt = ((@r << 16) | (@g << 8) | @b)
  end

  def red
    @r
  end

  def green
    @g
  end

  def blue
    @b
  end

  def to_HSVColor
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
    HSVColor.new(h, s, v)
  end

end

class HSVColor < Color
  @h
  @s
  @v

  def initialize (h, s, v)
    @h = h
    @s = s
    @v = v
  end

  def hue
    @h
  end

  def saturation
    @s
  end
  
  def value
    @v
  end
end

class HexColor < Color
  @hexString

  def initialize(hex_string)
    
    @hexString = hex_string
    @rgbInt = @hexString.to_i(16)
  end

end

class NameColor < Color
  @name
  def initialize(colorname)
    @name = colorname
    @rgbInt = $gimp_iface.ggimp_rgb_parse(name)[0]
  end
  
end
