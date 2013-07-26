# Functions to be used with image compute need to meet the following 
# requirements:
## Be a Proc object
## Take a 3 element array of ints (which describes an rgb color)
## Return a 3 element array of ints (also describes an rgb color)
## Image#compute will clamp the ints to be between 0 and 255

#!ruby/bin/env ruby

$rgb_redder_proc = Proc.new do |rgb_array|
  [rgb_array[0] += 32,
   rgb_array[1],
   rgb_array[2]]
end

$rgb_greener_proc = Proc.new do |rgb_array|
  [rgb_array[0],
   rgb_array[1] += 32,
   rgb_array[2]]
end

$rgb_bluer_proc = Proc.new do |rgb_array|
  [rgb_array[0],
  rgb_array[1],
  rgb_array[2] += 32]
end    

$rgb_kill_all_green = Proc.new do |rgb_array|
  [rgb_array[0],
   0,
   rgb_array[2]]
end

#x and y are the coordinates of the pixel that is being transformed
$rgb_smooth_gradient = Proc.new do |rgb_array, x, y|
  [rgb_clamp(( x * rgb_array[0])),
   rgb_clamp(( x * rgb_array[1])),
   rgb_clamp(( x * rgb_array[2]))]
end
