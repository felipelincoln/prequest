module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: {
    content: [
      "../lib/prequest_web/live/**/*.html.leex",
      "../lib/prequest_web/templates/**/*.html.leex",
      "../lib/prequest_web/templates/**/*.html.eex",
      "../lib/prequest_web/views/**/*.ex",
    ],
    options: {
      whitelistPatterns: [/^bg-/]
    }
  },
  theme: {
    extend: {
      fontFamily: {
        'sans': '"Lato", "Helvetica Neue", Helvetica, Arial, sans-serif'
      }
    },
  },
  variants: {
    display: ['responsive', 'group-focus'],
    flexGrow: ['responsive', 'last']
  },
  plugins: [],
}
