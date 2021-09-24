weaponrobCfg=
{
systemStop={1,28800}, --系统免战期 每天的第1秒到X秒之间
grapRate = 0.3, --抢夺玩家基础成功率
energyMax=10, --能量最大值
energyRecovery=7200, --能量恢复速度 每X秒恢复1点
energyGemsBuyNum={ --金币恢复体力次数 跟VIP等级有关 第一个为vip0的配置，VIP+1取出
1,2,3,4,5,6,7,8,9,10,11,12,13
},
energyGemsBuyCost={ --金币购买体力价格
25,50,75,100,125,150,175,200,225,250,275,300,325
},
energyBuyAdd=5, --金币购买体力增加量

refreshRobList=1800, --系统刷新抢夺列表时间
refreshRobListFreeCd=600, --手动刷新免费间隔
refreshRobListGems={ --金币刷新列表价格
1,2,3,4,5,6,7,8,10,12,15,20
},
gemsBuyProtectTime=7200, --金币购买保护时间 单位 秒
gemsBuyProtectCost=58, --金币购买保护价格
robProtectTime=40, --抢夺碎片成功自动保护时间 单位 秒
getProtectTime=60, --获得碎片后自动保护时间 单位 秒

 --NPC部队随机库
npcArmyRandList={
{"a10003","a10004","a10024","a10023","a10034"},
{"a10003","a10004","a10024","a10023","a10034"},
{"a10003","a10004","a10024","a10023","a10034"},
{"a10013","a10014","a10033","a10043","a10053"},
{"a10013","a10014","a10033","a10043","a10053"},
{"a10013","a10014","a10033","a10043","a10053"},
},

 --战斗结束翻牌奖池
flop={
{100},
{7,6,6,6,7,6,5,1,7,7,7,3,2,3,3,3,3,3,3,3,3,3,3,},
{{"props_p19",1},{"props_p20",1},{"props_p15",1},{"props_p292",1},{"props_p446",1},{"props_p447",1},{"props_p601",1},{"props_p601",5},{"accessory_p3",1},{"accessory_p2",1},{"accessory_p1",1},{"weapon_p1",100},{"weapon_p1",1000},{"weapon_c1",1},{"weapon_c11",1},{"weapon_c21",1},{"weapon_c31",1},{"weapon_c41",1},{"weapon_c51",1},{"weapon_c61",1},{"weapon_c71",1},{"weapon_c81",1},{"weapon_c91",1},},
},

 --战斗结束翻牌奖池前端
flopReward={p={p19=1,p20=1,p15=1,p292=1,p446=1,p447=1,p601=1,p601=5,},e={p3=1,p2=1,p1=1,},w={p1=100,p1=1000,c1=1,c11=1,c21=1,c31=1,c41=1,c51=1,c61=1,c71=1,c81=1,c91=1,}},

--和平时段 0点到10点
peaceTime={{0,0},{8,0}},

--免战消耗道具
protectCostProp={p={p912=1}},
--补充体力消耗道具
addEnergyCostProp={p={p911=1}},

npcArmyNum=12, --NPC部队数量倍率，数量为等级*12
 --抢夺概率对应的低中高显示
rate={10,35,100,},

robListRule={ --抢夺规则 
hThan=300, --Higher than高于X名次
hThanNum=2, --高于400取x个玩家
lThan=200, --Less than低于X名次
lThanNum=2, --低于100取X个玩家
npcNum=1, --NPC取X名
 --NPC抢夺概率
npcRobProb={15,9,9,8,8,7,7,6,6,5,5,4,4,3,3,},
}

}
