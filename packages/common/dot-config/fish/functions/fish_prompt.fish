function fish_prompt --description Hydro
    prompt_hook
    echo -e -n "$_hydro_color_start$hydro_symbol_start$hydro_color_normal$_hydro_color_pwd$_hydro_pwd$hydro_color_normal $_hydro_color_git$$_hydro_git$hydro_color_normal$_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$_hydro_status$hydro_color_normal "
end

function prompt_hook
    set --query prompt_username || set -g prompt_username (whoami)
    set --query prompt_hostuser_separator || set -g prompt_hostuser_separator "@"
    set --query prompt_hostname || set -g prompt_hostname (hostname)

    set --query prompt_username_color || set -g prompt_username_color blue
    set --query prompt_hostname_color || set -g prompt_hostname_color green
    set --query prompt_hostuser_separator_color || set -g prompt_hostuser_separator_color magenta

    echo -e -n (set_color $prompt_username_color)"$prompt_username"(set_color $prompt_hostuser_separator_color)"$prompt_hostuser_separator"(set_color $prompt_hostname_color)"$prompt_hostname"(set_color normal)" "
end
