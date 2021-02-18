Rails.application.config.content_security_policy do |policy|
    policy.frame_ancestors :self, 'sustainabletompkins.org'
end