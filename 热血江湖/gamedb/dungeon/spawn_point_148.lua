----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[29601] = {	id = 29601, pos = { x = 21.30611, y = 9.187286, z = 80.1069 }, randomPos = 1, randomRadius = 200, monsters = { 87407,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29602] = {	id = 29602, pos = { x = 24.97038, y = 9.187286, z = 119.9598 }, randomPos = 1, randomRadius = 200, monsters = { 87407,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29603] = {	id = 29603, pos = { x = 1.120224, y = 6.187279, z = -17.16948 }, randomPos = 1, randomRadius = 200, monsters = { 87407,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29604] = {	id = 29604, pos = { x = -24.28309, y = 6.187279, z = 10.03306 }, randomPos = 1, randomRadius = 200, monsters = { 87407,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29701] = {	id = 29701, pos = { x = -55.85452, y = 8.187279, z = 39.51633 }, randomPos = 1, randomRadius = 500, monsters = { 87408,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29702] = {	id = 29702, pos = { x = -88.82546, y = 8.187279, z = -18.85678 }, randomPos = 1, randomRadius = 500, monsters = { 87408,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29703] = {	id = 29703, pos = { x = -50.45366, y = 5.58728, z = -49.56264 }, randomPos = 1, randomRadius = 500, monsters = { 87408,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29704] = {	id = 29704, pos = { x = -53.55745, y = 4.187279, z = -70.99274 }, randomPos = 1, randomRadius = 500, monsters = { 87408,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29705] = {	id = 29705, pos = { x = -17.87645, y = 4.187279, z = -47.70008 }, randomPos = 1, randomRadius = 500, monsters = { 87408,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29706] = {	id = 29706, pos = { x = 18.21196, y = 1.187279, z = -83.4071 }, randomPos = 1, randomRadius = 500, monsters = { 87408,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
