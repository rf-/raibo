module Raibo
  class Bot
    attr_accessor :thread

    def initialize(*args)
      if args.first.is_a?(Raibo::Connection)
        @connection = args.shift
        @handlers = []

        args.each do |handler|
          append_handler(handler)
        end
      else
        @connection = Raibo::Connection.new(*args)
        @handlers = []
      end
    end

    def insert_handler(handler=nil, &block)
      @handlers.unshift(handler || block)
    end

    def append_handler(handler=nil, &block)
      @handlers.push(handler || block)
    end

    def run
      @connection.open
      @connection.handle_lines do |line|
        begin
          message = Raibo::Message.new(line)
        rescue => e
          if @connection.verbose
            puts "Error parsing line:"
            puts "  #{line}"
            puts "  #{e.backtrace}"
          end
        end
        @handlers.each do |handler|
          break if handler.call(@connection, message)
        end
      end
    end

    def run_async
      @thread = Thread.new { self.run }
      @thread.abort_on_exception = true
    end

    def stop
      @thread.kill if @thread
      @connection.close
    end
  end
end
