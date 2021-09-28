----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[37601] = {	id = 37601, pos = { x = 81.98758, y = 10.22691, z = -83.1832 }, randomPos = 1, randomRadius = 200, monsters = { 87707,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37602] = {	id = 37602, pos = { x = 173.5294, y = 26.08202, z = 67.35957 }, randomPos = 1, randomRadius = 200, monsters = { 87707,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37603] = {	id = 37603, pos = { x = 15.61811, y = 17.08202, z = 127.3049 }, randomPos = 1, randomRadius = 200, monsters = { 87707,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37604] = {	id = 37604, pos = { x = -7.572205, y = 0.0820236, z = -152.155 }, randomPos = 1, randomRadius = 200, monsters = { 87707,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37701] = {	id = 37701, pos = { x = 5.275693, y = 3.082024, z = -119.8143 }, randomPos = 1, randomRadius = 500, monsters = { 87708,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37702] = {	id = 37702, pos = { x = -103.0629, y = 2.181054, z = -89.53061 }, randomPos = 1, randomRadius = 500, monsters = { 87708,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37703] = {	id = 37703, pos = { x = -55.88796, y = 5.082024, z = -22.32669 }, randomPos = 1, randomRadius = 500, monsters = { 87708,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37704] = {	id = 37704, pos = { x = -23.34406, y = 17.47241, z = 114.3998 }, randomPos = 1, randomRadius = 500, monsters = { 87708,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37705] = {	id = 37705, pos = { x = 111.7759, y = 20.09512, z = 47.76029 }, randomPos = 1, randomRadius = 500, monsters = { 87708,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37706] = {	id = 37706, pos = { x = 80.0229, y = 10.08202, z = -86.79742 }, randomPos = 1, randomRadius = 500, monsters = { 87708,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
