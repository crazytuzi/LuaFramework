----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[350601] = {	id = 350601, pos = { x = 10.3823, y = 0.1588621, z = 108.3101 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350602] = {	id = 350602, pos = { x = 3.151488, y = 0.1588621, z = 108.6991 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350603] = {	id = 350603, pos = { x = 5.735786, y = 0.1588621, z = 106.8812 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350604] = {	id = 350604, pos = { x = 7.905102, y = 0.1588621, z = 107.8444 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350605] = {	id = 350605, pos = { x = 3.047471, y = 0.1588621, z = 107.2821 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350606] = {	id = 350606, pos = { x = 10.01662, y = 0.1588621, z = 107.2155 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350607] = {	id = 350607, pos = { x = 6.02008, y = 0.158862, z = 106.2431 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350608] = {	id = 350608, pos = { x = 8.003716, y = 0.1588619, z = 106.0053 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350609] = {	id = 350609, pos = { x = 6.313334, y = 0.1588621, z = 111.4444 }, randomPos = 0, randomRadius = 0, monsters = { 90325,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
