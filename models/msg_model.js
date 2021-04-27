const mongoose = require('mongoose');

const messageSchema = mongoose.Schema({
    secretMessage:{
        type: String,
        required: true
    }
}, { timestamps: true });


const Message = module.exports = mongoose.model('Message', messageSchema);