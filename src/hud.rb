# ── HUD ────────────────────────────────────────────────────────────────────
class Hud
  def initialize
    @font_lg = Gosu::Font.new(36, bold: true)
    @font_sm = Gosu::Font.new(20)
    @font_xs = Gosu::Font.new(15)
    @notifs  = []   # [{text:, t:, max_t:, color:}]
  end

  # Call each frame; text pops up and fades out
  def notify(text, color: PALETTE[:ui_accent])
    @notifs << { text: text, t: 60, max_t: 60, color: color }
  end

  def update
    @notifs.each { |n| n[:t] -= 1 }
    @notifs.reject! { |n| n[:t] <= 0 }
  end

  def draw_game(score, hi, speed, phoenix)
    # Score
    @font_lg.draw_text("#{score}", WINDOW_W - 140, 18, 5,
                        1, 1, PALETTE[:ui_accent])
    @font_xs.draw_text("SCORE", WINDOW_W - 140, 10, 5,
                        1, 1, PALETTE[:ui_text])
    @font_sm.draw_text("BEST #{hi}", WINDOW_W - 140, 56, 5,
                        1, 1, PALETTE[:ui_text])

    # Speed bar
    bar_w = 120
    spd_n = ((speed - SCROLL_SPEED_INIT) / 10.0).clamp(0.0, 1.0)
    Gosu.draw_rect(WINDOW_W - 145, 82, bar_w, 6, gosu_color(40, 0, 80), 5)
    Gosu.draw_rect(WINDOW_W - 145, 82, (bar_w * spd_n).to_i, 6,
                   PALETTE[:ui_accent], 5)
    @font_xs.draw_text("SPD", WINDOW_W - 145, 90, 5,
                        1, 1, PALETTE[:ui_text])

    @font_xs.draw_text("LegendaryOS", 14, 10, 5,
                        1, 1, gosu_color(100, 50, 180, 140))

    # Active power-up indicators
    draw_powerup_hud(phoenix)

    # Pop-up notifications
    draw_notifs
  end

  def draw_menu(hi)
    overlay(180)
    cx = WINDOW_W / 2
    @font_lg.draw_text_rel("⚡ PHOENIX RUNNER", cx, 130, 6,
                            0.5, 0.5, 1, 1, PALETTE[:ui_accent])
    @font_sm.draw_text_rel("LegendaryOS Edition", cx, 178, 6,
                            0.5, 0.5, 1, 1, PALETTE[:ui_text])

    # Controls
    @font_sm.draw_text_rel("Spacja / ↑  —  skocz   (x2 w powietrzu!)", cx, 262, 6,
                            0.5, 0.5, 1, 1, gosu_color(180, 140, 255))
    @font_sm.draw_text_rel("Zbieraj power-upy: 🛡 🐢 ⭐", cx, 298, 6,
                            0.5, 0.5, 1, 1, gosu_color(160, 220, 255))
    @font_sm.draw_text_rel("Naciśnij dowolny klawisz aby zacząć", cx, 348, 6,
                            0.5, 0.5, 1, 1, PALETTE[:ui_text])
    @font_sm.draw_text_rel("BEST: #{hi}", cx, 396, 6,
                            0.5, 0.5, 1, 1, PALETTE[:ui_accent]) if hi > 0
    @font_xs.draw_text_rel("ESC — wyjście", cx, WINDOW_H - 30, 6,
                            0.5, 0.5, 1, 1, gosu_color(100, 80, 160))
  end

  def draw_gameover(score, hi, new_record: false)
    overlay(160)
    cx = WINDOW_W / 2
    @font_lg.draw_text_rel("GAME OVER", cx, 190, 6,
                            0.5, 0.5, 1, 1, gosu_color(255, 60, 180))
    if new_record
      @font_sm.draw_text_rel("✨ NOWY REKORD! ✨", cx, 238, 6,
                              0.5, 0.5, 1, 1, PALETTE[:powerup_score])
    end
    @font_sm.draw_text_rel("Wynik: #{score}", cx, 268, 6,
                            0.5, 0.5, 1, 1, PALETTE[:ui_accent])
    @font_sm.draw_text_rel("Rekord: #{hi}", cx, 303, 6,
                            0.5, 0.5, 1, 1, PALETTE[:ui_text])
    @font_sm.draw_text_rel("Spacja — zagraj ponownie", cx, 368, 6,
                            0.5, 0.5, 1, 1, gosu_color(180, 140, 255))
    @font_xs.draw_text_rel("ESC — wyjście", cx, 418, 6,
                            0.5, 0.5, 1, 1, gosu_color(100, 80, 160))
  end

  private

  def draw_powerup_hud(phoenix)
    return unless phoenix.shielded

    # Shield countdown bar
    bar_w = 80
    frac  = (phoenix.instance_variable_get(:@shield_t).to_f / SHIELD_DURATION).clamp(0, 1)
    Gosu.draw_rect(14, 32, bar_w, 6, gosu_color(20, 60, 80), 5)
    Gosu.draw_rect(14, 32, (bar_w * frac).to_i, 6, PALETTE[:powerup_shield], 5)
    @font_xs.draw_text("SHIELD", 14, 40, 5, 1, 1, PALETTE[:powerup_shield])
  end

  def draw_notifs
    @notifs.each_with_index do |n, i|
      alpha = ((n[:t].to_f / n[:max_t]) * 255).clamp(0, 255).to_i
      c     = Gosu::Color.argb(alpha, n[:color].red, n[:color].green, n[:color].blue)
      y     = WINDOW_H / 2 - 60 - i * 34
      @font_sm.draw_text_rel(n[:text], WINDOW_W / 2, y, 6, 0.5, 0.5, 1, 1, c)
    end
  end

  def overlay(alpha)
    Gosu.draw_rect(0, 0, WINDOW_W, WINDOW_H,
                   Gosu::Color.argb(alpha, 5, 0, 20), 5)
  end
end
