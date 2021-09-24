local dragonboat={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --单抽价格（单倍，五倍）
        cost1={58,270},
        --全选价格（单倍，五倍）
        cost2={220,1040},
        --选中概率
        winRate=0.2,
        --未抽中增长概率
        increaseRate=0.05,
        serverreward={
            --兑换道具
            itemNeed={"dragonboat_a1"},
            --选错奖池
            pool1={
                {100},
                {10,10,20,20,20,10,10,10,10},
                {{"hero_s6",2},{"hero_s16",2},{"equip_e1",300},{"equip_e2",300},{"equip_e3",300},{"props_p933",1},{"props_p469",1},{"props_p470",1},{"props_p471",1}},
                score={5,5,5,5,5,5,5,5,5},
            },
            --选对奖池
            pool2={
                {100},
                {10,10,10,20,3,20,20,20,20},
                {{"hero_s14",5},{"hero_s15",5},{"hero_s24",5},{"equip_e1",2000},{"props_p481",1},{"props_p4852",2},{"props_p472",5},{"props_p473",5},{"props_p474",5}},
                score={30,30,30,30,30,30,30,30,30},
            },
            --商店
            shopList={
                [1]={serverreward={props_p4913=20},price=350,limit=3},
                [2]={serverreward={props_p4900=1},price=350,limit=3},
                [3]={serverreward={props_p481=1},price=150,limit=3},
                [4]={serverreward={props_p4810=5},price=20,limit=50},
                [5]={serverreward={props_p4811=3},price=30,limit=50},
                [6]={serverreward={props_p4812=2},price=40,limit=50},
            },
        },
        rewardTb={
            --兑换道具
            itemNeed={"dragonboat_a1"},
            --选错奖池
            pool1={f={{e1=300,index=3},{e2=300,index=4},{e3=300,index=5}},h={{s6=2,index=1},{s16=2,index=2}},p={{p933=1,index=6},{p469=1,index=7},{p470=1,index=8},{p471=1,index=9}}},
            
            --选对奖池
            pool2={f={{e1=2000,index=4}},h={{s14=5,index=1},{s15=5,index=2},{s24=5,index=3}},p={{p481=1,index=5},{p4852=2,index=6},{p472=5,index=7},{p473=5,index=8},{p474=5,index=9}}},
            
            --商店
            shopList={
                {reward={p={p4913=20}},index=1,price=350,limit=3},
                {reward={p={p4900=1}},index=2,price=350,limit=3},
                {reward={p={p481=1}},index=3,price=150,limit=3},
                {reward={p={p4810=5}},index=4,price=20,limit=50},
                {reward={p={p4811=3}},index=5,price=30,limit=50},
                {reward={p={p4812=2}},index=6,price=40,limit=50},
                
            },
        },
    },
}

return dragonboat
