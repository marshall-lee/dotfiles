require 'fileutils'
require 'tmpdir'

def backup(path)
  stamp = Time.now.strftime '%Y%m%d%H%M%S'
  FileUtils.cp path, "#{path}.#{stamp}.save" if File.exists? path
end

def absolute_path(filename)
  File.expand_path(filename, FileUtils.pwd)
end

def backup_and_link(path, filename)
  path = File.expand_path(path)
  backup path
  FileUtils.ln_sf absolute_path(filename), path
end

def git_clone(repo, to)
  system 'git', 'clone', '--', repo, to
end

def git_tmp_clone(repo, &block)
  Dir.mktmpdir do |tmpdir|
    git_clone(repo, tmpdir)
    FileUtils.cd tmpdir, &block
  end
end

def github_url(str)
  "https://github.com/#{str}.git"
end

def github_clone(str, to)
  git_clone(github_url(str), to)
end

def github_tmp_clone(str, &block)
  git_tmp_clone(github_url(str), &block)
end

task :init do
  FileUtils.cd(__dir__)
end

namespace :git do
  task :ignore => :init do
    path = File.join(Dir.home, '.gitignore_global')
    backup_and_link path, 'gitignore_global'
    cmd = %w(git config --global core.excludesfile)
    previous = `#{cmd.join ' '}`.strip
    if !previous.empty? && previous != path
      $stderr.puts "WARNING: previous value of core.excludesfile global setting is: #{previous}"
    end
    cmd << path
    system(*cmd)
  end
end

task :powerline_fonts => :init do
  github_tmp_clone('powerline/fonts') do
    system './install.sh'
  end
end

task :terminator => [:init, :powerline_fonts] do
  backup_and_link '~/.config/terminator/config', 'terminator_config'
end

task :nethack => :init do
  backup_and_link '~/.nethackrc', 'nethackrc'
end

task :omz_install => :init do
  system 'RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"'
end

task :omz_custom_plugins do
  plugins_path = File.join(Dir.home, '.oh-my-zsh', 'custom', 'plugins')
  FileUtils.mkdir_p plugins_path
  github_clone 'zsh-users/zsh-syntax-highlighting', File.join(plugins_path, 'zsh-syntax-highlighting')
  github_clone 'zsh-users/zsh-completions', File.join(plugins_path, 'zsh-completions')
end

task :omz_custom_theme do
  themes_path = File.join(Dir.home, '.oh-my-zsh', 'custom', 'themes')
  FileUtils.mkdir_p themes_path
  backup_and_link File.join(themes_path, 'agnoster.zsh-theme'), 'agnoster.zsh-theme'
end

task :omz_link_config => :init do
  backup_and_link '~/.zshrc', 'zshrc'
end

task :omz => [:init, :omz_install, :omz_custom_plugins, :omz_custom_theme, :omz_link_config]
