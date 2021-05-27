return {
{
	name =Lang.ActivityName.name00022,
	desc=Lang.ActivityName.desc00031,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = "16:30-17:00",
	level = 35,
	icon = 32,
	type = 1,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward016,
	openTimes=
	{
		{
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"16:30-17:00",
			}
		},
	},
	awards=
	{
		{type=2,id=0,count=-1,bind=1,strong=0,quality=0},
		{type=6,id=0,count=-1,bind=1,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=1,name=Lang.EntityName.n00005,
			conds = { },
		},
	},
},
}