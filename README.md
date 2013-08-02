RubyGGimp
=========

Ruby &amp; GGimp

An unfinished wrapper library which allows easy use of ggimpDbus with Ruby.

Within the labs directory, you can find a setup guide.

'require UnsafeSimplify.rb' to use this wrapper

Using the GimpDBus server found here:   https://github.com/GlimmerLabs/gimp-dbus
                                       
Using DBus-Ruby found here:             https://github.com/mvidner/ruby-dbus

Hierarchy of libraries:

dbus -> gimpConnection -> images, context, gimp Tools -> drawings/drawinggroup, turtles, imagetransform color/clamp-> simplify
