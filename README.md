# ClaudeREPL.jl

> A seamless Claude AI integration for the Julia REPL

ClaudeREPL.jl brings Claude AI directly into your Julia workflow. Chat with Claude without leaving your REPL environment, complete with persistent history and rich markdown formatting.

## ✨ Features

- 🚀 **One-key access**: Press `)` to instantly enter Claude mode
- 📚 **Persistent history**: Navigate previous conversations with arrow keys across Julia sessions
- 🎨 **Rich formatting**: Markdown rendering for code blocks, lists, and formatting
- 🔄 **Seamless integration**: Native Julia REPL experience with automatic initialization
- 🛡️ **Robust error handling**: Graceful handling of network issues and API errors
- ⚡ **Streaming responses**: Real-time response display as Claude types

## 🚀 Quick Start

### Prerequisites

You'll need the Claude Code CLI installed and authenticated:

```bash
# Install Claude Code CLI (see https://docs.anthropic.com/en/docs/claude-code)
# Then authenticate
claude auth login
```

### Installation

```julia
# Clone and install
git clone https://github.com/terasakisatoshi/ClaudeREPL.jl.git
cd ClaudeREPL.jl
julia --project -e 'using Pkg; Pkg.instantiate()'
```

### Basic Usage

```julia
julia> using ClaudeREPL
Claude REPL mode initialized. Press ')' to enter and backspace to exit.

julia> )
claude> What's the difference between map and broadcast in Julia?

# Claude responds with detailed explanation...

claude> Can you show me an example of metaprogramming?

# Use ↑ arrow to navigate back to previous questions
# Press backspace on empty line to return to Julia REPL
```

## 📖 How to Use

### Entering Claude Mode

**Method 1: Quick key** (recommended)
```julia
julia> )    # Press ')' at the start of any line
claude> 
```

**Method 2: Function call**
```julia
julia> claude_mode!()
claude> 
```

### Navigation and History

- **↑/↓ Arrow keys**: Navigate through command history
- **Ctrl+P/Ctrl+N**: Alternative history navigation
- **Backspace** (on empty line): Exit to Julia REPL
- **Type `exit`**: Exit to Julia REPL
- **Type `help`**: Show help message

### History Features

Your conversations are automatically saved and restored:

- **Persistent storage**: History saved to `DEPOT_PATH[1]/config/claude_repl_history.txt`
- **Cross-session**: Access previous conversations after restarting Julia
- **Smart deduplication**: Consecutive identical commands are filtered out
- **Reasonable limits**: Keeps last 100 commands for optimal performance

## 🛠️ Configuration

### History File Location

History is stored in your Julia depot:
```julia
# Check your history file location
julia> using ClaudeREPL
julia> println(ClaudeREPL.CLAUDE_HISTORY_FILE)
```

### Manual Initialization

If auto-initialization fails:
```julia
julia> claude_repl_init()
```

## 🔧 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `Claude CLI not found` | Install Claude Code CLI and ensure it's in PATH |
| Authentication errors | Run `claude auth login` |
| History not working | Check write permissions for `DEPOT_PATH[1]/config/` |
| Arrow keys not working | Ensure you're in Claude mode (`claude>` prompt) |
| Responses not displaying | Check Claude CLI connection with `claude --version` |

### Getting Help

```julia
claude> help
```

Shows available commands and keyboard shortcuts.

## 🏗️ Architecture

ClaudeREPL.jl consists of three main components:

### Core Module (`src/ClaudeREPL.jl`)
- Package exports and automatic initialization
- Integration with Julia's module system

### REPL Integration (`src/repl.jl`)
- Custom REPL mode with native Julia integration
- Manual history system with persistent storage
- Key binding management and safe error handling

### Claude Communication (`src/claude.jl`)
- Streaming interface to ClaudeCodeSDK
- Markdown response processing and display
- Robust error handling for API communication

## 🧪 Development

### Running Tests

```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

### Dependencies

- **Julia**: 1.10+
- **[ClaudeCodeSDK.jl](https://github.com/AtelierArith/ClaudeCodeSDK.jl)**: Core Claude integration
- **Standard Library**: REPL, Markdown

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs and request features via [GitHub Issues](https://github.com/terasakisatoshi/ClaudeREPL.jl/issues)
- Submit pull requests for improvements
- Share usage examples and workflows

## 📄 License

MIT License - see LICENSE file for details.

## 👥 Authors

- [Satoshi Terasaki](https://github.com/terasakisatoshi)
- Claude Code

---

*Built with ❤️ for the Julia community*