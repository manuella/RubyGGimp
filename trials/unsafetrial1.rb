require 'benchmark'

require './UnsafeSourceTrial.rb'
def unsaferun()

$i = 0

  while $i < 100000 do
    jeb = Color.new_rgb(30, 120, 110)
    
    r = jeb.r
    g = jeb.g
    b = jeb.b
    
    h = jeb.h
    s = jeb.s
    v = jeb.v
    $i += 1
  end
end


puts Benchmark.measure {unsaferun()}
