import Joi from "joi";

export const locationSchema = Joi.object({
    lat: Joi.number()
        .required()
        .messages( {
            'number.base': `latitude must be a number.`,
            'any.required': `latitude is required.`
        }),
    lon : Joi.number()
        .required()
        .messages({
            'number.base': `longitute must be a number.`,
            'any.required': `longitute is required.`
        }),
});