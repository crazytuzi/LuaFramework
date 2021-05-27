
RoseRankConfig = {
	RankData = {
		{
			rankFile = "weekCharming.txt", showName = Lang.Rank.r12, pointName = Lang.Rank.i28, titles = {4, 5, 6}, noticeStr = Lang.ScriptTips.c000081,
			weekAward = {
				{type = 0,id=948,count=1,strong=0,quality=0,bind=1},
			},
		},
		{
			rankFile = "weekHandsome.txt", showName = Lang.Rank.r13, pointName = Lang.Rank.i29, titles = {7, 8, 9}, noticeStr = Lang.ScriptTips.c000082,
			weekAward = {
				{type = 0,id=947,count=1,strong=0,quality=0,bind=1},
			},
		},
	},
}
RedRose = 0
BlueRose = 1
GiveRoseConfig = {
	Coin = 0,
	Rose = {
		[RedRose] = {
			{roseNum = 1, roseItemId = 354, tips = false, gold = 2, toAll = false, toSelf = false},
			{roseNum = 9, roseItemId = 355, atomRoseId = 354, tips = false, gold = 18, toAll = false, toSelf = false },
			{roseNum = 99, roseItemId = 356, tips = true, gold = 213, toAll = false, effectSec = 15, toSelf = true },
			{roseNum = 999, roseItemId = 357, tips = true, gold = 1314, toAll = true, effectSec = 20, toSelf = true },
		},
		[BlueRose] = {
			{roseNum = 1, roseItemId = 359, tips = false, gold = 1, toAll = false, toSelf = false },
			{roseNum = 9, roseItemId = 360, atomRoseId = 359,tips = false, gold = 9, toAll = false, toSelf = false },
			{roseNum = 99, roseItemId = 361, tips = true, gold = 58, toAll = false, effectSec = 10,toSelf = true  },
			{roseNum = 999, roseItemId = 362, tips = true, gold = 388, toAll = true, effectSec = 15,toSelf = true  },
		},
	},
	RoseData = {
		[RedRose] = {1, 1},
		[BlueRose] = {7, 1},
	},
	PickRose = {1, 3, 10},
	PackCoin =  10000,
	UnpackCoin = 0,
	PackRose = {
		[RedRose] =  {
			{srcId=354, srcCount = 9, destId = 355, opt = Lang.ScriptTips.c000032 },
			{srcId=355, srcCount = 10, destId = 356, opt = Lang.ScriptTips.c000033},
			{srcId=356, srcCount = 10, destId = 357, opt = Lang.ScriptTips.c000034},
			{srcId=357, noBind = true,srcCount = 10, destId = 358, opt = Lang.ScriptTips.c000035},
			{srcId=358, noBind = true,srcCount = 10, destId = 287, opt = Lang.ScriptTips.c000036},
		},
	},
	UnpackRose = {
		[RedRose] =  {
			{srcId = 355, destId = 354, destCount = 9, opt = Lang.ScriptTips.c000044},
			{srcId = 356, destId = 355, destCount = 10, opt = Lang.ScriptTips.c000045},
			{srcId = 357, destId = 356, destCount = 10, opt = Lang.ScriptTips.c000046},
			{srcId = 358, destId = 357, destCount = 10, opt = Lang.ScriptTips.c000047},
			{srcId = 287, destId = 358, destCount = 10, opt = Lang.ScriptTips.c000048},
		},
	},
	BuyRose = {
		[RedRose] =  {
			{id=354, count = 1, gold = 2,},
			{id=354, count = 6, gold = 10,},
			{id=354, count = 18, gold = 30,},
			{id=354, count = 36, gold = 58,},
		},
		[BlueRose] = {
			{id=359, count = 1, gold = 4, },
			{id=359, count = 3, gold = 12,},
			{id=359, count = 9, gold = 36,},
			{id=359, count = 15, gold = 60,},
			{id=359, count = 27, gold = 108,},
		},
	},
}