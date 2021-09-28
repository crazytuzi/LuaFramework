----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[31001] = {	id = 31001, pos = { x = 72.48468, y = 2.005698, z = -1.217948 }, randomPos = 1, randomRadius = 350, monsters = { 99411,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31002] = {	id = 31002, pos = { x = 76.76575, y = 2.005698, z = -8.579535 }, randomPos = 1, randomRadius = 350, monsters = { 99411,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31003] = {	id = 31003, pos = { x = 60.01037, y = 2.005698, z = -7.164815 }, randomPos = 1, randomRadius = 350, monsters = { 99412,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31004] = {	id = 31004, pos = { x = 67.05927, y = 2.005698, z = -17.35634 }, randomPos = 1, randomRadius = 350, monsters = { 99412,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31005] = {	id = 31005, pos = { x = 78.60233, y = 2.2057, z = 37.40431 }, randomPos = 1, randomRadius = 350, monsters = { 99413,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31006] = {	id = 31006, pos = { x = 86.36077, y = 2.2057, z = 43.03748 }, randomPos = 1, randomRadius = 350, monsters = { 99413,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31007] = {	id = 31007, pos = { x = 67.45534, y = 2.2057, z = 47.9308 }, randomPos = 1, randomRadius = 350, monsters = { 99414,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31008] = {	id = 31008, pos = { x = 62.69411, y = 2.205698, z = 58.77608 }, randomPos = 1, randomRadius = 350, monsters = { 99414,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31009] = {	id = 31009, pos = { x = 60.50836, y = 2.4057, z = 91.24147 }, randomPos = 1, randomRadius = 350, monsters = { 99415,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31010] = {	id = 31010, pos = { x = 67.33913, y = 2.405699, z = 102.5813 }, randomPos = 1, randomRadius = 350, monsters = { 99415,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31101] = {	id = 31101, pos = { x = 117.4586, y = 10.3945, z = -10.40303 }, randomPos = 1, randomRadius = 350, monsters = { 99421,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31102] = {	id = 31102, pos = { x = 125.5996, y = 10.3945, z = -22.15082 }, randomPos = 1, randomRadius = 350, monsters = { 99421,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31103] = {	id = 31103, pos = { x = 109.6317, y = 10.3945, z = -22.90227 }, randomPos = 1, randomRadius = 350, monsters = { 99422,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31104] = {	id = 31104, pos = { x = 123.301, y = 10.56297, z = -38.24912 }, randomPos = 1, randomRadius = 350, monsters = { 99422,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31105] = {	id = 31105, pos = { x = 81.32479, y = 14.9945, z = 5.886064 }, randomPos = 1, randomRadius = 350, monsters = { 99423,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31106] = {	id = 31106, pos = { x = 87.156, y = 12.7945, z = -11.45589 }, randomPos = 1, randomRadius = 350, monsters = { 99423,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31107] = {	id = 31107, pos = { x = 69.87691, y = 15.22516, z = -39.89171 }, randomPos = 1, randomRadius = 350, monsters = { 99424,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31108] = {	id = 31108, pos = { x = 72.96509, y = 12.85974, z = -19.20924 }, randomPos = 1, randomRadius = 350, monsters = { 99424,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31109] = {	id = 31109, pos = { x = 114.011, y = 7.443585, z = -49.91476 }, randomPos = 1, randomRadius = 350, monsters = { 99425,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[31110] = {	id = 31110, pos = { x = 107.7797, y = 7.394505, z = -63.4114 }, randomPos = 1, randomRadius = 350, monsters = { 99425,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
