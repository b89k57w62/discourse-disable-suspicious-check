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
      Rails.logger.info("[DisableSuspiciousCheck] account_created called")
      Rails.logger.info("[DisableSuspiciousCheck] Session keys: #{session.keys}")
      Rails.logger.info("[DisableSuspiciousCheck] Has user_created_message: #{session['user_created_message'].present?}")
      
      if session["user_created_message"].blank?
        Rails.logger.warn("[DisableSuspiciousCheck] *** MISSING SESSION DETECTED ***")
        Rails.logger.warn("[DisableSuspiciousCheck] IP: #{request.remote_ip}")
        Rails.logger.warn("[DisableSuspiciousCheck] User-Agent: #{request.user_agent&.first(100)}")
        
        success = false
        
        if session_user_id = session[SessionController::ACTIVATE_USER_KEY]
          Rails.logger.info("[DisableSuspiciousCheck] Found user ID in session: #{session_user_id}")
          
          if user = User.where(id: session_user_id.to_i).first
            Rails.logger.info("[DisableSuspiciousCheck] Found user: #{user.username} (#{user.email})")
            
            if user.active?
              message = I18n.t("activation.success")
              Rails.logger.info("[DisableSuspiciousCheck] User is active, using success message")
            else
              message = I18n.t("login.activate_email", email: user.email)
              Rails.logger.info("[DisableSuspiciousCheck] User inactive, using activation message")
            end
            
            @message = message
            @account_created = {
              message: message,
              username: user.username,
              email: user.email,
              show_controls: !user.from_staged?
            }
            
            Rails.logger.info("[DisableSuspiciousCheck] Database fallback successful!")
            success = true
            
            begin
              session["user_created_message"] = message
              Rails.logger.info("[DisableSuspiciousCheck] Successfully reset session message")
            rescue => e
              Rails.logger.error("[DisableSuspiciousCheck] Failed to reset session: #{e.message}")
            end
          else
            Rails.logger.error("[DisableSuspiciousCheck] User not found with ID: #{session_user_id}")
          end
        else
          Rails.logger.error("[DisableSuspiciousCheck] No user ID found in session")
        end
        
        unless success
          Rails.logger.warn("[DisableSuspiciousCheck] Database fallback failed, using generic message")
          fallback_message = I18n.t("activation.success") || "Account created successfully"
          @message = fallback_message
          
          begin
            session["user_created_message"] = fallback_message
          rescue => e
            Rails.logger.error("[DisableSuspiciousCheck] Final session write failed: #{e.message}")
          end
        end
      else
        Rails.logger.info("[DisableSuspiciousCheck] Session message exists, proceeding normally")
      end
      
      super
    end
  end

  require_dependency 'users_controller'
  
  UsersController.prepend(DisableSuspiciousRequestCheck)
  
  Rails.logger.info("[DisableSuspiciousCheck] Plugin loaded - suspicious request checks disabled")
end