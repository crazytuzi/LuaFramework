----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[677701] = {	id = 677701, pos = { x = 0.125255, y = 5.305711, z = 38.53933 }, randomPos = 0, randomRadius = 0, monsters = { 61210,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[677702] = {	id = 677702, pos = { x = 0.0299483, y = 5.305711, z = 39.30893 }, randomPos = 0, randomRadius = 0, monsters = { 61212,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[677703] = {	id = 677703, pos = { x = -0.2240888, y = 5.305711, z = 39.7488 }, randomPos = 0, randomRadius = 0, monsters = { 61214,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[677704] = {	id = 677704, pos = { x = -0.2251594, y = 5.305711, z = 40.00368 }, randomPos = 0, randomRadius = 0, monsters = { 61216,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[677705] = {	id = 677705, pos = { x = -0.2251594, y = 5.305711, z = 40.00368 }, randomPos = 0, randomRadius = 0, monsters = { 61218,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
