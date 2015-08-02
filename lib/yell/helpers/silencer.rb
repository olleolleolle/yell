# encoding: utf-8
module Yell #:nodoc:
  module Helpers #:nodoc:
    module Silencer #:nodoc:
      # Set the silence pattern
      def silence(*patterns)
        silencer.add(*patterns)
      end

      def silencer
        @__silencer__
      end

      private

      def reset!(options = {})
        @__silencer__ = Yell::Silencer.new
        silencer.add(*Yell.__fetch__(options, :silence, default: []))

        super(options)
      end

      def silence!(*messages)
        @__silencer__.silence!(*messages) if silencer.silence?
      end
    end
  end
end
