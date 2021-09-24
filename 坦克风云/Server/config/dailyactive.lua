--
-- 每日活动配置
-- User: luoning
-- Date: 15-1-23
-- Time: 下午4:09
--
local dailyactiveCfg = {
    --每日答题
    meiridati={
        sortId=567,
        type=1,
        --开启时间端
        openTime={{12,30},{12,40}},
        --可以领取奖励的最后时间24:00
        getRewardTime={24,00},
        --排行榜保留时间24个小时
        rankTime=24,
        --活动开启前X时间可进入活动
        lastTime=300,
        --答题时间
        choiceTime=20,
        --显示X秒结果
        resultTime=5,
        --正确答案
        rightAnswer=1,
        --答错积分
        losepoint=5,
        --排名奖励
        rankReward={
            {{1,1},{p={{p817=30,index=1},{p416=50,index=2},},}},
            {{2,2},{p={{p817=20,index=1},{p416=35,index=2},},}},
            {{3,3},{p={{p817=15,index=1},{p416=25,index=2},},}},
            {{4,5},{p={{p817=10,index=1},{p416=20,index=2},},}},
            {{6,10},{p={{p817=7,index=1},{p416=15,index=2},},}},
            {{11,20},{p={{p817=5,index=1},{p416=10,index=2},},}},
        },
        --每题答对奖励
        choiceReward={p={{p19=1,index=1},},},
        --排名前几名的有排名奖励
        rewardlimit=20,
        serverreward={
            --每个类别选择4道题
            choiceSubject=4,
            --总计五大类
            category=5,
            --每个类别题库有多少道题
            subjectCount={55,36,29,53,27},
            --排名奖励
            rankReward={
                {{1,1},{props_p817=30,props_p416=50,}},
                {{2,2},{props_p817=20,props_p416=35,}},
                {{3,3},{props_p817=15,props_p416=25,}},
                {{4,5},{props_p817=10,props_p416=20,}},
                {{6,10},{props_p817=7,props_p416=15,}},
                {{11,20},{props_p817=5,props_p416=10,}},
            },
            --每题答对奖励
            choiceReward={props_p19=1},
        },
    },
    --每日领体力（晚上）
    getEnergyNightCfg={
        opentime={{18,0},{20,0}}, --开放时间
        reward={u={{energy=10},},},
        serverReward={
            reward={userinfo_energy=10},
        },
    },
    --每日领体力（中午）
    getEnergyNoonCfg={
        opentime={{12,0},{14,0}}, --开放时间
        reward={u={{energy=10},},},
        serverReward={
            reward={userinfo_energy=10},
        },
    },
    --维修打折
fixdiscount ={
    --等级限制
    levelLimit=10,
    --活动时间（星期X，目前是跟海域争夺战一致，为周六(多天数配置中：周日=0，周一到周六=1-6））
    openWeek={6},
    --开启时间（时）
    openTime={{0,24}},
    --打折幅度（钻石、稀土）
    gemDiscount=0.1,
    goldDiscount=0.8,

},




}

return dailyactiveCfg
