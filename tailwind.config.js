/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,js}"],
  theme: {
    extend: {
      fontFamily: {
        passiononebold: ['PassionOne-Regular', "sans-serif"],
        openSansBold: ['OpenSansBold', 'sans-serif'],
        openSansBoldItalic: ['OpenSansBoldItalic', 'sans-serif'],
        openSansExtraBold: ['OpenSansExtraBold', 'sans-serif'],
        openSansExtraBoldItalic: ['OpenSansExtraBoldItalic', 'sans-serif'],
        openSansItalic: ['OpenSansItalic', 'sans-serif'],
        openSansLight: ['OpenSansLight', 'sans-serif'],
        openSansLightItalic: ['OpenSansLightItalic', 'sans-serif'],
        openSansRegular: ['OpenSansRegular', 'sans-serif'],
        openSansSemiBold: ['OpenSansSemiBold', 'sans-serif'],
        openSansSemiBoldItalic: ['OpenSansSemiBoldItalic', 'sans-serif'],
        passionOneBlack: ['PassionOneBlack', 'sans-serif'],
        passionOneBold: ['PassionOneBold', 'sans-serif'],
        passionOneRegular: ['PassionOneRegular', 'sans-serif'],
      },
      colors:{
        azulprincipal: "#1931B6",
        azulsecundario: "#172DA7",
        azulsombreado: "#F5F7FF",
        azulescuro:'#002d60',
        laranjaprincipal: "#FD4F04",
        laranjasecundario: "#EE4135",
        laranjasombreado: "#FFDCDA",
        amarelopaleta:"#f5e646",
        amareloprincipal: "#E8D942",
        amarelosecundario: "#EBCE30",
        amarelosombreado: "#FFFCDA",
        verdepaleta:"#7CFF6B",
        verdeprincipal: "#1CDB92",
        verdesecundario: "#1BD08B",
        verdesombreado: "#E3FFF4",
        roxoprincipal: "#6E11B9",
        roxosecundario: "#4E005E",
        roxosombreado: "#F0DEFF",
        vermelhosombreado: "#FFDCDA",
        cinza: "#2F2F2F"
      },
      backgroundImage: {
        'radial-blue-radial': 'radial-gradient(circle, #1CDB92, #1931B6)',
        'radial-blue-radial-ligth':'radial-gradient(circle, #FD4F04, #fc753b)',
        'radial-blue':'radial-gradient(circle, #172DA7, #0C185C)'

      },
      transitionProperty: {
        'opacity': 'opacity',
      }
    },
  },
  plugins: [],
}

