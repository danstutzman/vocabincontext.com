{
  appDir: '../www',
  baseUrl: 'js',
  paths: {
    'almond': '../../tools/almond',
    'coffee-script': '../../tools/coffee-script',
    'cs': '../../tools/cs',
    'jquery': '../../vendor/jquery/jquery-1.7.2.min',
    'soundmanager2': '../../vendor/soundmanagerv297a-20120513/script/soundmanager2-nodebug-jsmin'
  },
  dir: '../www-built',
  stubModules: ['cs'],
  modules: [
    {
      name: 'main',
      include: ['almond'],
      exclude: ['coffee-script', 'jquery']
    }
  ]
}
