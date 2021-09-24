local luckybag ={
    multiSelectType = true,
    [1]={
        sortid=227,
        type=1,
        --福袋升级需求
        supportNeed={0,150,300},
        --幸运值最大值
        maxLuck=300,
        --福袋对应道具
        items={reward={luckybag={{luckybag_a1=1},{luckybag_a2=1},{luckybag_a3=1}}},serverreward={{"luckybag_a1",1},{"luckybag_a2",1},{"luckybag_a3",1}}},
        --福袋对应积分
        score={luckybag_a1={2,6},luckybag_a2={5,11},luckybag_a3={5,11}},
        serverreward={
            
            taskList={
                --完成N个日常任务
                {type="kn1",num=1,index=1,limit=10,serverreward={{"props_p902",2},{"troops_a10043",2},{"luckybag_a1",1}}},
                --进攻玩家N次
                {type="kn2",num=1,index=2,limit=10,serverreward={{"props_p902",2},{"troops_a10073",2},{"luckybag_a1",1}}},
                --消费累计N钻石
                {type="kn3",num=3000,index=3,limit=20,serverreward={{"props_p4810",2},{"equip_e1",2000},{"luckybag_a2",1}}},
                --累计充值N钻石
                {type="kn4",num=2000,index=4,limit=30,serverreward={{"alien_r2",500},{"alien_r6",20},{"luckybag_a3",1}}},
            },
            luckybag_a1={
                --奖池1
                pool1={
                    {100},
                    {7,8,9,10,7,8,9,10},
                    {{"troops_a10082",2},{"troops_a10073",2},{"troops_a10043",2},{"troops_a10053",2},{"troops_a10035",2},{"troops_a10005",2},{"troops_a10025",2},{"troops_a10015",2}},
                },
                
                --奖池2
                pool2={
                    {100},
                    {7,8,9,10,7,8,9,10},
                    {{"troops_a10083",2},{"troops_a10074",2},{"troops_a10044",2},{"troops_a10054",2},{"troops_a10036",2},{"troops_a10006",2},{"troops_a10026",2},{"troops_a10016",2}},
                },
                
                --奖池3
                pool3={
                    {100},
                    {7,8,9,10,7,8,9,10},
                    {{"troops_a10084",1},{"troops_a10075",1},{"troops_a10045",1},{"troops_a20055",1},{"troops_a10037",1},{"troops_a10007",1},{"troops_a10027",1},{"troops_a10017",1}},
                },
                
            },
            luckybag_a2={
                --奖池4
                pool1={
                    {100},
                    {10,10,10,10,10,10,10},
                    {{"equip_e1",1000},{"equip_e2",1000},{"equip_e3",1000},{"props_p957",10},{"props_p956",2},{"props_p4810",3},{"props_p819",3}},
                },
                
                --奖池5
                pool2={
                    {100},
                    {10,10,10,10,10,10,10},
                    {{"equip_e1",2000},{"equip_e2",2000},{"equip_e3",2000},{"props_p958",10},{"props_p956",5},{"props_p4811",3},{"props_p818",3}},
                },
                
                --奖池6
                pool3={
                    {100},
                    {10,10,10,10,10,10},
                    {{"equip_e1",3000},{"equip_e2",3000},{"equip_e3",3000},{"props_p959",10},{"props_p956",7},{"props_p4812",3}},
                },
                
            },
            luckybag_a3={
                --奖池7
                pool1={
                    {100},
                    {10,10,10,10,7},
                    {{"alien_r1",600},{"alien_r2",300},{"alien_r4",80},{"alien_r5",80},{"alien_r6",20}},
                },
                
                --奖池8
                pool2={
                    {100},
                    {10,10,10,10,7},
                    {{"alien_r1",1200},{"alien_r2",600},{"alien_r4",160},{"alien_r5",160},{"alien_r6",40}},
                },
                
                --奖池9
                pool3={
                    {100},
                    {10,10,10,10,7},
                    {{"alien_r1",1800},{"alien_r2",900},{"alien_r4",240},{"alien_r5",240},{"alien_r6",60}},
                },
                
            },
        },
        rewardTb={
            
            taskList={
                {type="kn1",num=1,index=1,limit=10,reward={o={{a10043=2,index=2}},p={{p902=2,index=1}},luckybag={{luckybag_a1=1,index=3}}}},
                {type="kn2",num=1,index=2,limit=10,reward={o={{a10073=2,index=2}},p={{p902=2,index=1}},luckybag={{luckybag_a1=1,index=3}}}},
                {type="kn3",num=3000,index=3,limit=20,reward={f={{e1=2000,index=2}},p={{p4810=2,index=1}},luckybag={{luckybag_a2=1,index=3}}}},
                {type="kn4",num=2000,index=4,limit=30,reward={r={{r2=500,index=1},{r6=20,index=2}},luckybag={{luckybag_a3=1,index=3}}}},
            },
            pool={
                luckybag_a1={
                    --奖池1
                    pool1={o={{a10082=2,index=1},{a10073=2,index=2},{a10043=2,index=3},{a10053=2,index=4},{a10035=2,index=5},{a10005=2,index=6},{a10025=2,index=7},{a10015=2,index=8}}},
                    --奖池2
                    pool2={o={{a10083=2,index=1},{a10074=2,index=2},{a10044=2,index=3},{a10054=2,index=4},{a10036=2,index=5},{a10006=2,index=6},{a10026=2,index=7},{a10016=2,index=8}}},
                    --奖池3
                    pool3={o={{a10084=1,index=1},{a10075=1,index=2},{a10045=1,index=3},{a20055=1,index=4},{a10037=1,index=5},{a10007=1,index=6},{a10027=1,index=7},{a10017=1,index=8}}},
                },
                luckybag_a2={
                    --奖池4
                    pool1={f={{e1=1000,index=1},{e2=1000,index=2},{e3=1000,index=3}},p={{p957=10,index=4},{p956=2,index=5},{p4810=3,index=6},{p819=3,index=7}}},
                    --奖池5
                    pool2={f={{e1=2000,index=1},{e2=2000,index=2},{e3=2000,index=3}},p={{p958=10,index=4},{p956=5,index=5},{p4811=3,index=6},{p818=3,index=7}}},
                    --奖池6
                    pool3={f={{e1=3000,index=1},{e2=3000,index=2},{e3=3000,index=3}},p={{p959=10,index=4},{p956=7,index=5},{p4812=3,index=6}}},
                },
                luckybag_a3={
                    --奖池7
                    pool1={r={{r1=600,index=1},{r2=300,index=2},{r4=80,index=3},{r5=80,index=4},{r6=20,index=5}}},
                    --奖池8
                    pool2={r={{r1=1200,index=1},{r2=600,index=2},{r4=160,index=3},{r5=160,index=4},{r6=40,index=5}}},
                    --奖池9
                    pool3={r={{r1=1800,index=1},{r2=900,index=2},{r4=240,index=3},{r5=240,index=4},{r6=60,index=5}}},
                },
            },
        },
    },
}

return luckybag 
