#!/usr/bin/env ruby
#
# Eats messy chat transcripts and spits out a better aligned version
#
# Author:: Soon Van <cog@randomecho.com>
# Copyright:: Copyright 2013 Soon Van
# License:: BSD 3-Clause License <http://opensource.org/licenses/BSD-3-Clause>

# Reads in a username file and a transcript file, or can read in a folder
# full of transcripts and renders the alignment in a prettier fashion.
#
# Usage: 
#
#  $ chatscript-iron.rb path/to/usernames path/to/transcript


# Preferences
@message_width    = 80        # Maximum width per message before it starts new line
@line_indent      = 4         # Spaces to indent each line in the output
@name_breather    = 3         # Minimum characters to separate a user and their message
@dialogue_marker  = ''        # What to use to separate username and message line with
@leader_marker    = ' '       # Characters to fill void between username and message
@output_folder    = './'        # Include the trailing directory separator
@dir_separator    = '/'
@output_suffix    = '-ironed'

# Script use, edit the above settings only
@all_usernames    = Array.new
@max_username     = 0         # Used to store the max length of username found

def ironing_transcripts(chatscript_file, username_file)
  if File.file?(chatscript_file)
    puts "\nReading in transcript: " + chatscript_file
    ironing_board(chatscript_file)
  elsif File.directory?(chatscript_file)
    directory_portion = (chatscript_file + @dir_separator).length
    username_file = username_file[directory_portion..-1]

    Dir.foreach(chatscript_file) do |chatscript|
      active_script = chatscript_file + @dir_separator + chatscript
      
      if File.file?(active_script) && chatscript != username_file
        puts "\nReading in transcript: " + active_script
        ironing_board(active_script)
      end
    end
  else
    puts "\n- Skipping " + chatscript_file + " - Not a valid file."
  end
end

def ironing_board(wrinkled_chatscript)
  if File.file?(wrinkled_chatscript)
    puts " |_ Ironing out " + wrinkled_chatscript + " chatscript"
    file = File.new(wrinkled_chatscript, "r")
    output_file = output_destination(wrinkled_chatscript)
    
    existing_indent = @message_width
    message_buffer = Array.new
    message_start = @max_username + @name_breather + @dialogue_marker.length

    while (msg_line = file.gets)
      line_indent = msg_line.index(/\S/)

      if msg_line.length > 1
        if line_indent < existing_indent && 
          existing_indent = line_indent
        end
     
        message_buffer << msg_line
      end
    end

    if message_buffer.length > 0
      line_indent = '' * @line_indent
      name_breath_start = ' ' * @name_breather
      hanging_indent = @leader_marker * @max_username + name_breath_start + @dialogue_marker
      save_file = File.open(output_file, "w")
      
      message_buffer.each do |chat_line|
        message_said = chat_line[existing_indent..-1]
        message_parts = breakdown_message(message_said)
        
        if message_parts[:raw].length > @message_width
          wrapped_line = reflow_line(message_parts[:raw], hanging_indent)
        else
          wrapped_line = message_parts[:raw]
        end

        if message_parts[:username].empty?
          line_message = hanging_indent + wrapped_line
        else
          message_line_start = @max_username - message_parts[:username].length
          line_begins_here = @leader_marker * message_line_start
          line_message = message_parts[:username] + line_begins_here + name_breath_start
          line_message += @dialogue_marker + wrapped_line
        end

        save_file.write(line_indent + line_message + "\n")
      end

      save_file.close
      puts " |_ #{message_buffer.length} lines, exported to " + output_file + "\n |"
    else
      puts "  No messages found"
    end
  else
    puts "\n- Skipping " + wrinkled_chatscript + " - Not a valid file."
  end
end

def ironing_usernames(usernames_list)
  if File.file?(usernames_list)
    puts " |_ Picking out usernames from " + usernames_list
    file = File.new(usernames_list, "r")

    while (username = file.gets)
      raw_username = username.strip
      
      if raw_username.length > 0
        @all_usernames << raw_username

        if raw_username.length > @max_username
          @max_username = raw_username.length
        end
      end
    end

    if @all_usernames.length > 0
      puts " |_ #{@all_usernames.length} usernames found"
    else
      puts " ! No usernames found"
      exit
    end
  else
    puts " List of usernames not found in a valid file"
    exit
  end
end      

def output_destination(wrinkled_chatscript)
  if wrinkled_chatscript.rindex(@dir_separator)
    directory_separator = wrinkled_chatscript.rindex(@dir_separator) + 1
    wrinkled_chatscript = wrinkled_chatscript[directory_separator..-1]
  end

  filename_separator = wrinkled_chatscript.rindex('.')
  original_filename = wrinkled_chatscript[0..(filename_separator - 1)]
  original_extension = wrinkled_chatscript[filename_separator..-1]
  output_file = @output_folder + original_filename + @output_suffix + original_extension
  
  return output_file
end    

def breakdown_message(message_said)
  message = {:msg_start => 0, :username => '', :raw => message_said.rstrip}

  @all_usernames.each do |username|
    if (message_said[0..@max_username].include? username) && (message_said[username.length] == ' ')
      message[:msg_start] = username.length
      message[:username] = username
      message[:raw] = message_said[username.length..-1].strip
      break
    end
  end
  
  return message
end

def reflow_line(wide_message, hanging_indent)
  hard_lines = wide_message.length / @message_width
  broken_line = ''
  line_fragment = wide_message
  
  for i in 0..hard_lines
    soft_line_end = line_fragment[0..@message_width]

    if soft_line_end[-1] != ''
      last_word_space = @message_width - soft_line_end.reverse.index(' ')

      if last_word_space == 0
        broken_line += line_fragment.lstrip
      else
        broken_line += line_fragment[0..last_word_space].lstrip
        line_fragment = line_fragment[last_word_space..-1]
      end

      broken_line += (i != hard_lines) ? "\n" + hanging_indent : ""
    end
  end

  return broken_line
end

if ARGV[1].nil?
  puts "! Missing either usernames file or transcript."
  puts "\nUse the following format: "
  puts "\n chatscript-iron.rb path/to/usernames path/to/transcript"
else
  if @output_folder.strip.length == 0
    puts "No output folder specified."
    exit
  end

  puts "Reading in usernames: " + ARGV[0]
  ironing_usernames(ARGV[0])
  ironing_transcripts(ARGV[1], ARGV[0])
end
