return {
{
	name =Lang.ActivityName.name00035,
	desc=Lang.ActivityName.desc00035,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = Lang.ActivityName.timeDesc00001,
	level = 30,
	icon = 22,
	type = 2,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward003,
	openTimes=
	{
		{
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"00:00-24:00",
			}
		},
	},
	awards=
	{
		{type=6,id=0,count=-1,bind=0,strong=0,quality=1},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00030,
			conds = { },
		},
	},
},
}