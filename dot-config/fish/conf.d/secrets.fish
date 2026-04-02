if status is-interactive &&
    command -q pass &&
    ! set -q FISH_NO_SECRETS
    if ! status is-login || ! not-in-desktop-environment
        inject-secrets
    end
end
