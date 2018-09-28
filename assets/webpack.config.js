const webpack = require('webpack')
const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
      './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      // javascript
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      // css, scss, sass
      {
        test: /\.s?[ac]ss$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader']
      },
      // elm
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack-loader',
        options: {
          debug: true,
          pathToElm: path.resolve(__dirname, 'node_modules', '.bin', 'elm'),
          cwd: __dirname
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.sass' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
    new webpack.ProvidePlugin({
      'videojs': 'video.js',
      'window.videojs': 'video.js'
    })
  ]
});
