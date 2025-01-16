# WANTS AND NEEDS

## WANTS
1. Refactor and adding some QOL to autotestrunner
    - it isn't automatic
    - it requires specific file name template; which we can remove
2. Keymap for testing:
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
