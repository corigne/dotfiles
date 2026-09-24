if status is-interactive
    set -x GPG_TTY (tty)
    fish_add_path --prepend ~/.local/bin
    if test -f ~/.config/shell/dev.env
        bass source ~/.config/shell/dev.env
    end
    if test -f ~/.cargo/env
        bass source ~/.cargo/env
    end
    if test -f ~/.rokit/env
        bass source ~/.rokit/env
    end
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
