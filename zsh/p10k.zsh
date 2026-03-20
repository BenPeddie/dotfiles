# Powerlevel10k configuration
# Generated for dotfiles with AWS SSO expiry segment
# To customize further, run: p10k configure

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Left prompt segments
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    prompt_char             # prompt symbol
  )

  # Right prompt segments
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    aws_sso                 # AWS SSO session expiry (custom)
    cursor_spend            # Cursor spend today (Enterprise Admin API)
    node_version            # node.js version
    go_version              # go version
    context                 # user@hostname
    time                    # current time
  )

  # =============================================================================
  # Visual Style - Rainbow/Powerline with backgrounds
  # =============================================================================
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  # Powerline separators (angled)
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '

  # End/start symbols for the prompt edges
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  # No extra newline before prompt
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # =============================================================================
  # Prompt Character
  # =============================================================================
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true

  # =============================================================================
  # Directory
  # =============================================================================
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=31
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER='…'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=250
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # Directory classes with icons
  # Note: ~emitwise is a named directory defined in zshrc (hash -d emitwise=~/dev/emitwise-v2)
  # This makes paths show as ~emitwise/service instead of ~/dev/emitwise-v2/service
  typeset -g POWERLEVEL9K_DIR_CLASSES=(
    '~emitwise(|/*)'  EMITWISE  '󰲋'
    '~/dev(|/*)'      DEV       '󰲋'
    '~'               HOME      ''
    '*'               DEFAULT   ''
  )

  typeset -g POWERLEVEL9K_DIR_EMITWISE_BACKGROUND=31
  typeset -g POWERLEVEL9K_DIR_EMITWISE_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_EMITWISE_SHORTENED_FOREGROUND=250
  typeset -g POWERLEVEL9K_DIR_EMITWISE_ANCHOR_FOREGROUND=255

  typeset -g POWERLEVEL9K_DIR_DEV_BACKGROUND=31
  typeset -g POWERLEVEL9K_DIR_DEV_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_HOME_BACKGROUND=31
  typeset -g POWERLEVEL9K_DIR_HOME_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_DEFAULT_BACKGROUND=31
  typeset -g POWERLEVEL9K_DIR_DEFAULT_FOREGROUND=254

  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.git|package.json|go.mod)'

  # Lock icon for non-writable directories
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='󰌾'

  # =============================================================================
  # Git/VCS
  # =============================================================================
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=22
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=254
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=130
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=254
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=130
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=254
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=196
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=254
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=244
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=254

  # Branch icon
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '

  # Git status icons
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='*'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_ICON='~'
  # Disable stash display by removing git-stash from hooks
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-remotebranch git-tagname)

  # Commit/tag icons
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  typeset -g POWERLEVEL9K_VCS_TAG_ICON=' '

  # Remote tracking
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'

  # Formatting
  typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM=1
  typeset -g POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM=1

  # =============================================================================
  # Status (exit code)
  # =============================================================================
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=22
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=254
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=22
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=254
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=52
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=254
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=52
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=254
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_BACKGROUND=52
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=254
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

  # =============================================================================
  # Command Execution Time
  # =============================================================================
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=238
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=254
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION='󱎫'

  # =============================================================================
  # Background Jobs
  # =============================================================================
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=57
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=254
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⚙'

  # =============================================================================
  # Context (user@host)
  # =============================================================================
  # Only show in SSH sessions or when root
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=178
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=180

  # =============================================================================
  # Node Version
  # =============================================================================
  typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=22
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=254
  typeset -g POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_EXPANSION='󰎙'
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  # =============================================================================
  # Go Version
  # =============================================================================
  typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=37
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=254
  typeset -g POWERLEVEL9K_GO_VERSION_VISUAL_IDENTIFIER_EXPANSION='󰟓'
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true

  # =============================================================================
  # Time
  # =============================================================================
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=236
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=254
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=''

  # =============================================================================
  # AWS SSO Expiry (Custom Segment)
  # =============================================================================
  function prompt_aws_sso() {
    local best_epoch=0 f content exp epoch now_epoch=$EPOCHSECONDS

    # Check SSO access token first (this is what `aws sso login` refreshes)
    for f in ~/.aws/sso/cache/*.json(N); do
      content=$(<"$f")
      [[ "$content" == *'"accessToken"'* ]] || continue
      if [[ "$content" =~ '"expiresAt"[[:space:]]*:[[:space:]]*"([^"]+)"' ]]; then
        exp="${match[1]}"
        epoch=$(TZ=UTC /bin/date -jf "%Y-%m-%dT%H:%M:%SZ" "$exp" +%s 2>/dev/null) || continue
        (( epoch > best_epoch )) && best_epoch=$epoch
      fi
    done

    # Also check CLI cache for role credentials, but only if they're still valid
    for f in ~/.aws/cli/cache/*.json(N); do
      content=$(<"$f")
      if [[ "$content" =~ '"Expiration"[[:space:]]*:[[:space:]]*"([^"]+)"' ]]; then
        exp="${match[1]/+00:00/Z}"
        epoch=$(TZ=UTC /bin/date -jf "%Y-%m-%dT%H:%M:%SZ" "$exp" +%s 2>/dev/null) || continue
        # Only consider if not expired and later than current best
        (( epoch > now_epoch && epoch > best_epoch )) && best_epoch=$epoch
      fi
    done

    (( best_epoch > 0 )) || return

    local remaining=$(( best_epoch - now_epoch ))
    local color text

    local bg fg
    if (( remaining <= 0 )); then
      bg=124  # Dark red background
      fg=254
      text="expired"
    elif (( remaining < 1800 )); then
      bg=166  # Orange background (< 30 min)
      fg=254
      text="$((remaining / 60))m"
    elif (( remaining < 3600 )); then
      bg=136  # Yellow/gold background (30-60 min)
      fg=254
      text="$((remaining / 60))m"
    else
      local h=$((remaining / 3600))
      local m=$(( (remaining % 3600) / 60 ))
      text="${h}h${m}m"
      bg=22   # Dark green background (> 1 hour)
      fg=254
    fi

    # AWS icon: 
    p10k segment -b $bg -f $fg -i '' -t "$text"
  }

  # =============================================================================
  # Cursor spend today (CURSOR_SPEND_PROMPT from precmd hook in zshrc)
  # =============================================================================
  typeset -g POWERLEVEL9K_CURSOR_SPEND_BACKGROUND=236
  typeset -g POWERLEVEL9K_CURSOR_SPEND_FOREGROUND=109
  typeset -g POWERLEVEL9K_CURSOR_SPEND_VISUAL_IDENTIFIER_EXPANSION='󰆘'

  function prompt_cursor_spend() {
    [[ -n "$CURSOR_SPEND_PROMPT" ]] || return
    p10k segment -b $POWERLEVEL9K_CURSOR_SPEND_BACKGROUND -f $POWERLEVEL9K_CURSOR_SPEND_FOREGROUND -i $POWERLEVEL9K_CURSOR_SPEND_VISUAL_IDENTIFIER_EXPANSION -t "$CURSOR_SPEND_PROMPT"
  }

  # =============================================================================
  # Transient Prompt
  # =============================================================================
  # When enabled, shows minimal prompt for previous commands
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # =============================================================================
  # Instant Prompt
  # =============================================================================
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

}

# Tell p10k that this file was sourced
(( ${+functions[p10k]} )) || source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
