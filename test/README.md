# ClaudeREPL.jl Test Suite

This directory contains comprehensive tests for ClaudeREPL.jl functionality.

## Test Files Overview

### `test_simple.jl` (Main Test Suite)
The primary test file that runs by default. Tests core functionality that can be safely executed without a full REPL environment:

- **Module Structure**: Verifies module exports and function availability
- **Function Types**: Ensures exported functions are callable
- **Constants**: Validates configuration constants and history settings
- **History File Path**: Tests history file configuration and path validation
- **Safe Function Calls**: Tests functions that don't require active REPL context

### Additional Test Files (For Development/Manual Testing)

- **`test_basic.jl`**: Extended basic functionality tests
- **`test_repl.jl`**: REPL mode initialization and navigation tests
- **`test_history.jl`**: Comprehensive history management tests
- **`test_claude.jl`**: Claude communication and API interaction tests
- **`test_integration.jl`**: Full integration and workflow tests

## Running Tests

### Standard Test Suite
```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

### Extended Tests (Requires Claude CLI)
```bash
CLAUDE_FULL_TESTS=true julia --project=. -e "using Pkg; Pkg.test()"
```

## Test Design Philosophy

### Safe Testing
The main test suite focuses on testing components that:
- Don't require an active REPL session
- Don't depend on external Claude CLI authentication
- Can run reliably in CI/CD environments
- Test the package's core structure and exports

### Environment Considerations
Some tests are skipped by default because they require:
- Active Julia REPL session (`Base.active_repl`)
- Claude Code CLI installation and authentication
- Network connectivity for Claude API calls
- Write permissions for history files

## Test Coverage

The test suite covers:
- ✅ Module structure and exports
- ✅ Function availability and types
- ✅ Configuration constants
- ✅ History file path validation
- ✅ Safe function calls (history management)
- ⚠️ REPL mode functionality (manual testing recommended)
- ⚠️ Claude communication (requires CLI setup)
- ⚠️ Full integration workflows (requires CLI setup)

## Adding New Tests

When adding new tests:

1. **Safe tests** should go in `test_simple.jl`
2. **REPL-dependent tests** should go in `test_repl.jl` 
3. **History tests** should go in `test_history.jl`
4. **Claude API tests** should go in `test_claude.jl`
5. **Integration tests** should go in `test_integration.jl`

Remember to guard REPL and Claude-dependent tests with appropriate environment checks or try-catch blocks.

## Manual Testing

For full functionality validation, manual testing in a Julia REPL is recommended:

```julia
using ClaudeREPL
# Press 'c' to enter Claude mode
# Test arrow key navigation
# Test history persistence across sessions
```