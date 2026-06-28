# ── Cloud ──────────────────────────────────────────────────────────────────
# Decorative parallax nebula-clouds drifting across the background.
class Cloud
  def initialize
    reset(rand(WINDOW_W))
  end

  def reset(x = 0)
    @x    = x.to_f
    @y    = rand(40..(GROUND_Y - 120)).to_f
    @w    = rand(80..200).to_f
    @h    = rand(20..55).to_f
    @spd  = rand(0.4..1.4)
    @alpha = rand(18..50)
  end

  def update(scroll_speed)
    @x -= @spd * (scroll_speed / SCROLL_SPEED_INIT) * 0.4
    reset if @x + @w < -10
  end

  def draw
    c = Gosu::Color.argb(@alpha, 120, 60, 200)
    # Draw as stacked ellipse-ish rects
    layers = 4
    layers.times do |i|
      t    = i.to_f / (layers - 1)
      lw   = @w * (1.0 - t * 0.35)
      lh   = @h * (1.0 - t * 0.5)
      lx   = @x + (@w - lw) / 2
      ly   = @y + i * (@h / layers.to_f) * 0.4
      Gosu.draw_rect(lx, ly, lw, lh, c, 0)
    end
  end
end
