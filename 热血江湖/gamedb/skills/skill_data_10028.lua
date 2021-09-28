----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[10028] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[2] = {studyLvl = 2, needCoin = 60, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[3] = {studyLvl = 3, needCoin = 100, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[4] = {studyLvl = 4, needCoin = 200, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[5] = {studyLvl = 5, needCoin = 400, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[6] = {studyLvl = 6, needCoin = 600, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[7] = {studyLvl = 7, needCoin = 900, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[8] = {studyLvl = 8, needCoin = 1200, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[9] = {studyLvl = 9, needCoin = 1600, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[10] = {studyLvl = 10, needCoin = 2000, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[11] = {studyLvl = 11, needCoin = 2600, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[12] = {studyLvl = 12, needCoin = 3200, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[13] = {studyLvl = 13, needCoin = 4000, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[14] = {studyLvl = 14, needCoin = 4800, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[15] = {studyLvl = 15, needCoin = 5700, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[16] = {studyLvl = 16, needCoin = 6800, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[17] = {studyLvl = 17, needCoin = 7900, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[18] = {studyLvl = 18, needCoin = 9200, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[19] = {studyLvl = 19, needCoin = 10600, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[20] = {studyLvl = 20, needCoin = 12100, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[21] = {studyLvl = 21, needCoin = 13800, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[22] = {studyLvl = 22, needCoin = 15600, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[23] = {studyLvl = 23, needCoin = 17600, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[24] = {studyLvl = 24, needCoin = 19800, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[25] = {studyLvl = 25, needCoin = 22100, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[26] = {studyLvl = 26, needCoin = 24500, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[27] = {studyLvl = 27, needCoin = 27200, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[28] = {studyLvl = 28, needCoin = 30000, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[29] = {studyLvl = 29, needCoin = 33000, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[30] = {studyLvl = 30, needCoin = 36200, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[31] = {studyLvl = 31, needCoin = 39600, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[32] = {studyLvl = 32, needCoin = 43300, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[33] = {studyLvl = 33, needCoin = 47100, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[34] = {studyLvl = 34, needCoin = 51100, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[35] = {studyLvl = 35, needCoin = 55400, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[36] = {studyLvl = 36, needCoin = 59900, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[37] = {studyLvl = 37, needCoin = 64600, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[38] = {studyLvl = 38, needCoin = 69600, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[39] = {studyLvl = 39, needCoin = 74800, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[40] = {studyLvl = 40, needCoin = 80300, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[41] = {studyLvl = 41, needCoin = 86120, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[42] = {studyLvl = 42, needCoin = 90320, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[43] = {studyLvl = 43, needCoin = 94620, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[44] = {studyLvl = 44, needCoin = 99020, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[45] = {studyLvl = 45, needCoin = 103520, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[46] = {studyLvl = 46, needCoin = 108120, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[47] = {studyLvl = 47, needCoin = 112820, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[48] = {studyLvl = 48, needCoin = 117620, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[49] = {studyLvl = 49, needCoin = 122520, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[50] = {studyLvl = 50, needCoin = 127520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[51] = {studyLvl = 51, needCoin = 132620, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[52] = {studyLvl = 52, needCoin = 137820, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[53] = {studyLvl = 53, needCoin = 143120, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[54] = {studyLvl = 54, needCoin = 148520, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[55] = {studyLvl = 55, needCoin = 154020, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[56] = {studyLvl = 56, needCoin = 159620, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[57] = {studyLvl = 57, needCoin = 165320, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[58] = {studyLvl = 58, needCoin = 171120, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[59] = {studyLvl = 59, needCoin = 177020, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[60] = {studyLvl = 60, needCoin = 183020, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[61] = {studyLvl = 61, needCoin = 189120, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[62] = {studyLvl = 62, needCoin = 195320, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[63] = {studyLvl = 63, needCoin = 201620, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[64] = {studyLvl = 64, needCoin = 208020, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[65] = {studyLvl = 65, needCoin = 214520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[66] = {studyLvl = 66, needCoin = 221120, needItemID = 65715, needItemNum = 5, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[67] = {studyLvl = 67, needCoin = 227820, needItemID = 65715, needItemNum = 6, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[68] = {studyLvl = 68, needCoin = 234620, needItemID = 65715, needItemNum = 7, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[69] = {studyLvl = 69, needCoin = 241520, needItemID = 65715, needItemNum = 8, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[70] = {studyLvl = 70, needCoin = 248520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[71] = {studyLvl = 71, needCoin = 255520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[72] = {studyLvl = 72, needCoin = 262520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[73] = {studyLvl = 73, needCoin = 269520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[74] = {studyLvl = 74, needCoin = 276520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[75] = {studyLvl = 75, needCoin = 283520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[76] = {studyLvl = 76, needCoin = 290520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[77] = {studyLvl = 77, needCoin = 297520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[78] = {studyLvl = 78, needCoin = 304520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[79] = {studyLvl = 79, needCoin = 311520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[80] = {studyLvl = 80, needCoin = 318520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[81] = {studyLvl = 81, needCoin = 325520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[82] = {studyLvl = 82, needCoin = 332520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[83] = {studyLvl = 83, needCoin = 339520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[84] = {studyLvl = 84, needCoin = 346520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[85] = {studyLvl = 85, needCoin = 353520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[86] = {studyLvl = 86, needCoin = 360520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[87] = {studyLvl = 87, needCoin = 367520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[88] = {studyLvl = 88, needCoin = 374520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[89] = {studyLvl = 89, needCoin = 381520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[90] = {studyLvl = 90, needCoin = 388520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[91] = {studyLvl = 91, needCoin = 395520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[92] = {studyLvl = 92, needCoin = 402520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[93] = {studyLvl = 93, needCoin = 409520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[94] = {studyLvl = 94, needCoin = 416520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[95] = {studyLvl = 95, needCoin = 423520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[96] = {studyLvl = 96, needCoin = 430520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[97] = {studyLvl = 97, needCoin = 437520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[98] = {studyLvl = 98, needCoin = 444520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[99] = {studyLvl = 99, needCoin = 451520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[100] = {studyLvl = 100, needCoin = 458520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[101] = {studyLvl = 101, needCoin = 465520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[102] = {studyLvl = 102, needCoin = 472520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[103] = {studyLvl = 103, needCoin = 479520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[104] = {studyLvl = 104, needCoin = 486520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[105] = {studyLvl = 105, needCoin = 493520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[106] = {studyLvl = 106, needCoin = 500520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[107] = {studyLvl = 107, needCoin = 507520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[108] = {studyLvl = 108, needCoin = 514520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[109] = {studyLvl = 109, needCoin = 521520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[110] = {studyLvl = 110, needCoin = 528520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[111] = {studyLvl = 111, needCoin = 535520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[112] = {studyLvl = 112, needCoin = 542520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[113] = {studyLvl = 113, needCoin = 549520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[114] = {studyLvl = 114, needCoin = 556520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[115] = {studyLvl = 115, needCoin = 563520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[116] = {studyLvl = 116, needCoin = 570520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[117] = {studyLvl = 117, needCoin = 577520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[118] = {studyLvl = 118, needCoin = 584520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[119] = {studyLvl = 119, needCoin = 591520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[120] = {studyLvl = 120, needCoin = 598520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[121] = {studyLvl = 121, needCoin = 605520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[122] = {studyLvl = 122, needCoin = 612520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[123] = {studyLvl = 123, needCoin = 619520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[124] = {studyLvl = 124, needCoin = 626520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[125] = {studyLvl = 125, needCoin = 633520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[126] = {studyLvl = 126, needCoin = 640520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[127] = {studyLvl = 127, needCoin = 647520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[128] = {studyLvl = 128, needCoin = 654520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[129] = {studyLvl = 129, needCoin = 661520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[130] = {studyLvl = 130, needCoin = 668520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[131] = {studyLvl = 131, needCoin = 675520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[132] = {studyLvl = 132, needCoin = 682520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[133] = {studyLvl = 133, needCoin = 689520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[134] = {studyLvl = 134, needCoin = 696520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[135] = {studyLvl = 135, needCoin = 703520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[136] = {studyLvl = 136, needCoin = 710520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[137] = {studyLvl = 137, needCoin = 717520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[138] = {studyLvl = 138, needCoin = 724520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[139] = {studyLvl = 139, needCoin = 731520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[140] = {studyLvl = 140, needCoin = 738520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[141] = {studyLvl = 141, needCoin = 745520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[142] = {studyLvl = 142, needCoin = 752520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[143] = {studyLvl = 143, needCoin = 759520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[144] = {studyLvl = 144, needCoin = 766520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[145] = {studyLvl = 145, needCoin = 773520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[146] = {studyLvl = 146, needCoin = 780520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[147] = {studyLvl = 147, needCoin = 787520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[148] = {studyLvl = 148, needCoin = 794520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[149] = {studyLvl = 149, needCoin = 801520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
		[150] = {studyLvl = 150, needCoin = 808520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, status = {{odds = 10000, buffID = 550, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
