import {Map} from "@vis.gl/react-google-maps";
import React from 'react';

const MapDisplay = () => {
    return (

        <Map
            style={{width: '100%', height: '90%'}}
            defaultCenter={{lat: 46.2276, lng: 2.2137}}
            defaultZoom={6}
            gestureHandling={'greedy'}
            disableDefaultUI={true}
            minZoom={5}
            maxZoom={17}
        />

    );
};

export default MapDisplay;