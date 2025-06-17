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
git clone https://github.com/terasakisatoshi/ClaudeREPL.jl.git
cd ClaudeREPL.jl
julia --project -e 'using Pkg; Pkg.instantiate()'
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
claude> solve 3x + 4 = 5
3x + 4 = 5
3x = 1
x = 1/3
claude>
```

3. Exit Claude mode by pressing backspace at an empty prompt or typing `exit`.

### Special Commands

Warning!!! It contains lots of bugs:

- `help`: Display help message
- `clear`: Clear conversation history
- `exit`: Exit Claude mode

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

## Testing

```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

## License

This project is licensed under the MIT License.

## Authors

- Claude Code and Satoshi Terasaki
