 --万圣节不给糖就捣乱活动										
local halloween={										
multiSelectType=true,										
 --第一版										
[1]={										
sortId=200,										
atRate=10,	 --攻打关卡给糖的概率									
arRate=17,	 --扫矿给糖果的概率									
										
serverreward={										
apool={	 --攻打关卡或者扫矿给的糖果									
{100},										
{3,2},										
{{"t1",1},{"t2",1},}										
},										
dayreward={	 --每天的充值奖励									
t={	t2=1,	t1=2,	},							
p={	props_p20=5,	props_p393=15,	},							
},										
totalreward={	 --每到cost领一次									
t={	t4=1,	t3=1,	},							
p={	props_p818=10,	props_p601=30,	},							
},										
 --种子奖励										
reward={										
t1={										
{100},										
{	10,	17,	10,	15,	15,	15,	15,	3,	},	
{	{"props_p19",3},	{"props_p601",5},	{"props_p20",1},	{"props_p393",2},	{"props_p394",2},	{"props_p395",2},	{"props_p396",2},	{"props_p5",1},	},	
},										
t2={										
{100},										
{	30,	25,	25,	7,	10,	3,	},			
{	{"accessory_p3",15},	{"accessory_p2",3},	{"accessory_p1",2},	{"accessory_p4",100},	{"accessory_p6",1},	{"accessory_p5",1},	},			
},										
t3={										
{100},										
{	16,	12,	12,	12,	12,	12,	12,	12,	},	
{	{"props_p611",3},	{"props_p612",3},	{"props_p613",3},	{"props_p614",3},	{"props_p615",3},	{"props_p616",3},	{"props_p617",3},	{"props_p618",3},	},	
},										
t4={										
{100},										
{	22,	26,	22,	14,	16,		},			
{	{"troops_a10044",12},	{"troops_a10054",12},	{"troops_a10064",12},	{"troops_a10074",12},	{"troops_a10094",12},		},			
},										
										
},										
										
cropreward={props_p963=1},	 --种植奖励,紫色配件碎片									
asreward={props_p893=1},	 --抢夺奖励,头像									
},										
										
 --前台格式										
dayreward={	 --每天的充值奖励									
{t={	{t2=1,index=1},	{t1=2,index=2},	},p={	{p20=5,index=3},	{p393=15,index=4},	}},				
},										
totalreward={	 --每到cost领一次									
{t={	{t4=1,index=1},	{t3=1,index=2},	},p={	{p818=10,index=3},	{p601=30,index=4},	}},				
},										
										
showlist={p={{p267=3,index=1},{p20=2,index=2},{p19=5,index=3},{p2=2,index=3},{p47=5,index=4},{p982=10,index=5},{p983=5,index=6},}},										
										
reward={										
{	p={	{p19=3,index=1},	{p601=5,index=2},	{p20=1,index=3},	{p393=2,index=4},	{p394=2,index=5},	{p395=2,index=6},	{p396=2,index=7},	{p5=1,index=8},	}},
{	e={	{p3=15,index=1},	{p2=3,index=2},	{p1=2,index=3},	{p4=100,index=4},	{p6=1,index=5},	{p5=1,index=6},			}},
{	p={	{p611=3,index=1},	{p612=3,index=2},	{p613=3,index=3},	{p614=3,index=4},	{p615=3,index=5},	{p616=3,index=6},	{p617=3,index=7},	{p618=3,index=8},	}},
{	o={	{a10044=12,index=1},	{a10054=12,index=2},	{a10064=12,index=3},	{a10074=12,index=4},	{a10094=12,index=5},				}},
},										
										
cropreward={p={p963=1}},	 --种植奖励									
asreward={p={p893=1}},	 --抢夺奖励									
										
needtime={	t1=1,	t2=2,	t3=4,	t4=8,	},					
cost=2000,										
cropcount=40,	 --种植									
ascount=60,	 --抢夺									
gemsecond=60,	 --加速价格，多少秒一金币									
										
},										
										
}										
return halloween										
