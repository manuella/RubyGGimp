#***************************************************************
#----------            Image Class              ----------------
#***************************************************************

require './gimp_dbus_connection.rb'

class Image

  @width
  @height
  @imageID
  @active_layer

  attr_reader :width, :height, :imageID, :active_layer


  #Takes a an Image instance, and displays it in a new window
  def show
    $gimp_iface.gimp_display_new(@imageID)
  end
  
  
  #Selects a layer to be the active drawable
  def set_active_layer(layerID)
    layerList = $gimp_iface.gimp_image_get_layers(@imageID)[1]
    if layerList.include? layerID
      @active_layer = layerID
    else
      raise Arguement "Invalide layer ID for this image: #{@imageID}"
    end
    
  end


  def fill_selection
    $gimp_iface.gimp_edit_fill(@active_layer, 0)
  end

  def stroke_selection
     $gimp_iface.gimp_edit_stroke(@active_layer)
  end

  def select_rectangle(operation, x, y, width, height)
    $gimp_iface.gimp_image_select_rectangle(@imageID, operation, 
                                            x, y, width, height)
  end

  def select_ellipse(operation, x, y, width, height)
    $gimp_iface.gimp_image_select_ellipse(@imageID, operation, 
                                          x, y, width, height)
  end

  def select_none
    $gimp_iface.gimp_selection_none(@imageID)
  end
  
  private

  #Initializes a new instance of Image, which is completely blank
  def Image.new_blank(width, height) 
    imageID = $gimp_iface.gimp_image_new(width, height, 0)[0]
    active_layer = $gimp_iface.gimp_layer_new(imageID, width,
                                              height, 0, "Background",
                                              100, 0)[0]
    $gimp_iface.gimp_image_insert_layer(imageID, active_layer, 0, 0)
    $gimp_iface.gimp_drawable_fill(active_layer, 1)
    Image.new(width, height, imageID, active_layer)
  end

  # Initializes a new instance of Image which loads a previously
  # saved image
  def Image.new_loaded(path)
    imageID = $gimp_iface.gimp_file_load(0, path, path)[0]
    width = $gimp_iface.gimp_image_width(imageID)
    height = $gimp_iface.gimp_image_height(imageID)
    active_layer = $gimp_iface.gimp_image_get_active_layer(imageID)
    Image.new(width, height, imageID, active_layer)
  end

  protected
  
  #This should only be called by new_blank and new_loaded
  def initialize(width, height, imageID, active_layer)
    @width = width
    @height = height
    @imageID = imageID
    @active_layer = active_layer
  end
end
