# ── PowerUp ────────────────────────────────────────────────────────────────
# Three kinds:
#   :shield  — absorbs one collision
#   :slow    — temporarily reduces scroll speed
#   :score   — instant score bonus (+25)
class PowerUp
  KINDS = %i[shield slow score].freeze
  SIZE  = 20

  attr_reader :x, :y, :kind, :collected

  def initialize(scroll_speed)
    @kind      = KINDS.sample
    @x         = WINDOW_W + 20.0
    @y         = (GROUND_Y - SIZE - rand(10..120)).to_f
    @spd       = scroll_speed
    @t         = 0
    @collected = false
  end

  def update(scroll_speed)
    @spd = scroll_speed
    @x  -= @spd
    @t  += 1
  end

  def collect!
    @collected = true
  end

  def offscreen?
    @x + SIZE < -10
  end

  def hitbox
    pad = 3
    { x: @x + pad, y: @y + pad, w: SIZE - pad * 2, h: SIZE - pad * 2 }
  end

  def draw
    return if @collected

    hover = (Math.sin(@t * 0.08) * 5).to_i
    y     = @y + hover

    color = case @kind
            when :shield then PALETTE[:powerup_shield]
            when :slow   then PALETTE[:powerup_slow]
            when :score  then PALETTE[:powerup_score]
            end

    # Glow
    glow_alpha = (80 + (Math.sin(@t * 0.12) * 40).to_i).clamp(40, 120)
    glow_c     = Gosu::Color.argb(glow_alpha, color.red, color.green, color.blue)
    Gosu.draw_rect(@x - 6, y - 6, SIZE + 12, SIZE + 12, glow_c, 2)

    # Body
    Gosu.draw_rect(@x, y, SIZE, SIZE, color, 3)

    # Icon drawn with small rects
    draw_icon(@x, y, color)
  end

  private

  def draw_icon(bx, by, _color)
    cx = bx + SIZE / 2
    cy = by + SIZE / 2
    white = gosu_color(255, 255, 255, 200)

    case @kind
    when :shield
      # Simple shield silhouette
      Gosu.draw_rect(cx - 4, cy - 5, 8, 8, white, 4)
      Gosu.draw_rect(cx - 3, cy + 3, 6, 3, white, 4)
    when :slow
      # Clock-like: circle + hands
      Gosu.draw_rect(cx - 4, cy - 4, 8, 8, gosu_color(0, 0, 0, 80), 4)
      Gosu.draw_rect(cx - 1, cy - 3, 2, 4, white, 4)
      Gosu.draw_rect(cx,     cy - 1, 3, 2, white, 4)
    when :score
      # Star-ish cross
      Gosu.draw_rect(cx - 1, cy - 5, 2, 10, white, 4)
      Gosu.draw_rect(cx - 5, cy - 1, 10,  2, white, 4)
    end
  end
end
