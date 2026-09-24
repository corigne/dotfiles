function rgvim
    set -l tmpfile (mktemp /tmp/rg-qf-XXXXXX)
    rg --vimgrep $argv > $tmpfile
    or begin; rm -f $tmpfile; return 1; end

    nvim +"cfile $tmpfile" +copen
    rm -f $tmpfile
end
