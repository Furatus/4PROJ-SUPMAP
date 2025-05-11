import './App.css';
import {BrowserRouter as Router, Navigate, Route, Routes} from "react-router-dom";
import MapDisplay from "./components/MapDisplay";
import {APIProvider} from "@vis.gl/react-google-maps";
import SearchPanel from './components/SearchPanel'
import MapControls from './components/MapControls'
import ZoomControls from './components/ZoomControls'
import Header from './components/Header'
import {useState} from "react";
import LoginPage from "./components/LoginPage";
import RegisterPage from "./components/RegisterPage";
import LiveMap from "./components/LiveMap";
import AccountPage from "./components/AccountPage";
import StatisticsPage from "./components/StatisticsPage.jsx";
import {useAuth} from "./hooks/useAuth";

function App() {
    const [startCoordinates, setStartCoordinates] = useState(null)
    const [endCoordinates, setEndCoordinates] = useState(null)
    const [liveMapactive, setLiveMapActive] = useState(false)
    const {user} = useAuth();

    return (
        <div className="h-screen w-full bg-gray-50 relative">

            <Router>
                <Header/>
                <Routes>
                    <Route path='/' element={user ? <Navigate to='/map'/> : <Navigate to='/login'/>}/>
                    <Route path='/map' element={
                        <>
                            <APIProvider apiKey={import.meta.env.VITE_GOOGLE_MAPS_API_KEY}>
                                <MapDisplay/>
                                <MapControls endCoordinates={endCoordinates} liveMapActive={liveMapactive}
                                             setLiveMapActive={setLiveMapActive}/>
                                <ZoomControls/>
                                <LiveMap liveMapActive={liveMapactive}/>

                                <SearchPanel
                                    setStartCoordinates={setStartCoordinates}
                                    setEndCoordinates={setEndCoordinates}
                                    startCoordinates={startCoordinates}
                                    endCoordinates={endCoordinates}/>


                            </APIProvider>
                        </>
                    }/>
                    <Route path='/login' element={<LoginPage/>}/>
                    <Route path='/register' element={<RegisterPage/>}/>
                    <Route path='/account' element={user ? <AccountPage/> : <Navigate to='/login'/>}/>
                    <Route path='/statistics' element={user?.role === 'admin' ? <StatisticsPage/> : <Navigate to='/login'/>}/>
                    <Route path='*' element={<h1 className="text-center text-2xl font-bold text-gray-700 mt-20">Page non trouvée</h1>}/>
                </Routes>
            </Router>
        </div>
    );
}

export default App;
