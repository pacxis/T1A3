
require 'date'
require 'uuidtools'
require 'fileutils'
require 'json'
require 'tty-prompt'
require 'awesome_print'

require_relative 'classes.rb'

#------------------------OBJECTS-------------------------

main_menu = Menu.new("New Journal Entry", "View All Journal Entries", "Search Journal Entries", "Exit")

entry_categories = Emotions.new("okay", "happy", "sad", "angry", "stressed", "anxious", "suprised", "confused")

view_menu = Menu.new("By date", "By feeling", "By title alphabetical order")

# ----------------ERROR CLASSES---------------------------

# class InvalidFeeling < StandardError
#     def message(feel)
#         return "Invalid feeling entry, input one of the following: #{feel.feelings.join(', ')}"
#     end
# end

# class InvalidIntensity < StandardError
#     def message
#         return "Invalid intensity entry, input a number from 1 to 5"
#     end
# end

# class InvalidYesNo < StandardError
#     def message
#         return "Invalid entry, enter 'y' for yes and 'n' for no"
#     end
# end

#-------------------------MAIN CODE-------------------------


j_index = JSON.load_file('journal_index.json', symbolize_names: true)
prompt = TTY::Prompt.new
selection = nil

while selection != main_menu.menu_items[-1] do
    selection = ARGV[0].to_s
    if selection == ""
        selection = prompt.select("What would you like to do?", main_menu.menu_items)
    end
    case selection
    when main_menu.menu_items[0], '-n'

        year = Date.today.strftime("%Y")
        month = Date.today.strftime("%m")
        day = Date.today.strftime("%d")
        date = "#{day}/#{month}/#{year}"
        id = UUIDTools::UUID.timestamp_create.to_s
        title = prompt.ask("Please enter the title: ")
        feeling = prompt.select("What is your overall feeling today?", entry_categories.feelings)
        unless feeling == "okay"
            intensity = prompt.ask("How would you rank the intensity of this feeling from 1 to 5? (1 being the weakest)") do |num|
                num.in "1-5"
                num.messages[:range?] = "Invalid input, select a number from 1 to 5"
            end
        else
            intensity = 0
        end
        entry = prompt.ask("Type out your journal entry: ")
        
        selection = prompt.yes?("Do you want to save this entry?")
    
        if selection == true
            file = File.open("#{id}.txt", 'w')
            FileUtils.mv("#{id}.txt", "Entries/#{id}.txt")
            file << title + "\n"*2
            file << date + "\n"*2
            file << feeling + " (#{intensity})" + "\n"*2
            file << entry

            entry_info = {
              title: title,
              id: id,
              feeling: feeling,
              intensity: intensity,
              year: year.to_i,
              month: year.to_i,
              day: day.to_i
            }

            File.open('journal_index.json', 'w') do |f|
                f.puts JSON.pretty_generate(j_index << entry_info)
            end
             puts "Journal entry saved"
        else 
            puts "Journal entry discarded"
        end
    when main_menu.menu_items[1], '-v'
        selection = prompt.select("How would you like to view your entries?", view_menu.menu_items)
        # j_index.each do |etr|
        
        case selection
        when view_menu.menu_items[0]
            puts 'ere'
        when view_menu.menu_items[1]
            sorted_entries = j_index.sort { |a, b| [a[:feeling], a[:intensity]] <=> [b[:feeling], b[:intensity]] }
            # sorted_entries = j_index.sort_by { |k| k[:feeling] }
            # sorted_entries2 = sorted_entries.sort_by { |k| k[:intensity] }
            ap sorted_entries
        when view_menu.menu_items[2]
            sorted_entries = j_index.sort_by { |key| key[:title] }
            ap sorted_entries
            
            # sorted_entries.each do |key, value|
            #     puts key
        end
        
    when main_menu.menu_items[2], '-s'
        puts "hello"

    else
        begin
            raise InvalidArgument
        rescue InvalidArgument => e
            puts e.message
        end
        exit
    end
end






