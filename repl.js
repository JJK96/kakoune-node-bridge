const kakoune_node_bridge_fs = require('fs');

//From https://stackoverflow.com/questions/67322922/context-preserving-eval
var kakoune_node_bridge__EVAL = s => eval(`void (__EVAL = ${kakoune_node_bridge__EVAL.toString()}); ${s}`);

function kakoune_node_bridge_evaluate(expr) {
    return kakoune_node_bridge__EVAL(expr);
}

while(1){
    const kakoune_node_bridge_input = kakoune_node_bridge_fs.readFileSync(process.argv[2]).toString()
    if (kakoune_node_bridge_input == '.exit\n') {
        break;
    }
    var kakoune_node_bridge_output;
    try {
        kakoune_node_bridge_output = kakoune_node_bridge_evaluate(kakoune_node_bridge_input)
    } catch (kakoune_node_bridge_e) {
        kakoune_node_bridge_output = kakoune_node_bridge_e
    }
    kakoune_node_bridge_fs.writeFileSync(process.argv[3], String(kakoune_node_bridge_output))
}
