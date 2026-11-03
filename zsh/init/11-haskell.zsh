function my_ghcup_init() {
    local ghcup_bin_dir="$HOME/.ghcup/bin"
    [[ -d $ghcup_bin_dir ]] && path=($ghcup_bin_dir $path)
}

function my_cabal_init() {
    local cabal_bin_dir="$HOME/.cabal/bin"
    [[ -d $cabal_bin_dir ]] && path=($cabal_bin_dir $path)
}

my_ghcup_init
my_cabal_init
