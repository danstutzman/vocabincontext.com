{
  appDir: '../backend/public',
  baseUrl: 'js',
  dir: '../backend/public-building',
  stubModules: ['cs'],
  modules: [
    {
      name: 'main',
      include: ['almond', 'swfobject-shim'],
      exclude: ['coffee-script', 'jquery', 'swfobject'],
    },
    {
      name: 'main_with_tests',
      exclude: ['coffee-script', 'jquery', 'swfobject']
    }
  ]
}
