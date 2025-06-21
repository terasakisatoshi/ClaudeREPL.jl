using Test
using ClaudeREPL

@testset "Basic Functionality Tests" begin
    @testset "Module and Exports" begin
        @test ClaudeREPL isa Module
        @test isdefined(ClaudeREPL, :claude_repl_init)
        @test isdefined(ClaudeREPL, :claude_mode!)
        @test isdefined(ClaudeREPL, :send_to_claude)
    end
    
    @testset "Constants and Configuration" begin
        @test ClaudeREPL.CLAUDE_HISTORY isa Vector{String}
        @test ClaudeREPL.CLAUDE_HISTORY_INDEX isa Base.RefValue{Int}
        @test ClaudeREPL.CLAUDE_HISTORY_FILE isa String
        @test endswith(ClaudeREPL.CLAUDE_HISTORY_FILE, "claude_repl_history.txt")
    end
    
    @testset "Function Types" begin
        @test claude_repl_init isa Function
        @test claude_mode! isa Function
        @test send_to_claude isa Function
    end
    
    @testset "History Functions" begin
        @test isdefined(ClaudeREPL, :load_claude_history!)
        @test isdefined(ClaudeREPL, :save_claude_history!)
        @test ClaudeREPL.load_claude_history! isa Function
        @test ClaudeREPL.save_claude_history! isa Function
    end
end