require 'dttforms'

class FakeConnection
  attr_reader :opts, :queries
  attr_writer :nextresult

  def initialize(opts)
    @opts = opts
    @queries = []
  end

  def exec_params(query, params)
    @queries << [query, params]
    return @nextresult
  end
end

class FakeResult
  def initialize(rows)
    @rows = rows
  end

  def [](index)
    @rows.fetch(index)
  end
end

describe "Connection handling" do
  it "creates a connection object" do
    dbname = "database_name"
    user = "database_user"
    conn = DTTForms::Connection.new({
      dbname: dbname,
      user: user
    }, connection_type=FakeConnection)

    expect(conn.conn).to be_a(FakeConnection)
    expect(conn.conn.opts[:dbname]).to eq dbname
    expect(conn.conn.opts[:user]).to eq user
  end

  it "gets a spec" do
    dbname = "database_name"
    user = "database_user"
    conn = DTTForms::Connection.new({
      dbname: dbname,
      user: user
    }, connection_type=FakeConnection)

    row = ["specid", "spectext", "etc"]
    conn.conn.nextresult = [row]

    specid = 1234
    actualrow = conn.get_spec(1234)
    expect(actualrow).to eq row
  end

  it "fails with an IndexError if the spec isn't found" do
    dbname = "database_name"
    user = "database_user"
    conn = DTTForms::Connection.new({
      dbname: dbname,
      user: user
    }, connection_type=FakeConnection)

    row = nil
    conn.conn.nextresult = FakeResult.new([])

    specid = 1234
    expect {conn.get_spec(1234)}.to raise_exception IndexError
  end

end
