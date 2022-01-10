module DcidevMailer
  module Errors
    class InvalidTemplate < StandardError
      def to_s
        "Missing email template"
      end
    end
  end
end