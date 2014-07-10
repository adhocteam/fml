require 'pg'

module DTTForms
  class Connection
    attr_reader :conn

    def initialize(opts={}, connection_type=PG::Connection)
      opts = {
        dbname: "",
        user: "",
        password: "",
        host: "localhost",
      }.merge(opts)

      @conn = connection_type.new(opts)
    end
  end
end
