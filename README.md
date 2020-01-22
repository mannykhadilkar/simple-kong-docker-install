# Demoing Kong Enterprise & Studio Integration

**Assumptions:**

1. _You have Docker installed_
1. _You have Bintray access_
1. _You have an environment variable KONG_LICENSE_DATA with a valid license.json loaded_
1. _You have Kong Studio <https://github.com/Kong/studio/releases/> 0.0.10 (or better) installed_
1. _You have a Github Person token https://github.com/settings/tokens_
### Running the Demo

* Start Kong Studio

* * Select `From File` to import an OpenAPI spec
  * Import the provided `summit-petstore-demo.yaml`
  * Select the middle icon from the left side (Try API, it looks like a little Erlenmeyer flask)
    * Where you see `No Environment` select the dropdown and
    * Activate the `OpenAPI env`

Get excited...you're now ready to demo a direct call from Kong Studio to `petstore.swagger.io`  so choose `GET /store/inventory` and hit `Send`

You should see output in the `Preview` tab on the right that is a bunch of JSON that looks like store inventory.

**Congratulations! You just called a service using Studio. But wait...there's more!** 

- Start Kong
  `> docker-compose up -d`

- Back in Studio, in the upper lefthand corner, select the dropdown `Swagger Petstore 1.0.0` and choose `Deploy to Kong`
- You'll be dropped into the third tool, (Monitor Instance, looks like a little speedometer) and should see the output of Kong's Admin API /services endpoint

We now we need to create an **Environment** for our Kong Proxy:

* Back in the Try API tool, select the `OpenAPI env` dropdown and choose `Manage Environments`

* To the existing Sub Environment definition for `OpenAPI env` add `"id": 1` and then copy the full JSON

* Now add a new Sub Environment, and title it (double-click the New Environment string to edit) **Kong Proxy**

* Paste in your previously copied JSON, then edit it to look exactly like this:

  ```json
  {
    "base_path": "/v2",
    "host": "localhost:8000",
    "scheme": "http",
    "id":1
  }
  ```

We're now ready to test the Studio's integration with the Kong Proxy.

* Start by making sure you've activated the **Kong Proxy** environment from the dropdown
* Select the `GET /store/inventory` again and while you should see the exact same preview data, note that the `Header` tab (right hand side) has some interesting new entries, namely `X-Kong-Upstream-Latency, X-Kong-Proxy-Latency, and Via` (technically transfer encoding is also there, but it's not pertinent for now)

*NOTE: if you don't see those. headers, you might not have changed petstore.swagger.io -> localhost:8000*



**Congratulations again! You have now successfully proxied a call through Studio's integration with Kong's Proxy...BUT WAIT...there's more!!!**

You're now really ready to show the power of Kong...let's add a couple plugins. We'll be making them Global in scope for simplicity, but in real-world scenarios, you'll usually apply them to specific Services or Routes.

1. In your Kong Manager (http://localhost:8002), open the default workspace and select `Plugins`
2. Add a new Rate Limiting Plugin, setup a limit of 3 per minute and go back to Studio.

Exercise an endpoint again, let's say `GET /pet/{id}` and notice in the headers the presence of `X-RateLimit-Limit-minute` and `X-RateLimit-Remaining-minute` headers. Hit send a few more times and you'll receive a `429` indicating you've reached your limit (_keep this in mind at the bar tonight_).

Let's add one more plugin, an important one for any API...Authentication:

1. Back in the Manager, add an instance of a Key Authentication Plugin
2. From the Consumers menu, add a new one (auth credentials are associated with them)
3. With your new Consumer, select `View` and add a Credential to your new Consumer under its tab, and there you'll see the ability to create a new Key Auth Credential. Do so.
4. In Studio, you can now run a call again, but without a Key, you'll see a `401 Unauthorized`
5. In the `Query` tab in the middle pane, add `name` `apikey` and for it's `value` use the `key` from your consumer's Key Authentication Credential
6. Re-send the same request and you should see a `200 OK` with the expected values

Next we will proxy Graphql queries to Kong from Studio! For this demo, we will use Github's Graphql API as the backend service:

1. In Manager, click `Services` then click `New Service`.  Enter a service name `graphql` and in the `Enter the URL` field enter `https://api.github.com/graphql`
2. Next, select `New Route`.  In the `Enter a Name` field, enter `graphql`, click `+Add Path` and in the field enter `/graphql`.
3. In Studio, click the `+` button next to Filter text box to create a `New Request`.
4. In the request enter name `/graphql`, click the dropdown to select `Post` and click the `No Body` dropdown to select `GraphQL Query`
5. Enter the POST URL as `localhost:8000/graphql`
6. Paste the following query into the Body:
```
query {
  insomnia: organization(login: "getinsomnia") {
    description
    location
    repository(name: "insomnia") {
      description
    }
  }
  
  kong: organization(login: "kong") {
    description
    location
    repository(name: "se-tools") {
        description
    }
  }
 }
 ```
5. Click the `Auth` tab, choose `Bearer Token` and paste your Github personal token in the token field
6. In the `Query` tab in the middle pane, add `name` `apikey` and for it's `value` use the `key` from your consumer's Key Authentication Credential
7. Click `Send` and a `200 OK` with the results of the GraphQL query which in this example returns information about Kong's and Insomnia's Github repos.


## That concludes this brief demo of Kong and Kong Studio

##### To cleanup: `> docker-compose down` and in Studio's _Summit Demo_ menu, `Delete app data`

#### What you've learned/shown:

1. How to load an OpenAPI spec from Studio into Kong
2. How to setup an environment in Studio to proxy through Kong
3. How to augment service behavior by applying different Plugins to the Kong Proxy using the Kong Manager

