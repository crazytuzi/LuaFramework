 --战术研讨						
local zhanshuyantao={						
multiSelectType=true,						
[1]={						
type=1,						
sortId=317,						
						
day=7,	 --活动天数					
						
goldCost1=58,	 --发表意见 金币花费					
goldCost2=232,	 --集中讨论 金币花费					
						
free=1,	 --每天赠送一次普通启动的次数					
num=6,	 --一共具有6个随机格子					
						
spStart1=0,	 --发表意见 初始0个特殊Sp道具					
spStart2=2,	 --集中讨论 初始2个特殊Sp道具					
						
poolStart={	 --启动时 道具出现的几率					
{100},						
{15,17,17,17,17,17},						
{{"sp",1},{"p1",1},{"p2",1},{"p3",1},{"p4",1},{"p4",1},{"p5",1}}						
},						
						
poolRestart={	 --重新变化 道具出现的几率					
{100},						
{20,16,16,16,16,16},						
{{"sp",1},{"p1",1},{"p2",1},{"p3",1},{"p4",1},{"p4",1},{"p5",1}}						
},						
						
reStartTime=5,	 --最多重新变化次数					
 --重新变化的金币花费						
reStartGoldCost={	58,	87,	116,	174,	290,	},
						
reward={	 --奖励兑奖关系					
	[0]={p={	{p601=2,index=1},				}},
	[1]={p={	{p601=3,index=1},	{p446=2,index=2},			}},
	[2]={p={	{p601=5,index=1},	{p446=5,index=2},	{p959=1,index=3},		}},
	[3]={p={	{p601=10,index=1},	{p447=1,index=2},	{p959=2,index=3},		}},
	[4]={p={	{p601=20,index=1},	{p447=2,index=2},	{p961=3,index=3},		}},
	[5]={p={	{p601=40,index=1},	{p448=1,index=2},	{p961=4,index=3},		}},
	[6]={p={	{p601=80,index=1},	{p448=2,index=2},	{p960=5,index=3},	{p608=2,index=4},	}},
},						
						
serverreward={						
	[0]={	props_p601=2,				},
	[1]={	props_p601=3,	props_p446=2,			},
	[2]={	props_p601=5,	props_p446=5,	props_p959=1,		},
	[3]={	props_p601=10,	props_p447=1,	props_p959=2,		},
	[4]={	props_p601=20,	props_p447=2,	props_p961=3,		},
	[5]={	props_p601=40,	props_p448=1,	props_p961=4,		},
	[6]={	props_p601=80,	props_p448=2,	props_p960=5,	props_p608=2,	},
						
}						
},						

 --不含专家心得包						
[2]={						
type=1,						
sortId=317,						
						
day=7,	 --活动天数					
						
goldCost1=58,	 --发表意见 金币花费					
goldCost2=232,	 --集中讨论 金币花费					
						
free=1,	 --每天赠送一次普通启动的次数					
num=6,	 --一共具有6个随机格子					
						
spStart1=0,	 --发表意见 初始0个特殊Sp道具					
spStart2=2,	 --集中讨论 初始2个特殊Sp道具					
						
poolStart={	 --启动时 道具出现的几率					
{100},						
{15,17,17,17,17,17},						
{{"sp",1},{"p1",1},{"p2",1},{"p3",1},{"p4",1},{"p4",1},{"p5",1}}						
},						
						
poolRestart={	 --重新变化 道具出现的几率					
{100},						
{20,16,16,16,16,16},						
{{"sp",1},{"p1",1},{"p2",1},{"p3",1},{"p4",1},{"p4",1},{"p5",1}}						
},						
						
reStartTime=5,	 --最多重新变化次数					
 --重新变化的金币花费						
reStartGoldCost={	58,	87,	116,	174,	290,	},
						
reward={	 --奖励兑奖关系					
	[0]={p={	{p601=2,index=1},				}},
	[1]={p={	{p601=3,index=1},	{p446=2,index=2},			}},
	[2]={p={	{p601=5,index=1},	{p446=5,index=2},	{p959=1,index=3},		}},
	[3]={p={	{p601=10,index=1},	{p447=1,index=2},	{p959=2,index=3},	{p20=2,index=4},	}},
	[4]={p={	{p601=20,index=1},	{p447=2,index=2},	{p959=3,index=3},	{p20=4,index=4},	}},
	[5]={p={	{p601=40,index=1},	{p448=1,index=2},	{p959=4,index=3},	{p20=6,index=4},	}},
	[6]={p={	{p601=80,index=1},	{p448=2,index=2},	{p959=5,index=3},	{p20=8,index=4},	}},
},						
						
serverreward={						
	[0]={	props_p601=2,				},
	[1]={	props_p601=3,	props_p446=2,			},
	[2]={	props_p601=5,	props_p446=5,	props_p959=1,		},
	[3]={	props_p601=10,	props_p447=1,	props_p959=2,	props_p20=2,	},
	[4]={	props_p601=20,	props_p447=2,	props_p959=3,	props_p20=4,	},
	[5]={	props_p601=40,	props_p448=1,	props_p959=4,	props_p20=6,	},
	[6]={	props_p601=80,	props_p448=2,	props_p959=5,	props_p20=8,	},
						
}						
}						
						
}						
return zhanshuyantao						
