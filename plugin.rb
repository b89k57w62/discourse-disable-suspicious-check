# frozen_string_literal: true

# name: discourse-disable-suspicious-check
# about: Disables the suspicious request check that can block user registration
# version: 1.0.0
# authors: Jeffrey

after_initialize do
  module DisableSuspiciousRequestCheck
    def respond_to_suspicious_request
      Rails.logger.info("[DisableSuspiciousCheck] respond_to_suspicious_request called but doing nothing")
    end
    
    def suspicious?(params)
      Rails.logger.info("[DisableSuspiciousCheck] suspicious? called - always returning false")
      false
    end
    
    def honeypot_or_challenge_fails?(params)
      Rails.logger.info("[DisableSuspiciousCheck] honeypot_or_challenge_fails? called - always returning false")
      false
    end
    
    def account_created
      Rails.logger.info("[DisableSuspiciousCheck] account_created method called")
      Rails.logger.info("[DisableSuspiciousCheck] Session data: #{session.inspect}")
      Rails.logger.info("[DisableSuspiciousCheck] Current user: #{current_user.inspect}")
      super
    end
  end

  require_dependency 'users_controller'
  
  UsersController.prepend(DisableSuspiciousRequestCheck)
  
  Rails.logger.info("[DisableSuspiciousCheck] Plugin loaded successfully - multiple methods overridden")
end