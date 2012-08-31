#
# Copyright 2012 Mortar Data Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "mortar/generators/generator_base"
module Mortar
  module Generators
    class ProjectGenerator < Base

      def generate_project(project_name, options)

        set_script_binding(project_name, options)
        mkdir project_name, :verbose => false
        @dest_path = File.join(@dest_path, project_name)
        
        copy_file "README.md", "README.md"
        copy_file "gitignore", ".gitignore"
        copy_file "Gemfile", "Gemfile"
        
        mkdir "pigscripts"
        
        inside "pigscripts" do
          generate_file "pigscript.pig", "#{project_name}.pig"
        end
        
        mkdir "macros"
        
        inside "macros" do
          copy_file "gitkeep", ".gitkeep"
        end
        
        mkdir "udfs"
        
        inside "udfs" do
          mkdir "python"
          inside "python" do
            copy_file "python_udf.py", "#{project_name}.py"
          end
        end
        
        display_run("bundle install")
        `cd #{project_name} && bundle install && cd ..`

      end

      protected

        def set_script_binding(project_name, options)
          options = options
          project_name = project_name
          @script_binding = binding
        end
    end
  end
end