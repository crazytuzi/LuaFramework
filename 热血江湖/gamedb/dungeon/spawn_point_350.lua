----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[70101] = {	id = 70101, pos = { x = 4.063597, y = 6.377395, z = -12.95213 }, randomPos = 1, randomRadius = 500, monsters = { 61101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70102] = {	id = 70102, pos = { x = 2.958295, y = 6.376993, z = -9.25589 }, randomPos = 1, randomRadius = 500, monsters = { 61102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70103] = {	id = 70103, pos = { x = 2.212009, y = 6.369367, z = -5.425182 }, randomPos = 1, randomRadius = 500, monsters = { 61103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
