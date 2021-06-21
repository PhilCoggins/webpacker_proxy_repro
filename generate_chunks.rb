Dir.glob("node_modules/lodash/*.js").each_with_index do |file, idx|
  module_name = file.split("/").last
  content = File.read(file)
  export = content.match(/module\.exports = (?<named_export>.*);/)
  if export && !export[:named_export].match(/require/)
    named_export = export[:named_export]
    File.open("app/javascript/files/#{idx}.js", "w") { |file| file.write("import #{named_export} from 'lodash'") }
    File.open("app/javascript/packs/application.js", "a") { |file| file.write("import(/* webpackChunkName: \"#{named_export}\" */ \"../files/#{idx}.js\")\n") }
  end
end

500.times do |idx|
  File.open("app/javascript/files/#{idx}.js", "w") { |file| file.write("import React from 'react'\nimport ReactDOM from 'react-dom'\nimport lodash from 'lodash'\nimport highcharts from 'highcharts'\nimport moment from 'moment'\nimport * as material from '@material-ui/core'\nimport jquery from 'jquery/dist/jquery'") }
  File.open("app/javascript/packs/application.js", "a") { |file| file.write("import(/* webpackChunkName: \"galaxy-#{idx}\" */ \"../files/#{idx}.js\")\n") }
end
