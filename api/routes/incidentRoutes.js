import {
    addIncident,
    confirmIncident,
    getIncidents,
    refuteIncident,
    getIncidentsNearLocation,
    getIncidentsNearMe,
    closeExpiredIncidentsEndpoint
} from "../controllers/incidentController.js";
import express from "express";
import passport from "passport";

const router = express.Router();
/**
 * @swagger
 * tags:
 *   name: Incidents
 *   description: API pour gérer les incidents
 */
/**
 * @swagger
 * /incidents/create:
 *   post:
 *     summary: Créer un nouvel incident
 *     tags: [Incidents]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               location:
 *                 type: string
 *                 description: Emplacement de l'incident
 *               type:
 *                 type: string
 *                 description: Type d'incident
 *     responses:
 *       201:
 *         description: Incident créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   description: ID de l'incident
 *                 location:
 *                   type: string
 *                   description: Emplacement de l'incident
 *                 type:
 *                   type: string
 *                   description: Type d'incident
 *                 severity:
 *                   type: string
 *                   description: Sévérité de l'incident
 *                 status:
 *                   type: string
 *                   description: Statut de l'incident
 *                 createdBy:
 *                   type: string
 *                   description: ID de l'utilisateur qui a créé l'incident
 *                 updatedBy:
 *                   type: string
 *                   description: ID de l'utilisateur qui a mis à jour l'incident
 *                 createdAt:
 *                   type: string
 *                   description: Date de création de l'incident
 *                 updatedAt:
 *                   type: string
 *                   description: Date de mise à jour de l'incident
 */


router.post("/create", passport.authenticate("jwt", {session: false}), addIncident);


/**
 * @swagger
 * /incidents/confirm/{id}:
 *   get:
 *     summary: Confirmer un incident
 *     tags: [Incidents]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: ID de l'incident à confirmer
 *     responses:
 *       200:
 *         description: Incident confirmé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   description: ID de l'incident
 */
router.get("/confirm/:id", passport.authenticate("jwt", {session: false}), confirmIncident);

/**
 * @swagger
 * /incidents/refute/{id}:
 *   get:
 *     summary: Réfuter un incident
 *     tags: [Incidents]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: ID de l'incident à réfuter
 *     responses:
 *       200:
 *         description: Incident réfuté avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   description: ID de l'incident
 */

router.get("/refute/:id", passport.authenticate("jwt", {session: false}), refuteIncident);
/**
 * @swagger
 * /incidents/get/nearme:
 *   get:
 *     summary: Récupérer les incidents à proximité d'une localisation donnée
 *     tags: [Incidents]
 *     responses:
 *       200:
 *         description: Liste des incidents récupérée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 incidents:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: string
 *                         description: ID de l'incident
 */

router.get("/get/nearlocation", passport.authenticate("jwt", {session: false}), getIncidentsNearLocation);

/**
 * @swagger
 * /incidents/get/nearlocation:
 *   get:
 *     summary: Récupérer les incidents à proximité de l'utilisateur
 *     tags: [Incidents]
 *     responses:
 *       200:
 *         description: Liste des incidents récupérée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 incidents:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: string
 *                         description: ID de l'incident
 */
router.get("/get/nearme", passport.authenticate("jwt", {session: false}), getIncidentsNearMe);


/**
 * @swagger
 * /incident:
 *   get:
 *     summary: Récupérer tous les incidents
 *     tags: [Incidents]
 *     parameters:
 *       - name: limit
 *         in: query
 *         required: false
 *         description: Nombre maximum d'incidents à récupérer par page
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: Liste des incidents récupérée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 incidents:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: string
 *                         description: ID de l'incident
 *                       location:
 *                         type: string
 *                         description: Emplacement de l'incident
 *                       type:
 *                         type: string
 *                         description: Type d'incident
 */
router.get("/", passport.authenticate("jwt", {session: false}), getIncidents);

/**
 * @swagger
 * /incidents/closeExpired:
 *   get:
 *     summary: Fermer les incidents expirés
 *     tags: [Incidents]
 *     responses:
 *       200:
 *         description: Incidents expirés fermés avec succès
 *       403:
 *         description: Accès refusé si l'utilisateur n'est pas administrateur
 */
router.get ("/closeExpired", passport.authenticate("jwt", {session: false}), closeExpiredIncidentsEndpoint);

export default router;