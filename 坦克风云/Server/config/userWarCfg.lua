local userWarCfg={ -- 异元战场 2016年 超豪华萌萌加强版本
    maxBattleTime=1500, --战斗最大战斗时间
    prepareTime=300, --开战前的准备阶段时长
    --winPointToDonate=0.005, --积分换成贡献
    --maxTankDonate=1000, --最大击毁坦克贡献获得
    tankeTransRate=100, --坦克消耗兑换的比例
    xMaxValue = 6, -- 地图x轴最大值
    yMaxValue = 5, -- 地图y轴最大值
    startWarTime={20,0}, --战斗开启时间
    roundTime=15, -- 每回合准备阶段时长
    roundAccountTime = 15, -- 每回合结算时长
    openDate=0,    --  开启的单双天
    signUpTime={     --  报名时间
        start={9,0},--报名的开始时间 {时,分}
        finish={19,55},--报名的结束时间 {时,分}
    },
    roundMax = 50, -- 战斗最大回合数
    energyMax = 30,
    maxApplyNum = 200,-- 最大报名人数


    ShopItems=
    {
		i1={id="i1",buynum=10,price=100,reward={p={{p601=5}}},serverReward={props_p601=5}},
		i2={id="i2",buynum=1,price=200,reward={p={{p431=1}}},serverReward={props_p431=1}},
		i3={id="i3",buynum=1,price=200,reward={p={{p432=1}}},serverReward={props_p432=1}},
		i4={id="i4",buynum=1,price=200,reward={p={{p433=1}}},serverReward={props_p433=1}},
		i5={id="i5",buynum=1,price=200,reward={p={{p434=1}}},serverReward={props_p434=1}},
		i6={id="i6",buynum=1,price=1500,reward={p={{p807=1}}},serverReward={props_p807=1}},
		i7={id="i7",buynum=1,price=2500,reward={p={{p810=1}}},serverReward={props_p810=1}},
    },

    -- 行动卡名称映射
    cardsName = {
        stay1= 0,
        discovery1 = 1,
        battle = 2,
        settrap1 = 3,
        stay2 = 4,
        discovery2 = 5,
        hide = 6,
        settrap2 = 102,
    },
    -- 随机抽行动卡
    randAction = {
        normal = {
            num = 1,
            list = {
                -- stay1 = 30, 前端固定不用返回
                discovery1 = 20,
                settrap1 = 30,
                battle = 50,
            }
        },
        gems = {
            num = 1,
            list = {
                stay2 = 70,
                discovery2 = 20,
                hide = 10,
            }
        }
    },

    -- 随机事件
    -- 格式：事件名 = {默认权重=30,行为权重}
    -- 行为权重，增加不同行为触发某种随机事件的可能性
    randEvent = { -- 幸存者
        none = { default=0,stay1=35,battle1=50,settrap1=50,stay2=45,hide=100,battle2=60,settrap2=100,}, --什么都没发生
        battle = { default=0,noselect=35,stay1=20,discovery1=10,settrap1=20,stay2=15,discovery2=5,}, --放入战斗列表
        trap1 = { default=0,noselect=20,stay1=5,discovery1=5,battle1=10,settrap1=5,discovery2=5,}, --踩到陷阱
        trap2 = { default=0,noselect=10,discovery1=5,battle1=10,settrap1=5,discovery2=5,}, --踩到污染
        upBuff = { default=0,noselect=5,stay1=30,discovery1=10,battle1=20,settrap1=0,stay2=35,discovery2=10,battle2=30,}, --增益buff
        downBuff = { default=0,noselect=30,stay1=10,discovery1=10,battle1=10,settrap1=10,stay2=5,discovery2=5,}, --减益buff
        reward = { default=0,discovery1=10,settrap1=10,discovery2=10,battle2=10,noselect=0}, --普通物品奖励
        point = { default=0,discovery1=20,discovery2=25,}, --发现点数
        energy = { default=0,discovery1=30,discovery2=35,}, --发现体力
    },

    randPoint = {5,15},

    -- 事件buff增加
    eventUpBuff = {
        probability = {
            b1 = {default=5}, -- 攻击 5%
            b2 = {default=15}, -- 血量 5%
        },
        list = {
            b1={maxLv=10,per=0.05},
            b2={maxLv=10,per=0.05},
        }
    },
    -- 减少的buff
    eventDownBuff = {
        probability = {
            b1 = {default=15}, -- 攻击 5%
            --b2 = {default=5}, -- 血量 5%
            b3 = {default=40}, -- 命中 5%
            --b4 = {default=40}, -- 闪避 5%
            b5 = {default=40}, -- 暴击 5%
            --b6 = {default=40}, -- 装甲 5%
        },
        list = {
            b1={maxLv=10,per=0.05},
            b2={maxLv=10,per=0.05},
            b3={maxLv=10,per=0.05},
            b4={maxLv=10,per=0.05},
            b5={maxLv=10,per=0.05},
            b6={maxLv=10,per=0.05},
        }
    },



    -- 设置陷阱
    trap1 = {
        cost = {energy=2},
        probability = {
            --b1 = {default=15}, -- 攻击 5%
            b2 = {default=5}, -- 血量 5%
            --b3 = {default=40}, -- 命中 5%
            b4 = {default=40}, -- 闪避 5%
            --b5 = {default=40}, -- 暴击 5%
            b6 = {default=40}, -- 装甲 5%
        },
    },
    -- 污染
    trap2 = {
        cost = {energy=5},
        probability = {
            --b1 = {default=15}, -- 攻击 5%
            b2 = {default=5}, -- 血量 5%
            --b3 = {default=40}, -- 命中 5%
            b4 = {default=40}, -- 闪避 5%
            --b5 = {default=40}, -- 暴击 5%
            b6 = {default=40}, -- 装甲 5%
        },
    },

    -- 补给
    support = {
        energy = { -- 体力恢复
            cost = {gems=88},addEnergy = 20,limit = 2,
        },
        troops = { -- 部队恢复
            cost = {gems=58},limit = 1,
        },
        clearStatus = { -- 去除Deff
            cost = {gems=38},limit = 1,
        }
    },
    -- 普通休整
    stay1 = {
        -- 消耗行动力
        cost = {energy=1},
        -- 恢复x点行动力
        addEnergy = 0,
    },
    -- 高级休整
    stay2 = {
        -- 消耗行动力
        cost = {gems=18},
        -- 恢复x点行动力
        addEnergy = 0,
    },

-- 随机事件增加体力
    eventAddEnergy = 5,

-- 事件奖励
    eventReward = {
        pool={
            {100},
            {3,12,8,1,1,15,15,15,15,15},
            {{"props_p20",1},{"props_p19",1},{"props_p447",1},{"props_p983",1},{"props_p819",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1}}
        },
    },

    -- 普通探索
    discovery1 = {
        -- 30%几率探索成功
        probability = 30,
        -- 消耗行动力
        cost = {energy=2},
        -- 成功探索奖励
        -- 给积分的概率
        pointProb = 30,
        addPoint = {10,10},
        -- 否则给普通奖励
        pool={
{100},
{5,5,5,5,5,15,15,15,15,15},
{{"props_p19",1},{"props_p427",1},{"props_p428",1},{"props_p429",1},{"props_p430",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1}}
},
    },
    -- 高级探索
    discovery2 = {
        -- 60%几率探索成功
        probability = 50,
        -- 消耗行动力
        cost = {energy=1,gems=38},
        -- 成功探索奖励
        pool={
{100},
{45,10,10,10,10,3,3,3,3,3},
{{"props_p19",1},{"props_p427",1},{"props_p428",1},{"props_p429",1},{"props_p430",1},{"props_p20",1},{"props_p431",1},{"props_p432",1},{"props_p433",1},{"props_p434",1}},
}
    },
    -- 躲猫猫 隐藏自己
    hide = {
        cost = {energy=2,gems=58},
    },
    --战斗
    battle={
        cost = {energy=3},
    },
    --设置陷阱
    settrap1={
        cost = {energy=2},
    },
    --污染
    settrap2={
        cost = {energy=5},
    },
    --亡者增加的buff
    delbuff={
        delhp=0.1, --减少对方的血量
        win=0.1, --胜利多给兵
        addbuff={--增加的buff
         accuracy=0.3,     -- 精准
         evade=0.3,        -- 闪避
         crit=0.3,         -- 暴击
         anticrit=0.3,     -- 装甲
        },
    },
-- 每回合生存积分
    survivalPoint = 10,

    -- 增加的积分 胜利的
    point={
        20, -- 亡者
        5, -- 生还者
        300,-- 最终胜利分
    },
    -- 亡者胜利增加的行动力
    energy=10,
    -- 总共格子
    blastcount=30,
    -- 回合数爆炸数序
    blast={0,0,0,1,0,0,0,2,0,0,0,3,0,0,4,0,0,5,0,0,6,0,0,7,0,8,0,9,0,10,0,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29},
    --blast={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},



    --个人排名奖励
    rankReward={
        {range={50,50},reward={p={{p20= 5}},e={{p8=5000},{p9=5000},{p10=5000}}},serverReward={props_p20= 5,accessory_p8=5000,accessory_p9=5000,accessory_p10=5000},icon="serverWarTopMedal1.png"},
        {range={45,49},reward={p={{p20= 2}},e={{p8=3500},{p9=3500},{p10=3500}}},serverReward={props_p20= 2,accessory_p8=3500,accessory_p9=3500,accessory_p10=3500},icon="serverWarTopMedal2.png"},
        {range={40,44},reward={p={{p20= 1}},e={{p8=2000},{p9=2000},{p10=2000}}},serverReward={props_p20= 1,accessory_p8=2000,accessory_p9=2000,accessory_p10=2000},icon="serverWarTopMedal3.png"},
        {range={30,39},reward={p={{p19=50}},e={{p8=1500},{p9=1500}}},serverReward={props_p19=50,accessory_p8=1500,accessory_p9=1500}},
        {range={20,29},reward={p={{p19=15}},e={{p8=1000},{p9=1000}}},serverReward={props_p19=15,accessory_p8=1000,accessory_p9=1000}},
        {range={1,19},reward={p={{p19= 5}},e={{p8=500}}},serverReward={props_p19=5,accessory_p8=500}},
    },
    -- 打仗的最大回合数
    maxbattleround=3,
    limitLevel=30, --玩家30以上才能参战
    --战报最大数量
    reportMaxNum=50,
    --积分明细最多多少条
    militaryrank=50,
}
return userWarCfg
