----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[51001] = {	id = 51001, pos = { x = -8.452834, y = 5.836179, z = -54.0031 }, randomPos = 1, randomRadius = 550, monsters = { 51001,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51003] = {	id = 51003, pos = { x = -10.07216, y = 3.406951, z = -92.8902 }, randomPos = 1, randomRadius = 550, monsters = { 51003,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51004] = {	id = 51004, pos = { x = 4.254754, y = 8.802643, z = -23.5106 }, randomPos = 1, randomRadius = 550, monsters = { 51004,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51005] = {	id = 51005, pos = { x = -18.5253, y = 14.64021, z = 6.478608 }, randomPos = 1, randomRadius = 550, monsters = { 51005,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51006] = {	id = 51006, pos = { x = -36.29263, y = 16.04214, z = 34.69362 }, randomPos = 1, randomRadius = 550, monsters = { 51006,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51007] = {	id = 51007, pos = { x = 39.93885, y = 12.599, z = 0.0743541 }, randomPos = 1, randomRadius = 350, monsters = { 51007,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51051] = {	id = 51051, pos = { x = 2.24992, y = 7.678996, z = -42.63777 }, randomPos = 1, randomRadius = 300, monsters = { 51051,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51052] = {	id = 51052, pos = { x = -20.05192, y = 3.49588, z = -81.93618 }, randomPos = 1, randomRadius = 300, monsters = { 51052,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[51053] = {	id = 51053, pos = { x = -28.99221, y = 14.40305, z = 9.940607 }, randomPos = 0, randomRadius = 100, monsters = { 51053,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
