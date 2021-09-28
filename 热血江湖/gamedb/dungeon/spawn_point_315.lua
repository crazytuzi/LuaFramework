----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[63101] = {	id = 63101, pos = { x = -8.992022, y = 6.252323, z = 13.75674 }, randomPos = 1, randomRadius = 400, monsters = { 61221,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63102] = {	id = 63102, pos = { x = 3.264153, y = 6.243748, z = 19.75577 }, randomPos = 1, randomRadius = 400, monsters = { 61222,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63103] = {	id = 63103, pos = { x = 14.07827, y = 6.250881, z = 9.960616 }, randomPos = 1, randomRadius = 400, monsters = { 61223,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63104] = {	id = 63104, pos = { x = -0.5446596, y = 6.449397, z = 0.5461297 }, randomPos = 0, randomRadius = 0, monsters = { 61229,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[63111] = {	id = 63111, pos = { x = 6.257771, y = 6.251202, z = 20.13676 }, randomPos = 0, randomRadius = 0, monsters = { 61227,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63112] = {	id = 63112, pos = { x = -5.595905, y = 6.478341, z = 10.33096 }, randomPos = 0, randomRadius = 0, monsters = { 61229,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[63121] = {	id = 63121, pos = { x = -8.894301, y = 6.207289, z = 7.231989 }, randomPos = 1, randomRadius = 400, monsters = { 61224,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63122] = {	id = 63122, pos = { x = 0.6473446, y = 6.208381, z = -2.339537 }, randomPos = 1, randomRadius = 400, monsters = { 61225,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63123] = {	id = 63123, pos = { x = -2.164398, y = 6.2015, z = 17.98243 }, randomPos = 1, randomRadius = 400, monsters = { 61226,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63124] = {	id = 63124, pos = { x = 10.56309, y = 6.41351, z = 11.65048 }, randomPos = 0, randomRadius = 0, monsters = { 61229,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[63131] = {	id = 63131, pos = { x = 12.01205, y = 6.233236, z = 15.86074 }, randomPos = 0, randomRadius = 0, monsters = { 61228,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[63132] = {	id = 63132, pos = { x = -3.943378, y = 6.571169, z = 13.79964 }, randomPos = 0, randomRadius = 0, monsters = { 61229,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
