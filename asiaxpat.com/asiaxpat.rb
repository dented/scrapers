# encoding uft8
require 'nokogiri'
require 'open-uri'
require 'json'
require_relative '../lib/preserve'

class Asiaxpat

  def initialize category, url
    @base_url = url
    @products = []
    @category = category
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
        title: title.strip,
        price: price.strip,
        category: @category,
        description: description.strip,
        link: link
      }
    end
  end

  def save
    puts "Saving #{@products.size}"
    Preserve.new.save(@products)
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