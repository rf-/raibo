module Raibo
  class Bot
    def initialize(*args)
      @handlers = []

      if args.first.is_a?(Raibo::Connection)
        @connection = args.shift
      else
        @connection = Raibo::Connection.new(*args)
      end
    end

    def use(handler=nil, &block)
      @handlers.push(handler || block)
    end

    def match(regexp, &block)
      use do |msg|
        if msg.body =~ regexp
          exec_with_var_arity($~, msg, &block)
        end
      end
    end

    def run(async=false)
      if async
        @thread = Thread.new { run_sync }
        @thread.abort_on_exception = true
      else
        run_sync
      end
    end

    def stop
      @thread.kill if @thread
      @connection.close
    end

    def alive?
      @thread.alive? if @thread
    end

    private
      def run_sync
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
            if handler.is_a?(Proc)
              break if @connection.instance_exec(message, &handler)
            else
              break if handler.call(@connection, message)
            end
          end
        end
      end
  end
end
