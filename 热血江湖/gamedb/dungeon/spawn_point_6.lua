----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[1201] = {	id = 1201, pos = { x = -11.42172, y = 8.865156, z = 45.39095 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1202] = {	id = 1202, pos = { x = -10.83328, y = 8.881127, z = 58.39937 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1203] = {	id = 1203, pos = { x = -9.856999, y = 8.801448, z = 49.27277 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1204] = {	id = 1204, pos = { x = -9.041092, y = 8.852448, z = 54.60474 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1205] = {	id = 1205, pos = { x = -34.36192, y = 8.789296, z = 58.07845 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1206] = {	id = 1206, pos = { x = -36.25108, y = 9.049001, z = 43.4477 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1207] = {	id = 1207, pos = { x = -37.41606, y = 8.820045, z = 54.73414 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1208] = {	id = 1208, pos = { x = -38.00612, y = 8.801604, z = 48.26233 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1209] = {	id = 1209, pos = { x = -10.6876, y = 8.834614, z = 47.7531 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1210] = {	id = 1210, pos = { x = -10.01594, y = 8.808963, z = 55.33336 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1211] = {	id = 1211, pos = { x = -11.21961, y = 8.865876, z = 50.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60914,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1212] = {	id = 1212, pos = { x = -31.52577, y = 8.989296, z = 46.58984 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1213] = {	id = 1213, pos = { x = -31.88144, y = 8.940076, z = 53.74977 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1214] = {	id = 1214, pos = { x = -17.65512, y = 8.789296, z = 48.0 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1215] = {	id = 1215, pos = { x = -17.82113, y = 8.972347, z = 53.34894 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1216] = {	id = 1216, pos = { x = -23.95348, y = 8.960325, z = 58.83297 }, randomPos = 0, randomRadius = 0, monsters = { 60911,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1217] = {	id = 1217, pos = { x = -23.3449, y = 9.111974, z = 44.01061 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1218] = {	id = 1218, pos = { x = -33.25488, y = 8.965033, z = 47.28321 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1219] = {	id = 1219, pos = { x = -33.78922, y = 8.893667, z = 55.24586 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1220] = {	id = 1220, pos = { x = -38.92981, y = 8.852368, z = 51.07874 }, randomPos = 0, randomRadius = 0, monsters = { 60915,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1221] = {	id = 1221, pos = { x = -13.06972, y = 8.927092, z = 46.3718 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1222] = {	id = 1222, pos = { x = -13.14585, y = 8.977846, z = 54.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1223] = {	id = 1223, pos = { x = -8.388633, y = 8.926172, z = 49.74634 }, randomPos = 0, randomRadius = 0, monsters = { 60916,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1224] = {	id = 1224, pos = { x = -22.3369, y = 9.050947, z = 43.81792 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1225] = {	id = 1225, pos = { x = -23.5467, y = 8.956652, z = 58.9676 }, randomPos = 0, randomRadius = 0, monsters = { 60912,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1226] = {	id = 1226, pos = { x = -32.12183, y = 8.964587, z = 50.52365 }, randomPos = 0, randomRadius = 0, monsters = { 60913,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1227] = {	id = 1227, pos = { x = -13.79174, y = 9.139952, z = 55.17506 }, randomPos = 0, randomRadius = 0, monsters = { 60913,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1228] = {	id = 1228, pos = { x = -31.42398, y = 8.967686, z = 51.57241 }, randomPos = 0, randomRadius = 0, monsters = { 60913,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1229] = {	id = 1229, pos = { x = -12.56043, y = 9.025417, z = 50.91461 }, randomPos = 0, randomRadius = 0, monsters = { 60913,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1230] = {	id = 1230, pos = { x = -25.05618, y = 9.183576, z = 58.37172 }, randomPos = 0, randomRadius = 0, monsters = { 60917,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1301] = {	id = 1301, pos = { x = -11.42172, y = 8.865156, z = 45.39095 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1302] = {	id = 1302, pos = { x = -10.83328, y = 8.881127, z = 58.39937 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1303] = {	id = 1303, pos = { x = -9.856999, y = 8.801448, z = 49.27277 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1304] = {	id = 1304, pos = { x = -9.041092, y = 8.852448, z = 54.60474 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1305] = {	id = 1305, pos = { x = -34.36192, y = 8.789296, z = 58.07845 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1306] = {	id = 1306, pos = { x = -36.25108, y = 9.049001, z = 43.4477 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1307] = {	id = 1307, pos = { x = -37.41606, y = 8.820045, z = 54.73414 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1308] = {	id = 1308, pos = { x = -38.00612, y = 8.801604, z = 48.26233 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1309] = {	id = 1309, pos = { x = -10.6876, y = 8.834614, z = 47.7531 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1310] = {	id = 1310, pos = { x = -10.01594, y = 8.808963, z = 55.33336 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1311] = {	id = 1311, pos = { x = -11.21961, y = 8.865876, z = 50.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60924,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1312] = {	id = 1312, pos = { x = -31.52577, y = 8.989296, z = 46.58984 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1313] = {	id = 1313, pos = { x = -31.88144, y = 8.940076, z = 53.74977 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1314] = {	id = 1314, pos = { x = -17.65512, y = 8.789296, z = 48.0 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1315] = {	id = 1315, pos = { x = -17.82113, y = 8.972347, z = 53.34894 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1316] = {	id = 1316, pos = { x = -23.95348, y = 8.960325, z = 58.83297 }, randomPos = 0, randomRadius = 0, monsters = { 60921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1317] = {	id = 1317, pos = { x = -23.3449, y = 9.111974, z = 44.01061 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1318] = {	id = 1318, pos = { x = -33.25488, y = 8.965033, z = 47.28321 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1319] = {	id = 1319, pos = { x = -33.78922, y = 8.893667, z = 55.24586 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1320] = {	id = 1320, pos = { x = -38.92981, y = 8.852368, z = 51.07874 }, randomPos = 0, randomRadius = 0, monsters = { 60925,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1321] = {	id = 1321, pos = { x = -13.06972, y = 8.927092, z = 46.3718 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1322] = {	id = 1322, pos = { x = -13.14585, y = 8.977846, z = 54.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1323] = {	id = 1323, pos = { x = -8.388633, y = 8.926172, z = 49.74634 }, randomPos = 0, randomRadius = 0, monsters = { 60926,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1324] = {	id = 1324, pos = { x = -22.3369, y = 9.050947, z = 43.81792 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1325] = {	id = 1325, pos = { x = -23.5467, y = 8.956652, z = 58.9676 }, randomPos = 0, randomRadius = 0, monsters = { 60922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1326] = {	id = 1326, pos = { x = -32.12183, y = 8.964587, z = 50.52365 }, randomPos = 0, randomRadius = 0, monsters = { 60923,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1327] = {	id = 1327, pos = { x = -13.79174, y = 9.139952, z = 55.17506 }, randomPos = 0, randomRadius = 0, monsters = { 60923,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1328] = {	id = 1328, pos = { x = -31.42398, y = 8.967686, z = 51.57241 }, randomPos = 0, randomRadius = 0, monsters = { 60923,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1329] = {	id = 1329, pos = { x = -12.56043, y = 9.025417, z = 50.91461 }, randomPos = 0, randomRadius = 0, monsters = { 60923,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1330] = {	id = 1330, pos = { x = -25.05618, y = 9.183576, z = 58.37172 }, randomPos = 0, randomRadius = 0, monsters = { 60927,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
