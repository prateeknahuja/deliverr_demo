// Import modules
const express= require('express');
const CryptoJS = require("crypto-js");
const mongoose = require("mongoose");

const bodyParser = require('body-parser');
const Message=  require('./models/msg_model');
var mysql = require('mysql');

//Initialize variables
const app = express();
const port = process.env.PORT || 3000;
const dbConnection =  "mongodb+srv://deliverr-db-user:tempPassword1@cluster1.txfob.mongodb.net/deliverrdb?retryWrites=true&w=majority"   //Mongo DB database hosted on MongoDb Atlas
const key = "1515242426161525";  // Secret key used to encrypt the message
var encryptedMessage;
var jsonParser = bodyParser.json()
// ------------------------------------------------------------------------------------------------------------------------------------------

//Mongodb Connection 
// =============================================================================================
mongoose.connect(dbConnection, {
    useNewUrlParser: true, 
    useUnifiedTopology: true
});

mongoose.connection.on("error", err => {
    console.log("MongoDb Error: ", err)
  });

  mongoose.connection.on("connected", (err, res) => {
    console.log("Connected to mongodb database")
  });
// =============================================================================================

//RDS MYSQL DB CONNECTION
var connection = mysql.createConnection({
  host     : process.env.RDS_HOSTNAME,
  port: 3306,
  user     : process.env.RDS_USERNAME,
  password : process.env.RDS_PASSWORD
});
 
connection.connect(function(err) {
  if (err) {
    console.error('error connecting: ' + err.stack);
    return;
  }
 
  console.log('connected to MySQL as id ' + connection.threadId);
});
//==============================================================================================

//Start the service on port 3000
app.listen(port, ()=>{
    console.log("Started the app on port "+ port);
});

app.get('/health', (req,res)=> {
    res.send("Message Microservice is running."); 
});


// API to encrypt the message and store it in the mongodb database
app.post('/storeMessage', jsonParser, (req,res)=> {
    
    // Encrypt
    encryptedMessage = CryptoJS.AES.encrypt(req.body.message, key).toString();

    //Create an object of Message model
    var newMessage =  new Message({
        secretMessage: encryptedMessage
    });
    
    // Save the new encrypted message in the messages collection 
    newMessage.save().then((result) =>{
        res.send(result);
    }).catch((err)=>{
        console.log(err);
    });
});


// API to retrieve the message from the mongodb
app.get('/getMessage', (req,res)=> {
    var msg =  new Message();
    
    //Retrieve the last message from messages collection.
    Message.find().sort({$natural:-1}).limit(1).then((result)=>{
        // Decrypt the message. 
        var bytes  = CryptoJS.AES.decrypt(result[0].secretMessage, key);
        var message = bytes.toString(CryptoJS.enc.Utf8);
        res.send(message);
    }).catch((err)=>{
        console.log(err);
    }); 
});