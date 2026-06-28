# ── Obstacle ───────────────────────────────────────────────────────────────
class Obstacle
  WIDTHS  = [18, 24, 14, 20].freeze
  HEIGHTS = [38, 55, 70, 45, 90, 60].freeze

  # Obstacle kinds: :single (default pillar), :double (two stacked pillars),
  # :low (wide, short — requires jumping early)
  KINDS = %i[single single single double low].freeze

  attr_reader :x, :y, :w, :h, :passed

  def initialize(scroll_speed)
    @kind = KINDS.sample
    @w    = WIDTHS.sample
    @h    = HEIGHTS.sample
    @x    = WINDOW_W + 20.0
    @spd  = scroll_speed
    @passed = false

    case @kind
    when :double
      @h2 = HEIGHTS.sample
      @y  = (GROUND_Y - @h).to_f
      @x2 = @x + @w + rand(30..50)
      @y2 = (GROUND_Y - @h2).to_f
    when :low
      @w  = rand(50..80)
      @h  = rand(18..28)
      @y  = (GROUND_Y - @h).to_f
    else
      @y = (GROUND_Y - @h).to_f
    end
  end

  def update(scroll_speed)
    @spd = scroll_speed
    @x  -= @spd
    @x2 -= @spd if @kind == :double
  end

  def pass!
    @passed = true
  end

  def offscreen?
    rightmost_x = @kind == :double ? [@x + @w, @x2 + @w].max : @x + @w
    rightmost_x < -10
  end

  # Returns array of hitboxes (one for :single/:low, two for :double)
  def hitboxes
    pad = 5
    boxes = [{ x: @x + pad, y: @y + pad, w: @w - pad * 2, h: @h - pad * 2 }]
    boxes << { x: @x2 + pad, y: @y2 + pad, w: @w - pad * 2, h: @h2 - pad * 2 } if @kind == :double
    boxes
  end

  def draw
    draw_pillar(@x, @y, @w, @h)
    draw_pillar(@x2, @y2, @w, @h2) if @kind == :double
  end

  private

  def draw_pillar(px, py, pw, ph)
    glow_pad = 8
    Gosu.draw_rect(px - glow_pad, py - glow_pad,
                   pw + glow_pad * 2, ph + glow_pad * 2,
                   PALETTE[:obstacle_glow], 1)
    Gosu.draw_rect(px, py, pw, ph, PALETTE[:obstacle], 2)
    Gosu.draw_rect(px, py, pw, 3, gosu_color(160, 60, 255), 2)
    step = 12
    step.step(ph - step, step) do |oy|
      Gosu.draw_rect(px, py + oy, pw, 1, gosu_color(50, 0, 120, 80), 2)
    end
  end
end
