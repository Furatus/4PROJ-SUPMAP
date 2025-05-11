"use client"
import {useState} from "react"
import {Link, useNavigate} from "react-router-dom"
import {LockIcon, MailIcon, UserIcon} from "lucide-react"
import axios from "axios"
import Lottie from "react-lottie-player"
import lottieJson from "../assets/animations/Animation_manwithphone.json"
import GoogleAuth from "./GoogleAuth";

export default function RegisterPage() {
    const navigate = useNavigate()
    const [formData, setFormData] = useState({
        email: "",
        pseudo: "",
        password: "",
        confirmPassword: "",
    })
    const [errors, setErrors] = useState(null)
    const apiUrl = import.meta.env.VITE_API_SERVER_URL

    const handleChange = (e) => {
        setFormData({...formData, [e.target.name]: e.target.value})
    }

    const handleRegister = (e) => {
        e.preventDefault()
        // Check if the password and confirm password match
        if (formData.password !== formData.confirmPassword) {
            setErrors("Les mots de passe ne correspondent pas")
            return
        }

        // Remove confirmPassword from formData
        const {confirmPassword, ...data} = formData
        console.log("Registration attempt with:", data)
        axios
            .post(`${apiUrl}/auth/register`, data)
            .then(() => {
                navigate("/login")
            })
            .catch((err) => {
                setErrors(err.response.data.error)
            })
    }


    return (
        <div
            className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 py-12 px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-7xl w-full">
                <div className="max-w-md w-full space-y-8 bg-white p-8 rounded-xl shadow-xl border border-gray-100">
                    <div>
                        <h2 className="text-center text-3xl font-extrabold text-gray-900 mb-2">Créer un compte</h2>
                        <p className="mt-2 text-center text-sm text-gray-600">
                            Ou{" "}
                            <Link to="/login" className="font-medium text-teal-600 hover:text-teal-500">
                                connectez-vous à votre compte
                            </Link>
                        </p>
                    </div>
                    {errors && (
                        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mt-4">
                            <strong>Erreur : </strong>
                            {errors}
                        </div>
                    )}
                    <form className="mt-8 space-y-6" onSubmit={handleRegister}>
                        <div className="rounded-md shadow-sm space-y-4">
                            <div className="relative">
                                <label htmlFor="pseudo" className="sr-only">
                                    Pseudo
                                </label>
                                <div
                                    className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none z-10">
                                    <UserIcon className="h-5 w-5 text-gray-400" aria-hidden="true"/>
                                </div>
                                <input
                                    id="pseudo"
                                    name="pseudo"
                                    type="text"
                                    required
                                    className="appearance-none rounded-lg relative block w-full px-3 py-3 pl-10 border border-gray-300 placeholder-gray-400 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 sm:text-sm transition-all duration-200 ease-in-out"
                                    placeholder="Pseudo"
                                    value={formData.pseudo}
                                    onChange={handleChange}
                                />
                            </div>
                            <div className="relative">
                                <label htmlFor="email-address" className="sr-only">
                                    Adresse email
                                </label>
                                <div
                                    className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none z-10">
                                    <MailIcon className="h-5 w-5 text-gray-400" aria-hidden="true"/>
                                </div>
                                <input
                                    id="email-address"
                                    name="email"
                                    type="email"
                                    autoComplete="email"
                                    required
                                    className="appearance-none rounded-lg relative block w-full px-3 py-3 pl-10 border border-gray-300 placeholder-gray-400 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 sm:text-sm transition-all duration-200 ease-in-out"
                                    placeholder="Adresse email"
                                    value={formData.email}
                                    onChange={handleChange}
                                />
                            </div>
                            <div className="relative">
                                <label htmlFor="password" className="sr-only">
                                    Mot de passe
                                </label>
                                <div
                                    className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none z-10">
                                    <LockIcon className="h-5 w-5 text-gray-400" aria-hidden="true"/>
                                </div>
                                <input
                                    id="password"
                                    name="password"
                                    type="password"
                                    autoComplete="new-password"
                                    required
                                    className="appearance-none rounded-lg relative block w-full px-3 py-3 pl-10 border border-gray-300 placeholder-gray-400 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 sm:text-sm transition-all duration-200 ease-in-out"
                                    placeholder="Mot de passe"
                                    value={formData.password}
                                    onChange={handleChange}
                                />
                            </div>
                            <div className="relative">
                                <label htmlFor="confirm-password" className="sr-only">
                                    Confirmer le mot de passe
                                </label>
                                <div
                                    className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none z-10">
                                    <LockIcon className="h-5 w-5 text-gray-400" aria-hidden="true"/>
                                </div>
                                <input
                                    id="confirm-password"
                                    name="confirmPassword"
                                    type="password"
                                    autoComplete="new-password"
                                    required
                                    className="appearance-none rounded-lg relative block w-full px-3 py-3 pl-10 border border-gray-300 placeholder-gray-400 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 sm:text-sm transition-all duration-200 ease-in-out"
                                    placeholder="Confirmer le mot de passe"
                                    value={formData.confirmPassword}
                                    onChange={handleChange}
                                />
                            </div>
                        </div>
                        <div>
                            <button
                                type="submit"
                                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-teal-600 hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 transition-all duration-300 shadow-md hover:shadow-lg transform hover:-translate-y-0.5"
                            >
                                S'inscrire
                            </button>
                        </div>
                    </form>
                    <div className="relative my-6">
                        <div className="absolute inset-0 flex items-center">
                            <div className="w-full border-t border-gray-300"></div>
                        </div>
                        <div className="relative flex justify-center text-sm">
                            <span className="px-2 bg-white text-gray-500">Ou continuer avec</span>
                        </div>
                    </div>
                    <div className="flex items-center justify-center">
                       <GoogleAuth/>
                    </div>
                </div>
                <div className="hidden md:flex items-center justify-center">
                    <Lottie loop animationData={lottieJson} play style={{width: "100%", height: "100%"}}/>
                </div>
            </div>
        </div>
    )
}

