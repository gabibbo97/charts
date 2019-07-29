load('/opt/mongo-scripts/helm-values.js')

// Functions
function getArbiters() {
  let arbiters = [];
  for (let i = 0; i < helmData['values']['replicaSetTopology']['arbiters']; i++) {
    arbiters.push(`${helmData['fullname']}-arbiter-${i}.${helmData['fullname']}-arbiter.${helmData['release']['Namespace']}.svc.cluster.local:${helmData['port']}`)
  }
  return arbiters
}
function getDatanodes() {
  let datanodes = [];
  for (let i = 0; i < helmData['values']['replicaSetTopology']['data']; i++) {
    datanodes.push(`${helmData['fullname']}-data-${i}.${helmData['fullname']}-data.${helmData['release']['Namespace']}.svc.cluster.local:${helmData['port']}`)
  }
  return datanodes
}

function getRequiredMemberNames() {
  return getArbiters().concat(getDatanodes())
}

function getCurrentMemberNames() {
  return rs.status()['members'].map(member => member['name'])
}

function getInitialRSDoc() {
  return {
    _id: helmData['values']['replicaSetName'],
    configsvr: helmData['values']['mode'] === 'config',
    members: getArbiters().map(arbiter => {
      return { host: arbiter, arbiterOnly: true };
    }).concat(getDatanodes().map(datanode => {
      return { host: datanode };
    })).map((member, id) => {
      const oldMember = member;
      oldMember['_id'] = id;
      return oldMember;
    })
  };
}

// Health checks

function primaryPresent() {
  print('Waiting for a primary to be elected')
  while (!rs.status()['members'].map(member => member['stateStr']).some(state => { return state === 'PRIMARY'; })) {
    sleep(1000)
  }
  print('Consensus reached')
}

function statusesOK() {
  print('Waiting for all members to be on a regular status')
  while (!rs.status()['members'].map(member => member['stateStr']).every(state => ['PRIMARY', 'SECONDARY', 'ARBITER'].includes(state))) {
    sleep(1000)
  }
  print('All members ok')
}

function checkRSHealth() {
  primaryPresent()
  statusesOK()
}


// RS Reconfiguration
if (rs.status().ok == 0) {
  print('Initializing replica set')

  printjson(getInitialRSDoc())
  const rsInitResult = rs.initiate(getInitialRSDoc())

  if (rsInitResult.ok == 0) {
    print('Initialization failed!')
    printjson(rsInitResult)
    quit(1)
  }

  checkRSHealth()

  print('Initialization complete')
} else {
  print('Reconfiguring replica set')

  // Remove extraneous members
  getCurrentMemberNames().filter(member => !getRequiredMemberNames().includes(member)).forEach(extraneous => {
    print(`Removing extraneous member ${extraneous}`)
    rs.remove(extraneous)
  })
  checkRSHealth()

  // Add missing arbiters
  // Add missing members
  getRequiredMemberNames().filter(member => !getCurrentMemberNames().includes(member)).forEach(required => {
    if (required.match('arbiter')) {
      print(`Adding missing arbiter ${required}`)
      rs.addArb(required)
    } else {
      print(`Adding missing server ${required}`)
      rs.add(required)
    }
    checkRSHealth()
  })

  print('Reconfiguration complete')
}