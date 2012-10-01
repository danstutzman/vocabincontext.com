{
    appDir: '../www',
    baseUrl: 'js',
    paths: {
        app: 'app'
    },
    dir: '../www-built',
insertRequire: ['main'],
    modules: [
        {
//            name: 'main',
            name: 'almond',
            include: ['main']
        }
    ]
}
