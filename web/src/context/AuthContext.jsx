import {createContext, useEffect, useState} from "react";

export const AuthContext = createContext();

export const AuthProvider = ({children}) => {
    const [token, setToken] = useState(() => {
        return localStorage.getItem("token") || null;
    });
    const [user, setUser] = useState(() => {
        const user = localStorage.getItem("user");
        return user ? JSON.parse(user) : null;
    });

    const login = (newToken, newUser) => {
        setToken(newToken);
        setUser(newUser);
        localStorage.setItem("token", newToken);
        localStorage.setItem("user", JSON.stringify(newUser));
    };


    const logout = () => {
        setToken(null);
        // Supprimer les informations de l'utilisateur et le token de localStorage
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        setUser(null);
    };

    const checkTokenExpiration = () => {
        if (token) {
            const tokenExpiration = JSON.parse(atob(token.split('.')[1])).exp * 1000;
            if (Date.now() >= tokenExpiration) {
                logout();
            }
        }
    };

    useEffect(() => {
        checkTokenExpiration();
    }, [token]);

    return (
        <AuthContext.Provider value={{user, token, login, logout}}>
            {children}
        </AuthContext.Provider>
    );
};