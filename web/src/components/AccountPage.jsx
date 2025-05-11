import {useEffect, useState} from "react";
import {Save, Trash, User} from "lucide-react";
import axios from "axios";
import {useAuth} from "../hooks/useAuth";

export default function AccountPage() {
    const [profile, setProfile] = useState(null);
    const {token} = useAuth();
    const [successMessage, setSuccessMessage] = useState(null);
    const [errors, setErrors] = useState({});
    const [updatedInfo, setUpdatedInfo] = useState({});
    const [isEditing, setIsEditing] = useState(false);
    const apiUrl = import.meta.env.VITE_API_SERVER_URL;

    const handleUpdateAccount = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.put(`${apiUrl}/auth/profile`, updatedInfo, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });
            setProfile(response.data);
            setSuccessMessage("Informations mises à jour avec succès.");
            setErrors({});
            setIsEditing(false);
        } catch (error) {
            console.error("Update error:", error);
            setErrors(error.response?.data || {});
        }
    };

    const handleDeleteAccount = async () => {
        try {
            await axios.delete(`${apiUrl}/auth/profile`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });
            // Redirige ou vide les infos après suppression
            setProfile(null);
            setSuccessMessage("Compte supprimé avec succès.");
        } catch (error) {
            console.error("Delete error:", error);
            setErrors({general: "Erreur lors de la suppression du compte."});
        }
    };

    const handleChange = (e) => {
        setUpdatedInfo({...updatedInfo, [e.target.name]: e.target.value});
    };

    const fetchUserInfo = async () => {
        try {
            const response = await axios.get(`${apiUrl}/auth/profile`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });
            setProfile(response.data);
            setUpdatedInfo({
                pseudo: response.data.pseudo,
                email: response.data.email,
            });
        } catch (error) {
            console.error("Fetch user info error:", error);
            setErrors({general: "Impossible de récupérer les informations."});
        }
    };

    useEffect(() => {
        fetchUserInfo();
    }, []);

    return (
        <>
            {profile === null ? (
                <div className="bg-white shadow-lg rounded-lg p-8 mb-8">
                    <p className="text-gray-600">Vos informations ne sont pas disponibles pour le moment.</p>
                </div>
            ) : (
                <div className="bg-white shadow overflow-hidden sm:rounded-lg">
                    <div className="px-4 py-5 sm:px-6 flex justify-between items-center">
                        <div>
                            <h1 className="text-2xl font-bold text-gray-900">Mon profil</h1>
                            <p className="mt-1 max-w-2xl text-sm text-gray-500">
                                Compte créé le {new Date(profile.createdAt).toLocaleDateString()}
                            </p>
                        </div>
                        <div className="space-x-2">
                            <button
                                type="button"
                                onClick={() => setIsEditing(!isEditing)}
                                className="inline-flex items-center px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-teal-600 hover:bg-teal-700"
                            >
                                {isEditing ? 'Annuler' : 'Modifier le profil'}
                            </button>
                            <button
                                type="button"
                                onClick={handleDeleteAccount}
                                className="inline-flex items-center px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700"
                            >
                                <Trash className="h-4 w-4 mr-2"/>
                                Supprimer le compte
                            </button>
                        </div>
                    </div>

                    {successMessage && (
                        <div
                            className="mx-4 my-4 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded relative">
                            <span>{successMessage}</span>
                        </div>
                    )}

                    {errors.general && (
                        <div
                            className="mx-4 my-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded relative">
                            <span>{errors.general}</span>
                        </div>
                    )}

                    <div className="border-t border-gray-200">
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 px-4 py-5 sm:p-6">
                            <div className="md:col-span-1">
                                <div className="flex flex-col items-center">
                                    {profile.picture ? (
                                        <img
                                            src={profile.picture}
                                            alt="Profile"
                                            className="h-40 w-40 rounded-full border-4 border-white shadow"
                                        />
                                    ) : (
                                        <div
                                            className="h-40 w-40 flex items-center justify-center text-teal-500 bg-gray-200 rounded-full border-4 border-white shadow text-4xl font-bold"
                                        >
                                            {profile.pseudo
                                                .split(' ')
                                                .map((word) => word[0])
                                                .join('')
                                                .toUpperCase()}
                                        </div>
                                    )}
                                    <h2 className="mt-4 text-xl font-medium text-gray-900">{profile.pseudo}</h2>
                                </div>
                            </div>

                            <div className="md:col-span-2">
                                <form onSubmit={handleUpdateAccount}>
                                    <div className="space-y-6">
                                        <div>
                                            <h3 className="text-lg font-medium text-gray-900">Informations du
                                                compte</h3>
                                            <p className="mt-1 text-sm text-gray-500">Mettre à jour vos informations de
                                                compte</p>
                                        </div>

                                        <div className="grid grid-cols-6 gap-6">
                                            <div className="col-span-6 sm:col-span-4">
                                                <label htmlFor="pseudo"
                                                       className="block text-sm font-medium text-gray-700">
                                                    Pseudo
                                                </label>
                                                <input
                                                    type="text"
                                                    name="pseudo"
                                                    id="pseudo"
                                                    value={updatedInfo.pseudo}
                                                    onChange={handleChange}
                                                    disabled={!isEditing}
                                                    className={`w-full px-4 py-3 rounded-lg border focus:ring-2 focus:ring-teal-500 transition-all ${
                                                        !isEditing ? 'bg-gray-50' : ''
                                                    } ${errors.pseudo ? 'border-red-300' : 'border-gray-300'}`}
                                                />
                                                {errors.pseudo && (
                                                    <p className="mt-2 text-sm text-red-600">{errors.pseudo}</p>
                                                )}
                                            </div>

                                            <div className="col-span-6 sm:col-span-4">
                                                <label htmlFor="email"
                                                       className="block text-sm font-medium text-gray-700">
                                                    Adresse email
                                                </label>
                                                <input
                                                    type="email"
                                                    name="email"
                                                    id="email"
                                                    value={updatedInfo.email}
                                                    onChange={handleChange}
                                                    disabled={!isEditing}
                                                    className={`w-full px-4 py-3 rounded-lg border focus:ring-2 focus:ring-teal-500 transition-all ${
                                                        !isEditing ? 'bg-gray-50' : ''
                                                    } ${errors.email ? 'border-red-300' : 'border-gray-300'}`}
                                                />
                                                {errors.email && (
                                                    <p className="mt-2 text-sm text-red-600">{errors.email}</p>
                                                )}
                                            </div>
                                        </div>

                                        {isEditing && (
                                            <div className="pt-5">
                                                <div className="flex justify-end">
                                                    <button
                                                        type="submit"
                                                        className="inline-flex justify-center items-center py-2 px-4 text-sm font-medium rounded-md text-white bg-teal-600 hover:bg-teal-700"
                                                    >
                                                        <Save className="h-4 w-4 mr-2"/>
                                                        Enregistrer
                                                    </button>
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
}
