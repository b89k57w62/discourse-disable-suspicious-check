# frozen_string_literal: true

# name: discourse-disable-suspicious-check
# about: Disables the suspicious request check that can block user registration
# version: 1.0.0
# authors: Jeffrey

after_initialize do
  module DisableSuspiciousRequestCheck
    def respond_to_suspicious_request
      Rails.logger.info("[DisableSuspiciousCheck] respond_to_suspicious_request called - bypassed completely")
    end
    
    def suspicious?(params)
      Rails.logger.info("[DisableSuspiciousCheck] suspicious? called - always returning false")
      false
    end
    
    def honeypot_or_challenge_fails?(params)
      Rails.logger.info("[DisableSuspiciousCheck] honeypot_or_challenge_fails? called - always returning false")
      false
    end
    
    def create
      Rails.logger.info("[DisableSuspiciousCheck] create method called - tracking session")
      Rails.logger.info("[DisableSuspiciousCheck] Before create - session keys: #{session.keys.inspect}")
      
      result = super
      
      Rails.logger.info("[DisableSuspiciousCheck] After create - session keys: #{session.keys.inspect}")
      Rails.logger.info("[DisableSuspiciousCheck] Response status: #{response.status}")
      Rails.logger.info("[DisableSuspiciousCheck] Session user_created_message: #{session['user_created_message'].inspect}")
      
      result
    end
    
    def account_created
      Rails.logger.info("[DisableSuspiciousCheck] account_created called")
      Rails.logger.info("[DisableSuspiciousCheck] Session all keys: #{session.keys.inspect}")
      Rails.logger.info("[DisableSuspiciousCheck] Session user_created_message: #{session['user_created_message'].inspect}")
      Rails.logger.info("[DisableSuspiciousCheck] Current user: #{current_user&.username}")

      if session["user_created_message"].blank?
        Rails.logger.warn("[DisableSuspiciousCheck] Missing user_created_message in session, setting default")
        session["user_created_message"] = I18n.t("activation.success") || "Account created successfully"
        Rails.logger.info("[DisableSuspiciousCheck] Session after setting default: #{session['user_created_message']}")
      end
      
      super
    end
  end

  require_dependency 'users_controller'
  
  UsersController.prepend(DisableSuspiciousRequestCheck)
  
  Rails.logger.info("[DisableSuspiciousCheck] Plugin loaded - suspicious check disabled with session fix")
end