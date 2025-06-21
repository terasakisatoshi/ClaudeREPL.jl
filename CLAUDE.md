# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeREPL.jl is a Julia package that provides a REPL mode for interacting with Claude AI directly from the Julia REPL. It integrates with Claude Code CLI via the ClaudeCodeSDK.jl dependency.

## Development Commands

### Testing
```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

### Installation for Development
```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
```

## Architecture

The package has three main components:

1. **src/ClaudeREPL.jl**: Main module with exports and initialization. Automatically initializes the REPL mode when Base.active_repl is available.

2. **src/repl.jl**: REPL mode implementation using ReplMaker.jl
   - Uses `initrepl()` from ReplMaker.jl to create custom REPL mode
   - `claude_repl_parser()` function handles input processing and special commands
   - Provides special commands: `help`, `clear`, `exit`
   - Much simpler implementation compared to direct REPL.jl usage

3. **src/claude.jl**: Claude AI communication layer
   - Uses ClaudeCodeSDK.query() for communication with Claude Code CLI
   - Manages conversation history with MAX_HISTORY_SIZE limit (100 messages)
   - Handles SDK-specific error types (ClaudeSDKError, CLIConnectionError, CLINotFoundError)

## Key Dependencies

- **ReplMaker.jl**: Simplified REPL mode creation - replaces direct REPL.jl usage
- **ClaudeCodeSDK.jl**: Core integration with Claude Code CLI - this is the primary interface
- **JSON3.jl**: JSON handling for conversation data

## REPL Mode Details

- Mode prompt: "claude> "
- Entry: Press Ctrl-g from any Julia prompt
- Exit handled automatically by ReplMaker.jl (backspace or special commands)
- The mode initializes via `initrepl()` call in `__init__()` when the package is loaded
- ReplMaker.jl handles all the complex REPL internals automatically

## Error Handling

The claude.jl module specifically handles ClaudeCodeSDK error types. When debugging connection issues, check:
1. Claude Code CLI installation
2. ClaudeCodeSDK connection status
3. Conversation history size (auto-trimmed at 100 messages)