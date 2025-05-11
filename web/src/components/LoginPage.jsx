import React, {useState} from 'react';
import {Link, useNavigate} from 'react-router-dom';
import {LockIcon, MailIcon} from 'lucide-react';
import axios from 'axios';
import {useAuth} from "../hooks/useAuth";
import Lottie from 'react-lottie-player';
import lottieJson from '../assets/animations/Animation_manwithphone.json';
import GoogleAuth from "./GoogleAuth";

export default function LoginPage() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [errors, setErrors] = useState(null);
    const apiUrl = import.meta.env.VITE_API_SERVER_URL;
    const {login} = useAuth();
    const navigate = useNavigate();

    const handleLogin = (e) => {
        e.preventDefault();
        console.log('Login attempt with:', email, password);
        axios.post(`${apiUrl}/auth/login`, {
            email,
            password
        }).then((response) => {
            console.log('Login successful:', response.data);
            const token = response.data.token;
            const user = response.data.user;
            if (token) {
                login(token, user);
            }
            navigate('/');
        }).catch((error) => {
            setErrors(error.response.data.error);
        });
    };

    return (
        <div
            className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 py-12 px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-7xl w-full">
                <div className="hidden md:flex items-center justify-center">
                    <Lottie
                        loop
                        animationData={lottieJson}
                        play
                        style={{width: '100%', height: '100%'}}
                    />
                </div>
                <div className="max-w-md w-full space-y-8 bg-white p-8 rounded-xl shadow-xl border border-gray-100">
                    <div>
                        <h2 className="text-center text-3xl font-extrabold text-gray-900 mb-2">Connexion</h2>
                        <p className="mt-2 text-center text-sm text-gray-600">
                            Ou{" "}
                            <Link to="/register" className="font-medium text-teal-600 hover:text-teal-500">
                                créez un compte
                            </Link>
                        </p>
                    </div>
                    {errors && (
                        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mt-4">
                            <strong>Erreur : </strong>
                            {errors}
                        </div>
                    )}
                    <form className="mt-8 space-y-6" onSubmit={handleLogin}>
                        <div className="rounded-md shadow-sm space-y-4">
                            <div>
                                <label htmlFor="email-address" className="sr-only">
                                    Adresse email
                                </label>
                                <div className="relative">
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
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                    />
                                </div>
                            </div>
                            <div>
                                <label htmlFor="password" className="sr-only">
                                    Mot de passe
                                </label>
                                <div className="relative">
                                    <div
                                        className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none z-10">
                                        <LockIcon className="h-5 w-5 text-gray-400" aria-hidden="true"/>
                                    </div>
                                    <input
                                        id="password"
                                        name="password"
                                        type="password"
                                        autoComplete="current-password"
                                        required
                                        className="appearance-none rounded-lg relative block w-full px-3 py-3 pl-10 border border-gray-300 placeholder-gray-400 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 sm:text-sm transition-all duration-200 ease-in-out"
                                        placeholder="Mot de passe"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>
                        <div>
                            <button
                                type="submit"
                                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-teal-600 hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 transition-all duration-300 shadow-md hover:shadow-lg transform hover:-translate-y-0.5"
                            >
                                Se connecter
                            </button>
                        </div>
                    </form>
                    <div className="relative my-6">
                        <div className="absolute inset-0 flex items-center">
                            <div className="w-full border-t border-gray-300"></div>
                        </div>
                        <div className="relative flex justify-center text-sm">
                            <span className="px-2 bg-white text-gray-500">Ou se connecter avec</span>
                        </div>
                    </div>
                    <div className="flex items-center justify-center mt-4">
                        <GoogleAuth/>
                    </div>
                </div>
            </div>
        </div>
    );
}
