# node bridge for executing things interactively

declare-option -hidden str node_bridge_folder "/tmp/kakoune_node_bridge/%val{session}"
declare-option -hidden str node_bridge_in "%opt{node_bridge_folder}/in"
declare-option -hidden str node_bridge_out "%opt{node_bridge_folder}/out"
declare-option -hidden str node_bridge_fifo "%opt{node_bridge_folder}/fifo"
declare-option -hidden str node_bridge_source %sh{echo "${kak_source%/*}"}
declare-option bool node_bridge_fifo_enabled false
declare-option -hidden bool node_bridge_running false
declare-option -hidden str-list node_bridge_output

hook global GlobalSetOption node_bridge_fifo_enabled=true %{
    nop %sh{
        mkfifo $kak_opt_node_bridge_fifo
    }
    terminal tail -f %opt{node_bridge_fifo}
}

hook global GlobalSetOption node_bridge_fifo_enabled=false %{
    nop %sh{
        rm $kak_opt_node_bridge_fifo
    }
}

define-command -docstring 'Create FIFOs and start node' \
node-bridge-start %{
    nop %sh{
        if ! $kak_opt_node_bridge_running; then
            mkdir -p $kak_opt_node_bridge_folder
            mkfifo $kak_opt_node_bridge_in
            mkfifo $kak_opt_node_bridge_out
            ( node $kak_opt_node_bridge_source/repl.js $kak_opt_node_bridge_in $kak_opt_node_bridge_out) >/dev/null 2>&1 </dev/null &
        fi
    }
    set-option global node_bridge_running true
}

define-command -docstring 'Stop node and remove FIFOs' \
node-bridge-stop %{
    nop %sh{
        if $kak_opt_node_bridge_running; then
            echo ".exit" > $kak_opt_node_bridge_in
            rm $kak_opt_node_bridge_in
            rm $kak_opt_node_bridge_out
            rmdir -p $kak_opt_node_bridge_folder
        fi
    }
    set-option global node_bridge_fifo_enabled false
    set-option global node_bridge_running false
}

define-command -docstring 'Evaluate selections or argument using node-bridge return result in " register' \
node-bridge-send -params 0..1 %{
    node-bridge-start
    set-option global node_bridge_output
    evaluate-commands %sh{
        cat_command="cat $kak_opt_node_bridge_out"
        if $kak_opt_node_bridge_fifo_enabled; then
            cat_command="$cat_command | tee -a $kak_opt_node_bridge_fifo"
        fi

        if [ $# -eq 0 ]; then
            eval set -- "$kak_quoted_selections"
        fi
        out=""
        while [ $# -gt 0 ]; do
            output="$(eval $cat_command)" && echo "set-option -add global node_bridge_output %{$output}" &
            echo "$1" > $kak_opt_node_bridge_in &
            wait
            shift
        done
    }
    set-register dquote %opt{node_bridge_output}
}

define-command node-bridge -params 1.. -shell-script-candidates %{
    for cmd in start stop send;
        do echo $cmd;
    done
} %{ evaluate-commands "node-bridge-%arg{1}" }

hook global KakEnd .* %{
    node-bridge-stop
}
