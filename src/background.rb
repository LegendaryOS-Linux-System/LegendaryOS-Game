# ── Background ─────────────────────────────────────────────────────────────
class Background
  def draw
    row_h = 4
    rows  = (GROUND_Y / row_h).ceil
    rows.times do |i|
      t = i.to_f / rows
      r = (10 + t * 20).to_i
      b = (28 + t * 22).to_i
      Gosu.draw_rect(0, i * row_h, WINDOW_W, row_h, gosu_color(r, 0, b), 0)
    end
    (1..6).each do |i|
      y = (GROUND_Y * i / 7.0).to_i
      Gosu.draw_rect(0, y, WINDOW_W, 1, PALETTE[:grid_line], 0)
    end
  end
end
