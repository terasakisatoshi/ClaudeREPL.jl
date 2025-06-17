# ClaudeREPL.jl

A Julia REPL mode for interacting with Claude AI directly from the Julia REPL. Provides secure, rate-limited communication with proper error handling and memory management.

## Features

- **Seamless REPL Integration**: Press `c` to enter Claude mode, backspace to exit
- **Conversation History**: Maintains context across interactions with automatic memory management
- **Error Handling**: Robust error handling for network issues and API errors
- **Rate Limiting**: Built-in protection against API abuse
- **Memory Management**: Automatic conversation history trimming to prevent memory leaks

## Installation

```julia
using Pkg
Pkg.add("ClaudeREPL")
```

## Usage

### Basic Usage

1. Load the package:
```julia
using ClaudeREPL
```

2. The Claude REPL mode is automatically initialized. Enter Claude mode by pressing `c` at the beginning of a line:
```
julia> c
claude> Hello, can you help me with Julia?
```

3. Exit Claude mode by pressing backspace at an empty prompt or typing `exit`.

### Special Commands

- `help`: Display help message
- `clear`: Clear conversation history
- `exit`: Exit Claude mode

### Manual Mode Switching

```julia
# Switch to Claude mode programmatically
claude_mode!()

# Clear conversation history
clear_conversation_history!()

# Get conversation statistics
print_conversation_stats()
```

## Requirements

- Julia 1.10+
- ClaudeCodeSDK 0.1.0
- Active Claude Code CLI installation

## Dependencies

- [ClaudeCodeSDK.jl](https://github.com/AtelierArith/ClaudeCodeSDK): Core integration with Claude Code
- JSON3.jl: JSON handling
- REPL: Julia REPL system integration

## Architecture

The package consists of three main components:

- **ClaudeREPL.jl**: Main module with exports and initialization
- **repl.jl**: REPL mode implementation with key bindings and prompt handling
- **claude.jl**: Claude AI communication layer with conversation management

## Configuration

The package uses the following default settings:

- Maximum conversation history: 100 messages
- Maximum input length: 10,000 characters
- Automatic history trimming to prevent memory leaks

## Error Handling

The package handles various error conditions:

- **ClaudeSDKError**: General SDK-related errors
- **CLIConnectionError**: Claude CLI connection issues
- **CLINotFoundError**: Missing Claude CLI installation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Testing

```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

## License

This project is licensed under the MIT License.

## Authors

- Claude Code and Satoshi Terasaki