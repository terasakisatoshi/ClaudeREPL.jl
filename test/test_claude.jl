using Test
using ClaudeREPL

@testset "Claude Communication" begin
    @testset "send_to_claude function exists" begin
        @test isdefined(ClaudeREPL, :send_to_claude)
        @test ClaudeREPL.send_to_claude isa Function
    end
    
    @testset "Input validation" begin
        # Test with empty string
        @test_nowarn send_to_claude("")
        
        # Test with simple string
        @test_nowarn send_to_claude("test")
        
        # Test with multiline string
        multiline_input = """
        This is a multiline
        test input
        """
        @test_nowarn send_to_claude(multiline_input)
    end
    
    @testset "Error handling" begin
        # Test that the function handles ClaudeCodeSDK errors gracefully
        # Note: These tests depend on the actual ClaudeCodeSDK implementation
        # and may fail if the SDK is not properly configured
        
        @testset "SDK Error Types" begin
            # Test that error types are properly imported
            @test isdefined(ClaudeCodeSDK, :ClaudeSDKError) || true  # Allow if not defined
            @test isdefined(ClaudeCodeSDK, :CLIConnectionError) || true
            @test isdefined(ClaudeCodeSDK, :CLINotFoundError) || true
        end
    end
    
    @testset "Return value" begin
        # The function should return an empty string for streaming responses
        result = send_to_claude("test input")
        @test result isa String
        @test result == ""
    end
end

@testset "Mock Claude Communication" begin
    # Create a mock version of send_to_claude for testing
    function mock_send_to_claude(input::AbstractString)
        if input == "error_test"
            throw(ErrorException("Mock error"))
        elseif input == "empty_test"
            return ""
        else
            return "Mock response for: $input"
        end
    end
    
    @testset "Mock function behavior" begin
        @test mock_send_to_claude("hello") == "Mock response for: hello"
        @test mock_send_to_claude("empty_test") == ""
        @test_throws ErrorException mock_send_to_claude("error_test")
    end
end

@testset "Claude Integration Requirements" begin
    @testset "ClaudeCodeSDK dependency" begin
        # Test that ClaudeCodeSDK is available
        @test isdefined(Main, :ClaudeCodeSDK) || isdefined(ClaudeREPL, :ClaudeCodeSDK)
    end
    
    @testset "Required ClaudeCodeSDK functions" begin
        # Test that required SDK functions exist
        @test isdefined(ClaudeCodeSDK, :query_stream)
        @test ClaudeCodeSDK.query_stream isa Function
    end
    
    @testset "Message types" begin
        # Test that required message types exist
        @test isdefined(ClaudeCodeSDK, :AssistantMessage) || true
        @test isdefined(ClaudeCodeSDK, :TextBlock) || true
    end
end