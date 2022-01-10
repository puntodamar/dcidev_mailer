module DcidevMailer
  module Errors
    class InvalidRecipients < StandardError
      def to_s
        "Must have at lease one recipient"
      end
    end
  end
end