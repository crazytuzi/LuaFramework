--bigRewardNum  幸运奖大奖人数
--smallRewardNum 幸运奖小奖人数
--bigReward 大奖内容 50个金币 后台配置下 配置两份 一个后台用 一个前台用 格式不一样
--smallReward 小奖内容 三个幸运币 后台配置下 配置两份 一个后台用 一个前台用 格式不一样
--failCD 失败CD 600秒
--clearCDGold 清楚cd  10秒一金币
--startChallengingTimes 初始挑战次数 5次
--buyChallengingTimes vip可购买挑战次数
--buyChallengingTimesGold 购买次数的金币 每次50
--winReward 战斗胜利获得配置
--loseReward 战斗失败获得配置
--luckRank 幸运名次区间 {2，1000}，2到1000名
--rewardTime={1,3,5,7}, 周一 三 五 日 零点
--noticeStreak 公告连胜次数 {10,15,50,100} 连胜次数到达里面值会发公告连胜信息
--rewardStopWarTime 停止战斗时间 1800半小时
--rankReward 排名奖励配置
arenaCfg=
{

bigRewardNum=3,
smallRewardNum=7,
maxlucknums=10,
bigReward={u={{gems=50}}},
smallReward={u={{gems=25}}},
bigLuckReward={userinfo_gems=50},
smallLuckReward={userinfo_gems=25},
luckRank={2,1000},
failCD=600,
clearCDGold=10,
startChallengingTimes=5,
buyChallengingTimes={vip0=2,vip1=3,vip2=3,vip3=4,vip4=4,vip5=5,vip6=5,vip7=6,vip8=6,vip9=7,vip10=7,vip11=8,vip12=8,vip13=9,},
buyChallengingTimesGold=20,
winReward={props_p291=1},
loseReward={{100},{7,7,7,7,7,7,7,7,7,7,7,6,6,3,8,},{{"props_p6",1},{"props_p7",1},{"props_p8",1},{"props_p9",1},{"props_p10",1},{"props_p13",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p19",1},{"props_p15",1},{"props_p20",1},{"props_p47",1},}},
rankRewardItemId={e={{p4=1,index=1}}},
rankRewardId="accessory_p4",
rankMinReward=50,
useprop="p292",
rewardTime={1,3,5,7},
noticeStreak={10,20,50,100},
rewardStopWarTime=1800,
npcName={10,40,130,400,450},

---------------------------------------------------------------以上为原配置---------------------------------------------------------------

---------------------------------------------------------------新增军事演习配置---------------------------------------------------------------
 --winPoint军事演习胜利获得积分,每日清空
 --losePoint军事演习失败获得积分,每日清空
 --buyChallengingTimes2 vip可购买挑战次数
 --buyChallengingTimesGold2 购买次数的金币 越来越贵
 --buyNum金币每次都买挑战次数
 --frontRival从前面多少位取玩家
 --frontRivalNum从前面取几个
 --behindRival从后面多少位取玩家
 --behindRivalNum从后面取几个
 --refershPrice刷新可攻打列表价格,越来越贵
 --rankReward每日排名奖
 --pointReward每日积分奖励
 --rewardStopWarTime2 发奖前休战时间
 --refreshCost奖池刷新价格，超过最大值按最大值算

winPoint=2,
losePoint=1,
buyChallengingTimes2={vip0=1,vip1=2,vip2=2,vip3=3,vip4=3,vip5=4,vip6=4,vip7=5,vip8=6,vip9=7,vip10=8,vip11=9,vip12=10,vip13=11,},
buyChallengingTimesGold2={50,100,150,200,250,300,350,400,450,500,550,600,},
buyNum=5,
frontRival=20,
frontRivalNum=4,
behindRival=10,
behindRivalNum=1,
refershPrice={1,2,3,4,5,6,7,8,9,10,},
refreshtime={24,0}, --发奖和积分任务刷新时间
rewardStopWarTime2=300,
refreshCost={0,10,20,30,40,50,60,70,80,90,100,},

rankReward={
{range={1,1},serverReward={userinfo_gems=100,userarena_point=2000,accessory_p4=1000,},reward={u={gems=100},m={p=2000},e={p4=1000},}},
{range={2,2},serverReward={userinfo_gems=95,userarena_point=1900,accessory_p4=950,},reward={u={gems=95},m={p=1900},e={p4=950},}},
{range={3,3},serverReward={userinfo_gems=90,userarena_point=1800,accessory_p4=900,},reward={u={gems=90},m={p=1800},e={p4=900},}},
{range={4,4},serverReward={userinfo_gems=85,userarena_point=1700,accessory_p4=850,},reward={u={gems=85},m={p=1700},e={p4=850},}},
{range={5,5},serverReward={userinfo_gems=80,userarena_point=1600,accessory_p4=800,},reward={u={gems=80},m={p=1600},e={p4=800},}},
{range={6,6},serverReward={userinfo_gems=75,userarena_point=1500,accessory_p4=750,},reward={u={gems=75},m={p=1500},e={p4=750},}},
{range={7,7},serverReward={userinfo_gems=70,userarena_point=1400,accessory_p4=700,},reward={u={gems=70},m={p=1400},e={p4=700},}},
{range={8,8},serverReward={userinfo_gems=65,userarena_point=1300,accessory_p4=650,},reward={u={gems=65},m={p=1300},e={p4=650},}},
{range={9,9},serverReward={userinfo_gems=60,userarena_point=1200,accessory_p4=600,},reward={u={gems=60},m={p=1200},e={p4=600},}},
{range={10,10},serverReward={userinfo_gems=55,userarena_point=1100,accessory_p4=550,},reward={u={gems=55},m={p=1100},e={p4=550},}},
{range={11,20},serverReward={userinfo_gems=50,userarena_point=1000,accessory_p4=500,},reward={u={gems=50},m={p=1000},e={p4=500},}},
{range={21,40},serverReward={userinfo_gems=45,userarena_point=900,accessory_p4=450,},reward={u={gems=45},m={p=900},e={p4=450},}},
{range={41,60},serverReward={userinfo_gems=40,userarena_point=800,accessory_p4=400,},reward={u={gems=40},m={p=800},e={p4=400},}},
{range={61,80},serverReward={userinfo_gems=35,userarena_point=700,accessory_p4=350,},reward={u={gems=35},m={p=700},e={p4=350},}},
{range={81,100},serverReward={userinfo_gems=30,userarena_point=650,accessory_p4=300,},reward={u={gems=30},m={p=650},e={p4=300},}},
{range={101,200},serverReward={userinfo_gems=25,userarena_point=600,accessory_p4=250,},reward={u={gems=25},m={p=600},e={p4=250},}},
{range={201,300},serverReward={userinfo_gems=20,userarena_point=550,accessory_p4=200,},reward={u={gems=20},m={p=550},e={p4=200},}},
{range={301,500},serverReward={userinfo_gems=15,userarena_point=500,accessory_p4=150,},reward={u={gems=15},m={p=500},e={p4=150},}},
{range={501,1000},serverReward={userinfo_gems=10,userarena_point=450,accessory_p4=100,},reward={u={gems=10},m={p=450},e={p4=100},}},
{range={1001,3000},serverReward={userinfo_gems=5,userarena_point=400,accessory_p4=50,},reward={u={gems=5},m={p=400},e={p4=50},}},
},

pointReward={
{point=2,serverReward={equip_e1=100,userarena_point=100,props_p19=1,},reward={f={e1=100},m={p=100},p={p19=1},}},
{point=4,serverReward={equip_e1=100,userarena_point=100,props_p19=1,},reward={f={e1=100},m={p=100},p={p19=1},}},
{point=6,serverReward={equip_e1=100,userarena_point=100,props_p19=1,},reward={f={e1=100},m={p=100},p={p19=1},}},
{point=8,serverReward={equip_e1=100,userarena_point=100,props_p19=1,},reward={f={e1=100},m={p=100},p={p19=1},}},
{point=10,serverReward={equip_e1=200,userarena_point=200,props_p933=1,},reward={f={e1=200},m={p=200},p={p933=1},}},
{point=12,serverReward={equip_e1=100,userarena_point=100,props_p819=1,},reward={f={e1=100},m={p=100},p={p819=1},}},
{point=14,serverReward={equip_e1=100,userarena_point=100,props_p819=1,},reward={f={e1=100},m={p=100},p={p819=1},}},
{point=16,serverReward={equip_e1=100,userarena_point=100,props_p819=1,},reward={f={e1=100},m={p=100},p={p819=1},}},
{point=18,serverReward={equip_e1=100,userarena_point=100,props_p819=1,},reward={f={e1=100},m={p=100},p={p819=1},}},
{point=20,serverReward={equip_e1=200,userarena_point=200,props_p933=1,},reward={f={e1=200},m={p=200},p={p933=1},}},
},



}

function arenaCfg.getrewardcount(rank)
    return math.floor(1955*17/(16+rank)+45)
end

function arenaCfg.getGoldByTime(time)
    local gold=math.ceil(time/arenaCfg.clearCDGold)
    return gold
end

