serverWarTeamCfg=
{
	--跨服战每个军团上阵人数
	numberOfBattle=15,
	-- 跨服战参赛军团数
	sevbattleAlliance=8,
	--胜利所需胜利点数10万
	winPointMax=100000,
	--战斗最大战斗时间25分钟
	warTime=1500,
	--积分明细50条
	militaryrank=50,
	-- buff 相关 
	-- maxLv 最大等级
	-- cost 购买需要的金币数
	-- per 每级提供的buff加成
	-- probability 升级成功概率
	buffSkill={
		b1={maxLv=10,cost=18,per=0.03,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffSmeltExpert.png",name="serverwarteam_buffName1",des="serverwarteam_buffDesc1"},
		b2={maxLv=10,cost=18,per=0.03,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffCommander.png",name="serverwarteam_buffName2",des="serverwarteam_buffDesc2"},
		b3={maxLv=5,cost=28,per=0.1,probability={100,95,90,85,80},donate=5,icon="WarBuffNetget.png",name="serverwarteam_buffName3",des="serverwarteam_buffDesc3"},
		b4={maxLv=5,cost=28,per=0.1,probability={100,95,90,85,80},donate=5,icon="WarBuffStatistician.png",name="serverwarteam_buffName4",des="serverwarteam_buffDesc4"},
	},

	--加速的buff
	speedBuff=
	{
		cost={10,20,40,80,}, --花费
		per=0.5, --提供的加成值
		minsec=1, -- 能购买加速的最小秒数
	},
	--[战斗相关] ---------------
	--开战时间
	startBattleTs={{19,0},{19,30},{20,0},{20,30}},
	--对应每天每场战斗的开始时间索引
	startBattleIndex={{1,2,3,4},{1,2},{1}},
	--不能献花的时间, 每个元素表示每一轮, 再下面第一个元素表示开战前献花的截止时间, 第二个元素表示每天最后一场战斗结束后
	flowerLimit={{{18,50},{20,55}},{{18,50},{19,55}},{{18,50},{19,25}}},
	--匹配列表（8组）初始化小组赛
	matchList1={{1,8},{4,5},{2,7},{3,6},},
	matchList2={{1,8},{3,6},{5,4},{7,2},},
	produceRank={{5,8},{3,4},{1,2}},    -- 轮次对应出现的排名

	--[押注] [押注分两个档次](最后3轮筹码加大)
	betStyle4Round={1,1,2,},
	betTs_a={19,25}, -- 下注,时间
	betTs_b={20,25}, --下注,时间
	--押注类型1
	betGem_1={0,20,100,150,}, --追加消耗的金币数量
	winner_1={10,30,100,200,}, --赢后的积分奖励
	failer_1={5,15,50,100,}, --输的积分奖励
	--押注类型2
	betGem_2={0,40,200,300,}, --追加消耗的金币数量
	winner_2={20,60,200,400,}, --赢后的积分奖励
	failer_2={10,30,100,200,}, --输的积分奖励

	--战斗奖励贡献
	winDonate=100,
	loseDonate=30,
	--战后积分奖励
	winPoint=6000,
	losePoint=2000,
	--战后个人加成
	personalWinPoint=200,
	personalLosePoint=100,
	--最终排名奖励积分
	rankReward=
	{
		{range={1,1},point=500},
		{range={2,2},point=300},
		{range={3,4},point=250},
		{range={5,8},point=200},
	},
	--前2名对应服务器的全服奖励
	severReward=
	{
		{reward={u={{r1=20000000},{r2=20000000},{r3=20000000},}},serverReward={userinfo_r1=20000000,userinfo_r2=20000000,userinfo_r3=20000000,},},
		{reward={u={{r1=10000000},{r2=10000000},{r3=10000000},}},serverReward={userinfo_r1=10000000,userinfo_r2=10000000,userinfo_r3=10000000,},},
	},

	--部队设置限制没有金币设置
	settingTroopsLimit=60, --每次设置需要间隔1分钟
	--默认补充配置
	adminTroops={'a10001',1},--默认补充轻型坦克
	--[跨服战商店]
	--pShop是普通商店
	--aShop是参赛商店
	--所有物品在本次跨服战之中均展示给玩家
	pShopItems=
	{
		i1={id="i1",buynum=10,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
		i2={id="i2",buynum=10,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
		i3={id="i3",buynum=10,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
		i4={id="i4",buynum=10,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
		i5={id="i5",buynum=50,price=40,reward={p={{p277=5}}},serverReward={props_p277=5}},
		i6={id="i6",buynum=50,price=40,reward={p={{p276=2}}},serverReward={props_p276=2}},
		i7={id="i7",buynum=50,price=40,reward={p={{p275=1}}},serverReward={props_p275=1}},
		i8={id="i8",buynum=10,price=20,reward={p={{p36=1}}},serverReward={props_p36=1}},
		i9={id="i9",buynum=5,price=20,reward={p={{p20=1}}},serverReward={props_p20=1}},
		i10={id="i10",buynum=3,price=50,reward={p={{p268=1}}},serverReward={props_p268=1}},
		i11={id="i11",buynum=3,price=300,reward={p={{p269=1}}},serverReward={props_p269=1}},
		i12={id="i12",buynum=3,price=800,reward={p={{p230=1}}},serverReward={props_p230=1}},
	},
	aShopItems=
	{
		a1={id="a1",buynum=1,price=1500,reward={p={{p804=1}}},serverReward={props_p804=1}},
		a2={id="a2",buynum=1,price=1000,reward={p={{p90=1}}},serverReward={props_p90=1}},
		a3={id="a3",buynum=1,price=1800,reward={p={{p270=1}}},serverReward={props_p270=1}},
		a4={id="a4",buynum=8,price=330,reward={p={{p354=1}}},serverReward={props_p354=1}},
		a5={id="a5",buynum=8,price=320,reward={p={{p362=1}}},serverReward={props_p362=1}},
		a6={id="a6",buynum=8,price=300,reward={p={{p370=1}}},serverReward={props_p370=1}},
		a7={id="a7",buynum=8,price=310,reward={p={{p378=1}}},serverReward={props_p378=1}},
		a8={id="a8",buynum=5,price=800,reward={p={{p230=1}}},serverReward={props_p230=1}},
	},

	--开战前可以设置部队的截止时间
	setTroopsLimit=600,
	--开战前投注的准备时间
	enterBattleTime=300,
	--开战前有几天预热时间，不能操作
	preparetime=2,
	--开战前准备时间，可以报名，上阵，设置部队，资金
	signuptime=1,
	--结束战斗后有几天购买时间
	shoppingtime=3,
	-- durationtime  持续时间+领奖时间
	durationtime=6,
	--服内赛军团数
	serverAlliance=8,
	--报名,设置上阵成员截止时间，开战的第一天，preparetime+signuptime+1
	applyedtime={12,0},
	--设置部队的截止时间
	settroopstime={18,50},
	--基地耐久值
	baseBlood=300,
	--攻打一次损失
	lossBlood=20,
	--设置上下阵成员时间间隔
	settingBattleMemLimit=60, --每次设置需要间隔1分钟
	--到达捐献次数给的部队总数
	maxBaseFleetNum=15,
	--基地捐献部队数量
	baseDonateNum={1,2,3,4,5,},
	--基地捐献次数
	baseDonateTime={5,20,50,100,200,},
	--基地部队信息
	baseFleetInfo={
		[60]={"a10005","a10015","a10025","a10035",},
		[70]={"a10006","a10016","a10026","a10036",},
		[80]={"a10007","a10017","a10027","a10037",},
	},
	baseFleetAttribute={
		[60]={skill={s101=60,s102=60,s103=60,s104=60,},attributeUp={attack=3,life=3,accurate=1,avoid=1,critical=1,decritical=1,},},
		[70]={skill={s101=70,s102=70,s103=70,s104=70,},attributeUp={attack=4,life=4,accurate=1,avoid=1,critical=1,decritical=1,},},
		[80]={skill={s101=80,s102=80,s103=80,s104=80,},attributeUp={attack=5,life=5,accurate=1,avoid=1,critical=1,decritical=1,},},
	},
	--部队数量
	--Num =int (unLockLevel * unLockLevel / 4 ) 
	--基地捐献资源,q 前台，h后台
	baseDonateRes={q={u={{r4=2000000,index=1},}},h={r4=2000000}},
	--基地捐献金币
	baseDonateGem=15,
	--小路出现的时间, 开战之后n秒钟之后才出现
	countryRoadTime=300,
	--在战斗中刷新整体数据的时间间隔
	battleRefreshTime=60,
	--阵亡者复活时间和金币消耗
	reviveTime=40,
	reviveCost=100,
}