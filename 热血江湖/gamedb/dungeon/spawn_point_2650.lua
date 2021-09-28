----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[530101] = {	id = 530101, pos = { x = -42.79887, y = 11.37133, z = -76.33125 }, randomPos = 0, randomRadius = 0, monsters = { 90631,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530102] = {	id = 530102, pos = { x = -42.62799, y = 11.38598, z = -70.46548 }, randomPos = 0, randomRadius = 0, monsters = { 90631,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530103] = {	id = 530103, pos = { x = -40.62241, y = 11.38163, z = -62.01454 }, randomPos = 0, randomRadius = 0, monsters = { 90631,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530104] = {	id = 530104, pos = { x = -36.99176, y = 11.38163, z = -63.32349 }, randomPos = 0, randomRadius = 0, monsters = { 90632,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530105] = {	id = 530105, pos = { x = -42.1645, y = 11.45616, z = -72.9705 }, randomPos = 0, randomRadius = 0, monsters = { 90632,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530106] = {	id = 530106, pos = { x = -39.61462, y = 11.41432, z = -66.54128 }, randomPos = 0, randomRadius = 0, monsters = { 90632,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530107] = {	id = 530107, pos = { x = -40.30273, y = 11.51234, z = -69.94406 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530108] = {	id = 530108, pos = { x = 5.925648, y = 11.38163, z = -74.35896 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530109] = {	id = 530109, pos = { x = 8.958721, y = 11.38163, z = -76.07735 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530110] = {	id = 530110, pos = { x = 11.73645, y = 11.38163, z = -78.42104 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530111] = {	id = 530111, pos = { x = 13.08618, y = 11.30832, z = -80.37604 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530112] = {	id = 530112, pos = { x = 12.96884, y = 11.35969, z = -82.44445 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530113] = {	id = 530113, pos = { x = 12.12394, y = 11.37436, z = -83.91167 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[530114] = {	id = 530114, pos = { x = 11.15041, y = 11.38162, z = -85.56996 }, randomPos = 0, randomRadius = 0, monsters = { 90633,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
