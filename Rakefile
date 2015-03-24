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

def git_clone(repo)
  Dir.mktmpdir do |tmpdir|
    system 'git', 'clone', '--', repo, tmpdir
    FileUtils.cd tmpdir do
      yield
    end
  end
end

def github_clone(str, &block)
  git_clone("https://github.com/#{str}.git", &block)
end

task :init do
  FileUtils.cd(File.dirname(__FILE__))
end

task :powerline_fonts => :init do
  github_clone('powerline/fonts') do
    system './install.sh'
  end
end

task :terminator => [:init, :powerline_fonts] do
  backup_and_link '~/.config/terminator/config', 'terminator_config'
end

task :nethack => :init do
  backup_and_link '~/.nethackrc', 'nethackrc'
end
