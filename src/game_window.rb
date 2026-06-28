# ── PhoenixRunnerWindow ────────────────────────────────────────────────────
class PhoenixRunnerWindow < Gosu::Window
  def initialize
    super(WINDOW_W, WINDOW_H, false)
    self.caption = GAME_TITLE

    @bg       = Background.new
    @hud      = Hud.new
    @hi_score = ScoreStore.load
    @new_record = false

    reset_game
    @state = :menu
  end

  # ── Gosu callbacks ──────────────────────────────────────────────────────

  def update
    @hud.update

    case @state
    when :menu     then update_menu
    when :playing  then update_playing
    when :gameover then update_gameover
    end

    scroll = effective_scroll_speed
    @stars.each  { |s| s.update(scroll) }
    @clouds.each { |c| c.update(scroll) }
  end

  def draw
    @bg.draw
    @clouds.each(&:draw)
    @stars.each(&:draw)
    @ground.draw

    case @state
    when :menu
      @phoenix.draw
      @hud.draw_menu(@hi_score)

    when :playing
      @powerups.each(&:draw)
      @obstacles.each(&:draw)
      @particles.each(&:draw)
      @phoenix.draw
      @hud.draw_game(@score, @hi_score, @scroll_speed, @phoenix)

    when :gameover
      @powerups.each(&:draw)
      @obstacles.each(&:draw)
      @particles.each(&:draw)
      @phoenix.draw
      @hud.draw_game(@score, @hi_score, @scroll_speed, @phoenix)
      @hud.draw_gameover(@score, @hi_score, new_record: @new_record)
    end
  end

  def button_down(id)
    close if id == Gosu::KB_ESCAPE

    case @state
    when :menu     then start_game if any_action_key?(id)
    when :playing  then @phoenix.jump if jump_key?(id)
    when :gameover then start_game if id == Gosu::KB_SPACE
    end
  end

  private

  # ── Game state management ───────────────────────────────────────────────

  def start_game
    reset_game
    @state = :playing
  end

  def reset_game
    @phoenix      = Phoenix.new
    @ground       = Ground.new
    @obstacles    = []
    @particles    = []
    @powerups     = []
    @stars        = Array.new(70) { Star.new }
    @clouds       = Array.new(8)  { Cloud.new }
    @score        = 0
    @frame        = 0
    @scroll_speed = SCROLL_SPEED_INIT
    @slow_timer   = 0
    @spawn_timer  = spawn_interval
    @new_record   = false
  end

  # ── Update helpers ──────────────────────────────────────────────────────

  def update_menu
    @phoenix.update(@particles)
    @particles.reject!(&:dead)
    @particles.each(&:update)
    @ground.update(SCROLL_SPEED_INIT)
  end

  def update_playing
    @frame        += 1
    @scroll_speed += SCROLL_ACCEL
    @score         = @frame / 6

    spd = effective_scroll_speed
    @ground.update(spd)
    @phoenix.update(@particles)

    # Obstacle spawning
    @spawn_timer -= 1
    if @spawn_timer <= 0
      @obstacles << Obstacle.new(spd)
      @spawn_timer = spawn_interval
    end

    @obstacles.each  { |o| o.update(spd) }
    @obstacles.reject!(&:offscreen?)
    @obstacles.each  { |o| o.pass! if !o.passed && o.x + o.w < @phoenix.x }

    # Power-up spawning & updates
    maybe_spawn_powerup(spd)
    @powerups.each { |p| p.update(spd) }
    @powerups.reject! { |p| p.offscreen? || p.collected }

    # Particles
    @particles.each(&:update)
    @particles.reject!(&:dead)

    # Slow timer countdown
    @slow_timer -= 1 if @slow_timer > 0

    # Collision: phoenix ↔ obstacles
    ph = @phoenix.hitbox
    @obstacles.each do |obs|
      obs.hitboxes.each do |ob|
        next unless rects_overlap?(ph, ob)

        @phoenix.die!(@particles)
        unless @phoenix.alive
          handle_death
          return
        end
      end
    end

    # Collision: phoenix ↔ power-ups
    @powerups.each do |pu|
      next if pu.collected
      next unless rects_overlap?(ph, pu.hitbox)

      apply_powerup(pu)
      pu.collect!
    end
  end

  def update_gameover
    @particles.each(&:update)
    @particles.reject!(&:dead)
    @phoenix.update(@particles)
  end

  # ── Collision ───────────────────────────────────────────────────────────

  def rects_overlap?(a, b)
    a[:x] < b[:x] + b[:w] &&
      a[:x] + a[:w] > b[:x] &&
      a[:y] < b[:y] + b[:h] &&
      a[:y] + a[:h] > b[:y]
  end

  # ── Death ────────────────────────────────────────────────────────────────

  def handle_death
    if @score > @hi_score
      @hi_score   = @score
      @new_record = true
      ScoreStore.save(@hi_score)
    end
    @state = :gameover
  end

  # ── Power-up logic ───────────────────────────────────────────────────────

  def maybe_spawn_powerup(spd)
    return unless rand < POWERUP_SPAWN_CHANCE

    @powerups << PowerUp.new(spd)
  end

  def apply_powerup(pu)
    case pu.kind
    when :shield
      @phoenix.activate_shield
      @hud.notify("SHIELD AKTYWNY!", color: PALETTE[:powerup_shield])
    when :slow
      @slow_timer = SLOW_DURATION
      @hud.notify("SPOWOLNIENIE!", color: PALETTE[:powerup_slow])
    when :score
      @score += 25
      @frame  = @score * 6   # keep frame in sync
      @hud.notify("+25 PKT", color: PALETTE[:powerup_score])
    end
    Particle.burst(@particles, pu.x + PowerUp::SIZE / 2, pu.y + PowerUp::SIZE / 2,
                   n: 14, speed: 3.0, life: 24, size: 5)
  end

  # ── Helpers ─────────────────────────────────────────────────────────────

  def effective_scroll_speed
    @slow_timer > 0 ? @scroll_speed * SLOW_FACTOR : @scroll_speed
  end

  def spawn_interval
    base      = 90
    min       = 38
    spd_bonus = ((@scroll_speed - SCROLL_SPEED_INIT) * 2.5).to_i
    [base - spd_bonus, min].max + rand(30)
  end

  def jump_key?(id)
    [Gosu::KB_SPACE, Gosu::KB_UP, Gosu::KB_W].include?(id)
  end

  def any_action_key?(id)
    jump_key?(id) || id == Gosu::KB_RETURN || id == Gosu::KB_NUMPAD_ENTER
  end
end
