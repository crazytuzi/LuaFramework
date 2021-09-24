local thanksgiving ={
    multiSelectType = true,
    [1]={
        sortid=227,
        type=1,
        --积分需求
        supportNeed={10,30,50,70,100},
        --充值额度
        rechargeNum={268,2000},
        serverreward={
            --三种道具获得概率（100为底）
            candyGet={
                {{"thank_a1",1},{"thank_a2",1},{"thank_a3",1}},
                --攻击基地获得概率
                {80,0,40},
                --攻击矿点获得概率
                {80,0,40},
                --攻打海盗
                {0,0,0},
                --攻打关卡
                {80,0,40},
                --攻打剧情关卡
                {100,0,80},
                --攻打装备探索关卡
                {100,0,80},
                --攻打补给线
                {80,0,40},
                --完成每日任务
                {0,100,0},
            },
            --兑换1
            exchange1={thank_a1=1,thank_a2=1},
            --兑换2
            exchange2={thank_a1=1,thank_a3=1},
            --积分奖励1
            gift1={{"props_p275",3},{"props_p276",6}},
            --积分奖励2
            gift2={{"props_p4852",3},{"equip_e3",1000},{"equip_e2",1000}},
            --积分奖励3
            gift3={{"props_p277",10},{"props_p282",1},{"props_p279",20},{"props_p278",1}},
            --积分奖励4
            gift4={{"props_p4852",5},{"equip_e1",2000},{"equip_e3",2000},{"equip_e2",2000}},
            --积分奖励5
            gift5={{"props_p4852",10},{"troops_a20154",10}},
            --单次充值达到X钻时奖励
            recharge1={{"props_p837",2},{"props_p875",2},{"thank_a3",1}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"troops_a10124",3},{"troops_a20154",3},{"thank_a3",2}},
            --兑换奖池1
            pool1={
                {100},
                {50,600,500,20,300,200},
                {{"props_p275",1},{"props_p276",1},{"props_p277",5},{"props_p278",1},{"props_p279",1},{"props_p281",2}},
            },
            
            --兑换奖池2
            pool2={
                {100},
                {60,50,50,50,30,60},
                {{"equip_e1",500},{"equip_e2",500},{"equip_e3",500},{"armor_exp",500},{"aweapon_exp",500},{"props_p447",1}},
            },
            
        },
        rewardTb={
            --三种道具获得概率（100为底）
            candyGet={thank={{thank_a1=1,index=1},{thank_a2=1,index=2},{thank_a3=1,index=3}}},
            --兑换1
            exchange1={thank={{thank_a1=1},{thank_a2=1}}},
            --兑换2
            exchange2={thank={{thank_a1=1},{thank_a3=1}}},
            gift={
                --积分奖励1
                {supportNeed=10,gift={p={{p275=3,index=1},{p276=6,index=2}}}},
                
                --积分奖励2
                {supportNeed=30,gift={f={{e3=1000,index=2},{e2=1000,index=3}},p={{p4852=3,index=1}}}},
                
                --积分奖励3
                {supportNeed=50,gift={p={{p277=10,index=1},{p282=1,index=2},{p279=20,index=3},{p278=1,index=4}}}},
                
                --积分奖励4
                {supportNeed=70,gift={f={{e1=2000,index=2},{e3=2000,index=2},{e2=2000,index=3}},p={{p4852=5,index=1}}}},
                
                --积分奖励5
                {supportNeed=100,gift={o={{a20154=10,index=2}},p={{p4852=10,index=1}}}},
                
            },
            --单次充值达到X钻时奖励
            recharge1={p={{p837=2,index=1},{p875=2,index=2}},thank={{thank_a3=1,index=4}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={o={{a10124=3,index=1},{a20154=3,index=2}},thank={{thank_a3=2,index=4}}},
            pool={
                --兑换奖池1
                {p={{p275=1,index=1},{p276=1,index=2},{p277=5,index=3},{p278=1,index=4},{p279=1,index=5},{p281=2,index=6}}},
                
                --兑换奖池2
                {f={{e1=500,index=1},{e2=500,index=2},{e3=500,index=3}},p={{p447=1,index=6}},am={{exp=500,index=4}},aw={{exp=500,index=5}}},
                
            },
        },
    },
}

return thanksgiving 
