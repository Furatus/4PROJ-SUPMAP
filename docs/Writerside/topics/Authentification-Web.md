# Authentification Web

### Technologies utilisées
- API REST (/api/auth/login, /api/auth/register) : Pour gérer l’authentification avec le backend.
- React Router DOM : Pour rediriger l’utilisateur après connexion.
- JWT (JSON Web Token) : Gestion du token d’authentification.
- LocalStorage : Stockage du token côté client.
- UseAuth : Hook personnalisé pour gérer l’état de connexion de l’utilisateur (via un context).

### Fonctionnement
L'authentification se compose de deux vues : Login et Register.
Ces composants font partie d’un flux d’authentification classique :
- L’utilisateur entre ses identifiants dans un formulaire.
- Les données sont validées.
- Une requête HTTP est envoyée vers l'API REST du backend.
- En cas de succès, un token JWT est retourné et stocké en LocalStorage.
- L'utilisateur est redirigé vers la page d'accueil.
- Le token est ensuite envoyé lors des appels API en utilisant le token stocké dans le context et dans le LocalStorage.

```JS
const handleLogin = (e) => {
    e.preventDefault();
    console.log('Login attempt with:', email, password);
    axios.post(`${apiUrl}/auth/login`, {
        email,
        password
    }).then((response) => {
        login(response.data.token);
        navigate('/');
    }).catch((error) => {
        setErrors(error.response.data.error);
    });
};
```
Connection avec Google :
#### Procédure:
- L'utilisateur clique sur le bouton de connexion Google et se connecte sur la popup Google.
- Un token est récupéré , contenant les informations de l'utilisateur, et est envoyé au backend.
- Le backend vérifie le token avec Google et, si valide, crée un utilisateur dans la base de données.
- Le backend retourne un token JWT et les informations de l'utilisateur.

```js
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

```