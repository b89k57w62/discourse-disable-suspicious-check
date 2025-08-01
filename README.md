Discourse Disable Suspicious Check
A Discourse plugin that disables the suspicious request check to prevent user registration from being blocked by filter chain halts.

Installation
Add the plugin repository to your app.yml file:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/yourusername/discourse-disable-suspicious-check.git
```

Rebuild your Discourse container:

```bash
cd /var/discourse
./launcher rebuild app
```

Usage
Once installed, the plugin automatically overrides the `respond_to_suspicious_request` method in UsersController to prevent registration interruptions. This resolves the "Filter chain halted as :respond_to_suspicious_request rendered or redirected" error that can block new user registrations. Note that this disables a security feature, so ensure you have alternative anti-spam measures in place.