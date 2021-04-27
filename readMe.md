The Message Microservices is responsible for storing and retreving a sensitive message. 

The microservice has three apis:

- GET /health => To check if the microservice is up and running.

- POST /storeMessage => This api needs the message to be passed in the body of the request. 
                        This message is then encrypted and stored in the messages database 

                        ex. body 
                        {
                            "message": "This is the secret message"
                        }

- GET /getMessage => This api retrieves the last message stored in the database. 
                     Decrypts the message using the same key and returns the message to the user. 



=====================================================================================================================================

<h1>PROVISIONING/DEPLOYMENT INSTRUCTIONS</h1>

1. To provision the app on AWS Elastic Beanstalk and RDS, you need the access key and secret key for the AWS account. 
2. Now go into the provisioning directory, and enter the access key and secret key in the variables.example.tfvars file. 
3. Now rename the variables.example.tfvars file to variables.auto.tfvars. This will automatically inject the values for the variables in terraform. 
4. Now run the below command to plan the resources, check everything is good. 
    terraform plan 

5. Then run apply to provision the Elastic Beanstalk (NodeJS) instance with RDS (MySQL)

=====================================================================================================================================



NOTES: 
1. The deliver_v3.zip is zip file of the Message Microservice. Terraform will automatically deploy this zip file to the AWS Elastic Beanstalk. 


2. I have hosted the mongo db database on the Mongo AtlasDB under my account. The connection string is mentioned in the app.js. 
   The messages are encrypted stored into the messages collection in the mongodb. The getMessage Api retrieves the message from mongodb, decryts the message and send it as response. 


3. I have also created the connection to the MySQL RDS from the app.

4. All the VPC/Network manifests are specified in the vpc.tf file.

5. The RDS Database connection is also configured in the app.js file. The connection info is passed as environment variables to the app during the time of provisioning.
