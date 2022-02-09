require 'fileutils'
require 'tmpdir'

def absolute_path(filename)
  File.expand_path(filename, FileUtils.pwd)
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
    need_backup = File.exists? path
    need_link = true
  end
  if need_backup
    stamp = Time.now.strftime '%Y%m%d%H%M%S'
    FileUtils.mv path, "#{path}.#{stamp}.save"
  end
  FileUtils.ln_s srcpath, path if need_link
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
    safe_symlink path, 'gitignore_global'
    cmd = %w(git config --global core.excludesfile)
    previous = `#{cmd.join ' '}`.strip
    if !previous.empty? && previous != path
      $stderr.puts "WARNING: previous value of core.excludesfile global setting is: #{previous}"
    end
    cmd << path
    system(*cmd)
  end
end

task :zsh => :init do
  safe_symlink File.join(Dir.home, '.zshrc'), 'zshrc'
  safe_symlink File.join(Dir.home, '.zsh'), 'zsh'
end

task :powerline_fonts => :init do
  github_tmp_clone('powerline/fonts') do
    system './install.sh'
  end
end

task :terminator => [:init, :powerline_fonts] do
  safe_symlink '~/.config/terminator/config', 'terminator_config'
end

task :nethack => :init do
  safe_symlink '~/.nethackrc', 'nethackrc'
end
