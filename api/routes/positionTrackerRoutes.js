import express from "express";
import passport from "passport";
import {updateLocation} from "../controllers/PositionController.js";

const router = express.Router();

/**
 * @swagger
 * /positionTracker/updateLocation:
 *   post:
 *     summary: Met à jour la position de l'utilisateur
 *     tags: [PositionTracker]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               latitude:
 *                 type: number
 *                 description: Latitude de la position
 *               longitude:
 *                 type: number
 *                 description: Longitude de la position
 *     responses:
 *       200:
 *         description: Position mise à jour avec succès
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur interne du serveur
 */
router.post("/updateLocation", passport.authenticate("jwt", {session: false}) , updateLocation);

export default router;