using Test
using ClaudeREPL

@testset "Simple ClaudeREPL Tests" begin
    @testset "Module Structure" begin
        @test ClaudeREPL isa Module
        @test isdefined(ClaudeREPL, :claude_repl_init)
        @test isdefined(ClaudeREPL, :claude_mode!)
        @test isdefined(ClaudeREPL, :send_to_claude)
    end
    
    @testset "Function Types" begin
        @test claude_repl_init isa Function
        @test claude_mode! isa Function  
        @test send_to_claude isa Function
    end
    
    @testset "Constants Exist" begin
        @test isdefined(ClaudeREPL, :CLAUDE_HISTORY)
        @test isdefined(ClaudeREPL, :CLAUDE_HISTORY_INDEX)
        @test isdefined(ClaudeREPL, :CLAUDE_HISTORY_FILE)
    end
    
    @testset "History File Path" begin
        @test ClaudeREPL.CLAUDE_HISTORY_FILE isa String
        @test !isempty(ClaudeREPL.CLAUDE_HISTORY_FILE)
        @test endswith(ClaudeREPL.CLAUDE_HISTORY_FILE, ".txt")
        @test occursin("config", ClaudeREPL.CLAUDE_HISTORY_FILE)
    end
    
    @testset "Safe Function Calls" begin
        # Test functions that don't require REPL context
        @test_nowarn ClaudeREPL.save_claude_history!()
        @test_nowarn ClaudeREPL.load_claude_history!()
        
        # Test that history navigation functions exist and have correct signatures
        @test hasmethod(ClaudeREPL.safe_history_prev, (Any, Any))
        @test hasmethod(ClaudeREPL.safe_history_next, (Any, Any))
    end
end