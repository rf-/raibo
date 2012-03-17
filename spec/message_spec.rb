require 'spec_helper'

module Raibo
  describe Message do
    it 'parses a message' do
      m = Raibo::IrcMessage.new(":someone!someone@Nightstar-251832d1.snfc22.example.com PRIVMSG #raibo :foo bar baz")

      m.kind.should == :message
      m.from.should == 'someone'
      m.to.should == '#raibo'
      m.body.should == 'foo bar baz'
    end

    it 'parses an emote' do
      m = Raibo::IrcMessage.new(":someone!someone@Nightstar-251832d1.snfc22.example.com PRIVMSG #raibo :\001ACTION foo bar baz\001")

      m.kind.should == :emote
      m.from.should == 'someone'
      m.to.should == '#raibo'
      m.body.should == 'foo bar baz'
    end

    it 'parses a join' do
      m = Raibo::IrcMessage.new(":someone!someone@Nightstar-251832d1.snfc22.example.com JOIN :#raibo")

      m.kind.should == :join
      m.from.should == 'someone'
      m.to.should == nil
      m.body.should == nil
    end

    it 'parses a part' do
      m = Raibo::IrcMessage.new(":someone!someone@Nightstar-251832d1.snfc22.example.com PART #raibo")

      m.kind.should == :part
      m.from.should == 'someone'
      m.to.should == nil
      m.body.should == nil
    end

    it 'parses an arbitrary line' do
      m = Raibo::IrcMessage.new(":Deepthought.NY.US.Nightstar.Net 255 Raibo :I have 83 clients and 1 servers")
      m.kind.should == nil
    end
  end
end
