# encoding uft8
require 'nokogiri'
require 'open-uri'
require 'json'
require_relative '../lib/preserve'

class Geoexpat

  def initialize category, url
    @base_url = url
    @products = []
    @category = category
    @css_query = '#dj-classifieds .items .gxclsf-cat-desc'
  end

  def listing url
    page = Nokogiri::HTML(open(url))
    if !page.nil?
      link = url
      title = page.css('.dj-item .title_top h2').first.inner_text.strip

      price_details = page.css('.dj-item .general_det span[itemprop="price"]').first
      price = ''
      if !price_details.nil?
        price = "#{price_details.inner_text.strip.gsub('HK$', '').strip } HKD"
      end

      description_details = page.css(".dj-item .description .desc_content").first
      description = ''
      if !description_details.nil?
        description = description_details.inner_text.strip
      end

      @products << {
        title: title.strip,
        price: price.strip,
        category: @category,
        description: description.strip,
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
    puts "Saving #{@products.size}"
    Preserve.new.save(@products)
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