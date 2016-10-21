<cfcomponent output="false">
  <cfinclude template="../../wheels/global/functions.cfm">
  <cfinclude template="../../wheels/plugins/injection.cfm">

  <!--- PRIVATE FUNCTIONS --->

  <cffunction name="$initServiceClass" returntype="any" access="public" output="false">
    <cfargument name="name" type="string" required="false" default="">
    <cfscript>
      var loc = {};
      variables.$class.name = arguments.name;
      variables.$class.path = arguments.path;

      // if our name has pathing in it, remove it and add it to the end of of the $class.path variable
      if (Find("/", arguments.name))
      {
        variables.$class.name = ListLast(arguments.name, "/");
        variables.$class.path = ListAppend(arguments.path, ListDeleteAt(arguments.name, ListLen(arguments.name, "/"), "/"), "/");
      }

      loc.rv = this;
    </cfscript>
    <cfreturn loc.rv>
  </cffunction>

  <cffunction name="$createServiceObject" returntype="any" access="public" output="false">
    <cfscript>
      var loc = {};

      // if the controller file exists we instantiate it, otherwise we instantiate the parent controller
      // this is done so that an action's view page can be rendered without having an actual controller file for it
      loc.controllerName = $objectFileName(name=variables.$class.name, objectPath=variables.$class.path, type="service");
      loc.rv = $createObjectFromRoot(path=variables.$class.path, fileName=loc.controllerName, method="$initServiceObject", name=variables.$class.name);
    </cfscript>
    <cfreturn loc.rv>
  </cffunction>

  <cffunction name="$initServiceObject" returntype="any" access="public" output="false">
    <cfargument name="name" type="string" required="true">
    <cfscript>
      var loc = {};

      // create a struct for storing request specific data
      variables.$instance = {};

      loc.executeArgs = {};
      loc.executeArgs.name = arguments.name;
      loc.lockName = "serviceLock" & application.applicationName;
      $simpleLock(name=loc.lockName, type="readonly", execute="$setServiceClassData", executeArgs=loc.executeArgs);
      loc.rv = this;
    </cfscript>
    <cfreturn loc.rv>
  </cffunction>

  <cffunction name="$setServiceClassData" returntype="void" access="public" output="false">
    <cfscript>
      variables.$class = application.wheels.services[arguments.name].$getServiceClassData();
    </cfscript>
  </cffunction>

  <cffunction name="$getServiceClassData" returntype="struct" access="public" output="false">
    <cfscript>
      var loc = {};
      loc.rv = variables.$class;
    </cfscript>
    <cfreturn loc.rv>
  </cffunction>
</cfcomponent>
