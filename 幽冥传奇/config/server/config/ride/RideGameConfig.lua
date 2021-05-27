--#include "..\..\language\LangCode.txt"
RideGameConfig =
{
	openLevel = 41,
	OneUpExp = 500,
	FreeUpCount = 0,
    nBindCoin = 0,
    CoinUpCount = {20,30,40,55,70,85,105,125,145,170,195,225,260},
	BindCoinConsume = {type = 5,id = 0,count = 100000,logs = {923,"金币提升坐骑"}},
	nItem = 415,
	YBUp =
	{
		{count = 1, needYb = 50},
		{count = 10, needYb = 475},
		{count = 50, needYb = 2400},
		{count = 100, needYb = 4600},
		{count = 500, needYb = 22500},
	},
	rideRankConfig =
	{
		{
			level=1,needExp=0,
			needChopLevel = 0,
			allOptionsNum = 0,
			baseAttrConfig =
			{
				{type=9,addmode=0,value=25,},
				{type=11,addmode=0,value=100,},
				{type=13,addmode=0,value=25,},
				{type=15,addmode=0,value=100,},
				{type=17,addmode=0,value=25,},
				{type=19,addmode=0,value=100,},
				{type=21,addmode=0,value=28,},
				{type=23,addmode=0,value=56,},
				{type=25,addmode=0,value=20,},
				{type=27,addmode=0,value=39,},
				{type=49,addmode=1,value=-120,},
			},
			needItemInfo=
			{
				nBindCoin=500000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride001
		},
		{
			level=2,needExp=12000,
			needChopLevel = 1,
			allOptionsNum = 2,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=38,},
				{type=11,addmode=0,value=150,},
				{type=13,addmode=0,value=38,},
				{type=15,addmode=0,value=150,},
				{type=17,addmode=0,value=38,},
				{type=19,addmode=0,value=150,},
				{type=21,addmode=0,value=42,},
				{type=23,addmode=0,value=83,},
				{type=25,addmode=0,value=29,},
				{type=27,addmode=0,value=58,},
				{type=49,addmode=1,value=-122,},
			},
			needItemInfo=
			{
				nBindCoin=1000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride002
		},
		{
			level=3,needExp=86000,
			needChopLevel = 2,
			allOptionsNum = 3,
			baseAttrConfig=
				{
					{type=9,addmode=0,value=63,},
					{type=11,addmode=0,value=250,},
					{type=13,addmode=0,value=63,},
					{type=15,addmode=0,value=250,},
					{type=17,addmode=0,value=63,},
					{type=19,addmode=0,value=250,},
					{type=21,addmode=0,value=70,},
					{type=23,addmode=0,value=139,},
					{type=25,addmode=0,value=49,},
					{type=27,addmode=0,value=97,},
					{type=49,addmode=1,value=-124,},
				},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride003
		},
		{
			needChopLevel = 3,
			allOptionsNum = 4,
			level=4,needExp=240000,
			baseAttrConfig=
				{
					{type=9,addmode=0,value=100,},
					{type=11,addmode=0,value=400,},
					{type=13,addmode=0,value=100,},
					{type=15,addmode=0,value=400,},
					{type=17,addmode=0,value=100,},
					{type=19,addmode=0,value=400,},
					{type=21,addmode=0,value=110,},
					{type=23,addmode=0,value=220,},
					{type=25,addmode=0,value=78,},
					{type=27,addmode=0,value=155,},
					{type=49,addmode=1,value=-126,},
				},
				needItemInfo=
				{
					nBindCoin=2000,itemId=542,itemCount=1,
				},
			buff={},
			name = Lang.ScriptTips.ride004
		},
		{
			needChopLevel = 4,
			allOptionsNum = 5,
			level=5,needExp=650000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=150,},
				{type=11,addmode=0,value=600,},
				{type=13,addmode=0,value=150,},
				{type=15,addmode=0,value=600,},
				{type=17,addmode=0,value=150,},
				{type=19,addmode=0,value=600,},
				{type=21,addmode=0,value=167,},
				{type=23,addmode=0,value=333,},
				{type=25,addmode=0,value=117,},
				{type=27,addmode=0,value=233,},
				{type=49,addmode=1,value=-128,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride005
		},
		{
			needChopLevel = 5,
			allOptionsNum = 5,
			level=6,needExp=950000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=213,},
				{type=11,addmode=0,value=900,},
				{type=13,addmode=0,value=213,},
				{type=15,addmode=0,value=900,},
				{type=17,addmode=0,value=213,},
				{type=19,addmode=0,value=900,},
				{type=21,addmode=0,value=236,},
				{type=23,addmode=0,value=472,},
				{type=25,addmode=0,value=165,},
				{type=27,addmode=0,value=330,},
				{type=49,addmode=1,value=-130,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride006
		},
		{
			needChopLevel = 6,
			allOptionsNum = 5,
			level=7,needExp=1400000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=288,},
				{type=11,addmode=0,value=1300,},
				{type=13,addmode=0,value=288,},
				{type=15,addmode=0,value=1300,},
				{type=17,addmode=0,value=288,},
				{type=19,addmode=0,value=1300,},
				{type=21,addmode=0,value=320,},
				{type=23,addmode=0,value=639,},
				{type=25,addmode=0,value=224,},
				{type=27,addmode=0,value=447,},
				{type=49,addmode=1,value=-132,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride007
		},
		{
			needChopLevel = 7,
			allOptionsNum = 5,
			level=8,needExp=2000000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=375,},
				{type=11,addmode=0,value=1800,},
				{type=13,addmode=0,value=375,},
				{type=15,addmode=0,value=1800,},
				{type=17,addmode=0,value=375,},
				{type=19,addmode=0,value=1800,},
				{type=21,addmode=0,value=417,},
				{type=23,addmode=0,value=833,},
				{type=25,addmode=0,value=292,},
				{type=27,addmode=0,value=583,},
				{type=49,addmode=1,value=-134,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},
			name = Lang.ScriptTips.ride008
		},
		{
			needChopLevel = 8,
			allOptionsNum = 5,
			level=9,needExp=2500000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=475,},
				{type=11,addmode=0,value=2400,},
				{type=13,addmode=0,value=475,},
				{type=15,addmode=0,value=2400,},
				{type=17,addmode=0,value=475,},
				{type=19,addmode=0,value=2400,},
				{type=21,addmode=0,value=528,},
				{type=23,addmode=0,value=1056,},
				{type=25,addmode=0,value=370,},
				{type=27,addmode=0,value=739,},
				{type=49,addmode=1,value=-136,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},name = Lang.ScriptTips.ride009
		},
		{
			needChopLevel = 9,
			allOptionsNum = 5,
			level=10,needExp=3600000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=588,},
				{type=11,addmode=0,value=3100,},
				{type=13,addmode=0,value=588,},
				{type=15,addmode=0,value=3100,},
				{type=17,addmode=0,value=588,},
				{type=19,addmode=0,value=3100,},
				{type=21,addmode=0,value=653,},
				{type=23,addmode=0,value=1306,},
				{type=25,addmode=0,value=457,},
				{type=27,addmode=0,value=914,},
				{type=49,addmode=1,value=-138,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},name = Lang.ScriptTips.ride010
		},
	        {
			needChopLevel = 10,
			allOptionsNum = 5,
			level=11,needExp=4800000,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=713,},
				{type=11,addmode=0,value=3900,},
				{type=13,addmode=0,value=713,},
				{type=15,addmode=0,value=3900,},
				{type=17,addmode=0,value=713,},
				{type=19,addmode=0,value=3900,},
				{type=21,addmode=0,value=792,},
				{type=23,addmode=0,value=1583,},
				{type=25,addmode=0,value=554,},
				{type=27,addmode=0,value=1108,},
				{type=49,addmode=1,value=-140,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},name = Lang.ScriptTips.ride011
		},
	{
			level=12,needExp=6800000,
			needChopLevel = 11,
			allOptionsNum = 5,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=850,},
				{type=11,addmode=0,value=4900,},
				{type=13,addmode=0,value=850,},
				{type=15,addmode=0,value=4900,},
				{type=17,addmode=0,value=850,},
				{type=19,addmode=0,value=4900,},
				{type=21,addmode=0,value=945,},
				{type=23,addmode=0,value=1889,},
				{type=25,addmode=0,value=661,},
				{type=27,addmode=0,value=1322,},
				{type=49,addmode=1,value=-143,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},name = Lang.ScriptTips.ride012
		},
	{
			level=13,needExp=10800000,
			needChopLevel = 12,
			allOptionsNum = 5,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=1000,},
				{type=11,addmode=0,value=6100,},
				{type=13,addmode=0,value=1000,},
				{type=15,addmode=0,value=6100,},
				{type=17,addmode=0,value=1000,},
				{type=19,addmode=0,value=6100,},
				{type=21,addmode=0,value=1111,},
				{type=23,addmode=0,value=2222,},
				{type=25,addmode=0,value=778,},
				{type=27,addmode=0,value=1555,},
				{type=49,addmode=1,value=-146,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},name = Lang.ScriptTips.ride013
		},
	{
			level=14,needExp=18000000,
			needChopLevel = 13,
			allOptionsNum = 5,
			baseAttrConfig=
			{
				{type=9,addmode=0,value=1163,},
				{type=11,addmode=0,value=7500,},
				{type=13,addmode=0,value=1163,},
				{type=15,addmode=0,value=7500,},
				{type=17,addmode=0,value=1163,},
				{type=19,addmode=0,value=7500,},
				{type=21,addmode=0,value=1292,},
				{type=23,addmode=0,value=2583,},
				{type=25,addmode=0,value=904,},
				{type=27,addmode=0,value=1808,},
				{type=49,addmode=1,value=-150,},
			},
			needItemInfo=
			{
				nBindCoin=2000,itemId=542,itemCount=1,
			},
			buff={},name = Lang.ScriptTips.ride014
		},
	},
}