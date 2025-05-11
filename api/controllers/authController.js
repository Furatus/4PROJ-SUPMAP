import User from "../models/User.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import {userSchema} from "../validations/authValidation.js";


export const register = async (req, res) => {
    const {email, pseudo, password} = req.body;
    const {error} = userSchema.validate(req.body);
    if (error) return res.status(400).json({error: error.details[0].message});
    try {
        const existingUser = await User.findOne({ email: email });
        if (existingUser) {
            return res.status(400).json({error: "Email déjà utilisé"});
        }
        const existingPseudo = await User.findOne({pseudo: pseudo});
        if (existingPseudo) return res.status(400).json({error: "Pseudo déjà utilisé"});
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({email, pseudo, password: hashedPassword});
        await newUser.save();
        const token = jwt.sign({ id: newUser._id, role: newUser.role }, process.env.JWT_SECRET, { expiresIn: "3d" });
        res.status(201).json({ message: "Utilisateur créé avec succès", token: token, user: { id: newUser._id, pseudo: newUser.pseudo, email: newUser.email, role: newUser.role } });
    } catch (err) {
        res.status(500).json({error: "Erreur serveur"});
    }
};

export const login = async (req, res) => {
    const {email, password} = req.body;

    try {
        const user = await User.findOne({email});
        if (!user) return res.status(400).json({error: "Utilisateur non trouvé"});

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({error: "Mot de passe incorrect"});
        const token = jwt.sign({id: user._id, role: user.role}, process.env.JWT_SECRET, {expiresIn: "3d"});


        res.json({ token : token, user: {id: user._id, pseudo: user.pseudo, email: user.email, role: user.role}});
    } catch (err) {
        res.status(500).json({error: "Erreur serveur"});
    }
};
export const getUser = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select("-password -role");
        res.json(user);
    }
    catch (err) {
        res.status(500).json({error: "Erreur serveur"});
    }
}

export const deleteUser = async (req, res) => {
    try {
        await User.findByIdAndDelete(req.user.id);
        res.json({message: "Utilisateur supprimé"});
    }
    catch (err) {
        res.status(500).json({error: "Erreur serveur"});
    }
}

export  const  googleAuth = async (req, res) => {
    if (!req.user) {
        return res.status(401).json({ message: 'Authentication failed' });
    }
    const token = jwt.sign({ id: req.user._id, role: req.user.role }, process.env.JWT_SECRET, { expiresIn: "3d" });
    res.json({ token: token, user: { id: req.user._id, pseudo: req.user.pseudo, email: req.user.email, role: req.user.role } });
}


