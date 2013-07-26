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

# $clamp_elements = Proc.new do |rgb_array|
#   i = 0
#   arr = []
  
#   while rgb_array[i]
#     arr << rgb_clamp(rgb_array[i])
#     i += 1
#   end
  
#   arr
# end

# rgb_flatten_proc = Proc.new do |rgb_array|
#   flatten_element = Proc.new |element| do
#     element - (element % 16)
#   end
#   rgb_array.map(|element| flatten_element.call(element))
# end
