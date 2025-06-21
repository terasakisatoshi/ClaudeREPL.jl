using Test
using ClaudeREPL
using REPL
using REPL.LineEdit

@testset "REPL Mode Initialization" begin
    @testset "Constants and Configuration" begin
        @test ClaudeREPL.CLAUDE_HISTORY isa Vector{String}
        @test ClaudeREPL.CLAUDE_HISTORY_INDEX isa Base.RefValue{Int}
        @test ClaudeREPL.CLAUDE_HISTORY_FILE isa String
        @test endswith(ClaudeREPL.CLAUDE_HISTORY_FILE, "claude_repl_history.txt")
        @test occursin("config", ClaudeREPL.CLAUDE_HISTORY_FILE)
    end
    
    @testset "History File Path" begin
        # Test that the history file path uses DEPOT_PATH
        @test startswith(ClaudeREPL.CLAUDE_HISTORY_FILE, DEPOT_PATH[1])
    end
    
    @testset "Function Exports" begin
        # Test that key functions are exported
        @test isdefined(ClaudeREPL, :claude_repl_init)
        @test isdefined(ClaudeREPL, :claude_mode!)
        @test isdefined(ClaudeREPL, :send_to_claude)
        
        # Test internal functions exist
        @test isdefined(ClaudeREPL, :load_claude_history!)
        @test isdefined(ClaudeREPL, :save_claude_history!)
        @test isdefined(ClaudeREPL, :safe_history_prev)
        @test isdefined(ClaudeREPL, :safe_history_next)
    end
end

@testset "REPL Mode Functions" begin
    @testset "claude_mode! function" begin
        # Test that claude_mode! doesn't error when called
        @test_nowarn claude_mode!()
    end
    
    @testset "claude_repl_init function" begin
        # Test initialization doesn't error
        @test_nowarn claude_repl_init()
    end
end

@testset "History Navigation Functions" begin
    # Create a mock state for testing
    struct MockREPLState
        buffer::IOBuffer
        pos::Int
    end
    
    struct MockClaudeMode
        hist::Nothing
    end
    
    @testset "safe_history_prev" begin
        mock_state = MockREPLState(IOBuffer(), 0)
        mock_mode = MockClaudeMode(nothing)
        
        # Test that function doesn't error with empty history
        @test_nowarn ClaudeREPL.safe_history_prev(mock_state, mock_mode)
        
        # The function should return false when there's no history
        result = ClaudeREPL.safe_history_prev(mock_state, mock_mode)
        @test result isa Bool
    end
    
    @testset "safe_history_next" begin
        mock_state = MockREPLState(IOBuffer(), 0)
        mock_mode = MockClaudeMode(nothing)
        
        # Test that function doesn't error with empty history
        @test_nowarn ClaudeREPL.safe_history_next(mock_state, mock_mode)
        
        # The function should return false when there's no history
        result = ClaudeREPL.safe_history_next(mock_state, mock_mode)
        @test result isa Bool
    end
end