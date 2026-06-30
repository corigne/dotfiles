# Fish completions for imgsorter
# Auto-installed to ~/.config/fish/completions/ via `make install`

set -l commands fetch train classify reorganize purge evaluate taste discover

# Disable file completions globally; re-enable per-subcommand where needed
complete -c imgsorter -f

# ── subcommands ───────────────────────────────────────────────────────────────
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a fetch      -d "Download labeled training images from external sources"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a train      -d "Train / fine-tune classifier"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a classify   -d "Classify unsorted images in a directory"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a reorganize -d "Reorganize library by predicted content ratings"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a purge      -d "Delete cached data"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a evaluate   -d "Test model accuracy on your sorted library"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a taste      -d "Build/update tag-preference index"
complete -c imgsorter -n "not __fish_seen_subcommand_from $commands" -a discover   -d "Interactively find new wallpapers matching your taste"

# ── fetch ─────────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from fetch" -l sources    -d "Sources to fetch from" -a "konachan e621" -r
complete -c imgsorter -n "__fish_seen_subcommand_from fetch" -l per-class  -d "Images per rating class per source (default: 500)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from fetch" -l min-score  -d "Minimum community score (default: 50)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from fetch" -l output-dir -d "Override cache directory" -r -F

# ── train ─────────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from train" -l skip-external -d "Train on personal library only"
complete -c imgsorter -n "__fish_seen_subcommand_from train" -l skip-personal -d "Train on external data only"
complete -c imgsorter -n "__fish_seen_subcommand_from train" -l model-dir     -d "Override model output directory" -r -F
complete -c imgsorter -n "__fish_seen_subcommand_from train" -l phase2-only   -d "Skip Phase 1, run Phase 2 fine-tuning only"

# ── classify ──────────────────────────────────────────────────────────────────
# positional directory arg — re-enable file completion
complete -c imgsorter -n "__fish_seen_subcommand_from classify" -F
complete -c imgsorter -n "__fish_seen_subcommand_from classify" -s o -l output    -d "Output report path (.csv or .json)" -r -F
complete -c imgsorter -n "__fish_seen_subcommand_from classify" -l threshold      -d "Confidence threshold (default: 0.6)" -r

# ── reorganize ────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from reorganize" -l library          -d "Library root (default: ~/Pictures)" -r -F
complete -c imgsorter -n "__fish_seen_subcommand_from reorganize" -l apply            -d "Actually move files (default: dry-run)"
complete -c imgsorter -n "__fish_seen_subcommand_from reorganize" -l threshold        -d "Min confidence to act on reclassification (default: 0.75)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from reorganize" -s o -l output      -d "Write reorganization report (.csv or .json)" -r -F
complete -c imgsorter -n "__fish_seen_subcommand_from reorganize" -l review-uncertain -d "Interactively review low-confidence moves"

# ── purge ─────────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from purge" -l force         -d "Skip confirmation prompt"
complete -c imgsorter -n "__fish_seen_subcommand_from purge" -l taste-db      -d "Also wipe taste index DB"
complete -c imgsorter -n "__fish_seen_subcommand_from purge" -l taste-db-only -d "Wipe ONLY taste DB, keep training cache"

# ── evaluate ──────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l samples       -d "Images per rating class to sample (default: 50)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l library       -d "Library root (default: ~/Pictures)" -r -F
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l preview       -d "Force inline image preview"
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l no-preview    -d "Disable inline image preview"
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l open          -d "xdg-open every misclassified image"
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l all           -d "Print all misclassified images without pause"
complete -c imgsorter -n "__fish_seen_subcommand_from evaluate" -l anim-duration -d "Seconds to play animated GIFs" -r

# ── taste ─────────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l library       -d "Library root (default: ~/Pictures)" -r -F
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l refetch       -d "Re-fetch tags from API even if cached"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l summary       -d "Compact single-screen summary"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l full-summary  -d "Full summary with per-source tables"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l top           -d "Top N tags to show in summary (default: 25)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l sfw-only      -d "Filter explicit/suggestive tags from summary"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l wd-tag        -d "Auto-tag with WD-tagger (downloads ~300 MB first use)"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l tag-queue     -d "Interactively tag images in the manual queue"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l batch         -d "Process only N images from the queue" -r
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l reset-skipped -d "Reset permanently-skipped queue items to pending"
complete -c imgsorter -n "__fish_seen_subcommand_from taste" -l no-ai-blurb   -d "Skip AI-generated summary"

# ── discover ──────────────────────────────────────────────────────────────────
complete -c imgsorter -n "__fish_seen_subcommand_from discover" -s n                   -d "Number of images to accept (default: 10)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from discover" -l rating              -d "Rating filter" -a "safe questionable nsfw lewd all" -r
complete -c imgsorter -n "__fish_seen_subcommand_from discover" -l source              -d "Source to query" -a "konachan e621 rule34 both all" -r
complete -c imgsorter -n "__fish_seen_subcommand_from discover" -l max-pages           -d "Max API pages per source (default: 20)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from discover" -l explore-rate        -d "Explore fraction 0.0–1.0 (default: 0.15)" -r
complete -c imgsorter -n "__fish_seen_subcommand_from discover" -l no-wallpaper-filter -d "Disable wallpaper dimension/quality gates"
