# README

Roarcast is a Ruby on Rails application that looks up the weather for a given location.

## Getting Started with Local Development

In order to run Roarcast locally for development, be sure to have the version of Ruby
specified by the ".ruby-version" and in the "Gemfile" installed. Once installed, you should
be able to run `bundle install` from the root of the directory to install all the gems
needed to locally run Roarcast. Because we are using TailwindCSS, you'll want to start the
Rails server using `bin/dev` as that will also start the Tailwind process that watches for
Tailwind classes to add and remove to the CSS file.

## Key Libraries

- [TailwindCSS][]: A utility-first system for CSS styling
- [Slim][]: Used for HTML templates
- [RSpec][]: Used for autmated tests
- [Hotwire][]: Used for fast page rendering (Turbo) and simple page interactivity (Stimulus)


## License

Copyright 2024 Bradley Lindsay

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



[Hotwire]: https://hotwired.dev
[RSpec]: http://rspec.info
[Slim]: https://slim-template.github.io
[TailwindCSS]: https://tailwindcss.com
