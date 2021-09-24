local yunshiyelian={
    multiSelectType=true,
    [1]={
        --开放等级
        funcOpen=25,
        --抽一次消耗
        cost=35,
        --10连抽
        cost10=332,
        showList={o={{a10003=5,index=18},{a10013=5,index=17},{a10023=5,index=16},{a10033=5,index=15},{a10004=5,index=14},{a10014=5,index=13},{a10024=5,index=12},{a10034=5,index=11}},r={{r2=220,index=4},{r1=300,index=5},{r5=20,index=2},{r4=20,index=3},{r6=5,index=1},{r2=50,index=7},{r1=120,index=8},{r5=8,index=9},{r4=8,index=10},{r6=2,index=6}}},    --前台展示列表
        
        flickReward={r={{r2=220},{r1=300},{r5=20},{r4=20},{r6=5}}},    --前台展示列表
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {8,8,8,8,2,8,8,8,8,2,4,4,3,3,5,5,4,4},
                {{"alien_r2",220},{"alien_r1",300},{"alien_r5",20},{"alien_r4",20},{"alien_r6",5},{"alien_r2",50},{"alien_r1",120},{"alien_r5",8},{"alien_r4",8},{"alien_r6",2},{"troops_a10003",5},{"troops_a10013",5},{"troops_a10023",5},{"troops_a10033",5},{"troops_a10004",5},{"troops_a10014",5},{"troops_a10024",5},{"troops_a10034",5}},
            },
            
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="gb",needNum=268,reward={r={{r6=20,index=1},{r4=5,index=2},{r5=5,index=3}}},serverreward={alien_r6=20,alien_r4=5,alien_r5=5},},
            {key="rd",needNum=3500,reward={r={{r6=70,index=1},{r4=300,index=2}}},serverreward={alien_r6=70,alien_r4=300},},
            {key="ry",needNum=5600,reward={r={{r6=150,index=1},{r5=300,index=2}}},serverreward={alien_r6=150,alien_r5=300},},
            {key="rb",needNum=5,reward={r={{r6=8,index=1},{r4=5,index=2},{r5=10,index=3}}},serverreward={alien_r6=8,alien_r4=5,alien_r5=10},},
            {key="pe",needNum=5,reward={r={{r6=8,index=1},{r4=10,index=2},{r5=5,index=3}}},serverreward={alien_r6=8,alien_r4=10,alien_r5=5},},
            {key="ra",needNum=4,reward={r={{r6=25,index=1},{r4=5,index=2},{r5=5,index=3}}},serverreward={alien_r6=25,alien_r4=5,alien_r5=5},},
            {key="rs",needNum=10,reward={r={{r6=25,index=1},{r4=10,index=2},{r5=10,index=3}}},serverreward={alien_r6=25,alien_r4=10,alien_r5=10},},
            
        },
    },
    [2]={
        --开放等级
        funcOpen=25,
        --抽一次消耗
        cost=35,
        --10连抽
        cost10=332,
        showList={o={{a10003=4,index=18},{a10013=4,index=17},{a10023=4,index=16},{a10033=4,index=15},{a10004=4,index=14},{a10014=4,index=13},{a10024=4,index=12},{a10034=4,index=11}},r={{r2=200,index=4},{r1=280,index=5},{r5=18,index=2},{r4=18,index=3},{r6=5,index=1},{r2=40,index=7},{r1=100,index=8},{r5=8,index=9},{r4=8,index=10},{r6=2,index=6}}},    --前台展示列表
        
        flickReward={r={{r2=200},{r1=280},{r5=18},{r4=18},{r6=5}}},    --前台展示列表
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {8,8,8,8,2,8,8,8,8,2,4,4,3,3,5,5,4,4},
                {{"alien_r2",200},{"alien_r1",280},{"alien_r5",18},{"alien_r4",18},{"alien_r6",5},{"alien_r2",40},{"alien_r1",100},{"alien_r5",8},{"alien_r4",8},{"alien_r6",2},{"troops_a10003",4},{"troops_a10013",4},{"troops_a10023",4},{"troops_a10033",4},{"troops_a10004",4},{"troops_a10014",4},{"troops_a10024",4},{"troops_a10034",4}},
            },
            
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="gb",needNum=268,reward={r={{r1=800,index=1},{r2=400,index=2}}},serverreward={alien_r1=800,alien_r2=400},},
            {key="rd",needNum=3500,reward={r={{r6=70,index=1},{r4=300,index=2}}},serverreward={alien_r6=70,alien_r4=300},},
            {key="ry",needNum=5600,reward={r={{r6=150,index=1},{r5=300,index=2}}},serverreward={alien_r6=150,alien_r5=300},},
            {key="rb",needNum=5,reward={r={{r1=150,index=1},{r2=300,index=2}}},serverreward={alien_r1=150,alien_r2=300},},
            {key="pe",needNum=5,reward={r={{r1=300,index=1},{r2=150,index=2}}},serverreward={alien_r1=300,alien_r2=150},},
            {key="ra",needNum=4,reward={r={{r1=800,index=1},{r2=400,index=2}}},serverreward={alien_r1=800,alien_r2=400},},
            {key="rs",needNum=10,reward={r={{r1=400,index=1},{r2=600,index=2}}},serverreward={alien_r1=400,alien_r2=600},},
            
        },
    },
    [3]={
        --开放等级
        funcOpen=25,
        --抽一次消耗
        cost=35,
        --10连抽
        cost10=332,
        showList={o={{a10005=2,index=20},{a10015=2,index=21},{a10025=2,index=22},{a10035=2,index=23},{a10043=1,index=11},{a10053=1,index=12},{a10063=1,index=13},{a10073=1,index=14},{a10082=1,index=15},{a10093=1,index=16},{a10113=1,index=17},{a10123=1,index=18},{a20153=1,index=19}},r={{r2=150,index=4},{r1=240,index=5},{r5=20,index=2},{r4=20,index=3},{r6=5,index=1},{r2=20,index=7},{r1=40,index=8},{r5=10,index=9},{r4=10,index=10},{r6=3,index=6}}},    --前台展示列表
        
        flickReward={r={{r2=150},{r1=240},{r5=20},{r4=20},{r6=5}}},    --前台展示列表
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {8,8,8,8,5,8,8,8,8,4,4,4,4,4,3,3,3,3,2,3,3,3,2},
                {{"alien_r2",150},{"alien_r1",240},{"alien_r5",20},{"alien_r4",20},{"alien_r6",5},{"alien_r2",20},{"alien_r1",40},{"alien_r5",10},{"alien_r4",10},{"alien_r6",3},{"troops_a10005",2},{"troops_a10015",2},{"troops_a10025",2},{"troops_a10035",2},{"troops_a10043",1},{"troops_a10053",1},{"troops_a10063",1},{"troops_a10073",1},{"troops_a10082",1},{"troops_a10093",1},{"troops_a10113",1},{"troops_a10123",1},{"troops_a20153",1}},
            },
            
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="gb",needNum=268,reward={r={{r1=1000,index=1},{r2=500,index=2}}},serverreward={alien_r1=1000,alien_r2=500},},
            {key="rd",needNum=3000,reward={r={{r6=200,index=1},{r4=600,index=2}}},serverreward={alien_r6=200,alien_r4=600},},
            {key="ry",needNum=4000,reward={r={{r6=350,index=1},{r5=600,index=2}}},serverreward={alien_r6=350,alien_r5=600},},
            {key="rb",needNum=5,reward={r={{r1=150,index=1},{r2=300,index=2}}},serverreward={alien_r1=150,alien_r2=300},},
            {key="pe",needNum=5,reward={r={{r1=400,index=1},{r2=200,index=2}}},serverreward={alien_r1=400,alien_r2=200},},
            {key="ra",needNum=4,reward={r={{r1=800,index=1},{r2=400,index=2}}},serverreward={alien_r1=800,alien_r2=400},},
            {key="rs",needNum=10,reward={r={{r1=400,index=1},{r2=600,index=2}}},serverreward={alien_r1=400,alien_r2=600},},
            
        },
    },
    [4]={
        --开放等级
        funcOpen=25,
        --抽一次消耗
        cost=35,
        --10连抽
        cost10=332,
        showList={r={{r2=150,index=4},{r1=240,index=5},{r5=30,index=2},{r4=30,index=3},{r6=10,index=1},{r2=40,index=7},{r1=40,index=8},{r5=15,index=9},{r4=15,index=10},{r6=5,index=6}}},    --前台展示列表
        
        flickReward={r={{r2=150},{r1=240},{r5=30},{r4=30},{r6=10}}},    --前台展示列表
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {8,8,8,8,5,8,8,7,7,4},
                {{"alien_r2",150},{"alien_r1",240},{"alien_r5",30},{"alien_r4",30},{"alien_r6",10},{"alien_r2",40},{"alien_r1",40},{"alien_r5",15},{"alien_r4",15},{"alien_r6",5}},
            },
            
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="gb",needNum=268,reward={r={{r1=1000,index=1},{r2=500,index=2}}},serverreward={alien_r1=1000,alien_r2=500},},
            {key="rd",needNum=4700,reward={r={{r6=300,index=1},{r4=600,index=2}}},serverreward={alien_r6=300,alien_r4=600},},
            {key="ry",needNum=7400,reward={r={{r6=400,index=1},{r5=600,index=2}}},serverreward={alien_r6=400,alien_r5=600},},
            {key="rb",needNum=5,reward={r={{r1=150,index=1},{r2=300,index=2}}},serverreward={alien_r1=150,alien_r2=300},},
            {key="pe",needNum=5,reward={r={{r1=400,index=1},{r2=200,index=2}}},serverreward={alien_r1=400,alien_r2=200},},
            {key="ra",needNum=4,reward={r={{r1=800,index=1},{r2=400,index=2}}},serverreward={alien_r1=800,alien_r2=400},},
            {key="rs",needNum=10,reward={r={{r1=400,index=1},{r2=600,index=2}}},serverreward={alien_r1=400,alien_r2=600},},
            
        },
    },
}

return yunshiyelian
