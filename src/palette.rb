# ── Color helpers & palette ────────────────────────────────────────────────
def gosu_color(r, g, b, a = 255)
  Gosu::Color.argb(a, r, g, b)
end

PALETTE = {
  bg_top:          gosu_color(10,   0,  28),
  bg_bottom:       gosu_color( 5,   0,  50),
  ground:          gosu_color(30,   0,  80),
  ground_line:     gosu_color(90,   0, 200),
  phoenix_body:    gosu_color(200,   0, 255),
  phoenix_wing:    gosu_color(100,  80, 255),
  phoenix_eye:     gosu_color(255, 240,   0),
  obstacle:        gosu_color( 80,   0, 200),
  obstacle_glow:   gosu_color(160,  30, 255, 120),
  particle_a:      gosu_color(255,  60, 200),
  particle_b:      gosu_color( 80, 160, 255),
  star:            gosu_color(180, 140, 255, 160),
  ui_text:         gosu_color(220, 180, 255),
  ui_accent:       gosu_color(255,  30, 220),
  grid_line:       gosu_color(40,   0, 100, 60),
  flash:           gosu_color(255, 100, 255, 60),
  cloud:           gosu_color(120,  60, 200, 40),
  shield:          gosu_color( 80, 200, 255, 160),
  powerup_shield:  gosu_color( 50, 200, 255),
  powerup_slow:    gosu_color( 50, 255, 140),
  powerup_score:   gosu_color(255, 220,  30),
}.freeze
