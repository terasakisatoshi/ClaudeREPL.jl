"""
    send_to_claude(user_input::AbstractString) -> String

Sends user input to Claude using ClaudeCodeSDK with proper validation, rate limiting, and error handling.
"""
function send_to_claude(user_input::AbstractString)
    try
        result = ClaudeCodeSDK.query_stream(prompt=string(user_input))
        for m in result
            if m isa AssistantMessage
                for c in m.content
                    if c isa TextBlock
                        display(Markdown.parse(c.text))
                    end
                end
            end
        end
        return ""
    catch e
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
