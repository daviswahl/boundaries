require "boundaries/version"
require 'boundaries/boundary'
require 'boundaries/mock'
require 'boundaries/method_stub'
require 'boundaries/accumulator'

module Boundaries
  @registered_classes = []
  def self.register_class(klass)
    @registered_classes << klass 
  end

  def self.unmock!
    @registered_classes.each(&:unmock!)
  end

  RSpec.configure { |c| c.after(:each) { Boundaries.unmock! } }
end
