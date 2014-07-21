require 'dynamic_session_expiry'

ActionDispatch::Session::CookieStore.session_expiration_offset=2.weeks
