import  pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port :  Number(process.env.DB_PORT)

});


const connectDB = async () => {
    try{
        const client = await  pool.connect();

        console.log("Connected to Postgres...");
    client.release();
    }catch (error){
        console.error("Error connecting to Postgres...", error.message);
        process.exit(1);
    }
}




export {
    connectDB,
    pool
}

