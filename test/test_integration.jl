using Test
using ClaudeREPL
using REPL

@testset "Integration Tests" begin
    @testset "Package Loading and Initialization" begin
        @testset "Module structure" begin
            @test ClaudeREPL isa Module
            @test parentmodule(ClaudeREPL) == Main
        end
        
        @testset "Exports" begin
            # Test that the package exports the expected functions
            exported_names = names(ClaudeREPL)
            @test :claude_repl_init in exported_names
            @test :claude_mode! in exported_names
            @test :send_to_claude in exported_names
        end
        
        @testset "Dependencies loaded" begin
            # Test that required dependencies are available
            @test isdefined(ClaudeREPL, :REPL)
            @test isdefined(ClaudeREPL, :ClaudeCodeSDK)
            @test isdefined(ClaudeREPL, :Markdown)
        end
    end
    
    @testset "Full Workflow Simulation" begin
        # Backup original state
        original_history = copy(ClaudeREPL.CLAUDE_HISTORY)
        original_index = ClaudeREPL.CLAUDE_HISTORY_INDEX[]
        
        @testset "Initialization workflow" begin
            # Clear history
            empty!(ClaudeREPL.CLAUDE_HISTORY)
            ClaudeREPL.CLAUDE_HISTORY_INDEX[] = 0
            
            # Test initialization
            @test_nowarn claude_repl_init()
            
            # Test mode switching
            @test_nowarn claude_mode!()
        end
        
        @testset "History workflow" begin
            # Test adding commands to history (simulate user interaction)
            test_commands = ["What is Julia?", "How do I define a function?", "Explain macros"]
            
            # Simulate adding commands to history
            for cmd in test_commands
                if isempty(ClaudeREPL.CLAUDE_HISTORY) || ClaudeREPL.CLAUDE_HISTORY[end] != cmd
                    push!(ClaudeREPL.CLAUDE_HISTORY, cmd)
                end
            end
            
            @test length(ClaudeREPL.CLAUDE_HISTORY) == 3
            @test ClaudeREPL.CLAUDE_HISTORY == test_commands
            
            # Test history persistence (save/load cycle)
            temp_file = tempname()
            original_file = ClaudeREPL.CLAUDE_HISTORY_FILE
            ClaudeREPL.CLAUDE_HISTORY_FILE = temp_file
            
            try
                # Save current history
                ClaudeREPL.save_claude_history!()
                @test isfile(temp_file)
                
                # Clear and reload
                empty!(ClaudeREPL.CLAUDE_HISTORY)
                ClaudeREPL.load_claude_history!()
                
                # Verify history was restored
                @test length(ClaudeREPL.CLAUDE_HISTORY) == 3
                @test ClaudeREPL.CLAUDE_HISTORY == test_commands
            finally
                ClaudeREPL.CLAUDE_HISTORY_FILE = original_file
                isfile(temp_file) && rm(temp_file)
            end
        end
        
        # Restore original state
        empty!(ClaudeREPL.CLAUDE_HISTORY)
        append!(ClaudeREPL.CLAUDE_HISTORY, original_history)
        ClaudeREPL.CLAUDE_HISTORY_INDEX[] = original_index
    end
    
    @testset "Error Resilience" begin
        @testset "File system errors" begin
            # Test behavior when history file directory doesn't exist
            non_existent_dir = "/non/existent/directory/history.txt"
            original_file = ClaudeREPL.CLAUDE_HISTORY_FILE
            ClaudeREPL.CLAUDE_HISTORY_FILE = non_existent_dir
            
            try
                # These should not throw errors
                @test_nowarn ClaudeREPL.load_claude_history!()
                @test_nowarn ClaudeREPL.save_claude_history!()
            finally
                ClaudeREPL.CLAUDE_HISTORY_FILE = original_file
            end
        end
        
        @testset "REPL state errors" begin
            # Test that history navigation functions handle errors gracefully
            struct MockErrorState end
            struct MockErrorMode end
            
            @test_nowarn ClaudeREPL.safe_history_prev(MockErrorState(), MockErrorMode())
            @test_nowarn ClaudeREPL.safe_history_next(MockErrorState(), MockErrorMode())
        end
    end
    
    @testset "Configuration Validation" begin
        @testset "History file path" begin
            @test ClaudeREPL.CLAUDE_HISTORY_FILE isa String
            @test !isempty(ClaudeREPL.CLAUDE_HISTORY_FILE)
            @test endswith(ClaudeREPL.CLAUDE_HISTORY_FILE, ".txt")
        end
        
        @testset "History limits" begin
            # Test that history respects size limits
            original_history = copy(ClaudeREPL.CLAUDE_HISTORY)
            
            # Add many entries
            empty!(ClaudeREPL.CLAUDE_HISTORY)
            for i in 1:150
                push!(ClaudeREPL.CLAUDE_HISTORY, "command $i")
            end
            
            # Save should limit to 100
            temp_file = tempname()
            original_file = ClaudeREPL.CLAUDE_HISTORY_FILE
            ClaudeREPL.CLAUDE_HISTORY_FILE = temp_file
            
            try
                ClaudeREPL.save_claude_history!()
                saved_lines = readlines(temp_file)
                @test length(saved_lines) <= 100
            finally
                ClaudeREPL.CLAUDE_HISTORY_FILE = original_file
                isfile(temp_file) && rm(temp_file)
                
                # Restore original history
                empty!(ClaudeREPL.CLAUDE_HISTORY)
                append!(ClaudeREPL.CLAUDE_HISTORY, original_history)
            end
        end
    end
    
    @testset "Thread Safety" begin
        # Basic test that concurrent access doesn't cause issues
        @testset "Concurrent history access" begin
            # This is a basic test - in practice, more sophisticated
            # thread safety testing would be needed
            original_history = copy(ClaudeREPL.CLAUDE_HISTORY)
            
            try
                @test_nowarn begin
                    # Simulate concurrent access
                    for i in 1:10
                        push!(ClaudeREPL.CLAUDE_HISTORY, "concurrent_test_$i")
                        ClaudeREPL.CLAUDE_HISTORY_INDEX[] = i
                    end
                end
            finally
                empty!(ClaudeREPL.CLAUDE_HISTORY)
                append!(ClaudeREPL.CLAUDE_HISTORY, original_history)
            end
        end
    end
end