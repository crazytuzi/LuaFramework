----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[1601] = {	id = 1601, pos = { x = -11.42172, y = 8.865156, z = 45.39095 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1602] = {	id = 1602, pos = { x = -10.83328, y = 8.881127, z = 58.39937 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1603] = {	id = 1603, pos = { x = -9.856999, y = 8.801448, z = 49.27277 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1604] = {	id = 1604, pos = { x = -9.041092, y = 8.852448, z = 54.60474 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1605] = {	id = 1605, pos = { x = -34.36192, y = 8.789296, z = 58.07845 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1606] = {	id = 1606, pos = { x = -36.25108, y = 9.049001, z = 43.4477 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1607] = {	id = 1607, pos = { x = -37.41606, y = 8.820045, z = 54.73414 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1608] = {	id = 1608, pos = { x = -38.00612, y = 8.801604, z = 48.26233 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1609] = {	id = 1609, pos = { x = -10.6876, y = 8.834614, z = 47.7531 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1610] = {	id = 1610, pos = { x = -10.01594, y = 8.808963, z = 55.33336 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1611] = {	id = 1611, pos = { x = -11.21961, y = 8.865876, z = 50.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60954,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1612] = {	id = 1612, pos = { x = -31.52577, y = 8.989296, z = 46.58984 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1613] = {	id = 1613, pos = { x = -31.88144, y = 8.940076, z = 53.74977 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1614] = {	id = 1614, pos = { x = -17.65512, y = 8.789296, z = 48.0 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1615] = {	id = 1615, pos = { x = -17.82113, y = 8.972347, z = 53.34894 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1616] = {	id = 1616, pos = { x = -23.95348, y = 8.960325, z = 58.83297 }, randomPos = 0, randomRadius = 0, monsters = { 60951,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1617] = {	id = 1617, pos = { x = -23.3449, y = 9.111974, z = 44.01061 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1618] = {	id = 1618, pos = { x = -33.25488, y = 8.965033, z = 47.28321 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1619] = {	id = 1619, pos = { x = -33.78922, y = 8.893667, z = 55.24586 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1620] = {	id = 1620, pos = { x = -38.92981, y = 8.852368, z = 51.07874 }, randomPos = 0, randomRadius = 0, monsters = { 60955,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1621] = {	id = 1621, pos = { x = -13.06972, y = 8.927092, z = 46.3718 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1622] = {	id = 1622, pos = { x = -13.14585, y = 8.977846, z = 54.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1623] = {	id = 1623, pos = { x = -8.388633, y = 8.926172, z = 49.74634 }, randomPos = 0, randomRadius = 0, monsters = { 60956,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1624] = {	id = 1624, pos = { x = -22.3369, y = 9.050947, z = 43.81792 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1625] = {	id = 1625, pos = { x = -23.5467, y = 8.956652, z = 58.9676 }, randomPos = 0, randomRadius = 0, monsters = { 60952,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1626] = {	id = 1626, pos = { x = -32.12183, y = 8.964587, z = 50.52365 }, randomPos = 0, randomRadius = 0, monsters = { 60953,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1627] = {	id = 1627, pos = { x = -13.79174, y = 9.139952, z = 55.17506 }, randomPos = 0, randomRadius = 0, monsters = { 60953,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1628] = {	id = 1628, pos = { x = -31.42398, y = 8.967686, z = 51.57241 }, randomPos = 0, randomRadius = 0, monsters = { 60953,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1629] = {	id = 1629, pos = { x = -12.56043, y = 9.025417, z = 50.91461 }, randomPos = 0, randomRadius = 0, monsters = { 60953,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1630] = {	id = 1630, pos = { x = -25.05618, y = 9.183576, z = 58.37172 }, randomPos = 0, randomRadius = 0, monsters = { 60957,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1701] = {	id = 1701, pos = { x = -11.42172, y = 8.865156, z = 45.39095 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1702] = {	id = 1702, pos = { x = -10.83328, y = 8.881127, z = 58.39937 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1703] = {	id = 1703, pos = { x = -9.856999, y = 8.801448, z = 49.27277 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1704] = {	id = 1704, pos = { x = -9.041092, y = 8.852448, z = 54.60474 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1705] = {	id = 1705, pos = { x = -34.36192, y = 8.789296, z = 58.07845 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1706] = {	id = 1706, pos = { x = -36.25108, y = 9.049001, z = 43.4477 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1707] = {	id = 1707, pos = { x = -37.41606, y = 8.820045, z = 54.73414 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1708] = {	id = 1708, pos = { x = -38.00612, y = 8.801604, z = 48.26233 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1709] = {	id = 1709, pos = { x = -10.6876, y = 8.834614, z = 47.7531 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1710] = {	id = 1710, pos = { x = -10.01594, y = 8.808963, z = 55.33336 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1711] = {	id = 1711, pos = { x = -11.21961, y = 8.865876, z = 50.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60964,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1712] = {	id = 1712, pos = { x = -31.52577, y = 8.989296, z = 46.58984 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1713] = {	id = 1713, pos = { x = -31.88144, y = 8.940076, z = 53.74977 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1714] = {	id = 1714, pos = { x = -17.65512, y = 8.789296, z = 48.0 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1715] = {	id = 1715, pos = { x = -17.82113, y = 8.972347, z = 53.34894 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1716] = {	id = 1716, pos = { x = -23.95348, y = 8.960325, z = 58.83297 }, randomPos = 0, randomRadius = 0, monsters = { 60961,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1717] = {	id = 1717, pos = { x = -23.3449, y = 9.111974, z = 44.01061 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1718] = {	id = 1718, pos = { x = -33.25488, y = 8.965033, z = 47.28321 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1719] = {	id = 1719, pos = { x = -33.78922, y = 8.893667, z = 55.24586 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1720] = {	id = 1720, pos = { x = -38.92981, y = 8.852368, z = 51.07874 }, randomPos = 0, randomRadius = 0, monsters = { 60965,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1721] = {	id = 1721, pos = { x = -13.06972, y = 8.927092, z = 46.3718 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1722] = {	id = 1722, pos = { x = -13.14585, y = 8.977846, z = 54.8452 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1723] = {	id = 1723, pos = { x = -8.388633, y = 8.926172, z = 49.74634 }, randomPos = 0, randomRadius = 0, monsters = { 60966,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1724] = {	id = 1724, pos = { x = -22.3369, y = 9.050947, z = 43.81792 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1725] = {	id = 1725, pos = { x = -23.5467, y = 8.956652, z = 58.9676 }, randomPos = 0, randomRadius = 0, monsters = { 60962,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1726] = {	id = 1726, pos = { x = -32.12183, y = 8.964587, z = 50.52365 }, randomPos = 0, randomRadius = 0, monsters = { 60963,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1727] = {	id = 1727, pos = { x = -13.79174, y = 9.139952, z = 55.17506 }, randomPos = 0, randomRadius = 0, monsters = { 60963,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1728] = {	id = 1728, pos = { x = -31.42398, y = 8.967686, z = 51.57241 }, randomPos = 0, randomRadius = 0, monsters = { 60963,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1729] = {	id = 1729, pos = { x = -12.56043, y = 9.025417, z = 50.91461 }, randomPos = 0, randomRadius = 0, monsters = { 60963,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[1730] = {	id = 1730, pos = { x = -25.05618, y = 9.183576, z = 58.37172 }, randomPos = 0, randomRadius = 0, monsters = { 60967,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
