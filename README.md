# ClaudeREPL.jl

A Julia REPL mode for interacting with Claude AI directly from the Julia REPL. Provides secure, rate-limited communication with proper error handling and memory management.

## Features

- **Seamless REPL Integration**: Press `Ctrl-g` to enter Claude mode, backspace to exit
- **Simplified Implementation**: Built on ReplMaker.jl for reliable REPL mode creation
- **Special Commands**: Built-in help, clear, and exit commands
- **Conversation Management**: Automatic history management with size limits
- **Error Handling**: Robust error handling for SDK and connection issues

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

2. The Claude REPL mode is automatically initialized. Enter Claude mode by pressing `Ctrl-g`:
```
julia> [Ctrl-g]
claude> solve 3x + 4 = 5
3x + 4 = 5
3x = 1
x = 1/3
claude>
```

3. Exit Claude mode by pressing backspace at an empty prompt or typing `exit`.

### Special Commands

- `help`: Display help message
- `clear`: Clear conversation history  
- `exit`: Exit Claude mode

## Requirements

- Julia 1.10+
- ClaudeCodeSDK 0.1.0
- Active Claude Code CLI installation

## Dependencies

- [ClaudeCodeSDK.jl](https://github.com/AtelierArith/ClaudeCodeSDK.jl): Core integration with Claude Code
- [ReplMaker.jl](https://github.com/MasonProtter/ReplMaker.jl): Simplified REPL mode creation
- JSON3.jl: JSON handling
- REPL: Julia REPL system integration

## Architecture

The package consists of three main components:

- **ClaudeREPL.jl**: Main module with exports and initialization
- **repl.jl**: REPL mode implementation using ReplMaker.jl with input parsing and special commands
- **claude.jl**: Claude AI communication layer with conversation management and error handling

## Testing

```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

## License

This project is licensed under the MIT License.

## Authors

- Claude Code and Satoshi Terasaki
