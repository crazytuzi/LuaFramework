return {
{
	name =Lang.ActivityName.name00004,
	desc=Lang.ActivityName.desc00004,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = Lang.ActivityName.timeDesc00001,
	level = 35,
	icon = 22,
	type = 2,
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
				"00:00-23:59",
			}
		},
	},
	awards=
	{
		{type=2,id=0,count=-1,bind=1,strong=0,quality=0},
		{type=6,id=0,count=-1,bind=1,strong=0,quality=0},
                {type=0,id=280,count=-1,bind=1,strong=0,quality=0},
                {type=0,id=281,count=-1,bind=1,strong=0,quality=0},
                {type=0,id=282,count=-1,bind=1,strong=0,quality=0},
                {type=0,id=283,count=-1,bind=1,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00024,
			conds = { },
		},
	},
},
}