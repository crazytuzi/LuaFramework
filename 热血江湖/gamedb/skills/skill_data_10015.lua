----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[10015] = {
		[1] = {studyLvl = 12, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[2] = {studyLvl = 2, needCoin = 30, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[3] = {studyLvl = 3, needCoin = 50, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[4] = {studyLvl = 4, needCoin = 100, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[5] = {studyLvl = 5, needCoin = 200, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[6] = {studyLvl = 6, needCoin = 300, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[7] = {studyLvl = 7, needCoin = 450, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[8] = {studyLvl = 8, needCoin = 600, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[9] = {studyLvl = 9, needCoin = 800, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[10] = {studyLvl = 10, needCoin = 1000, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[11] = {studyLvl = 11, needCoin = 1300, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[12] = {studyLvl = 12, needCoin = 1600, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[13] = {studyLvl = 13, needCoin = 2000, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[14] = {studyLvl = 14, needCoin = 2400, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[15] = {studyLvl = 15, needCoin = 2850, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[16] = {studyLvl = 16, needCoin = 3400, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[17] = {studyLvl = 17, needCoin = 3950, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[18] = {studyLvl = 18, needCoin = 4600, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[19] = {studyLvl = 19, needCoin = 5300, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[20] = {studyLvl = 20, needCoin = 6050, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[21] = {studyLvl = 21, needCoin = 6900, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[22] = {studyLvl = 22, needCoin = 7800, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[23] = {studyLvl = 23, needCoin = 8800, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[24] = {studyLvl = 24, needCoin = 9900, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[25] = {studyLvl = 25, needCoin = 11050, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[26] = {studyLvl = 26, needCoin = 12250, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[27] = {studyLvl = 27, needCoin = 13600, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[28] = {studyLvl = 28, needCoin = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[29] = {studyLvl = 29, needCoin = 16500, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[30] = {studyLvl = 30, needCoin = 18100, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[31] = {studyLvl = 31, needCoin = 19800, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[32] = {studyLvl = 32, needCoin = 21650, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[33] = {studyLvl = 33, needCoin = 23550, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[34] = {studyLvl = 34, needCoin = 25550, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[35] = {studyLvl = 35, needCoin = 27700, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[36] = {studyLvl = 36, needCoin = 29950, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[37] = {studyLvl = 37, needCoin = 32300, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[38] = {studyLvl = 38, needCoin = 34800, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[39] = {studyLvl = 39, needCoin = 37400, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[40] = {studyLvl = 40, needCoin = 40150, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[41] = {studyLvl = 41, needCoin = 43060, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[42] = {studyLvl = 42, needCoin = 45160, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[43] = {studyLvl = 43, needCoin = 47310, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[44] = {studyLvl = 44, needCoin = 49510, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[45] = {studyLvl = 45, needCoin = 51760, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[46] = {studyLvl = 46, needCoin = 54060, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[47] = {studyLvl = 47, needCoin = 56410, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[48] = {studyLvl = 48, needCoin = 58810, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[49] = {studyLvl = 49, needCoin = 61260, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[50] = {studyLvl = 50, needCoin = 63760, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[51] = {studyLvl = 51, needCoin = 66310, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[52] = {studyLvl = 52, needCoin = 68910, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[53] = {studyLvl = 53, needCoin = 71560, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[54] = {studyLvl = 54, needCoin = 74260, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[55] = {studyLvl = 55, needCoin = 77010, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[56] = {studyLvl = 56, needCoin = 79810, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[57] = {studyLvl = 57, needCoin = 82660, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[58] = {studyLvl = 58, needCoin = 85560, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[59] = {studyLvl = 59, needCoin = 88510, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[60] = {studyLvl = 60, needCoin = 91510, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[61] = {studyLvl = 61, needCoin = 94560, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[62] = {studyLvl = 62, needCoin = 97660, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[63] = {studyLvl = 63, needCoin = 100810, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[64] = {studyLvl = 64, needCoin = 104010, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[65] = {studyLvl = 65, needCoin = 107260, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[66] = {studyLvl = 66, needCoin = 110560, needItemID = 65714, needItemNum = 5, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[67] = {studyLvl = 67, needCoin = 113910, needItemID = 65714, needItemNum = 6, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[68] = {studyLvl = 68, needCoin = 117310, needItemID = 65714, needItemNum = 7, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[69] = {studyLvl = 69, needCoin = 120760, needItemID = 65714, needItemNum = 8, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[70] = {studyLvl = 70, needCoin = 124260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[71] = {studyLvl = 71, needCoin = 127760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[72] = {studyLvl = 72, needCoin = 131260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[73] = {studyLvl = 73, needCoin = 134760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[74] = {studyLvl = 74, needCoin = 138260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[75] = {studyLvl = 75, needCoin = 141760, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[76] = {studyLvl = 76, needCoin = 145260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[77] = {studyLvl = 77, needCoin = 148760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[78] = {studyLvl = 78, needCoin = 152260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[79] = {studyLvl = 79, needCoin = 155760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[80] = {studyLvl = 80, needCoin = 159260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[81] = {studyLvl = 81, needCoin = 162760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[82] = {studyLvl = 82, needCoin = 166260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[83] = {studyLvl = 83, needCoin = 169760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[84] = {studyLvl = 84, needCoin = 173260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[85] = {studyLvl = 85, needCoin = 176760, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[86] = {studyLvl = 86, needCoin = 180260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[87] = {studyLvl = 87, needCoin = 183760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[88] = {studyLvl = 88, needCoin = 187260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[89] = {studyLvl = 89, needCoin = 190760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[90] = {studyLvl = 90, needCoin = 194260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[91] = {studyLvl = 91, needCoin = 197760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[92] = {studyLvl = 92, needCoin = 201260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[93] = {studyLvl = 93, needCoin = 204760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[94] = {studyLvl = 94, needCoin = 208260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[95] = {studyLvl = 95, needCoin = 211760, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[96] = {studyLvl = 96, needCoin = 215260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[97] = {studyLvl = 97, needCoin = 218760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[98] = {studyLvl = 98, needCoin = 222260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[99] = {studyLvl = 99, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[100] = {studyLvl = 100, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[101] = {studyLvl = 101, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[102] = {studyLvl = 102, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[103] = {studyLvl = 103, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[104] = {studyLvl = 104, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[105] = {studyLvl = 105, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[106] = {studyLvl = 106, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[107] = {studyLvl = 107, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[108] = {studyLvl = 108, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[109] = {studyLvl = 109, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[110] = {studyLvl = 110, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[111] = {studyLvl = 111, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[112] = {studyLvl = 112, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[113] = {studyLvl = 113, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[114] = {studyLvl = 114, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[115] = {studyLvl = 115, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[116] = {studyLvl = 116, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[117] = {studyLvl = 117, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[118] = {studyLvl = 118, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[119] = {studyLvl = 119, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[120] = {studyLvl = 120, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[121] = {studyLvl = 121, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[122] = {studyLvl = 122, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[123] = {studyLvl = 123, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[124] = {studyLvl = 124, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[125] = {studyLvl = 125, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[126] = {studyLvl = 126, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[127] = {studyLvl = 127, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[128] = {studyLvl = 128, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[129] = {studyLvl = 129, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[130] = {studyLvl = 130, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[131] = {studyLvl = 131, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[132] = {studyLvl = 132, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[133] = {studyLvl = 133, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[134] = {studyLvl = 134, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[135] = {studyLvl = 135, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[136] = {studyLvl = 136, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[137] = {studyLvl = 137, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[138] = {studyLvl = 138, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[139] = {studyLvl = 139, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[140] = {studyLvl = 140, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[141] = {studyLvl = 141, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[142] = {studyLvl = 142, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[143] = {studyLvl = 143, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[144] = {studyLvl = 144, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[145] = {studyLvl = 145, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[146] = {studyLvl = 146, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[147] = {studyLvl = 147, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[148] = {studyLvl = 148, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[149] = {studyLvl = 149, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
		[150] = {studyLvl = 150, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 563, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
