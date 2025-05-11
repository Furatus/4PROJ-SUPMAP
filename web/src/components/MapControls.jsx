import {MapIcon, Share2Icon} from 'lucide-react'
import {Fragment, useState} from 'react';
import QRCode from 'react-qr-code';
import {Dialog, Transition} from "@headlessui/react";

export default function MapControls({endCoordinates, liveMapActive, setLiveMapActive}) {
    const [open, setOpen] = useState(false);
    const url = endCoordinates ? `https://supmap.com/destination?lat=${endCoordinates.lat}&lon=${endCoordinates.lon}` : '';
    const [copied, setCopied] = useState(false);


    const handleShare = () => {
        setOpen(true);
    }

    const handleCopyToClipBoard = () => {
        if (url) {
            navigator.clipboard.writeText(url).then(() => {
                setCopied(true);
                setTimeout(() => setCopied(false), 2000);
            });
        }
    };
    const handleLiveMap = () => {
        setLiveMapActive(!liveMapActive)
    }

    return <>
        <div className="absolute right-2 top-16 py-2 flex flex-col gap-2">
            <button
                className={`p-3 rounded-lg shadow-lg ${liveMapActive ? 'bg-teal-600 text-white' : 'bg-white hover:bg-gray-100 text-gray-700'}`}
                onClick={handleLiveMap}
                aria-label="Live Map"
            >
                <MapIcon size={20}/>
            </button>

            {endCoordinates && <button
                className="bg-white hover:bg-gray-100 text-gray-700 shadow-lg p-3 rounded-lg"
                onClick={handleShare}
                aria-label="Partager la localisation"
            >
                <Share2Icon size={20}/>
            </button>}
        </div>
        {/* Modal pour partager la localisation */}
        <Transition appear show={open} as={Fragment}>
            <Dialog as="div" className="fixed inset-0 z-10 overflow-y-auto" onClose={() => setOpen(false)}>
                <div className="min-h-screen px-4 text-center">
                    <Transition.Child
                        as={Fragment}
                        enter="ease-out duration-300"
                        enterFrom="opacity-0 scale-95"
                        enterTo="opacity-100 scale-100"
                        leave="ease-in duration-200"
                        leaveFrom="opacity-100 scale-100"
                        leaveTo="opacity-0 scale-95"
                    >
                        <Dialog.Panel className="bg-white p-6 rounded-lg shadow-lg max-w-md mx-auto">
                            <Dialog.Title className="text-lg font-semibold text-center">
                                Scannez ce QR Code
                            </Dialog.Title>
                            <div className="flex justify-center my-4">
                                <QRCode value={url} size={200}/>
                            </div>
                            <p className="mt-2 text-sm text-gray-500 text-center break-words">
                                {url}
                            </p>
                            <div className="flex justify-center mt-4">
                                <button
                                    className="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded"
                                    onClick={handleCopyToClipBoard}
                                >
                                    {copied ? "Lien copié !" : "Copier le lien"}
                                </button>
                            </div>
                        </Dialog.Panel>
                    </Transition.Child>
                </div>
            </Dialog>
        </Transition>
    </>;
}
