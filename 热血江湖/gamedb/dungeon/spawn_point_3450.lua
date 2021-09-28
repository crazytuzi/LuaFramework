----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[690101] = {	id = 690101, pos = { x = -21.42693, y = 0.3857151, z = 6.468319 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690102] = {	id = 690102, pos = { x = -22.26519, y = 0.3857151, z = 5.862991 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690103] = {	id = 690103, pos = { x = -22.82962, y = 0.3857151, z = 3.995617 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690104] = {	id = 690104, pos = { x = -23.51066, y = 0.3857151, z = 7.844198 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
