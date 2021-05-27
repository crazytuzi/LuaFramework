
DarkBoxConfig =
{
	sceneId = 206,
	activityTime = 1800,
	level = {0, 70},
	EnterPos = {206,108,86,5,5},
	RelivePos = {{24,86,3,3},{63,86,3,3}},
	itemId = 4095,
	itemMaxCount = 30,
	Monsters =
	{
		{
			refreshTime = 15,
			Monster =
			{
        			{monsterId=561, range={0,108,86,0}, count = 50, livetime=1800,},
				{monsterId=562, range={0,108,86,0}, count = 50, livetime=1800,},
			}
		},
		{
			refreshTime = 150,
			Monster =
			{
        			{monsterId=563, posX = 45, posY = 87, count = 1, livetime=1800,},
				{monsterId=564, posX = 65, posY = 59, count = 1, livetime=1800,},
				{monsterId=565, posX = 39, posY = 24, count = 1, livetime=1800,},
				{monsterId=566, posX = 19, posY = 52, count = 1, livetime=1800,},
			}
		},
		{
			refreshTime = 210,
			broadMsg = Lang.ScriptTips.DarkBox003,
			Monster =
			{
				{monsterId=567, posX = 36, posY = 82, count = 1, livetime=1800, needItemCount = 3,needBagCount=1,},
				{monsterId=567, posX = 25, posY = 67, count = 1, livetime=1800, needItemCount = 3,needBagCount=1,},
				{monsterId=567, posX = 52, posY = 32, count = 1, livetime=1800, needItemCount = 3,needBagCount=1,},
				{monsterId=567, posX = 62, posY = 47, count = 1, livetime=1800, needItemCount = 3,needBagCount=1,},
			}
		},
		{
			refreshTime = 420,
			broadMsg = Lang.ScriptTips.DarkBox003,
			Monster =
			{
				{monsterId=568, posX = 34, posY = 44, count = 1, livetime=1800, needItemCount = 10,needBagCount=1,},
				{monsterId=568, posX = 51, posY = 68, count = 1, livetime=1800, needItemCount = 10,needBagCount=1,},
			}
		},
		{
			refreshTime = 660,
			broadMsg = Lang.ScriptTips.DarkBox002,
			Monster =
			{
				{monsterId=569, posX = 43, posY = 57, count = 1, livetime=1800, needItemCount = 30,needBagCount=1,},
			}
		},
	},
}
