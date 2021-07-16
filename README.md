

# Atlas Billing & MongoDB Charts

<img width="2277" alt="Screenshot 2021-07-16 at 09 14 05" src="https://user-images.githubusercontent.com/77750987/125917217-cae7b4ce-d5ac-40d5-973f-92ac24db8051.png">

This repository is pretty much the exact replica of [MDB-live-2020](https://github.com/rbohan/MDB-live-2020). The main difference is that we will be using the Realm CLI Version 2 and only focus on how to deploy our charts.
If you want more context around this rep, I encourage you to have a lookg at [Tracking and Managing Your Spend on MongoDB Atlas](https://www.youtube.com/watch?v=qP-n8wnwZzI).
 

# Overview
The code in this repo contains one function, one trigger and some values & secrets as follows:

### Function:
`getData`: this function retrieves all invoice data, update data and has additional categorization of the data to enhance the output in MongoDB Charts.

### Values & Secrets
`billing-org`: maps to the Org Id we want to gather Billing data from. `Maps to billing-orgSecret`.

`billing-username`: maps to the Public API key for the Org we want to gather Billing data from. Maps to `billing-usernameSecret`.

`billing-password`: maps to the Private API key for the Org we want to gather Billing data from. Maps to `billing-passwordSecret`.

### Triggers
`getdataTrigger`: runs at 4am GMT each morning to retrieve the billing data using the `getData` function above.

# Pre-requisites
* You will need the following before you can use this code:
  * A [MongoDB Atlas cluster](https://www.mongodb.com/cloud/atlas) to gather the billing data we collect (a M0 will do). (To minimize network data transfer, select AWS, in the 'us-east-1', 'us-west-2', 'eu-east-1' or 'ap-southeast-2' regions).
  * A local clone of this repo which you will import into your MongoDB Realm application.

# Setup
* To deploy the code in this repo you'll need several API Keys.
  * The main API key will be used to retrieve the Billing data from the target Organization.
  * An additional API key will be required to import the code in this repo into your own Realm application.

# Create an API key for the Billing function
You will need to create an API key in the target organization (the one you want to gather Billing data from).

* ### Navigate to the target org.
* ### Click on the 'Access Manager' on the left navigation bar:
   * Create an API key by clicking the 'Create API Key' button on the top right of the page.
   * Give the API key a suitable description.
   * Add the following permissions to your key: Organization Billing Admin and Organization Read Only.
   * Click 'Next'.
   * Record the Public and Private Key details and store them securely.
   * Add a Whitelist Entry for the API key if required.
   * Click 'Done' when you're ready to save the new key to your Organization.
* ### Before moving on we will record the Organization ID:
   * Navigate to the 'Organzation Settings' by clicking the cog to the right of the organization name (on the top left of the window).
   * Select 'General Settings' and record the 'Organization ID'.

# Create an API key for the Realm CLI
To import the code in this repo into your own Realm app you will need an additional Project-level API key associated with the Project where your Billing cluster resides.
* ### Navigate to the Project where you created the MongoDB cluster to store the Billing data and create your API key.
  * Click the 3 vertical dots to the right of the project name (on the top left of the window).
  * Select 'Project Settings'.
  * Select 'Access Manager' on the left navigation bar.
  * Select the 'Create API Key' tab.
  * Create a new API Key with the Project Owner role.
  * Record the Public and Private Key details and store them securely.
* ### [Download the Realm CLI Client](https://docs.mongodb.com/realm/deploy/realm-cli-reference/#installation)
  * Follow the instructions on this page to download the Realm CLI for your platform.
* ### [Import the code into your Realm App](https://docs.mongodb.com/realm/deploy/realm-cli-reference/#import-an-application)
  * Log in via the Realm CLI using the details of the key you just created above (Project level): 
     `realm-cli login --api-key="<my api key>" --private-api-key="<my private api key>"`
  * From the root of the local github clone run the following to create a new Stitch App:
     `realm-cli import`
  
* ### Answer the questions e.g.:

  * *? Do you want to create a new app?:* **Yes**
  * *? App name:* **billing**
  * *? App Location:* **[US-VA]**
  * *? App Deployment Model:* **LOCAL**
   * *Note: this is expected to fail with an error message similar to the follow, as some Secrets have not yet been created:*
     **"failed to import app: error: error validating Value: auto-password: could not find secret "auto-passwordSecret"**

# Create Secrets
While the previous command failed, it did create a new Realm App. Navigate back to the Realm App page (refresh if required) and select the new billing App.

With the Realm App selected we can create the missing Secrets:

* ### Switch to 'Values' on the left navigation bar
  * Create a new value.
  * Choose a Secret type.
  
* ### Create the following Secrets mapped to the values from above:
  * `billing-orgSecret`: the ID of the Org we want to retrieve the Billing data for.
  * `billing-usernameSecret`: the Public API key details for that Org.
  * `billing-passwordSecret`: the Private API key details for that Org.

# Redeploy your app
### Now that we have our Secrets in place we can redeploy our App:
`realm-cli import --remote "<AppID>"`

Select 'y' to confirm you want to repace the existing application.

# Connect to your Atlas cluster:

* ### Now that the App has been redeployed, verify that the App is linked to your Atlas cluster:
  * Switch to 'Linked Data Sources' on the left navigation bar.
  * Ensure the 'Atlas Clusters' entry maps to your Atlas cluster from above.
  * Your Realm Service name is `mongodb-atlas`.
  * All other entries can be left as is.
  * Click 'Save' to save your choice.
  * Click the 'Review & Deploy Changes' option from the new blue bar at the top of the screen.
  * Verify the changes in the resulting dialog and click 'Deploy' to deploy and make live your changes.
  * Now that we've deployed our code you can test it interactively.  

* ### Navigate to 'Functions' from the left navigation bar.
  * Select the `getData` function.
  * Click the 'Run' button at the bottom of the screen.
  * All going well, the function should complete successfully and populate the billingdata collection in the billing database of your Atlas cluster.

# Double Check
  * If anthing goes wrong, check the error message and make sure you have entered the values of the Secrets correctly (you can update them at any stage by navigating to Values & Secrets on the left navigation bar, choosing the Secrets tab and updating each entry as required).
  * Check if your 'Service Name' (in your Linked Data Source settings) is `mongodb-atlas`.

# Next Steps
  * Activate you trigger getdataTrigger to retrieve automatically the billing data using the getdata function.
  * You are now ready to use MongoDB Charts and build your first dashboards. If you need some inspiration you can have a look at [Building a MongoDB Billing Dashboard](https://www.mongodb.com/blog/post/building-a-mongodb-billing-dashboard--part-2)
 
# Bonus
  * I have included in the repository a pre-built dashboard `billing_charts.charts` which will give you info on your clusters, projects, SKU consumption over the last 7, 30 days and last 12 months. You will just have to [import](https://docs.mongodb.com/charts/saas/dashboards/#export-and-import-a-dashboard) the dashboard in your MongoDB Charts project.
 
# Enhancements
Additional enhancements are possible such as:
Extend the Billing code to retrieve data from multiple MongoDB Atlas Orgs.

# Postscript

If there are any errors or corrections required for this repo please feel free to send me a pull-request.

# Documentation
* [Realm CLI](https://docs.mongodb.com/realm/deploy/realm-cli-reference/)
* [MongoDB Atlas cluster](https://www.mongodb.com/cloud/atlas)
* [MongoDB Charts](https://docs.mongodb.com/charts/master/)
* [Values & Secrets](https://docs.mongodb.com/realm/values-and-secrets/)
* [MongoDB API Resources](https://docs.atlas.mongodb.com/reference/api-resources/)
* [Tracking and Managing Your Spend on MongoDB Atlas](https://www.youtube.com/watch?v=qP-n8wnwZzI)
* [Building a MongoDB Billing Dashboard](https://www.mongodb.com/blog/post/building-a-mongodb-billing-dashboard--part-2)

