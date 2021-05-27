return {
{
	name = Lang.ActivityName.name00013,
	desc = Lang.ActivityName.desc00013,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = Lang.ActivityName.timeDesc00004,
	level = 30,
	icon = 3,
	type = 3,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward005,
	openTimes=
	{
		{
			opensererday = {3},
			months={},
			days ={},
			weeks={},
			minutes=
			{
				"20:00-22:00",
			}
		},
	},
	awards=
	{
		{type=0,id=573,count=1,bind=0,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00173,
			conds = { },
		},
	},
},
}