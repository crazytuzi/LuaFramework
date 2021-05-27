
--#include "..\..\language\LangCode.txt" once
SwingItem =
{
	{ item_id = 4391, level = 3, addBless = 600, },
}
furnaceItem =
{
	{ item_id = 4392,  equipFurnaceIdx = 1,  furnaceStar = 11, furnaceValue = 2000, },
	{ item_id = 4393,  equipFurnaceIdx = 2,  furnaceStar = 11, furnaceValue = 2000, },
	{ item_id = 4394,  equipFurnaceIdx = 3,  furnaceStar = 21, furnaceValue = 10000, },
	{ item_id = 4395,  equipFurnaceIdx = 4,  furnaceStar = 11, furnaceValue = 2000, },
}
VipExperienceItem =
{
	{ item_id = 4380,   experienceTime = 1800, },
}
MultiItemsMakeNewItem =
{
	{ item_id = 1324, count = 10,  newItem = { type=0, id=1325, count=1, bind=1, broadMsg=Lang.ScriptTips.ItemMsg01, }, },
}
ExpBoxItem =
{
	{
		item_id = 4301,
		getExp  =
		{
			{
				rate = 1,
			},
			{
				rate = 2,
				consume = { type=10, id=0, count=50, },
			},
			{
				consume = { type=10, id=0, count=100, },
				vip =
				{
					{ cond = {1,3}, rate = 3, },
					{ cond = {4,6}, rate = 3, },
					{ cond = {7,9}, rate = 3, },
					{ cond = {10,99}, rate = 3, },
				},
			},
		},
	},
	{
		item_id = 4302,
		getExp  =
		{
			{
				rate = 1,
			},
			{
				rate = 2,
				consume = { type=10, id=0, count=250, },
			},
			{
				consume = { type=10, id=0, count=400, },
				vip =
				{
					{ cond = {1,3}, rate = 3, },
					{ cond = {4,6}, rate = 3, },
					{ cond = {7,9}, rate = 3, },
					{ cond = {10,99}, rate = 3, },
				},
			},
		},
	},
	{
		item_id = 4303,
		getExp  =
		{
			{
				rate = 1,
			},
			{
				rate = 2,
				consume = { type=10, id=0, count=1000, },
			},
			{
				consume = { type=10, id=0, count=1600, },
				vip =
				{
					{ cond = {1,3}, rate = 3, },
					{ cond = {4,6}, rate = 3, },
					{ cond = {7,9}, rate = 3, },
					{ cond = {10,99}, rate = 3, },
				},
			},
		},
	},
	{
		item_id = 4304,
		getExp  =
		{
			{
				rate = 1,
			},
			{
				rate = 2,
				consume = { type=10, id=0, count=3750, },
			},
			{
				consume = { type=10, id=0, count=6000, },
				vip =
				{
					{ cond = {1,3}, rate = 3, },
					{ cond = {4,6}, rate = 3, },
					{ cond = {7,9}, rate = 3, },
					{ cond = {10,99}, rate = 3, },
				},
			},
		},
	},
	{
		item_id = 4305,
		getExp  =
		{
			{
				rate = 1,
			},
			{
				rate = 2,
				consume = { type=10, id=0, count=15000, },
			},
			{
				consume = { type=10, id=0, count=24000, },
				vip =
				{
					{ cond = {1,3}, rate = 3, },
					{ cond = {4,6}, rate = 3, },
					{ cond = {7,9}, rate = 3, },
					{ cond = {10,99}, rate = 3, },
				},
			},
		},
	},
	{
		item_id = 4671,
		getExp  =
		{
			{
				rate = 1,
			},
			{
				rate = 2,
				consume = { type=10, id=0, count=50, },
			},
			{
				consume = { type=10, id=0, count=100, },
				vip =
				{
					{ cond = {1,3}, rate = 3, },
					{ cond = {4,6}, rate = 3, },
					{ cond = {7,9}, rate = 3, },
					{ cond = {10,99}, rate = 3, },
				},
			},
		},
	},
}
ConcVipItemTable =
{
	{
		item_id = 1492,
		addHour = 2,
		vipType = enConcVip1,
	},
	{
		item_id = 1493,
		addHour = 2,
		vipType = enConcVip2,
	},
	{
		item_id = 1494,
		addHour = 2,
		vipType = enConcVip3,
	},
}
