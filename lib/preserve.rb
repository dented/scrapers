require 'rethinkdb'

class Preserve
  include RethinkDB::Shortcuts

  def initialize
    begin
      @conn = r.connect(db: 'blackbox')
      # r.db_create('blackbox').run(@conn)
      # @conn.use('blackbox')
      # r.table_create('listings').run(@conn)
    rescue Exception => e
      puts "Error connecting #{e}"
    end
  end

  def finalize
    @conn.close
  end

  def save listings
    r.table('listings').insert(listings).run(@conn)
  end

  def latest
    r.table('listings').limit(10).run(@conn)
  end

end