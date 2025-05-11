import express from "express";
import passport from "passport";
import {login, register,deleteUser, getUser, googleAuth} from "../controllers/authController.js";
import jwt from "jsonwebtoken";

const router = express.Router();
/**
 * @swagger
 * tags:
 *   name: Authentification
 *   description: API pour l'authentification des utilisateurs
 */
/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Inscription d'un nouvel utilisateur
 *     tags: [Authentification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - pseudo
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               pseudo:
 *                 type: string
 *               password:
 *                 type: string
 *                 format: password
 *     responses:
 *       201:
 *         description: Utilisateur créé avec succès
 *       400:
 *         description: Erreur de validation ou email/pseudo déjà utilisé
 *       500:
 *         description: Erreur serveur
 */
router.post("/register", register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Connexion utilisateur
 *     tags: [Authentification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *                 format: password
 *     responses:
 *       200:
 *         description: Connexion réussie
 *       400:
 *         description: Email ou mot de passe incorrect
 *       500:
 *         description: Erreur serveur
 */
router.post("/login", login);

/**
 * @swagger
 * /auth/profile:
 *   get:
 *     summary: Récupérer le profil de l'utilisateur connecté
 *     tags: [Authentification]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Données de l'utilisateur
 *       401:
 *         description: Utilisateur non authentifié
 *       500:
 *         description: Erreur serveur
 */
router.get("/profile", passport.authenticate("jwt", {session: false}), getUser);

/**
 * @swagger
 * /auth/delete:
 *   delete:
 *     summary: Supprimer le compte utilisateur
 *     tags: [Authentification]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Utilisateur supprimé
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
router.delete("/delete", passport.authenticate("jwt", {session: false}), deleteUser);

/**
 * @swagger
 * /auth/google:
 *   post:
 *     summary: Authentification via Google
 *     tags: [Authentification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - access_token
 *             properties:
 *               access_token:
 *                 type: string
 *                 description: Jeton OAuth2 fourni par Google
 *     responses:
 *       200:
 *         description: Authentification réussie
 *       401:
 *         description: Échec de l'authentification
 */


// Route pour l'authentification Google
router.post('/google', passport.authenticate('google-token', {session: false}), (req, res) => {
    if (req.user) {
        const token = jwt.sign({ id: req.user._id, role: req.user.role }, process.env.JWT_SECRET, { expiresIn: "3d" });
        res.status(200).json({ message: "Utilisateur authentifié avec succès", token: token, user: { id: req.user._id, pseudo: req.user.pseudo, email: req.user.email, role: req.user.role, picture:req.user.picture } });
    } else {
        res.status(401).json({ message: "Utilisateur non authentifié" });
    }
});
export default router;
