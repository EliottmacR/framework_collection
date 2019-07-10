-- framework for Collection project
--
--

-- here's some values the framework gives out:
-- - _difficulty : 0 is super easy, 100 should be near-impossible (we'll scale it internally - game 25 would have a difficulty of 100)

-- here's what the player should define (as global)
-- - _title: name of the game
-- - _description: a one sentence description/instruction for the game
-- - _palette : table of indexes pointing to which colors you want in the full palette (up to 8)
-- - _controls : table listing the controls you're using in this game
-- - 
-- - _init() : callback called on loading the game
-- - _update() : callback called every frame to update the game
-- - _draw() : callback called every frame to draw the game
--

-- Chain general info
  -- Going from a game to another / Go To Game : "gtg"
  -- "global_score" and "battery" are to be passed into the parameters when gtg. if it's the first link in chain, the framework will go with default value (0 and 100 respectively)
  -- The game_registry is now at "https://raw.githubusercontent.com/TRASEVOL-DOG/Collection/master/game_registery" and should be moved on later, maybe on the leaderboard repo.
  -- game_previews contains the game previews for the game over screen, inited in chain_init()



-- Notes on control system:
-- directions map to arrow keys, WASD, and the controller left stick
-- A and B map to Z and X, enter and rshift, and the controller A and B buttons
-- cursor position is mouse poistion, and/or simulated cursor controlled with controller right stick
-- cursor clics are mouse lb and rb, and controller right bumper and trigger.



-- Todo:
----- forbid all sugar functions except some
---
----- load audio assets
---
----- shader?
---
----- control screen
--- control descriptions are stored in ctrl_descriptions
---  ^ it goes {{inputs} = "desc"} -> inputs are all the inputs that have the same description
---
----- pause/settings button + panel
---
----- game over screen
---
----- ui bar
---


if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    "sugarcoat/sugarcoat.lua",
    "glyphs.png",
    "HungryPro.ttf"
  })
end


require(game_list.lua)

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)

-- forward declarations (local):
local load_palette, load_controls
local update_controls
local update_controls_screen, draw_controls_screen

local in_controls, in_pause, in_gameover
local ctrl_descriptions, ctrl_active
local light_table

function love.load()
  
  if first_time_launch then -- global variable in .castle linked main 
  
    love.update = function () end
    love.draw = function () end
    
  else -- inside collection loop of game.

    init_sugar("Remy & Eliott's Collection", 256, 192, 3)
    
    -- setting default game info
    _title = _title or "[please set a title!]"
    _description = _description or "[please set a description!]"
    _palette = _palette or { 0, 1, 3, 19, 27, 28, 29 } -- greyish gradient
    _controls = _controls or {}
    
    -- loading resources
    load_palette()
    load_font("HungryPro.ttf", 16, "main", true)
    init_glyphs()
    load_controls()
    
    init_chain()
    
    init_controls_screen()
  
  end
  
  if _init then _init() end

end

function love.update()
  update_controls()

  if in_controls then update_controls_screen() return end

  if _update then _update() end
end

function love.draw()
  if _draw then _draw() end
  
  if in_controls then draw_controls_screen() return end
end



-- controls screen

function init_controls_screen()
  in_controls = 99
  
  -- define color_0, color_1 and color_2 here
  
  
end

function update_controls_screen()
  if in_controls == 99 then
    if btnp("start") then
      in_controls = 1
      in_controls = false
    end
  elseif in_controls then
    in_controls = in_controls - dt()
    
    if in_controls <= 0 then
      in_controls = false
    end
  end
end

function draw_controls_screen()
  local lt = light_table
  cls(lt[1])
  
  printp(0x0000, 0x0100, 0x0200, 0x0000)
  printp_color(lt[#lt], lt[flr(#lt/2)], 0)
  
  local x,y = 0, 8
  local space1, space2 = 16, 28
  
  x = (screen_w() - str_px_width(_title)) / 2
  pprint(_title, x, y)
  
  x = (screen_w() - str_px_width(_description)) / 2
  y = y + space2
  pprint(_description, x, y)

  y = y + space2
  for _, d in ipairs(ctrl_descriptions) do
    local str = ""
    for _, v in ipairs(d[1]) do
      str = str..v..", "
    end
    
    str = str:sub(1, #str-2).." : "..d[2]
    
    x = (screen_w() - str_px_width(str)) / 2
    
    pprint(str, x, y)
    
    y = y + space1
  end

  -- draw controls
  -- add controls sprite
  
  -- "press start to continue"
  
  if t()%1 < 0.75 then
    local str = "Press START to continue!"
    x = (screen_w() - str_px_width(str)) / 2
    y = screen_h() - 16
    pprint(str, x, y)
  end
end




-- palette & glyphs

function load_palette()
  local full_palette, palette = {  -- "Glassworks", by Trasevol_Dog B-)
    0x000000, 0x000020, 0x330818, 0x1a0f4d,
    0x990036, 0x660000, 0x992e00, 0x332708,
    0x001c12, 0x00591b, 0x118f45, 0x998a26,
    0xff2600, 0xff8c00, 0xffff33, 0x6de622,
    0x0fff9f, 0x00ace6, 0x2e00ff, 0x772e99,
    0xb319ff, 0xff4f75, 0xff9999, 0xffc8a3,
    0xfeffad, 0xb1ff96, 0x99fff5, 0xbcb6e3,
    0xebebeb, 0xffffff
  }, {}

  if not _palette then _palette = {0, 29} end
  for i,c in ipairs(_palette) do
    palette[i] = full_palette[c+1]
  end
  
  local light_ref = { 0, 5, 1, 2, 4, 3, 8, 12, 7, 6, 18, 19, 20, 9, 21, 13, 11, 10, 22, 17, 15, 23, 27, 14, 16, 24, 25, 28, 26, 29 }
  
  light_table = {}
  
  for i,lc in ipairs(light_ref) do
    for j,c in ipairs(_palette) do
      if c == lc then
        add(light_table, j-1)
      end
    end
  end
  
  use_palette(palette)
end

function init_glyphs()
  load_png("glyphs", "glyphs.png", { 0x000000, 0xffffff, 0x888888}, true)
  spritesheet_grid(16, 16)
  palt(0, true)
end

function glyph(n, x, y, width, height, angle, color_a, color_b)
  width = width or 16
  height = height or 16
  angle = angle or 0

  pal(1, color_a or 0)
  pal(2, color_b or 0)
  aspr(n, x, y, angle, 1, 1, 0.5, 0.5, width/16, height/16)
  pal(1, 1)
  pal(2, 2)
end

function outlined_glyph(n, x, y, width, height, angle, color_a, color_b, outline_color)
  width = width or 16
  height = height or 16
  angle = angle or 0

  pal(1, outline_color)
  pal(2, outline_color)
  aspr(n, x-1, y, angle, 1, 1, 0.5, 0.5, width/16, height/16)
  aspr(n, x+1, y, angle, 1, 1, 0.5, 0.5, width/16, height/16)
  aspr(n, x, y-1, angle, 1, 1, 0.5, 0.5, width/16, height/16)
  aspr(n, x, y+1, angle, 1, 1, 0.5, 0.5, width/16, height/16)

  pal(1, color_a or 0)
  pal(2, color_b or 0)
  aspr(n, x, y, angle, 1, 1, 0.5, 0.5, width/16, height/16)
  pal(1, 1)
  pal(2, 2)
end




-- controls system

local cur_x, cur_y, m_x, m_y = 0, 0, 0, 0
local s_btn, s_btnv = btn, btnv
function update_controls()
  for k, d in pairs(ctrl_active) do
    d.pstate = d.state
    
    if k == "left" then
      d.value = s_btnv("left") - min(s_btnv("lx_axis"), 0)
      d.state = d.value > 0
    elseif k == "right" then
      d.value = s_btnv("right") + max(s_btnv("lx_axis"), 0)
      d.state = d.value > 0
    elseif k == "up" then
      d.value = s_btnv("up") - min(s_btnv("ly_axis"), 0)
      d.state = d.value > 0
    elseif k == "down" then
      d.value = s_btnv("down") + max(s_btnv("ly_axis"), 0)
      d.state = d.value > 0
    elseif k == "cur_x" then
      d.value = d.value + 3* s_btnv("rx_axis")
      d.state = s_btn("rx_axis")
      
      local n_x = s_btnv("cur_x")
      if n_x ~= m_x then
        m_x, d.value = n_x, n_x
        d.state = true
      end
    elseif k == "cur_y" then
      d.value = d.value + 3* s_btnv("ry_axis")
      d.state = s_btn("ry_axis")
      
      local n_y = s_btnv("cur_y")
      if n_y ~= m_y then
        m_y, d.value = n_y, n_y
        d.state = true
      end
    else
      d.value = s_btnv(k)
      d.state = s_btn(k)
    end
  end
end

function btn(k)
  local d = ctrl_active[k]
  return d and d.state
end

function btnp(k)
  local d = ctrl_active[k]
  return d and d.state and not d.pstate
end

function btnr(k)
  local d = ctrl_active[k]
  return d and d.pstate and not d.state
end

function btnv(k)
  local d = ctrl_active[k]
  return d and d.value or 0
end

function load_controls()
  local bindings = {
    left   = { input_id("keyboard_scancode", "left"),
               input_id("keyboard_scancode", "a"),
               input_id("controller_button", "dpleft") },
    right  = { input_id("keyboard_scancode", "right"),
               input_id("keyboard_scancode", "d"),
               input_id("controller_button", "dpright") },
    up     = { input_id("keyboard_scancode", "up"),
               input_id("keyboard_scancode", "w"),
               input_id("controller_button", "dpup") },
    down   = { input_id("keyboard_scancode", "down"),
               input_id("keyboard_scancode", "s"),
               input_id("controller_button", "dpdown") },
    
    lx_axis = { input_id("controller_axis", "leftx") },
    ly_axis = { input_id("controller_axis", "lefty") },
    
    A =      { input_id("keyboard_scancode", "z"),
               input_id("keyboard_scancode", "rshift"),
               input_id("controller_button", "a") },
    B =      { input_id("keyboard_scancode", "x"),
               input_id("keyboard_scancode", "return"),
               input_id("controller_button", "b") },

    cur_x  = { input_id("mouse_position", "x") },
    cur_y  = { input_id("mouse_position", "y") },
    
    cur_lb = { input_id("mouse_button", "lb"),
               input_id("controller_button", "rightshoulder") },
    cur_rb = { input_id("mouse_button", "rb"),
               input_id("controller_axis", "triggerright") },

    rx_axis = { input_id("controller_axis", "rightx") },
    ry_axis = { input_id("controller_axis", "righty") }
  }
  
  player_assign_ctrlr(0, 0)
  
  ctrl_descriptions, ctrl_active = {}, {}
  
  for k, desc in pairs(_controls) do
    local b = true
    for _,v in pairs(ctrl_descriptions) do
      if v[2] == desc then
        b = false
        add(v[1], k)
      end
    end
    
    if b then
      add(ctrl_descriptions, { {k}, desc})
    end
    
    ctrl_active[k] = { state = false, pstate = false, value = 0}
    
    register_btn(k, 0, bindings[k])
    
    if k == "left" or k == "right" then
      register_btn("lx_axis", 0, bindings.lx_axis)
    end
    
    if k == "up" or k == "down" then
      register_btn("ly_axis", 0, bindings.ly_axis)
    end
    
    if k == "cur_x" then
      register_btn("rx_axis", 0, bindings.rx_axis)
    end
    
    if k == "cur_y" then
      register_btn("ry_axis", 0, bindings.ry_axis)
    end
  end

  register_btn("start", 0, { input_id("keyboard_scancode", "return"),
                             input_id("controller_button", "start") })
  ctrl_active["start"] = { state = false, pstate = false, value = 0}
end

-- game loading

function launch_game( game_id )
  
  local path = get_path_from_id(game_id)
    
  if path then
  
    local params = castle.game.getInitialParams()
    local battery_level
    local global_score
    
    if params then 
      battery_level = params.battery_level or 100
      global_score = params.global_score or 0    
    end
    
    castle.game.load(
        path, {
        battery_level = battery_level,
        global_score = global_score
      }
    )
    
  end
  
end
