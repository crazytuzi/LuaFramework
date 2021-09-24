--跨服战配置
local sevbattleCfg ={
    ---------------------------- 跨服战----------------------------
    --跨服战参赛人数
    sevbattlePlayer=16,

    --[战斗相关]
    -- starttime 第一轮的开始时间
    -- durationtime  持续时间+领奖时间
    -- 军事演习取多少排名的前几名
    starttime={8,0},
    durationtime=8,
    militaryrank=100,
    tankeTransRate=25, --25比1的消耗比例,足的部分向上取整									
    --[轮次相关]
    -- 每天的开战时间(每日两轮,第一论胜败组均有,第二轮仅败组)
    startBattleTs={{19,30},{20,30}},
    --无论开启几组服务器的跨服战,序号最小的服参赛的1到X名序号为1到X,序号第二小的服的1-X名序号为(X+1)到2X,依次类推。
    --匹配列表（8组）初始化小组赛
    matchList = {{1,16},{6,11},{12,5},{15,2},{3,14},{8,9},{10,7},{13,4}},
    produceRank={{13,16},{9,12},{7,8},{5,6},{4,4},{3,3},{1,2},},    -- 轮次对应出现的排名

    --[押注] [押注分两个档次](最后3轮筹码加大)
    betStyle4Round={1,1,1,1,1,2,2,2,},
    betTs_a={19,25}, -- 下注,变阵截止时间
    betTs_b={20,25}, --下注,变阵截止时间
	--押注类型1									
	betGem_1={	0,	40,	80,	160,	},	 --追加消耗的钻石数量			
	winner_1={	10,	20,	30,	40,	},	 --赢后的积分奖励			
	failer_1={	5,	10,	15,	20,	},	 --输的积分奖励			
	--押注类型2									
	betGem_2={	0,	80,	160,	320,	},	 --追加消耗的钻石数量			
	winner_2={	10,	30,	50,	70,	},	 --赢后的积分奖励			
	failer_2={	5,	15,	25,	35,	},	 --输的积分奖励			

    --战斗奖励
    --区分胜者组和败者组没有连胜奖励
winTeam_win=600,									
winTeam_lose=200,									
loseTeam_win=300,									
loseTeam_lose=100,									

    --最终排名奖励积分
    rankReward={
        {range={1,1},point=3000,title="serverwar_first_title",desc="serverwar_first_desc",icon="serverWarTopMedal1.png",lastTime={7,7}},
        {range={2,2},point=2700,title="serverwar_second_title",desc="serverwar_second_desc",icon="serverWarTopMedal2.png",lastTime={7,7}},
        {range={3,3},point=2400,title="serverwar_third_title",desc="serverwar_third_desc",icon="serverWarTopMedal3.png",lastTime={7,7}},
{	range={4,4},	point=2000,					},		
{	range={5,6},	point=1600,					},		
{	range={7,8},	point=1200,					},		
{	range={9,12},	point=800,					},		
{	range={13,16},	point=500,					},		
    },
    --前三名对应服务器的全服奖励
    severReward={
        {reward={u={{r1=20000000},{r2=20000000},{r3=20000000},}},serverReward={userinfo_r1=20000000,userinfo_r2=20000000,userinfo_r3=20000000,},},
        {reward={u={{r1=10000000},{r2=10000000},{r3=10000000},}},serverReward={userinfo_r1=10000000,userinfo_r2=10000000,userinfo_r3=10000000,},},
        {reward={u={{r1=5000000},{r2=5000000},{r3=5000000},}},serverReward={userinfo_r1=5000000,userinfo_r2=5000000,userinfo_r3=5000000,},},
    },
    --部队设置限制没有金币设置
    settingTroopsLimit=120,	 --每次设置需要间隔2分钟								

    --默认补充配置
    adminTroops={'a10001',1},--默认补充轻型坦克

    --[跨服战商店]
    --pShop是普通商店
    --aShop是参赛商店
    --所有物品在本次跨服战之中均展示给玩家
    pShopItems=
    {
	i1	={	id="i1",	buynum=3,	price=200,	reward={e={{p11=1}}},	serverReward={accessory_p11=1}	},		
	i2	={	id="i2",	buynum=2,	price=600,	reward={p={{p230=1}}},	serverReward={props_p230=1}	},		
	i3	={	id="i3",	buynum=2,	price=400,	reward={p={{p568=1}}},	serverReward={props_p568=1}	},		
	i4	={	id="i4",	buynum=2,	price=275,	reward={p={{p183=1}}},	serverReward={props_p183=1}	},		
	i5	={	id="i5",	buynum=2,	price=275,	reward={p={{p186=1}}},	serverReward={props_p186=1}	},		
	i6	={	id="i6",	buynum=2,	price=250,	reward={p={{p195=1}}},	serverReward={props_p195=1}	},		
	i7	={	id="i7",	buynum=2,	price=250,	reward={p={{p198=1}}},	serverReward={props_p198=1}	},		
	i8	={	id="i8",	buynum=2,	price=275,	reward={p={{p207=1}}},	serverReward={props_p207=1}	},		
	i9	={	id="i9",	buynum=2,	price=275,	reward={p={{p210=1}}},	serverReward={props_p210=1}	},		
	i10	={	id="i10",	buynum=2,	price=300,	reward={p={{p219=1}}},	serverReward={props_p219=1}	},		
	i11	={	id="i11",	buynum=2,	price=300,	reward={p={{p222=1}}},	serverReward={props_p222=1}	},		
	i12	={	id="i12",	buynum=3,	price=500,	reward={p={{p269=1}}},	serverReward={props_p269=1}	},		
	i13	={	id="i13",	buynum=3,	price=100,	reward={p={{p268=1}}},	serverReward={props_p268=1}	},		
	i14	={	id="i14",	buynum=5,	price=10,	reward={p={{p20=1}}},	serverReward={props_p20=1}	},		
	i15	={	id="i15",	buynum=1,	price=20,	reward={p={{p393=10}}},	serverReward={props_p393=10}	},		
	i16	={	id="i16",	buynum=1,	price=20,	reward={p={{p394=10}}},	serverReward={props_p394=10}	},		
	i17	={	id="i17",	buynum=1,	price=20,	reward={p={{p395=10}}},	serverReward={props_p395=10}	},		
	i18	={	id="i18",	buynum=1,	price=20,	reward={p={{p396=10}}},	serverReward={props_p396=10}	},		
	i19	={	id="i19",	buynum=10,	price=5,	reward={p={{p393=1}}},	serverReward={props_p393=1}	},		
	i20	={	id="i20",	buynum=10,	price=5,	reward={p={{p394=1}}},	serverReward={props_p394=1}	},		
	i21	={	id="i21",	buynum=10,	price=5,	reward={p={{p395=1}}},	serverReward={props_p395=1}	},		
	i22	={	id="i22",	buynum=10,	price=5,	reward={p={{p396=1}}},	serverReward={props_p396=1}	},		
    },
	pShopItems2=
	{
	i101={id="i101",buynum=2,price=400,reward={p={{p5062=1}}},serverReward={props_p5062=1}},
	i102={id="i102",buynum=2,price=400,reward={p={{p5063=1}}},serverReward={props_p5063=1}},
	i103={id="i103",buynum=2,price=365,reward={p={{p5070=1}}},serverReward={props_p5070=1}},
	i104={id="i104",buynum=2,price=365,reward={p={{p5071=1}}},serverReward={props_p5071=1}},
	i105={id="i105",buynum=2,price=400,reward={p={{p5078=1}}},serverReward={props_p5078=1}},
	i106={id="i106",buynum=2,price=400,reward={p={{p5079=1}}},serverReward={props_p5079=1}},
	i107={id="i107",buynum=2,price=440,reward={p={{p5086=1}}},serverReward={props_p5086=1}},
	i108={id="i108",buynum=2,price=440,reward={p={{p5087=1}}},serverReward={props_p5087=1}},
	i109={id="i109",buynum=3,price=200,reward={e={{p11=1}}},serverReward={accessory_p11=1}},
	i110={id="i110",buynum=2,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
	i111={id="i111",buynum=2,price=400,reward={p={{p568=1}}},serverReward={props_p568=1}},
	i112={id="i112",buynum=2,price=275,reward={p={{p183=1}}},serverReward={props_p183=1}},
	i113={id="i113",buynum=2,price=275,reward={p={{p186=1}}},serverReward={props_p186=1}},
	i114={id="i114",buynum=2,price=250,reward={p={{p195=1}}},serverReward={props_p195=1}},
	i115={id="i115",buynum=2,price=250,reward={p={{p198=1}}},serverReward={props_p198=1}},
	i116={id="i116",buynum=2,price=275,reward={p={{p207=1}}},serverReward={props_p207=1}},
	i117={id="i117",buynum=2,price=275,reward={p={{p210=1}}},serverReward={props_p210=1}},
	i118={id="i118",buynum=2,price=300,reward={p={{p219=1}}},serverReward={props_p219=1}},
	i119={id="i119",buynum=2,price=300,reward={p={{p222=1}}},serverReward={props_p222=1}},
	i120={id="i120",buynum=3,price=500,reward={p={{p269=1}}},serverReward={props_p269=1}},
	i121={id="i121",buynum=3,price=100,reward={p={{p268=1}}},serverReward={props_p268=1}},
	i122={id="i122",buynum=5,price=10,reward={p={{p20=1}}},serverReward={props_p20=1}},
	i123={id="i123",buynum=1,price=20,reward={p={{p393=10}}},serverReward={props_p393=10}},
	i124={id="i124",buynum=1,price=20,reward={p={{p394=10}}},serverReward={props_p394=10}},
	i125={id="i125",buynum=1,price=20,reward={p={{p395=10}}},serverReward={props_p395=10}},
	i126={id="i126",buynum=1,price=20,reward={p={{p396=10}}},serverReward={props_p396=10}},
	i127={id="i127",buynum=10,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
	i128={id="i128",buynum=10,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
	i129={id="i129",buynum=10,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
	i130={id="i130",buynum=10,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
	},
    aShopItems=
    {
	a1	={	id="a1",	buynum=1,	price=2000,	reward={p={{p804=1}}},	serverReward={props_p804=1}	},		
	a2	={	id="a2",	buynum=5,	price=600,	reward={p={{p230=1}}},	serverReward={props_p230=1}	},		
	a3	={	id="a3",	buynum=3,	price=275,	reward={p={{p183=1}}},	serverReward={props_p183=1}	},		
	a4	={	id="a4",	buynum=3,	price=275,	reward={p={{p186=1}}},	serverReward={props_p186=1}	},		
	a5	={	id="a5",	buynum=3,	price=250,	reward={p={{p195=1}}},	serverReward={props_p195=1}	},		
	a6	={	id="a6",	buynum=3,	price=250,	reward={p={{p198=1}}},	serverReward={props_p198=1}	},		
	a7	={	id="a7",	buynum=3,	price=275,	reward={p={{p207=1}}},	serverReward={props_p207=1}	},		
	a8	={	id="a8",	buynum=3,	price=275,	reward={p={{p210=1}}},	serverReward={props_p210=1}	},		
	a9	={	id="a9",	buynum=3,	price=300,	reward={p={{p219=1}}},	serverReward={props_p219=1}	},		
	a10	={	id="a10",	buynum=3,	price=300,	reward={p={{p222=1}}},	serverReward={props_p222=1}	},		
	a11	={	id="a11",	buynum=1,	price=1500,	reward={p={{p270=1}}},	serverReward={props_p270=1}	},		
	a12	={	id="a12",	buynum=1,	price=800,	reward={p={{p90=1}}},	serverReward={props_p90=1}	},		
    },
	aShopItems2=
	{
	a101={id="a101",buynum=2,price=400,reward={p={{p5062=1}}},serverReward={props_p5062=1}},
	a102={id="a102",buynum=2,price=400,reward={p={{p5063=1}}},serverReward={props_p5063=1}},
	a103={id="a103",buynum=2,price=365,reward={p={{p5070=1}}},serverReward={props_p5070=1}},
	a104={id="a104",buynum=2,price=365,reward={p={{p5071=1}}},serverReward={props_p5071=1}},
	a105={id="a105",buynum=2,price=400,reward={p={{p5078=1}}},serverReward={props_p5078=1}},
	a106={id="a106",buynum=2,price=400,reward={p={{p5079=1}}},serverReward={props_p5079=1}},
	a107={id="a107",buynum=2,price=440,reward={p={{p5086=1}}},serverReward={props_p5086=1}},
	a108={id="a108",buynum=2,price=440,reward={p={{p5087=1}}},serverReward={props_p5087=1}},
	a109={id="a109",buynum=1,price=2000,reward={p={{p804=1}}},serverReward={props_p804=1}},
	a110={id="a110",buynum=5,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
	a111={id="a111",buynum=3,price=275,reward={p={{p183=1}}},serverReward={props_p183=1}},
	a112={id="a112",buynum=3,price=275,reward={p={{p186=1}}},serverReward={props_p186=1}},
	a113={id="a113",buynum=3,price=250,reward={p={{p195=1}}},serverReward={props_p195=1}},
	a114={id="a114",buynum=3,price=250,reward={p={{p198=1}}},serverReward={props_p198=1}},
	a115={id="a115",buynum=3,price=275,reward={p={{p207=1}}},serverReward={props_p207=1}},
	a116={id="a116",buynum=3,price=275,reward={p={{p210=1}}},serverReward={props_p210=1}},
	a117={id="a117",buynum=3,price=300,reward={p={{p219=1}}},serverReward={props_p219=1}},
	a118={id="a118",buynum=3,price=300,reward={p={{p222=1}}},serverReward={props_p222=1}},
	a119={id="a119",buynum=1,price=1500,reward={p={{p270=1}}},serverReward={props_p270=1}},
	a120={id="a120",buynum=1,price=800,reward={p={{p90=1}}},serverReward={props_p90=1}},
	},

    --每场战斗持续时间, 用于前台展示
    battleTime=300,
    --开战前投注的准备时间
    betTime=300,
    --开战前有几天准备时间
    preparetime=2,
    --结束战斗后有几天购买时间
    shoppingtime=3,
    -- 自动补充的坦克
    troops={
        {"a10001",1},
        {"a10001",1},
        {"a10001",1},
        {"a10001",1},
        {"a10001",1},
        {"a10001",1},

    },
    -- 自动补充的npc
    npc={
        name='player',
        level=60,
        fc=1000000,
        pic=1,
        rank=9,
    },
	
	buildingOpenLevel = 30,
}
return  sevbattleCfg