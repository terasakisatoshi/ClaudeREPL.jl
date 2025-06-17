using ClaudeCodeSDK
using JSON3

# Global conversation history - now simpler since SDK handles most of the complexity
const CONVERSATION_HISTORY = Vector{Dict{String,Any}}()

# Configuration constants
const MAX_HISTORY_SIZE = 100
const MAX_INPUT_LENGTH = 10000  # characters

"""
    send_to_claude(user_input::AbstractString) -> String

Sends user input to Claude using ClaudeCodeSDK with proper validation, rate limiting, and error handling.
"""
function send_to_claude(user_input::AbstractString)
    try
        # Use ClaudeCodeSDK to send the query
        result = ClaudeCodeSDK.query(prompt=string(user_input))

        # Extract response text from SDK result (which is a Vector{Message})
        response_text = if isa(result, Vector) && !isempty(result)
            # Get the last ResultMessage which contains the final response
            last_message = result[end]
            if isa(last_message, ClaudeCodeSDK.ResultMessage)
                last_message.result
            else
                # Fallback to string representation
                string(last_message)
            end
        elseif isa(result, String)
            result
        else
            # Fallback - convert to string
            string(result)
        end

        # Add assistant response to conversation history
        push!(CONVERSATION_HISTORY, Dict("role" => "assistant", "content" => response_text))

        # Trim conversation history to prevent memory leaks
        trim_conversation_history!()

        return response_text

    catch e
        # Enhanced error handling for ClaudeCodeSDK specific errors
        if isa(e, ClaudeCodeSDK.ClaudeSDKError)
            error("Claude Code SDK error: $(e)")
        elseif isa(e, ClaudeCodeSDK.CLIConnectionError)
            error("Claude CLI connection error: $(e)")
        elseif isa(e, ClaudeCodeSDK.CLINotFoundError)
            error("Claude CLI not found: $(e)")
        else
            rethrow(e)
        end
    end
end

"""
    trim_conversation_history!()

Trims the global `CONVERSATION_HISTORY` vector so that its length does not exceed
`MAX_HISTORY_SIZE`. Older messages are removed from the front of the vector to
retain the most recent context while preventing unbounded memory growth.
"""
function trim_conversation_history!()
    while length(CONVERSATION_HISTORY) > MAX_HISTORY_SIZE
        popfirst!(CONVERSATION_HISTORY)
    end
end
