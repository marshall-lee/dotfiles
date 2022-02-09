require 'fileutils'
require 'tmpdir'

def backup(path)
  stamp = Time.now.strftime '%Y%m%d%H%M%S'
  FileUtils.cp path, "#{path}.#{stamp}.save"
end

def absolute_path(filename)
  File.expand_path(filename, FileUtils.pwd)
end

def backup_and_link(path, filename)
  path = File.expand_path(path)
  srcpath = absolute_path(filename)
  need_backup = begin
    File.readlink(path) != srcpath
  rescue Errno::ENOENT, Errno::EINVAL
    File.exists? path
  end
  backup path if need_backup
  FileUtils.ln_sf srcpath, path
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
