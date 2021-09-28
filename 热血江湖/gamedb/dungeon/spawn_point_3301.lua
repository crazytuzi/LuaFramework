----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[660201] = {	id = 660201, pos = { x = 59.19101, y = 18.99218, z = 44.47041 }, randomPos = 0, randomRadius = 0, monsters = { 92113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660202] = {	id = 660202, pos = { x = 67.17906, y = 18.99218, z = 48.40524 }, randomPos = 0, randomRadius = 0, monsters = { 92113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660203] = {	id = 660203, pos = { x = 52.8164, y = 18.99218, z = 50.79548 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660204] = {	id = 660204, pos = { x = 60.54605, y = 18.99218, z = 50.89619 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660205] = {	id = 660205, pos = { x = 64.11118, y = 18.99218, z = 53.83544 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660206] = {	id = 660206, pos = { x = 54.70122, y = 18.99218, z = 55.50968 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660207] = {	id = 660207, pos = { x = 53.50453, y = 18.99218, z = 53.37819 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660208] = {	id = 660208, pos = { x = 66.86079, y = 18.99218, z = 54.55347 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660209] = {	id = 660209, pos = { x = 65.26694, y = 18.99504, z = 43.60247 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660301] = {	id = 660301, pos = { x = 59.94913, y = 18.99218, z = 60.57558 }, randomPos = 0, randomRadius = 0, monsters = { 92112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660302] = {	id = 660302, pos = { x = 65.9632, y = 18.99218, z = 66.58968 }, randomPos = 0, randomRadius = 0, monsters = { 92112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660303] = {	id = 660303, pos = { x = 72.06848, y = 18.99218, z = 49.70269 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660304] = {	id = 660304, pos = { x = 71.34097, y = 18.99218, z = 56.46009 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660305] = {	id = 660305, pos = { x = 74.33045, y = 18.99218, z = 56.71544 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660306] = {	id = 660306, pos = { x = 66.47305, y = 18.99218, z = 61.34635 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660307] = {	id = 660307, pos = { x = 87.17532, y = 18.88465, z = 70.51011 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660308] = {	id = 660308, pos = { x = 80.02473, y = 26.39218, z = 108.5124 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660309] = {	id = 660309, pos = { x = 50.22495, y = 27.09109, z = 109.4888 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
