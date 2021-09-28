----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[29001] = {	id = 29001, pos = { x = 47.65895, y = 3.187279, z = -48.81009 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29002] = {	id = 29002, pos = { x = 31.0363, y = 1.187279, z = -84.45793 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29003] = {	id = 29003, pos = { x = 1.277321, y = 1.187279, z = -71.33824 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29004] = {	id = 29004, pos = { x = -11.56082, y = 4.187279, z = -49.58765 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29005] = {	id = 29005, pos = { x = -46.7014, y = 5.58728, z = -48.13083 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29006] = {	id = 29006, pos = { x = -95.59099, y = 8.187279, z = -31.30902 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29007] = {	id = 29007, pos = { x = -65.11452, y = 8.187279, z = -13.97055 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29008] = {	id = 29008, pos = { x = -58.06568, y = 8.187279, z = 36.57372 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29009] = {	id = 29009, pos = { x = -69.07186, y = 8.187279, z = 67.54236 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29010] = {	id = 29010, pos = { x = -81.5621, y = 11.18729, z = 99.1108 }, randomPos = 1, randomRadius = 500, monsters = { 87401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29101] = {	id = 29101, pos = { x = -18.6848, y = 4.187279, z = -45.99059 }, randomPos = 1, randomRadius = 500, monsters = { 87402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29102] = {	id = 29102, pos = { x = -14.76764, y = 6.187279, z = -15.3544 }, randomPos = 1, randomRadius = 500, monsters = { 87402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29103] = {	id = 29103, pos = { x = 16.23866, y = 6.187279, z = 8.166035 }, randomPos = 1, randomRadius = 500, monsters = { 87402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29104] = {	id = 29104, pos = { x = -21.51965, y = 9.187286, z = 44.58455 }, randomPos = 1, randomRadius = 500, monsters = { 87402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29105] = {	id = 29105, pos = { x = -24.09914, y = 9.187286, z = 81.1526 }, randomPos = 1, randomRadius = 500, monsters = { 87402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29106] = {	id = 29106, pos = { x = -75.21712, y = 11.18729, z = 101.0627 }, randomPos = 1, randomRadius = 500, monsters = { 87402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
