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
    @css_query = '#dj-classifieds .items .gxclsf-cat-desc'
    @previous_first_page_link = ''
  end

  def listing url
    page = Nokogiri::HTML(open(url))
    if !page.nil?
      link = url
      title = page.css('.dj-item .title_top h2').first.inner_text.strip

      price_details = page.css('.dj-item .general_det span[itemprop="price"]').first
      price = ''
      if !price_details.nil?
        price = "#{price_details.inner_text.strip.gsub('HK$', '') } HKD"
      end

      description_details = page.css(".dj-item .description .desc_content").first
      description = ''
      if !description_details.nil?
        description = description_details.inner_text.strip
      end

      @products << {
        title: title,
        price: price,
        description: description,
        link: link
      }
    end
  end

  def parse page
    listings = page.css(@css_query)
    listings.each do |item|
      atag = page.css("#{item.css_path} .gxclsf-cat-img a").first
      link = "https://geoexpat.com#{atag['href']}"
      listing(link)
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

  def fetch
    offset = 0
    run = true
    puts "Fetching #{@base_url}..."
    while run
      url = "#{@base_url}?start=#{offset}"
      page = Nokogiri::HTML(open(url))
      if(page.css(@css_query).any?)
        parse(page)
        offset+=12
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
  css_query = '.dj-category .cat_title_desc a'
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
    if relative_url != 'helper'
      Scraper.new(filename, base_url).fetch
    end
  end
end

start 'https://geoexpat.com'