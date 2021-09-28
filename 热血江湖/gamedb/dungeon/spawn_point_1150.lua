----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[230101] = {	id = 230101, pos = { x = 59.90606, y = 2.005699, z = -15.60608 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230102] = {	id = 230102, pos = { x = 64.31783, y = 2.034825, z = -16.52763 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230103] = {	id = 230103, pos = { x = 59.28558, y = 2.005699, z = -9.751904 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230104] = {	id = 230104, pos = { x = 63.96033, y = 2.005699, z = -11.84411 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
