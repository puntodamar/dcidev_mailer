module DcidevMailer
  module Errors
    class InvalidBody < StandardError
      def to_s
        "Email body must be HTML string"
      end
    end
  end
end