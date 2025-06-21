# ClaudeREPL.jl

A Julia REPL mode for interacting with Claude AI directly from the Julia REPL using ClaudeCodeSDK.

## Features

- **Seamless REPL Integration**: Press `c` to enter Claude mode, backspace to exit
- **Native REPL Implementation**: Uses Julia's built-in REPL system for stability
- **Automatic Initialization**: Claude mode is set up automatically when the package loads
- **Simple Commands**: Built-in help, clear, and exit commands
- **Error Handling**: Proper error handling for Claude API interactions

## Prerequisites

Before using ClaudeREPL.jl, you need:

1. **Claude Code CLI**: Install and configure the Claude Code CLI
   - Follow the installation guide at [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code)
   - Ensure the CLI is authenticated and working

2. **ClaudeCodeSDK.jl**: This package depends on ClaudeCodeSDK.jl for Claude integration

## Installation

```julia
git clone https://github.com/terasakisatoshi/ClaudeREPL.jl.git
cd ClaudeREPL.jl
julia --project -e 'using Pkg; Pkg.instantiate()'
```

## Usage

### Basic Usage

1. Start Julia and load the package:
```julia
julia> using ClaudeREPL
Claude REPL mode initialized. Press 'c' to enter and backspace to exit.
```

2. Enter Claude mode by pressing `c` at the beginning of a line:
```julia
julia> c
claude> What is the capital of France?
The capital of France is Paris.

claude> How do I create a vector in Julia?
You can create a vector in Julia in several ways:
- Using square brackets: [1, 2, 3, 4]
- Using the Vector constructor: Vector{Int}([1, 2, 3, 4])
- Using collect(): collect(1:4)

claude>
```

3. Exit Claude mode by pressing backspace at an empty prompt or typing `exit`:
```julia
claude> [backspace]
julia>
```

### Special Commands

Within Claude mode, you can use these special commands:

- `help`: Display help message with available commands
- `exit`: Exit Claude mode and return to Julia

Example:
```julia
claude> help
Claude REPL Mode Help:
- Type your question or request to Claude
- Use backspace to exit Claude mode and return to Julia
- Type 'help' for this help message
- Type 'exit' to exit Claude mode

claude> clear
Conversation history cleared.

claude> exit
julia>
```

### Manual Mode Switching

You can also manually switch to Claude mode using:
```julia
julia> claude_mode!()
claude>
```

## Requirements

- Julia 1.10+
- ClaudeCodeSDK 0.1.0+
- Active Claude Code CLI installation and authentication

## Dependencies

- [ClaudeCodeSDK.jl](https://github.com/AtelierArith/ClaudeCodeSDK.jl): Core integration with Claude Code CLI
- REPL: Julia's built-in REPL system

## Architecture

The package is structured into three main components:

### Core Module (`src/ClaudeREPL.jl`)
- Main module definition with automatic initialization
- Exports key functions: `claude_repl_init`, `claude_mode!`, `send_to_claude`, `clear_conversation_history!`
- Handles package loading and REPL setup

### REPL Integration (`src/repl.jl`)
- Native Julia REPL mode implementation
- Key binding setup ('c' to enter, backspace to exit)
- Command handling and user interface
- Stable integration without external dependencies

### Claude Communication (`src/claude.jl`)
- Interface to ClaudeCodeSDK for AI interactions
- Error handling for API communication
- Response processing and formatting

## Troubleshooting

### Common Issues

1. **"Claude CLI not found" error**: Ensure Claude Code CLI is installed and in your PATH
2. **Authentication errors**: Run `claude auth login` to authenticate the CLI
3. **Mode not initialized**: The package automatically initializes on load, but you can manually call `claude_repl_init()` if needed

### Manual Initialization

If automatic initialization fails, you can manually set up the REPL mode:
```julia
julia> claude_repl_init()
```

## Testing

```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License.

## Authors

- Claude Code and Satoshi Terasaki
