module Prequel
  class SubscriptionNode
    def initialize
      clear
    end

    def subscribe(&proc)
      subscriptions.push(proc)
    end

    def publish(*args)
      subscriptions.each do |proc|
        proc.call(*args)
      end
    end

    def clear
      @subscriptions = []
    end

    protected
    attr_reader :subscriptions
  end
end
