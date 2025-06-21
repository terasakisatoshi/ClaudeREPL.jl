"""
ClaudeREPL.jl

A Julia REPL mode for interacting with Claude AI directly from the Julia REPL.
Provides secure, rate-limited communication with proper error handling and memory management.
"""
module ClaudeREPL

using REPL
using REPL.LineEdit
using ClaudeCodeSDK
using Markdown

include("repl.jl")
include("claude.jl")

function __init__()
    if isdefined(Base, :active_repl)
        claude_repl_init()
    end
end

end