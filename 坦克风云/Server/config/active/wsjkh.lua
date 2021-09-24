local wsjkh ={
    multiSelectType = true,
    [1]={
        sortid=227,
        type=1,
        --外观展现（1-万圣节，2-新版）
        appear=1,
        --糖果积分需求
        supportNeed={200,500,1000,2000,3000},
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --礼包价格
        cost=200,
        --充值额度
        rechargeNum=500,
        --礼包限购次数
        buyLimit=100,
        serverreward={
            --AB糖果获得概率（100为底）
            candyGet={
                {{"wsjkh_a1",1},{"wsjkh_a2",1}},
                --攻击基地获得概率
                {0,20},
                --攻击矿点获得概率
                {20,0},
                --攻打海盗
                {30,0},
                --攻打关卡
                {0,15},
                --攻打剧情关卡
                {0,30},
                --攻打装备探索关卡
                {0,30},
            },
            --糖果对应积分
            candyScore={wsjkh_a1=3,wsjkh_a2=3,wsjkh_a3=6,wsjkh_a4=10},
            --糖果积分奖励1
            gift1={{"props_p4852",1},{"props_p601",10},{"props_p957",10}},
            --糖果积分奖励2
            gift2={{"props_p275",4},{"props_p276",10}},
            --糖果积分奖励3
            gift3={{"props_p4852",3},{"props_p601",20},{"props_p958",10},{"props_p956",5}},
            --糖果积分奖励4
            gift4={{"props_p277",20},{"props_p282",2},{"props_p279",20},{"props_p278",2}},
            --糖果积分奖励5
            gift5={{"props_p4852",6},{"props_p601",30},{"props_p959",10}},
            --排行榜奖励1
            rank1={{"troops_a10083",30},{"troops_a10074",30},{"props_p4852",50}},
            --排行榜奖励2
            rank2={{"troops_a10083",20},{"troops_a10074",20},{"props_p4852",40}},
            --排行榜奖励3
            rank3={{"troops_a10083",10},{"troops_a10074",10},{"props_p4852",30}},
            --排行榜奖励4
            rank4={{"troops_a10082",15},{"troops_a10073",15},{"props_p4852",20}},
            --排行榜奖励5
            rank5={{"troops_a10082",10},{"troops_a10073",10},{"props_p4852",10}},
            --礼包内容
            recharge1={{"props_p4750",1},{"props_p601",20},{"props_p4852",2},{"wsjkh_a3",1}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"props_p3007",1},{"props_p956",1},{"props_p4852",2},{"wsjkh_a4",1}},
            --fb分享奖励
            fbreward={{"troops_a10082",3},{"wsjkh_a1",1},{"wsjkh_a2",1}},
            --糖果A奖池
            pool1={
                {100},
                {50,600,500,20,300,200},
                {{"props_p275",1},{"props_p276",1},{"props_p277",5},{"props_p278",1},{"props_p279",1},{"props_p281",2}},
            },
            
            --糖果B奖池
            pool2={
                {100},
                {20,90,90,30,30,30,10},
                {{"props_p4852",1},{"props_p601",2},{"props_p957",2},{"props_p958",1},{"props_p4810",1},{"props_p447",1},{"props_p956",1}},
            },
            
            --糖果C奖池
            pool3={
                {100},
                {1,50,50,60,20,20,20,20,20},
                {{"props_p4824",1},{"props_p279",3},{"props_p276",2},{"props_p277",8},{"props_p447",3},{"equip_e1",500},{"equip_e3",500},{"equip_e2",500},{"props_p959",2}},
            },
            
            --糖果D奖池
            pool4={
                {100},
                {1,10,60,60,10,20,20,20,30},
                {{"props_p4820",1},{"props_p278",1},{"props_p275",1},{"props_p282",1},{"props_p448",1},{"equip_e1",1000},{"userarena_point",1000},{"userexpedition_point",1000},{"props_p960",1}},
            },
            
        },
        rewardTb={
            --AB糖果获得概率（100为底）
            candyGet={wsjkh={{wsjkh_a1=1},{wsjkh_a2=1}}},
            --糖果对应积分
            candyScore={wsjkh={{wsjkh_a1=3},{wsjkh_a2=3},{wsjkh_a3=6},{wsjkh_a4=10}}},
            gift={
                --糖果积分奖励1
                {supportNeed=200,gift={p={{p4852=1,index=1},{p601=10,index=2},{p957=10,index=3}}}},
                
                --糖果积分奖励2
                {supportNeed=500,gift={p={{p275=4,index=1},{p276=10,index=2}}}},
                
                --糖果积分奖励3
                {supportNeed=1000,gift={p={{p4852=3,index=1},{p601=20,index=2},{p958=10,index=3},{p956=5,index=4}}}},
                
                --糖果积分奖励4
                {supportNeed=2000,gift={p={{p277=20,index=1},{p282=2,index=2},{p279=20,index=3},{p278=2,index=4}}}},
                
                --糖果积分奖励5
                {supportNeed=3000,gift={p={{p4852=6,index=1},{p601=30,index=2},{p959=10,index=3}}}},
                
            },
            rank={
                --排行榜奖励1
                {o={{a10083=30,index=1},{a10074=30,index=2}},p={{p4852=50,index=3}}},
                
                --排行榜奖励2
                {o={{a10083=20,index=1},{a10074=20,index=2}},p={{p4852=40,index=3}}},
                
                --排行榜奖励3
                {o={{a10083=10,index=1},{a10074=10,index=2}},p={{p4852=30,index=3}}},
                
                --排行榜奖励4
                {o={{a10082=15,index=1},{a10073=15,index=2}},p={{p4852=20,index=3}}},
                
                --排行榜奖励5
                {o={{a10082=10,index=1},{a10073=10,index=2}},p={{p4852=10,index=3}}},
                
            },
            --礼包内容
            recharge1={p={{p4750=1,index=1},{p601=20,index=2},{p4852=2,index=3}},wsjkh={{wsjkh_a3=1,index=4}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={p={{p3007=1,index=1},{p956=1,index=2},{p4852=2,index=3}},wsjkh={{wsjkh_a4=1,index=4}}},
            --fb分享奖励
            fbreward={o={{a10082=3,index=1}},wsjkh={{wsjkh_a1=1,index=2},{wsjkh_a2=1,index=3}}},
            pool={
                --糖果A奖池
                {p={{p275=1,index=1},{p276=1,index=2},{p277=5,index=3},{p278=1,index=4},{p279=1,index=5},{p281=2,index=6}}},
                
                --糖果B奖池
                {p={{p4852=1,index=1},{p601=2,index=2},{p957=2,index=3},{p958=1,index=4},{p4810=1,index=5},{p447=1,index=6},{p956=1,index=7}}},
                
                --糖果C奖池
                {f={{e1=500,index=6},{e3=500,index=7},{e2=500,index=8}},p={{p4824=1,index=1},{p279=3,index=2},{p276=2,index=3},{p277=8,index=4},{p447=3,index=5},{p959=2,index=9}}},
                
                --糖果D奖池
                {f={{e1=1000,index=6}},m={{p=1000,index=7}},n={{p=1000,index=8}},p={{p4820=1,index=1},{p278=1,index=2},{p275=1,index=3},{p282=1,index=4},{p448=1,index=5},{p960=1,index=9}}},
                
            },
        },
    },
    [2]={
        sortid=227,
        type=1,
        --外观展现（1-万圣节，2-新版）
        appear=1,
        --糖果积分需求
        supportNeed={200,500,1000,2000,3000},
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --礼包价格
        cost=200,
        --充值额度
        rechargeNum=500,
        --礼包限购次数
        buyLimit=100,
        serverreward={
            --AB糖果获得概率（100为底）
            candyGet={
                {{"wsjkh_a1",1},{"wsjkh_a2",1}},
                --攻击基地获得概率
                {0,20},
                --攻击矿点获得概率
                {20,0},
                --攻打海盗
                {30,0},
                --攻打关卡
                {0,15},
                --攻打剧情关卡
                {0,30},
                --攻打装备探索关卡
                {0,30},
            },
            --糖果对应积分
            candyScore={wsjkh_a1=3,wsjkh_a2=3,wsjkh_a3=6,wsjkh_a4=10},
            --糖果积分奖励1
            gift1={{"props_p4852",1},{"props_p601",10},{"props_p957",10}},
            --糖果积分奖励2
            gift2={{"props_p275",4},{"props_p276",10}},
            --糖果积分奖励3
            gift3={{"props_p4852",3},{"props_p601",20},{"props_p958",10},{"props_p956",5}},
            --糖果积分奖励4
            gift4={{"props_p277",20},{"props_p282",2},{"props_p279",20},{"props_p278",2}},
            --糖果积分奖励5
            gift5={{"props_p4852",6},{"props_p601",30},{"props_p959",10}},
            --排行榜奖励1
            rank1={{"troops_a10083",30},{"troops_a10074",30},{"props_p4852",50}},
            --排行榜奖励2
            rank2={{"troops_a10083",20},{"troops_a10074",20},{"props_p4852",40}},
            --排行榜奖励3
            rank3={{"troops_a10083",10},{"troops_a10074",10},{"props_p4852",30}},
            --排行榜奖励4
            rank4={{"troops_a10082",15},{"troops_a10073",15},{"props_p4852",20}},
            --排行榜奖励5
            rank5={{"troops_a10082",10},{"troops_a10073",10},{"props_p4852",10}},
            --礼包内容
            recharge1={{"props_p4750",1},{"props_p601",20},{"props_p4852",2},{"wsjkh_a3",1}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"props_p3007",1},{"props_p956",1},{"props_p4852",2},{"wsjkh_a4",1}},
            --fb分享奖励
            fbreward={{"troops_a10082",3},{"wsjkh_a1",1},{"wsjkh_a2",1}},
            --糖果A奖池
            pool1={
                {100},
                {50,600,500,20,300,200},
                {{"props_p275",1},{"props_p276",1},{"props_p277",5},{"props_p278",1},{"props_p279",1},{"props_p281",2}},
            },
            
            --糖果B奖池
            pool2={
                {100},
                {20,90,90,30,30,30,10},
                {{"props_p4852",1},{"props_p601",2},{"props_p957",2},{"props_p958",1},{"props_p4810",1},{"props_p447",1},{"props_p956",1}},
            },
            
            --糖果C奖池
            pool3={
                {100},
                {1,10,60,60,10,20,20,20,30},
                {{"troops_a10043",2},{"troops_a10053",2},{"troops_a10063",2},{"troops_a10073",2},{"troops_a10082",2},{"troops_a10093",2},{"troops_a10113",2},{"troops_a10123",2},{"troops_a20153",2}},
            },
            
            --糖果D奖池
            pool4={
                {100},
                {1,10,60,60,10,20,20,20,30},
                {{"troops_a10044",1},{"troops_a10054",1},{"troops_a10064",1},{"troops_a10074",1},{"troops_a10083",1},{"troops_a10094",1},{"troops_a10114",1},{"troops_a10124",1},{"troops_a20154",1}},
            },
            
        },
        rewardTb={
            --AB糖果获得概率（100为底）
            candyGet={wsjkh={{wsjkh_a1=1},{wsjkh_a2=1}}},
            --糖果对应积分
            candyScore={wsjkh={{wsjkh_a1=3},{wsjkh_a2=3},{wsjkh_a3=6},{wsjkh_a4=10}}},
            gift={
                --糖果积分奖励1
                {supportNeed=200,gift={p={{p4852=1,index=1},{p601=10,index=2},{p957=10,index=3}}}},
                
                --糖果积分奖励2
                {supportNeed=500,gift={p={{p275=4,index=1},{p276=10,index=2}}}},
                
                --糖果积分奖励3
                {supportNeed=1000,gift={p={{p4852=3,index=1},{p601=20,index=2},{p958=10,index=3},{p956=5,index=4}}}},
                
                --糖果积分奖励4
                {supportNeed=2000,gift={p={{p277=20,index=1},{p282=2,index=2},{p279=20,index=3},{p278=2,index=4}}}},
                
                --糖果积分奖励5
                {supportNeed=3000,gift={p={{p4852=6,index=1},{p601=30,index=2},{p959=10,index=3}}}},
                
            },
            rank={
                --排行榜奖励1
                {o={{a10083=30,index=1},{a10074=30,index=2}},p={{p4852=50,index=3}}},
                
                --排行榜奖励2
                {o={{a10083=20,index=1},{a10074=20,index=2}},p={{p4852=40,index=3}}},
                
                --排行榜奖励3
                {o={{a10083=10,index=1},{a10074=10,index=2}},p={{p4852=30,index=3}}},
                
                --排行榜奖励4
                {o={{a10082=15,index=1},{a10073=15,index=2}},p={{p4852=20,index=3}}},
                
                --排行榜奖励5
                {o={{a10082=10,index=1},{a10073=10,index=2}},p={{p4852=10,index=3}}},
                
            },
            --礼包内容
            recharge1={p={{p4750=1,index=1},{p601=20,index=2},{p4852=2,index=3}},wsjkh={{wsjkh_a3=1,index=4}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={p={{p3007=1,index=1},{p956=1,index=2},{p4852=2,index=3}},wsjkh={{wsjkh_a4=1,index=4}}},
            --fb分享奖励
            fbreward={o={{a10082=3,index=1}},wsjkh={{wsjkh_a1=1,index=2},{wsjkh_a2=1,index=3}}},
            pool={
                --糖果A奖池
                {p={{p275=1,index=1},{p276=1,index=2},{p277=5,index=3},{p278=1,index=4},{p279=1,index=5},{p281=2,index=6}}},
                
                --糖果B奖池
                {p={{p4852=1,index=1},{p601=2,index=2},{p957=2,index=3},{p958=1,index=4},{p4810=1,index=5},{p447=1,index=6},{p956=1,index=7}}},
                
                --糖果C奖池
                {o={{a10043=2,index=1},{a10053=2,index=2},{a10063=2,index=3},{a10073=2,index=4},{a10082=2,index=5},{a10093=2,index=6},{a10113=2,index=7},{a10123=2,index=8},{a20153=2,index=9}}},
                
                --糖果D奖池
                {o={{a10044=1,index=1},{a10054=1,index=2},{a10064=1,index=3},{a10074=1,index=4},{a10083=1,index=5},{a10094=1,index=6},{a10114=1,index=7},{a10124=1,index=8},{a20154=1,index=9}}},
                
            },
        },
    },
    [3]={
        sortid=227,
        type=1,
        --外观展现（1-万圣节，2-新版）
        appear=2,
        --糖果积分需求
        supportNeed={200,500,1000,2000,3000},
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --礼包价格
        cost=200,
        --充值额度
        rechargeNum=500,
        --礼包限购次数
        buyLimit=100,
        serverreward={
            --AB糖果获得概率（100为底）
            candyGet={
                {{"wsjkh_a1",1},{"wsjkh_a2",1}},
                --攻击基地获得概率
                {0,20},
                --攻击矿点获得概率
                {20,0},
                --攻打海盗
                {30,0},
                --攻打关卡
                {0,15},
                --攻打剧情关卡
                {0,30},
                --攻打装备探索关卡
                {0,30},
            },
            --糖果对应积分
            candyScore={wsjkh_a1=3,wsjkh_a2=3,wsjkh_a3=6,wsjkh_a4=10},
            --糖果积分奖励1
            gift1={{"props_p4852",1},{"props_p601",10},{"props_p957",10}},
            --糖果积分奖励2
            gift2={{"props_p275",4},{"props_p276",10}},
            --糖果积分奖励3
            gift3={{"props_p4852",3},{"props_p601",20},{"props_p958",10},{"props_p956",5}},
            --糖果积分奖励4
            gift4={{"props_p277",20},{"props_p282",2},{"props_p279",20},{"props_p278",2}},
            --糖果积分奖励5
            gift5={{"props_p4852",6},{"props_p601",30},{"props_p959",10}},
            --排行榜奖励1
            rank1={{"troops_a10083",30},{"troops_a10074",30},{"props_p4852",50}},
            --排行榜奖励2
            rank2={{"troops_a10083",20},{"troops_a10074",20},{"props_p4852",40}},
            --排行榜奖励3
            rank3={{"troops_a10083",10},{"troops_a10074",10},{"props_p4852",30}},
            --排行榜奖励4
            rank4={{"troops_a10082",15},{"troops_a10073",15},{"props_p4852",20}},
            --排行榜奖励5
            rank5={{"troops_a10082",10},{"troops_a10073",10},{"props_p4852",10}},
            --礼包内容
            recharge1={{"props_p4739",1},{"props_p601",20},{"props_p4852",2},{"wsjkh_a3",1}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"props_p3003",1},{"props_p956",1},{"props_p4852",2},{"wsjkh_a4",1}},
            --fb分享奖励
            fbreward={{"troops_a10082",3},{"wsjkh_a1",1},{"wsjkh_a2",1}},
            --糖果A奖池
            pool1={
                {100},
                {50,600,500,20,300,200},
                {{"props_p275",1},{"props_p276",1},{"props_p277",5},{"props_p278",1},{"props_p279",1},{"props_p281",2}},
            },
            
            --糖果B奖池
            pool2={
                {100},
                {20,90,90,30,30,30,10},
                {{"props_p4852",1},{"props_p601",2},{"props_p957",2},{"props_p958",1},{"props_p4810",1},{"props_p447",1},{"props_p956",1}},
            },
            
            --糖果C奖池
            pool3={
                {100},
                {1,50,50,60,20,20,20,20,20},
                {{"props_p4824",1},{"props_p279",3},{"props_p276",2},{"props_p277",8},{"props_p447",3},{"equip_e1",500},{"equip_e3",500},{"equip_e2",500},{"props_p959",2}},
            },
            
            --糖果D奖池
            pool4={
                {100},
                {1,10,60,60,10,20,20,20,30},
                {{"props_p4820",1},{"props_p278",1},{"props_p275",1},{"props_p282",1},{"props_p448",1},{"equip_e1",1000},{"userarena_point",1000},{"userexpedition_point",1000},{"props_p960",1}},
            },
            
        },
        rewardTb={
            --AB糖果获得概率（100为底）
            candyGet={wsjkh={{wsjkh_a1=1},{wsjkh_a2=1}}},
            --糖果对应积分
            candyScore={wsjkh={{wsjkh_a1=3},{wsjkh_a2=3},{wsjkh_a3=6},{wsjkh_a4=10}}},
            gift={
                --糖果积分奖励1
                {supportNeed=200,gift={p={{p4852=1,index=1},{p601=10,index=2},{p957=10,index=3}}}},
                
                --糖果积分奖励2
                {supportNeed=500,gift={p={{p275=4,index=1},{p276=10,index=2}}}},
                
                --糖果积分奖励3
                {supportNeed=1000,gift={p={{p4852=3,index=1},{p601=20,index=2},{p958=10,index=3},{p956=5,index=4}}}},
                
                --糖果积分奖励4
                {supportNeed=2000,gift={p={{p277=20,index=1},{p282=2,index=2},{p279=20,index=3},{p278=2,index=4}}}},
                
                --糖果积分奖励5
                {supportNeed=3000,gift={p={{p4852=6,index=1},{p601=30,index=2},{p959=10,index=3}}}},
                
            },
            rank={
                --排行榜奖励1
                {o={{a10083=30,index=1},{a10074=30,index=2}},p={{p4852=50,index=3}}},
                
                --排行榜奖励2
                {o={{a10083=20,index=1},{a10074=20,index=2}},p={{p4852=40,index=3}}},
                
                --排行榜奖励3
                {o={{a10083=10,index=1},{a10074=10,index=2}},p={{p4852=30,index=3}}},
                
                --排行榜奖励4
                {o={{a10082=15,index=1},{a10073=15,index=2}},p={{p4852=20,index=3}}},
                
                --排行榜奖励5
                {o={{a10082=10,index=1},{a10073=10,index=2}},p={{p4852=10,index=3}}},
                
            },
            --礼包内容
            recharge1={p={{p4739=1,index=1},{p601=20,index=2},{p4852=2,index=3}},wsjkh={{wsjkh_a3=1,index=4}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={p={{p3003=1,index=1},{p956=1,index=2},{p4852=2,index=3}},wsjkh={{wsjkh_a4=1,index=4}}},
            --fb分享奖励
            fbreward={o={{a10082=3,index=1}},wsjkh={{wsjkh_a1=1,index=2},{wsjkh_a2=1,index=3}}},
            pool={
                --糖果A奖池
                {p={{p275=1,index=1},{p276=1,index=2},{p277=5,index=3},{p278=1,index=4},{p279=1,index=5},{p281=2,index=6}}},
                
                --糖果B奖池
                {p={{p4852=1,index=1},{p601=2,index=2},{p957=2,index=3},{p958=1,index=4},{p4810=1,index=5},{p447=1,index=6},{p956=1,index=7}}},
                
                --糖果C奖池
                {f={{e1=500,index=6},{e3=500,index=7},{e2=500,index=8}},p={{p4824=1,index=1},{p279=3,index=2},{p276=2,index=3},{p277=8,index=4},{p447=3,index=5},{p959=2,index=9}}},
                
                --糖果D奖池
                {f={{e1=1000,index=6}},m={{p=1000,index=7}},n={{p=1000,index=8}},p={{p4820=1,index=1},{p278=1,index=2},{p275=1,index=3},{p282=1,index=4},{p448=1,index=5},{p960=1,index=9}}},
                
            },
        },
    },
    [4]={
        sortid=227,
        type=1,
        --外观展现（1-万圣节，2-新版）
        appear=2,
        --糖果积分需求
        supportNeed={200,500,1000,2000,3000},
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --礼包价格
        cost=200,
        --充值额度
        rechargeNum=500,
        --礼包限购次数
        buyLimit=100,
        serverreward={
            --AB糖果获得概率（100为底）
            candyGet={
                {{"wsjkh_a1",1},{"wsjkh_a2",1}},
                --攻击基地获得概率
                {0,20},
                --攻击矿点获得概率
                {20,0},
                --攻打海盗
                {30,0},
                --攻打关卡
                {0,15},
                --攻打剧情关卡
                {0,30},
                --攻打装备探索关卡
                {0,30},
            },
            --糖果对应积分
            candyScore={wsjkh_a1=3,wsjkh_a2=3,wsjkh_a3=6,wsjkh_a4=10},
            --糖果积分奖励1
            gift1={{"props_p4852",1},{"props_p601",10},{"props_p957",10}},
            --糖果积分奖励2
            gift2={{"props_p275",4},{"props_p276",10}},
            --糖果积分奖励3
            gift3={{"props_p4852",3},{"props_p601",20},{"props_p958",10},{"props_p956",5}},
            --糖果积分奖励4
            gift4={{"props_p277",20},{"props_p282",2},{"props_p279",20},{"props_p278",2}},
            --糖果积分奖励5
            gift5={{"props_p4852",6},{"props_p601",30},{"props_p959",10}},
            --排行榜奖励1
            rank1={{"troops_a20154",30},{"troops_a10124",30},{"props_p4852",50}},
            --排行榜奖励2
            rank2={{"troops_a20154",20},{"troops_a10124",20},{"props_p4852",40}},
            --排行榜奖励3
            rank3={{"troops_a20154",10},{"troops_a10124",10},{"props_p4852",30}},
            --排行榜奖励4
            rank4={{"troops_a20153",15},{"troops_a10123",15},{"props_p4852",20}},
            --排行榜奖励5
            rank5={{"troops_a20153",10},{"troops_a10123",10},{"props_p4852",10}},
            --礼包内容
            recharge1={{"props_p4852",2},{"props_p601",20},{"props_p959",1},{"wsjkh_a3",1}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"props_p4852",2},{"props_p956",1},{"props_p448",1},{"wsjkh_a4",1}},
            --fb分享奖励
            fbreward={{"troops_a20153",3},{"wsjkh_a1",1},{"wsjkh_a2",1}},
            --糖果A奖池
            pool1={
                {100},
                {50,600,500,20,300,200},
                {{"props_p275",1},{"props_p276",1},{"props_p277",5},{"props_p278",1},{"props_p279",1},{"props_p281",2}},
            },
            
            --糖果B奖池
            pool2={
                {100},
                {20,90,90,30,30,30,10},
                {{"props_p4852",1},{"props_p601",2},{"props_p957",2},{"props_p958",1},{"props_p4810",1},{"props_p447",1},{"props_p956",1}},
            },
            
            --糖果C奖池
            pool3={
                {100},
                {1,50,50,60,20,20,20,20,20},
                {{"props_p4824",1},{"props_p279",3},{"props_p276",2},{"props_p277",8},{"props_p447",3},{"equip_e1",500},{"equip_e3",500},{"equip_e2",500},{"props_p959",2}},
            },
            
            --糖果D奖池
            pool4={
                {100},
                {1,10,60,60,10,20,20,20,30},
                {{"props_p4820",1},{"props_p278",1},{"props_p275",1},{"props_p282",1},{"props_p448",1},{"equip_e1",1000},{"userarena_point",1000},{"userexpedition_point",1000},{"props_p960",1}},
            },
            
        },
        rewardTb={
            --AB糖果获得概率（100为底）
            candyGet={wsjkh={{wsjkh_a1=1},{wsjkh_a2=1}}},
            --糖果对应积分
            candyScore={wsjkh={{wsjkh_a1=3},{wsjkh_a2=3},{wsjkh_a3=6},{wsjkh_a4=10}}},
            gift={
                --糖果积分奖励1
                {supportNeed=200,gift={p={{p4852=1,index=1},{p601=10,index=2},{p957=10,index=3}}}},
                
                --糖果积分奖励2
                {supportNeed=500,gift={p={{p275=4,index=1},{p276=10,index=2}}}},
                
                --糖果积分奖励3
                {supportNeed=1000,gift={p={{p4852=3,index=1},{p601=20,index=2},{p958=10,index=3},{p956=5,index=4}}}},
                
                --糖果积分奖励4
                {supportNeed=2000,gift={p={{p277=20,index=1},{p282=2,index=2},{p279=20,index=3},{p278=2,index=4}}}},
                
                --糖果积分奖励5
                {supportNeed=3000,gift={p={{p4852=6,index=1},{p601=30,index=2},{p959=10,index=3}}}},
                
            },
            rank={
                --排行榜奖励1
                {o={{a20154=30,index=1},{a10124=30,index=2}},p={{p4852=50,index=3}}},
                
                --排行榜奖励2
                {o={{a20154=20,index=1},{a10124=20,index=2}},p={{p4852=40,index=3}}},
                
                --排行榜奖励3
                {o={{a20154=10,index=1},{a10124=10,index=2}},p={{p4852=30,index=3}}},
                
                --排行榜奖励4
                {o={{a20153=15,index=1},{a10123=15,index=2}},p={{p4852=20,index=3}}},
                
                --排行榜奖励5
                {o={{a20153=10,index=1},{a10123=10,index=2}},p={{p4852=10,index=3}}},
                
            },
            --礼包内容
            recharge1={p={{p4852=2,index=1},{p601=20,index=2},{p959=1,index=3}},wsjkh={{wsjkh_a3=1,index=4}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={p={{p4852=2,index=1},{p956=1,index=2},{p448=1,index=3}},wsjkh={{wsjkh_a4=1,index=4}}},
            --fb分享奖励
            fbreward={o={{a20153=3,index=1}},wsjkh={{wsjkh_a1=1,index=2},{wsjkh_a2=1,index=3}}},
            pool={
                --糖果A奖池
                {p={{p275=1,index=1},{p276=1,index=2},{p277=5,index=3},{p278=1,index=4},{p279=1,index=5},{p281=2,index=6}}},
                
                --糖果B奖池
                {p={{p4852=1,index=1},{p601=2,index=2},{p957=2,index=3},{p958=1,index=4},{p4810=1,index=5},{p447=1,index=6},{p956=1,index=7}}},
                
                --糖果C奖池
                {f={{e1=500,index=6},{e3=500,index=7},{e2=500,index=8}},p={{p4824=1,index=1},{p279=3,index=2},{p276=2,index=3},{p277=8,index=4},{p447=3,index=5},{p959=2,index=9}}},
                
                --糖果D奖池
                {f={{e1=1000,index=6}},m={{p=1000,index=7}},n={{p=1000,index=8}},p={{p4820=1,index=1},{p278=1,index=2},{p275=1,index=3},{p282=1,index=4},{p448=1,index=5},{p960=1,index=9}}},
                
            },
        },
    },
}

return wsjkh 
