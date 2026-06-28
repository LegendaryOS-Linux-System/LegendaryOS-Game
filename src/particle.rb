# ── Particle ───────────────────────────────────────────────────────────────
class Particle
  attr_reader :dead

  def initialize(x, y, vx, vy, life, color, size)
    @x, @y   = x.to_f, y.to_f
    @vx, @vy = vx.to_f, vy.to_f
    @life    = @max_life = life.to_f
    @color   = color
    @size    = size.to_f
    @dead    = false
  end

  def update
    @x    += @vx
    @y    += @vy
    @vy   += 0.12
    @vx   *= 0.96
    @life -= 1
    @dead  = @life <= 0
  end

  def draw
    alpha = ((@life / @max_life) * 255).clamp(0, 255).to_i
    c = Gosu::Color.argb(alpha, @color.red, @color.green, @color.blue)
    s = @size * (@life / @max_life)
    Gosu.draw_rect(@x - s / 2, @y - s / 2, s, s, c, 3)
  end

  # Burst helper — spawns N particles in a circle from (x, y)
  def self.burst(particles, x, y, n: 18, color_a: nil, color_b: nil, speed: 3.5, life: 30, size: 5)
    color_a ||= PALETTE[:particle_a]
    color_b ||= PALETTE[:particle_b]
    n.times do
      angle = rand * 2 * Math::PI
      spd   = rand(0.5..speed)
      col   = rand < 0.5 ? color_a : color_b
      particles << Particle.new(x, y,
                                Math.cos(angle) * spd,
                                Math.sin(angle) * spd,
                                rand((life * 0.6)..(life * 1.2)).to_f,
                                col,
                                rand((size * 0.5)..(size * 1.3)).to_f)
    end
  end
end
