module Raibo
  class Message
    attr_reader :kind, :from, :to, :body

    def initialize(kind, from, to, body)
      @kind, @from, @to, @body = kind, from, to, body
    end
  end

  class IrcMessage
    attr_reader :prefix, :type, :middle, :trailing

    def initialize(line)
      @prefix, @type, @middle, @trailing = parse_line(line)
    end

    def kind
      case type
      when 'PRIVMSG'
        if trailing =~ /^\001ACTION/
          :emote
        else
          :message
        end
      when 'JOIN'
        :join
      when 'PART'
        :part
      end
    end

    def from
      prefix[/^([^!@ ]*)/, 1]
    end

    def to
      if [:message, :emote].include?(kind)
        middle.first
      end
    end

    def body
      case kind
      when :message
        trailing
      when :emote
        trailing[/\001ACTION ([^\001]*)/, 1]
      end
    end

    private
      def parse_line(line)
        prefix, type, params = line.match(/:(\S+) (\S+) (.*)/).captures
        if params
          middle, _, trailing = params.partition(':')
          middle = middle.split
          trailing.chomp!
        end
        [prefix, type, middle, trailing]
      end
  end
end
