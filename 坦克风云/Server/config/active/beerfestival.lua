 --啤酒节													
local beerfestival={													
	multiSelectType=true,												
	 --第一版												
	[1]={												
		sortId=200,											
		Rate1={15,0},	--攻打关卡获得概率										
		Rate2={15,0},	--补给线获得概率										
		Rate3={30,0},	--装备探索获得概率										
		Rate4={0,10},	--攻击基地获得概率										
		Rate5={0,30},	--攻打海盗获得概率										
		Rate6={30,0},	--剧情战役获得概率										
		stages={	500,	1000,	2000,	},	--材料需求数量阶梯						
		cost=300,	--充值礼包需要充值钻石数量										
		serverreward={											
			dayreward={	troops_a10083=3,				t1=2,	t2=2,	},	 --每次的充值奖励		
			t1={{	props_p20=2,	props_p19=5,	},{	props_p275=2,	props_p276=4,	},{	props_p819=10,		}},	 --材料1对应阶段奖励
			t2={{	props_p2=1,		},{	props_p4603=2,		},{	props_p818=5,	props_p448=5,	}},	 --材料2对应阶段奖励
			final={	troops_a10083=20,	troops_a10074=20,			},	--最终大奖				
			fbreward={	troops_a10083=2,	t1=1,	t2=1,	},	--分享奖励					
			pool1={							--材料1兑换奖池			
				{100},									
				{	10,	10,	10,	10,	10,	10,	},		
				{	{"armor_exp",1000},	{"accessory_p4",500},	{"accessory_p6",3},	{"props_p957",5},	{"props_p446",10},	{"props_p819",2},	},		
			},										
			pool2={							--材料2兑换奖池			
				{100},									
				{	5,	10,	5,	20,	20,	10,			},
				{	{"armor_exp",2000},	{"accessory_p3",20},	{"accessory_p5",1},	{"props_p956",2},	{"props_p447",2},	{"props_p818",1},			},
			},										
		},											
		 --前台格式											
		reward={											
			dayreward={	 --每天的充值奖励									
				{o={	{a10083=3,index=1},				},beer={	{t1=2,index=3},	{t2=2,index=4},	}},	
			},										
			t1={{p={	p20=2,	p19=5,	}},{p={	p275=2,	p276=4,	}},{p={	p819=10,		}}},	
			t2={{p={	p2=1,		}},{p={	p4603=2,		}},{p={	p818=5,	p448=5,	}}},	
													
			final={o={	{a10083=20,index=1},	{a10074=20,index=2},			}},					
			fbreward={o={	{a10083=2,index=1},	},beer={	{t1=1,index=2},	{t2=1,index=3},	}},					
		},											
	},	
	 --第二版												
	[2]={												
		sortId=200,											
		Rate1={15,0},	--攻打关卡获得概率										
		Rate2={15,0},	--补给线获得概率										
		Rate3={30,0},	--装备探索获得概率										
		Rate4={0,10},	--攻击基地获得概率										
		Rate5={0,30},	--攻打海盗获得概率										
		Rate6={30,0},	--剧情战役获得概率										
		stages={	500,	1000,	2000,	},	--材料需求数量阶梯						
		cost=300,	--充值礼包需要充值钻石数量										
		serverreward={											
			dayreward={	troops_a10084=5,				t1=2,	t2=2,	},	 --每次的充值奖励		
			t1={{	props_p20=10,	props_p2=1,	},{	props_p275=10,	props_p276=20,	},{	props_p3436=10,		}},	 --材料1对应阶段奖励
			t2={{	props_p19=50,		},{	props_p960=10,		},{	props_p4604=1,	}},	 --材料2对应阶段奖励
			final={	troops_a10084=30,	troops_a10075=30,			},	--最终大奖				
			fbreward={	troops_a10084=2,	t1=1,	t2=1,	},	--分享奖励					
			pool1={							--材料1兑换奖池			
				{100},									
				{	10,	10,	10,	5,	10,	10,	},		
				{	{"armor_exp",1500},	{"accessory_p4",1000},	{"props_p279",3},	{"props_p959",2},	{"props_p447",5},	{"props_p818",1},	},		
			},										
			pool2={							--材料2兑换奖池			
				{100},									
				{	20,	30,	20,	5,	20,	20,			},
				{	{"armor_exp",3000},	{"accessory_p3",30},	{"accessory_p5",1},	{"props_p960",1},	{"props_p448",1},	{"props_p3436",1},			},
			},										
		},											
		 --前台格式											
		reward={											
			dayreward={	 --每天的充值奖励									
				{o={	{a10084=5,index=1},				},beer={	{t1=2,index=3},	{t2=2,index=4},	}},	
			},										
			t1={{p={	p20=10,	p2=1,	}},{p={	p275=10,	p276=20,	}},{p={	p3436=10,		}}},	
			t2={{p={	p19=50,		}},{p={	p960=10,		}},{p={	p4604=1,		}}},	
													
			final={o={	{a10084=30,index=1},	{a10075=30,index=2},			}},					
			fbreward={o={	{a10084=2,index=1},	},beer={	{t1=1,index=2},	{t2=1,index=3},	}},					
		},											
	},												
												
												
	
}													
return beerfestival													
