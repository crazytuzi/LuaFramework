----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[530401] = {	id = 530401, pos = { x = 35.77958, y = 13.97077, z = -8.298944 }, randomPos = 0, randomRadius = 0, monsters = { 90639,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530402] = {	id = 530402, pos = { x = 35.5002, y = 13.68962, z = -4.017431 }, randomPos = 0, randomRadius = 0, monsters = { 90637,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530403] = {	id = 530403, pos = { x = 35.49216, y = 13.97885, z = -11.19193 }, randomPos = 0, randomRadius = 0, monsters = { 90637,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530404] = {	id = 530404, pos = { x = 38.38749, y = 13.84898, z = -11.76916 }, randomPos = 0, randomRadius = 0, monsters = { 90637,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530405] = {	id = 530405, pos = { x = 38.3913, y = 13.96803, z = -6.713802 }, randomPos = 0, randomRadius = 0, monsters = { 90637,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530406] = {	id = 530406, pos = { x = 37.8298, y = 13.91108, z = -8.942675 }, randomPos = 0, randomRadius = 0, monsters = { 90637,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530407] = {	id = 530407, pos = { x = 39.51587, y = 13.91801, z = -9.219509 }, randomPos = 0, randomRadius = 0, monsters = { 90638,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530408] = {	id = 530408, pos = { x = 40.25761, y = 13.96717, z = -7.382782 }, randomPos = 0, randomRadius = 0, monsters = { 90638,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530409] = {	id = 530409, pos = { x = 39.49848, y = 13.8932, z = -10.26735 }, randomPos = 0, randomRadius = 0, monsters = { 90638,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530410] = {	id = 530410, pos = { x = 34.90443, y = 13.91277, z = -5.368819 }, randomPos = 0, randomRadius = 0, monsters = { 90638,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530411] = {	id = 530411, pos = { x = 36.14756, y = 13.93076, z = -12.18792 }, randomPos = 0, randomRadius = 0, monsters = { 90638,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
