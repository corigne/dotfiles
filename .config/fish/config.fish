if status is-login && test -z "$DISPLAY" && test -z "$WAYLAND_DISPLAY" && test -z "$SSH_CONNECTION"
    if uwsm check may-start
        exec uwsm start hyprland-uwsm.desktop
    end
end

if status is-interactive
    bass source ~/.config/environment.d/environment.conf
    bass source ~/.cargo/env
    bass source ~/.rokit/env
    bind ctrl-d ''
    # Commands to run in interactive sessions can go here
    function bind_bang
        switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
        end
    end

    function bind_dollar
        switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
        end
    end

    function fish_user_key_bindings
        bind ! bind_bang
        bind '$' bind_dollar
    end

    function fish_greeting
        fortune -s | cowsay -f larvitar-sm
        echo
    end

    function postexec_test --on-event fish_postexec
        echo
    end

    zoxide init --cmd cd fish | source
    pyenv init - fish | source

    bass source ~/.bash_aliases
end
