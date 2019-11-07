const kakoune_node_bridge_fs = require('fs');

while(1){
    const kakoune_node_bridge_input = kakoune_node_bridge_fs.readFileSync(process.argv[2]).toString()
    if (kakoune_node_bridge_input == '.exit\n') {
        break;
    }
    var kakoune_node_bridge_output;
    try {
        kakoune_node_bridge_output = eval(kakoune_node_bridge_input)
    } catch (kakoune_node_bridge_e) {
        kakoune_node_bridge_output = kakoune_node_bridge_e
    }
    kakoune_node_bridge_fs.writeFileSync(process.argv[3], kakoune_node_bridge_output.toString())
}
