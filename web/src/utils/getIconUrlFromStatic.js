export function getIconUrlFromStatic(svgContent, color = "#000000") {
    // Injecter dynamiquement la couleur dans le SVG
    const coloredSvg = svgContent.replace(/stroke="[^"]*"/g, `stroke="${color}"`);
    const blob = new Blob([coloredSvg], { type: "image/svg+xml" });
    return URL.createObjectURL(blob);
}
