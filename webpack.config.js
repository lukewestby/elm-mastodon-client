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
        test: /server\/index\.ts/,
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
    ],
  },

  serve: {
    hotClient: false,
  },

  plugins: [
    new HtmlPlugin()
  ],
}
