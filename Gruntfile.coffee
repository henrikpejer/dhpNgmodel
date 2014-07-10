module.exports = (grunt)->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')
    coffee:
      build:
        expand: true
        flatten: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'build'
        ext: '.js'
    watch:
      src:
        files: ['src/**/*.coffee'],
        tasks: ['coffee:build']
  )


  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.registerTask "build", ["coffee:build"]