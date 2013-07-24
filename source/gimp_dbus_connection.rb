#!/ruby/bin/env ruby

require 'dbus'

$bus = DBus::SessionBus.instance
$gimp_service = $bus.service("edu.grinnell.cs.glimmer.GimpDBus")
$gimp_object = $gimp_service.object("/edu/grinnell/cs/glimmer/gimp")
$gimp_object.introspect
#interface for pdb functions
$gimp_iface = $gimp_object["edu.grinnell.cs.glimmer.pdb"]
#interface for the tilestream functions
$gimp_itile = $gimp_object["edu.grinnell.cs.glimmer.gimpplus"]
