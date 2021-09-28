----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[340101] = {	id = 340101, pos = { x = -0.040428, y = 0.5588617, z = 7.871123 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340102] = {	id = 340102, pos = { x = 2.25, y = 0.5588617, z = 9.33577 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340103] = {	id = 340103, pos = { x = -2.449311, y = 0.5588617, z = 9.67152 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
