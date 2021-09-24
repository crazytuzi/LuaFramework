local gqlh ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        --单抽价格
        cost1=58,
        --五连价格
        cost2=276,
        serverreward={
            --增加分数（1-对子，2-三条，3-四条，4-带金色全不一样，5-不带金色全不一样，6-全金色）
            extraScore={2,4,8,5,6,8},
            --奖池对应分数（由后向前，大于等于该数则使用这个奖池）
            matchScore={0,10,200},
            --金色数量
            goldNum={30,80,150,300,500},
            --奖励1
            gift1={{"props_p20",1},{"props_p19",1}},
            --奖励2
            gift2={{"props_p4810",3},{"props_p601",5}},
            --奖励3
            gift3={{"props_p4605",1},{"armor_exp",1000}},
            --奖励4
            gift4={{"alien_r2",800},{"alien_r1",800}},
            --奖励5
            gift5={{"alien_r6",20},{"alien_r5",100},{"alien_r4",100}},
            --礼花奖池（权重、代号、积分）
            mainPool={
                {100},
                {20,20,20,20,5},
                {1,2,3,4,5},
                {1,1,1,1,2},
            },
            
            --奖池1
            pool1={
                {100},
                {15,15,15,15,10,15,10,8,10,10,10},
                {{"alien_r2",300},{"alien_r1",600},{"alien_r5",50},{"alien_r4",50},{"alien_r6",10},{"armor_exp",1000},{"props_p4602",1},{"props_p4603",1},{"equip_e1",500},{"equip_e2",500},{"equip_e3",500}},
            },
            
            --奖池2
            pool2={
                {100},
                {15,15,15,15,5,15,10,5,1,10,10},
                {{"alien_r2",500},{"alien_r1",1000},{"alien_r5",100},{"alien_r4",100},{"alien_r6",30},{"armor_exp",2000},{"props_p4602",2},{"props_p4603",2},{"props_p4604",1},{"userarena_point",1000},{"userexpedition_point",1000}},
            },
            
            --奖池3
            pool3={
                {100},
                {15,15,12,12,10,10,20},
                {{"alien_r2",10000},{"alien_r1",20000},{"alien_r5",2000},{"alien_r4",2000},{"alien_r6",500},{"armor_exp",100000},{"props_p4604",2}},
            },
            
            --金球额外奖池
            goldpool={
                {100},
                {50,10,10,10,20,5,5,5,5},
                {{"props_p4810",1},{"props_p451",1},{"props_p452",1},{"props_p453",1},{"props_p4811",1},{"props_p454",1},{"props_p455",1},{"props_p456",1},{"props_p457",1}},
            },
            
            --商店
            shopList={
                [1]={serverreward={"props_p4606",1},price=1200,limit=2},
                [2]={serverreward={"armor_exp",2000},price=35,limit=50},
                [3]={serverreward={"alien_r6",50},price=180,limit=20},
                [4]={serverreward={"alien_r4",500},price=180,limit=20},
                [5]={serverreward={"alien_r5",500},price=200,limit=20},
                [6]={serverreward={"props_p4811",1},price=20,limit=50},
                [7]={serverreward={"props_p4810",1},price=10,limit=50},
                [8]={serverreward={"userarena_point",2000},price=75,limit=50},
                [9]={serverreward={"userexpedition_point",2000},price=75,limit=50},
            },
        },
        reward={
            --奖励1
            {goldNum=30,gift={p={{p20=1,index=1},{p19=1,index=2}}}},
            
            --奖励2
            {goldNum=80,gift={p={{p4810=3,index=1},{p601=5,index=2}}}},
            
            --奖励3
            {goldNum=150,gift={p={{p4605=1,index=1}},am={{exp=1000,index=2}}}},
            
            --奖励4
            {goldNum=300,gift={r={{r2=800,index=1},{r1=800,index=2}}}},
            
            --奖励5
            {goldNum=500,gift={r={{r6=20,index=1},{r5=100,index=2},{r4=100,index=3}}}},
            
        },
        showList={f={{e1=500,index=20},{e2=500,index=21},{e3=500,index=22}},m={{p=1000,index=10}},n={{p=1000,index=11}},p={{p4604=1,index=1},{p4603=2,index=2},{p4602=2,index=9},{p4603=1,index=12},{p4602=1,index=13},{p4810=1,index=23},{p451=1,index=24},{p452=1,index=25},{p453=1,index=26},{p4811=1,index=27},{p454=1,index=28},{p455=1,index=29},{p456=1,index=30},{p457=1,index=31}},r={{r2=500,index=3},{r1=1000,index=4},{r5=100,index=5},{r4=100,index=6},{r6=30,index=7},{r2=300,index=14},{r1=600,index=15},{r5=50,index=16},{r4=50,index=17},{r6=10,index=18}},am={{exp=2000,index=8},{exp=1000,index=19}}},    --前台展示列表
        flash={2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --商店
        shopList={
            {reward={p={p4606=1}},index=1,price=1200,limit=2},
            {reward={am={exp=2000}},index=2,price=35,limit=50},
            {reward={r={r6=50}},index=3,price=180,limit=20},
            {reward={r={r4=500}},index=4,price=180,limit=20},
            {reward={r={r5=500}},index=5,price=200,limit=20},
            {reward={p={p4811=1}},index=6,price=20,limit=50},
            {reward={p={p4810=1}},index=7,price=10,limit=50},
            {reward={m={p=2000}},index=8,price=75,limit=50},
            {reward={n={p=2000}},index=9,price=75,limit=50},
        },
    },
    [2]={
        sortid=223,
        type=1,
        --单抽价格
        cost1=58,
        --五连价格
        cost2=276,
        serverreward={
            --增加分数（1-对子，2-三条，3-四条，4-带金色全不一样，5-不带金色全不一样，6-全金色）
            extraScore={2,4,8,5,6,8},
            --奖池对应分数（由后向前，大于等于该数则使用这个奖池）
            matchScore={0,10,200},
            --金色数量
            goldNum={30,80,150,300,500},
            --奖励1
            gift1={{"props_p20",2},{"props_p19",5}},
            --奖励2
            gift2={{"props_p4811",5},{"props_p601",20}},
            --奖励3
            gift3={{"props_p3436",10}},
            --奖励4
            gift4={{"alien_r6",100},{"alien_r2",1000}},
            --奖励5
            gift5={{"props_p4604",1}},
            --礼花奖池（权重、代号、积分）
            mainPool={
                {100},
                {20,20,20,20,5},
                {1,2,3,4,5},
                {1,1,1,1,2},
            },
            
            --奖池1
            pool1={
                {100},
                {15,15,5,15,10,15,10,10,10},
                {{"alien_r2",300},{"alien_r1",1000},{"props_p4603",1},{"armor_exp",1000},{"props_p818",1},{"props_p819",3},{"equip_e1",1000},{"equip_e2",1000},{"equip_e3",1000}},
            },
            
            --奖池2
            pool2={
                {100},
                {10,15,1,15,10,20,20,20,20},
                {{"alien_r6",50},{"alien_r2",1000},{"props_p4604",1},{"armor_exp",3000},{"props_p3436",1},{"props_p818",2},{"equip_e1",2000},{"equip_e2",2000},{"equip_e3",2000}},
            },
            
            --奖池3
            pool3={
                {100},
                {15,15,12,12,10,10,20},
                {{"alien_r2",10000},{"alien_r1",20000},{"alien_r5",2000},{"alien_r4",2000},{"alien_r6",500},{"armor_exp",100000},{"props_p4604",2}},
            },
            
            --金球额外奖池
            goldpool={
                {100},
                {50,20,20},
                {{"props_p4812",1},{"props_p4811",2},{"props_p4810",5}},
            },
            
            --商店
            shopList={
                [1]={serverreward={"props_p4606",1},price=1200,limit=2},
                [2]={serverreward={"armor_exp",2000},price=35,limit=50},
                [3]={serverreward={"alien_r6",50},price=180,limit=20},
                [4]={serverreward={"alien_r2",500},price=30,limit=20},
                [5]={serverreward={"props_p4812",1},price=20,limit=50},
                [6]={serverreward={"props_p4811",1},price=10,limit=50},
                [7]={serverreward={"props_p4810",1},price=5,limit=50},
                [8]={serverreward={"equip_e1",2000},price=75,limit=50},
                [9]={serverreward={"equip_e2",2000},price=75,limit=50},
                [10]={serverreward={"equip_e3",2000},price=75,limit=50},
            },
        },
        reward={
            --奖励1
            {goldNum=30,gift={p={{p20=2,index=1},{p19=5,index=2}}}},
            
            --奖励2
            {goldNum=80,gift={p={{p4811=5,index=1},{p601=20,index=2}}}},
            
            --奖励3
            {goldNum=150,gift={p={{p3436=10,index=1}}}},
            
            --奖励4
            {goldNum=300,gift={r={{r6=100,index=1},{r2=1000,index=2}}}},
            
            --奖励5
            {goldNum=500,gift={p={{p4604=1,index=1}}}},
            
        },
        showList={f={{e1=2000,index=7},{e2=2000,index=8},{e3=2000,index=9},{e1=1000,index=16},{e2=1000,index=17},{e3=1000,index=18}},p={{p4604=1,index=1},{p3436=1,index=5},{p818=2,index=6},{p4603=1,index=12},{p818=1,index=14},{p819=3,index=15},{p4812=1,index=19},{p4811=2,index=20},{p4810=5,index=21}},r={{r6=50,index=2},{r2=1000,index=3},{r2=300,index=10},{r1=1000,index=11}},am={{exp=3000,index=4},{exp=1000,index=13}}},    --前台展示列表
        flash={2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --商店
        shopList={
            {reward={p={p4606=1}},index=1,price=1200,limit=2},
            {reward={am={exp=2000}},index=2,price=35,limit=50},
            {reward={r={r6=50}},index=3,price=180,limit=20},
            {reward={r={r2=500}},index=4,price=30,limit=20},
            {reward={p={p4812=1}},index=5,price=20,limit=50},
            {reward={p={p4811=1}},index=6,price=10,limit=50},
            {reward={p={p4810=1}},index=7,price=5,limit=50},
            {reward={f={e1=2000}},index=8,price=75,limit=50},
            {reward={f={e2=2000}},index=9,price=75,limit=50},
            {reward={f={e3=2000}},index=10,price=75,limit=50},
        },
    },
}

return gqlh 
