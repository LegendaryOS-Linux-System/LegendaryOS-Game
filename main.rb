LEGENDARY_GEM_HOME = File.join(Dir.home, ".legendaryos", "venvs", "legendary", "gems")

begin
  require "gosu"
rescue LoadError
  venv_lib_dirs = Dir.glob(File.join(LEGENDARY_GEM_HOME, "gems", "gosu-*", "lib"))
  if venv_lib_dirs.empty?
    warn "\e[1m\e[91m✘  Gosu nie jest zainstalowany.\e[0m"
    warn "\e[90m   Uruchom: \e[1mlegendary game\e[0m\e[90m — zainstaluje automatycznie.\e[0m"
    warn "\e[90m   Lub ręcznie: GEM_HOME=#{LEGENDARY_GEM_HOME} gem install gosu\e[0m"
    exit 1
  end

  venv_lib_dirs.each { |d| $LOAD_PATH.unshift(d) unless $LOAD_PATH.include?(d) }
  Gem.paths = { "GEM_HOME" => LEGENDARY_GEM_HOME, "GEM_PATH" => LEGENDARY_GEM_HOME }

  begin
    require "gosu"
  rescue LoadError => e
    warn "\e[1m\e[91m✘  Nie można załadować Gosu z venv: #{e.message}\e[0m"
    warn "\e[90m   GEM_HOME: #{LEGENDARY_GEM_HOME}\e[0m"
    warn "\e[90m   Spróbuj: GEM_HOME=#{LEGENDARY_GEM_HOME} gem install gosu\e[0m"
    exit 1
  end
end

require "fileutils"

ROOT_DIR = __dir__

require_relative "src/constants"
require_relative "src/palette"
require_relative "src/particle"
require_relative "src/star"
require_relative "src/cloud"
require_relative "src/obstacle"
require_relative "src/powerup"
require_relative "src/phoenix"
require_relative "src/ground"
require_relative "src/background"
require_relative "src/hud"
require_relative "src/score_store"
require_relative "src/game_window"

PhoenixRunnerWindow.new.show
