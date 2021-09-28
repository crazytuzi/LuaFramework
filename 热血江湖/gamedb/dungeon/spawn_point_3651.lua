----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[730201] = {	id = 730201, pos = { x = 16.97011, y = 25.26144, z = 16.57041 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730202] = {	id = 730202, pos = { x = 21.33508, y = 25.2, z = 15.90238 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730203] = {	id = 730203, pos = { x = 25.05049, y = 25.2, z = 19.6178 }, randomPos = 0, randomRadius = 0, monsters = { 94114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730204] = {	id = 730204, pos = { x = 26.56572, y = 25.2, z = 15.999 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730205] = {	id = 730205, pos = { x = 9.551537, y = 25.38832, z = 12.57646 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730301] = {	id = 730301, pos = { x = -3.887557, y = 21.09212, z = -18.10646 }, randomPos = 0, randomRadius = 0, monsters = { 94114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730302] = {	id = 730302, pos = { x = -3.085698, y = 21.07464, z = -15.8853 }, randomPos = 0, randomRadius = 0, monsters = { 94114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730303] = {	id = 730303, pos = { x = -5.500677, y = 21.07942, z = -21.74481 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730304] = {	id = 730304, pos = { x = -4.516428, y = 21.09748, z = -19.3759 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730305] = {	id = 730305, pos = { x = -6.312483, y = 21.0877, z = -21.95086 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730306] = {	id = 730306, pos = { x = -8.67197, y = 21.16251, z = -18.57305 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
