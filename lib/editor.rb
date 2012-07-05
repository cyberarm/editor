require 'gtk2'
require 'gtksourceview2'
require 'mime/types'
require 'filetype'

Filetype.add(:xml, %w{svg xml dtd})

require_relative "lib/settings.rb"
require_relative "lib/editor_lib.rb"
require_relative "views/main.rb"