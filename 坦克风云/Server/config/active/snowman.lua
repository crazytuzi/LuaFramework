local snowman ={
    multiSelectType = true,
    [1]={
        sortid=227,
        type=1,
        --单抽价格
        cost1=58,
        --五连价格
        cost2=275,
        --积分需求
        supportNeed={100,300,600},
        serverreward={
            --组合顺序相关
            sortlist={
                {sort={1,2,3},score=1,poolpick=1},
                {sort={1,3,2},score=1,poolpick=1},
                {sort={2,1,3},score=1,poolpick=1},
                {sort={2,3,1},score=1,poolpick=1},
                {sort={3,1,2},score=1,poolpick=1},
                {sort={3,2,1},score=3,poolpick=2},
            },
            combins={
                {100},
                {12,12,12,12,12,10},
                {1,2,3,4,5,6},
            },
            --积分奖励1
            gift1={{"alien_r1",2000},{"alien_r2",1000}},
            --积分奖励2
            gift2={{"props_p4852",10},{"equip_e1",2000},{"equip_e3",1000},{"equip_e2",1000}},
            --积分奖励3
            gift3={{"troops_a10083",10},{"troops_a10094",10},{"props_p4820",2},{"props_p4752",1}},
            --奖池1
            pool1={
                {100},
                {10,10,10,10,10,10,10,10,10,10,10,10,10},
                {{"troops_a10082",1},{"troops_a10093",1},{"troops_a10043",1},{"troops_a10113",1},{"equip_e1",500},{"equip_e2",500},{"equip_e3",500},{"props_p4810",2},{"props_p4811",2},{"alien_r1",500},{"alien_r2",300},{"alien_r4",50},{"alien_r5",50}},
            },
            
            --奖池2
            pool2={
                {100},
                {10,10,10,10,10,10,10},
                {{"troops_a10083",5},{"troops_a10094",5},{"troops_a10044",5},{"troops_a10114",5},{"props_p4852",5},{"alien_r6",50},{"props_p4820",2}},
            },
            
            --商店
            shopList={
                [1]={serverreward={"alien_r2",2000},price=300,limit=10,scoreLimit=100},
                [2]={serverreward={"props_p4812",5},price=300,limit=10,scoreLimit=100},
                [3]={serverreward={"alien_r6",50},price=300,limit=10,scoreLimit=300},
                [4]={serverreward={"props_p4820",1},price=140,limit=10,scoreLimit=300},
                [5]={serverreward={"props_p4751",1},price=1,limit=1,scoreLimit=600},
                [6]={serverreward={"props_p4804",1},price=450,limit=10,scoreLimit=600},
                [7]={serverreward={"props_p4852",5},price=360,limit=10,scoreLimit=600},
            },
        },
        rewardTb={
            gift={
                --积分奖励1
                {supportNeed=100,gift={r={{r1=2000,index=1},{r2=1000,index=2}}}},
                
                --积分奖励2
                {supportNeed=300,gift={f={{e1=2000,index=2},{e3=1000,index=3},{e2=1000,index=4}},p={{p4852=10,index=1}}}},
                
                --积分奖励3
                {supportNeed=600,gift={o={{a10083=10,index=1},{a10094=10,index=2}},p={{p4820=2,index=3},{p4752=1,index=4}}}},
                
            },
            showList={f={{e1=500,index=12},{e2=500,index=13},{e3=500,index=14}},o={{a10083=5,index=1},{a10094=5,index=2},{a10044=5,index=3},{a10114=5,index=4},{a10082=1,index=8},{a10093=1,index=9},{a10043=1,index=10},{a10113=1,index=11}},p={{p4852=5,index=5},{p4820=2,index=7},{p4810=2,index=15},{p4811=2,index=16}},r={{r6=50,index=6},{r1=500,index=17},{r2=300,index=18},{r4=50,index=19},{r5=50,index=20}}},    --前台展示列表
            --商店
            shopList={
                {scoreLimit=100,reward={{reward={r={r2=2000}},index=1,price=300,limit=10,value=500},{reward={p={p4812=5}},index=2,price=300,limit=10,value=500}}},
                {scoreLimit=300,reward={{reward={r={r6=50}},index=3,price=300,limit=10,value=500},{reward={p={p4820=1}},index=4,price=140,limit=10,value=240}}},
                {scoreLimit=600,reward={{reward={p={p4751=1}},index=5,price=1,limit=1,value=500},{reward={p={p4804=1}},index=6,price=450,limit=10,value=750},{reward={p={p4852=5}},index=7,price=360,limit=10,value=600}}},
            },
        },
    },
}

return snowman 
