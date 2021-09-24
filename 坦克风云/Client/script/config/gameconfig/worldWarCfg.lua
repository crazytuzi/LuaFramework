--世界争霸配置
--NB组的配置是xx1, SB组的配置是xx2
worldWarCfg=
{
	------------------比赛开始时间和押注时间相关---------------------------
	--开战之后有几天的报名时间
	signuptime=2,
	--积分赛持续的天数
	pmatchdays=3,
	--积分赛每天的开战时间
	pmatchstarttime1={15,0}, -- NB组  开始时间
	pmatchstarttime2={15,0}, -- SB组  开始时间
	--积分赛每天的结束时间
	pmatchendtime1={21,0},   --NB组 结束时间
	pmatchendtime2={21,0},   --SB组 结束时间
	--积分赛两轮比赛之间的间隔
	breaktime=900, -- 900秒 15分钟
	--每场战斗持续时间, 用于前台展示
	battleTime=300,
	--淘汰赛 第一场的时间
	tmatch1starttime1={18,0},
	tmatch1starttime2={18,0},
	--淘汰赛 第二场的时间
	tmatch2starttime1={21,0},
	tmatch2starttime2={21,0},
	
	--开战前投注的准备时间
	betTime=300,
	
	--开战前有几天准备时间
	preparetime=3,
	
	--结束战斗后有几天购买时间
	shoppingtime=3,
	
	
	--参加淘汰赛的选手数目
	tmatchplayer=64,
	
	--淘汰赛几天时间
	battletime=3,
	
	--淘汰赛的分组数目
	tmatchgroup=4,
	
	--报名需要达到的军衔等级
	signRank=10,
	
	--NB组别的建议战斗力
	fightingSuggest1 = 10000000,
	fightingSuggest2 = 500000,
	
	
	--无论开启几组服务器的跨服战,序号最小的服参赛的1到X名序号为1到X,序号第二小的服的1-X名序号为(X+1)到2X,依次类推。
	--匹配列表（8组）初始化小组赛
	matchList={
	{{1,64},{32,33},{16,49},{17,48},{8,57},{25,40},{9,56},{24,41},}, --A组
	{{2,63},{31,34},{15,50},{18,47},{7,58},{26,39},{10,55},{23,42},}, --B组
	{{3,62},{30,35},{14,51},{19,46},{6,59},{27,38},{11,54},{22,43},}, --C组
	{{4,61},{29,36},{13,52},{20,45},{5,60},{28,37},{12,53},{21,44},}, --D组
	},
	
	produceRank={{33,64},{17,32},{9,16},{5,8},{},{3,4},{1,2}}, --轮次对应出现的排名
	
	-----------------------押注规则所需金额----------------------
	
	--[押注] [押注分两个档次](最后2轮筹码加大)
	betStyle4Round1={2,2,2,2,3,3,}, --NB组的押注类型
	betStyle4Round2={1,1,1,1,2,2,}, --SB组的押注类型
	betTs_a={19,25}, -- 下注,变阵截止时间
	betTs_b={20,25}, --下注,变阵截止时间
	--押注类型1
	betGem_1={0,20,100,150,}, --追加消耗的金币数量
	winner_1={10,30,120,200,}, --赢后的积分奖励
	failer_1={5,15,60,100,}, --输的积分奖励
	--押注类型2
	betGem_2={0,40,200,300,}, --追加消耗的金币数量
	winner_2={20,60,240,400,}, --赢后的积分奖励
	failer_2={10,30,120,200,}, --输的积分奖励
	--押注类型3
	betGem_3={0,80,400,600,}, --追加消耗的金币数量
	winner_3={40,120,480,800,}, --赢后的积分奖励
	failer_3={20,60,240,400,}, --输的积分奖励
	
	--------------------积分赛规则-------------------------------------------
	--积分赛 排行分初始值
	tmatchRankBasePt = 1000,
	tmatchRankPt={[3]=10,[2]=6,[1]=1,[0]=-5}, --大赢3：0 分数 ，小赢2：1 分数，小输1：2 分数，大输0：3 分数
	conWinPoint=3, --连胜额外积分
	conWinTime=3, --至少连胜次数
	tmatchPoint1={[3]=30,[2]=20,[1]=6,[0]=2}, --NB组 大赢3：0 代币 ，小赢2：1 代币，小输1：2 代币，大输0：3 代币
	tmatchPoint2={[3]=15,[2]=10,[1]=3,[0]=1}, --SB组 大赢3：0 代币 ，小赢2：1 代币，小输1：2 代币，大输0：3 代币
	--所有人初始化 1000分后，有一个排名
	--每次开打，排名组中的第一人，可随机到2-10名的玩家
	tmatchRandomValue=9,--抽9个
	--单数默认为胜利,给大赢排行分数,给大赢积分
	--最后取64人的时候,如果排行分数一致,以战斗力的多少为准,战斗力相同的时候 uid为准
	
	
	
	
	
	--三种策略的属性加成
	strategyAtt={
	{{[103]=15,[105]=15},2},--对面为2时，则克制，获得属性双倍
	{{[100]=15,[104]=15},3},--对面为3时，则克制，获得属性双倍
	{{[102]=15,[108]=15},1},--对面为1时，则克制，获得属性双倍
	},
	
	--6种地形全出现 且均分概率 无需配置
	
	--商店积分
	--排名奖励积分NB组
	rankReward1={
	{range={1,1},point=2288},
	{range={2,2},point=1800},
	{range={3,3},point=1500},
	{range={4,4},point=1200},
	{range={5,8},point=900},
	{range={9,16},point=750},
	{range={17,32},point=600},
	{range={33,64},point=500},
	},
	
	--排名奖励积分SB组
	rankReward2={
	{range={1,1},point=1000},
	{range={2,2},point=750},
	{range={3,3},point=650},
	{range={4,4},point=550},
	{range={5,8},point=450},
	{range={9,16},point=350},
	{range={17,32},point=250},
	{range={33,64},point=150},
	},
	
	
	
	
	------------------------部队设置规则----------------------------------
	
	--开战前N分钟不允许配置部队
	setTroopsLimit=300,
	
	--部队设置限制没有金币设置
	settingTroopsLimit=60, --每次设置需要间隔1分钟
	
	--坦克消耗兑换的比例
	tankeTransRate = 100, --100比1的消耗比例， 不足的部分向上取整
	
	--默认补充配置
	adminTroops={"a10001",1},--默认补充轻型坦克
	
	--[跨服战商店]
	--pShop是普通商店
	--aShop是参赛商店
	--所有物品在本次跨服战之中均展示给玩家
pShopItems=																		
{																		
i1={id="i1",buynum=20,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
i2={id="i2",buynum=20,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
i3={id="i3",buynum=20,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
i4={id="i4",buynum=20,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
i5={id="i5",buynum=1,price=30,reward={p={{p393=10}}},serverReward={props_p393=10}},
i6={id="i6",buynum=1,price=30,reward={p={{p394=10}}},serverReward={props_p394=10}},
i7={id="i7",buynum=1,price=50,reward={p={{p395=10}}},serverReward={props_p395=10}},
i8={id="i8",buynum=1,price=50,reward={p={{p396=10}}},serverReward={props_p396=10}},
i9={id="i9",buynum=5,price=5,reward={p={{p20=1}}},serverReward={props_p20=1}},
i10={id="i10",buynum=3,price=40,reward={p={{p268=1}}},serverReward={props_p268=1}},
i11={id="i11",buynum=3,price=200,reward={p={{p269=1}}},serverReward={props_p269=1}},
i12={id="i12",buynum=50,price=30,reward={p={{p672=1}}},serverReward={props_p672=1}},
i13={id="i13",buynum=3,price=1000,reward={e={{f0=1}}},serverReward={accessory_f0=1}},
i14={id="i14",buynum=2,price=290,reward={p={{p189=1}}},serverReward={props_p189=1}},
i15={id="i15",buynum=2,price=290,reward={p={{p192=1}}},serverReward={props_p192=1}},
i16={id="i16",buynum=2,price=290,reward={p={{p201=1}}},serverReward={props_p201=1}},
i17={id="i17",buynum=2,price=290,reward={p={{p204=1}}},serverReward={props_p204=1}},
i18={id="i18",buynum=2,price=290,reward={p={{p213=1}}},serverReward={props_p213=1}},
i19={id="i19",buynum=2,price=290,reward={p={{p216=1}}},serverReward={props_p216=1}},
i20={id="i20",buynum=2,price=290,reward={p={{p225=1}}},serverReward={props_p225=1}},
i21={id="i21",buynum=2,price=290,reward={p={{p228=1}}},serverReward={props_p228=1}},
i22={id="i22",buynum=4,price=500,reward={p={{p4840=1}}},serverReward={props_p4840=1}},
i23={id="i23",buynum=4,price=500,reward={p={{p4841=1}}},serverReward={props_p4841=1}},											
},
aShopItems=
{
a1={id="a1",buynum=1,price=2600,reward={e={{p7=1}}},serverReward={accessory_p7=1}},
a2={id="a2",buynum=1,price=1300,reward={p={{p90=1}}},serverReward={props_p90=1}},
a3={id="a3",buynum=1,price=2200,reward={p={{p270=1}}},serverReward={props_p270=1}},
a4={id="a4",buynum=5,price=290,reward={p={{p189=1}}},serverReward={props_p189=1}},
a5={id="a5",buynum=5,price=290,reward={p={{p192=1}}},serverReward={props_p192=1}},
a6={id="a6",buynum=5,price=290,reward={p={{p201=1}}},serverReward={props_p201=1}},
a7={id="a7",buynum=5,price=290,reward={p={{p204=1}}},serverReward={props_p204=1}},
a8={id="a8",buynum=5,price=290,reward={p={{p213=1}}},serverReward={props_p213=1}},
a9={id="a9",buynum=5,price=290,reward={p={{p216=1}}},serverReward={props_p216=1}},
a10={id="a10",buynum=5,price=290,reward={p={{p225=1}}},serverReward={props_p225=1}},
a11={id="a11",buynum=5,price=290,reward={p={{p228=1}}},serverReward={props_p228=1}},
a12={id="a12",buynum=2,price=1000,reward={e={{f0=1}}},serverReward={accessory_f0=1}},
a13={id="a13",buynum=10,price=500,reward={p={{p4840=1}}},serverReward={props_p4840=1}},
a14={id="a14",buynum=10,price=500,reward={p={{p4841=1}}},serverReward={props_p4841=1}},											

},

	
	--自动补充的坦克
	troops={
	{"a10001",1},
	{"a10001",1}, 
	{"a10001",1},
	{"a10001",1},
	{"a10001",1},
	{"a10001",1},
	},
	
	--连胜配置
	winningStreak={[0]=1,[3]=2,[5]=3,[10]=4,[20]=5},
	streakMaxNum=20,
	--积分明细最多多少条
	militaryrank=50,
}