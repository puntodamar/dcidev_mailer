Gem::Specification.new do |s|
    s.name = "dcidev_mailer"
    s.version = "0.0.9"
    # s.date = ""
    s.summary = "Commonly used email codes"
    s.description = "Testing phase"
    s.authors = ["Punto Damar P"]
    s.email = ["punto@privyid.tech"]
    s.files = Dir["{bin,lib}/**/*", "README.md"]
    s.require_paths = ["lib"]

    s.add_dependency 'mimemagic', '~> 0.4.3'
    s.add_dependency 'dcidev_utility'
  end
