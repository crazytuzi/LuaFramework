----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[700101] = {	id = 700101, pos = { x = -20.87476, y = 0.4378013, z = 7.413843 }, randomPos = 0, randomRadius = 0, monsters = { 93121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700102] = {	id = 700102, pos = { x = -24.20554, y = 0.3857151, z = 8.333822 }, randomPos = 0, randomRadius = 0, monsters = { 93121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700103] = {	id = 700103, pos = { x = -24.45175, y = 0.3857151, z = 6.642899 }, randomPos = 0, randomRadius = 0, monsters = { 93122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700104] = {	id = 700104, pos = { x = -24.37842, y = 0.3857151, z = 4.945532 }, randomPos = 0, randomRadius = 0, monsters = { 93122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700105] = {	id = 700105, pos = { x = -23.15604, y = 0.3857151, z = 8.041664 }, randomPos = 0, randomRadius = 0, monsters = { 93124,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700011] = {	id = 700011, pos = { x = -32.95021, y = 5.031435, z = -0.8691371 }, randomPos = 0, randomRadius = 0, monsters = { 99999,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700012] = {	id = 700012, pos = { x = 33.13616, y = 5.112771, z = -0.3814461 }, randomPos = 0, randomRadius = 0, monsters = { 99999,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700021] = {	id = 700021, pos = { x = -32.95021, y = 5.031435, z = -0.8691371 }, randomPos = 0, randomRadius = 0, monsters = { 99999,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[700022] = {	id = 700022, pos = { x = 33.13616, y = 5.112771, z = -0.3814461 }, randomPos = 0, randomRadius = 0, monsters = { 99999,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
