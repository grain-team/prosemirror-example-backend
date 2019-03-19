const {schema} = require("prosemirror-schema-basic");
const {Step} = require("prosemirror-transform")

process.stdin.setEncoding('utf-8');

const instances = {}

function newInstance(hash) {
    const doc = schema.node("doc", null, [schema.node("paragraph", null, [schema.text("Welcome!")])]);
    return instances[hash] = doc;
}

function handle(cmd, hash, args) {
    let instance;
    switch (cmd) {
        case "fetch":
            instance = instances[hash] || newInstance(hash);
            return ['OK', instance];
        case "snapshot":
            instance = instances[hash];
            for (let i = 0; i < args.steps.length; i++) {
                let step = Step.fromJSON(schema, args.steps[i]);
                step.clientID = args.clientIds[i];
                let result = step.apply(instance);
                instance = result.doc;
            }
            instances[hash] = instance;
            return ['OK'];

        default:
            return ['ERROR', 'unknown_command'];
    }
}

process.stdin.on('data', (chunk) => {
    const cmd = JSON.parse(chunk);
    const resp = handle(cmd[0], cmd[1], cmd[2]);
    process.stdout.write(JSON.stringify(resp) + '\n');
});

