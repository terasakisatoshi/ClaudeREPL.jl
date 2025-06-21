using ReplMaker

const CLAUDE_REPL_HELP = """
Claude REPL Mode Help:
- Type your question or request to Claude
- Use backspace to exit Claude mode and return to Julia
- Type 'help' for this help message
- Type 'clear' to clear conversation history
- Type 'exit' to exit Claude mode
"""

"""
    claude_repl_parser(input::AbstractString)

Parses and processes input from the Claude REPL mode.
Handles special commands and sends user input to Claude.
"""
function claude_repl_parser(input::AbstractString)
    input = strip(input)
    
    if isempty(input)
        return nothing
    end
    
    # Handle special commands
    if input == "help"
        println(CLAUDE_REPL_HELP)
        return nothing
    elseif input == "clear"
        clear_conversation_history!()
        println("Conversation history cleared.")
        return nothing
    elseif input == "exit"
        println("Exiting Claude mode...")
        return nothing
    end
    
    # Send input to Claude
    try
        response = send_to_claude(input)
        println(response)
    catch e
        printstyled("Error communicating with Claude: ", color=:red)
        println(e)
    end
    
    return nothing
end

"""
    claude_repl_init()

Initializes the Claude REPL mode using ReplMaker.
Press 'c' at the beginning of a line to enter Claude mode.
"""
function claude_repl_init()
    try
        initrepl(
            claude_repl_parser,
            prompt_text = "claude> ",
            prompt_color = :blue,
            start_key = 'c',
            mode_name = "claude_mode"
        )
    catch e
        @warn "Failed to initialize Claude REPL mode: $e"
    end
end

"""
    claude_mode!()

Manually switch to claude mode (alias for compatibility).
Note: With ReplMaker, mode switching is handled automatically.
"""
function claude_mode!()
    @info "Claude REPL mode is available. Press 'c' at the beginning of a line to enter Claude mode."
end