# encoding uft8
require 'logger'
require 'rethinkdb'

class Preserve
  include RethinkDB::Shortcuts

  # assume database is setup
  def initialize
    begin
      @logger = Logger.new('errors.log')
      @conn = r.connect(db: 'blackbox')
      @table = 'listings'
    rescue Exception => e
      puts "Error connecting #{e}"
    end
  end

  def finalize
    @conn.close
  end

  def save listings
    begin
      r.table(@table).insert(listings, {conflict: 'replace'}).run(@conn)
    rescue Exception => e
      @logger.error "Saving #{e}"
    end
  end

  def latest
    r.table(@table).limit(25).run(@conn)
  end

  def filter_by_category category
    r.table(@table).filter{ |item|
      item['category'].eq(category)
    }.pluck('link', 'title', 'price').run(@conn)
  end

  def categories
    r.table(@table).pluck('category').distinct().run(@conn)
  end

end