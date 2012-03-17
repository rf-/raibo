require 'tinder'

module Raibo
  class CampfireConnection
    attr_accessor :subdomain, :token, :room_name, :verbose, :opened

    def initialize(subdomain, opts={})
      @subdomain  = subdomain
      @token      = opts[:token]
      @room_name  = opts[:room] || 'Raibo'
      @verbose    = !!opts[:verbose]
      @opened     = false
    end

    def open
      if @token.nil? or @token == ''
        raise "token is a required field for Campfire"
      end

      @campfire = Tinder::Campfire.new @subdomain, :token => @token
      @room = @campfire.find_room_by_name @room_name
      @name = @campfire.me['name']

      puts "Connected to room #{@room_name}" if @verbose
      @opened = true
    end

    def close
      @room.leave if @room
    rescue
    end

    def handle_lines
      @room.listen do |m|
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
        if m[:type] == 'TextMessage' and m[:user][:name] != @name
          yield m
        end
      end
    rescue => e
      puts "Error:\n  #{e.backtrace.join('  ')}" if @verbose
      retry
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
