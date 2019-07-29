load('/opt/mongo-scripts/helm-values.js')
const timeout = 60;

// Functions
function waitConnection(host) {
  let retriesLeft = 60;
  print(`Trying connection to ${host}`)
  while (true) {
    try {
      new Mongo(host);
      print(`Connected to ${host}`)
      break;
    } catch (e) {
      retriesLeft--
      sleep(1000)
    }
    // Fail with error
    if (retriesLeft <= 0) {
      print(`Could not connect to ${host} after ${timeout} retries`)
      quit(1)
    }
  }
}

// Wait arbiters
for (let i = 0; i < helmData['values']['replicaSetTopology']['arbiters']; i++) {
  waitConnection(`${helmData['fullname']}-arbiter-${i}.${helmData['fullname']}-arbiter.${helmData['release']['Namespace']}.svc.cluster.local:${helmData['port']}`)
}
// Wait data nodes
for (let i = 0; i < helmData['values']['replicaSetTopology']['data']; i++) {
  waitConnection(`${helmData['fullname']}-data-${i}.${helmData['fullname']}-data.${helmData['release']['Namespace']}.svc.cluster.local:${helmData['port']}`)
}
// Notify success
print('All servers are alive')