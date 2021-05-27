--#include "..\..\language\LangCode.txt"
EquipEnchantElemCfg =
{
	[128] = { elemName = Lang.ScriptTips.EquipEnchantElemLight, },
	[6] = { elemName = Lang.ScriptTips.EquipEnchantElemLight, },
	[8] = { elemName = Lang.ScriptTips.EquipEnchantElemLight, },
	[80] = { elemName = Lang.ScriptTips.EquipEnchantElemDark, },
	[12] = { elemName = Lang.ScriptTips.EquipEnchantElemDark, },
	[16] = { elemName = Lang.ScriptTips.EquipEnchantElemDark, },
	[20] = { elemName = Lang.ScriptTips.EquipEnchantElemDark, },
	[120] = { elemName = Lang.ScriptTips.EquipEnchantElemFire, },
	[121] = { elemName = Lang.ScriptTips.EquipEnchantElemFire, },
	[11] = { elemName = Lang.ScriptTips.EquipEnchantElemFire, },
	[27] = { elemName = Lang.ScriptTips.EquipEnchantElemFire, },
	[118] = { elemName = Lang.ScriptTips.EquipEnchantElemWind, },
	[119] = { elemName = Lang.ScriptTips.EquipEnchantElemWind, },
	[15] = { elemName = Lang.ScriptTips.EquipEnchantElemWind, },
	[23] = { elemName = Lang.ScriptTips.EquipEnchantElemWind, },
	[122]	= { elemName = Lang.ScriptTips.EquipEnchantElemWater, },
	[123]	= { elemName = Lang.ScriptTips.EquipEnchantElemWater, },
	[19]	= { elemName = Lang.ScriptTips.EquipEnchantElemWater, },
	[25]	= { elemName = Lang.ScriptTips.EquipEnchantElemWater, },
	[124] = { elemName = Lang.ScriptTips.EquipEnchantElemEarth,	},
	[125] = { elemName = Lang.ScriptTips.EquipEnchantElemEarth,	},
	[63] = { elemName = Lang.ScriptTips.EquipEnchantElemEarth,	},
	[21] = { elemName = Lang.ScriptTips.EquipEnchantElemEarth,	},
}
ActorEnchantCfg =
{
	{ addExp = 1, maxExp = 100, },
	{ addExp = 1, maxExp = 500, },
	{ addExp = 1, maxExp = 1000, },
	{ addExp = 1, maxExp = 2000, },
	{ addExp = 1, maxExp = 4000, },
	{ addExp = 1, maxExp = 7000, },
	{ addExp = 1, maxExp = 10000, },
	{ addExp = 1, maxExp = 30000, },
	{ addExp = 1, maxExp = 60000, },
	{ addExp = 1, maxExp = 100000, },
	{ addExp = 1, maxExp = 150000, },
	{ addExp = 1, maxExp = 200000, },
	{ addExp = 1, maxExp = 300000, },
	{ addExp = 1, maxExp = 400000, },
	{ addExp = 1, maxExp = 500000, },
	{ addExp = 1, maxExp = 600000, },
	{ addExp = 1, maxExp = 700000, },
	{ addExp = 1, maxExp = 800000, },
	{ addExp = 1, maxExp = 900000, },
	{ addExp = 1, maxExp = 1000000, },
	{ addExp = 1, maxExp = 0, },
}
EquipEnchantCfg =
{
	{
		equipCircle 	= { 5, 7 },
		equipLevel 		= { 0, 0 },
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 40, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 30 }, smithId = 21, },
			{ enchantCount = { 31, 90 }, smithId = 22, },
			{ enchantCount = { 91, 180 }, smithId = 23, },
			{ enchantCount = { 181, 270 }, smithId = 24, },
			{ enchantCount = { 271, 9999999 }, smithId = 25, },
		},
	},
	{
		equipCircle 	= { 8, 10 },
		equipLevel 		= { 0, 0 },
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 60, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 40 }, smithId = 22, },
			{ enchantCount = { 41, 120 }, smithId = 23, },
			{ enchantCount = { 121, 240 }, smithId = 24, },
			{ enchantCount = { 241, 360 }, smithId = 25, },
			{ enchantCount = { 361, 9999999 }, smithId = 26, },
		},
	},
	{
		equipCircle 	= { 11, 13 },
		equipLevel 		= { 0, 0 },
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 80, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 50 }, smithId = 23, },
			{ enchantCount = { 51, 150 }, smithId = 24, },
			{ enchantCount = { 151, 300 }, smithId = 25, },
			{ enchantCount = { 301, 450 }, smithId = 26, },
			{ enchantCount = { 451, 9999999 }, smithId = 27, },
		},
	},
	{
		equipCircle 	= { 14, 16 },
		equipLevel 		= { 0, 0 },
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 60 }, smithId = 24, },
			{ enchantCount = { 61, 180 }, smithId = 25, },
			{ enchantCount = { 181, 360 }, smithId = 26, },
			{ enchantCount = { 361, 540 }, smithId = 27, },
			{ enchantCount = { 541, 9999999 }, smithId = 28, },
		},
	},
	{
		equipCircle 	= { 17, 19 },
		equipLevel 		= { 0, 0 },
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 70 }, smithId = 25, },
			{ enchantCount = { 71, 210 }, smithId = 26, },
			{ enchantCount = { 211, 420 }, smithId = 27, },
			{ enchantCount = { 421, 630 }, smithId = 28, },
			{ enchantCount = { 631, 9999999 }, smithId = 29, },
		},
	},
	{
		equipCircle 	= { 20, 22 },
		equipLevel 		= { 0, 0},
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 80 }, smithId = 27, },
			{ enchantCount = { 81, 240 }, smithId = 28, },
			{ enchantCount = { 241, 480 }, smithId = 29, },
			{ enchantCount = { 481, 720 }, smithId = 30, },
			{ enchantCount = { 721, 9999999 }, smithId = 31, },
		},
	},
	{
		equipCircle 	= { 23, 25 },
		equipLevel 		= { 0, 0},
		attrNum			= 3,
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 90 } , smithId = 29, },
			{ enchantCount = { 91, 270 }, smithId = 30, },
			{ enchantCount = { 271, 540 }, smithId = 31, },
			{ enchantCount = { 541, 810 }, smithId = 32, },
			{ enchantCount = { 811, 9999999 }, smithId = 33, },
		},
	},
	{
		equipCircle 	= { 26, 28 },
		equipLevel 		= { 0, 0},
		attrNum			= 3,
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 100 } , smithId = 31, },
			{ enchantCount = { 101, 300 }, smithId = 32, },
			{ enchantCount = { 301, 600 }, smithId = 33, },
			{ enchantCount = { 601, 900 }, smithId = 34, },
			{ enchantCount = { 901, 9999999 }, smithId = 35, },
		},
	},
	{
		equipCircle 	= { 29, 31 },
		equipLevel 		= { 0, 0 },
		attrNum			= 3,
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 110 } , smithId = 33, },
			{ enchantCount = { 111, 330 }, smithId = 34, },
			{ enchantCount = { 331, 660 }, smithId = 35, },
			{ enchantCount = { 661, 990 }, smithId = 36, },
			{ enchantCount = { 991, 9999999 }, smithId = 37, },
		},
	},
	{
		equipCircle 	= { 33, 999},
		equipLevel 		= { 0, 0 },
		attrNum			= 3,
		enchantConsumes 	=
		{
			{ type = 0, id = 4092, count = 10, },
		},
		lockConsumes 	=
		{
			{ type = 10, id = 0, count = 100, },
		},
		smithLib =
		{
			{ enchantCount = { 0, 120 } , smithId = 35, },
			{ enchantCount = { 121, 360 }, smithId = 36, },
			{ enchantCount = { 361, 720 }, smithId = 37, },
			{ enchantCount = { 721, 1080 }, smithId = 38, },
			{ enchantCount = { 1081, 1620 }, smithId = 39, },
			{ enchantCount = { 1621, 9999999 }, smithId = 40, },
		},
	},
}
