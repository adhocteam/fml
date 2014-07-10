require 'dttforms'

class FakeConnection
  attr_reader :opts
  def initialize(opts)
    @opts = opts
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
end
