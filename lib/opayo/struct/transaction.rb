module Opayo
  module Struct
    class Transaction < Base
      attr_accessor :transactionId
      attr_accessor :acsTransId
      attr_accessor :dsTranId
      attr_accessor :transactionType
      attr_accessor :status
      attr_accessor :statusCode
      attr_accessor :statusDetail
      attr_accessor :retrievalReference
      attr_accessor :bankResponseCode
      attr_accessor :bankAuthorisationCode
      attr_accessor :avsCvsCheck
      attr_accessor :paymentMethod
      attr_accessor :amount
      attr_accessor :currency
      # attr_accessor :3DSecure #TODO add ETL around this attribute
      attr_accessor :fiRecipient
    end
  end
end
