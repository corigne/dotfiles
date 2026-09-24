function inject-secrets --description "Inject pass secrets into the current shell environment"
    # Two source types:
    #   pass:<pass-path>          — read from pass store
    #   gpg:<path-to-file.gpg>   — decrypt a standalone GPG file
    set -l secret_map \
        "CANVAS_TOKEN=pass:api-tokens/CANVAS_TOKEN" \
        "E621_USERNAME=gpg:$HOME/Documents/.crpyt/e621_username.gpg" \
        "E621_API_KEY=gpg:$HOME/Documents/.crpyt/e621_api_key.gpg"

    for entry in $secret_map
        set -l var_name (string split -f 1 "=" $entry)
        set -l source   (string split -f 2 "=" $entry)
        set -l kind     (string split -f 1 ":" $source)
        set -l ref      (string split -f 2 ":" $source)

        set -l value
        switch $kind
            case pass
                set value (pass show $ref 2>/dev/null)
            case gpg
                set value (gpg --quiet --decrypt $ref 2>/dev/null)
        end

        if test $status -eq 0 -a -n "$value"
            set -gx $var_name $value
            set -q secrets_debug && echo "✓ Injected $var_name"
        else
            set -q secrets_debug && echo "✗ Failed to inject $var_name ($kind:$ref)" >&2
        end
    end
end
