----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[7000] = {	id = 7000, pos = { x = 2.711478, y = 6.379011, z = -8.998058 }, randomPos = 0, randomRadius = 0, monsters = { 72100,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001] = {	id = 7001, pos = { x = 2.537472, y = 6.385019, z = -9.835606 }, randomPos = 0, randomRadius = 0, monsters = { 72101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7002] = {	id = 7002, pos = { x = 2.338486, y = 6.386256, z = -9.541031 }, randomPos = 0, randomRadius = 0, monsters = { 72102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7003] = {	id = 7003, pos = { x = 2.655107, y = 6.381803, z = -9.457272 }, randomPos = 0, randomRadius = 0, monsters = { 72103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7004] = {	id = 7004, pos = { x = 2.294996, y = 6.387025, z = -9.587498 }, randomPos = 0, randomRadius = 0, monsters = { 72104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7005] = {	id = 7005, pos = { x = 2.438322, y = 6.385635, z = -9.688824 }, randomPos = 0, randomRadius = 0, monsters = { 72105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7006] = {	id = 7006, pos = { x = 2.064365, y = 6.386442, z = -8.797935 }, randomPos = 0, randomRadius = 0, monsters = { 72106,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7007] = {	id = 7007, pos = { x = 2.311892, y = 6.384412, z = -9.055061 }, randomPos = 0, randomRadius = 0, monsters = { 72107,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7008] = {	id = 7008, pos = { x = 2.425482, y = 6.384718, z = -9.44809 }, randomPos = 0, randomRadius = 0, monsters = { 72108,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7009] = {	id = 7009, pos = { x = 2.092934, y = 6.388285, z = -9.289143 }, randomPos = 0, randomRadius = 0, monsters = { 72109,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7010] = {	id = 7010, pos = { x = 2.268095, y = 6.385187, z = -9.101891 }, randomPos = 0, randomRadius = 0, monsters = { 72110,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7011] = {	id = 7011, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7012] = {	id = 7012, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72124,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7013] = {	id = 7013, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72125,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7014] = {	id = 7014, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72126,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7015] = {	id = 7015, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72127,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7016] = {	id = 7016, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72128,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7017] = {	id = 7017, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72129,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7018] = {	id = 7018, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7019] = {	id = 7019, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7020] = {	id = 7020, pos = { x = 2.368887, y = 6.384565, z = -9.25227 }, randomPos = 0, randomRadius = 0, monsters = { 72132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
