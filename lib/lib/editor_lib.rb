puts "Loading Library..."

module Editor
  class Window
    def initialize
    @@window = Gtk::Window.new(options(:title))
    @@window.signal_connect( "destroy" ) { Gtk.main_quit }
    @@window.set_default_size(options(:width),options(:height))
    @@vbox = Gtk::VBox.new( false, 0)
    @@edit_box = Gtk::ScrolledWindow.new
    @@window.add( @@vbox )
    @@window.add( @@edit_box )
    UI.menu
    UI.tabs
    UI.statusbar
    @@window.show_all
    Gtk.main
    end
  end
end

class UI < Editor::Window
  def self.menu
    puts 'Loading Menu...'
 
    menubar = Gtk::MenuBar.new
    @@vbox.pack_start( menubar, false, false, 0)

    top_menu = Gtk::MenuItem.new( "File" )
    help = Gtk::MenuItem.new( "Help" )

    menubar.append( top_menu )
    menubar.append( help )

    file_menu = Gtk::Menu.new

    new_file = Gtk::MenuItem.new( "New" )
    new_file.signal_connect("activate") {
      @@statusbar.push(0, 'Temporary file: FILENAME')
    }
    open = Gtk::MenuItem.new( "Open" )
    open.signal_connect("activate") {
      UI.open
    }
    save = Gtk::MenuItem.new( "Save" )
    save.signal_connect("activate") {
      @@statusbar.push(0, 'Saved file: FILENAME')
    }
    exit = Gtk::MenuItem.new( "Exit" )
    exit.signal_connect("activate") {
      Gtk.main_quit
    }
    file_menu.append( new_file )
    file_menu.append( open )
    file_menu.append( save )
    file_menu.append( exit )

    top_menu.set_submenu( file_menu )
  
    help_menu = Gtk::Menu.new

    about = Gtk::MenuItem.new("About")
    about.signal_connect("activate") {
      about=Gtk::AboutDialog.new
      about.set_program_name("Editor")
      about.set_version("1.0")
      about.set_copyright("2012 Cyberarm")
      about.set_comments("Editor was created as a simple text editor.")
      about.set_website("https://github.com/cyberarm")
      about.set_website_label("Editor Homepage")
      about.set_authors(%w{Cyberarm})
      about.set_logo(Gdk::Pixbuf.new("D:/data/code/editor/static/icons/others/tools-hammer_and_nails.png"))
      about.show
      about.signal_connect( "destroy" ) { Gtk.main_quit }
    }
    exit = Gtk::MenuItem.new("Exit")
    exit.signal_connect("activate") {
      Gtk.main_quit
    }
    help_menu.append( about )
    help_menu.append( exit )

    help.set_submenu( help_menu )

    puts 'Loaded.'
  end

  def self.keypress &blk
      @@edit.signal_handler_disconnect @key_press_handler if @key_press_handler
      @@edit.set_events Gdk::Event::BUTTON_PRESS_MASK | Gdk::Event::BUTTON_RELEASE_MASK | Gdk::Event::KEY_PRESS_MASK
      @key_press_handler = @@edit.signal_connect("key_press_event") do |w, e|
        k = Gdk::Keyval.to_name e.keyval
        k = case
          when k == 'Return'; "\n"
          when k == 'Tab'; "\t"
        else k
        end
        blk[k]
      end
    end
  
  def self.editor
    @@edit = Gtk::SourceView.new
    @@edit.show_line_numbers = true
    @@edit.auto_indent = true
    @@edit.indent_on_tab = true
    @@edit.insert_spaces_instead_of_tabs = true
    @@edit_box.add(@@edit)
  end
  
  def self.open
    @@open = Gtk::FileChooserDialog.new("Open File",@@window,Gtk::FileChooser::ACTION_OPEN,nil,[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],[Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
    @@open.show
    if @@open.run == Gtk::Dialog::RESPONSE_ACCEPT
      @@filename=@@open.filename.gsub('\\', '/')
    end
    @@open.destroy
    if defined?(@@filename)
      @@edit.buffer.text=File.open(@@filename, 'r').read
      @@statusbar.push(0, 'Opened file: ' + @@filename)
    end
  end
  
  def self.welcome
    Gtk::Label.new("You're using Editor.\n    By: Cyberarm")
  end

  def self.tabs
    puts "Loading Tabs..."
    tabs = Gtk::Notebook.new
    @@vbox.pack_start( tabs, true, true, 0)
    tabs.prepend_page(editor)
    tabs.prepend_page(welcome, Gtk::Label.new('Welcome'))
    puts "Loaded."
  end
  
  def self.statusbar
    @@statusbar = Gtk::Statusbar.new
    @@statusbar.push(0, 'Ready.')
    @@vbox.pack_start(@@statusbar, false, false, 0)
  end
end


def data(file, mode)
  @file = File.open("#{file}", "#{mode}").read
  @data = {:file => file, :mode => mode, :data => @file}
end
puts "Loaded."