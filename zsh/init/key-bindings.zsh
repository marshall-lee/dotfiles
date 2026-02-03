# Inspired by ohmyzsh.
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh

function my_keybindings_init() {
  if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() {
      echoti smkx
    }
    function zle-line-finish() {
      echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish

    autoload -U up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
  fi

  bindkey -v

  local -A norman_mapping=(
    [d]=e
    [D]=E
    [e]=d
    [E]=D
    [f]=t
    [F]=T
    [h]=y
    [H]=Y
    [i]=r
    [I]=R
    [j]=n
    [J]=N
    [k]=i
    [K]=I
    [l]=o
    [L]=O
    [n]=p
    [N]=P
    [o]=l
    [O]=L
    [p]=";"
    [P]=":"
    [r]=f
    [R]=F
    [t]=k
    [T]=K
    [y]=j
    [Y]=J
    [";"]=h
    [":"]=H
  )

  local mapping=norman_mapping

  bindkey -M vicmd "${${(P)mapping}[d]}" vi-delete
  bindkey -M vicmd "${${(P)mapping}[D]}" vi-kill-eol
  bindkey -M vicmd "${${(P)mapping}[e]}" vi-forward-word-end
  bindkey -M vicmd "${${(P)mapping}[E]}" vi-forward-blank-word-end
  bindkey -M vicmd "${${(P)mapping}[f]}" vi-find-next-char
  bindkey -M vicmd "${${(P)mapping}[F]}" vi-find-prev-char
  bindkey -M vicmd "${${(P)mapping}[n]}" vi-repeat-search
  bindkey -M vicmd "${${(P)mapping}[N]}" vi-rev-repeat-search
  bindkey -M vicmd "${${(P)mapping}[;]}" vi-repeat-find
  bindkey -M vicmd "${${(P)mapping}[:]}" execute-named-cmd
  bindkey -M vicmd "${${(P)mapping}[o]}" vi-open-line-below
  bindkey -M vicmd "${${(P)mapping}[O]}" vi-open-line-above
  bindkey -M vicmd "${${(P)mapping}[p]}" vi-put-after
  bindkey -M vicmd "${${(P)mapping}[P]}" vi-put-before
  bindkey -M vicmd "${${(P)mapping}[r]}" vi-replace-chars
  bindkey -M vicmd "${${(P)mapping}[R]}" vi-replace
  bindkey -M vicmd "${${(P)mapping}[t]}" vi-find-next-char-skip
  bindkey -M vicmd "${${(P)mapping}[T]}" vi-find-prev-char-skip
  bindkey -M vicmd "${${(P)mapping}[i]}" vi-insert
  bindkey -M vicmd "${${(P)mapping}[I]}" vi-insert-bol
  bindkey -M vicmd "${${(P)mapping}[h]}" vi-backward-char
  bindkey -M vicmd "${${(P)mapping}[j]}" down-line-or-history
  bindkey -M vicmd "${${(P)mapping}[J]}" vi-join
  bindkey -M vicmd "${${(P)mapping}[k]}" up-line-or-history
  bindkey -M vicmd "${${(P)mapping}[l]}" vi-forward-char
  bindkey -M vicmd "${${(P)mapping}[y]}" vi-yank
  bindkey -M vicmd "${${(P)mapping}[Y]}" vi-yank-whole-line
  bindkey -M vicmd "g${${(P)mapping}[e]}" vi-backward-word-end
  bindkey -M vicmd "g${${(P)mapping}[E]}" vi-backward-blank-word-end
  bindkey -M vicmd "^${${(P)mapping}[R]}" redo

  # Page Up.
  # It is expected that we remap Ctrl+I to Page Up in the terminal emulator.
  # This is because default ansi code for Ctrl+I is ^I which the same as TAB.
  if [[ -n ${widgets[up-line-or-beginning-search]} ]] {
    bindkey -M vicmd "^[[5~" up-line-or-beginning-search
    bindkey -M viins "^[[5~" up-line-or-beginning-search
  } else {
    bindkey -M vicmd "^[[5~" up-line-or-history # Page Up key remapped from Ctrl-I in alacritty config.
    bindkey -M viins "^[[5~" up-line-or-history
  }

  # Ctrl-J / Page Down
  if [[ -n ${widgets[up-line-or-beginning-search]} ]] {
    bindkey -M vicmd "^${${(P)mapping}[J]}" down-line-or-beginning-search
    bindkey -M viins "^${${(P)mapping}[J]}" down-line-or-beginning-search
  } else {
    bindkey -M vicmd "^${${(P)mapping}[J]}" down-line-or-history
    bindkey -M viins "^${${(P)mapping}[J]}" down-line-or-history
  }

  # bindkey -M viins "^G" vi-ins
  bindkey -M viins "^[." insert-last-word
  bindkey -M viins "^[m" copy-prev-shell-word
  bindkey -M viins "^F" history-incremental-search-backward
  bindkey -M viins "^S" history-incremental-search-forward
  bindkey -M viins "^O" clear-screen

  # Emacs-style hybrid bindings
  bindkey -M viins "^B" vi-backward-char
  bindkey -M viins "^${${(P)mapping}[F]}" vi-forward-char
  bindkey -M viins "^${${(P)mapping}[D]}" end-of-line
  bindkey -M viins "^G" send-break
  bindkey -M viins "^[b" backward-word
  bindkey -M viins "^[${${(P)mapping}[f]}" forward-word
}

my_keybindings_init
