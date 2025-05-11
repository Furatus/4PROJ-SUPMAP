import Joi from "joi";

export const userSchema = Joi.object({
    email: Joi.string()
        .email({tlds: {allow: false}})
        .required()
        .messages({
            'string.empty': `L'email ne doit pas être vide.`,
            'string.email': `L'email doit être valide.`,
            'any.required': `L'email est requis.`
        }),
    pseudo: Joi.string()
        .min(2)
        .max(50)
        .required()
        .messages({
            'string.empty': `Le pseudo ne doit pas être vide.`,
            'string.min': `Le pseudo doit avoir une longueur minimale de {#limit} caractères.`,
            'string.max': `Le pseudo doit avoir une longueur maximale de {#limit} caractères.`,
            'any.required': `Le pseudo est requis.`
        }),
    password: Joi.string()
        .min(8)
        .max(50)
        .required()
        .messages({
            'string.empty': `Le mot de passe ne doit pas être vide.`,
            'string.min': `Le mot de passe doit avoir une longueur minimale de {#limit} caractères.`,
            'string.max': `Le mot de passe doit avoir une longueur maximale de {#limit} caractères.`,
            'any.required': `Le mot de passe est requis.`
        }),
});
