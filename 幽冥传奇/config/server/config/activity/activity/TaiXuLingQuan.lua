return {
{
	name =Lang.ActivityName.name00041,
	desc=Lang.ActivityName.desc00042,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = "13:40-14:20",
	level = 30,
	icon = 28,
	type = 1,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward020,
	openTimes=
	{
		{
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"13:40-14:20",
			}
		},
	},
	awards=
	{
		{type=2,id=0,count=-1,bind=1,strong=0,quality=0},
		{type=7,id=0,count=-1,bind=1,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00155,
			conds = { },
		},
	},
},
}