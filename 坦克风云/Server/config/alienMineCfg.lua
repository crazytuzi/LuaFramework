 -- 异星矿场配置
local alienMineCfg = {
--[[
island = {
{x=1,y=1,type=1,level=52},{x=2,y=1,type=2,level=52},{x=3,y=1,type=2,level=52},{x=4,y=1,type=3,level=52},{x=5,y=1,type=1,level=52},{x=6,y=1,type=2,level=52},{x=7,y=1,type=1,level=52},{x=8,y=1,type=2,level=52},{x=9,y=1,type=3,level=52},{x=10,y=1,type=3,level=52},{x=11,y=1,type=1,level=52},{x=12,y=1,type=1,level=52},{x=13,y=1,type=3,level=52},{x=14,y=1,type=3,level=52},{x=15,y=1,type=2,level=52},{x=16,y=1,type=2,level=52},{x=17,y=1,type=2,level=52},{x=18,y=1,type=1,level=52},{x=19,y=1,type=3,level=52},{x=20,y=1,type=1,level=52},
{x=1,y=2,type=3,level=52},{x=2,y=2,type=3,level=54},{x=3,y=2,type=1,level=54},{x=4,y=2,type=2,level=54},{x=5,y=2,type=1,level=54},{x=6,y=2,type=2,level=54},{x=7,y=2,type=2,level=54},{x=8,y=2,type=3,level=54},{x=9,y=2,type=1,level=54},{x=10,y=2,type=1,level=54},{x=11,y=2,type=2,level=54},{x=12,y=2,type=1,level=54},{x=13,y=2,type=3,level=54},{x=14,y=2,type=1,level=54},{x=15,y=2,type=2,level=54},{x=16,y=2,type=2,level=54},{x=17,y=2,type=2,level=54},{x=18,y=2,type=1,level=54},{x=19,y=2,type=2,level=54},{x=20,y=2,type=1,level=52},
{x=1,y=3,type=1,level=52},{x=2,y=3,type=2,level=54},{x=3,y=3,type=2,level=56},{x=4,y=3,type=3,level=56},{x=5,y=3,type=1,level=56},{x=6,y=3,type=1,level=56},{x=7,y=3,type=3,level=56},{x=8,y=3,type=3,level=56},{x=9,y=3,type=1,level=56},{x=10,y=3,type=3,level=56},{x=11,y=3,type=3,level=56},{x=12,y=3,type=2,level=56},{x=13,y=3,type=3,level=56},{x=14,y=3,type=3,level=56},{x=15,y=3,type=3,level=56},{x=16,y=3,type=2,level=56},{x=17,y=3,type=1,level=56},{x=18,y=3,type=2,level=56},{x=19,y=3,type=3,level=54},{x=20,y=3,type=1,level=52},
{x=1,y=4,type=3,level=52},{x=2,y=4,type=2,level=54},{x=3,y=4,type=2,level=56},{x=4,y=4,type=1,level=58},{x=5,y=4,type=1,level=58},{x=6,y=4,type=2,level=58},{x=7,y=4,type=2,level=58},{x=8,y=4,type=3,level=58},{x=9,y=4,type=3,level=58},{x=10,y=4,type=3,level=58},{x=11,y=4,type=1,level=58},{x=12,y=4,type=1,level=58},{x=13,y=4,type=1,level=58},{x=14,y=4,type=3,level=58},{x=15,y=4,type=3,level=58},{x=16,y=4,type=2,level=58},{x=17,y=4,type=2,level=58},{x=18,y=4,type=2,level=56},{x=19,y=4,type=3,level=54},{x=20,y=4,type=2,level=52},
{x=1,y=5,type=1,level=52},{x=2,y=5,type=3,level=54},{x=3,y=5,type=3,level=56},{x=4,y=5,type=3,level=58},{x=5,y=5,type=3,level=60},{x=6,y=5,type=1,level=60},{x=7,y=5,type=1,level=60},{x=8,y=5,type=1,level=60},{x=9,y=5,type=2,level=60},{x=10,y=5,type=1,level=60},{x=11,y=5,type=3,level=60},{x=12,y=5,type=3,level=60},{x=13,y=5,type=1,level=60},{x=14,y=5,type=3,level=60},{x=15,y=5,type=1,level=60},{x=16,y=5,type=1,level=60},{x=17,y=5,type=1,level=58},{x=18,y=5,type=3,level=56},{x=19,y=5,type=1,level=54},{x=20,y=5,type=1,level=52},
{x=1,y=6,type=2,level=52},{x=2,y=6,type=3,level=54},{x=3,y=6,type=3,level=56},{x=4,y=6,type=2,level=58},{x=5,y=6,type=3,level=60},{x=6,y=6,type=2,level=62},{x=7,y=6,type=2,level=62},{x=8,y=6,type=3,level=62},{x=9,y=6,type=2,level=62},{x=10,y=6,type=3,level=62},{x=11,y=6,type=3,level=62},{x=12,y=6,type=3,level=62},{x=13,y=6,type=1,level=62},{x=14,y=6,type=3,level=62},{x=15,y=6,type=1,level=62},{x=16,y=6,type=2,level=60},{x=17,y=6,type=2,level=58},{x=18,y=6,type=2,level=56},{x=19,y=6,type=2,level=54},{x=20,y=6,type=2,level=52},
{x=1,y=7,type=3,level=52},{x=2,y=7,type=3,level=54},{x=3,y=7,type=2,level=56},{x=4,y=7,type=2,level=58},{x=5,y=7,type=2,level=60},{x=6,y=7,type=3,level=62},{x=7,y=7,type=1,level=64},{x=8,y=7,type=2,level=64},{x=9,y=7,type=3,level=64},{x=10,y=7,type=3,level=64},{x=11,y=7,type=1,level=64},{x=12,y=7,type=3,level=64},{x=13,y=7,type=2,level=64},{x=14,y=7,type=2,level=64},{x=15,y=7,type=1,level=62},{x=16,y=7,type=2,level=60},{x=17,y=7,type=3,level=58},{x=18,y=7,type=2,level=56},{x=19,y=7,type=1,level=54},{x=20,y=7,type=2,level=52},
{x=1,y=8,type=2,level=52},{x=2,y=8,type=3,level=54},{x=3,y=8,type=2,level=56},{x=4,y=8,type=2,level=58},{x=5,y=8,type=3,level=60},{x=6,y=8,type=1,level=62},{x=7,y=8,type=1,level=64},{x=8,y=8,type=2,level=66},{x=9,y=8,type=2,level=66},{x=10,y=8,type=2,level=66},{x=11,y=8,type=1,level=66},{x=12,y=8,type=2,level=66},{x=13,y=8,type=2,level=66},{x=14,y=8,type=2,level=64},{x=15,y=8,type=3,level=62},{x=16,y=8,type=2,level=60},{x=17,y=8,type=3,level=58},{x=18,y=8,type=2,level=56},{x=19,y=8,type=2,level=54},{x=20,y=8,type=3,level=52},
{x=1,y=9,type=2,level=52},{x=2,y=9,type=1,level=54},{x=3,y=9,type=3,level=56},{x=4,y=9,type=3,level=58},{x=5,y=9,type=2,level=60},{x=6,y=9,type=1,level=62},{x=7,y=9,type=3,level=64},{x=8,y=9,type=3,level=66},{x=9,y=9,type=1,level=68},{x=10,y=9,type=3,level=68},{x=11,y=9,type=2,level=68},{x=12,y=9,type=3,level=68},{x=13,y=9,type=1,level=66},{x=14,y=9,type=2,level=64},{x=15,y=9,type=3,level=62},{x=16,y=9,type=3,level=60},{x=17,y=9,type=3,level=58},{x=18,y=9,type=3,level=56},{x=19,y=9,type=3,level=54},{x=20,y=9,type=3,level=52},
{x=1,y=10,type=3,level=52},{x=2,y=10,type=2,level=54},{x=3,y=10,type=3,level=56},{x=4,y=10,type=3,level=58},{x=5,y=10,type=3,level=60},{x=6,y=10,type=1,level=62},{x=7,y=10,type=3,level=64},{x=8,y=10,type=2,level=66},{x=9,y=10,type=3,level=68},{x=10,y=10,type=1,level=70},{x=11,y=10,type=3,level=70},{x=12,y=10,type=2,level=68},{x=13,y=10,type=2,level=66},{x=14,y=10,type=3,level=64},{x=15,y=10,type=3,level=62},{x=16,y=10,type=1,level=60},{x=17,y=10,type=3,level=58},{x=18,y=10,type=1,level=56},{x=19,y=10,type=1,level=54},{x=20,y=10,type=2,level=52},
{x=1,y=11,type=2,level=52},{x=2,y=11,type=1,level=54},{x=3,y=11,type=2,level=56},{x=4,y=11,type=1,level=58},{x=5,y=11,type=3,level=60},{x=6,y=11,type=3,level=62},{x=7,y=11,type=2,level=64},{x=8,y=11,type=2,level=66},{x=9,y=11,type=2,level=68},{x=10,y=11,type=1,level=70},{x=11,y=11,type=2,level=70},{x=12,y=11,type=3,level=68},{x=13,y=11,type=3,level=66},{x=14,y=11,type=3,level=64},{x=15,y=11,type=3,level=62},{x=16,y=11,type=2,level=60},{x=17,y=11,type=1,level=58},{x=18,y=11,type=2,level=56},{x=19,y=11,type=2,level=54},{x=20,y=11,type=3,level=52},
{x=1,y=12,type=1,level=52},{x=2,y=12,type=1,level=54},{x=3,y=12,type=3,level=56},{x=4,y=12,type=3,level=58},{x=5,y=12,type=1,level=60},{x=6,y=12,type=3,level=62},{x=7,y=12,type=3,level=64},{x=8,y=12,type=1,level=66},{x=9,y=12,type=1,level=68},{x=10,y=12,type=3,level=68},{x=11,y=12,type=2,level=68},{x=12,y=12,type=3,level=68},{x=13,y=12,type=2,level=66},{x=14,y=12,type=2,level=64},{x=15,y=12,type=3,level=62},{x=16,y=12,type=3,level=60},{x=17,y=12,type=1,level=58},{x=18,y=12,type=1,level=56},{x=19,y=12,type=3,level=54},{x=20,y=12,type=3,level=52},
{x=1,y=13,type=2,level=52},{x=2,y=13,type=1,level=54},{x=3,y=13,type=3,level=56},{x=4,y=13,type=2,level=58},{x=5,y=13,type=1,level=60},{x=6,y=13,type=2,level=62},{x=7,y=13,type=1,level=64},{x=8,y=13,type=3,level=66},{x=9,y=13,type=2,level=66},{x=10,y=13,type=3,level=66},{x=11,y=13,type=1,level=66},{x=12,y=13,type=3,level=66},{x=13,y=13,type=2,level=66},{x=14,y=13,type=3,level=64},{x=15,y=13,type=3,level=62},{x=16,y=13,type=3,level=60},{x=17,y=13,type=3,level=58},{x=18,y=13,type=1,level=56},{x=19,y=13,type=2,level=54},{x=20,y=13,type=2,level=52},
{x=1,y=14,type=1,level=52},{x=2,y=14,type=3,level=54},{x=3,y=14,type=3,level=56},{x=4,y=14,type=1,level=58},{x=5,y=14,type=3,level=60},{x=6,y=14,type=2,level=62},{x=7,y=14,type=1,level=64},{x=8,y=14,type=3,level=64},{x=9,y=14,type=3,level=64},{x=10,y=14,type=3,level=64},{x=11,y=14,type=3,level=64},{x=12,y=14,type=2,level=64},{x=13,y=14,type=2,level=64},{x=14,y=14,type=2,level=64},{x=15,y=14,type=1,level=62},{x=16,y=14,type=3,level=60},{x=17,y=14,type=3,level=58},{x=18,y=14,type=2,level=56},{x=19,y=14,type=1,level=54},{x=20,y=14,type=2,level=52},
{x=1,y=15,type=2,level=52},{x=2,y=15,type=3,level=54},{x=3,y=15,type=1,level=56},{x=4,y=15,type=2,level=58},{x=5,y=15,type=1,level=60},{x=6,y=15,type=1,level=62},{x=7,y=15,type=2,level=62},{x=8,y=15,type=3,level=62},{x=9,y=15,type=3,level=62},{x=10,y=15,type=2,level=62},{x=11,y=15,type=3,level=62},{x=12,y=15,type=2,level=62},{x=13,y=15,type=3,level=62},{x=14,y=15,type=1,level=62},{x=15,y=15,type=2,level=62},{x=16,y=15,type=1,level=60},{x=17,y=15,type=3,level=58},{x=18,y=15,type=1,level=56},{x=19,y=15,type=1,level=54},{x=20,y=15,type=1,level=52},
{x=1,y=16,type=2,level=52},{x=2,y=16,type=1,level=54},{x=3,y=16,type=3,level=56},{x=4,y=16,type=3,level=58},{x=5,y=16,type=3,level=60},{x=6,y=16,type=1,level=60},{x=7,y=16,type=1,level=60},{x=8,y=16,type=2,level=60},{x=9,y=16,type=3,level=60},{x=10,y=16,type=2,level=60},{x=11,y=16,type=2,level=60},{x=12,y=16,type=2,level=60},{x=13,y=16,type=2,level=60},{x=14,y=16,type=3,level=60},{x=15,y=16,type=1,level=60},{x=16,y=16,type=1,level=60},{x=17,y=16,type=3,level=58},{x=18,y=16,type=3,level=56},{x=19,y=16,type=3,level=54},{x=20,y=16,type=3,level=52},
{x=1,y=17,type=1,level=52},{x=2,y=17,type=1,level=54},{x=3,y=17,type=2,level=56},{x=4,y=17,type=3,level=58},{x=5,y=17,type=1,level=58},{x=6,y=17,type=2,level=58},{x=7,y=17,type=1,level=58},{x=8,y=17,type=2,level=58},{x=9,y=17,type=3,level=58},{x=10,y=17,type=1,level=58},{x=11,y=17,type=2,level=58},{x=12,y=17,type=2,level=58},{x=13,y=17,type=1,level=58},{x=14,y=17,type=3,level=58},{x=15,y=17,type=1,level=58},{x=16,y=17,type=3,level=58},{x=17,y=17,type=3,level=58},{x=18,y=17,type=2,level=56},{x=19,y=17,type=3,level=54},{x=20,y=17,type=3,level=52},
{x=1,y=18,type=2,level=52},{x=2,y=18,type=3,level=54},{x=3,y=18,type=2,level=56},{x=4,y=18,type=1,level=56},{x=5,y=18,type=2,level=56},{x=6,y=18,type=1,level=56},{x=7,y=18,type=3,level=56},{x=8,y=18,type=3,level=56},{x=9,y=18,type=1,level=56},{x=10,y=18,type=1,level=56},{x=11,y=18,type=2,level=56},{x=12,y=18,type=2,level=56},{x=13,y=18,type=2,level=56},{x=14,y=18,type=1,level=56},{x=15,y=18,type=1,level=56},{x=16,y=18,type=2,level=56},{x=17,y=18,type=1,level=56},{x=18,y=18,type=2,level=56},{x=19,y=18,type=3,level=54},{x=20,y=18,type=1,level=52},
{x=1,y=19,type=2,level=52},{x=2,y=19,type=3,level=54},{x=3,y=19,type=3,level=54},{x=4,y=19,type=1,level=54},{x=5,y=19,type=2,level=54},{x=6,y=19,type=2,level=54},{x=7,y=19,type=2,level=54},{x=8,y=19,type=3,level=54},{x=9,y=19,type=2,level=54},{x=10,y=19,type=2,level=54},{x=11,y=19,type=3,level=54},{x=12,y=19,type=2,level=54},{x=13,y=19,type=3,level=54},{x=14,y=19,type=2,level=54},{x=15,y=19,type=3,level=54},{x=16,y=19,type=3,level=54},{x=17,y=19,type=1,level=54},{x=18,y=19,type=1,level=54},{x=19,y=19,type=3,level=54},{x=20,y=19,type=2,level=52},
{x=1,y=20,type=3,level=52},{x=2,y=20,type=3,level=52},{x=3,y=20,type=2,level=52},{x=4,y=20,type=3,level=52},{x=5,y=20,type=3,level=52},{x=6,y=20,type=1,level=52},{x=7,y=20,type=1,level=52},{x=8,y=20,type=2,level=52},{x=9,y=20,type=2,level=52},{x=10,y=20,type=3,level=52},{x=11,y=20,type=1,level=52},{x=12,y=20,type=1,level=52},{x=13,y=20,type=2,level=52},{x=14,y=20,type=1,level=52},{x=15,y=20,type=3,level=52},{x=16,y=20,type=3,level=52},{x=17,y=20,type=3,level=52},{x=18,y=20,type=1,level=52},{x=19,y=20,type=1,level=52},{x=20,y=20,type=1,level=52},
},]]
 --矿点类型：1晶尘2晶岩3晶核
-- 52~70的配置 矿点NPC配置
-- 52~70的钛矿 侦查 和 采集速度  map.lua

needLevel=45, --该功能需要至少45级才能使用

dailyOccupyNum=5, -- 每日占领的次数
dailyRobNum=5, -- 每日掠夺的次数



startTime = {15,0}, -- 战斗开始的时间,
endTime = {16,0}, -- 战斗结束时间

openTime={6,0}, -- 每周的星期六和日开放

protectTime=900, -- 占领后保护时间,无法被攻击

robRate=0.5, -- 击败敌方部队可以获得  ---可以获得对面 50%的资源

damageRate=0.2, ---损失率 直接损失20%的部队，不能修复 ，余下部队全部自动修复（不花资源）

 -- TODO
 -- 每个矿点上增配置,不同等级,可以采集的资源种类,和 资源速度。

 -- 排行榜,每种资源换算点数

resToPoint = {
r1=1,
r2=2,
r3=5,
},

 -- 个人排行榜的奖励
userRanking = {
needpoint=10000,
reward ={
{range={1,1},reward={r={{r2=5000}}},serverReward={r2=5000}},
{range={2,2},reward={r={{r2=4000}}},serverReward={r2=4000}},
{range={3,3},reward={r={{r2=3000}}},serverReward={r2=3000}},
{range={4,5},reward={r={{r2=2000}}},serverReward={r2=2000}},
{range={6,10},reward={r={{r2=1000}}},serverReward={r2=1000}},
},
},

 --军团排行榜的奖励，今日之前加入且能进入该界面才可领取
allianceRanking={
needpoint=50000,
reward={
{range={1,1},reward={r={{r1=10000}}},serverReward={r1=10000}},
},
},

 -- TODO
 -- 收集资源转换r1,r2,r3的比例，可以获得的上限
collect={
{res="r1",rate=0.001,max=58000},
{res="r2",rate=0.0005,max=29000},
{res="r3",rate=0.0002,max=12000},
}

}

return alienMineCfg
