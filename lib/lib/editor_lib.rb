puts "Loading Library..."

module Editor
  class Window
    def initialize
    @@files = []
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
      UI.save
    }
    exit = Gtk::MenuItem.new( "Exit" )
    exit.signal_connect("activate") {
      Gtk.main_quit
    }
    #file_menu.append( new_file )
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
      about.signal_connect( "destroy" ) { about.hide }
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
  
  def self.editor
    @@edit = Gtk::SourceView.new
    @@edit.show_line_numbers = true
    @@edit.auto_indent = true
    @@edit.indent_on_tab = true
    @@edit.insert_spaces_instead_of_tabs = true
    if defined?(@@filename)
      @@edit.buffer.language = Gtk::SourceLanguageManager.new.get_language('text')
    end
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
      @@edit.buffer.language = Gtk::SourceLanguageManager.new.get_language(Filetype.get(@@filename).to_s)
      p @@the_thing.set_tab_label_text(@@e,"#{File.basename(@@filename)} - (Editor)")
      @@the_thing.set_page(1)
      if @@edit.buffer.text == File.open(@@filename,'r').read
        @@statusbar.push(0, 'Opened file: ' + @@filename)
        @@window.set_title("#{@@filename} - Editor")
      else
        @@statusbar.push(0, 'Unable to open: \'' + @@filename + '\', is it a text file?')
      end
    end
  end
  
  def self.save
    if defined?(@@filename)
      File.open(@@filename, 'w') do |f|
        f.write @@edit.buffer.text
      end
      @@statusbar.push(0, 'Saved file: '+@@filename)
    else
      @@save = Gtk::FileChooserDialog.new("Open File",@@window,Gtk::FileChooser::ACTION_SAVE,nil,[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],[Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
      @@save.show
      if @@save.run == Gtk::Dialog::RESPONSE_ACCEPT
        @@filename = @@save.filename.gsub('\\', '/')
      elsif @@save.run == Gtk::Dialog::RESPONSE_CANCEL
        @@filename = nil
      end
      @@save.destroy
      @@the_thing.set_page(1)
      @@window.set_title("#{@@filename} - Editor")
    end
  end
  
  def self.welcome
    @@welcome = Gtk::Label.new("Welcome to Editor.\nEnjoy.")
  end
  
  def self.settings
    @@frame = Gtk::VBox.new(true,10)
    @@frame.modify_base Gtk::STATE_NORMAL, Gdk::Color.parse('#333111222')
    @@s = @@the_thing.prepend_page(@@frame, Gtk::Label.new("Settings"))
    title = Gtk::Label.new('Settings')
    title_width = Gtk::Label.new('Window Width')
    title_height = Gtk::Label.new('Window Height')
    width = Gtk::Entry.new
    height = Gtk::Entry.new
    @@frame.add(title)
    @@frame.add(title_width)
    @@frame.add(width)
    @@frame.add(title_height)
    @@frame.add(height)
  end

  def self.tabs
    puts "Loading Tabs..."
    tabs = Gtk::Notebook.new
    #p tabs.set_tab_reorderable(tabs, @@e)
    tabs.set_enable_popup(true)
    @@the_thing = tabs
    @@vbox.pack_start( tabs, true, true, 0)
    settings
    @@e = tabs.prepend_page(editor, Gtk::Label.new("Editor"))
    @@w = tabs.prepend_page(welcome, Gtk::Label.new('Welcome'))
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