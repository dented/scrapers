require_relative 'geoexpat.com/geoexpat'
require_relative 'asiaxpat.com/asiaxpat'

class Runner

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

end

runner = Runner.new
runner.asiaexpat
runner.geoexpat
# runner.dcfever
# runner.pricecomhk