----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[72104] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 24, skillrealpower = {0,153,312,481,661,}, },
		[2] = {studyLvl = 2, needCoin = 30, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 26, skillrealpower = {0,153,312,481,661,}, },
		[3] = {studyLvl = 3, needCoin = 50, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 30, skillrealpower = {0,153,312,481,661,}, },
		[4] = {studyLvl = 4, needCoin = 100, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 34, skillrealpower = {0,153,312,481,661,}, },
		[5] = {studyLvl = 5, needCoin = 200, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 38, skillrealpower = {0,153,312,481,661,}, },
		[6] = {studyLvl = 6, needCoin = 300, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 42, skillrealpower = {0,153,312,481,661,}, },
		[7] = {studyLvl = 7, needCoin = 450, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 48, skillrealpower = {0,153,312,481,661,}, },
		[8] = {studyLvl = 8, needCoin = 600, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 54, skillrealpower = {0,153,312,481,661,}, },
		[9] = {studyLvl = 9, needCoin = 800, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 60, skillrealpower = {0,153,312,481,661,}, },
		[10] = {studyLvl = 10, needCoin = 1000, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 66, skillrealpower = {0,153,312,481,661,}, },
		[11] = {studyLvl = 11, needCoin = 1300, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 72, skillrealpower = {0,153,312,481,661,}, },
		[12] = {studyLvl = 12, needCoin = 1600, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 78, skillrealpower = {0,153,312,481,661,}, },
		[13] = {studyLvl = 13, needCoin = 2000, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 84, skillrealpower = {0,153,312,481,661,}, },
		[14] = {studyLvl = 14, needCoin = 2400, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 90, skillrealpower = {0,153,312,481,661,}, },
		[15] = {studyLvl = 15, needCoin = 2850, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 96, skillrealpower = {0,153,312,481,661,}, },
		[16] = {studyLvl = 16, needCoin = 3400, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 102, skillrealpower = {0,153,312,481,661,}, },
		[17] = {studyLvl = 17, needCoin = 3950, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 108, skillrealpower = {0,153,312,481,661,}, },
		[18] = {studyLvl = 18, needCoin = 4600, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 114, skillrealpower = {0,153,312,481,661,}, },
		[19] = {studyLvl = 19, needCoin = 5300, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 120, skillrealpower = {0,153,312,481,661,}, },
		[20] = {studyLvl = 20, needCoin = 6050, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 126, skillrealpower = {0,153,312,481,661,}, },
		[21] = {studyLvl = 21, needCoin = 6900, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 132, skillrealpower = {0,153,312,481,661,}, },
		[22] = {studyLvl = 22, needCoin = 7800, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 138, skillrealpower = {0,153,312,481,661,}, },
		[23] = {studyLvl = 23, needCoin = 8800, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 144, skillrealpower = {0,153,312,481,661,}, },
		[24] = {studyLvl = 24, needCoin = 9900, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 150, skillrealpower = {0,153,312,481,661,}, },
		[25] = {studyLvl = 25, needCoin = 11050, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 156, skillrealpower = {0,153,312,481,661,}, },
		[26] = {studyLvl = 26, needCoin = 12250, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 164, skillrealpower = {0,153,312,481,661,}, },
		[27] = {studyLvl = 27, needCoin = 13600, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 172, skillrealpower = {0,153,312,481,661,}, },
		[28] = {studyLvl = 28, needCoin = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 180, skillrealpower = {0,153,312,481,661,}, },
		[29] = {studyLvl = 29, needCoin = 16500, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 188, skillrealpower = {0,153,312,481,661,}, },
		[30] = {studyLvl = 30, needCoin = 18100, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 198, skillrealpower = {0,153,312,481,661,}, },
		[31] = {studyLvl = 31, needCoin = 19800, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 208, skillrealpower = {0,153,312,481,661,}, },
		[32] = {studyLvl = 32, needCoin = 21650, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 218, skillrealpower = {0,153,312,481,661,}, },
		[33] = {studyLvl = 33, needCoin = 23550, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 228, skillrealpower = {0,153,312,481,661,}, },
		[34] = {studyLvl = 34, needCoin = 25550, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 238, skillrealpower = {0,153,312,481,661,}, },
		[35] = {studyLvl = 35, needCoin = 27700, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 248, skillrealpower = {0,153,312,481,661,}, },
		[36] = {studyLvl = 36, needCoin = 29950, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 258, skillrealpower = {0,153,312,481,661,}, },
		[37] = {studyLvl = 37, needCoin = 32300, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 268, skillrealpower = {0,153,312,481,661,}, },
		[38] = {studyLvl = 38, needCoin = 34800, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 278, skillrealpower = {0,153,312,481,661,}, },
		[39] = {studyLvl = 39, needCoin = 37400, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 288, skillrealpower = {0,153,312,481,661,}, },
		[40] = {studyLvl = 40, needCoin = 40150, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 298, skillrealpower = {0,153,312,481,661,}, },
		[41] = {studyLvl = 41, needCoin = 43060, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 308, skillrealpower = {0,153,312,481,661,}, },
		[42] = {studyLvl = 42, needCoin = 45160, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 318, skillrealpower = {0,153,312,481,661,}, },
		[43] = {studyLvl = 43, needCoin = 47310, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 330, skillrealpower = {0,153,312,481,661,}, },
		[44] = {studyLvl = 44, needCoin = 49510, needItemID = 65714, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 342, skillrealpower = {0,153,312,481,661,}, },
		[45] = {studyLvl = 45, needCoin = 51760, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 354, skillrealpower = {0,153,312,481,661,}, },
		[46] = {studyLvl = 46, needCoin = 54060, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 366, skillrealpower = {0,153,312,481,661,}, },
		[47] = {studyLvl = 47, needCoin = 56410, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 378, skillrealpower = {0,153,312,481,661,}, },
		[48] = {studyLvl = 48, needCoin = 58810, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 390, skillrealpower = {0,153,312,481,661,}, },
		[49] = {studyLvl = 49, needCoin = 61260, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 404, skillrealpower = {0,153,312,481,661,}, },
		[50] = {studyLvl = 50, needCoin = 63760, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 418, skillrealpower = {0,153,312,481,661,}, },
		[51] = {studyLvl = 51, needCoin = 66310, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 432, skillrealpower = {0,153,312,481,661,}, },
		[52] = {studyLvl = 52, needCoin = 68910, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 446, skillrealpower = {0,153,312,481,661,}, },
		[53] = {studyLvl = 53, needCoin = 71560, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 460, skillrealpower = {0,153,312,481,661,}, },
		[54] = {studyLvl = 54, needCoin = 74260, needItemID = 65714, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 474, skillrealpower = {0,153,312,481,661,}, },
		[55] = {studyLvl = 55, needCoin = 77010, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 488, skillrealpower = {0,153,312,481,661,}, },
		[56] = {studyLvl = 56, needCoin = 79810, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 502, skillrealpower = {0,153,312,481,661,}, },
		[57] = {studyLvl = 57, needCoin = 82660, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 518, skillrealpower = {0,153,312,481,661,}, },
		[58] = {studyLvl = 58, needCoin = 85560, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 534, skillrealpower = {0,153,312,481,661,}, },
		[59] = {studyLvl = 59, needCoin = 88510, needItemID = 65714, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 550, skillrealpower = {0,153,312,481,661,}, },
		[60] = {studyLvl = 60, needCoin = 91510, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 566, skillrealpower = {0,153,312,481,661,}, },
		[61] = {studyLvl = 61, needCoin = 94560, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 582, skillrealpower = {0,153,312,481,661,}, },
		[62] = {studyLvl = 62, needCoin = 97660, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 598, skillrealpower = {0,153,312,481,661,}, },
		[63] = {studyLvl = 63, needCoin = 100810, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 614, skillrealpower = {0,153,312,481,661,}, },
		[64] = {studyLvl = 64, needCoin = 104010, needItemID = 65714, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 632, skillrealpower = {0,153,312,481,661,}, },
		[65] = {studyLvl = 65, needCoin = 107260, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 650, skillrealpower = {0,153,312,481,661,}, },
		[66] = {studyLvl = 66, needCoin = 110560, needItemID = 65714, needItemNum = 5, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 668, skillrealpower = {0,153,312,481,661,}, },
		[67] = {studyLvl = 67, needCoin = 113910, needItemID = 65714, needItemNum = 6, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 686, skillrealpower = {0,153,312,481,661,}, },
		[68] = {studyLvl = 68, needCoin = 117310, needItemID = 65714, needItemNum = 7, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 704, skillrealpower = {0,153,312,481,661,}, },
		[69] = {studyLvl = 69, needCoin = 120760, needItemID = 65714, needItemNum = 8, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 722, skillrealpower = {0,153,312,481,661,}, },
		[70] = {studyLvl = 70, needCoin = 124260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 740, skillrealpower = {0,153,312,481,661,}, },
		[71] = {studyLvl = 71, needCoin = 127760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 758, skillrealpower = {0,153,312,481,661,}, },
		[72] = {studyLvl = 72, needCoin = 131260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 778, skillrealpower = {0,153,312,481,661,}, },
		[73] = {studyLvl = 73, needCoin = 134760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 798, skillrealpower = {0,153,312,481,661,}, },
		[74] = {studyLvl = 74, needCoin = 138260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 818, skillrealpower = {0,153,312,481,661,}, },
		[75] = {studyLvl = 75, needCoin = 141760, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 838, skillrealpower = {0,153,312,481,661,}, },
		[76] = {studyLvl = 76, needCoin = 145260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 858, skillrealpower = {0,153,312,481,661,}, },
		[77] = {studyLvl = 77, needCoin = 148760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 880, skillrealpower = {0,153,312,481,661,}, },
		[78] = {studyLvl = 78, needCoin = 152260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 902, skillrealpower = {0,153,312,481,661,}, },
		[79] = {studyLvl = 79, needCoin = 155760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 924, skillrealpower = {0,153,312,481,661,}, },
		[80] = {studyLvl = 80, needCoin = 159260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 946, skillrealpower = {0,153,312,481,661,}, },
		[81] = {studyLvl = 81, needCoin = 162760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 968, skillrealpower = {0,153,312,481,661,}, },
		[82] = {studyLvl = 82, needCoin = 166260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 990, skillrealpower = {0,153,312,481,661,}, },
		[83] = {studyLvl = 83, needCoin = 169760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1012, skillrealpower = {0,153,312,481,661,}, },
		[84] = {studyLvl = 84, needCoin = 173260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1036, skillrealpower = {0,153,312,481,661,}, },
		[85] = {studyLvl = 85, needCoin = 176760, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1060, skillrealpower = {0,153,312,481,661,}, },
		[86] = {studyLvl = 86, needCoin = 180260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1084, skillrealpower = {0,153,312,481,661,}, },
		[87] = {studyLvl = 87, needCoin = 183760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1108, skillrealpower = {0,153,312,481,661,}, },
		[88] = {studyLvl = 88, needCoin = 187260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1132, skillrealpower = {0,153,312,481,661,}, },
		[89] = {studyLvl = 89, needCoin = 190760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1156, skillrealpower = {0,153,312,481,661,}, },
		[90] = {studyLvl = 90, needCoin = 194260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1182, skillrealpower = {0,153,312,481,661,}, },
		[91] = {studyLvl = 91, needCoin = 197760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1208, skillrealpower = {0,153,312,481,661,}, },
		[92] = {studyLvl = 92, needCoin = 201260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1234, skillrealpower = {0,153,312,481,661,}, },
		[93] = {studyLvl = 93, needCoin = 204760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1260, skillrealpower = {0,153,312,481,661,}, },
		[94] = {studyLvl = 94, needCoin = 208260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1286, skillrealpower = {0,153,312,481,661,}, },
		[95] = {studyLvl = 95, needCoin = 211760, needItemID = 66312, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1314, skillrealpower = {0,153,312,481,661,}, },
		[96] = {studyLvl = 96, needCoin = 215260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1342, skillrealpower = {0,153,312,481,661,}, },
		[97] = {studyLvl = 97, needCoin = 218760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1370, skillrealpower = {0,153,312,481,661,}, },
		[98] = {studyLvl = 98, needCoin = 222260, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1398, skillrealpower = {0,153,312,481,661,}, },
		[99] = {studyLvl = 99, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1426, skillrealpower = {0,153,312,481,661,}, },
		[100] = {studyLvl = 100, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1454, skillrealpower = {0,153,312,481,661,}, },
		[101] = {studyLvl = 101, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1484, skillrealpower = {0,153,312,481,661,}, },
		[102] = {studyLvl = 102, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1514, skillrealpower = {0,153,312,481,661,}, },
		[103] = {studyLvl = 103, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1544, skillrealpower = {0,153,312,481,661,}, },
		[104] = {studyLvl = 104, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1574, skillrealpower = {0,153,312,481,661,}, },
		[105] = {studyLvl = 105, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1604, skillrealpower = {0,153,312,481,661,}, },
		[106] = {studyLvl = 106, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1634, skillrealpower = {0,153,312,481,661,}, },
		[107] = {studyLvl = 107, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1666, skillrealpower = {0,153,312,481,661,}, },
		[108] = {studyLvl = 108, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1698, skillrealpower = {0,153,312,481,661,}, },
		[109] = {studyLvl = 109, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1730, skillrealpower = {0,153,312,481,661,}, },
		[110] = {studyLvl = 110, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1762, skillrealpower = {0,153,312,481,661,}, },
		[111] = {studyLvl = 111, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1794, skillrealpower = {0,153,312,481,661,}, },
		[112] = {studyLvl = 112, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1826, skillrealpower = {0,153,312,481,661,}, },
		[113] = {studyLvl = 113, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1858, skillrealpower = {0,153,312,481,661,}, },
		[114] = {studyLvl = 114, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1890, skillrealpower = {0,153,312,481,661,}, },
		[115] = {studyLvl = 115, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1922, skillrealpower = {0,153,312,481,661,}, },
		[116] = {studyLvl = 116, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1954, skillrealpower = {0,153,312,481,661,}, },
		[117] = {studyLvl = 117, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 1986, skillrealpower = {0,153,312,481,661,}, },
		[118] = {studyLvl = 118, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2018, skillrealpower = {0,153,312,481,661,}, },
		[119] = {studyLvl = 119, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2050, skillrealpower = {0,153,312,481,661,}, },
		[120] = {studyLvl = 120, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2082, skillrealpower = {0,153,312,481,661,}, },
		[121] = {studyLvl = 121, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2114, skillrealpower = {0,153,312,481,661,}, },
		[122] = {studyLvl = 122, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2146, skillrealpower = {0,153,312,481,661,}, },
		[123] = {studyLvl = 123, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2178, skillrealpower = {0,153,312,481,661,}, },
		[124] = {studyLvl = 124, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2210, skillrealpower = {0,153,312,481,661,}, },
		[125] = {studyLvl = 125, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2242, skillrealpower = {0,153,312,481,661,}, },
		[126] = {studyLvl = 126, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2274, skillrealpower = {0,153,312,481,661,}, },
		[127] = {studyLvl = 127, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2306, skillrealpower = {0,153,312,481,661,}, },
		[128] = {studyLvl = 128, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2338, skillrealpower = {0,153,312,481,661,}, },
		[129] = {studyLvl = 129, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2370, skillrealpower = {0,153,312,481,661,}, },
		[130] = {studyLvl = 130, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2402, skillrealpower = {0,153,312,481,661,}, },
		[131] = {studyLvl = 131, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2434, skillrealpower = {0,153,312,481,661,}, },
		[132] = {studyLvl = 132, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2466, skillrealpower = {0,153,312,481,661,}, },
		[133] = {studyLvl = 133, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2498, skillrealpower = {0,153,312,481,661,}, },
		[134] = {studyLvl = 134, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2530, skillrealpower = {0,153,312,481,661,}, },
		[135] = {studyLvl = 135, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2562, skillrealpower = {0,153,312,481,661,}, },
		[136] = {studyLvl = 136, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2594, skillrealpower = {0,153,312,481,661,}, },
		[137] = {studyLvl = 137, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2626, skillrealpower = {0,153,312,481,661,}, },
		[138] = {studyLvl = 138, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2658, skillrealpower = {0,153,312,481,661,}, },
		[139] = {studyLvl = 139, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2690, skillrealpower = {0,153,312,481,661,}, },
		[140] = {studyLvl = 140, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2722, skillrealpower = {0,153,312,481,661,}, },
		[141] = {studyLvl = 141, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2754, skillrealpower = {0,153,312,481,661,}, },
		[142] = {studyLvl = 142, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2786, skillrealpower = {0,153,312,481,661,}, },
		[143] = {studyLvl = 143, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2818, skillrealpower = {0,153,312,481,661,}, },
		[144] = {studyLvl = 144, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2850, skillrealpower = {0,153,312,481,661,}, },
		[145] = {studyLvl = 145, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2882, skillrealpower = {0,153,312,481,661,}, },
		[146] = {studyLvl = 146, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2914, skillrealpower = {0,153,312,481,661,}, },
		[147] = {studyLvl = 147, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2946, skillrealpower = {0,153,312,481,661,}, },
		[148] = {studyLvl = 148, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 2978, skillrealpower = {0,153,312,481,661,}, },
		[149] = {studyLvl = 149, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 3010, skillrealpower = {0,153,312,481,661,}, },
		[150] = {studyLvl = 150, needCoin = 225760, needItemID = 65714, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 660, }, }, }, },skillpower = 3042, skillrealpower = {0,153,312,481,661,}, },
	},

};
function get_db_table()
	return level;
end
