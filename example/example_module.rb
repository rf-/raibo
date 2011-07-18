# This is a simple example of a module that could be used with Raibo.
# An associated Botfile might look like this:
#
#   require_relative 'example/test_module'
#   use ExampleModule.new(/hello/, 'goodbye')
#   use ExampleModule.new(/goodbye/, 'hello')
#
# This will run a bot that responds to a message containing "hello"
# by saying "goodbye", and vice versa.
#
# Bots can maintain whatever state they want to. The only requirement
# is that they respond to a #call method with a Raibo::Connection as
# the first parameter and Raibo::Message as the second.

class ExampleModule
  def initialize(regexp, response)
    @regexp, @response = regexp, response
  end

  def call(c, message)
    if message.body =~ @regexp
      c.say @response
    end
  end
end
