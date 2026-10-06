import {pool} from "./db.js";


export const createTable = async () => {
    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS accounts (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                balance NUMERIC(10, 2) NOT NULL CHECK (balance >= 0),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        await pool.query(`
            CREATE TABLE IF NOT EXISTS transaction_logs (
                id SERIAL PRIMARY KEY,
                sender_id INT REFERENCES accounts(id),
                receiver_id INT REFERENCES accounts(id),
                amount NUMERIC(10, 2) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);


        await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_tx_sender 
        ON transaction_logs(sender_id)
        
        `)

        await pool.query(`CREATE INDEX IF NOT EXISTS idx_tx_receiver ON transaction_logs(receiver_id)`)


        console.log("Database tables initialized successfully!");
    } catch (error) {
        console.error("Error creating table with error:", error);
        throw error;
    }
};