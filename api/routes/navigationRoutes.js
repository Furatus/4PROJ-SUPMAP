import {getCustomModel, route} from "../controllers/navigationController.js";
import express from "express";

const router = express.Router();

/**
 * @swagger
 * tags:
 *  name: Navigation
 *  description: Navigation related endpoints
 */

/**
 * @swagger
 * post:
 *
 * /navigation/getCustomModel:
 *   get:
 *     summary: Get custom model
 *     tags: [Navigation]
 *     responses:
 *       200:
 *         description: Custom model retrieved successfully
 *       500:
 *         description: Internal server error
 *
 */

router.get("/getCustomModel", getCustomModel);


/**
 * @swagger
 * /navigation/route:
 *      post:
 *          summary: Get navigation route
 *          tags: [Navigation]
 *          description: Overload the default route to use the custom model with the custom parameters
 */

router.post("/route", route);


export default router;