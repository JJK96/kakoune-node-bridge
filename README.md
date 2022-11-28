This bridge runs a node shell in the background and can send selections through the shell.
This way you can do calculations while keeping memory of previous variables, so this enables you to use variables in later calculations.

# Install

Add this repository to your autoload dir: `~/.config/kak/autoload/`.

Or via [plug.kak](https://github.com/andreyorst/plug.kak):

```
plug 'JJK96/kakoune-node-bridge' %{
  # Suggested mapping
  map global normal = ': node-bridge-send<ret>R'
  # run some node code initially
  node-bridge-send %{
    fs = require('fs')
  }
  
}
```

# usage

1. Select a piece of text that can be interpreted by node, then run `node-bridge-send`.

or

2. run `:node-bridge-send expr` where `expr` can be any node code.

This will automatically start the interpreter if it is not running.
Then it will execute the code using node and return the output in the `"` register.
This can then be used with <kbd>R</kbd> or <kbd>p</kbd> or some other command that uses the register.

The interpreter will first try to run the code interactively line by line, if that fails, the whole code will be executed at once.

If `node_bridge_fifo_enabled` is set to true the output will also be written to a second fifo, for example to keep track of previous outputs. 

```
set global option node_bridge_fifo_enabled true
```

The node interpreter will be shut down when the kakoune server is closed.

# commands

`node-bridge-start` Start the node bridge  
`node-bridge-stop` Stop the node bridge  
`node-bridge-send` Send the current selections through the node bridge  

# options

`node_bridge_fifo_enabled` Whether the output should be written to a second fifo (for keeping track of previous outputs)  
