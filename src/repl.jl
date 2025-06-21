using REPL
using REPL.LineEdit

const CLAUDE_REPL_MODE_NAME = "claude"
const CLAUDE_REPL_PROMPT = "claude> "
const CLAUDE_REPL_HELP = """
Claude REPL Mode Help:
- Type your question or request to Claude
- Use backspace to exit Claude mode and return to Julia
- Type 'help' for this help message
- Type 'clear' to clear conversation history
- Type 'exit' to exit Claude mode
"""

struct ClaudeREPLMode <: REPL.AbstractREPL
    repl::REPL.LineEditREPL
    mode::LineEdit.Prompt
end

"""
    claude_repl_init()

Initializes the Claude REPL mode and sets up key bindings.
Press 'c' at the beginning of a line to enter Claude mode.
"""
function claude_repl_init()
    repl = Base.active_repl
    
    if !isdefined(repl, :interface)
        repl.interface = REPL.setup_interface(repl)
    end
    
    claude_mode = create_claude_mode(repl)
    
    # Add the mode to the REPL
    push!(repl.interface.modes, claude_mode)
    
    # Set up history provider now that mode is in REPL
    claude_mode.hist = REPL.REPLHistoryProvider(Dict{Symbol,LineEdit.Prompt}(:claude => claude_mode))
    
    # Set up key bindings
    setup_claude_keybindings(repl, claude_mode)
    
    return claude_mode
end

function create_claude_mode(repl)
    claude_mode = LineEdit.Prompt(CLAUDE_REPL_PROMPT;
        prompt_prefix = Base.text_colors[:blue],
        prompt_suffix = Base.text_colors[:normal],
        on_enter = claude_on_enter,
        on_done = claude_on_done,
        sticky = true
    )
    
    # Note: Completion functionality removed due to Julia version compatibility issues
    # History provider will be set up later in claude_repl_init
    
    return claude_mode
end

function setup_claude_keybindings(repl, claude_mode)
    main_mode = repl.interface.modes[1]
    
    # Bind 'c' key to enter claude mode (similar to ] for Pkg mode)
    claude_keymap = Dict{Any,Any}(
        'c' => function (s, args...)
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, claude_mode) do
                    LineEdit.state(s, claude_mode).input_buffer = buf
                end
            else
                LineEdit.edit_insert(s, 'c')
            end
        end
    )
    
    main_mode.keymap_dict = LineEdit.keymap_merge(main_mode.keymap_dict, claude_keymap)
    
    # Set up backspace to exit claude mode
    claude_mode.keymap_dict = LineEdit.keymap_merge(claude_mode.keymap_dict, Dict{Any,Any}(
        '\b' => function (s, args...)
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                LineEdit.transition(s, main_mode)
            else
                LineEdit.edit_backspace(s)
            end
        end
    ))
end

function claude_completions(s, prefix, pos)
    # Basic completions for Claude mode
    completions = ["help", "clear", "exit"]
    return filter(c -> startswith(c, prefix), completions), prefix, true
end

function claude_on_enter(s)
    input = String(take!(copy(LineEdit.buffer(s))))
    return !isempty(strip(input))
end

function claude_on_done(s, buf, ok)
    if !ok
        return REPL.transition(s, :abort)
    end
    
    input = String(take!(buf))
    input = strip(input)
    
    if isempty(input)
        return true
    end
    
    # Handle special commands
    if input == "help"
        println(CLAUDE_REPL_HELP)
        return true
    elseif input == "clear"
        clear_conversation_history!()
        return true
    elseif input == "exit"
        # Exit claude mode and return to Julia
        try
            # Get the REPL from Base.active_repl
            repl = Base.active_repl
            if isdefined(repl, :interface) && !isempty(repl.interface.modes)
                # Find main mode - typically the first mode
                main_mode = repl.interface.modes[1]
                LineEdit.transition(s, main_mode)
            else
                @warn "Cannot find REPL interface"
            end
        catch e
            @warn "Error transitioning to main mode: $e"
        end
        return true
    end
    
    # Send input to Claude
    try
        response = send_to_claude(input)
        println(response)
    catch e
        printstyled("Error communicating with Claude: ", color=:red)
        println(e)
    end
    
    return true
end

"""
    claude_mode!()

Manually switch to claude mode. Searches for the Claude mode by prompt instead of assuming position.
"""
function claude_mode!()
    repl = Base.active_repl
    if isdefined(repl, :interface) && length(repl.interface.modes) > 1
        # Find Claude mode by looking for the correct prompt
        claude_mode = nothing
        for mode in repl.interface.modes
            if isa(mode, LineEdit.Prompt) && mode.prompt == CLAUDE_REPL_PROMPT
                claude_mode = mode
                break
            end
        end
        
        if claude_mode !== nothing
            REPL.LineEdit.transition(repl.interface, claude_mode)
        else
            @warn "Claude REPL mode not found. Run claude_repl_init() first."
        end
    else
        @warn "Claude REPL mode not initialized. Run claude_repl_init() first."
    end
end