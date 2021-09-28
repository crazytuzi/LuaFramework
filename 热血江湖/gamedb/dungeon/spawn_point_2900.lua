----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[580101] = {	id = 580101, pos = { x = -3.053135, y = 0.1966242, z = -32.76231 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580102] = {	id = 580102, pos = { x = -0.864337, y = 0.1966242, z = -32.50922 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580103] = {	id = 580103, pos = { x = 0.5774803, y = 0.1966242, z = -32.64811 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580104] = {	id = 580104, pos = { x = 2.517695, y = 0.1966242, z = -32.5579 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580105] = {	id = 580105, pos = { x = 3.696364, y = 0.1966242, z = -32.69678 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580106] = {	id = 580106, pos = { x = 4.957169, y = 0.1966242, z = -32.75 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
