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
        rescue Tinder::ListenFailed => e
          puts "Failed listening to #{@room_name}: #{e.message}"
        end
      end
    rescue IOError
      close
    end

    def say(*msgs)
      msgs.each { |m| msg(m) }
    end

    def msg(m)
      @room.speak m
      puts "<-- #{m}" if @verbose
    end

    def construct_message(msg)
      Raibo::Message.new('PRIVMSG', msg[:user][:name], '', msg[:body])
    end
  end
end
