----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[10030] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105001, }, }, }, },},
		[2] = {studyLvl = 2, needCoin = 60, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105002, }, }, }, },},
		[3] = {studyLvl = 3, needCoin = 100, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105003, }, }, }, },},
		[4] = {studyLvl = 4, needCoin = 200, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105004, }, }, }, },},
		[5] = {studyLvl = 5, needCoin = 400, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105005, }, }, }, },},
		[6] = {studyLvl = 6, needCoin = 600, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105006, }, }, }, },},
		[7] = {studyLvl = 7, needCoin = 900, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105007, }, }, }, },},
		[8] = {studyLvl = 8, needCoin = 1200, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105008, }, }, }, },},
		[9] = {studyLvl = 9, needCoin = 1600, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105009, }, }, }, },},
		[10] = {studyLvl = 10, needCoin = 2000, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105010, }, }, }, },},
		[11] = {studyLvl = 11, needCoin = 2600, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105011, }, }, }, },},
		[12] = {studyLvl = 12, needCoin = 3200, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105012, }, }, }, },},
		[13] = {studyLvl = 13, needCoin = 4000, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105013, }, }, }, },},
		[14] = {studyLvl = 14, needCoin = 4800, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105014, }, }, }, },},
		[15] = {studyLvl = 15, needCoin = 5700, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105015, }, }, }, },},
		[16] = {studyLvl = 16, needCoin = 6800, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105016, }, }, }, },},
		[17] = {studyLvl = 17, needCoin = 7900, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105017, }, }, }, },},
		[18] = {studyLvl = 18, needCoin = 9200, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105018, }, }, }, },},
		[19] = {studyLvl = 19, needCoin = 10600, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105019, }, }, }, },},
		[20] = {studyLvl = 20, needCoin = 12100, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105020, }, }, }, },},
		[21] = {studyLvl = 21, needCoin = 13800, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105021, }, }, }, },},
		[22] = {studyLvl = 22, needCoin = 15600, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105022, }, }, }, },},
		[23] = {studyLvl = 23, needCoin = 17600, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105023, }, }, }, },},
		[24] = {studyLvl = 24, needCoin = 19800, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105024, }, }, }, },},
		[25] = {studyLvl = 25, needCoin = 22100, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105025, }, }, }, },},
		[26] = {studyLvl = 26, needCoin = 24500, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105026, }, }, }, },},
		[27] = {studyLvl = 27, needCoin = 27200, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105027, }, }, }, },},
		[28] = {studyLvl = 28, needCoin = 30000, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105028, }, }, }, },},
		[29] = {studyLvl = 29, needCoin = 33000, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105029, }, }, }, },},
		[30] = {studyLvl = 30, needCoin = 36200, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105030, }, }, }, },},
		[31] = {studyLvl = 31, needCoin = 39600, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105031, }, }, }, },},
		[32] = {studyLvl = 32, needCoin = 43300, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105032, }, }, }, },},
		[33] = {studyLvl = 33, needCoin = 47100, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105033, }, }, }, },},
		[34] = {studyLvl = 34, needCoin = 51100, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105034, }, }, }, },},
		[35] = {studyLvl = 35, needCoin = 55400, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105035, }, }, }, },},
		[36] = {studyLvl = 36, needCoin = 59900, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105036, }, }, }, },},
		[37] = {studyLvl = 37, needCoin = 64600, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105037, }, }, }, },},
		[38] = {studyLvl = 38, needCoin = 69600, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105038, }, }, }, },},
		[39] = {studyLvl = 39, needCoin = 74800, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105039, }, }, }, },},
		[40] = {studyLvl = 40, needCoin = 80300, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105040, }, }, }, },},
		[41] = {studyLvl = 41, needCoin = 86120, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105041, }, }, }, },},
		[42] = {studyLvl = 42, needCoin = 90320, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105042, }, }, }, },},
		[43] = {studyLvl = 43, needCoin = 94620, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105043, }, }, }, },},
		[44] = {studyLvl = 44, needCoin = 99020, needItemID = 65715, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105044, }, }, }, },},
		[45] = {studyLvl = 45, needCoin = 103520, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105045, }, }, }, },},
		[46] = {studyLvl = 46, needCoin = 108120, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105046, }, }, }, },},
		[47] = {studyLvl = 47, needCoin = 112820, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105047, }, }, }, },},
		[48] = {studyLvl = 48, needCoin = 117620, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105048, }, }, }, },},
		[49] = {studyLvl = 49, needCoin = 122520, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105049, }, }, }, },},
		[50] = {studyLvl = 50, needCoin = 127520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105050, }, }, }, },},
		[51] = {studyLvl = 51, needCoin = 132620, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105051, }, }, }, },},
		[52] = {studyLvl = 52, needCoin = 137820, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105052, }, }, }, },},
		[53] = {studyLvl = 53, needCoin = 143120, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105053, }, }, }, },},
		[54] = {studyLvl = 54, needCoin = 148520, needItemID = 65715, needItemNum = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105054, }, }, }, },},
		[55] = {studyLvl = 55, needCoin = 154020, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105055, }, }, }, },},
		[56] = {studyLvl = 56, needCoin = 159620, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105056, }, }, }, },},
		[57] = {studyLvl = 57, needCoin = 165320, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105057, }, }, }, },},
		[58] = {studyLvl = 58, needCoin = 171120, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105058, }, }, }, },},
		[59] = {studyLvl = 59, needCoin = 177020, needItemID = 65715, needItemNum = 3, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105059, }, }, }, },},
		[60] = {studyLvl = 60, needCoin = 183020, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105060, }, }, }, },},
		[61] = {studyLvl = 61, needCoin = 189120, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105061, }, }, }, },},
		[62] = {studyLvl = 62, needCoin = 195320, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105062, }, }, }, },},
		[63] = {studyLvl = 63, needCoin = 201620, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105063, }, }, }, },},
		[64] = {studyLvl = 64, needCoin = 208020, needItemID = 65715, needItemNum = 4, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105064, }, }, }, },},
		[65] = {studyLvl = 65, needCoin = 214520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105065, }, }, }, },},
		[66] = {studyLvl = 66, needCoin = 221120, needItemID = 65715, needItemNum = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105066, }, }, }, },},
		[67] = {studyLvl = 67, needCoin = 227820, needItemID = 65715, needItemNum = 6, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105067, }, }, }, },},
		[68] = {studyLvl = 68, needCoin = 234620, needItemID = 65715, needItemNum = 7, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105068, }, }, }, },},
		[69] = {studyLvl = 69, needCoin = 241520, needItemID = 65715, needItemNum = 8, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105069, }, }, }, },},
		[70] = {studyLvl = 70, needCoin = 248520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105070, }, }, }, },},
		[71] = {studyLvl = 71, needCoin = 255520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105071, }, }, }, },},
		[72] = {studyLvl = 72, needCoin = 262520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105072, }, }, }, },},
		[73] = {studyLvl = 73, needCoin = 269520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105073, }, }, }, },},
		[74] = {studyLvl = 74, needCoin = 276520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105074, }, }, }, },},
		[75] = {studyLvl = 75, needCoin = 283520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105075, }, }, }, },},
		[76] = {studyLvl = 76, needCoin = 290520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105076, }, }, }, },},
		[77] = {studyLvl = 77, needCoin = 297520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105077, }, }, }, },},
		[78] = {studyLvl = 78, needCoin = 304520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105078, }, }, }, },},
		[79] = {studyLvl = 79, needCoin = 311520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105079, }, }, }, },},
		[80] = {studyLvl = 80, needCoin = 318520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105080, }, }, }, },},
		[81] = {studyLvl = 81, needCoin = 325520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105081, }, }, }, },},
		[82] = {studyLvl = 82, needCoin = 332520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105082, }, }, }, },},
		[83] = {studyLvl = 83, needCoin = 339520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105083, }, }, }, },},
		[84] = {studyLvl = 84, needCoin = 346520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105084, }, }, }, },},
		[85] = {studyLvl = 85, needCoin = 353520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105085, }, }, }, },},
		[86] = {studyLvl = 86, needCoin = 360520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105086, }, }, }, },},
		[87] = {studyLvl = 87, needCoin = 367520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105087, }, }, }, },},
		[88] = {studyLvl = 88, needCoin = 374520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105088, }, }, }, },},
		[89] = {studyLvl = 89, needCoin = 381520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105089, }, }, }, },},
		[90] = {studyLvl = 90, needCoin = 388520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105090, }, }, }, },},
		[91] = {studyLvl = 91, needCoin = 395520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105091, }, }, }, },},
		[92] = {studyLvl = 92, needCoin = 402520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105092, }, }, }, },},
		[93] = {studyLvl = 93, needCoin = 409520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105093, }, }, }, },},
		[94] = {studyLvl = 94, needCoin = 416520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105094, }, }, }, },},
		[95] = {studyLvl = 95, needCoin = 423520, needItemID = 66148, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105095, }, }, }, },},
		[96] = {studyLvl = 96, needCoin = 430520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105096, }, }, }, },},
		[97] = {studyLvl = 97, needCoin = 437520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105097, }, }, }, },},
		[98] = {studyLvl = 98, needCoin = 444520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105098, }, }, }, },},
		[99] = {studyLvl = 99, needCoin = 451520, needItemID = 65715, needItemNum = 9, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105099, }, }, }, },},
		[100] = {studyLvl = 100, needCoin = 451520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105100, }, }, }, },},
		[101] = {studyLvl = 101, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105101, }, }, }, },},
		[102] = {studyLvl = 102, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105102, }, }, }, },},
		[103] = {studyLvl = 103, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105103, }, }, }, },},
		[104] = {studyLvl = 104, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105104, }, }, }, },},
		[105] = {studyLvl = 105, needCoin = 451520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105105, }, }, }, },},
		[106] = {studyLvl = 106, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105106, }, }, }, },},
		[107] = {studyLvl = 107, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105107, }, }, }, },},
		[108] = {studyLvl = 108, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105108, }, }, }, },},
		[109] = {studyLvl = 109, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105109, }, }, }, },},
		[110] = {studyLvl = 110, needCoin = 451520, needItemID = 66144, needItemNum = 1, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105110, }, }, }, },},
		[111] = {studyLvl = 111, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105111, }, }, }, },},
		[112] = {studyLvl = 112, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105112, }, }, }, },},
		[113] = {studyLvl = 113, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105113, }, }, }, },},
		[114] = {studyLvl = 114, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105114, }, }, }, },},
		[115] = {studyLvl = 115, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105115, }, }, }, },},
		[116] = {studyLvl = 116, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105116, }, }, }, },},
		[117] = {studyLvl = 117, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105117, }, }, }, },},
		[118] = {studyLvl = 118, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105118, }, }, }, },},
		[119] = {studyLvl = 119, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105119, }, }, }, },},
		[120] = {studyLvl = 120, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105120, }, }, }, },},
		[121] = {studyLvl = 121, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105121, }, }, }, },},
		[122] = {studyLvl = 122, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105122, }, }, }, },},
		[123] = {studyLvl = 123, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105123, }, }, }, },},
		[124] = {studyLvl = 124, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105124, }, }, }, },},
		[125] = {studyLvl = 125, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105125, }, }, }, },},
		[126] = {studyLvl = 126, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105126, }, }, }, },},
		[127] = {studyLvl = 127, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105127, }, }, }, },},
		[128] = {studyLvl = 128, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105128, }, }, }, },},
		[129] = {studyLvl = 129, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105129, }, }, }, },},
		[130] = {studyLvl = 130, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105130, }, }, }, },},
		[131] = {studyLvl = 131, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105131, }, }, }, },},
		[132] = {studyLvl = 132, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105132, }, }, }, },},
		[133] = {studyLvl = 133, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105133, }, }, }, },},
		[134] = {studyLvl = 134, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105134, }, }, }, },},
		[135] = {studyLvl = 135, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105135, }, }, }, },},
		[136] = {studyLvl = 136, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105136, }, }, }, },},
		[137] = {studyLvl = 137, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105137, }, }, }, },},
		[138] = {studyLvl = 138, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105138, }, }, }, },},
		[139] = {studyLvl = 139, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105139, }, }, }, },},
		[140] = {studyLvl = 140, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105140, }, }, }, },},
		[141] = {studyLvl = 141, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105141, }, }, }, },},
		[142] = {studyLvl = 142, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105142, }, }, }, },},
		[143] = {studyLvl = 143, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105143, }, }, }, },},
		[144] = {studyLvl = 144, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105144, }, }, }, },},
		[145] = {studyLvl = 145, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105145, }, }, }, },},
		[146] = {studyLvl = 146, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105146, }, }, }, },},
		[147] = {studyLvl = 147, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105147, }, }, }, },},
		[148] = {studyLvl = 148, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105148, }, }, }, },},
		[149] = {studyLvl = 149, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105149, }, }, }, },},
		[150] = {studyLvl = 150, needCoin = 451520, needItemID = 65715, needItemNum = 10, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 105150, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
