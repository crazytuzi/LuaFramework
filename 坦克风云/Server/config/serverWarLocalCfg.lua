local serverWarLocalCfg=
{
limitLevel=30, --玩家30以上才能参战
minRegistrationFee=1000, -- 报名 最少花费
 --跨服战参赛军团数
sevbattleAlliance=8,
-- startWarTime={20,0},
startWarTime={ a={20,0},b={21,0} },
maxBattleTime=3600, --最长战斗时间, 单位: 秒
cdTime=20, -- 战斗冷却时间，每X秒发生1次战斗
 --胜利所需胜利点数10万
winPointMax=100000,
 --开战前可以设置部队的截止时间
setTroopsLimit=300,

    --报名时间, 周几0~6 周日是0
signuptime=2,
    --战斗时间,可以设置部队，军饷，购买buff
battleTime=2,
 --结束战斗后有几天购买时间
shoppingtime=4,
 --整场战斗总时间
durationtime=8,

 --阵亡者复活时间和金币消耗
reviveTime=30,
reviveCost=10, --(每1秒花费1金币+固定值)
    --战斗队列人数上限
battleQueue=5,
    --当玩家一轮战斗多次时，那么该玩家战斗力削减
reducePercentage=0.15,

    --报名前几名可参加战斗
signupBattleNum=8,
    --团长和副团长标记建筑的cd时间
flagBuildCD=30,

 --坦克消耗兑换的比例
tankeTransRate=25, --25比1的消耗比例,足的部分向上取整
 --战报最大数量
reportMaxNum=50,

 --战斗奖励贡献
winDonate=100,
loseDonate=50,
 --战后积分奖励
winPoint=10000,
losePoint=4000,
 --战后个人加成
personalWinPoint=100,
personalLosePoint=50,
 -- 每天场次间隔时间
spacingtime=1,

    
 --野怪配置
guard={tank={{"a10004",676},{"a10004",676},{"a10004",676},{"a10034",676},{"a10024",676},{"a10014",676},},skill={s101=50,s102=50,s103=50,s104=50,s105=50,s106=50,s107=50,s108=50,s109=50,s110=50,s111=50,s112=50,},attributeUp={attack=1,life=1,accurate=1,avoid=1,critical=1,decritical=1,},},

 -------------------------------------新增字段-------------------------------------

 --最多出战部队
 maxTroop=3,
 --鹰巢BOSS配置
boss={tank={{"a10007",1200},{"a10007",1200},{"a10007",1200},{"a10037",1200},{"a10027",1200},{"a10017",1200},},skill={s101=80,s102=80,s103=80,s104=80,s105=80,s106=80,s107=80,s108=80,s109=80,s110=80,s111=80,s112=80,},attributeUp={attack=40,life=1200,accurate=2,avoid=2,critical=2,decritical=2,},},
 --分组配置
    matchList={
 --2个服配置
[2]={
{{1,1},{2,4},{1,3},{2,2},},
{{2,1},{1,4},{2,3},{1,2},},
},
 -- 4个服配置
[4]={
{{1,1},{3,2},{2,2},{4,1},},
{{2,1},{4,2},{1,2},{3,1},},
},
 -- 8个服配置
[8]={
{{1,1},{4,1},{5,1},{8,1},},
{{2,1},{3,1},{6,1},{7,1},},
},
},




 --死亡BUFF
deathBuff={times=10,buff={[100]=0.2,[109]=0.07},},
 --奇袭任务(point军团占领分，buff完成获得的buff,time持续时间，CD任务发布间隔，last任务持续时间）
quest={point=1000,buff={[100]=0.2,[109]=0.1},time=120,CD=360,last=240},
 --鹰巢首杀BUFF(point军团占领分，buff完成获得的buff,time持续时间，devote个人获得贡献）
nest={point=5000,buff={[100]=0.5,[109]=0.2},time=120,devote=1000},

 --军团排名奖
AllianceReward={
{range={1,1},point=1000,icon="serverWarTopMedal1.png"},
{range={2,2},point=700,icon="serverWarTopMedal2.png"},
{range={3,4},point=500,icon="serverWarTopMedal3.png"},
{range={5,6},point=300,},
{range={7,8},point=200,},
},

ShopItems=
{
i1={id="i1",buynum=1,price=3000,reward={p={{p804=1}}},serverReward={props_p804=1}},
i2={id="i2",buynum=5,price=800,reward={p={{p358=1}}},serverReward={props_p358=1}},
i3={id="i3",buynum=5,price=800,reward={p={{p366=1}}},serverReward={props_p366=1}},
i4={id="i4",buynum=5,price=800,reward={p={{p374=1}}},serverReward={props_p374=1}},
i5={id="i5",buynum=5,price=800,reward={p={{p382=1}}},serverReward={props_p382=1}},
i6={id="i6",buynum=5,price=1000,reward={p={{p230=1}}},serverReward={props_p230=1}},
i7={id="i7",buynum=2,price=1500,reward={p={{p90=1}}},serverReward={props_p90=1}},
i8={id="i8",buynum=2,price=3000,reward={p={{p270=1}}},serverReward={props_p270=1}},
i9={id="i9",buynum=20,price=5,reward={p={{p20=1}}},serverReward={props_p20=1}},
i10={id="i10",buynum=10,price=200,reward={p={{p277=50}}},serverReward={props_p277=50}},
i11={id="i11",buynum=10,price=200,reward={p={{p276=10}}},serverReward={props_p276=10}},
i12={id="i12",buynum=10,price=200,reward={p={{p275=5}}},serverReward={props_p275=5}},
},
	ShopItems2=
	{
	i101={id="i101",buynum=3,price=1480,reward={p={{p5067=1}}},serverReward={props_p5067=1}},
	i102={id="i102",buynum=3,price=1480,reward={p={{p5075=1}}},serverReward={props_p5075=1}},
	i103={id="i103",buynum=3,price=1480,reward={p={{p5083=1}}},serverReward={props_p5083=1}},
	i104={id="i104",buynum=3,price=1480,reward={p={{p5091=1}}},serverReward={props_p5091=1}},
	i105={id="i105",buynum=1,price=3000,reward={p={{p804=1}}},serverReward={props_p804=1}},
	i106={id="i106",buynum=5,price=800,reward={p={{p358=1}}},serverReward={props_p358=1}},
	i107={id="i107",buynum=5,price=800,reward={p={{p366=1}}},serverReward={props_p366=1}},
	i108={id="i108",buynum=5,price=800,reward={p={{p374=1}}},serverReward={props_p374=1}},
	i109={id="i109",buynum=5,price=800,reward={p={{p382=1}}},serverReward={props_p382=1}},
	i110={id="i110",buynum=5,price=1000,reward={p={{p230=1}}},serverReward={props_p230=1}},
	i111={id="i111",buynum=2,price=1500,reward={p={{p90=1}}},serverReward={props_p90=1}},
	i112={id="i112",buynum=2,price=3000,reward={p={{p270=1}}},serverReward={props_p270=1}},
	i113={id="i113",buynum=20,price=5,reward={p={{p20=1}}},serverReward={props_p20=1}},
	i114={id="i114",buynum=10,price=200,reward={p={{p277=50}}},serverReward={props_p277=50}},
	i115={id="i115",buynum=10,price=200,reward={p={{p276=10}}},serverReward={props_p276=10}},
	i116={id="i116",buynum=10,price=200,reward={p={{p275=5}}},serverReward={props_p275=5}},
	},						


    -- buff 相关 
    -- maxLv 最大等级
    -- cost 购买需要的金币数
    -- per 每级提供的buff加成
    -- probability 升级成功概率
buffSkill={
b1={maxLv=10,cost=38,per=0.05,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffSmeltExpert.png",},
b2={maxLv=10,cost=38,per=5,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffCommander.png",},
b3={maxLv=10,cost=38,per=0.03,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffNetget.png",},
b4={maxLv=5,cost=38,per=0.1,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffStatistician.png",},
},

 --积分明细最多多少条
militaryrank=50,
 --小路出现的时间, 开战之后n秒钟之后才出现
countryRoadTime=300,
}

return serverWarLocalCfg