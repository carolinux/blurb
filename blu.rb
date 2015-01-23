require 'sinatra'
SUBS_DIR="./subs"
GLOB="*.srt"

def get_random_filename(dir,glob)
    files = Dir.glob(File.join(dir,glob))
    return files[rand(0..files.size-1)]
end

def is_beginning_of_speech(line)
    # for when we have subtitle blurb where two or more people speak
    return (line =~ /^(\s)*-/) 
end 

def is_end_of_sentence(line)
    # TODO: for improved detection
    return (line =~/[\.!\?](\s)*$/)
end
#TODO remove '- ' part from lines when printing

def is_dialogue_line(line)
    return not(line =~ /^(\s)*$/ or line =~/^(\s)*[\[<]/ or line=~/\](\s)*$/ or line=~/^(\s)*[\d:,->\s]+$/ )
end

def get_random_blurb_from_file(filename)
    line_num=0
    text=File.open(filename).read
    lines = text.gsub!(/\r\n?/, "\n").split("\n")
    found=false
    until found  do
        idx=rand(0..lines.size-1)
        line=lines[idx]
        if (is_dialogue_line(line))
            found=true
        end
    end
    result = line

    # get lines before
    i=1
    while i>=0 do
        line=lines[idx-i]
        if (is_dialogue_line(line) and not is_beginning_of_speech(lines[idx-i]))
            result=line+"\n"+result
        else
            break
        end
        i=i+1
    end

    # get lines after
    i=1
    while i<lines.size do
        line=lines[idx+i]
        if (is_dialogue_line(line) and not is_beginning_of_speech(line))
            result=result+"\n"+line
        else 
            break
        end
        i=i+1
    end

    return result
end

get '/line' do
    get_random_blurb_from_file(get_random_filename(SUBS_DIR,GLOB))
end
