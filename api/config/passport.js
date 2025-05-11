import passport from "passport";
import {Strategy as LocalStrategy} from "passport-local";
import {ExtractJwt, Strategy as JwtStrategy} from "passport-jwt";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import { Strategy as GoogleTokenStrategy } from 'passport-google-verify-token';
import {googleAuth} from "../controllers/authController.js";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import dotenv from "dotenv";

dotenv.config();

// Stratégie locale (email + mot de passe)
passport.use(

    new LocalStrategy(
        {usernameField: "email"},
        async (email, password, done) => {
            try {
                const user = await User.findOne({email});
                if (!user) return done(null, false, {message: "Utilisateur non trouvé"});

                const isMatch = await bcrypt.compare(password, user.password);
                if (!isMatch) return done(null, false, {message: "Mot de passe incorrect"});

                return done(null, user);
            } catch (err) {
                return done(err);
            }
        }
    )
);

// Stratégie JWT
const opts = {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: process.env.JWT_SECRET,
};

passport.use(
    new JwtStrategy(opts, async (jwt_payload, done) => {
        try {
            const user = await User.findById(jwt_payload.id);
            if (user) return done(null, user);
            return done(null, false);
        } catch (err) {
            return done(err, false);
        }
    })
);


// Stratégie Google Token
passport.use(
    'google-token',
    new GoogleTokenStrategy(
    {
        // Optionnel : audience si plusieurs clients (web, mobile, etc.)
        audience: [process.env.GOOGLE_WEB_CLIENT_ID, process.env.GOOGLE_ANDROID_CLIENT_ID],
    },
    async (parsedToken, googleId, done) => {
        try {
            // Vérifiez si l'utilisateur s'est connecté avec un autre moyen
            const user = await User.findOne({ email: parsedToken.email });
            if (user) {
                // Si l'utilisateur existe déjà, mettez à jour son googleId
                user.googleId = parsedToken.sub;
                await user.save();
                return done(null, user);
            }
            // Vérifiez si l'utilisateur s'est déjà connecté avec Google
            const userWithGoogle = await User.findOne({ googleId: parsedToken.sub });
            if (!userWithGoogle) {
                const newUser = new User({
                    googleId: parsedToken.sub,
                    email: parsedToken.email,
                    pseudo: parsedToken.name,
                    picture: parsedToken.picture,
                });
                await newUser.save();
                return done(null, newUser);
            }
            return done(null, user);
        } catch (err) {
            return done(err);
        }
    }
));



export default passport;
