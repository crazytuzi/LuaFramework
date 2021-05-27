
BackToCity =
{
	{item_id = 4266, type = 3, SceneId = 0, x = 0, y = 0,usedura = false},
	{item_id = 4267, type = 2, SceneId = 0, x = 0, y = 0,usedura = false},
}
BackToCityLimitItem = {}
CrossBackToCityLimitItem = {4556,4557,4558,4559,4560}
HeroExpItem =
{
   {
      item_id = 4456,
	  level =
	  {
	    {
		   min = 1, max = 199, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4457,
	  level =
	  {
	    {
		   min = 1, max = 299, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4458,
	  level =
	  {
	    {
		   min = 1, max = 499, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4459,
	  level =
	  {
	    {
		   min = 1, max = 699, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4460,
	  level =
	  {
	    {
		   min = 1, max = 999, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
}
ExpItem =
{
   {
      item_id = 4273,
	  level =
	  {
	    {
		   min = 1, max = 99, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4001,
	  level =
	  {
	    {
		   min = 1, max = 199, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4002,
	  level =
	  {
	    {
		   min = 1, max = 299, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4003,
	  level =
	  {
	    {
		   min = 1, max = 499, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4004,
	  level =
	  {
	    {
		   min = 1, max = 699, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
   {
      item_id = 4005,
	  level =
	  {
	    {
		   min = 1, max = 999, level = 1, exp = 0,
		},
	    {
		   min = 100, max = 999, level = 0, exp = 100000000,
		},
	  },
   },
}
RepairItems =
{
	{item_id = 760, needDelete = true},
}
ForceItems =
{
  {item_id = 780, force = 5},
  {item_id = 866, force = 50},
  {item_id = 867, force = 100},
  {item_id = 868, force = 200},
}
BlessOil =
{
	{
		item_id = 4234,
		blessVal = 1,
		lucksuccRate	= {	10000, 3000, 1500, 1000, 500, 400, 300, 200, 100, },
		lucknoChgRate	= {	0, 6500, 7900, 8300, 8700, 8750, 8800, 8850, 8900, },
		luckfailRate	= {	0, 500, 600, 700, 800, 850, 900, 950, 1000, },
		cursesuccRate	= {	10000, 9000, 8000, 7000, 6000, 5000, 4500, 4000, 3500, 3000, },
		cursenoChgRate	= {	0, 1000, 2000, 3000, 4000, 5000, 5500, 6000, 6500, 7000, },
		cursefailRate	= {	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
		maxLv = 0,
	},
	{
		item_id = 4235,
		blessVal = 1,
		lucksuccRate	= {	10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, },
		lucknoChgRate	= {	0, 0, 0, 0, 0, 0, 0, 0, },
		luckfailRate	= {	0, 0, 0, 0, 0, 0, 0, 0, },
		cursesuccRate	= {	10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, },
		cursenoChgRate	= {	0, 0, 0, 0, 0, 0, 0, 0, },
		cursefailRate	= {	0, 0, 0, 0, 0, 0, 0, 0, },
		maxLv = 99999,
	},
}
CondUseItems =
{
	{
		item_id = 4439,
		useCond = { guildLevel = 1, },
		getItems =
		{
			{ type = 0, id = 4013, count = 2, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4091, count = 2, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4447, count = 2, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4264, count = 2, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4440, count = 1, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 3531, count = 1, quality = 0, strong = 0, bind = 1, },
		},
	},
	{
		item_id = 4440,
		useCond = { guildLevel = 2, },
		getItems =
		{
			{ type = 0, id = 4013, count = 5, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4063, count = 1, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4091, count = 5, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4264, count = 10, quality = 0, strong = 0, bind = 1, },
		},
	},
	{
		item_id = 4476,
		useCond = { firstCharge = true, },
		getItems =
		{
			{ type = 0, id = 4091, count = 5, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4013, count = 5, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4276, count = 1, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4237, count = 1, quality = 0, strong = 0, bind = 1, },
			{ type = 0, id = 4215, count = 1, quality = 0, strong = 0, bind = 1, },
		},
	},
	{
		item_id = 4699,
		useCond = { firstCharge = true,  },
		getItems =
		{
           { type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4058, count = 1, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4063, count = 1, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4700, count = 1, quality = 0, strong = 0, bind = 1, }, --二级战力礼包*1"
		},
	},
	{
		item_id = 4700,
		useCond = { needConsume={type=10,id=0,count=15000}, },
		getItems =
		{
           { type = 10, id = 0, count = 15000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 15000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4091, count = 15, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4023, count = 5, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4701, count = 1, quality = 0, strong = 0, bind = 1, }, --三级战力礼包*1"
		},
	},
	{
		item_id = 4701,
		useCond = { needConsume={type=10,id=0,count=34000}, },
		getItems =
		{
           { type = 10, id = 0, count = 34000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 19000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4048, count = 1, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4028, count = 5, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4702, count = 1, quality = 0, strong = 0, bind = 1, }, --四级战力礼包*1"
		},
	},
	{
		item_id = 4702,
		useCond = { needConsume={type=10,id=0,count=64000}, },
		getItems =
		{
           { type = 10, id = 0, count = 64000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 30000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4034, count = 1, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4703, count = 1, quality = 0, strong = 0, bind = 1, }, --五级战力礼包*1"
		},
	},
	{
		item_id = 4703,
		useCond = { needConsume={type=10,id=0,count=164000}, },
		getItems =
		{
           { type = 10, id = 0, count = 164000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 100000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4483, count = 3, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4039, count = 2, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4704, count = 1, quality = 0, strong = 0, bind = 1, }, --六级战力礼包*1"
		},
	},
	{
		item_id = 4704,
		useCond = { needConsume={type=10,id=0,count=328000}, },
		getItems =
		{
           { type = 10, id = 0, count = 328000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 160000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4647, count = 5, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4448, count = 3, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4705, count = 1, quality = 0, strong = 0, bind = 1, }, --七级战力礼包*1"
		},
	},
	{
		item_id = 4705,
		useCond = { needConsume={type=10,id=0,count=500000}, },
		getItems =
		{
           { type = 10, id = 0, count = 500000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 176000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4035, count = 1, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4706, count = 1, quality = 0, strong = 0, bind = 1, }, --八级战力礼包*1"
		},
	},
	{
		item_id = 4706,
		useCond = { needConsume={type=10,id=0,count=1000000}, },
		getItems =
		{
           { type = 10, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 500000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4040, count = 2, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4064, count = 3, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4707, count = 1, quality = 0, strong = 0, bind = 1, }, --九级战力礼包*1"
		},
	},
	{
		item_id = 4707,
		useCond = { needConsume={type=10,id=0,count=1500000}, },
		getItems =
		{
           { type = 10, id = 0, count = 1500000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 500000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4091, count = 500, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4449, count = 3, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4708, count = 1, quality = 0, strong = 0, bind = 1, }, --十级战力礼包*1"
		},
	},
	{
		item_id = 4708,
		useCond = { needConsume={type=10,id=0,count=2500000}, },
		getItems =
		{
           { type = 10, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4094, count = 10, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4053, count = 3, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4709, count = 1, quality = 0, strong = 0, bind = 1, }, --十一级战力礼包*1"
		},
	},
	{
		item_id = 4709,
		useCond = { needConsume={type=10,id=0,count=5000000}, },
		getItems =
		{
           { type = 10, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4102, count = 10, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4122, count = 10, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4710, count = 1, quality = 0, strong = 0, bind = 1, }, --十二级战力礼包*1"
		},
	},
	{
		item_id = 4710,
		useCond = { needConsume={type=10,id=0,count=10000000}, },
		getItems =
		{
           { type = 10, id = 0, count = 10000000, quality = 0, strong = 0, bind = 1, },
           { type = 5, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4162, count = 10, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4142, count = 10, quality = 0, strong = 0, bind = 1, },
           { type = 0, id = 4648, count = 10, quality = 0, strong = 0, bind = 1, }, --至尊碎片*10"
		},
	},
}
