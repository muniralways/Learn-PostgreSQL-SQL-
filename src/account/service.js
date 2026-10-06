import { pool } from "../../db.js";
const MIN_INITIAL_BALANCE = 400;

export const getAllAcc = async () => {
    const result = await pool.query('SELECT * FROM accounts ORDER BY created_at ASC');
    return result.rows;
};


export const createAccount = async (name, balance) => {
    name = typeof name === 'string' ? name.trim() : '';
    balance = Number(balance);

    if (!name || name.length > 50) {
        throw new AppError("Name is required and must be 50 characters or less", 400);
    }
    if (!Number.isFinite(balance) || balance < MIN_INITIAL_BALANCE) {
        throw new AppError(`Initial balance must be at least ${MIN_INITIAL_BALANCE} tk`, 400);
    }

    const result = await pool.query(
        'INSERT INTO accounts (name, balance) VALUES ($1, $2) RETURNING id, name, balance, created_at',
        [name, balance]
    );

    return result.rows[0];
};


export const transferFunds = async (senderId, receiverId, amount) => {
    senderId = Number(senderId);
    receiverId = Number(receiverId);
    amount = Number(amount);

    if (!Number.isSafeInteger(senderId) || !Number.isSafeInteger(receiverId)) {
        throw new Error("senderId and receiverId must be valid numbers");
    }
    if (!Number.isFinite(amount) || amount <= 0) {
        throw new Error("Amount must be a number greater than 0");
    }
    if (senderId === receiverId) {
        throw new Error("Sender and receiver cannot be the same account");
    }

    const client = await pool.connect();

    try { 
        await client.query('BEGIN');

        const locked = await client.query(
            'SELECT id, name, balance FROM accounts WHERE id = ANY($1) ORDER BY id FOR UPDATE',
            [[senderId, receiverId]]
        );

        const sender = locked.rows.find((r) => r.id === senderId);
        const receiver = locked.rows.find((r) => r.id === receiverId);

        if (!sender) throw new Error("Sender account not found");
        if (!receiver) throw new Error("Receiver account not found");

        if (Number(sender.balance) < amount) {
            throw new Error("Insufficient balance");
        }

        const senderRes = await client.query(
            'UPDATE accounts SET balance = balance - $1 WHERE id = $2 RETURNING balance',
            [amount, senderId]
        );

        await client.query(
            'UPDATE accounts SET balance = balance + $1 WHERE id = $2',
            [amount, receiverId]
        );

        await client.query(
            'INSERT INTO transaction_logs (sender_id, receiver_id, amount) VALUES ($1, $2, $3)',
            [senderId, receiverId, amount]
        );

        await client.query('COMMIT');

        return {
            sender: sender.name,
            newBalance: senderRes.rows[0].balance,
            receiver: receiver.name,
            transferredAmount: amount,
        };
    } catch (error) {
        try {
            await client.query('ROLLBACK');
        } catch (rollbackError) {
            console.error('Rollback failed', rollbackError.message);
        }
        throw error;
    } finally {
        client.release();
    }
};