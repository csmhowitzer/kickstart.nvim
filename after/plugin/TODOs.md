# WANTS AND NEEDS

## WANTS
- [ ] Refactor and adding some QOL to autotestrunner
    - it isn't automatic
    - it requires specific file name template; which we can remove
        - will need to recognize a file with no tests vs. one with tests
- [ ] Keymap for testing:
    a. All langs will 
        - open terminal/buffer and run that lang's test
        i. CS
            - open term
            - run `dotnet run` for xunit runner
        ii. Go
            - open term
            - run `go test ./<filepath>`
        iii. Lua
            - most likely used for just plugins
            - if so, used *Busted* via *plenary.nvim*
            - open buffer
            - run `:PlenaryBustedFile %`
                - "%" refers to current file
    - the idea here is to see the test output from stdout in a term window
- [ ] Auto add **usings** to csharp files
    - a very nice feature in VS and VSCode
    - On Buffer Save or as we're typing
        - may want to look at the blink.nvim for better autocomplete
            - if it can tie into when to add the using...
        - Otherwise, would probably be a great autocommand
