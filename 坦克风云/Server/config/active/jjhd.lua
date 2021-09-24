local jjhd ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        --单抽价格
        cost1=58,
        --五连价格
        cost2=290,
        --额外积分
        extraScore=5,
        serverreward={
            --狙击奖池（权重、代号、积分）
            mainPool={
                {100},
                {20,17,14,11,8},
                {1,2,3,4,5},
                {10,11,12,13,14},
            },
            
            --奖池1
            pool1={
                {100},
                {3,5,5,10,25,25},
                {{"props_p4820",1},{"props_p4824",1},{"props_p275",1},{"props_p276",1},{"props_p277",2},{"props_p281",1}},
            },
            
            --奖池2
            pool2={
                {100},
                {5,8,5,10,25,25},
                {{"props_p4820",1},{"props_p4824",1},{"props_p275",1},{"props_p276",1},{"props_p277",3},{"props_p281",1}},
            },
            
            --奖池3
            pool3={
                {100},
                {8,10,5,10,25,25},
                {{"props_p4820",1},{"props_p4824",1},{"props_p275",1},{"props_p276",1},{"props_p277",3},{"props_p282",1}},
            },
            
            --奖池4
            pool4={
                {100},
                {8,12,5,10,25,25},
                {{"props_p4820",1},{"props_p4824",1},{"props_p275",1},{"props_p276",2},{"props_p277",5},{"props_p282",1}},
            },
            
            --奖池5
            pool5={
                {100},
                {8,12,5,10,25,25},
                {{"props_p4820",1},{"props_p4824",1},{"props_p275",2},{"props_p276",2},{"props_p277",5},{"props_p283",1}},
            },
            
            
            goldpool={
                {100},
                {1,10,2,20,4,40},
                {{"props_p278",3},{"props_p279",3},{"props_p278",2},{"props_p279",2},{"props_p278",1},{"props_p279",1}},
            },
            
            --商店
            shopList={
                [1]={serverreward={"props_p4708",1},price=3500,limit=5},
                [2]={serverreward={"props_p4712",1},price=3000,limit=5},
                [3]={serverreward={"accessory_p11",1},price=240,limit=10},
                [4]={serverreward={"props_p969",1},price=40,limit=50},
                [5]={serverreward={"props_p970",1},price=40,limit=50},
                [6]={serverreward={"props_p971",1},price=40,limit=50},
                [7]={serverreward={"props_p972",1},price=40,limit=50},
                [8]={serverreward={"props_p278",1},price=80,limit=50},
                [9]={serverreward={"props_p279",5},price=80,limit=50},
            },
        },
        showList={p={{p4820=1,index=1},{p4824=1,index=2},{p275=2,index=3},{p276=2,index=4},{p277=5,index=5},{p283=1,index=6},{p278=3,index=7},{p279=3,index=8}}},    --前台展示列表
        flash={1,1,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --商店
        shopList={
            {reward={p={p4708=1}},index=1,price=3500,limit=5},
            {reward={p={p4712=1}},index=2,price=3000,limit=5},
            {reward={e={p11=1}},index=3,price=240,limit=10},
            {reward={p={p969=1}},index=4,price=40,limit=50},
            {reward={p={p970=1}},index=5,price=40,limit=50},
            {reward={p={p971=1}},index=6,price=40,limit=50},
            {reward={p={p972=1}},index=7,price=40,limit=50},
            {reward={p={p278=1}},index=8,price=80,limit=50},
            {reward={p={p279=5}},index=9,price=80,limit=50},
        },
    },
    [2]={
        sortid=223,
        type=1,
        --单抽价格
        cost1=58,
        --五连价格
        cost2=290,
        --额外积分
        extraScore=5,
        serverreward={
            --狙击奖池（权重、代号、积分）
            mainPool={
                {100},
                {20,17,14,11,8},
                {1,2,3,4,5},
                {10,11,12,13,14},
            },
            
            --奖池1
            pool1={
                {100},
                {27,45,50,100,250,250},
                {{"props_p4821",1},{"props_p4825",1},{"props_p275",1},{"props_p276",1},{"props_p277",2},{"props_p281",1}},
            },
            
            --奖池2
            pool2={
                {100},
                {45,75,50,100,250,250},
                {{"props_p4821",1},{"props_p4825",1},{"props_p275",1},{"props_p276",1},{"props_p277",3},{"props_p281",1}},
            },
            
            --奖池3
            pool3={
                {100},
                {75,95,50,100,250,250},
                {{"props_p4821",1},{"props_p4825",1},{"props_p275",1},{"props_p276",1},{"props_p277",3},{"props_p282",1}},
            },
            
            --奖池4
            pool4={
                {100},
                {75,115,50,100,250,250},
                {{"props_p4821",1},{"props_p4825",1},{"props_p275",1},{"props_p276",2},{"props_p277",5},{"props_p282",1}},
            },
            
            --奖池5
            pool5={
                {100},
                {75,115,50,100,250,250},
                {{"props_p4821",1},{"props_p4825",1},{"props_p275",2},{"props_p276",2},{"props_p277",5},{"props_p283",1}},
            },
            
            
            goldpool={
                {100},
                {1,10,2,20,4,40},
                {{"props_p278",3},{"props_p279",3},{"props_p278",2},{"props_p279",2},{"props_p278",1},{"props_p279",1}},
            },
            
            --商店
            shopList={
                [1]={serverreward={"props_p4709",1},price=3800,limit=5},
                [2]={serverreward={"props_p4713",1},price=3250,limit=5},
                [3]={serverreward={"accessory_p11",1},price=240,limit=10},
                [4]={serverreward={"props_p969",1},price=40,limit=50},
                [5]={serverreward={"props_p970",1},price=40,limit=50},
                [6]={serverreward={"props_p971",1},price=40,limit=50},
                [7]={serverreward={"props_p972",1},price=40,limit=50},
                [8]={serverreward={"props_p278",1},price=80,limit=50},
                [9]={serverreward={"props_p279",5},price=80,limit=50},
            },
        },
        showList={p={{p4821=1,index=1},{p4825=1,index=2},{p275=2,index=3},{p276=2,index=4},{p277=5,index=5},{p283=1,index=6},{p278=3,index=7},{p279=3,index=8}}},    --前台展示列表
        flash={1,1,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --商店
        shopList={
            {reward={p={p4709=1}},index=1,price=3800,limit=5},
            {reward={p={p4713=1}},index=2,price=3250,limit=5},
            {reward={e={p11=1}},index=3,price=240,limit=10},
            {reward={p={p969=1}},index=4,price=40,limit=50},
            {reward={p={p970=1}},index=5,price=40,limit=50},
            {reward={p={p971=1}},index=6,price=40,limit=50},
            {reward={p={p972=1}},index=7,price=40,limit=50},
            {reward={p={p278=1}},index=8,price=80,limit=50},
            {reward={p={p279=5}},index=9,price=80,limit=50},
        },
    },
}

return jjhd 
