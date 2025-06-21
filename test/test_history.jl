using Test
using ClaudeREPL

# Create a temporary directory for testing history functionality
const TEST_HISTORY_DIR = mktempdir()
const TEST_HISTORY_FILE = joinpath(TEST_HISTORY_DIR, "test_claude_history.txt")

# Backup original values
const ORIGINAL_HISTORY = copy(ClaudeREPL.CLAUDE_HISTORY)
const ORIGINAL_INDEX = ClaudeREPL.CLAUDE_HISTORY_INDEX[]
const ORIGINAL_FILE = ClaudeREPL.CLAUDE_HISTORY_FILE

@testset "History Management" begin
    # Setup: Temporarily modify the history file path for testing
    ClaudeREPL.CLAUDE_HISTORY_FILE = TEST_HISTORY_FILE
    
    @testset "History Initialization" begin
        # Clear history for clean testing
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        ClaudeREPL.CLAUDE_HISTORY_INDEX[] = 0
        
        @test isempty(ClaudeREPL.CLAUDE_HISTORY)
        @test ClaudeREPL.CLAUDE_HISTORY_INDEX[] == 0
    end
    
    @testset "History File Operations" begin
        @testset "save_claude_history!" begin
            # Add some test history
            push!(ClaudeREPL.CLAUDE_HISTORY, "test command 1")
            push!(ClaudeREPL.CLAUDE_HISTORY, "test command 2")
            push!(ClaudeREPL.CLAUDE_HISTORY, "test command 3")
            
            # Test saving
            @test_nowarn ClaudeREPL.save_claude_history!()
            @test isfile(TEST_HISTORY_FILE)
            
            # Check file contents
            saved_content = readlines(TEST_HISTORY_FILE)
            @test length(saved_content) == 3
            @test saved_content[1] == "test command 1"
            @test saved_content[2] == "test command 2"
            @test saved_content[3] == "test command 3"
        end
        
        @testset "load_claude_history!" begin
            # Clear history first
            empty!(ClaudeREPL.CLAUDE_HISTORY)
            ClaudeREPL.CLAUDE_HISTORY_INDEX[] = 5  # Set to non-zero
            
            # Load from file
            @test_nowarn ClaudeREPL.load_claude_history!()
            
            # Check that history was loaded
            @test length(ClaudeREPL.CLAUDE_HISTORY) == 3
            @test ClaudeREPL.CLAUDE_HISTORY[1] == "test command 1"
            @test ClaudeREPL.CLAUDE_HISTORY[2] == "test command 2"
            @test ClaudeREPL.CLAUDE_HISTORY[3] == "test command 3"
            @test ClaudeREPL.CLAUDE_HISTORY_INDEX[] == 0  # Should reset to 0
        end
        
        @testset "Empty file handling" begin
            # Create empty file
            empty_file = joinpath(TEST_HISTORY_DIR, "empty_history.txt")
            touch(empty_file)
            
            ClaudeREPL.CLAUDE_HISTORY_FILE = empty_file
            empty!(ClaudeREPL.CLAUDE_HISTORY)
            
            @test_nowarn ClaudeREPL.load_claude_history!()
            @test isempty(ClaudeREPL.CLAUDE_HISTORY)
        end
        
        @testset "Non-existent file handling" begin
            # Point to non-existent file
            non_existent_file = joinpath(TEST_HISTORY_DIR, "does_not_exist.txt")
            ClaudeREPL.CLAUDE_HISTORY_FILE = non_existent_file
            
            empty!(ClaudeREPL.CLAUDE_HISTORY)
            @test_nowarn ClaudeREPL.load_claude_history!()
            @test isempty(ClaudeREPL.CLAUDE_HISTORY)
        end
    end
    
    @testset "History Size Limits" begin
        ClaudeREPL.CLAUDE_HISTORY_FILE = TEST_HISTORY_FILE
        
        # Clear and add more than 100 entries
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        for i in 1:150
            push!(ClaudeREPL.CLAUDE_HISTORY, "command $i")
        end
        
        @test length(ClaudeREPL.CLAUDE_HISTORY) == 150
        
        # Save and check that only last 100 are saved
        ClaudeREPL.save_claude_history!()
        saved_content = readlines(TEST_HISTORY_FILE)
        @test length(saved_content) == 100
        @test saved_content[1] == "command 51"  # Should start from 51
        @test saved_content[end] == "command 150"
        
        # Load and check that only 100 are loaded
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        ClaudeREPL.load_claude_history!()
        @test length(ClaudeREPL.CLAUDE_HISTORY) == 100
        @test ClaudeREPL.CLAUDE_HISTORY[1] == "command 51"
        @test ClaudeREPL.CLAUDE_HISTORY[end] == "command 150"
    end
    
    @testset "History Filtering" begin
        ClaudeREPL.CLAUDE_HISTORY_FILE = TEST_HISTORY_FILE
        
        # Create a file with empty lines and whitespace
        test_content = [
            "good command 1",
            "",
            "  ",
            "good command 2",
            "\t",
            "good command 3"
        ]
        
        open(TEST_HISTORY_FILE, "w") do f
            for line in test_content
                println(f, line)
            end
        end
        
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        ClaudeREPL.load_claude_history!()
        
        # Should only load non-empty lines
        @test length(ClaudeREPL.CLAUDE_HISTORY) == 3
        @test ClaudeREPL.CLAUDE_HISTORY[1] == "good command 1"
        @test ClaudeREPL.CLAUDE_HISTORY[2] == "good command 2"
        @test ClaudeREPL.CLAUDE_HISTORY[3] == "good command 3"
    end
    
    # Cleanup: Restore original values
    ClaudeREPL.CLAUDE_HISTORY_FILE = ORIGINAL_FILE
    empty!(ClaudeREPL.CLAUDE_HISTORY)
    append!(ClaudeREPL.CLAUDE_HISTORY, ORIGINAL_HISTORY)
    ClaudeREPL.CLAUDE_HISTORY_INDEX[] = ORIGINAL_INDEX
    
    # Clean up test directory
    rm(TEST_HISTORY_DIR, recursive=true)
end

@testset "History Navigation Logic" begin
    # Test history navigation with mock data
    @testset "Navigation with populated history" begin
        # Setup test history
        test_history = ["cmd1", "cmd2", "cmd3", "cmd4"]
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        append!(ClaudeREPL.CLAUDE_HISTORY, test_history)
        ClaudeREPL.CLAUDE_HISTORY_INDEX[] = 0
        
        @test length(ClaudeREPL.CLAUDE_HISTORY) == 4
        @test ClaudeREPL.CLAUDE_HISTORY_INDEX[] == 0
        
        # Reset history for next test
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        append!(ClaudeREPL.CLAUDE_HISTORY, ORIGINAL_HISTORY)
        ClaudeREPL.CLAUDE_HISTORY_INDEX[] = ORIGINAL_INDEX
    end
end