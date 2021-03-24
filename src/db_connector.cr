require "./core_ext/object"

# An abstraction over DB::Database with the ability to log database operations.
class DBConnector(T)
  property? log : Bool = false

  initializer db : DB::Database, owner : T

  def transaction
    @db.transaction do |tr|
      if log?
        timer = Timer.new
        con = tr.connection
        Logs.debug(@owner) { "(#{timer.result(6)}s) BEGIN" }
        timer.start
        yield LoggedTransaction.new(self, con)
        Logs.debug(@owner) { "(#{timer.result(6)}s) COMMIT" }
      else
        yield LoggedTransaction.new(self, tr.connection)
      end
    end
  end

  def query_each(*args)
    with_debug(*args) { @db.query_each(*args) { |rs| yield rs } }
  end

  def each(*args)
    query_each(*args) { |rs| yield ResultSetReader.new(rs) }
  end

  def exec(*args)
    with_debug(*args) { @db.exec(*args) }
  end

  def scalar(*args)
    with_debug(*args) { @db.scalar(*args) }
  end

  def prepare(sql)
    @db.prepared(sql)
  end

  delegate close, to: @db

  private def to_debug(sql, *args)
    i = -1
    sql.gsub("?") do
      arg = args[i &+= 1]
      arg.is_a?(String) ? "'#{arg}'" : arg.nil? ? "null" : arg
    end
  end

  private struct LoggedTransaction(T)
    initializer owner : DBConnector(T), con : DB::Connection

    macro method_missing(call)
      @owner.with_debug({{*call.args}}) { @con.{{call}} }
    end
  end

  protected def with_debug(*args)
    if log?
      timer = Timer.new
      ret = yield
      Logs.debug(@owner) do
        String.build do |io|
          io.print('(', timer.result(6), "s) ")
          io << to_debug(*args)
        end
      end
      ret
    else
      yield
    end
  end
end
