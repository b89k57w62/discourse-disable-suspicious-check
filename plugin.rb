# frozen_string_literal: true

# name: discourse-disable-suspicious-check
# about: Disables the suspicious request check that can block user registration
# version: 1.0.0
# authors: Jeffrey

after_initialize do
  module DisableSuspiciousRequestCheck
    def respond_to_suspicious_request
      Rails.logger.info("[DisableSuspiciousCheck] respond_to_suspicious_request called but doing nothing")
      return
    end
    
    def suspicious?(params)
      Rails.logger.info("[DisableSuspiciousCheck] suspicious? called - always returning false")
      return false
    end
  end

  require_dependency 'users_controller'
  
  UsersController.prepend(DisableSuspiciousRequestCheck)
  
  Rails.logger.info("[DisableSuspiciousCheck] Plugin loaded successfully - both methods overridden")
end