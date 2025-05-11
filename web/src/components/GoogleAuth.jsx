import {useState} from 'react';
import {GoogleLogin} from "@react-oauth/google";
import {useAuth} from "../hooks/useAuth";
import axios from "axios";

const GoogleAuth = () => {
    const apiUrl = import.meta.env.VITE_API_SERVER_URL;
    const {login} = useAuth();
    const [successMessage, setSuccessMessage] = useState(false);
    const [errorMessage, setErrorMessage] = useState(null);


    return (

        <div className="container p-3 rounded flex flex-col items-center justify-center">
            {successMessage &&
                <div
                    className="p-4 mb-4 text-sm text-green-800 rounded-lg bg-green-50 dark:bg-gray-800 dark:text-green-400"
                    role="alert">
                    <span className="font-medium">Authentification réussie !</span> Vous allez être redirigé.
                </div>}
            {errorMessage &&
                <div className="p-4 mb-4 text-sm text-red-800 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400"
                     role="alert">
                    <span className="font-medium">Erreur!</span> Veuillez réessayer.
                </div>}

            {!successMessage && !errorMessage && <div className="p-4 mb-4 invisible"></div>}

            < GoogleLogin

                onSuccess={(credentialResponse) => {
                    const token = credentialResponse.credential;
                    axios.post(`${apiUrl}/auth/google`, {id_token: token})
                        .then(response => {
                            if (response.status === 200) {
                                const {token, user} = response.data;
                                login(token, user);
                                setTimeout(() => {
                                    setSuccessMessage(true);
                                }, 2000);
                                setTimeout(() => {
                                    window.location.href = '/';
                                }, 3000);
                            } else {
                                setTimeout(() => {
                                    setErrorMessage(true);
                                }, 2000);
                            }

                        })
                        .catch((error) => {
                            console.error('Error:', error);
                        });
                }}
                onError={() => {
                    console.log('Login Failed');
                }}
                useOneTap={false}
            />
        </div>

    );
};

export default GoogleAuth;
