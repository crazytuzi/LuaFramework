return {
{
	name =Lang.ActivityName.name00037,
	desc=Lang.ActivityName.desc00037,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = Lang.ActivityName.timeDesc00001,
	level = 35,
	icon = 22,
	type = 2,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward002,
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
		{type=2,id=0,count=-1,bind=1,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=2,name=Lang.EntityName.n00084,
			conds = { },
		},
	},
},
}