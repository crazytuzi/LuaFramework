----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[52203] = {
		[1] = {events = {{damage = {odds = 10000, arg2 = 135.0, realmAddon = 0.05, }, }, },},
		[2] = {studyLvl = 2, needCoin = 30, events = {{damage = {odds = 10000, arg2 = 150.0, realmAddon = 0.05, }, }, },},
		[3] = {studyLvl = 3, needCoin = 50, events = {{damage = {odds = 10000, arg2 = 165.0, realmAddon = 0.05, }, }, },},
		[4] = {studyLvl = 4, needCoin = 100, events = {{damage = {odds = 10000, arg2 = 180.0, realmAddon = 0.05, }, }, },},
		[5] = {studyLvl = 5, needCoin = 200, events = {{damage = {odds = 10000, arg2 = 195.0, realmAddon = 0.05, }, }, },},
		[6] = {studyLvl = 6, needCoin = 300, events = {{damage = {odds = 10000, arg2 = 210.0, realmAddon = 0.05, }, }, },},
		[7] = {studyLvl = 7, needCoin = 450, events = {{damage = {odds = 10000, arg2 = 225.0, realmAddon = 0.05, }, }, },},
		[8] = {studyLvl = 8, needCoin = 600, events = {{damage = {odds = 10000, arg2 = 240.0, realmAddon = 0.05, }, }, },},
		[9] = {studyLvl = 9, needCoin = 800, events = {{damage = {odds = 10000, arg2 = 255.0, realmAddon = 0.05, }, }, },},
		[10] = {studyLvl = 10, needCoin = 1000, events = {{damage = {odds = 10000, arg2 = 270.0, realmAddon = 0.05, }, }, },},
		[11] = {studyLvl = 11, needCoin = 1300, events = {{damage = {odds = 10000, arg2 = 285.0, realmAddon = 0.05, }, }, },},
		[12] = {studyLvl = 12, needCoin = 1600, events = {{damage = {odds = 10000, arg2 = 300.0, realmAddon = 0.05, }, }, },},
		[13] = {studyLvl = 13, needCoin = 2000, events = {{damage = {odds = 10000, arg2 = 315.0, realmAddon = 0.05, }, }, },},
		[14] = {studyLvl = 14, needCoin = 2400, events = {{damage = {odds = 10000, arg2 = 330.0, realmAddon = 0.05, }, }, },},
		[15] = {studyLvl = 15, needCoin = 2850, events = {{damage = {odds = 10000, arg2 = 345.0, realmAddon = 0.05, }, }, },},
		[16] = {studyLvl = 16, needCoin = 3400, events = {{damage = {odds = 10000, arg2 = 360.0, realmAddon = 0.05, }, }, },},
		[17] = {studyLvl = 17, needCoin = 3950, events = {{damage = {odds = 10000, arg2 = 375.0, realmAddon = 0.05, }, }, },},
		[18] = {studyLvl = 18, needCoin = 4600, events = {{damage = {odds = 10000, arg2 = 390.0, realmAddon = 0.05, }, }, },},
		[19] = {studyLvl = 19, needCoin = 5300, events = {{damage = {odds = 10000, arg2 = 405.0, realmAddon = 0.05, }, }, },},
		[20] = {studyLvl = 20, needCoin = 6050, events = {{damage = {odds = 10000, arg2 = 420.0, realmAddon = 0.05, }, }, },},
		[21] = {studyLvl = 21, needCoin = 6900, events = {{damage = {odds = 10000, arg2 = 435.0, realmAddon = 0.05, }, }, },},
		[22] = {studyLvl = 22, needCoin = 7800, events = {{damage = {odds = 10000, arg2 = 450.0, realmAddon = 0.05, }, }, },},
		[23] = {studyLvl = 23, needCoin = 8800, events = {{damage = {odds = 10000, arg2 = 465.0, realmAddon = 0.05, }, }, },},
		[24] = {studyLvl = 24, needCoin = 9900, events = {{damage = {odds = 10000, arg2 = 480.0, realmAddon = 0.05, }, }, },},
		[25] = {studyLvl = 25, needCoin = 11050, events = {{damage = {odds = 10000, arg2 = 495.0, realmAddon = 0.05, }, }, },},
		[26] = {studyLvl = 26, needCoin = 12250, events = {{damage = {odds = 10000, arg2 = 510.0, realmAddon = 0.05, }, }, },},
		[27] = {studyLvl = 27, needCoin = 13600, events = {{damage = {odds = 10000, arg2 = 525.0, realmAddon = 0.05, }, }, },},
		[28] = {studyLvl = 28, needCoin = 15000, events = {{damage = {odds = 10000, arg2 = 540.0, realmAddon = 0.05, }, }, },},
		[29] = {studyLvl = 29, needCoin = 16500, events = {{damage = {odds = 10000, arg2 = 555.0, realmAddon = 0.05, }, }, },},
		[30] = {studyLvl = 30, needCoin = 18100, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 570.0, realmAddon = 0.05, }, }, },},
		[31] = {studyLvl = 31, needCoin = 19800, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 585.0, realmAddon = 0.05, }, }, },},
		[32] = {studyLvl = 32, needCoin = 21650, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 600.0, realmAddon = 0.05, }, }, },},
		[33] = {studyLvl = 33, needCoin = 23550, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 615.0, realmAddon = 0.05, }, }, },},
		[34] = {studyLvl = 34, needCoin = 25550, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 630.0, realmAddon = 0.05, }, }, },},
		[35] = {studyLvl = 35, needCoin = 27700, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 645.0, realmAddon = 0.05, }, }, },},
		[36] = {studyLvl = 36, needCoin = 29950, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 660.0, realmAddon = 0.05, }, }, },},
		[37] = {studyLvl = 37, needCoin = 32300, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 675.0, realmAddon = 0.05, }, }, },},
		[38] = {studyLvl = 38, needCoin = 34800, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 690.0, realmAddon = 0.05, }, }, },},
		[39] = {studyLvl = 39, needCoin = 37400, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 705.0, realmAddon = 0.05, }, }, },},
		[40] = {studyLvl = 40, needCoin = 40150, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 778.0, realmAddon = 0.05, }, }, },},
		[41] = {studyLvl = 41, needCoin = 43060, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 823.0, realmAddon = 0.05, }, }, },},
		[42] = {studyLvl = 42, needCoin = 45160, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 870.0, realmAddon = 0.05, }, }, },},
		[43] = {studyLvl = 43, needCoin = 47310, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 920.0, realmAddon = 0.05, }, }, },},
		[44] = {studyLvl = 44, needCoin = 49510, needItemID = 65714, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 975.0, realmAddon = 0.05, }, }, },},
		[45] = {studyLvl = 45, needCoin = 51760, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1039.0, realmAddon = 0.05, }, }, },},
		[46] = {studyLvl = 46, needCoin = 54060, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1118.0, realmAddon = 0.05, }, }, },},
		[47] = {studyLvl = 47, needCoin = 56410, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1187.0, realmAddon = 0.05, }, }, },},
		[48] = {studyLvl = 48, needCoin = 58810, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1255.0, realmAddon = 0.05, }, }, },},
		[49] = {studyLvl = 49, needCoin = 61260, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1350.0, realmAddon = 0.05, }, }, },},
		[50] = {studyLvl = 50, needCoin = 63760, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1450.0, realmAddon = 0.05, }, }, },},
		[51] = {studyLvl = 51, needCoin = 66310, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1552.0, realmAddon = 0.05, }, }, },},
		[52] = {studyLvl = 52, needCoin = 68910, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1696.0, realmAddon = 0.05, }, }, },},
		[53] = {studyLvl = 53, needCoin = 71560, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1894.0, realmAddon = 0.05, }, }, },},
		[54] = {studyLvl = 54, needCoin = 74260, needItemID = 65714, needItemNum = 2, events = {{damage = {odds = 10000, arg2 = 1967.0, realmAddon = 0.05, }, }, },},
		[55] = {studyLvl = 55, needCoin = 77010, needItemID = 65714, needItemNum = 3, events = {{damage = {odds = 10000, arg2 = 2192.0, realmAddon = 0.05, }, }, },},
		[56] = {studyLvl = 56, needCoin = 79810, needItemID = 65714, needItemNum = 3, events = {{damage = {odds = 10000, arg2 = 2383.0, realmAddon = 0.05, }, }, },},
		[57] = {studyLvl = 57, needCoin = 82660, needItemID = 65714, needItemNum = 3, events = {{damage = {odds = 10000, arg2 = 2508.0, realmAddon = 0.05, }, }, },},
		[58] = {studyLvl = 58, needCoin = 85560, needItemID = 65714, needItemNum = 3, events = {{damage = {odds = 10000, arg2 = 2589.0, realmAddon = 0.05, }, }, },},
		[59] = {studyLvl = 59, needCoin = 88510, needItemID = 65714, needItemNum = 3, events = {{damage = {odds = 10000, arg2 = 2707.0, realmAddon = 0.05, }, }, },},
		[60] = {studyLvl = 60, needCoin = 91510, needItemID = 65714, needItemNum = 4, events = {{damage = {odds = 10000, arg2 = 2882.0, realmAddon = 0.05, }, }, },},
		[61] = {studyLvl = 61, needCoin = 94560, needItemID = 65714, needItemNum = 4, events = {{damage = {odds = 10000, arg2 = 3016.0, realmAddon = 0.05, }, }, },},
		[62] = {studyLvl = 62, needCoin = 97660, needItemID = 65714, needItemNum = 4, events = {{damage = {odds = 10000, arg2 = 3097.0, realmAddon = 0.05, }, }, },},
		[63] = {studyLvl = 63, needCoin = 100810, needItemID = 65714, needItemNum = 4, events = {{damage = {odds = 10000, arg2 = 3210.0, realmAddon = 0.05, }, }, },},
		[64] = {studyLvl = 64, needCoin = 104010, needItemID = 65714, needItemNum = 4, events = {{damage = {odds = 10000, arg2 = 3370.0, realmAddon = 0.05, }, }, },},
		[65] = {studyLvl = 65, needCoin = 107260, needItemID = 66312, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 3592.0, realmAddon = 0.05, }, }, },},
		[66] = {studyLvl = 66, needCoin = 110560, needItemID = 65714, needItemNum = 5, events = {{damage = {odds = 10000, arg2 = 4057.0, realmAddon = 0.05, }, }, },},
		[67] = {studyLvl = 67, needCoin = 113910, needItemID = 65714, needItemNum = 6, events = {{damage = {odds = 10000, arg2 = 4233.0, realmAddon = 0.05, }, }, },},
		[68] = {studyLvl = 68, needCoin = 117310, needItemID = 65714, needItemNum = 7, events = {{damage = {odds = 10000, arg2 = 4438.0, realmAddon = 0.05, }, }, },},
		[69] = {studyLvl = 69, needCoin = 120760, needItemID = 65714, needItemNum = 8, events = {{damage = {odds = 10000, arg2 = 4667.0, realmAddon = 0.05, }, }, },},
		[70] = {studyLvl = 70, needCoin = 124260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 5182.0, realmAddon = 0.05, }, }, },},
		[71] = {studyLvl = 71, needCoin = 127760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 5564.0, realmAddon = 0.05, }, }, },},
		[72] = {studyLvl = 72, needCoin = 131260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 5933.0, realmAddon = 0.05, }, }, },},
		[73] = {studyLvl = 73, needCoin = 134760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 6230.0, realmAddon = 0.05, }, }, },},
		[74] = {studyLvl = 74, needCoin = 138260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 6745.0, realmAddon = 0.05, }, }, },},
		[75] = {studyLvl = 75, needCoin = 141760, needItemID = 66312, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 7166.0, realmAddon = 0.05, }, }, },},
		[76] = {studyLvl = 76, needCoin = 145260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 7501.0, realmAddon = 0.05, }, }, },},
		[77] = {studyLvl = 77, needCoin = 148760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 8064.0, realmAddon = 0.05, }, }, },},
		[78] = {studyLvl = 78, needCoin = 152260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 8487.0, realmAddon = 0.05, }, }, },},
		[79] = {studyLvl = 79, needCoin = 155760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 8854.0, realmAddon = 0.05, }, }, },},
		[80] = {studyLvl = 80, needCoin = 159260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 9776.0, realmAddon = 0.05, }, }, },},
		[81] = {studyLvl = 81, needCoin = 162760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 10125.0, realmAddon = 0.05, }, }, },},
		[82] = {studyLvl = 82, needCoin = 166260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 10459.0, realmAddon = 0.05, }, }, },},
		[83] = {studyLvl = 83, needCoin = 169760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 11077.0, realmAddon = 0.05, }, }, },},
		[84] = {studyLvl = 84, needCoin = 173260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 11557.0, realmAddon = 0.05, }, }, },},
		[85] = {studyLvl = 85, needCoin = 176760, needItemID = 66312, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 12323.0, realmAddon = 0.05, }, }, },},
		[86] = {studyLvl = 86, needCoin = 180260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 13112.0, realmAddon = 0.05, }, }, },},
		[87] = {studyLvl = 87, needCoin = 183760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 13532.0, realmAddon = 0.05, }, }, },},
		[88] = {studyLvl = 88, needCoin = 187260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 14111.0, realmAddon = 0.05, }, }, },},
		[89] = {studyLvl = 89, needCoin = 190760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 14751.0, realmAddon = 0.05, }, }, },},
		[90] = {studyLvl = 90, needCoin = 194260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 15097.0, realmAddon = 0.05, }, }, },},
		[91] = {studyLvl = 91, needCoin = 197760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 15400.0, realmAddon = 0.05, }, }, },},
		[92] = {studyLvl = 92, needCoin = 201260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 16060.0, realmAddon = 0.05, }, }, },},
		[93] = {studyLvl = 93, needCoin = 204760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 16462.0, realmAddon = 0.05, }, }, },},
		[94] = {studyLvl = 94, needCoin = 208260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 16787.0, realmAddon = 0.05, }, }, },},
		[95] = {studyLvl = 95, needCoin = 211760, needItemID = 66312, needItemNum = 1, events = {{damage = {odds = 10000, arg2 = 17531.0, realmAddon = 0.05, }, }, },},
		[96] = {studyLvl = 96, needCoin = 215260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 18006.0, realmAddon = 0.05, }, }, },},
		[97] = {studyLvl = 97, needCoin = 218760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 18356.0, realmAddon = 0.05, }, }, },},
		[98] = {studyLvl = 98, needCoin = 222260, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 19129.0, realmAddon = 0.05, }, }, },},
		[99] = {studyLvl = 99, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 19602.0, realmAddon = 0.05, }, }, },},
		[100] = {studyLvl = 100, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 20166.0, realmAddon = 0.05, }, }, },},
		[101] = {studyLvl = 101, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 20978.0, realmAddon = 0.05, }, }, },},
		[102] = {studyLvl = 102, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 21603.0, realmAddon = 0.05, }, }, },},
		[103] = {studyLvl = 103, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 22070.0, realmAddon = 0.05, }, }, },},
		[104] = {studyLvl = 104, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 23065.0, realmAddon = 0.05, }, }, },},
		[105] = {studyLvl = 105, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 23592.0, realmAddon = 0.05, }, }, },},
		[106] = {studyLvl = 106, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 24019.0, realmAddon = 0.05, }, }, },},
		[107] = {studyLvl = 107, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 24982.0, realmAddon = 0.05, }, }, },},
		[108] = {studyLvl = 108, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 25577.0, realmAddon = 0.05, }, }, },},
		[109] = {studyLvl = 109, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 26119.0, realmAddon = 0.05, }, }, },},
		[110] = {studyLvl = 110, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 27215.0, realmAddon = 0.05, }, }, },},
		[111] = {studyLvl = 111, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 27738.0, realmAddon = 0.05, }, }, },},
		[112] = {studyLvl = 112, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 28300.0, realmAddon = 0.05, }, }, },},
		[113] = {studyLvl = 113, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 29493.0, realmAddon = 0.05, }, }, },},
		[114] = {studyLvl = 114, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 30001.0, realmAddon = 0.05, }, }, },},
		[115] = {studyLvl = 115, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 30594.0, realmAddon = 0.05, }, }, },},
		[116] = {studyLvl = 116, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 31900.0, realmAddon = 0.05, }, }, },},
		[117] = {studyLvl = 117, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 32485.0, realmAddon = 0.05, }, }, },},
		[118] = {studyLvl = 118, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 33430.0, realmAddon = 0.05, }, }, },},
		[119] = {studyLvl = 119, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 34097.0, realmAddon = 0.05, }, }, },},
		[120] = {studyLvl = 120, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 34758.0, realmAddon = 0.05, }, }, },},
		[121] = {studyLvl = 121, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 35337.0, realmAddon = 0.05, }, }, },},
		[122] = {studyLvl = 122, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 35926.0, realmAddon = 0.05, }, }, },},
		[123] = {studyLvl = 123, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 36577.0, realmAddon = 0.05, }, }, },},
		[124] = {studyLvl = 124, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 37183.0, realmAddon = 0.05, }, }, },},
		[125] = {studyLvl = 125, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 37800.0, realmAddon = 0.05, }, }, },},
		[126] = {studyLvl = 126, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 38425.0, realmAddon = 0.05, }, }, },},
		[127] = {studyLvl = 127, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 39060.0, realmAddon = 0.05, }, }, },},
		[128] = {studyLvl = 128, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 39704.0, realmAddon = 0.05, }, }, },},
		[129] = {studyLvl = 129, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 40545.0, realmAddon = 0.05, }, }, },},
		[130] = {studyLvl = 130, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 41209.0, realmAddon = 0.05, }, }, },},
		[131] = {studyLvl = 131, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 41883.0, realmAddon = 0.05, }, }, },},
		[132] = {studyLvl = 132, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 42566.0, realmAddon = 0.05, }, }, },},
		[133] = {studyLvl = 133, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 43260.0, realmAddon = 0.05, }, }, },},
		[134] = {studyLvl = 134, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 43963.0, realmAddon = 0.05, }, }, },},
		[135] = {studyLvl = 135, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 44739.0, realmAddon = 0.05, }, }, },},
		[136] = {studyLvl = 136, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 45463.0, realmAddon = 0.05, }, }, },},
		[137] = {studyLvl = 137, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 46197.0, realmAddon = 0.05, }, }, },},
		[138] = {studyLvl = 138, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 46941.0, realmAddon = 0.05, }, }, },},
		[139] = {studyLvl = 139, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 47697.0, realmAddon = 0.05, }, }, },},
		[140] = {studyLvl = 140, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 48461.0, realmAddon = 0.05, }, }, },},
		[141] = {studyLvl = 141, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 49297.0, realmAddon = 0.05, }, }, },},
		[142] = {studyLvl = 142, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 50083.0, realmAddon = 0.05, }, }, },},
		[143] = {studyLvl = 143, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 50879.0, realmAddon = 0.05, }, }, },},
		[144] = {studyLvl = 144, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 51687.0, realmAddon = 0.05, }, }, },},
		[145] = {studyLvl = 145, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 52506.0, realmAddon = 0.05, }, }, },},
		[146] = {studyLvl = 146, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 53335.0, realmAddon = 0.05, }, }, },},
		[147] = {studyLvl = 147, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 54238.0, realmAddon = 0.05, }, }, },},
		[148] = {studyLvl = 148, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 55090.0, realmAddon = 0.05, }, }, },},
		[149] = {studyLvl = 149, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 55954.0, realmAddon = 0.05, }, }, },},
		[150] = {studyLvl = 150, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{damage = {odds = 10000, arg2 = 56830.0, realmAddon = 0.05, }, }, },},
	},

};
function get_db_table()
	return level;
end
