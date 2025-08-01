# frozen_string_literal: true

# name: discourse-disable-suspicious-check
# about: Disables the suspicious request check that can block user registration
# version: 1.0.0
# authors: Jeffrey

after_initialize do
  module DisableSuspiciousRequestCheck
    def respond_to_suspicious_request
      Rails.logger.info("[DisableSuspiciousCheck] Suspicious request check bypassed")
    end
    
    def account_created
      if session["user_created_message"].blank?
        Rails.logger.warn("[DisableSuspiciousCheck] Missing session - providing fallback")
        session["user_created_message"] = I18n.t("activation.success") || "Account created successfully"
      end
      super
    end
  end

  require_dependency 'users_controller'
  
  UsersController.prepend(DisableSuspiciousRequestCheck)
  
  Rails.logger.info("[DisableSuspiciousCheck] Plugin loaded - suspicious request checks disabled")
end