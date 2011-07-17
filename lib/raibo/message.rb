module Raibo
  class Message
    # Readers for the components of the actual IRC protocol line.
    attr_reader :prefix, :type, :middle, :trailing

    # Readers for higher-level attributes of the message.
    attr_reader :kind, :from, :to, :body

    def initialize(line)
      @prefix, @type, @middle, @trailing = parse_line(line)

      @kind = get_kind
      @from = get_from
      @to   = get_to
      @body = get_body
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

      def get_kind
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

      def get_from
        prefix[/^([^!@ ]*)/, 1]
      end

      def get_to
        if [:message, :emote].include?(kind)
          middle.first
        end
      end

      def get_body
        case kind
        when :message
          trailing
        when :emote
          trailing[/\001ACTION ([^\001]*)/, 1]
        end
      end
  end
end