require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @table_of_contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "This is a title"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  @chapter_number = "Chapter #{number}"
  redirect "/" unless (1..@table_of_contents.size).cover? number
  @chapter_name = @table_of_contents[number.to_i - 1]
  @title = "#{@chapter_number}: #{@chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")
  

  erb :chapter
end

def each_chapter(&block)
  @table_of_contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield(number, name, contents)
  end
end

def paragraph_matching(query)
  results = []
  return results if !query || query.empty?
  each_chapter do |number, name, contents|
    paragraphs = contents.split("\n\n")
    paragraphs.each do |paragraph|
      results << {number: number, name: name, paragraph: paragraph} if paragraph.include?(query)
    end
  end
  results
end

get "/search" do
  @title = "Search Page"
  @results = paragraph_matching(params[:query])
  erb :search
end

not_found do
  redirect '/'
end

helpers do
  def in_paragraphs(text)
    id = 0
    text.split("\n\n").map do |line|
      id += 1
      "<p id='#{id}'>#{line}</p>"
    end.join
  end

  def in_bold(text)
    text.gsub!(params[:query], "<strong>#{params[:query]}</strong>")
  end
end