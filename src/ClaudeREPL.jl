"""
ClaudeREPL.jl

A Julia REPL mode for interacting with Claude AI directly from the Julia REPL.
Provides secure, rate-limited communication with proper error handling and memory management.
"""
module ClaudeREPL

using REPL
using REPL.LineEdit
using REPL.REPLCompletions
using ClaudeCodeSDK
using JSON3

export claude_repl_init, claude_mode!, send_to_claude, clear_conversation_history!, print_conversation_stats

include("repl.jl")
include("claude.jl")

function __init__()
    if isdefined(Base, :active_repl)
        claude_repl_init()
    end
end

end