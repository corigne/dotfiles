function not-in-desktop-environment --description "Return true when no desktop session is available"
    test -z "$DISPLAY" &&
        test -z "$WAYLAND_DISPLAY" &&
        test -z "$SSH_CONNECTION"
end
