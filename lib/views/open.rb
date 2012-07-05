=begin
Shoes.app do
  button 'Open' do
    @file_ = ask_open_file
    @file_ = @file_.gsub('\\', '/')
    puts "Loading: #{@file_}"
    data("#{@file_}", 'r')
    require_relative "main.rb"
    puts "Loaded."
  end
end
=end
require_relative "main.rb"