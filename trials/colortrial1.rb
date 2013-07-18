require 'benchmark'

require './ColorSourceTrial.rb'


def colorrun()
 
$i = 0


  while $i < 100000 do
    jeb = RGBColor.new(30, 120, 110)
    
    r = jeb.red()
    g = jeb.green()
    b = jeb.blue()
    
    h = jeb.hue()
    s = jeb.saturation()
    v = jeb.value()
    
    $i += 1
    
  end
  
end

puts Benchmark.measure {colorrun()}
