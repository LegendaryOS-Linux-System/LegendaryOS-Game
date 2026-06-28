# ── ScoreStore ─────────────────────────────────────────────────────────────
# Handles loading and saving the high score to disk.
module ScoreStore
  HI_FILE = File.join(Dir.home, ".legendaryos", "game_hiscore.txt").freeze

  def self.load
    return 0 unless File.exist?(HI_FILE)
    File.read(HI_FILE).to_i
  rescue StandardError
    0
  end

  def self.save(score)
    FileUtils.mkdir_p(File.dirname(HI_FILE))
    File.write(HI_FILE, score.to_s)
  rescue StandardError
    nil
  end
end
