puts "Loading settings..."

def options(key)
  options = {
      :width => 1000,
      :height => 500,
      :title => 'Editor',
      :background => '#222'..'#888',
      :code_width => 980,
      :code_height => 440
    }
    unless key.to_s.include?(':')
      key = key.to_sym
      return options[key]
    else
      return options[key]
    end
  end
      
  keyboard = {
    :save => 'left_ctrl s',
    :open => 'left_ctrl o'
  }
puts "loaded."