 --跨服战配置
serverWarPersonalCfg={
 ---------------------------- 跨服战----------------------------
 --跨服战参赛人数
sevbattlePlayer=16,

 --[战斗相关]
 -- starttime 第一轮的开始时间
 -- durationtime  持续时间+领奖时间
 -- 军事演习取多少排名的前几名
starttime={8,0},
durationtime=8,
militaryrank=50,
 --[轮次相关]
 -- 每天的开战时间(每日两轮,第一论胜败组均有,第二轮仅败组)
startBattleTs={{19,30},{20,30}},
 --无论开启几组服务器的跨服战,序号最小的服参赛的1到X名序号为1到X,序号第二小的服的1-X名序号为(X+1)到2X,依次类推。
 --匹配列表（8组）初始化小组赛
matchList = {{1,16},{6,11},{12,5},{15,2},{3,14},{8,9},{10,7},{13,4}},
produceRank={{13,16},{9,12},{7,8},{5,6},{4,4},{3,3},{1,2},}, --轮次对应出现的排名
 --[押注] [押注分两个档次](最后3轮筹码加大)
betStyle4Round={1,1,1,1,1,2,2,2,},
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

--战斗奖励
--区分胜者组和败者组没有连胜奖励
winTeam_win=600,
winTeam_lose=240,
loseTeam_win=300,
loseTeam_lose=120,

--最终排名奖励积分
rankReward={
{range={1,1},point=3000,title="serverwar_first_title",desc="serverwar_first_desc",icon="serverWarTopMedal1.png",lastTime={7,7}},
{range={2,2},point=2700,title="serverwar_second_title",desc="serverwar_second_desc",icon="serverWarTopMedal2.png",lastTime={7,7}},
{range={3,3},point=2400,title="serverwar_third_title",desc="serverwar_third_desc",icon="serverWarTopMedal3.png",lastTime={7,7}},
{range={4,4},point=2100,},
{range={5,6},point=1800,},
{range={7,8},point=1500,},
{range={9,12},point=1200,},
{range={13,16},point=1000,},
},
--前三名对应服务器的全服奖励
severReward={
{reward={u={{r1=20000000},{r2=20000000},{r3=20000000},}},serverReward={userinfo_r1=20000000,userinfo_r2=20000000,userinfo_r3=20000000,},},
{reward={u={{r1=10000000},{r2=10000000},{r3=10000000},}},serverReward={userinfo_r1=10000000,userinfo_r2=10000000,userinfo_r3=10000000,},},
{reward={u={{r1=5000000},{r2=5000000},{r3=5000000},}},serverReward={userinfo_r1=5000000,userinfo_r2=5000000,userinfo_r3=5000000,},},
},
--部队设置限制没有金币设置
settingTroopsLimit=60, --每次设置需要间隔1分钟

--默认补充配置
adminTroops={"a10001",1},--默认补充轻型坦克

--[跨服战商店]
--pShop是普通商店
--aShop是参赛商店
--所有物品在本次跨服战之中均展示给玩家
pShopItems=									
{									
i1={id="i1",buynum=3,price=150,reward={e={{p11=1}}},serverReward={accessory_p11=1}},
i2={id="i2",buynum=2,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
i3={id="i3",buynum=2,price=400,reward={p={{p568=1}}},serverReward={props_p568=1}},
i4={id="i4",buynum=2,price=220,reward={p={{p183=1}}},serverReward={props_p183=1}},
i5={id="i5",buynum=2,price=220,reward={p={{p186=1}}},serverReward={props_p186=1}},
i6={id="i6",buynum=2,price=220,reward={p={{p195=1}}},serverReward={props_p195=1}},
i7={id="i7",buynum=2,price=220,reward={p={{p198=1}}},serverReward={props_p198=1}},
i8={id="i8",buynum=2,price=220,reward={p={{p207=1}}},serverReward={props_p207=1}},
i9={id="i9",buynum=2,price=220,reward={p={{p210=1}}},serverReward={props_p210=1}},
i10={id="i10",buynum=2,price=220,reward={p={{p219=1}}},serverReward={props_p219=1}},
i11={id="i11",buynum=2,price=220,reward={p={{p222=1}}},serverReward={props_p222=1}},
i12={id="i12",buynum=3,price=200,reward={p={{p269=1}}},serverReward={props_p269=1}},
i13={id="i13",buynum=3,price=40,reward={p={{p268=1}}},serverReward={props_p268=1}},
i14={id="i14",buynum=5,price=10,reward={p={{p20=1}}},serverReward={props_p20=1}},
i15={id="i15",buynum=1,price=20,reward={p={{p393=10}}},serverReward={props_p393=10}},
i16={id="i16",buynum=1,price=20,reward={p={{p394=10}}},serverReward={props_p394=10}},
i17={id="i17",buynum=1,price=20,reward={p={{p395=10}}},serverReward={props_p395=10}},
i18={id="i18",buynum=1,price=20,reward={p={{p396=10}}},serverReward={props_p396=10}},
i19={id="i19",buynum=10,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
i20={id="i20",buynum=10,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
i21={id="i21",buynum=10,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
i22={id="i22",buynum=10,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
i23={id="i23",buynum=4,price=500,reward={p={{p4840=1}}},serverReward={props_p4840=1}},
i24={id="i24",buynum=4,price=500,reward={p={{p4841=1}}},serverReward={props_p4841=1}},		

},
aShopItems=
{
a1={id="a1",buynum=1,price=1500,reward={p={{p804=1}}},serverReward={props_p804=1}},
a2={id="a2",buynum=5,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
a3={id="a3",buynum=10,price=300,reward={p={{p997=1}}},serverReward={props_p997=1}},
a4={id="a4",buynum=3,price=315,reward={p={{p969=1}}},serverReward={props_p969=1}},
a5={id="a5",buynum=3,price=315,reward={p={{p970=1}}},serverReward={props_p970=1}},
a6={id="a6",buynum=3,price=315,reward={p={{p971=1}}},serverReward={props_p971=1}},
a7={id="a7",buynum=3,price=315,reward={p={{p972=1}}},serverReward={props_p972=1}},
a8={id="a8",buynum=5,price=220,reward={p={{p183=1}}},serverReward={props_p183=1}},
a9={id="a9",buynum=5,price=220,reward={p={{p186=1}}},serverReward={props_p186=1}},
a10={id="a10",buynum=5,price=220,reward={p={{p195=1}}},serverReward={props_p195=1}},
a11={id="a11",buynum=5,price=220,reward={p={{p198=1}}},serverReward={props_p198=1}},
a12={id="a12",buynum=5,price=220,reward={p={{p207=1}}},serverReward={props_p207=1}},
a13={id="a13",buynum=5,price=220,reward={p={{p210=1}}},serverReward={props_p210=1}},
a14={id="a14",buynum=5,price=220,reward={p={{p219=1}}},serverReward={props_p219=1}},
a15={id="a15",buynum=5,price=220,reward={p={{p222=1}}},serverReward={props_p222=1}},
a16={id="a16",buynum=1,price=1000,reward={p={{p270=1}}},serverReward={props_p270=1}},
a17={id="a17",buynum=1,price=500,reward={p={{p90=1}}},serverReward={props_p90=1}},
a18={id="a18",buynum=12,price=500,reward={p={{p4840=1}}},serverReward={props_p4840=1}},		
a19={id="a19",buynum=12,price=500,reward={p={{p4841=1}}},serverReward={props_p4841=1}},		
																																			
},									

 --每场战斗持续时间, 用于前台展示
battleTime=300,
 --开战前投注的准备时间
betTime=300,
 --开战前有几天准备时间
preparetime=2,
 --结束战斗后有几天购买时间
shoppingtime=3,
 --自动补充的坦克
troops={
{"a10001",1},
{"a10001",1},
{"a10001",1},
{"a10001",1},
{"a10001",1},
{"a10001",1},
},
 --自动补充的npc
npc={
name='player',
level=60,
fc=1000000,
pic=1,
rank=9,
},
}
