module ActionDispatch
  module Session
    class CookieStore
      @@session_expiration_offset = 0
    
      def self.session_expiration_offset
        @@session_expiration_offset
      end
    
      def self.session_expiration_offset=(value)
        @@session_expiration_offset = value
      end
    
      alias :initialize_without_dynamic_session_expiration :initialize #:nodoc:
      def initialize(request, option={}) #:nodoc:
        if @@session_expiration_offset && @@session_expiration_offset > 0
          option[:expire_after] = @@session_expiration_offset
        end
        initialize_without_dynamic_session_expiration(request, option)
      end
    end
  end
end
