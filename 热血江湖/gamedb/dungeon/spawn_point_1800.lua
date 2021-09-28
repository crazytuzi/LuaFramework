----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[360101] = {	id = 360101, pos = { x = -0.6415834, y = 0.5588617, z = 7.25299 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360102] = {	id = 360102, pos = { x = 1.682038, y = 0.5588617, z = 9.80851 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360103] = {	id = 360103, pos = { x = -2.75, y = 0.5588617, z = 8.33577 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360104] = {	id = 360104, pos = { x = -1.296303, y = 0.5588617, z = 10.27767 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360105] = {	id = 360105, pos = { x = -0.232768, y = 0.5588617, z = 10.04074 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360106] = {	id = 360106, pos = { x = 2.25, y = 0.3588609, z = 12.33577 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
