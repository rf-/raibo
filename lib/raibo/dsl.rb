module Raibo
  class DSL
    def initialize(bot, connection)
      @bot = bot
      @connection = connection
    end

    def use(handler=nil, &block)
      @bot.use(handler, &block)
    end

    def match(regexp, &block)
      use do |msg|
        if msg.body =~ regexp
          exec_with_var_arity($~, msg, &block)
        end
      end
    end

    def method_missing(meth, *args, &block)
      @connection.__send__(meth, *args, &block)
    end

    private
      def exec_with_var_arity(*args, &block)
        arity = block.arity
        if arity <= 0
          instance_eval(&block)
        else
          instance_exec(*args.take(block.arity), &block)
        end
      end
  end
end
