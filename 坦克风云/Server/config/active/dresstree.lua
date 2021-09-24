local dresstree ={
    multiSelectType = true,
    [1]={
        sortid=227,
        type=1,
        --积分需求
        supportNeed={200,200,200},
        --三种道具积分提供
        getScore={5,6,7},
        --充值额度
        rechargeNum={268,2000},
        serverreward={
            --三种道具获得概率（100为底）
            candyGet={
                {{"dresstree_a1",1},{"dresstree_a2",1},{"dresstree_a3",1}},
                --攻击基地获得概率
                {0,0,20},
                --攻击矿点获得概率
                {0,35,0},
                --攻打关卡
                {50,0,0},
                --攻打剧情关卡
                {100,0,0},
                --攻打装备探索关卡
                {100,0,0},
            },
            --积分奖励1
            gift1={{"props_p19",30},{"props_p20",20},{"props_p3",1}},
            --积分奖励2
            gift2={{"props_p4852",5},{"equip_e1",2000},{"equip_e3",2000},{"equip_e2",2000}},
            --积分奖励3
            gift3={{"props_p275",5},{"props_p276",10},{"props_p277",50},{"props_p283",1},{"props_p279",5}},
            --大奖奖励
            gift4={{"troops_a10064",20},{"troops_a10074",20},{"troops_a10114",20},{"props_p3005",2}},
            --单次充值达到X钻时奖励
            recharge1={{"props_p3005",1},{"dresstree_a1",1},{"dresstree_a3",1}},
            --累计充值达到X钻时奖励（循环）
            recharge2={{"troops_a10074",5},{"props_p3005",3},{"dresstree_a2",3},{"dresstree_a3",3}},
            --fb分享奖励
            fbreward={{"props_p3005",1},{"dresstree_a1",1},{"dresstree_a2",1},{"dresstree_a3",1}},
            --兑换奖池1
            pool1={
                {100},
                {10,10,10,10,10,10,10},
                {{"props_p20",1},{"props_p19",3},{"props_p26",3},{"props_p27",3},{"props_p28",3},{"props_p29",3},{"props_p30",3}},
            },
            
            --兑换奖池2
            pool2={
                {100},
                {60,30,30,50,50,60,10},
                {{"equip_e1",500},{"equip_e2",500},{"equip_e3",500},{"props_p956",1},{"props_p601",3},{"props_p447",1},{"props_p818",1}},
            },
            
            --兑换奖池3
            pool3={
                {100},
                {50,50,50,50,50,1,2},
                {{"props_p275",1},{"props_p276",2},{"props_p277",10},{"props_p279",2},{"props_p282",1},{"props_p813",1},{"props_p815",1}},
            },
            
            --商店
            shopList={
                [1]={serverreward={"props_p817",50},price=200,limit=1,type=1},
                [2]={serverreward={"props_p3",1},price=200,limit=1,type=1},
                [3]={serverreward={"props_p818",2},price=100,limit=5,type=2},
                [4]={serverreward={"props_p956",5},price=100,limit=5,type=2},
                [5]={serverreward={"props_p277",50},price=100,limit=10,type=3},
                [6]={serverreward={"props_p283",1},price=100,limit=10,type=3},
            },
        },
        rewardTb={
            --三种道具获得概率（100为底）
            candyGet={dresstree={{dresstree_a1=1},{dresstree_a2=1},{dresstree_a3=1}}},
            gift={
                --积分奖励1
                {supportNeed=200,gift={p={{p19=30,index=1},{p20=20,index=2},{p3=1,index=3}}}},
                
                --积分奖励2
                {supportNeed=200,gift={f={{e1=2000,index=2},{e3=2000,index=2},{e2=2000,index=3}},p={{p4852=5,index=1}}}},
                
                --积分奖励3
                {supportNeed=200,gift={p={{p275=5,index=1},{p276=10,index=2},{p277=50,index=3},{p283=1,index=4},{p279=5,index=5}}}},
                
                --大奖奖励
                {supportNeed=0,gift={o={{a10064=20,index=1},{a10074=20,index=2},{a10114=20,index=3}},p={{p3005=2,index=4}}}},
                
            },
            --单次充值达到X钻时奖励
            recharge1={p={{p3005=1,index=1}},dresstree={{dresstree_a1=1,index=2},{dresstree_a3=1,index=3}}},
            --累计充值达到X钻时奖励（循环）
            recharge2={o={{a10074=5,index=1}},p={{p3005=3,index=2}},dresstree={{dresstree_a2=3,index=3},{dresstree_a3=3,index=4}}},
            --fb分享奖励
            fbreward={p={{p3005=1,index=1}},dresstree={{dresstree_a1=1,index=2},{dresstree_a2=1,index=3},{dresstree_a3=1,index=4}}},
            pool={
                --兑换奖池1
                {p={{p20=1,index=1},{p19=3,index=2},{p26=3,index=3},{p27=3,index=4},{p28=3,index=5},{p29=3,index=6},{p30=3,index=7}}},
                
                --兑换奖池2
                {f={{e1=500,index=1},{e2=500,index=2},{e3=500,index=3}},p={{p956=1,index=4},{p601=3,index=5},{p447=1,index=6},{p818=1,index=7}}},
                
                --兑换奖池3
                {p={{p275=1,index=1},{p276=2,index=2},{p277=10,index=3},{p279=2,index=5},{p282=1,index=6},{p813=1,index=7},{p815=1,index=8}}},
                
            },
            --商店
            shopList={
                {reward={p={p817=50}},index=1,price=200,limit=1,type=1},
                {reward={p={p3=1}},index=2,price=200,limit=1,type=1},
                {reward={p={p818=2}},index=3,price=100,limit=5,type=2},
                {reward={p={p956=5}},index=4,price=100,limit=5,type=2},
                {reward={p={p277=50}},index=5,price=100,limit=10,type=3},
                {reward={p={p283=1}},index=6,price=100,limit=10,type=3},
            },
        },
    },
}

return dresstree 
