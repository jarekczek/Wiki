/*
dependencies {
  compile 'org.glassfish.jersey.core:jersey-client:2.0.1'
  compile 'org.glassfish:javax.json:1.0.3'
}
*/

import javax.json.*
import javax.ws.rs.client.Entity
import javax.ws.rs.core.Response

class AzureClient
{
  String _token = null
  JsonObject[] _vms = null
  Properties _props

  AzureClient()
  {
    def inp = new java.io.FileInputStream("azure.properties")
    /*
    // azure.properties sample
    // App registrations, Application ID
    applicationId = 4492c681-...
    // Azure Active Directory, Properties, Directory ID
    tenantId = 5d6764d2-...
    // Subscriptions, Subscription ID
    subscriptionId = a3378580-...
    // App registrations, keys
    clientSecret = hKvN...
    */

    _props = new Properties()
    _props.load(inp)
    inp.close()
  }

  String getToken() {
    if (_token == null)
      _token = obtainToken()
    return _token
  }

  void setToken(token) {
    _token = token;
  }

  JsonObject[] getVms() {
    if (_vms == null)
      _vms = obtainVms()
    return _vms
  }
  
  void setVms(vms) {
    _vms = vms
  }

  String obtainToken() {
    println "Obtaining token..."
    def cli = javax.ws.rs.client.ClientBuilder.newClient()
    def postMap = new javax.ws.rs.core.MultivaluedHashMap([
      grant_type: 'client_credentials',
      client_secret: _props.getProperty("clientSecret"),
      client_id: _props.getProperty("applicationId"),
      resource: 'https://management.azure.com/'
    ])
    String link = "https://login.microsoftonline.com/"
    link += _props.getProperty("tenantId") + "/oauth2/token"
    def resp = cli.target(link)
      .request()
      .post(javax.ws.rs.client.Entity.form(postMap));
    def json = javax.json.Json.createReader(
      resp.readEntity(java.io.Reader.class))
      .readObject()
    if (resp.status == 200) {
      String token = json.getString("access_token")
      //println json
      //println "mamy token: $token"
      return token
    } else {
      throw new RuntimeException("Blad azure rest, status $resp.status, $json")
    }
  }

  JsonObject[] obtainVms() {
    println "Obtaining virtual machines..."
    def cli = javax.ws.rs.client.ClientBuilder.newClient()
    String link = "https://management.azure.com"
    link += "/subscriptions/" + _props.getProperty("subscriptionId")
    link += "/providers/Microsoft.Compute/virtualmachines"
    def resp = cli.target(link)
      .queryParam("api-version", "2016-04-30-preview")
      .request()
      .header("Authorization", "Bearer " + token)
      .get()
    def jsonResp = javax.json.Json.createReader(
      resp.readEntity(java.io.Reader.class))
      .readObject()
    if (resp.status == 200) {
      println "ok"
      //println jsonResp
      def jsona = jsonResp.getJsonArray("value");
      jsona.each {
        println it.getString("name")
      }
    } else {
      throw new RuntimeException("Blad azure rest, status $resp.status, $jsonResp")
    }
  }

  private JsonObject verbVm(String vmName, String method, String verb)
  {
    JsonObject vm = vms
      .grep { it -> vmName.equals(it.getString("name")) }
      .find()
    if (vm == null)
      throw new RuntimeException("Brak maszyny o nazwie $vmName")
    println verb + "ing vm $vmName"
    def cli = javax.ws.rs.client.ClientBuilder.newClient()
    String link = "https://management.azure.com"
    link += vm.getString("id") + "/$verb"
    def invoker = cli.target(link)
      .queryParam("api-version", "2016-04-30-preview")
      .request()
      .header("Authorization", "Bearer " + token)
    Response resp
    if (method == "POST")
      resp = invoker.post(Entity.text(""))
    else
      resp = invoker.method(method)
    String textResp = resp.readEntity(String.class)
    if (resp.status.intdiv(100) == 2) {
      println "ok ($resp.status)"
      //println textResp
      JsonObject jsonResp = null
      if (textResp.length() > 0) {
        jsonResp = javax.json.Json.createReader(
          new java.io.StringReader(textResp))
          .readObject()
      }
      return jsonResp
    } else {
      throw new RuntimeException(
        "Blad azure rest, status $resp.status, $textResp")
    }
  }

  void startVm(String vmName)
  {
    verbVm(vmName, "POST", "start")
    println "$vmName status: " + getVmDisplayStatus(vmName)
  }

  void stopVm(String vmName)
  {
    verbVm(vmName, "POST", "powerOff")
    println "$vmName status: " + getVmDisplayStatus(vmName)
  }

  JsonObject getVm(String vmName)
  {
    return verbVm(vmName, "GET", "InstanceView")
  }

  String getVmDisplayStatus(String vmName)
  {
    def vm = getVm(vmName)
    def status = vm.getJsonArray("statuses").getJsonObject(1)
    return status.getString("displayStatus")
  }
}

def ac = new AzureClient()
//ac.startVm("weblogic")
//ac.stopVm("weblogic")
println ac.getVmDisplayStatus("weblogic")
