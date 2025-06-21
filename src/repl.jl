# Simple manual history system for Claude mode with persistence
const CLAUDE_HISTORY = String[]
const CLAUDE_HISTORY_INDEX = Ref(0)
const CLAUDE_HISTORY_FILE = joinpath(DEPOT_PATH[1], "config", "claude_repl_history.txt")

"""
    load_claude_history!()

Load Claude REPL history from persistent file.
"""
function load_claude_history!()
    try
        if isfile(CLAUDE_HISTORY_FILE)
            lines = readlines(CLAUDE_HISTORY_FILE)
            # Filter out empty lines and limit to last 100 entries
            valid_lines = filter(!isempty, strip.(lines))
            if length(valid_lines) > 100
                valid_lines = valid_lines[end-99:end]
            end
            empty!(CLAUDE_HISTORY)
            append!(CLAUDE_HISTORY, valid_lines)
        end
    catch e
        # Silently handle any file reading errors
        @debug "Could not load Claude history: $e"
    end
    CLAUDE_HISTORY_INDEX[] = 0
end

"""
    save_claude_history!()

Save Claude REPL history to persistent file.
"""
function save_claude_history!()
    try
        # Ensure the config directory exists
        config_dir = dirname(CLAUDE_HISTORY_FILE)
        if !isdir(config_dir)
            mkpath(config_dir)
        end
        
        # Write history to file (keep last 100 entries)
        history_to_save = length(CLAUDE_HISTORY) > 100 ? CLAUDE_HISTORY[end-99:end] : CLAUDE_HISTORY
        open(CLAUDE_HISTORY_FILE, "w") do f
            for line in history_to_save
                println(f, line)
            end
        end
    catch e
        # Silently handle any file writing errors
        @debug "Could not save Claude history: $e"
    end
end

"""
    claude_repl_init()

Initializes the Claude REPL mode.
Press 'c' at the beginning of a line to enter Claude mode.
"""
function claude_repl_init()
    # Load persistent history first
    load_claude_history!()
    
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
        
        # Note: We use manual history instead of automatic REPL history
        # The claude_mode.hist property is left as default (not modified)

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

        # Set up backspace to exit claude mode and arrow key history navigation
        claude_mode.keymap_dict = LineEdit.keymap_merge(claude_mode.keymap_dict, Dict{Any,Any}(
            '\b' => function (s, args...)
                if isempty(s) || position(LineEdit.buffer(s)) == 0
                    LineEdit.transition(s, main_mode)
                else
                    LineEdit.edit_backspace(s)
                end
            end,
            # Add history navigation with up/down arrows
            "\e[A" => (s, o...) -> safe_history_prev(s, claude_mode),
            "\e[B" => (s, o...) -> safe_history_next(s, claude_mode),
            # Also bind Ctrl+P and Ctrl+N for history navigation (common alternatives)
            "^P" => (s, o...) -> safe_history_prev(s, claude_mode),
            "^N" => (s, o...) -> safe_history_next(s, claude_mode)
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

    # Add to history before processing
    if !isempty(input) && input != "help" && input != "exit"
        # Avoid duplicates
        if isempty(CLAUDE_HISTORY) || CLAUDE_HISTORY[end] != input
            push!(CLAUDE_HISTORY, input)
            # Keep history size reasonable
            if length(CLAUDE_HISTORY) > 100
                popfirst!(CLAUDE_HISTORY)
            end
            # Save history to file after adding new entry
            save_claude_history!()
        end
        CLAUDE_HISTORY_INDEX[] = 0  # Reset to "current" position
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

"""
Safe history navigation functions that handle edge cases properly
"""
function safe_history_prev(s, claude_mode)
    try
        # First try to move up within multi-line content
        if LineEdit.edit_move_up(s)
            return true
        end
        
        # Manual history navigation
        if !isempty(CLAUDE_HISTORY)
            if CLAUDE_HISTORY_INDEX[] == 0
                CLAUDE_HISTORY_INDEX[] = length(CLAUDE_HISTORY)
            elseif CLAUDE_HISTORY_INDEX[] > 1
                CLAUDE_HISTORY_INDEX[] -= 1
            end
            
            if CLAUDE_HISTORY_INDEX[] > 0 && CLAUDE_HISTORY_INDEX[] <= length(CLAUDE_HISTORY)
                # Replace current buffer with history entry
                LineEdit.edit_clear(s)
                LineEdit.edit_insert(s, CLAUDE_HISTORY[CLAUDE_HISTORY_INDEX[]])
                return true
            end
        end
        return false
    catch e
        return false
    end
end

function safe_history_next(s, claude_mode)
    try
        # First try to move down within multi-line content
        if LineEdit.edit_move_down(s)
            return true
        end
        
        # Manual history navigation
        if !isempty(CLAUDE_HISTORY) && CLAUDE_HISTORY_INDEX[] > 0
            if CLAUDE_HISTORY_INDEX[] < length(CLAUDE_HISTORY)
                CLAUDE_HISTORY_INDEX[] += 1
                LineEdit.edit_clear(s)
                LineEdit.edit_insert(s, CLAUDE_HISTORY[CLAUDE_HISTORY_INDEX[]])
                return true
            elseif CLAUDE_HISTORY_INDEX[] == length(CLAUDE_HISTORY)
                # Move to end (empty line)
                CLAUDE_HISTORY_INDEX[] = 0
                LineEdit.edit_clear(s)
                return true
            end
        end
        return false
    catch e
        return false
    end
end