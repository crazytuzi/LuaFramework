----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[580401] = {	id = 580401, pos = { x = -34.01676, y = 8.196625, z = -22.7917 }, randomPos = 0, randomRadius = 0, monsters = { 90725,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580402] = {	id = 580402, pos = { x = -31.43945, y = 8.286016, z = -20.82691 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580403] = {	id = 580403, pos = { x = -33.76958, y = 8.196625, z = -18.12812 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580404] = {	id = 580404, pos = { x = -28.32131, y = 8.318749, z = -17.90052 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580405] = {	id = 580405, pos = { x = -28.99285, y = 8.279762, z = -21.99921 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580406] = {	id = 580406, pos = { x = -34.50589, y = 8.196625, z = -26.29488 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580407] = {	id = 580407, pos = { x = -32.0, y = 8.196625, z = -27.04179 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580408] = {	id = 580408, pos = { x = -29.11717, y = 8.233038, z = -25.93586 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580409] = {	id = 580409, pos = { x = -32.01426, y = 8.196625, z = -24.88186 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580501] = {	id = 580501, pos = { x = -3.102395, y = 12.39662, z = 43.1241 }, randomPos = 0, randomRadius = 0, monsters = { 90726,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580502] = {	id = 580502, pos = { x = 1.416742, y = 12.33975, z = 39.0661 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580503] = {	id = 580503, pos = { x = 6.835367, y = 12.39663, z = 40.17676 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580504] = {	id = 580504, pos = { x = -4.297856, y = 12.39662, z = 40.34716 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580505] = {	id = 580505, pos = { x = 1.180931, y = 12.38726, z = 41.9917 }, randomPos = 0, randomRadius = 0, monsters = { 90724,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580506] = {	id = 580506, pos = { x = 5.307919, y = 12.39663, z = 43.25127 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580507] = {	id = 580507, pos = { x = -1.062454, y = 12.39662, z = 44.21603 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580508] = {	id = 580508, pos = { x = 3.683572, y = 12.39663, z = 43.46452 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580509] = {	id = 580509, pos = { x = 1.040264, y = 12.43758, z = 48.53387 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
