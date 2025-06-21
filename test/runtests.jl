using Test
using ClaudeREPL

# Include test modules
include("test_repl.jl")
include("test_history.jl")
include("test_claude.jl")
include("test_integration.jl")

@testset "ClaudeREPL.jl" begin
    @testset "REPL Mode Tests" begin
        include("test_repl.jl")
    end
    
    @testset "History Tests" begin
        include("test_history.jl")
    end
    
    @testset "Claude Communication Tests" begin
        include("test_claude.jl")
    end
    
    @testset "Integration Tests" begin
        include("test_integration.jl")
    end
end