#!ruby/bin/env ruby

require './UnsafeSimplify.rb'


ted = Image.new_blank(4000, 4000)

$context.set_fgcolor(124567)

bucket_fill(ted, 100, 100)

ted.compute($rgb_smooth_gradient)

ted.show()


