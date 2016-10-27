# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "NAME"
  spec.version       = '1.0'
  spec.authors       = ["Elizabeth Davis"]
  spec.email         = ["davise10@tcnj.edu"]
  spec.summary       = %q{A dynamic web application that keeps track of movies}
  spec.description   = %q{A dynamic web application that allows users to add, edit, delete, and review movies in a database that they create}
  spec.homepage      = "https://github.com/elizabethdavis/movie-database"
  spec.license       = "MIT"

  spec.files         = ['lib/NAME.rb']
  spec.executables   = ['bin/movie.rb']
  spec.test_files    = ['tests/test_NAME.rb']
  spec.require_paths = ["lib"]
end

