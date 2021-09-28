----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[630101] = {	id = 630101, pos = { x = 37.20173, y = 6.965291, z = -17.1245 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630102] = {	id = 630102, pos = { x = 37.15187, y = 6.965291, z = -12.26064 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630103] = {	id = 630103, pos = { x = 38.04288, y = 6.965291, z = -21.49989 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630104] = {	id = 630104, pos = { x = 40.54538, y = 6.965291, z = -17.45799 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630105] = {	id = 630105, pos = { x = 39.5979, y = 6.965291, z = -12.56394 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630106] = {	id = 630106, pos = { x = 39.99532, y = 6.965291, z = -19.45196 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630107] = {	id = 630107, pos = { x = 40.45587, y = 6.965291, z = -22.71932 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630108] = {	id = 630108, pos = { x = 40.56149, y = 6.965291, z = -13.60827 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630109] = {	id = 630109, pos = { x = 38.06274, y = 6.965291, z = -24.21637 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630110] = {	id = 630110, pos = { x = 41.78693, y = 6.965291, z = -14.92476 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
