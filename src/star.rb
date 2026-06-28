# ── Star ───────────────────────────────────────────────────────────────────
class Star
  def initialize
    reset(rand(WINDOW_W))
  end

  def reset(x = 0)
    @x       = x
    @y       = rand(WINDOW_H - 120).to_f
    @spd     = rand(0.3..1.2)
    @size    = rand(1..3)
    @twinkle = rand(40..120)
    @t       = rand(@twinkle)
  end

  def update(scroll)
    @x -= @spd * (scroll / SCROLL_SPEED_INIT)
    @t += 1
    reset if @x < -4
  end

  def draw
    alpha = (140 + (Math.sin(@t.to_f / @twinkle * 2 * Math::PI) * 80)).clamp(40, 220).to_i
    c = Gosu::Color.argb(alpha, 180, 140, 255)
    Gosu.draw_rect(@x, @y, @size, @size, c, 0)
  end
end
