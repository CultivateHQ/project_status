exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: 'js/app.js',
      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      // joinTo: {
      //  'js/app.js': /^(web\/static\/js)/,
      //  'js/vendor.js': /^(web\/static\/vendor)/
      // }
      //
      // To change the order of concatenation of files, explictly mention here
      // https://github.com/brunch/brunch/tree/stable/docs#concatenation
      order: {
        before: [
          'web/static/vendor/jquery.js',
          'web/static/vendor/bootstrap.min.js'
        ]
      }
    },
    stylesheets: {
      joinTo: 'css/app.css',

      order: {
        before: [
          'web/static/vendor/font-awesome.min.css'
        ]
      }
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  // Phoenix paths configuration
  paths: {
    // Which directories to watch
      watched: ["deps/phoenix/web/static",
                "deps/phoenix_html/web/static",
                "web/static",
                "test/static"],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/^(web\/static\/vendor)/]
    }
  }
};
