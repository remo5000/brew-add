# frozen_string_literal: true

require 'cli/parser'

###################################################################
#    brew-add lets you treat your Brewfile like a package.json    #
###################################################################
module Homebrew
  module_function

  def add_command_args!
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        A helper to add a module to a Brewfile and install it at the same time.
        Usage: `add` <formula> <options>

        Preference goes to installing via `brew bundle install` and Brewfile location is
        assumed to be ~/Brewfile, unless otherwise specified (using --brewfile=<path>).
      EOS
      flag   '-b',
             '--brewfile=',
             description: 'Use a custom Brewfile, instead of ~/Brewfile'
      switch '-n',
             '--no-bundle-install',
             description: 'Adds file(s) to Brewfile without calling `bundle install`. '\
             'Saves time, but not recommended'
      switch '-f',
             '--force-bundle-install',
             description: 'Forces `brew bundle install` even if no new formulae '\
             'were added to brewfile'
      min_named :formula
    end
  end

  module_function

  def add_command!
    add_command_args!.parse

    brewfile = File.expand_path(args.brewfile || '~/Brewfile')
    if !File.exist?(brewfile)
      warn "Brewfile @ #{brewfile} not found"
      return
    end
    brewfile_contents = `cat #{brewfile}`

    new_formulae_added = false
    args.formulae.each do |formula|
      if brewfile_contents.include? "\"#{formula.name}\""
        puts "#{formula} already exists in Brewfile @ #{brewfile}"
      else
        system("echo 'brew \"#{formula.name}\"' >> #{brewfile}")
        puts "#{formula} added to Brewfile @ #{brewfile}"
        new_formulae_added = true
      end
    end

    # Run brew bundle if new formulae added, but not if no_bundle_install specified
    unless args.force_bundle_install? ||
           (!args.no_bundle_install? && new_formulae_added)
      return
    end

    puts 'echo Installing from brewfile'
    system("cd #{File.dirname(brewfile)} && brew bundle install")
  end
end

Homebrew::add_command!
