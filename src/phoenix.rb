# ── Phoenix (player) ───────────────────────────────────────────────────────
class Phoenix
  BODY_W      = 38
  BODY_H      = 28
  MAX_JUMPS   = 2   # supports double jump

  attr_reader :x, :y, :alive, :shielded

  def initialize
    @x          = 120.0
    @y          = (GROUND_Y - BODY_H).to_f
    @vy         = 0.0
    @alive      = true
    @on_ground  = true
    @jumps_left = MAX_JUMPS
    @wing_t     = 0
    @flash_t    = 0
    @shielded   = false
    @shield_t   = 0
    @trail      = []   # Array of {x,y,age} for motion trail
  end

  # Returns true if a jump was actually performed
  def jump
    return false if @jumps_left <= 0

    force = @on_ground ? JUMP_FORCE : DOUBLE_JUMP_FORCE
    @vy         = force
    @on_ground  = false
    @jumps_left -= 1
    true
  end

  def activate_shield(duration = SHIELD_DURATION)
    @shielded = true
    @shield_t = duration
  end

  def update(particles)
    @wing_t += 1

    # Motion trail
    @trail.unshift({ x: @x, y: @y, age: 0 })
    @trail.each { |t| t[:age] += 1 }
    @trail.reject! { |t| t[:age] > 8 }

    @vy += GRAVITY
    @y  += @vy

    if @y >= GROUND_Y - BODY_H
      @y          = GROUND_Y - BODY_H
      @vy         = 0.0
      @on_ground  = true
      @jumps_left = MAX_JUMPS
    end

    emit_trail_particles(particles)

    @flash_t  -= 1 if @flash_t > 0

    if @shielded
      @shield_t -= 1
      @shielded  = false if @shield_t <= 0
    end
  end

  def die!(particles)
    return if @shielded  # shield absorbs one hit

    @alive   = false
    @flash_t = 14
    Particle.burst(particles, @x + BODY_W / 2, @y + BODY_H / 2,
                   n: 28, speed: 5.0, life: 36, size: 7)
  end

  def hitbox
    pad = 6
    { x: @x + pad, y: @y + pad, w: BODY_W - pad * 2, h: BODY_H - pad * 2 }
  end

  def draw
    draw_trail
    draw_flash_overlay if @flash_t > 0
    draw_shield_ring   if @shielded

    wing_offset = (Math.sin(@wing_t * 0.25) * 7).to_i
    draw_wing(@x - 4, @y - 14 + wing_offset, 30, 14, flipped: false)
    draw_wing(@x - 4, @y + BODY_H - 4 - wing_offset, 30, 12, flipped: true)

    Gosu.draw_rect(@x, @y, BODY_W, BODY_H, PALETTE[:phoenix_body], 2)
    Gosu.draw_rect(@x + BODY_W - 9, @y + 8,  5, 5, PALETTE[:phoenix_eye], 3)
    Gosu.draw_rect(@x + BODY_W,     @y + 10, 8, 4, gosu_color(255, 180, 0), 3)

    # Double-jump indicator: small pip above phoenix
    unless @on_ground
      remaining = @jumps_left
      remaining.times do |i|
        Gosu.draw_rect(@x + 4 + i * 10, @y - 10, 7, 4,
                       gosu_color(255, 220, 80, 200), 5)
      end
    end
  end

  private

  def emit_trail_particles(particles)
    if rand < 0.55
      col = rand < 0.5 ? PALETTE[:particle_a] : PALETTE[:particle_b]
      particles << Particle.new(
        @x + rand(8),
        @y + BODY_H * 0.6 + rand(8),
        rand(-2.5..-0.5),
        rand(-1.5..0.5),
        rand(14..28).to_f,
        col,
        rand(3..7).to_f
      )
    end
  end

  def draw_trail
    @trail.each_with_index do |t, i|
      next if i.zero?
      alpha = ((1.0 - t[:age] / 8.0) * 60).clamp(0, 60).to_i
      c = Gosu::Color.argb(alpha, 200, 80, 255)
      Gosu.draw_rect(t[:x], t[:y], BODY_W, BODY_H, c, 1)
    end
  end

  def draw_flash_overlay
    alpha = (@flash_t * 15).clamp(0, 180)
    Gosu.draw_rect(@x - 10, @y - 10, BODY_W + 20, BODY_H + 20,
                   Gosu::Color.argb(alpha, 255, 100, 255), 4)
  end

  def draw_shield_ring
    pulse = (Math.sin(@wing_t * 0.15) * 5).to_i
    pad   = 12 + pulse
    alpha = 120 + pulse * 4
    c     = Gosu::Color.argb(alpha.clamp(80, 200), 80, 200, 255)
    Gosu.draw_rect(@x - pad, @y - pad,
                   BODY_W + pad * 2, BODY_H + pad * 2, c, 1)
  end

  def draw_wing(wx, wy, ww, wh, flipped:)
    Gosu.draw_rect(wx, wy, ww, wh, PALETTE[:phoenix_wing], 2)
    tip_x = wx - 10
    tip_y = flipped ? wy + wh - 6 : wy
    Gosu.draw_rect(tip_x, tip_y, 12, 6, gosu_color(130, 100, 255), 2)
  end
end
