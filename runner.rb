# encoding uft8
require_relative 'geoexpat.com/geoexpat'
require_relative 'asiaxpat.com/asiaxpat'

class Runner

  def initialize
    @db = Preserve.new
  end

  def asiaexpat
    site = 'http://hongkong.asiaxpat.com'
    links = []
    url = "#{site}/classifieds/"

    puts "Starting AsiaXpat #{url}"
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
      category = relative_url.gsub('/classifieds/','')[0..-2]
      base_url = "#{site}#{relative_url}"
      Asiaxpat.new(category, base_url).fetch
    end

  end

  def geoexpat
    site = 'https://geoexpat.com'
    links = []
    url = "#{site}/classifieds/"

    puts "Starting GeoExpat"
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
      category = relative_url.gsub('/classifieds/','')[0..-2]
      base_url = "#{site}#{relative_url}"
      Geoexpat.new(category, base_url).fetch
    end
  end

  def dcfever
  end

  def pricecomhk
  end

  def latest
    display_results @db.latest
  end

  def by_category category
    display_results(@db.filter_by_category(category))
  end

  def list_of_categories
    display_results(@db.categories)
  end

  private

  def display_results rows
    rows.each do |item|
      item.each do |k,v|
        puts "#{k.capitalize}: #{v.gsub('  ', '')}\n"
      end
      puts "\n"
    end
  end

end

runner = Runner.new
# runner.asiaexpat
# runner.geoexpat
# runner.dcfever
# runner.pricecomhk