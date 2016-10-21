<cfscript>
  component output="false" mixin="controller" {

    public any function init() {
      this.version = "1.4.5";
      return this;
    }

    public any function service(required string name, struct params) {

      local.args = {};
      local.args.name = arguments.name;
      local.rv = $doubleCheckedLock(name="serviceLock#application.applicationName#", condition="$cachedServiceClassExists", execute="$createServiceClass", conditionArgs=local.args, executeArgs=local.args);
      local.rv = local.rv.$createServiceObject(arguments.params);
      return local.rv;
    }

    public any function $cachedServiceClassExists(required string name) {

      local.rv = false;
      if (not structKeyExists(application.wheels, "servicePath"))
        application.wheels.servicePath = "services";
      if (not structKeyExists(application.wheels, "services"))
        application.wheels.services = {};
      if (structKeyExists(application.wheels.services, arguments.name))
        local.rv = application.wheels.services[arguments.name];
      return local.rv;
    }

    public any function $createServiceClass(required string name, string servicePaths="#application.wheels.servicePath#", string type="service") {

      local.iEnd = ListLen(arguments.servicePaths);

      for (local.i=1; local.i <= local.iEnd; local.i++) {
        local.servicePath = listGetAt(arguments.servicePaths, local.i);
        local.fileName = arguments.name;
        if (local.fileName != "Service" || local.i == listLen(arguments.servicePaths)) {
          try {
            application.wheels.services[arguments.name] = $createObjectFromRoot(path=local.servicePath, fileName=local.fileName, method="$initServiceClass", name=arguments.name);
          }
          catch (any e) {

            $throw(type="Wheels.ServiceNotFound", message="The service #capitalize(arguments.name)# does not exist. Please create it in the services folder.");
          }
          loc.rv = application.wheels.services[arguments.name];
          break;
        }
      }
      return loc.rv;
    }
  }
</cfscript>
