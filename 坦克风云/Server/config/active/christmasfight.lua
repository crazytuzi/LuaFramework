local christmasfight={															
multiSelectType=true,															
[1]={															
sortId=1111,															
type=1,															
version=1,															
 --军功提高															
bIncr=0.3,															
 --采集速度提高															
rIncr=0.3,															
--每x秒钟雪人上方进度条增加n点；															
addMin=300,															
--玩家进行采集xM资源，进度条增加n点；向下取证															
addRes=10000000,															
--玩家获得x军功，进度条增加n点；															
addBp=10000,															
 --抽奖增加和减少的点数															
lotNum=1,															
 --进度条点数															
maxPoint=400,															
															
 --单抽金币															
oneCost=98,															
 --十连抽金币															
tenCost=882,															
 --贡献积累奖															
dreward={															
{p=8,	reward={p={p3005=1}},	serverReward={props_p3005=1},	},												
{p=88,	reward={p={p587=1}},	serverReward={props_p587=1},	},												
{p=188,	reward={p={p587=1}},	serverReward={props_p587=1},	},												
{p=288,	reward={p={p894=1}},	serverReward={props_p894=1},	},												
},															
															
 --抽奖奖池															
serverreward={															
poola={ --天使															
{100},															
{	9,	9,	9,	9,	9,	9,	9,	9,	8,	10,	10,	},			
{	{"troops_a10043",3},	{"troops_a10053",3},	{"troops_a10063",3},	{"troops_a10073",3},	{"troops_a10082",2},	{"troops_a10093",3},	{"troops_a10113",3},	{"troops_a10123",3},	{"accessory_p5",1},	{"accessory_p6",1},	{"props_p36",1},	},			
},															
poold={ --恶魔															
{100},															
{	10,	9,	9,	9,	9,	9,	9,	9,	9,	9,	9,	},			
{	{"troops_a10044",2},	{"troops_a10054",2},	{"troops_a10064",2},	{"troops_a10074",2},	{"troops_a10094",2},	{"troops_a10114",2},	{"troops_a10124",2},	{"accessory_p3",5},	{"accessory_p2",2},	{"accessory_p1",2},	{"accessory_p4",100},	},			
},															
bR={															
p351={	props_p542=1	},													
p301={	props_p357=1	},													
p241={	props_p550=1	},													
p171={	props_p365=1	},													
p91={	props_p373=1	},													
p1={	props_p534=1	},													
},															
															
															
															
},															
 --展示大奖															
bR={															
p351={	p={p542=1}},														
p301={	p={p357=1}},														
p241={	p={p550=1}},														
p171={	p={p365=1}},														
p91={	p={p373=1}},														
p1={	p={p534=1}},														
															
															
},															
 --奖池展示															
pool={															
angel={	o={	{a10043=3,index=1},	{a10053=3,index=2},	{a10063=3,index=3},	{a10073=3,index=4},	{a10082=2,index=5},	{a10093=3,index=6},	{a10113=3,index=7},	{a10113=3,index=7},	},e={	{p5=1,index=9},	{p6=1,index=10},	},p={	{p36=1,index=11},	}},
demon={	o={	{a10044=2,index=1},	{a10054=2,index=2},	{a10064=2,index=3},	{a10074=2,index=4},	{a10094=2,index=5},	{a10114=2,index=6},	{a10124=2,index=7},	},e={	{p3=5,index=8},	{p2=2,index=9},	{p1=2,index=10},	{p4=100,index=11},	}},	
},															
															
 --公告点数															
ncRes=10,															
ncBp=50,															
 --贡献大于多少点才可上榜															
cRankp=200,															
 --活跃大于多少点才可上榜															
aRankp=100,															
 --排行榜上榜人数															
rankNum=10,															
 --活跃榜															
rankReward1={															
{range={1,1},	reward={p={p20=20,	p267=4	}},	serverReward={props_p20=20,	props_p267=4	}},									
{range={2,2},	reward={p={p20=15,	p267=3	}},	serverReward={props_p20=15,	props_p267=3	}},									
{range={3,3},	reward={p={p20=10,	p267=2	}},	serverReward={props_p20=10,	props_p267=2	}},									
{range={4,10},	reward={p={p20=5,	p267=1	}},	serverReward={props_p20=5,	props_p267=1	}},									
},															
															
 --贡献榜															
rankReward2={															
{range={1,1},	reward={o={a10082=100},	p={p19=100},	u={gold=10000000},		},	serverReward={troops_a10082=100,	props_p19=100,	userinfo_gold=10000000,	}},						
{range={2,2},	reward={o={a10082=70},	p={p19=90},	u={gold=8000000},		},	serverReward={troops_a10082=70,	props_p19=90,	userinfo_gold=8000000,	}},						
{range={3,3},	reward={o={a10082=50},	p={p19=80},	u={gold=7000000},		},	serverReward={troops_a10082=50,	props_p19=80,	userinfo_gold=7000000,	}},						
{range={4,10},	reward={o={a10082=30},	p={p19=50},	u={gold=5000000},		},	serverReward={troops_a10082=30,	props_p19=50,	userinfo_gold=5000000,	}},						
},															
															
},															
											
																										
																																				
																																												
[2]={															
sortId=1111,															
type=1,															
version=1,															
 --军功提高															
bIncr=0.3,															
 --采集速度提高															
rIncr=0.3,															
--每x秒钟雪人上方进度条增加n点；															
addMin=300,															
--玩家进行采集xM资源，进度条增加n点；向下取证															
addRes=10000000,															
--玩家获得x军功，进度条增加n点；															
addBp=10000,															
 --抽奖增加和减少的点数															
lotNum=1,															
 --进度条点数															
maxPoint=400,															
															
 --单抽金币															
oneCost=98,															
 --十连抽金币															
tenCost=882,															
 --贡献积累奖															
dreward={															
{p=8,	reward={p={p3005=1}},	serverReward={props_p3005=1},	},												
{p=88,	reward={p={p587=1}},	serverReward={props_p587=1},	},												
{p=188,	reward={p={p587=1}},	serverReward={props_p587=1},	},												
{p=288,	reward={p={p894=1}},	serverReward={props_p894=1},	},												
},															
															
 --抽奖奖池															
serverreward={															
poola={ --天使															
{100},															
{	9,	9,	9,	9,	9,	9,	9,	9,	8,	10,	10,	},			
{	{"troops_a10043",3},	{"troops_a10053",3},	{"troops_a10063",3},	{"troops_a10073",3},	{"troops_a10082",2},	{"troops_a10093",3},	{"troops_a10113",3},	{"troops_a10123",3},	{"accessory_p5",1},	{"accessory_p6",1},	{"props_p36",1},	},			
},															
poold={ --恶魔															
{100},															
{	10,	9,	9,	9,	9,	9,	9,	9,	9,	9,	9,	},			
{	{"troops_a10044",2},	{"troops_a10054",2},	{"troops_a10064",2},	{"troops_a10074",2},	{"troops_a10094",2},	{"troops_a10114",2},	{"troops_a10124",2},	{"accessory_p3",5},	{"accessory_p2",2},	{"accessory_p1",2},	{"accessory_p4",100},	},			
},															
bR={															
p351={	props_p542=1	},													
p301={	props_p357=1	},													
p241={	props_p550=1	},													
p171={	props_p365=1	},													
p91={	props_p373=1	},													
p1={	props_p534=1	},													
},															
															
															
															
},															
 --展示大奖															
bR={															
p351={	p={p542=1}},														
p301={	p={p357=1}},														
p241={	p={p550=1}},														
p171={	p={p365=1}},														
p91={	p={p373=1}},														
p1={	p={p534=1}},														
															
															
},															
 --奖池展示															
pool={															
angel={	o={	{a10043=3,index=1},	{a10053=3,index=2},	{a10063=3,index=3},	{a10073=3,index=4},	{a10082=2,index=5},	{a10093=3,index=6},	{a10113=3,index=7},	{a10113=3,index=7},	},e={	{p5=1,index=9},	{p6=1,index=10},	},p={	{p36=1,index=11},	}},
demon={	o={	{a10044=2,index=1},	{a10054=2,index=2},	{a10064=2,index=3},	{a10074=2,index=4},	{a10094=2,index=5},	{a10114=2,index=6},	{a10124=2,index=7},	},e={	{p3=5,index=8},	{p2=2,index=9},	{p1=2,index=10},	{p4=100,index=11},	}},	
},															
															
 --公告点数															
ncRes=10,															
ncBp=50,															
 --贡献大于多少点才可上榜															
cRankp=200,															
 --活跃大于多少点才可上榜															
aRankp=100,															
 --排行榜上榜人数															
rankNum=10,															
 --活跃榜															
rankReward1={															
{range={1,1},	reward={p={p20=20,	p267=4	}},	serverReward={props_p20=20,	props_p267=4	}},									
{range={2,2},	reward={p={p20=15,	p267=3	}},	serverReward={props_p20=15,	props_p267=3	}},									
{range={3,3},	reward={p={p20=10,	p267=2	}},	serverReward={props_p20=10,	props_p267=2	}},									
{range={4,10},	reward={p={p20=5,	p267=1	}},	serverReward={props_p20=5,	props_p267=1	}},									
},															
															
 --贡献榜															
rankReward2={															
{range={1,1},	reward={o={a10082=100},	p={p19=100},	u={gold=10000000},		},	serverReward={troops_a10082=100,	props_p19=100,	userinfo_gold=10000000,	}},						
{range={2,2},	reward={o={a10082=70},	p={p19=90},	u={gold=8000000},		},	serverReward={troops_a10082=70,	props_p19=90,	userinfo_gold=8000000,	}},						
{range={3,3},	reward={o={a10082=50},	p={p19=80},	u={gold=7000000},		},	serverReward={troops_a10082=50,	props_p19=80,	userinfo_gold=7000000,	}},						
{range={4,10},	reward={o={a10082=30},	p={p19=50},	u={gold=5000000},		},	serverReward={troops_a10082=30,	props_p19=50,	userinfo_gold=5000000,	}},						
},															
															
},																											
												
																		

}	
return christmasfight
	