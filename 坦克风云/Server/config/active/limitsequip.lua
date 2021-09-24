local limitsequip ={
    multiSelectType = true,
    [1]={
        --每次抽奖
        cost=168,
        --十连抽价格
        cost2=1596,
        -- 9 ★ 级到了 必给装备
        mustGetSuperEquip={sequip_e112=1,},
        getSuperEquip={e112=1,},
        --幸运值阈值
        luckyLimit={17,25,30,35,45,55,68,80,100,},
        luckyValue={1,1,1,1,1,1,1,1,1,1,1,1,1},
        serverreward ={
            --奖池
            pool={
                {100},
                {15,12,10,14,12,20,13,16,12,12,12,19,19},
                {{"props_p36",1,},{"props_p4003",2,},{"props_p4004",2,},{"props_p4004",1,},{"props_p4001",50,},{"props_p4001",100,},{"props_p4001",180,},{"props_p19",4,},{"props_p19",8,},{"props_p3",1,},{"props_p20",2,},{"sp_s1",2,},{"sp_s1",5,}},
            },
            
            starRate ={0.07,0.055,0.04,0.03,0.024,0.02,0.016,0.013,0.011,},
        },
        showList={p={{sp_s1=5,index=1},{sp_s1=2,index=2},{p4004=2,index=3},{p4004=1,index=4},{p4003=2,index=6},{p4001=180,index=7},{p4001=100,index=8},{p4001=50,index=9},{p19=8,index=10},{p19=4,index=11},{p20=2,index=12},{p3=1,index=13},{p36=1,index=13}}},    --前台展示列表
        
        exchange={
            {id=1,maxLimit=1,price={sp_s1=330},reward={se2={e111_3=1},},serverReward={sequip_e111_3=1},},
            {id=2,maxLimit=1,price={sp_s1=60},reward={p={p4007=1},},serverReward={props_p4007=1},},
            {id=3,maxLimit=1,price={sp_s1=45},reward={se2={e822=1},},serverReward={sequip_e822=1},},
            {id=4,maxLimit=10,price={sp_s1=30},reward={p={p4002=1},},serverReward={props_p4002=1},},
            {id=5,maxLimit=10,price={sp_s1=15},reward={p={p1=1},},serverReward={props_p1=1},},
            {id=6,maxLimit=5,price={sp_s1=12},reward={p={p4005=1},},serverReward={props_p4005=1},},
            {id=7,maxLimit=10,price={sp_s1=3},reward={p={p4004=1},},serverReward={props_p4004=1},},
            {id=8,maxLimit=50,price={sp_s1=2},reward={p={p4003=3},},serverReward={props_p4003=3},},
            {id=9,maxLimit=50,price={sp_s1=5},reward={p={p20=6},},serverReward={props_p20=6},},
            {id=10,maxLimit=100,price={sp_s1=4},reward={p={p2=1},},serverReward={props_p2=1},},
        },
    },
    [2]={
        --每次抽奖
        cost=168,
        --十连抽价格
        cost2=1596,
        -- 9 ★ 级到了 必给装备
        mustGetSuperEquip={sequip_e121=1,},
        getSuperEquip={e121=1,},
        --幸运值阈值
        luckyLimit={18,22,28,37,45,53,62,80,94,},
        luckyValue={1,1,1,1,1,1,1,1,1,1,1,1,1},
        serverreward ={
            --奖池
            pool={
                {100},
                {16,12,10,14,12,20,13,16,12,12,12,19,19},
                {{"props_p36",1,},{"props_p4003",1,},{"props_p4004",2,},{"props_p4004",1,},{"props_p4001",25,},{"props_p4001",50,},{"props_p4001",150,},{"props_p19",1,},{"props_p19",3,},{"props_p3",1,},{"props_p20",2,},{"sp_s1",2,},{"sp_s1",4,}},
            },
            
            starRate ={0.07,0.055,0.04,0.03,0.024,0.02,0.017,0.013,0.011,},
        },
        showList={p={{sp_s1=4,index=1},{sp_s1=2,index=2},{p4004=2,index=3},{p4004=1,index=4},{p4003=1,index=5},{p4001=150,index=6},{p4001=50,index=7},{p4001=25,index=8},{p19=3,index=9},{p19=1,index=10},{p20=2,index=11},{p3=1,index=12},{p36=1,index=13}}},    --前台展示列表
        
        exchange={
            {id=1,maxLimit=1,price={sp_s1=330},reward={se2={e111_3=1},},serverReward={sequip_e111_3=1},},
            {id=2,maxLimit=1,price={sp_s1=60},reward={p={p4007=1},},serverReward={props_p4007=1},},
            {id=3,maxLimit=1,price={sp_s1=45},reward={se2={e822=1},},serverReward={sequip_e822=1},},
            {id=4,maxLimit=10,price={sp_s1=30},reward={p={p4002=1},},serverReward={props_p4002=1},},
            {id=5,maxLimit=10,price={sp_s1=15},reward={p={p1=1},},serverReward={props_p1=1},},
            {id=6,maxLimit=5,price={sp_s1=12},reward={p={p4005=1},},serverReward={props_p4005=1},},
            {id=7,maxLimit=10,price={sp_s1=3},reward={p={p4004=1},},serverReward={props_p4004=1},},
            {id=8,maxLimit=50,price={sp_s1=2},reward={p={p4003=3},},serverReward={props_p4003=3},},
            {id=9,maxLimit=50,price={sp_s1=5},reward={p={p20=6},},serverReward={props_p20=6},},
            {id=10,maxLimit=100,price={sp_s1=4},reward={p={p2=1},},serverReward={props_p2=1},},
        },
    },
    [3]={
        --每次抽奖
        cost=168,
        --十连抽价格
        cost2=1596,
        -- 9 ★ 级到了 必给装备
        mustGetSuperEquip={sequip_e102=1,},
        getSuperEquip={e102=1,},
        --幸运值阈值
        luckyLimit={18,22,32,39,45,53,66,87,128,},
        luckyValue={1,1,1,1,1,1,1,1,1,1,1,1,1},
        serverreward ={
            --奖池
            pool={
                {100},
                {16,12,10,14,12,20,13,16,12,12,12,19,19},
                {{"props_p36",1,},{"props_p4003",1,},{"props_p4004",2,},{"props_p4004",1,},{"props_p4001",25,},{"props_p4001",50,},{"props_p4001",150,},{"props_p19",1,},{"props_p19",3,},{"props_p3",1,},{"props_p20",2,},{"sp_s1",2,},{"sp_s1",4,}},
            },
            
            starRate ={0.07,0.055,0.035,0.028,0.024,0.02,0.016,0.012,0.008,},
        },
        showList={p={{sp_s1=4,index=1},{sp_s1=2,index=2},{p4004=2,index=3},{p4004=1,index=4},{p4003=1,index=5},{p4001=150,index=6},{p4001=50,index=7},{p4001=25,index=8},{p19=3,index=9},{p19=1,index=10},{p20=2,index=11},{p3=1,index=12},{p36=1,index=13}}},    --前台展示列表
        
        exchange={
            {id=1,maxLimit=1,price={sp_s1=330},reward={se2={e111_3=1},},serverReward={sequip_e111_3=1},},
            {id=2,maxLimit=1,price={sp_s1=60},reward={p={p4007=1},},serverReward={props_p4007=1},},
            {id=3,maxLimit=1,price={sp_s1=45},reward={se2={e822=1},},serverReward={sequip_e822=1},},
            {id=4,maxLimit=10,price={sp_s1=30},reward={p={p4002=1},},serverReward={props_p4002=1},},
            {id=5,maxLimit=10,price={sp_s1=15},reward={p={p1=1},},serverReward={props_p1=1},},
            {id=6,maxLimit=5,price={sp_s1=12},reward={p={p4005=1},},serverReward={props_p4005=1},},
            {id=7,maxLimit=10,price={sp_s1=3},reward={p={p4004=1},},serverReward={props_p4004=1},},
            {id=8,maxLimit=50,price={sp_s1=2},reward={p={p4003=3},},serverReward={props_p4003=3},},
            {id=9,maxLimit=50,price={sp_s1=5},reward={p={p20=6},},serverReward={props_p20=6},},
            {id=10,maxLimit=100,price={sp_s1=4},reward={p={p2=1},},serverReward={props_p2=1},},
        },
    },
    [4]={
        --每次抽奖
        cost=168,
        --十连抽价格
        cost2=1596,
        -- 9 ★ 级到了 必给装备
        mustGetSuperEquip={sequip_e142=1,},
        getSuperEquip={e142=1,},
        --幸运值阈值
        luckyLimit={18,20,23,26,28,32,43,80,115,},
        luckyValue={1,1,1,1,1,1,1,1,1,1,1,1,1},
        serverreward ={
            --奖池
            pool={
                {100},
                {16,12,10,14,12,20,13,16,12,12,12,19,19},
                {{"props_p36",1,},{"props_p4003",1,},{"props_p4004",2,},{"props_p4004",1,},{"props_p4001",25,},{"props_p4001",50,},{"props_p4001",150,},{"props_p19",1,},{"props_p19",3,},{"props_p3",1,},{"props_p20",2,},{"sp_s1",2,},{"sp_s1",4,}},
            },
            
            starRate ={0.07,0.06,0.05,0.045,0.04,0.035,0.025,0.013,0.009,},
        },
        showList={p={{sp_s1=4,index=1},{sp_s1=2,index=2},{p4004=2,index=3},{p4004=1,index=4},{p4003=1,index=5},{p4001=150,index=6},{p4001=50,index=7},{p4001=25,index=8},{p19=3,index=9},{p19=1,index=10},{p20=2,index=11},{p3=1,index=12},{p36=1,index=13}}},    --前台展示列表
        
        exchange={
            {id=1,maxLimit=1,price={sp_s1=330},reward={se2={e111_3=1},},serverReward={sequip_e111_3=1},},
            {id=2,maxLimit=1,price={sp_s1=60},reward={p={p4007=1},},serverReward={props_p4007=1},},
            {id=3,maxLimit=1,price={sp_s1=45},reward={se2={e822=1},},serverReward={sequip_e822=1},},
            {id=4,maxLimit=10,price={sp_s1=30},reward={p={p4002=1},},serverReward={props_p4002=1},},
            {id=5,maxLimit=10,price={sp_s1=15},reward={p={p1=1},},serverReward={props_p1=1},},
            {id=6,maxLimit=5,price={sp_s1=12},reward={p={p4005=1},},serverReward={props_p4005=1},},
            {id=7,maxLimit=10,price={sp_s1=3},reward={p={p4004=1},},serverReward={props_p4004=1},},
            {id=8,maxLimit=50,price={sp_s1=2},reward={p={p4003=3},},serverReward={props_p4003=3},},
            {id=9,maxLimit=50,price={sp_s1=5},reward={p={p20=6},},serverReward={props_p20=6},},
            {id=10,maxLimit=100,price={sp_s1=4},reward={p={p2=1},},serverReward={props_p2=1},},
        },
    },
}

return limitsequip 
