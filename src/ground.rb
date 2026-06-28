# ── Ground ─────────────────────────────────────────────────────────────────
class Ground
  def initialize
    @offset = 0.0
    @tile   = 60
  end

  def update(speed)
    @offset = (@offset + speed) % @tile
  end

  def draw
    Gosu.draw_rect(0, GROUND_Y, WINDOW_W, WINDOW_H - GROUND_Y,
                   PALETTE[:ground], 1)
    Gosu.draw_rect(0, GROUND_Y, WINDOW_W, 3, PALETTE[:ground_line], 1)
    x = -@offset
    while x < WINDOW_W
      Gosu.draw_rect(x, GROUND_Y + 3, 1, WINDOW_H - GROUND_Y - 3,
                     gosu_color(60, 0, 140, 80), 1)
      x += @tile
    end
  end
end
