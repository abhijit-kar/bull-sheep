pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

local last_updated
local sample_rate
local game_objects

function _init()
 last_updated = 0
 sample_rate = 0.05

 game_objects = {}

 make_shepherd(64, 10)

 make_sheep(60, 40)
 make_sheep(30, 20)
 make_sheep(80, 60)
end

function _update()
 local game_object

 for game_object in all(game_objects) do
  game_object:update()
 end

 animate()
end

function _draw()
 cls()
 map(0,0)
 
 print('press ❎ to intimidate sheeps', 5, 115, 7)

 local game_object

 for game_object in all(game_objects) do
  game_object:draw()
 end
end

function animate()
 local curr_time = time()
 
 if curr_time - last_updated > sample_rate then
  last_updated = curr_time

  for game_object in all(game_objects) do
   game_object:animate()
  end
 end
end

function make_sheep(x, y)
 local sheep = make_game_object("sheep", x, y, {
  width = 8,
  height = 8,
  offset = {0, 0},
  velocity = {rnd(4) - 2, rnd(2) - 1},
  sprite = 1,
  idle = {1, 7},
  update = function(self)
   self.x += self.velocity[1]
   self.y += self.velocity[2]
   
   self:bounce()
   self:compare_hit_boxes()
   
   if btnp(❎) then
    self:intimidate()
   end
  end,
  draw = function(self)
   spr(self.sprite,
       self.x, self.y, 1, 1,
       self.velocity[1] > 0)

   self:debug()
  end,
  animate = function(self)
   self.sprite += 1
   
   if self.sprite > self.idle[2] then
    self.sprite = self.idle[1]
   end
  end,
  bounce = function(self)
   -- left or right
   if self.x <= 0 or self.x >= 120 then
    self.velocity[1] = -self.velocity[1]
   end
   
   --top or bottom
   if self.y <= 0 or self.y >= 115 then
    self.velocity[2] = -self.velocity[2]
   end
  end,
  intimidate = function(self)
   self.velocity[1] = rnd(2) - 1
   self.velocity[2] = rnd(2) - 1
  end,
  compare_hit_boxes = function(self)
   local target

   for target in all(game_objects) do
    if target.name == "sheep" and self != target then
     if self:overlap(target) then
      target:intimidate()
     end
    end
   end
  end
 })
 
 add(game_objects, sheep)
end

function make_shepherd(x, y)
 local shepherd = make_game_object("shepherd", x, y, {
  width = 6,
  height = 7,
  offset = {1, 0},
  velocity = {1, 1},
  sprite = 16,
  idle = {16, 20},
  walk = {32, 38},
  state = "idle",
  update = function(self)
   self.x += self.velocity[1]
   self.y += self.velocity[2]

   -- standalone ifs
   -- to allow free movements in all directions
   if btn(⬅️) then
    self.velocity[1]= -1
   end
   if btn(➡️) then
    self.velocity[1] = 1
   end
   if btn(⬆️) then
    self.velocity[2] = -1
   end
   if btn(⬇️) then
    self.velocity[2] = 1
   end

   -- detect when none of the movement buttons are being
   -- pressed
   if not btn(⬆️) and
      not btn(⬇️) and
      not btn(⬅️) and
      not btn(➡️) then
    self.state = "idle"
   end

   -- prevent character drift,
   -- by making making deltas 0
   if not btn(⬆️) and
      not btn(⬇️) then
    self.velocity[2] = 0
   end
   if not btn(⬅️) and
      not btn(➡️) then
    self.velocity[1] = 0
   end
   
   -- walk animation cue
   if self.state=="idle" then
    if btnp(⬆️) or btnp(⬇️) or
       btnp(➡️) or btnp(⬅️) then
     self.sprite = self.walk[1]
     self.state = "walk"
    end
   end

   -- rudimentary collision detection
   if self.x >= 120 then
    self.x = 119
   end
   
   if self.x <= 0 then
    self.x = 1
   end
   
   if self.y >= 115 then
    self.y = 114
   end
   
   if self.y <= 0 then
    self.y = 1
   end

   self:compare_hit_boxes()
  end,
  draw = function(self)
   spr(self.sprite, self.x, self.y)

   self:debug()
  end,
  animate = function(self)
   self.sprite += 1

   if self.state == 'walk' then  
    if self.sprite > self.walk[2] then
     self.sprite = self.walk[1]
    end
   else  
    if self.sprite > self.idle[2] then
     self.sprite = self.idle[1]
    end
   end
  end,
  compare_hit_boxes = function(self)
   local target
   
   for target in all(game_objects) do
    if target.name == "sheep" and self:overlap(target) then
     target:intimidate()
    end
   end
  end
 })

 add(game_objects, shepherd)
end

function make_game_object(name, x, y, props) 
 local game_obj = {
  name = name,
  x = x,
  y = y,
  label = "",
  draw =function() end,
  debug = function(self)
   rect(self.x + self.offset[1],
        self.y + self.offset[2],
        self.x + self.width,
        self.y + self.height,
        12)
   
   print(self.label, self.x + 8, self.y, 10)
  end,
  update = function() end,
  animate = function() end,
  overlap = function(self, target)
   local left1 = self.x
   local top1 = self.y
   local right1 = self.x + self.width
   local bottom1 = self.y + self.height

   local left2 = target.x
   local top2 = target.y
   local right2 = target.x + target.width
   local bottom2 = target.y + target.height

   return right1 > left2 and right2 > left1 and
          bottom1 > top2 and bottom2 > top1
  end,
  collision = function(self, target)
  end
 }

 local key, val

 for key, val in pairs(props) do
  game_obj[key] = val
 end

 return game_obj
end

__gfx__
00000000000000000077000000777700007777000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001177770011777770117777700077777000777700000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777001177777011777666117776661177766611777770007777000000000000000000000000000000000000000000000000000000000000000000
00077000117777700176766601767766017677661177776611777666117777700000000000000000000000000000000000000000000000000000000000000000
00077000117776660666776606666660066666600176666001767766117776660000000000000000000000000000000000000000000000000000000000000000
00700700017677663315666033153150331331303666313006666660017677660000000000000000000000000000000000000000000000000000000000000000
00000000366666600133315001333310033133100315331003153150366666600000000000000000000000000000000000000000000000000000000000000000
00000000031331000333331000333000030330000133330000133130031331000000000000000000000000000000000000000000000000000000000000000000
00000000000550000005500000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055000003ff000003ff000003ff000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003ff0000388880003888800003ff000003ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
038888000388880003f88f0003888800038888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03f88f0003f88f000311110003f88f0003f88f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03111100031111000310310003111100031111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03103100031031000310310003103100031031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100100001001000010010000100100001001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000550000005500000055000000550000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055000003ff000003ff000003ff000003ff000003ff00000055000000000000000000000000000000000000000000000000000000000000000000000000000
003ff0000388880003888800003ff0000388880003888800003ff000000000000000000000000000000000000000000000000000000000000000000000000000
038888000388880003f888000388880003888f000388880003888800000000000000000000000000000000000000000000000000000000000000000000000000
03f88f0003f888000311110003f88f000311110003888f0003f88f00000000000000000000000000000000000000000000000000000000000000000000000000
03111100031111000010310003111100031031000311110003111100000000000000000000000000000000000000000000000000000000000000000000000000
03103100001031000000310003103100031000000310310003103100000000000000000000000000000000000000000000000000000000000000000000000000
00100000000000000000010000100100001000000000000000100100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffffffffffffffffffffb94499449944994499449ff04400540000000000000000000000000000000000000000000000000000000000000000000000000
ff33f333f333f333f33ff3fff594444444444444444449bf05400540000000000000000000000000000000000000000000000000000000000000000000000000
f3bb3bbb3bbb3bbb3bb33b3ff594433443344334433449bf05400440000000000000000000000000000000000000000000000000000000000000000000000000
fffbbbbbbbbbbbbbbbbbbbfff5444b344b344b344b3444ff44444444000000000000000000000000000000000000000000000000000000000000000000000000
ff3bbbbbbbbbbbbbbbbbbbffff5bbbbbbbbbbbbbbbbb35ff04400450000000000000000000000000000000000000000000000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbb3fff59bbbbbbbbbbbbbbbbb39ff04400450000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbbb3ff59bbbbbbbbbbbbbbbbb39ff04500440000000000000000000000000000000000000000000000000000000000000000000000000
fffbbbbbbbbbbbbbbbbbbbffff4bbbbbbbbbbbbbbbbbb4ff04400440000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbbfffff5bbbbbbbbbbbbbbbbb35ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbbfff59bbbbbbbbbbb3bbbbb39ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ff3bbbbbbbbbbbbbbbbbbb3ff59bbbbbbbbb3b3bbbbb39ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbb3ffff4bbbbbbbbbbbbbbbbbb4ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbbbffff5bbbbbbbbbbbbbbbbb35ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3ff59bbbbbb3bbbbbbbbbb39ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ff3bbbbbbbbbbbbbbbbbb3fff59bbbbbb3b3bbbbbbbb39ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbbbffff4bbbbbbbbbbbbbbbbbb4ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbbbffff5bbbbbbbbbbbbbbbbb35ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3ff59bbbbbbbbbbbbbbbbb39bf00000000000000000000000000000000000000000000000000000000000000000000000000000000
ff3bbbbbbbbbbbbbbbbbb3fff5999bb99bb99bb99bb999ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffbbbbbbbbbbbbbbbbbbbffff444bb44bb44bb44bb444ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffbbbbbbbbbbbbbbbbbbbb3ffb44499449944994499444bf00000000000000000000000000000000000000000000000000000000000000000000000000000000
f3b33b33b3bbb3bbb3bb3b3ff544444444444444444444bf00000000000000000000000000000000000000000000000000000000000000000000000000000000
ff3ff3ff3f333f333f33f3fff544433443344334433444ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffffffffffffffffffff5444b544f544f544b5444bf00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbbbbbbbbbbffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbb77bb77bbbbbfffffffff999fffff9ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbb73377337bbbbfffffffff999ffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbb77bb77bbbbbfffffffff999ffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b77bbbbbbbbbbbbbffffffffffffffffffff999f00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007337bbbbbbbbb77bffffffffffffffffffff999f00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b77bbbbbbbbb7337ffffffffffffff9fffff999f00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbbbbbbb77bffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee88888e88888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8888eee8888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee88888e88888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111dd1d1d1ddd1ddd1ddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d111d111d1d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ddd1ddd11111ddd1ddd1dd11dd11ddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111d1d1d1d111d111d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111dd11d1d1ddd1ddd1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11661616166616661666166611111cc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161116161611161116161161177711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616661661166116661161111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111616161611161116111161177711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16611616166616661611166611111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11661616166616661666166171111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1611161616111611161611617717111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666166616611661166611617771111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1116161616111611161111617777111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1661161616661666161116617711111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661661166616661111116616161666166616661171117111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111611616116111611111161116161611161116161711111711111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111111611616116111611111166616661661166116661711111711111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111611616116111611111111616161611161116111711111711111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616166611611666166116161666166616111171117111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166161616661666166611111166161616661666166616661111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161616111611161617771611161616111611161611611111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616611661166611111666166616611661166611611111111111111111111111111111111111111111111111111111111111111111111111111111
11111116161616111611161117771116161616111611161111611111111111111111111111111111111111111111111111111111111111111111111111111111
11111661161616661666161111111661161616661666161116661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111661616166616661666161611111c1c1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111116111616161116111616161617771c1c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111116661666166116611666116111111ccc1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111116161616111611161116161777111c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661161616661666161116161111111c1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111661616166616661666161611111c111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111116111616161116111616161617771c111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111116661666166116611666166611111ccc1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111161616161116111611111617771c1c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111116611616166616661611166611111ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111661616166611661166111111661616166616661666117111711111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616161616161611111116111616161116111616171111171111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116111666166616161666111116661666166116611666171111171111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616161616161116111111161616161116111611171111171111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111111661616161616611661166616611616166616661611117111711111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111116616161666166616661661161611111bbb1bb11bb111711c1c117111111ccc111111111111111111111111111111111111111111111111111111111111
1111161116161611161116161616161617771b1b1b1b1b1b17111c1c11171111111c111111111111111111111111111111111111111111111111111111111111
1111166616661661166116661616116111111bb11b1b1b1b17111ccc111717771ccc111111111111111111111111111111111111111111111111111111111111
1111111616161611161116111616161617771b1b1b1b1b1b1711111c111711111c11111111111111111111111111111111111111111111111111111111111111
1111166116161666166616111666161611111b1b1b1b1bbb1171111c117111111ccc111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111116616161666166616661661161611111bbb1bb11bb111711ccc117111111cc1111111111111111111111111111111111111111111111111111111111111
1111161116161611161116161616161617771b1b1b1b1b1b1711111c1117111111c1111111111111111111111111111111111111111111111111111111111111
1111166616661661166116661616166611111bb11b1b1b1b17111ccc1117177711c1111111111111111111111111111111111111111111111111111111111111
1111111616161611161116111616111617771b1b1b1b1b1b17111c111117111111c1111111111111111111111111111111111111111111111111111111111111
1111166116161666166616111666166611111b1b1b1b1bbb11711ccc117111111ccc111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661166161616661111116616161666166616661171117111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116661616161616111111161116161611161116161711111711111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161616161616611111166616661661166116661711111711111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616166616111111111616161611161116111711111711111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116161661116116661666166116161666166616111171117111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166161616661666166616161111111111661616166616661666166116161111111111111111111111111111111111111111111111111111111111111111
11111611161616111611161616161171177716111616161116111616161616161111111111111111111111111111111111111111111111111111111111111111
11111666166616611661166611611777111116661666166116611666161611611111111111111111111111111111111111111111111111111111111111111111
11111116161616111611161116161171177711161616161116111611161616161111111111111111111111111111111111111111111111111111111111111111
11111661161616661666161116161111111116611616166616661611166616161111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166161616661666166616161111111111661616166616661666166116161111111111111111111111111111111111111111111111111111111111111111
11111611161616111611161616161171177716111616161116111616161616161111111111111111111111111111111111111111111111111111111111111111
11111666166616611661166616661777111116661666166116611666161616661111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822288828282828888888888888888888888888888888888888888888888888888888228822282228882822282288222822288866688
82888828828282888888888288288282828888888888888888888888888888888888888888888888888888888828888288828828828288288282888288888888
82888828828282288888882288288222822288888888888888888888888888888888888888888888888888888828888288828828822288288222822288822288
82888828828282888888888288288882828288888888888888888888888888888888888888888888888888888828888288828828828288288882828888888888
82228222828282228888822282888882822288888888888888888888888888888888888888888888888888888222888288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
4344444444444473754444444444444500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515151515441415151515154515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515451515151515451515151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515151515151515151515151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515151615151515151515151725500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515152735051515162605151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515151415151516273605151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5371515151515451527573405161515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351516161515151514141515273505500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351627373605151515151515141515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5352734142745051516151545151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351415151415151527350515151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515151515151527550515151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351545151515151514151515451515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5351515151515151515151515151515500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6364646464646464646464646464646500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500000167000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000246001a600236001c6001d600216001b60019600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000000000000000000000000000000000000
