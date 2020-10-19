var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
  name:'Version Server',
  description: 'The server with the version and build numbers',
  script: '.\\app.js'
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install',function(){
  svc.start();
});

svc.install();