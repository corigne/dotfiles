if status is-interactive && command -q pass && ! set -q FISH_NO_SECRETS
    inject-secrets
end
