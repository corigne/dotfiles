function inject-secrets --description "Inject pass secrets into the current shell environment"
    # Map of ENV_VAR_NAME=pass/path/to/secret
    # Add or remove entries here to control what gets injected
    set -l secret_map \
        "CANVAS_TOKEN=api-tokens/CANVAS_TOKEN"

    for entry in $secret_map
        set -l var_name (string split -f 1 "=" $entry)
        set -l pass_path (string split -f 2 "=" $entry)

        set -l value (pass show $pass_path 2>/dev/null)
        if test $status -eq 0 -a -n "$value"
            set -gx $var_name $value
            set -q pass_debug && echo "✓ Injected $var_name"
        else
            set -q pass_debug && echo "✗ Failed to inject $var_name (pass show $pass_path returned error)" >&2
        end
    end
end
