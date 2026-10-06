
import express, {Router} from "express";
import {addAcc, getAccounts, transfer} from "./account/account.controller.js";


const router = express.Router();


router.get('/', getAccounts)
router.post('/add', addAcc)
router.post('/transfer', transfer)

export default router;