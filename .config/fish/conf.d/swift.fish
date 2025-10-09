# Added by swiftly
switch (uname)
    case Darwin
        source $HOME/.swiftly/env.fish
    case '*'
        source $HOME/.local/share/swiftly/env.fish
end
