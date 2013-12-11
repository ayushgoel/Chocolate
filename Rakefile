INITIAL_VERSION = '0.1.0'
DEFAULT_SPEC_REPO = 'talk-to'

desc "Release a new version of the Pod"
task :release do
  podspec_path = any_podspec_in_current_dir
  puts "- Found Podspec: " + blue(podspec_path)

  puts "* Linting the podspec"
  sh "pod lib lint"

  puts "* Fetching from remote"
  sh "git fetch"

  local_version = spec_version('master', podspec_path)
  remote_version = spec_version('origin/master', podspec_path)

  if local_version != remote_version
    puts "Error: local (#{local_version}) and remote (#{remote_version}) versions do not match"
    exit
  end

  puts "- Current Version: " + blue(local_version)
  current_version = local_version || INITIAL_VERSION

  new_version = bump_version(current_version)

  version_prompt = "Enter the new version"
  version = ask_user :prompt => version_prompt, :default => new_version
  spec_prompt = "Enter the name of the spec repository"
  spec_repo = ask_user :prompt => spec_prompt, :default => DEFAULT_SPEC_REPO
  exit unless confirm "Are you sure you want to release version #{red(version)} to #{red(spec_repo)}"

  replace_spec_version(podspec_path, current_version, new_version)

  sh "git commit #{podspec_path} -m 'Release #{version}'"
  sh "git tag #{tag}"
  sh "git push origin master"
  sh "git push origin --tags"
  sh "pod push #{spec_repo} #{podspec_path}"
end

def any_podspec_in_current_dir
  `ls -1 *.podspec`.split("\n").first
end

def spec_version(branch, podspec_path)
  require 'cocoapods-core'

  if file_exist_on_branch?(branch, podspec_path)
    remote_spec = eval(`git show #{branch}:#{podspec_path}`)
    remote_spec.version.to_s
  end
end

def file_exist_on_branch?(branch, file_path)
  `git rev-parse --verify --quiet #{branch}:#{file_path} >/dev/null`
  $?.exitstatus == 0
end

def bump_version(version)
  xs = version.split('.')
  xs[-1] = xs[-1].to_i.next.to_s
  xs.join('.')
end

# @param :prompt => String to prompt the user with
#        :default => Optional default value to return if the user presses ENTER
#
def ask_user(**options)
  prompt = options[:prompt] or raise "Prompt is required"
  default = options[:default]
  if default
    print "#{prompt} [#{default}]: "
    result = $stdin.gets.strip
    (!result.empty? && result) || default
  else
    print "#{prompt}: "
    $stdin.gets.strip
  end
end

def confirm prompt
  print "#{prompt}? [y/n] "
  $stdin.gets.strip.downcase == 'y'
end

def colorize(text, color_code)
  if STDOUT.tty?
    "\e[#{color_code}m#{text}\e[0m"
  else
    text
 end
end

def red(text); colorize(text, 31); end
def blue(text); colorize(text, 34); end

def replace_spec_version(podspec_path, current_version, new_version)
  file_gsub!(podspec_path,
             /(s.version\s*=\s*.)#{current_version}(.)/,
             "\\1#{new_version}\\2")
end

def file_gsub!(path, pattern, replacement)
  text = File.read(path)
  text.gsub!(pattern, replacement)
  File.write(path, text)
end