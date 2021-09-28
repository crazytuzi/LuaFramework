----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[460401] = {	id = 460401, pos = { x = -5.027317, y = 6.126064, z = -0.5887301 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460402] = {	id = 460402, pos = { x = -9.378452, y = 6.434393, z = 6.785931 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460403] = {	id = 460403, pos = { x = -7.072719, y = 6.057124, z = -2.821844 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460404] = {	id = 460404, pos = { x = -8.686937, y = 6.430533, z = 5.138739 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460405] = {	id = 460405, pos = { x = 14.47422, y = 6.326665, z = 12.83861 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460406] = {	id = 460406, pos = { x = 20.77606, y = 6.002942, z = 8.751299 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460407] = {	id = 460407, pos = { x = 15.2934, y = 6.315662, z = 11.13115 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460408] = {	id = 460408, pos = { x = 15.2394, y = 6.318502, z = 7.564853 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460409] = {	id = 460409, pos = { x = -2.456467, y = 6.041456, z = 25.99105 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460501] = {	id = 460501, pos = { x = 2.688091, y = 6.544906, z = 9.140331 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460502] = {	id = 460502, pos = { x = 2.830645, y = 6.524821, z = 7.883744 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460503] = {	id = 460503, pos = { x = 2.986133, y = 6.529514, z = 7.673938 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460504] = {	id = 460504, pos = { x = 3.995088, y = 6.57117, z = 7.518162 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460505] = {	id = 460505, pos = { x = 3.688633, y = 6.57117, z = 10.7273 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460506] = {	id = 460506, pos = { x = 12.36867, y = 6.035736, z = 24.66072 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460507] = {	id = 460507, pos = { x = 5.391913, y = 6.57117, z = 7.673655 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460508] = {	id = 460508, pos = { x = 4.772369, y = 6.57117, z = 7.420963 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460509] = {	id = 460509, pos = { x = 1.060394, y = 6.15776, z = 23.08217 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460510] = {	id = 460510, pos = { x = 5.596135, y = 6.57117, z = 7.575201 }, randomPos = 0, randomRadius = 0, monsters = { 90415,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
