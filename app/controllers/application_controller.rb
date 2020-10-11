class ApplicationController < ActionController::API
  include ActionView::Layouts
  rescue_from StandardError, with: :response_500

  def response_500(e = nil)
    if e
      Rails.logger.error e
      Rails.logger.error Rails.backtrace_cleaner.clean(e.backtrace).join("\n").indent(1)
    end

    head :internal_server_error
  end
end
# Modules in ActionController::Base but not in API
# AbstractController::Translation,
# AbstractController::AssetPaths,
# ActionController::Helpers,
# ActionView::Layouts,
# ActionController::Rendering,
# ActionController::EtagWithTemplateDigest,
# ActionController::EtagWithFlash,
# ActionController::Caching,
# ActionController::MimeResponds,
# ActionController::ImplicitRender,
# ActionController::ParameterEncoding,
# ActionController::Cookies,
# ActionController::Flash,
# ActionController::FormBuilder,
# ActionController::RequestForgeryProtection,
# ActionController::ContentSecurityPolicy,
# ActionController::FeaturePolicy,
# ActionController::Streaming,
# HttpAuthentication::Basic::ControllerMethods,
# HttpAuthentication::Digest::ControllerMethods,
# HttpAuthentication::Token::ControllerMethods,
