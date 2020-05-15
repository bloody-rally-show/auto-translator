require 'google/cloud/translate'

def setup
  puts "Authenticating with Google Cloud Platform (if it takes too long, it will most likely fail)"
  client = Google::Cloud::Translate.new
  puts "Authentication complete"

  input_file = ARGV[0]

  unless File.exists?(input_file)
    puts "File does not exist: #{input_file}"
    exit 1
  end

  puts "Select mode (1 - full, 2 - CSV-like (for BRS)): [1]"
  mode = ARGV[2].to_i
  mode = 1 if mode == 0

  puts "Batch size: [500]"
  batch_size = ARGV[3].to_i
  batch_size = 500 if batch_size == 0

  puts "Output language from https://cloud.google.com/translate/docs/languages: "
  output_lang = ARGV[1]

  puts "File: #{input_file}"
  puts "Target lang: #{output_lang}"
  puts "Mode: #{mode} (1 = full, 2 = CSV-like)"
  puts "Batch size: #{batch_size}"
  puts "All good? [y/N]"
  sleep 1
  confirm = $stdin.gets.strip
  puts "Your answer: #{confirm}"
  exit 0 unless confirm == 'y'

  input_lines = File.readlines(input_file)

  zone_id = 'global'
  project_id = ENV['TRANSLATE_PROJECT']
  parent = client.class.location_path(project_id, zone_id)

  chunk_id = 0
  if mode == 2
    input_lines.each_slice(batch_size) do |line_chunk|
      translate_csv(client, parent, line_chunk, output_lang, input_file, chunk_id)
      chunk_id += 1
    end
  elsif mode == 1
    input_lines.each_slice(batch_size) do |line_chunk|
      translate_full(client, parent, line_chunk, output_lang, input_file, chunk_id)
      chunk_id += 1
    end
  end
end

def translate_full(client, parent, input_lines, output_lang, input_file, chunk_id) 
  response = client.translate_text(input_lines, output_lang, parent)

  translated = []
  response.translations.each do |tr|
    translated.push(tr.translated_text.strip.gsub("&gt;", ">"))
  end

  File.open("#{output_lang}_#{chunk_id}_#{input_file}", 'w') do |f|
    translated.each do |line|
        f.write "#{line}\n"
    end
  end
end

def translate_csv(client, parent, input_lines, output_lang, input_file, chunk_id)
  output_lines = {}
  translation_line_nums = []
  to_translate = []
  translation_keys = {}
  total_lines = input_lines.count
  
  line_num = -1
  
  input_lines.each do |line|
    line_num += 1
    line = line.strip
    output_lines[line_num] = line
    if line.strip != '' && !line.start_with?("#")
      keyval = line.split(",", 2)
      translation_keys[line_num] = keyval[0]
      translation_line_nums.push(line_num)
      to_translate.push(keyval[1])
    end
  end
  
  response = client.translate_text(to_translate, output_lang, parent)
  
  translated = []
  response.translations.each do |tr|
    translated.push(tr.translated_text.strip.gsub("&gt;", ">"))
  end

  File.open("#{output_lang}_#{chunk_id}_#{input_file}", 'w') do |f|
    output_lines.each do |ln, line|
      if translation_line_nums.include?(ln)
        idx = translation_line_nums.index(ln)
        f.write "#{translation_keys[ln]},#{translated[idx]}\n"
      else
        f.write "#{line}\n"
      end 
    end
  end
end

setup()