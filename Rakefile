# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

def absolute_path(filename)
  File.expand_path(filename, FileUtils.pwd)
end

def backup(path)
  stamp = Time.now.strftime '%Y%m%d%H%M%S'
  dstpath = "#{path}.#{stamp}.save"
  puts "Backing up #{path} to #{dstpath}"
  FileUtils.mv path, dstpath
end

def safe_symlink(path, filename)
  path = File.expand_path(path)
  srcpath = absolute_path(filename)
  begin
    if File.readlink(path) != srcpath
      need_backup = true
      need_link = true
    else
      need_backup = false
      need_link = false
    end
  rescue Errno::ENOENT, Errno::EINVAL
    need_backup = File.exist? path
    need_link = true
  end
  backup path if need_backup
  FileUtils.ln_s srcpath, path if need_link
end

def git_clone(repo, to, branch: nil)
  cmd = ['git', 'clone']
  cmd.push '--branch', branch if branch
  cmd.push '--', repo, to
  system *cmd, exception: true
end

def git_tmp_clone(repo, **kwargs, &block)
  Dir.mktmpdir do |tmpdir|
    git_clone(repo, tmpdir, **kwargs)
    FileUtils.cd tmpdir, &block
  end
end

def github_url(str)
  "https://github.com/#{str}.git"
end

def github_clone(str, to, **kwargs)
  git_clone(github_url(str), to, **kwargs)
end

def github_tmp_clone(str, **kwargs, &block)
  git_tmp_clone(github_url(str), **kwargs, &block)
end

task :init do
  FileUtils.cd(__dir__)
end

namespace :git do
  desc 'Installs ~/.gitignore_global'
  task :ignore => :init do
    path = File.join(Dir.home, '.gitignore_global')
    safe_symlink path, 'gitignore_global'
    cmd = %w(git config --global core.excludesfile)
    previous = `#{cmd.join ' '}`.strip
    if !previous.empty? && previous != path
      $stderr.puts "WARNING: previous value of core.excludesfile global setting is: #{previous}"
    end
    cmd << path
    system(*cmd, exception: true)
  end
end

desc 'Installs Zsh'
task :zsh => :init do
  safe_symlink File.join(Dir.home, '.zshrc'), 'zshrc'
  safe_symlink File.join(Dir.home, '.zsh'), 'zsh'
end

desc 'Installs Powerline fonts'
task :powerline_fonts => :init do
  github_tmp_clone('powerline/fonts') do
    system './install.sh', exception: true
  end
end

desc 'Installs Terminator config'
task :terminator => [:init, :powerline_fonts] do
  safe_symlink '~/.config/terminator/config', 'terminator_config'
end

desc 'Installs NetHack config'
task :nethack => :init do
  safe_symlink '~/.nethackrc', 'nethackrc'
end

desc 'Installs Alacritty config'
task :alacritty => :init do
  config_dir = File.join(Dir.home, '.config', 'alacritty')
  FileUtils.mkdir_p(config_dir)
  themes_dir = File.join(config_dir, 'themes')
  unless Dir.exist?(themes_dir)
    github_clone 'alacritty/alacritty-theme', themes_dir
  end
  safe_symlink File.join(config_dir, 'alacritty.toml'), 'alacritty.toml'
end

desc 'Installs tmux config'
task :tmux => :init do
  safe_symlink File.join(Dir.home, ".tmux.conf"), "tmux.conf"
end

namespace :spacemacs do
  desc 'Installs Spacemacs'
  task :install => :init do
    destpath = File.join(Dir.home, '.emacs.d')
    need_clone = true
    if File.exist? destpath
      if Dir.exist? File.join(destpath, 'layers', '+spacemacs')
        need_clone = false
        puts 'Spacemacs directory ~/.emacs.d already exists'
      else
        puts "Directory ~/.emacs.d exists but it doesn't look like a Spacemacs installation"
        backup destpath
      end
    end
    github_clone 'syl20bnr/spacemacs', destpath, branch: 'develop' if need_clone
  end

  desc "Sets up my weird config (don't do this)"
  task :my => :init do
    safe_symlink '~/.spacemacs', 'spacemacs'
  end
end

namespace :brew do
  def brew_bundle(file)
    system 'brew', 'bundle', '--file', file, exception: true
  end

  def brew_uninstall(formula)
    system 'brew', 'uninstall', formula, exception: true
  end

  def brew_reinstall(formula)
    system 'brew', 'reinstall', formula, exception: true
  end

  def brew_link(formula)
    system 'brew', 'link', formula, exception: true
  end

  def brew_unlink(formula, skip_errors: false)
    cmd = +"brew unlink #{formula}"
    kwargs = { exception: true }
    if skip_errors
      cmd << " 2>/dev/null"
      kwargs[:exception] = false
    end
    system cmd, **kwargs
  end

  desc 'Installs common brew formulae'
  task :install do
    brew_bundle absolute_path('Brewfile')
  end

  desc 'Installs brew casks'
  task :install_casks do
    brew_bundle absolute_path('Brewfile-casks')
  end

  # Emacs tasks for installing and managing versions

  def brew_emacs_app_path(version)
    brew_prefix = `brew --prefix emacs-plus@#{version}`.strip
    File.join(brew_prefix, "Emacs.app")
  end

  def brew_link_emacs(version)
    brew_link "emacs-plus@#{version}"
    app_path = brew_emacs_app_path(version)
    puts "Linking #{app_path} to /Applications/#{File.basename(app_path)}"
    FileUtils.ln_sf(app_path, "/Applications")
  end

  emacs_versions = ['29', '30', '31']

  define_method(:brew_unlink_emacs) do
    emacs_versions.map do |ver|
      brew_unlink "emacs-plus@#{ver}", skip_errors: true
    end
    FileUtils.rm_f "/Applications/Emacs.app"
  end

  desc 'Unlinks ALL versions of Emacs'
  task :unlink_emacs => :init do
    brew_unlink_emacs
  end

  emacs_versions.each do |version|
    desc "Installs Emacs version #{version}"
    task "install_emacs#{version}" => [:init] do
      brew_bundle absolute_path("Brewfile-emacs@#{version}")
      brew_unlink_emacs
      brew_link_emacs version

      # See https://github.com/d12frosted/homebrew-emacs-plus/issues/742
      if RbConfig::CONFIG["host_cpu"] == "x86_64"
        app_path = brew_emacs_app_path(version)
        puts "Signing the app #{app_path}"
        system "sudo", "codesign", "--force", "--deep", "--sign", "-", app_path
      end
    end

    desc "Reinstalls Emacs version #{version}"
    task "reinstall_emacs#{version}" => [:init, :"uninstall_emacs#{version}", :"install_emacs#{version}"]

    desc "Uninstalls Emacs version #{version}"
    task "uninstall_emacs#{version}" => :init do
      brew_uninstall "emacs-plus@#{version}"
    end

    desc "Links Emacs version #{version}"
    task "link_emacs#{version}" => :init do
      brew_unlink_emacs
      brew_link_emacs version
    end
  end
end
