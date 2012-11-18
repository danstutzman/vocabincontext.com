{
  appDir: '../backend/public',
  baseUrl: 'js',
  dir: '../backend/public-building',
  stubModules: ['cs'],
  modules: [
    {
      name: 'main',
      include: ['almond'],
      exclude: ['coffee-script', 'jquery']
    }
  ]
}
