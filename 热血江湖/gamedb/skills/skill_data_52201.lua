----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[52201] = {
		[1] = {addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 24, skillrealpower = {0,153,312,481,661,}, spArgs1 = '135', },
		[2] = {studyLvl = 2, needCoin = 30, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 26, skillrealpower = {0,153,312,481,661,}, spArgs1 = '150', },
		[3] = {studyLvl = 3, needCoin = 50, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 30, skillrealpower = {0,153,312,481,661,}, spArgs1 = '165', },
		[4] = {studyLvl = 4, needCoin = 100, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 34, skillrealpower = {0,153,312,481,661,}, spArgs1 = '180', },
		[5] = {studyLvl = 5, needCoin = 200, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 38, skillrealpower = {0,153,312,481,661,}, spArgs1 = '195', },
		[6] = {studyLvl = 6, needCoin = 300, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 42, skillrealpower = {0,153,312,481,661,}, spArgs1 = '210', },
		[7] = {studyLvl = 7, needCoin = 450, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 48, skillrealpower = {0,153,312,481,661,}, spArgs1 = '225', },
		[8] = {studyLvl = 8, needCoin = 600, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 54, skillrealpower = {0,153,312,481,661,}, spArgs1 = '240', },
		[9] = {studyLvl = 9, needCoin = 800, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 60, skillrealpower = {0,153,312,481,661,}, spArgs1 = '255', },
		[10] = {studyLvl = 10, needCoin = 1000, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 66, skillrealpower = {0,153,312,481,661,}, spArgs1 = '270', },
		[11] = {studyLvl = 11, needCoin = 1300, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 72, skillrealpower = {0,153,312,481,661,}, spArgs1 = '285', },
		[12] = {studyLvl = 12, needCoin = 1600, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 78, skillrealpower = {0,153,312,481,661,}, spArgs1 = '300', },
		[13] = {studyLvl = 13, needCoin = 2000, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 84, skillrealpower = {0,153,312,481,661,}, spArgs1 = '315', },
		[14] = {studyLvl = 14, needCoin = 2400, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 90, skillrealpower = {0,153,312,481,661,}, spArgs1 = '330', },
		[15] = {studyLvl = 15, needCoin = 2850, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 96, skillrealpower = {0,153,312,481,661,}, spArgs1 = '345', },
		[16] = {studyLvl = 16, needCoin = 3400, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 102, skillrealpower = {0,153,312,481,661,}, spArgs1 = '360', },
		[17] = {studyLvl = 17, needCoin = 3950, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 108, skillrealpower = {0,153,312,481,661,}, spArgs1 = '375', },
		[18] = {studyLvl = 18, needCoin = 4600, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 114, skillrealpower = {0,153,312,481,661,}, spArgs1 = '390', },
		[19] = {studyLvl = 19, needCoin = 5300, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 120, skillrealpower = {0,153,312,481,661,}, spArgs1 = '405', },
		[20] = {studyLvl = 20, needCoin = 6050, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 126, skillrealpower = {0,153,312,481,661,}, spArgs1 = '420', },
		[21] = {studyLvl = 21, needCoin = 6900, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 132, skillrealpower = {0,153,312,481,661,}, spArgs1 = '435', },
		[22] = {studyLvl = 22, needCoin = 7800, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 138, skillrealpower = {0,153,312,481,661,}, spArgs1 = '450', },
		[23] = {studyLvl = 23, needCoin = 8800, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 144, skillrealpower = {0,153,312,481,661,}, spArgs1 = '465', },
		[24] = {studyLvl = 24, needCoin = 9900, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 150, skillrealpower = {0,153,312,481,661,}, spArgs1 = '480', },
		[25] = {studyLvl = 25, needCoin = 11050, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 156, skillrealpower = {0,153,312,481,661,}, spArgs1 = '495', },
		[26] = {studyLvl = 26, needCoin = 12250, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 164, skillrealpower = {0,153,312,481,661,}, spArgs1 = '510', },
		[27] = {studyLvl = 27, needCoin = 13600, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 172, skillrealpower = {0,153,312,481,661,}, spArgs1 = '525', },
		[28] = {studyLvl = 28, needCoin = 15000, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 180, skillrealpower = {0,153,312,481,661,}, spArgs1 = '540', },
		[29] = {studyLvl = 29, needCoin = 16500, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 188, skillrealpower = {0,153,312,481,661,}, spArgs1 = '555', },
		[30] = {studyLvl = 30, needCoin = 18100, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 198, skillrealpower = {0,153,312,481,661,}, spArgs1 = '570', },
		[31] = {studyLvl = 31, needCoin = 19800, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 208, skillrealpower = {0,153,312,481,661,}, spArgs1 = '585', },
		[32] = {studyLvl = 32, needCoin = 21650, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 218, skillrealpower = {0,153,312,481,661,}, spArgs1 = '600', },
		[33] = {studyLvl = 33, needCoin = 23550, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 228, skillrealpower = {0,153,312,481,661,}, spArgs1 = '615', },
		[34] = {studyLvl = 34, needCoin = 25550, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 238, skillrealpower = {0,153,312,481,661,}, spArgs1 = '630', },
		[35] = {studyLvl = 35, needCoin = 27700, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 248, skillrealpower = {0,153,312,481,661,}, spArgs1 = '645', },
		[36] = {studyLvl = 36, needCoin = 29950, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 258, skillrealpower = {0,153,312,481,661,}, spArgs1 = '660', },
		[37] = {studyLvl = 37, needCoin = 32300, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 268, skillrealpower = {0,153,312,481,661,}, spArgs1 = '675', },
		[38] = {studyLvl = 38, needCoin = 34800, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 278, skillrealpower = {0,153,312,481,661,}, spArgs1 = '690', },
		[39] = {studyLvl = 39, needCoin = 37400, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 288, skillrealpower = {0,153,312,481,661,}, spArgs1 = '705', },
		[40] = {studyLvl = 40, needCoin = 40150, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 298, skillrealpower = {0,153,312,481,661,}, spArgs1 = '778', },
		[41] = {studyLvl = 41, needCoin = 43060, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 308, skillrealpower = {0,153,312,481,661,}, spArgs1 = '823', },
		[42] = {studyLvl = 42, needCoin = 45160, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 318, skillrealpower = {0,153,312,481,661,}, spArgs1 = '870', },
		[43] = {studyLvl = 43, needCoin = 47310, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 330, skillrealpower = {0,153,312,481,661,}, spArgs1 = '920', },
		[44] = {studyLvl = 44, needCoin = 49510, needItemID = 65714, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 342, skillrealpower = {0,153,312,481,661,}, spArgs1 = '975', },
		[45] = {studyLvl = 45, needCoin = 51760, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 354, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1039', },
		[46] = {studyLvl = 46, needCoin = 54060, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 366, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1118', },
		[47] = {studyLvl = 47, needCoin = 56410, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 378, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1187', },
		[48] = {studyLvl = 48, needCoin = 58810, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 390, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1255', },
		[49] = {studyLvl = 49, needCoin = 61260, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 404, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1350', },
		[50] = {studyLvl = 50, needCoin = 63760, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 418, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1450', },
		[51] = {studyLvl = 51, needCoin = 66310, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 432, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1552', },
		[52] = {studyLvl = 52, needCoin = 68910, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 446, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1696', },
		[53] = {studyLvl = 53, needCoin = 71560, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 460, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1894', },
		[54] = {studyLvl = 54, needCoin = 74260, needItemID = 65714, needItemNum = 2, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 474, skillrealpower = {0,153,312,481,661,}, spArgs1 = '1967', },
		[55] = {studyLvl = 55, needCoin = 77010, needItemID = 65714, needItemNum = 3, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 488, skillrealpower = {0,153,312,481,661,}, spArgs1 = '2192', },
		[56] = {studyLvl = 56, needCoin = 79810, needItemID = 65714, needItemNum = 3, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 502, skillrealpower = {0,153,312,481,661,}, spArgs1 = '2383', },
		[57] = {studyLvl = 57, needCoin = 82660, needItemID = 65714, needItemNum = 3, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 518, skillrealpower = {0,153,312,481,661,}, spArgs1 = '2508', },
		[58] = {studyLvl = 58, needCoin = 85560, needItemID = 65714, needItemNum = 3, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 534, skillrealpower = {0,153,312,481,661,}, spArgs1 = '2589', },
		[59] = {studyLvl = 59, needCoin = 88510, needItemID = 65714, needItemNum = 3, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 550, skillrealpower = {0,153,312,481,661,}, spArgs1 = '2707', },
		[60] = {studyLvl = 60, needCoin = 91510, needItemID = 65714, needItemNum = 4, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 566, skillrealpower = {0,153,312,481,661,}, spArgs1 = '2882', },
		[61] = {studyLvl = 61, needCoin = 94560, needItemID = 65714, needItemNum = 4, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 582, skillrealpower = {0,153,312,481,661,}, spArgs1 = '3016', },
		[62] = {studyLvl = 62, needCoin = 97660, needItemID = 65714, needItemNum = 4, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 598, skillrealpower = {0,153,312,481,661,}, spArgs1 = '3097', },
		[63] = {studyLvl = 63, needCoin = 100810, needItemID = 65714, needItemNum = 4, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 614, skillrealpower = {0,153,312,481,661,}, spArgs1 = '3210', },
		[64] = {studyLvl = 64, needCoin = 104010, needItemID = 65714, needItemNum = 4, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 632, skillrealpower = {0,153,312,481,661,}, spArgs1 = '3370', },
		[65] = {studyLvl = 65, needCoin = 107260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 650, skillrealpower = {0,153,312,481,661,}, spArgs1 = '3592', },
		[66] = {studyLvl = 66, needCoin = 110560, needItemID = 65714, needItemNum = 5, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 668, skillrealpower = {0,153,312,481,661,}, spArgs1 = '4057', },
		[67] = {studyLvl = 67, needCoin = 113910, needItemID = 65714, needItemNum = 6, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 686, skillrealpower = {0,153,312,481,661,}, spArgs1 = '4233', },
		[68] = {studyLvl = 68, needCoin = 117310, needItemID = 65714, needItemNum = 7, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 704, skillrealpower = {0,153,312,481,661,}, spArgs1 = '4438', },
		[69] = {studyLvl = 69, needCoin = 120760, needItemID = 65714, needItemNum = 8, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 722, skillrealpower = {0,153,312,481,661,}, spArgs1 = '4667', },
		[70] = {studyLvl = 70, needCoin = 124260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 740, skillrealpower = {0,153,312,481,661,}, spArgs1 = '5182', },
		[71] = {studyLvl = 71, needCoin = 127760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 758, skillrealpower = {0,153,312,481,661,}, spArgs1 = '5564', },
		[72] = {studyLvl = 72, needCoin = 131260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 778, skillrealpower = {0,153,312,481,661,}, spArgs1 = '5933', },
		[73] = {studyLvl = 73, needCoin = 134760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 798, skillrealpower = {0,153,312,481,661,}, spArgs1 = '6230', },
		[74] = {studyLvl = 74, needCoin = 138260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 818, skillrealpower = {0,153,312,481,661,}, spArgs1 = '6745', },
		[75] = {studyLvl = 75, needCoin = 141760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 838, skillrealpower = {0,153,312,481,661,}, spArgs1 = '7166', },
		[76] = {studyLvl = 76, needCoin = 145260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 858, skillrealpower = {0,153,312,481,661,}, spArgs1 = '7501', },
		[77] = {studyLvl = 77, needCoin = 148760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 880, skillrealpower = {0,153,312,481,661,}, spArgs1 = '8064', },
		[78] = {studyLvl = 78, needCoin = 152260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 902, skillrealpower = {0,153,312,481,661,}, spArgs1 = '8487', },
		[79] = {studyLvl = 79, needCoin = 155760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 924, skillrealpower = {0,153,312,481,661,}, spArgs1 = '8854', },
		[80] = {studyLvl = 80, needCoin = 159260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 946, skillrealpower = {0,153,312,481,661,}, spArgs1 = '9776', },
		[81] = {studyLvl = 81, needCoin = 162760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 968, skillrealpower = {0,153,312,481,661,}, spArgs1 = '10125', },
		[82] = {studyLvl = 82, needCoin = 166260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 990, skillrealpower = {0,153,312,481,661,}, spArgs1 = '10459', },
		[83] = {studyLvl = 83, needCoin = 169760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1012, skillrealpower = {0,153,312,481,661,}, spArgs1 = '11077', },
		[84] = {studyLvl = 84, needCoin = 173260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1036, skillrealpower = {0,153,312,481,661,}, spArgs1 = '11557', },
		[85] = {studyLvl = 85, needCoin = 176760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1060, skillrealpower = {0,153,312,481,661,}, spArgs1 = '12323', },
		[86] = {studyLvl = 86, needCoin = 180260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1084, skillrealpower = {0,153,312,481,661,}, spArgs1 = '13112', },
		[87] = {studyLvl = 87, needCoin = 183760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1108, skillrealpower = {0,153,312,481,661,}, spArgs1 = '13532', },
		[88] = {studyLvl = 88, needCoin = 187260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1132, skillrealpower = {0,153,312,481,661,}, spArgs1 = '14111', },
		[89] = {studyLvl = 89, needCoin = 190760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1156, skillrealpower = {0,153,312,481,661,}, spArgs1 = '14751', },
		[90] = {studyLvl = 90, needCoin = 194260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1182, skillrealpower = {0,153,312,481,661,}, spArgs1 = '15097', },
		[91] = {studyLvl = 91, needCoin = 197760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1208, skillrealpower = {0,153,312,481,661,}, spArgs1 = '15400', },
		[92] = {studyLvl = 92, needCoin = 201260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1234, skillrealpower = {0,153,312,481,661,}, spArgs1 = '16060', },
		[93] = {studyLvl = 93, needCoin = 204760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1260, skillrealpower = {0,153,312,481,661,}, spArgs1 = '16462', },
		[94] = {studyLvl = 94, needCoin = 208260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1286, skillrealpower = {0,153,312,481,661,}, spArgs1 = '16787', },
		[95] = {studyLvl = 95, needCoin = 211760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1314, skillrealpower = {0,153,312,481,661,}, spArgs1 = '17531', },
		[96] = {studyLvl = 96, needCoin = 215260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1342, skillrealpower = {0,153,312,481,661,}, spArgs1 = '18006', },
		[97] = {studyLvl = 97, needCoin = 218760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1370, skillrealpower = {0,153,312,481,661,}, spArgs1 = '18356', },
		[98] = {studyLvl = 98, needCoin = 222260, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1398, skillrealpower = {0,153,312,481,661,}, spArgs1 = '19129', },
		[99] = {studyLvl = 99, needCoin = 225760, needItemID = 65714, needItemNum = 9, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1426, skillrealpower = {0,153,312,481,661,}, spArgs1 = '19602', },
		[100] = {studyLvl = 100, needCoin = 229260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1454, skillrealpower = {0,153,312,481,661,}, spArgs1 = '20166', },
		[101] = {studyLvl = 101, needCoin = 232760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1484, skillrealpower = {0,153,312,481,661,}, spArgs1 = '20978', },
		[102] = {studyLvl = 102, needCoin = 236260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1514, skillrealpower = {0,153,312,481,661,}, spArgs1 = '21603', },
		[103] = {studyLvl = 103, needCoin = 239760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1544, skillrealpower = {0,153,312,481,661,}, spArgs1 = '22070', },
		[104] = {studyLvl = 104, needCoin = 243260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1574, skillrealpower = {0,153,312,481,661,}, spArgs1 = '23065', },
		[105] = {studyLvl = 105, needCoin = 246760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1604, skillrealpower = {0,153,312,481,661,}, spArgs1 = '23592', },
		[106] = {studyLvl = 106, needCoin = 250260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1634, skillrealpower = {0,153,312,481,661,}, spArgs1 = '24019', },
		[107] = {studyLvl = 107, needCoin = 253760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1666, skillrealpower = {0,153,312,481,661,}, spArgs1 = '24982', },
		[108] = {studyLvl = 108, needCoin = 257260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1698, skillrealpower = {0,153,312,481,661,}, spArgs1 = '25577', },
		[109] = {studyLvl = 109, needCoin = 260760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1730, skillrealpower = {0,153,312,481,661,}, spArgs1 = '26119', },
		[110] = {studyLvl = 110, needCoin = 264260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1762, skillrealpower = {0,153,312,481,661,}, spArgs1 = '27215', },
		[111] = {studyLvl = 111, needCoin = 267760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1794, skillrealpower = {0,153,312,481,661,}, spArgs1 = '27738', },
		[112] = {studyLvl = 112, needCoin = 271260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1826, skillrealpower = {0,153,312,481,661,}, spArgs1 = '28300', },
		[113] = {studyLvl = 113, needCoin = 274760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1858, skillrealpower = {0,153,312,481,661,}, spArgs1 = '29493', },
		[114] = {studyLvl = 114, needCoin = 278260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1890, skillrealpower = {0,153,312,481,661,}, spArgs1 = '30001', },
		[115] = {studyLvl = 115, needCoin = 281760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1922, skillrealpower = {0,153,312,481,661,}, spArgs1 = '30594', },
		[116] = {studyLvl = 116, needCoin = 285260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1954, skillrealpower = {0,153,312,481,661,}, spArgs1 = '31900', },
		[117] = {studyLvl = 117, needCoin = 288760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 1986, skillrealpower = {0,153,312,481,661,}, spArgs1 = '32485', },
		[118] = {studyLvl = 118, needCoin = 292260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2018, skillrealpower = {0,153,312,481,661,}, spArgs1 = '33430', },
		[119] = {studyLvl = 119, needCoin = 295760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2050, skillrealpower = {0,153,312,481,661,}, spArgs1 = '34097', },
		[120] = {studyLvl = 120, needCoin = 299260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2082, skillrealpower = {0,153,312,481,661,}, spArgs1 = '34758', },
		[121] = {studyLvl = 121, needCoin = 302760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2114, skillrealpower = {0,153,312,481,661,}, spArgs1 = '35337', },
		[122] = {studyLvl = 122, needCoin = 306260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2146, skillrealpower = {0,153,312,481,661,}, spArgs1 = '35926', },
		[123] = {studyLvl = 123, needCoin = 309760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2178, skillrealpower = {0,153,312,481,661,}, spArgs1 = '36577', },
		[124] = {studyLvl = 124, needCoin = 313260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2210, skillrealpower = {0,153,312,481,661,}, spArgs1 = '37183', },
		[125] = {studyLvl = 125, needCoin = 316760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2242, skillrealpower = {0,153,312,481,661,}, spArgs1 = '37800', },
		[126] = {studyLvl = 126, needCoin = 320260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2274, skillrealpower = {0,153,312,481,661,}, spArgs1 = '38425', },
		[127] = {studyLvl = 127, needCoin = 323760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2306, skillrealpower = {0,153,312,481,661,}, spArgs1 = '39060', },
		[128] = {studyLvl = 128, needCoin = 327260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2338, skillrealpower = {0,153,312,481,661,}, spArgs1 = '39704', },
		[129] = {studyLvl = 129, needCoin = 330760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2370, skillrealpower = {0,153,312,481,661,}, spArgs1 = '40545', },
		[130] = {studyLvl = 130, needCoin = 334260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2402, skillrealpower = {0,153,312,481,661,}, spArgs1 = '41209', },
		[131] = {studyLvl = 131, needCoin = 337760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2434, skillrealpower = {0,153,312,481,661,}, spArgs1 = '41883', },
		[132] = {studyLvl = 132, needCoin = 341260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2466, skillrealpower = {0,153,312,481,661,}, spArgs1 = '42566', },
		[133] = {studyLvl = 133, needCoin = 344760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2498, skillrealpower = {0,153,312,481,661,}, spArgs1 = '43260', },
		[134] = {studyLvl = 134, needCoin = 348260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2530, skillrealpower = {0,153,312,481,661,}, spArgs1 = '43963', },
		[135] = {studyLvl = 135, needCoin = 351760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2562, skillrealpower = {0,153,312,481,661,}, spArgs1 = '44739', },
		[136] = {studyLvl = 136, needCoin = 355260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2594, skillrealpower = {0,153,312,481,661,}, spArgs1 = '45463', },
		[137] = {studyLvl = 137, needCoin = 358760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2626, skillrealpower = {0,153,312,481,661,}, spArgs1 = '46197', },
		[138] = {studyLvl = 138, needCoin = 362260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2658, skillrealpower = {0,153,312,481,661,}, spArgs1 = '46941', },
		[139] = {studyLvl = 139, needCoin = 365760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2690, skillrealpower = {0,153,312,481,661,}, spArgs1 = '47697', },
		[140] = {studyLvl = 140, needCoin = 369260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2722, skillrealpower = {0,153,312,481,661,}, spArgs1 = '48461', },
		[141] = {studyLvl = 141, needCoin = 372760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2754, skillrealpower = {0,153,312,481,661,}, spArgs1 = '49297', },
		[142] = {studyLvl = 142, needCoin = 376260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2786, skillrealpower = {0,153,312,481,661,}, spArgs1 = '50083', },
		[143] = {studyLvl = 143, needCoin = 379760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2818, skillrealpower = {0,153,312,481,661,}, spArgs1 = '50879', },
		[144] = {studyLvl = 144, needCoin = 383260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2850, skillrealpower = {0,153,312,481,661,}, spArgs1 = '51687', },
		[145] = {studyLvl = 145, needCoin = 386760, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2882, skillrealpower = {0,153,312,481,661,}, spArgs1 = '52506', },
		[146] = {studyLvl = 146, needCoin = 390260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2914, skillrealpower = {0,153,312,481,661,}, spArgs1 = '53335', },
		[147] = {studyLvl = 147, needCoin = 393760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2946, skillrealpower = {0,153,312,481,661,}, spArgs1 = '54238', },
		[148] = {studyLvl = 148, needCoin = 397260, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 2978, skillrealpower = {0,153,312,481,661,}, spArgs1 = '55090', },
		[149] = {studyLvl = 149, needCoin = 400760, needItemID = 65714, needItemNum = 10, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 3010, skillrealpower = {0,153,312,481,661,}, spArgs1 = '55954', },
		[150] = {studyLvl = 150, needCoin = 404260, needItemID = 66312, needItemNum = 1, addSP = 50, cool = 15000, events = {{triTime = 100, status = {{odds = 10000, buffID = 586, }, }, }, },skillpower = 3042, skillrealpower = {0,153,312,481,661,}, spArgs1 = '56830', },
	},

};
function get_db_table()
	return level;
end
