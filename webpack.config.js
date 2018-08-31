const path = require('path')
const HtmlPlugin = require('html-webpack-plugin')

module.exports = {
  entry: {
    app: path.join(__dirname, './src/index.ts'),
  },

  output: {
    filename: 'bundle.js',
    path: path.join(__dirname, 'dist'),
  },

  mode: process.env.NODE_ENV || 'development',

  watchOptions: {
    ignored: /node_modules|dist|\.js/g,
  },

  devtool: 'inline-source-map',

  resolve: {
    extensions: ['.mjs', '.ts', '.js', '.json'],
  },

  module: {
    rules: [
      {
        test: /\.mjs$/,
        include: /node_modules/,
        type: "javascript/auto",
      },
      {
        test: /Server\/Worker\.ts$/i,
        use: {
          loader: 'service-worker-loader',
          options: {
            filename: 'sw.js',
          },
        }
      },
      {
        test: /\.ts$/,
        use: 'awesome-typescript-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.elm$/,
        exclude: /elm-stuff/,
        use: {
          loader: 'elm-webpack-loader',
          options: {
            forceWatch: true,
            debug: true
          }
        },
      },
      {
        test: /\.graphql$/,
        use: 'graphql-import-loader',
        exclude: /node_modules/,
      }
    ],
  },

  serve: {
    hotClient: false,
  },

  plugins: [
    new HtmlPlugin()
  ],
}
