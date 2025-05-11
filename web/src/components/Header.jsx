import {LogOutIcon} from 'lucide-react'
import {useAuth} from "../hooks/useAuth";
import {useNavigate} from "react-router-dom";

export default function Header() {
    const {logout, user} = useAuth();
    const navigate = useNavigate();
    const logOut = () => {
        // Call the logout function from the context
        logout();
        // Redirect to the home page
        navigate("/");
    }
    return (
        <>

            <header className="right-0 bg-white shadow-lg border-b-4 border-teal-600">
                <div className="flex items-center justify-between px-4 py-2">
                    <h1 className="text-xl font-bold text-teal-600 mr-4 cursor-pointer"
                        onClick={() => navigate("/")}>Supmap</h1>
                    <div className="flex items-center">

                        {user ? (
                            <>
                                {user.role === "admin" && (
                                    <button
                                        className="text-gray-700 hover:bg-gray-100 p-3 rounded-lg cursor-pointer"
                                        onClick={() => navigate("/statistics")}>
                                        Statistiques
                                    </button>
                                )}

                                <button className="text-teal-600 hover:bg-gray-100 p-3 rounded-lg cursor-pointer"
                                        onClick={() => navigate('/account')}>
                                    Mon compte

                                </button>
                                <button className="text-gray-700 hover:bg-gray-100 p-3 rounded-lg cursor-pointer">
                                    <LogOutIcon size={20} onClick={logOut}/>
                                </button>
                            </>
                        ) : (
                            <>
                                <button className="text-teal-600 hover:bg-gray-100 p-3 rounded-lg cursor-pointer"
                                        onClick={() => navigate('/login')}>Connexion
                                </button>
                                <button className="text-teal-600 hover:bg-gray-100 p-3 rounded-lg cursor-pointer"
                                        onClick={() => navigate('/register')}>Inscription
                                </button>
                            </>
                        )}
                    </div>
                </div>
            </header>
        </>
    )
}

