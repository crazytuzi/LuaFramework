local anniversary2 ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        --航海日志等级限制
        levelLimit=10,
        --红卡分享获得数量
        cardShare=2,
        --归回相关（回归玩家等级限制，回归玩家上次登陆时间间隔限制，回归玩家充值额度，召回奖励领取次数限制）
        returnLevel=30,
        lastLogin=30,
        returnRecharge=500,
        callbackGetLimit=5,
        callrechargeGetLimit=100,
        --应援相关
        supportScore=10,
        supportNeed={1000,3000,6000,12000,18000},
        --充值额度
        rechargeNum={268,1000},
        --连续充值天数需求
        rechargeDay=3,
        --连续充值获得道具
        serverreward={
            rechargeGet={{"props_p3006",6},{"props_p4748",1}},
            --红蓝卡获得概率（100为底）
            cardGet={
                {{"anv_a1",1},{"anv_a2",1}},
                --攻击基地获得概率
                {25,15},
                --攻击矿点获得概率
                {25,15},
            },
            --航海日志奖励1
            career1={{"props_p5",1},{"props_p2",5}},
            --航海日志奖励2
            career2={{"props_p17",3},{"props_p18",3}},
            --航海日志奖励3
            career3={{"props_p4802",2}},
            --航海日志奖励4
            career4={{"props_p1",1}},
            --航海日志奖励5
            career5={{"props_p49",1}},
            --应援奖励1
            gift1={{"props_p20",5},{"props_p601",10}},
            --应援奖励2
            gift2={{"props_p4810",10},{"props_p957",20}},
            --应援奖励3
            gift3={{"props_p819",10},{"props_p956",10}},
            --应援奖励4
            gift4={{"props_p4811",20},{"props_p958",10},{"props_p959",10}},
            --应援奖励5
            gift5={{"props_p818",20},{"props_p448",10},{"props_p960",10}},
            --单次充值超过X钻时奖励（每次充值都可领取）
            recharge1={{"props_p601",5},{"props_p4810",2}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"props_p818",2},{"equip_e1",5000},{"equip_e2",1000},{"equip_e3",1000}},
            --回归奖励
            returnGet={{"props_p5",2},{"props_p3",2},{"troops_a10005",20},{"troops_a10015",20},{"troops_a10025",10},{"troops_a10035",10}},
            --召回奖励
            callbackGet={{"props_p601",20},{"props_p20",5},{"props_p5",1}},
            --回归玩家充值达到指定额度给召回玩家的奖励
            callrechargeGet={{"props_p988",3},{"props_p2",1}},
            --分享奖励
            fbreward={{"props_p818",2},{"anv_a1",3},{"anv_a2",1}},
            --蓝卡奖池
            pool1={
                {100},
                {5,100,100,100,3,1,60,60,5,5,5,5},
                {{"anv_b1",1},{"anv_b2",1},{"anv_b3",1},{"anv_b4",1},{"props_p4824",1},{"props_p4820",1},{"props_p36",1},{"props_p35",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p2",1}},
            },
            
            --红卡奖池 
            pool2={
                {100},
                {60,2,2,2,30,10,30,30,15,20,20,20},
                {{"anv_b1",1},{"anv_b2",1},{"anv_b3",1},{"anv_b4",1},{"props_p819",1},{"props_p818",1},{"props_p956",1},{"props_p957",5},{"props_p958",2},{"userarena_point",1000},{"userexpedition_point",1000},{"equip_e1",2000}},
            },
            
            --单次应援奖池 
            singlePool={
                {100},
                {10,20,10,20,30,1,1,2,20,10,5,5,5},
                {{"props_p818",2},{"props_p956",3},{"props_p448",1},{"props_p959",3},{"props_p933",3},{"props_p3",1},{"props_p4820",1},{"props_p4824",1},{"props_p601",20},{"props_p960",2},{"props_p606",6},{"props_p607",3},{"props_p608",2}},
            },
            
        },
        rewardTb={
            --连续充值获得道具
            rechargeGet={p={{p3006=6},{p4748=1}}},
            --红蓝卡获得概率（100为底）
            cardGet={anv={{anv_a1=1},{anv_a2=1}}},
            career={
                --航海日志奖励1
                {p={{p5=1,index=1},{p2=5,index=2}}},
                
                --航海日志奖励2
                {p={{p17=3,index=1},{p18=3,index=2}}},
                
                --航海日志奖励3
                {p={{p4802=2,index=1}}},
                
                --航海日志奖励4
                {p={{p1=1,index=1}}},
                
                --航海日志奖励5
                {p={{p49=1,index=1}}},
                
            },
            gift={
                --应援奖励1
                {supportNeed=1000,gift={p={{p20=5,index=1},{p601=10,index=2}}}},
                
                --应援奖励2
                {supportNeed=3000,gift={p={{p4810=10,index=1},{p957=20,index=2}}}},
                
                --应援奖励3
                {supportNeed=6000,gift={p={{p819=10,index=1},{p956=10,index=2}}}},
                
                --应援奖励4
                {supportNeed=12000,gift={p={{p4811=20,index=1},{p958=10,index=2},{p959=10,index=3}}}},
                
                --应援奖励5
                {supportNeed=18000,gift={p={{p818=20,index=1},{p448=10,index=2},{p960=10,index=3}}}},
                
            },
            --单次充值超过X钻时奖励（每次充值都可领取）
            recharge1={p={{p601=5,index=1},{p4810=2,index=2}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={f={{e1=5000,index=2},{e2=1000,index=3},{e3=1000,index=4}},p={{p818=2,index=1}}},
            --回归奖励
            returnGet={o={{a10005=20,index=3},{a10015=20,index=4},{a10025=10,index=5},{a10035=10,index=6}},p={{p5=2,index=1},{p3=2,index=2}}},
            --召回奖励
            callbackGet={p={{p601=20,index=1},{p20=5,index=2},{p5=1,index=3}}},
            --回归玩家充值达到指定额度给召回玩家的奖励
            callrechargeGet={p={{p988=3,index=1},{p2=1,index=2}}},
            --分享奖励
            fbreward={p={{p818=2,index=1}},anv={{anv_a1=3,index=2},{anv_a2=1,index=3}}},
        },
    },
    [2]={
        sortid=223,
        type=1,
        --航海日志等级限制
        levelLimit=10,
        --红卡分享获得数量
        cardShare=2,
        --归回相关（回归玩家等级限制，回归玩家上次登陆时间间隔限制，回归玩家充值额度，召回奖励领取次数限制）
        returnLevel=30,
        lastLogin=30,
        returnRecharge=500,
        callbackGetLimit=5,
        callrechargeGetLimit=100,
        --应援相关
        supportScore=10,
        supportNeed={1000,3000,6000,12000,18000},
        --充值额度
        rechargeNum={268,1000},
        --连续充值天数需求
        rechargeDay=3,
        --连续充值获得道具
        serverreward={
            rechargeGet={{"props_p3006",6},{"props_p4749",1}},
            --红蓝卡获得概率（100为底）
            cardGet={
                {{"anv_a1",1},{"anv_a2",1}},
                --攻击基地获得概率
                {25,15},
                --攻击矿点获得概率
                {25,15},
            },
            --航海日志奖励1
            career1={{"props_p5",1},{"props_p2",5}},
            --航海日志奖励2
            career2={{"props_p17",3},{"props_p18",3}},
            --航海日志奖励3
            career3={{"props_p4802",2}},
            --航海日志奖励4
            career4={{"props_p1",1}},
            --航海日志奖励5
            career5={{"props_p49",1}},
            --应援奖励1
            gift1={{"props_p20",5},{"props_p601",10}},
            --应援奖励2
            gift2={{"props_p4810",10},{"props_p957",20}},
            --应援奖励3
            gift3={{"props_p819",10},{"props_p956",10}},
            --应援奖励4
            gift4={{"props_p4811",20},{"props_p958",10},{"props_p959",10}},
            --应援奖励5
            gift5={{"props_p818",20},{"props_p448",10},{"props_p960",10}},
            --单次充值超过X钻时奖励（每次充值都可领取）
            recharge1={{"props_p601",5},{"props_p4810",2}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"props_p818",2},{"equip_e1",5000},{"equip_e2",1000},{"equip_e3",1000}},
            --回归奖励
            returnGet={{"props_p5",2},{"props_p3",2},{"troops_a10005",20},{"troops_a10015",20},{"troops_a10025",10},{"troops_a10035",10}},
            --召回奖励
            callbackGet={{"props_p601",20},{"props_p20",5},{"props_p5",1}},
            --回归玩家充值达到指定额度给召回玩家的奖励
            callrechargeGet={{"props_p988",3},{"props_p2",1}},
            --分享奖励
            fbreward={{"props_p818",2},{"anv_a1",3},{"anv_a2",1}},
            --蓝卡奖池
            pool1={
                {100},
                {5,100,100,100,3,1,60,60,5,5,5,5},
                {{"anv_b1",1},{"anv_b2",1},{"anv_b3",1},{"anv_b4",1},{"props_p4824",1},{"props_p4820",1},{"props_p36",1},{"props_p35",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p2",1}},
            },
            
            --红卡奖池 
            pool2={
                {100},
                {60,2,2,2,30,10,30,30,15,20,20,20},
                {{"anv_b1",1},{"anv_b2",1},{"anv_b3",1},{"anv_b4",1},{"props_p819",1},{"props_p818",1},{"props_p956",1},{"props_p957",5},{"props_p958",2},{"userarena_point",1000},{"userexpedition_point",1000},{"equip_e1",2000}},
            },
            
            --单次应援奖池 
            singlePool={
                {100},
                {10,20,10,20,30,1,1,2,20,10,5,5,5},
                {{"props_p818",2},{"props_p956",3},{"props_p448",1},{"props_p959",3},{"props_p933",3},{"props_p3",1},{"props_p4820",1},{"props_p4824",1},{"props_p601",20},{"props_p960",2},{"props_p606",6},{"props_p607",3},{"props_p608",2}},
            },
            
        },
        rewardTb={
            --连续充值获得道具
            rechargeGet={p={{p3006=6},{p4749=1}}},
            --红蓝卡获得概率（100为底）
            cardGet={anv={{anv_a1=1},{anv_a2=1}}},
            career={
                --航海日志奖励1
                {p={{p5=1,index=1},{p2=5,index=2}}},
                
                --航海日志奖励2
                {p={{p17=3,index=1},{p18=3,index=2}}},
                
                --航海日志奖励3
                {p={{p4802=2,index=1}}},
                
                --航海日志奖励4
                {p={{p1=1,index=1}}},
                
                --航海日志奖励5
                {p={{p49=1,index=1}}},
                
            },
            gift={
                --应援奖励1
                {supportNeed=1000,gift={p={{p20=5,index=1},{p601=10,index=2}}}},
                
                --应援奖励2
                {supportNeed=3000,gift={p={{p4810=10,index=1},{p957=20,index=2}}}},
                
                --应援奖励3
                {supportNeed=6000,gift={p={{p819=10,index=1},{p956=10,index=2}}}},
                
                --应援奖励4
                {supportNeed=12000,gift={p={{p4811=20,index=1},{p958=10,index=2},{p959=10,index=3}}}},
                
                --应援奖励5
                {supportNeed=18000,gift={p={{p818=20,index=1},{p448=10,index=2},{p960=10,index=3}}}},
                
            },
            --单次充值超过X钻时奖励（每次充值都可领取）
            recharge1={p={{p601=5,index=1},{p4810=2,index=2}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={f={{e1=5000,index=2},{e2=1000,index=3},{e3=1000,index=4}},p={{p818=2,index=1}}},
            --回归奖励
            returnGet={o={{a10005=20,index=3},{a10015=20,index=4},{a10025=10,index=5},{a10035=10,index=6}},p={{p5=2,index=1},{p3=2,index=2}}},
            --召回奖励
            callbackGet={p={{p601=20,index=1},{p20=5,index=2},{p5=1,index=3}}},
            --回归玩家充值达到指定额度给召回玩家的奖励
            callrechargeGet={p={{p988=3,index=1},{p2=1,index=2}}},
            --分享奖励
            fbreward={p={{p818=2,index=1}},anv={{anv_a1=3,index=2},{anv_a2=1,index=3}}},
        },
    },
}

return anniversary2 
