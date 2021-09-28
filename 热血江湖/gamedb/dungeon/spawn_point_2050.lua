----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[410101] = {	id = 410101, pos = { x = 75.39992, y = 12.9436, z = -13.20119 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410102] = {	id = 410102, pos = { x = 74.57612, y = 12.95954, z = -9.846372 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410103] = {	id = 410103, pos = { x = 72.02489, y = 12.95778, z = -9.042778 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410104] = {	id = 410104, pos = { x = 77.0387, y = 12.97919, z = -10.66659 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
