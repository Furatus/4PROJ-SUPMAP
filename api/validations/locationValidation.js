import Joi from "joi";


export const locationSchema = Joi.object({

    lat: Joi.number()
        .required()
        .messages({
            'number.base': `La latitude doit être un nombre.`,
            'any.required': `La latitude est requise.`
        }),
    lon: Joi.number()
        .required()
        .messages({
            'number.base': `La longitude doit être un nombre.`,
            'any.required': `La longitude est requise.`
        })
});