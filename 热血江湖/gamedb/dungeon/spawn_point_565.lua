----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[113101] = {	id = 113101, pos = { x = -4.786811, y = 0.5588617, z = 36.21902 }, randomPos = 1, randomRadius = 500, monsters = { 150500,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113102] = {	id = 113102, pos = { x = 24.9821, y = 0.0588617, z = 68.51117 }, randomPos = 1, randomRadius = 500, monsters = { 150501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113103] = {	id = 113103, pos = { x = 9.032393, y = 0.0588617, z = 103.9776 }, randomPos = 1, randomRadius = 500, monsters = { 150502,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113104] = {	id = 113104, pos = { x = 9.507753, y = 0.0588617, z = 107.5003 }, randomPos = 0, randomRadius = 0, monsters = { 150503,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
