

# Atlas Billing & MongoDB Charts

<img width="762" alt="Screenshot 2021-07-20 at 10 55 08" src="https://user-images.githubusercontent.com/77750987/126303881-5937fabb-d2d6-4e52-9fe0-2b14fa3bf6a5.png">


This repository is pretty much the exact replica of [MDB-live-2020](https://github.com/rbohan/MDB-live-2020). The main difference is that we will be using the Realm CLI Version 2 and only focus on how to deploy our charts.

If you want, I also created a small script that you can run to make it even easier, you will just have to input your organisation ID and pairs of API Keys (described below) to run it.

If you want more context around this rep, I encourage you to have a look at [Tracking and Managing Your Spend on MongoDB Atlas](https://www.youtube.com/watch?v=qP-n8wnwZzI).
 
 # Video
[![IMAGE ALT TEXT HERE](http://i3.ytimg.com/vi/1sD0MBuGecQ/hqdefault.jpg)](https://www.youtube.com/watch?v=1sD0MBuGecQ)
 

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
  
* [Download the Realm CLI Client](https://docs.mongodb.com/realm/deploy/realm-cli-reference/#installation)
  * Unless you want to build the application through the Realm UI you will have to install the Realm Cli to either run the command or the script `runRealmCli.sh`. You will need to have [npm](https://docs.npmjs.com/)installed on your machine to run installation. 
* The name of the cluster you will create to store the billing data has be called "billing" if you want to use another name you can modify the name of the cluster in the `realm_config.json` file.

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
* ### [Import the code into your Realm App](https://docs.mongodb.com/realm/deploy/realm-cli-reference/#import-an-application) from the root of the local github clone:
  * Log in via the Realm CLI using the details of the key you just created above (Project level): 
     `realm-cli login --api-key="<my api key>" --private-api-key="<my private api key>"`
  * Run the following to create a new Realm App:
     `realm-cli import`
  
* ### Answer the questions e.g.:

  * *? Do you want to create a new app?:* **Yes**
  * *? App name:* **billing**
  * *? App Location:* **[US-VA]**
  * *? App Deployment Model:* **LOCAL**
  * *? App Environment* **production**
   * *Note: this is expected to fail with an error message similar to the follow, as some Secrets have not yet been created:*
     **"failed to import app: error: error validating Value: auto-password: could not find secret "auto-passwordSecret"**

# Create Secrets
While the previous command failed, it did create a new Realm App. We will just need to create the missing Secrets which are our Organisation ID, Public-Key and Private-Key (to run our `getData` function).

 * Run the following to create a new Realm App:
   * `realm-cli secrets create -n billing-orgSecret -v <orgId>`
   * `realm-cli secrets create -n billing-usernameSecret -v <publicApiKey>`
   * `realm-cli secrets create -n billing-passwordSecret -v <privateApiKey>`

# Redeploy your app
### Now that we have our Secrets in place we can redeploy our App:
 * `realm-cli push --remote "billing"`

Select 'y' to confirm you want to repace the existing application.

# Run the `getData` function
### Now that our function, trigger and Secrets are up to date, we will need to run the function a first time (so we don't have to wait for the trigger to run)
 * `realm-cli function run —name "getData"`

# Double Check
  * If anthing goes wrong, check the error message and make sure you have entered the values of the Secrets correctly (you can update them at any stage by navigating to Values & Secrets on the left navigation bar, choosing the Secrets tab and updating each entry as required).

# Next Steps
  * You are now ready to use MongoDB Charts and build your first dashboards. If you need some inspiration you can have a look at [Building a MongoDB Billing Dashboard](https://www.mongodb.com/blog/post/building-a-mongodb-billing-dashboard--part-2)
 
# Bonus
  * I have included in the repository a pre-built dashboard `charts_billing_template.charts` which will give you info on your clusters, projects, SKU consumption over the last 7, 30 days and last 12 months. You will just have to [import](https://docs.mongodb.com/charts/saas/dashboards/#export-and-import-a-dashboard) the dashboard in your MongoDB Charts project.
 
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
* [MongoDB University: Introduction to MongoDB Charts](https://university.mongodb.com/courses/A131/about)


