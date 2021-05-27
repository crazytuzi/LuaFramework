return {
{
	name =Lang.ActivityName.name00020,
	desc=Lang.ActivityName.desc00020,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = Lang.ActivityName.timeDesc00011,
	level = 1,
	icon = 10,
	type = 3,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward005,
	openTimes=
	{
		{
			opensererday = {10},
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"0:00-23:00",
			}
		},
	},
	awards=
	{
		{type=0,id=960,count=1,bind=0,strong=0,quality=0},
	},
	npc=
	{
		{	},
	},
},
}