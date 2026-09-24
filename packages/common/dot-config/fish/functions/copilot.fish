function copilot
    set -lx NODE_OPTIONS (string join ' ' -- $NODE_OPTIONS --max-old-space-size=16384)
    command copilot $argv
end
