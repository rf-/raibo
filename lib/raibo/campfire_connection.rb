require 'tinder'

module Raibo
  class CampfireConnection
    attr_accessor :subdomain, :token, :room_name, :verbose

    def initialize(subdomain, opts={})
      @subdomain  = subdomain
      @token      = opts[:token]
      @room_name  = opts[:room] || 'Raibo'
      @verbose    = !!opts[:verbose]
    end

    def open
      if @token.nil? or @token == ''
        raise "token is a required field for Campfire"
      end
      
      @campfire = Tinder::Campfire.new @subdomain, :token => @token
      @room = @campfire.find_room_by_name @room_name
      puts "Connected to room #{@room_name}" if @verbose
    end

    def close
      @room.leave if @room
    end

    def handle_lines
      @room.listen do |m|
        begin
          # Message Format:
          # :body: the body of the message
          # :user: Campfire user, which is itself a hash, of:
          #    :id: User id
          #    :name: User name
          #    :email_address: Email address
          #    :admin: Boolean admin flag
          #    :created_at: User creation timestamp
          #    :type: User type (e.g. Member)
          # :id: Campfire message id
          # :type: Campfire message type
          # :room_id: Campfire room id
          # :created_at: Message creation timestamp
          
          puts "--> #{m}" if @verbose
          if m[:type] == 'TextMessage' and m[:user][:name] != 'raibo'
            line = m[:body]
            yield m
          end
        rescue => e
          puts "Error #{e.backtrace}" if @verbose
          raise IOError
        end
      end
    rescue IOError => e
      puts "IOError: #{e.backtrace}" if @verbose
      close
    end

    def say(*msgs)
      m = msgs.join("\n")
      if msgs.size == 1
        @room.speak m
      else
        @room.paste m
      end
      puts "<-- #{m}" if @verbose
    end

    def construct_message(msg)
      Raibo::Message.new('PRIVMSG', msg[:user][:name], '', msg[:body])
    end
  end
end
