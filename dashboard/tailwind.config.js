/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                primary: '#D70F64',    // Milap Primary
                secondary: '#F7F7F7',  // Milap Secondary
                dark: '#050505',       // Milap Dark Bg
                surface: '#111111',    // Milap Surface
            }
        },
    },
    plugins: [],
}
