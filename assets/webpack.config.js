const path = require('path');

module.exports = function(env) {
  const production = process.env.NODE_ENV === 'production';
  return {
    devtool: production ? 'source-maps' : 'eval',
    entry: './js/app.ts',
    output: {
      path: path.resolve(__dirname, '../priv/static/js'),
      filename: 'app.js',
      publicPath: '/',
    },
    module: {
      rules: [
        {
          test: /\.ts$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
          },
        },
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
          },
        },
      ],
    },
    resolve: {
      modules: ['node_modules', path.resolve(__dirname, 'js')],
      extensions: ['.js', '.ts'],
    },
  };
};
