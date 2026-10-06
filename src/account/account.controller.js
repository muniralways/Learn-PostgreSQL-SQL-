import {createAccount, getAllAcc, transferFunds} from "./service.js";




export const getAccounts = async (req, res) => {
    try{
        const accounts = await  getAllAcc();
        res.status(200).json(accounts);
    }catch(err){
        console.log(err);
    }
}


export const addAcc = async (req, res) => {
    try{
        const {name, balance} = req.body;

        const account = await createAccount(name, balance);

        res.status(200).json({
            success: true,
            message: "Account created successfully",
            data: account
        })
    }catch(err) {
        console.log(err);
    }
}

export const transfer = async (req, res) => {
    try{
        const {senderId , receiverId, amount} = req.body;

        const result = await transferFunds(senderId, receiverId, amount);

        res.status(200).json({
            success: true,
            message: `Successfully transferred ${senderId} successfully`,
            data: result
        })

    }catch(err){
        console.log(err);
    }
}



