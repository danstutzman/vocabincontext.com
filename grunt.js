/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-requirejs');

  // Project configuration.
  grunt.initConfig({
    meta: {
      version: '0.1.0',
      banner: '/*! PROJECT_NAME - v<%= meta.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '* http://PROJECT_WEBSITE/\n' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> ' +
        'YOUR_NAME; Licensed MIT */'
    },
    coffee: {
      app: {
        src: ['www/js/**/*.coffee'],
        dest: 'www/js-compiled-from-coffee',
        options: {
          bare: true
        }
      }
    },
    lint: {
      files: ['grunt.js', 'www/**/*.js']
    },
    jshint: {
      options: {
        curly: false, // for CoffeeScript
        eqeqeq: true,
        immed: false, // for CoffeeScript
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true,
        shadow: true, // for CoffeeScript
        loopfunc: true, // for CoffeeScript
        expr: true // for CoffeeScript
      },
      globals: {
        jQuery: true,
        $: true,
        require: true,
        define: true,
        SoundManager: true,
        console: true,
        describe: true,
        it: true,
        expect: true,
        exports: true
      }
    },
    uglify: {},
    requirejs: {
      appDir: 'www',
      baseUrl: 'js',
      paths: {
        'almond': '../../tools/almond',
        'coffee-script': '../../tools/coffee-script',
        'cs': '../../tools/cs',
        'jquery': '../../vendor/jquery/jquery-1.7.2.min',
        'soundmanager2': '../../vendor/soundmanagerv297a-20120513/script/soundmanager2-nodebug-jsmin'
      },
      dir: 'www-built',
      stubModules: ['cs'],
      modules: [
        {
          name: 'main',
          include: ['almond'],
          exclude: ['coffee-script', 'jquery']
        }
      ]
    }
  });

  // Default task.
  grunt.registerTask('default', 'coffee');
  grunt.registerTask('release', 'coffee requirejs');

};
