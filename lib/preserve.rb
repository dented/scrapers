require 'rethinkdb'

class Preserve
  include RethinkDB::Shortcuts

  # assume database is setup
  def initialize
    begin
      @conn = r.connect(db: 'blackbox')
    rescue Exception => e
      puts "Error connecting #{e}"
    end
  end

  def finalize
    @conn.close
  end

  def save listings
    r.table('listings').insert(listings, {upsert: true}).run(@conn)
  end

  def latest
    r.table('listings').limit(10).run(@conn)
  end

  def filter_by_category category
    r.table('listings').filter{ |item|
      item['category'].eq(category)
    }.pluck('link', 'title', 'price').run(@conn)
  end

  def categories
    r.table('listings').pluck('category').distinct().run(@conn)
  end

end