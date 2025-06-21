"""
    claude_repl_init()

Initializes the Claude REPL mode.
Press 'c' at the beginning of a line to enter Claude mode.
"""
function claude_repl_init()
    repl = Base.active_repl

    if !isdefined(repl, :interface)
        repl.interface = REPL.setup_interface(repl)
    end

    # Check if Claude mode already exists
    claude_mode = nothing
    for mode in repl.interface.modes
        if isa(mode, LineEdit.Prompt) && mode.prompt == "claude> "
            claude_mode = mode
            break
        end
    end

    if claude_mode === nothing
        claude_mode = LineEdit.Prompt("claude> ";
            prompt_prefix = Base.text_colors[:blue],
            prompt_suffix = Base.text_colors[:normal],
            on_enter = s -> true,
            on_done = claude_on_done,
            sticky = true
        )

        push!(repl.interface.modes, claude_mode)

        # Set up key bindings
        main_mode = repl.interface.modes[1]

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

    println("Claude REPL mode initialized. Press 'c' to enter and backspace to exit.")
    return claude_mode
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
        println("""
Claude REPL Mode Help:
- Type your question or request to Claude
- Use backspace to exit Claude mode and return to Julia
- Type 'help' for this help message
- Type 'exit' to exit Claude mode
""")
        return true
    elseif input == "exit"
        try
            repl = Base.active_repl
            if isdefined(repl, :interface) && !isempty(repl.interface.modes)
                main_mode = repl.interface.modes[1]
                LineEdit.transition(s, main_mode)
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
        println(sprint(showerror, e))
    end

    return true
end

"""
    claude_mode!()

Manually switch to claude mode.
"""
function claude_mode!()
    repl = Base.active_repl
    if isdefined(repl, :interface) && length(repl.interface.modes) > 1
        claude_mode = nothing
        for mode in repl.interface.modes
            if isa(mode, LineEdit.Prompt) && mode.prompt == "claude> "
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