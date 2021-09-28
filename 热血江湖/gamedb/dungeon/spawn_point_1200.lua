----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[240101] = {	id = 240101, pos = { x = 60.89154, y = 2.005699, z = -12.54145 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240102] = {	id = 240102, pos = { x = 62.67749, y = 2.005699, z = -12.3726 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240103] = {	id = 240103, pos = { x = 62.85004, y = 2.005699, z = -12.76698 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240104] = {	id = 240104, pos = { x = 63.83112, y = 2.005699, z = -12.50028 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240105] = {	id = 240105, pos = { x = 64.96505, y = 2.005699, z = -12.61468 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240106] = {	id = 240106, pos = { x = 66.12581, y = 2.005699, z = -12.20107 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
