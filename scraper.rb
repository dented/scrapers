# encoding uft8
require 'logger'
require 'nokogiri'
require 'open-uri'
require 'json'

class Scraper

  def initialize filename, url
    @logger = Logger.new('errors.log')
    @base_url = url
    @products = []
    @filename = "#{filename}.#{Time.now.to_i.to_s}.json"
    @css_query = '.soltop .listitem'
    @previous_first_page_link = ''
  end

  def parse page
    sources = page.css(@css_query)
    sources.each do |item|
      atag = page.css("#{item.css_path} h4.R a").first
      link = atag['href']
      title = atag.inner_text.strip

      price_details = page.css("#{item.css_path} .borderright").last
      price = price_details.children.last.inner_text.strip if !price_details.nil? && !price_details.children.nil?

      description = page.css("#{item.css_path} .leftlistitem").first.inner_text.strip
      
      @products << {
        title: title,
        price: price,
        description: description,
        link: link
      }
    end
  end

  def save
    puts "Saving #{@file}"
    type = 'w+'
    if !File.exists?(@filename)
      type = 'a+'
    end
    File.open(@filename, type) do |f|
      begin
        f.puts @products.to_json
      rescue Exception => e
        @logger.error("Failed #{e} - #{product}")
      end
    end
  end

  def is_duplicate page
    current_first_page_link = page.css("#{@css_query} h4.R a").first['href']
    duplicate_found = @previous_first_page_link == current_first_page_link
    if !duplicate_found
      @previous_first_page_link = current_first_page_link
    end
    duplicate_found
  end

  def fetch
    offset = 1
    run = true
    puts "Fetching #{@base_url}..."
    while run
      url = "#{@base_url}#{offset}"
      page = Nokogiri::HTML(open(url))
      if(page.css(@css_query).any? && !is_duplicate(page))
        parse(page)
        offset+=1
      else
        puts "No more results #{offset}"
        run = false
      end
    end
    save
  end
end

def start site
  links = []
  url = "#{site}/classifieds/"

  puts "Getting links #{url}"
  page = Nokogiri::HTML(open(url))
  css_query = '.rsb2'
  if(page.css(css_query).any?)
    page.css(css_query).each do |atag|
      links << atag['href']
    end
  else
    puts "No links found"
  end

  links.each do |relative_url|
    filename = relative_url.gsub('/classifieds/','')[0..-2]
    base_url = "#{site}#{relative_url}"
    Scraper.new(filename, base_url).fetch
  end
end

start 'http://hongkong.asiaxpat.com'