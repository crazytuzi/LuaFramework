local midautumn={
    multiSelectType=true,
    [1]={
        type=1,
        sortId=317,
        version=1,
        
        --任务配置
        change=28,    --换一批任务所需金币
        tnum=4,    --换一批刷新任务数量
        
        fixedTask={  --每日刷新，换一批不刷新  充值任务和购买任务
            --gu:购买礼包  needNum:礼包的价格
            --gb:充值金币  needNum:充值金币的数量
            {key="gu",needNum=388,reward={p={{p601=10,index=1},{p983=1,index=2},{p3329=5,index=3},{p3328=5,index=4},{p3327=5,index=5}}},serverreward={props_p601=10,props_p983=1,props_p3329=5,props_p3328=5,props_p3327=5}},
            {key="gb",needNum=8400,reward={p={{p586=1,index=1},{p988=30,index=2},{p3329=25,index=3},{p3328=25,index=4}}},serverreward={props_p586=1,props_p988=30,props_p3329=25,props_p3328=25}},
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="cn",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p817=2,index=1},{p3327=1,index=2}}},{p={{p817=3,index=1},{p3327=2,index=2}}},{p={{p817=4,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p817=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p817=2,props_p3327=1},{props_p817=3,props_p3327=2},{props_p817=4,props_p3328=1,props_p3327=2},{props_p817=5,props_p3329=1,props_p3327=2}}},
            {key="pp",ratio={55,25,15,5},needNum={3,3,3,3},reward={{p={{p15=1,index=1},{p3327=1,index=2}}},{p={{p15=2,index=1},{p3327=2,index=2}}},{p={{p15=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p16=1,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p15=1,props_p3327=1},{props_p15=2,props_p3327=2},{props_p15=3,props_p3328=1,props_p3327=2},{props_p16=1,props_p3329=1,props_p3327=2}}},
            {key="pe",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p19=3,index=1},{p3327=1,index=2}}},{p={{p19=5,index=1},{p3327=2,index=2}}},{p={{p19=7,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p19=10,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p19=3,props_p3327=1},{props_p19=5,props_p3327=2},{props_p19=7,props_p3328=1,props_p3327=2},{props_p19=10,props_p3329=1,props_p3327=2}}},
            {key="au",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p6=1,index=1}},p={{p3327=1,index=2}}},{e={{p6=2,index=1}},p={{p3327=2,index=2}}},{e={{p6=3,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p6=5,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p6=1,props_p3327=1},{accessory_p6=2,props_p3327=2},{accessory_p6=3,props_p3328=1,props_p3327=2},{accessory_p6=5,props_p3329=1,props_p3327=2}}},
            {key="ab",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p3=5,index=1}},p={{p3327=1,index=2}}},{e={{p3=10,index=1}},p={{p3327=2,index=2}}},{e={{p2=4,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p1=3,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p3=5,props_p3327=1},{accessory_p3=10,props_p3327=2},{accessory_p2=4,props_p3328=1,props_p3327=2},{accessory_p1=3,props_p3329=1,props_p3327=2}}},
            {key="mb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p47=3,index=1},{p3327=1,index=2}}},{p={{p47=5,index=1},{p3327=2,index=2}}},{p={{p47=7,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p47=10,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p47=3,props_p3327=1},{props_p47=5,props_p3327=2},{props_p47=7,props_p3328=1,props_p3327=2},{props_p47=10,props_p3329=1,props_p3327=2}}},
            {key="mw",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p292=1,index=1},{p3327=1,index=2}}},{p={{p292=2,index=1},{p3327=2,index=2}}},{p={{p292=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p292=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p292=1,props_p3327=1},{props_p292=2,props_p3327=2},{props_p292=3,props_p3328=1,props_p3327=2},{props_p292=5,props_p3329=1,props_p3327=2}}},
            {key="rb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p4=300,index=1}},p={{p3327=1,index=2}}},{e={{p4=500,index=1}},p={{p3327=2,index=2}}},{e={{p4=700,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p4=1000,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p4=300,props_p3327=1},{accessory_p4=500,props_p3327=2},{accessory_p4=700,props_p3328=1,props_p3327=2},{accessory_p4=1000,props_p3329=1,props_p3327=2}}},
            {key="eb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p447=1,index=1},{p3327=1,index=2}}},{p={{p447=2,index=1},{p3327=2,index=2}}},{p={{p447=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p447=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p447=1,props_p3327=1},{props_p447=2,props_p3327=2},{props_p447=3,props_p3328=1,props_p3327=2},{props_p447=5,props_p3329=1,props_p3327=2}}},
            {key="eu",ratio={55,25,15,5},needNum={1,1,1,1},reward={{p={{p819=1,index=1},{p3327=1,index=2}}},{p={{p819=2,index=1},{p3327=2,index=2}}},{p={{p819=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p819=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p819=1,props_p3327=1},{props_p819=2,props_p3327=2},{props_p819=3,props_p3328=1,props_p3327=2},{props_p819=5,props_p3329=1,props_p3327=2}}},
        },
        
        --抽奖配置
        need1={{p3327=1,p3328=1,p3329=1},{p={{p3327=1},{p3328=1},{p3329=1}}}},     --抽奖所需道具
        need2=10,    --10连抽所需道具翻倍
        
        showList={e={{p1=15,index=1},{p3=50,index=2},{p4=1000,index=3}},u={{r1=10000000,index=4},{r2=10000000,index=5},{r3=10000000,index=6},{r4=10000000,index=7},{gold=10000000,index=8},{r1=1000000,index=9},{r2=1000000,index=10},{r3=1000000,index=11},{r4=1000000,index=12},{gold=1000000,index=13}}},    --前台展示列表
        
        flick={1,1,1,1,1,1,1,1,0,0,0,0,0},    --前台闪光
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {10,20,4,3,3,3,7,7,10,10,10,20,20},
                {{"accessory_p1",15},{"accessory_p3",50},{"accessory_p4",1000},{"userinfo_r1",10000000},{"userinfo_r2",10000000},{"userinfo_r3",10000000},{"userinfo_r4",10000000},{"userinfo_gold",10000000},{"userinfo_r1",1000000},{"userinfo_r2",1000000},{"userinfo_r3",1000000},{"userinfo_r4",1000000},{"userinfo_gold",1000000}},
            },
            
            pointType={     --奖励顺序
                accessory_p1=1,
                accessory_p3=2,
                accessory_p4=3,
                userinfo_r1=4,
                userinfo_r2=5,
                userinfo_r3=6,
                userinfo_r4=7,
                userinfo_gold=8,
                userinfo_r1=9,
                userinfo_r2=10,
                userinfo_r3=11,
                userinfo_r4=12,
                userinfo_gold=13,
            },
            
            pointList={{36,54},{24,36},{18,27},{8,12},{8,12},{8,12},{8,12},{8,12},{4,6},{4,6},{4,6},{4,6},{4,6}},    --对应奖励顺序的随机增加点数范围
            
            rankReward={  --后台排行榜奖励
                {{1,1},{troops_a20115=50,troops_a10007=60,troops_a10083=70}},
                {{2,2},{troops_a20115=40,troops_a10007=60,troops_a10083=60}},
                {{3,3},{troops_a20115=30,troops_a10007=50,troops_a10083=50}},
                {{4,5},{troops_a20115=25,troops_a10007=45,troops_a10083=40}},
                {{6,10},{troops_a20115=20,troops_a10007=35,troops_a10083=30}},
            },
        },
        
        rankReward={  --前台排行榜奖励
            {{1,1},{o={{a20115=50,index=1},{a10007=60,index=2},{a10083=70,index=3}}}},
            {{2,2},{o={{a20115=40,index=1},{a10007=60,index=2},{a10083=60,index=3}}}},
            {{3,3},{o={{a20115=30,index=1},{a10007=50,index=2},{a10083=50,index=3}}}},
            {{4,5},{o={{a20115=25,index=1},{a10007=45,index=2},{a10083=40,index=3}}}},
            {{6,10},{o={{a20115=20,index=1},{a10007=35,index=2},{a10083=30,index=3}}}},
        },
        
        rankLimit=100,    --排行榜上榜限制
        
    },
	-----2017/9/18  老服
    [2]={
         type=1,
        sortId=317,
        version=1,
        
        --任务配置
        change=28,    --换一批任务所需金币
        tnum=4,    --换一批刷新任务数量
        
        fixedTask={  --每日刷新，换一批不刷新  充值任务和购买任务
            --gu:购买礼包  needNum:礼包的价格
            --gb:充值金币  needNum:充值金币的数量
            {key="gu",needNum=388,reward={e={{p1=3,index=1},{p2=5,index=2}},p={{p3329=5,index=3},{p3328=5,index=4},{p3327=5,index=5}}},serverreward={accessory_p1=3,accessory_p2=5,props_p3329=5,props_p3328=5,props_p3327=5}},
            {key="gb",needNum=2000,reward={e={{p4=5000,index=1},{p3=300,index=2}},p={{p3329=25,index=3},{p3328=25,index=4}}},serverreward={accessory_p4=5000,accessory_p3=300,props_p3329=25,props_p3328=25}},
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="cn",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p817=2,index=1},{p3327=1,index=2}}},{p={{p817=3,index=1},{p3327=2,index=2}}},{p={{p817=4,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p817=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p817=2,props_p3327=1},{props_p817=3,props_p3327=2},{props_p817=4,props_p3328=1,props_p3327=2},{props_p817=5,props_p3329=1,props_p3327=2}}},
            {key="pp",ratio={55,25,15,5},needNum={3,3,3,3},reward={{p={{p15=1,index=1},{p3327=1,index=2}}},{p={{p15=2,index=1},{p3327=2,index=2}}},{p={{p15=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p16=1,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p15=1,props_p3327=1},{props_p15=2,props_p3327=2},{props_p15=3,props_p3328=1,props_p3327=2},{props_p16=1,props_p3329=1,props_p3327=2}}},
            {key="pe",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p19=3,index=1},{p3327=1,index=2}}},{p={{p19=5,index=1},{p3327=2,index=2}}},{p={{p19=7,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p19=10,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p19=3,props_p3327=1},{props_p19=5,props_p3327=2},{props_p19=7,props_p3328=1,props_p3327=2},{props_p19=10,props_p3329=1,props_p3327=2}}},
            {key="au",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p6=1,index=1}},p={{p3327=1,index=2}}},{e={{p6=2,index=1}},p={{p3327=2,index=2}}},{e={{p6=3,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p6=5,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p6=1,props_p3327=1},{accessory_p6=2,props_p3327=2},{accessory_p6=3,props_p3328=1,props_p3327=2},{accessory_p6=5,props_p3329=1,props_p3327=2}}},
            {key="ab",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p3=5,index=1}},p={{p3327=1,index=2}}},{e={{p3=10,index=1}},p={{p3327=2,index=2}}},{e={{p2=4,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p1=3,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p3=5,props_p3327=1},{accessory_p3=10,props_p3327=2},{accessory_p2=4,props_p3328=1,props_p3327=2},{accessory_p1=3,props_p3329=1,props_p3327=2}}},
            {key="mb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p47=3,index=1},{p3327=1,index=2}}},{p={{p47=5,index=1},{p3327=2,index=2}}},{p={{p47=7,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p47=10,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p47=3,props_p3327=1},{props_p47=5,props_p3327=2},{props_p47=7,props_p3328=1,props_p3327=2},{props_p47=10,props_p3329=1,props_p3327=2}}},
            {key="mw",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p292=1,index=1},{p3327=1,index=2}}},{p={{p292=2,index=1},{p3327=2,index=2}}},{p={{p292=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p292=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p292=1,props_p3327=1},{props_p292=2,props_p3327=2},{props_p292=3,props_p3328=1,props_p3327=2},{props_p292=5,props_p3329=1,props_p3327=2}}},
            {key="rb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p4=300,index=1}},p={{p3327=1,index=2}}},{e={{p4=500,index=1}},p={{p3327=2,index=2}}},{e={{p4=700,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p4=1000,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p4=300,props_p3327=1},{accessory_p4=500,props_p3327=2},{accessory_p4=700,props_p3328=1,props_p3327=2},{accessory_p4=1000,props_p3329=1,props_p3327=2}}},
            {key="eb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p447=1,index=1},{p3327=1,index=2}}},{p={{p447=2,index=1},{p3327=2,index=2}}},{p={{p447=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p447=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p447=1,props_p3327=1},{props_p447=2,props_p3327=2},{props_p447=3,props_p3328=1,props_p3327=2},{props_p447=5,props_p3329=1,props_p3327=2}}},
            {key="eu",ratio={55,25,15,5},needNum={1,1,1,1},reward={{p={{p819=1,index=1},{p3327=1,index=2}}},{p={{p819=2,index=1},{p3327=2,index=2}}},{p={{p819=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p819=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p819=1,props_p3327=1},{props_p819=2,props_p3327=2},{props_p819=3,props_p3328=1,props_p3327=2},{props_p819=5,props_p3329=1,props_p3327=2}}},
        },
        
        --抽奖配置
        need1={{p3327=1,p3328=1,p3329=1},{p={{p3327=1},{p3328=1},{p3329=1}}}},     --抽奖所需道具
        need2=10,    --10连抽所需道具翻倍
        
        showList={o={{a10044=2,index=1},{a10054=2,index=2},{a10064=2,index=3},{a10074=2,index=4},{a10083=2,index=5},{a10045=1,index=6},{a20055=1,index=7},{a20065=1,index=8},{a10075=1,index=9}},u={{r2=1000000,index=10},{r3=1000000,index=11},{r4=1000000,index=12},{gold=1000000,index=13}}},    --前台展示列表
        
        flick={1,1,1,1,1,1,1,1,1,0,0,0,0},    --前台闪光
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {20,20,20,20,20,10,10,10,10,22,22,22,22},
                {{"troops_a10044",2},{"troops_a10054",2},{"troops_a10064",2},{"troops_a10074",2},{"troops_a10083",2},{"troops_a10045",1},{"troops_a20055",1},{"troops_a20065",1},{"troops_a10075",1},{"userinfo_r2",1000000},{"userinfo_r3",1000000},{"userinfo_r4",1000000},{"userinfo_gold",1000000}},
            },
            
            pointType={     --奖励顺序
                troops_a10044=1,
                troops_a10054=2,
                troops_a10064=3,
                troops_a10074=4,
                troops_a10083=5,
                troops_a10045=6,
                troops_a20055=7,
                troops_a20065=8,
                troops_a10075=9,
                userinfo_r2=10,
                userinfo_r3=11,
                userinfo_r4=12,
                userinfo_gold=13,
            },
            
            pointList={{36,54},{24,36},{18,27},{8,12},{8,12},{8,12},{8,12},{8,12},{4,6},{4,6},{4,6},{4,6},{4,6}},    --对应奖励顺序的随机增加点数范围
            
            rankReward={  --后台排行榜奖励
                {{1,1},{troops_a20115=50,troops_a10007=60,troops_a10083=70}},
                {{2,2},{troops_a20115=40,troops_a10007=60,troops_a10083=60}},
                {{3,3},{troops_a20115=30,troops_a10007=50,troops_a10083=50}},
                {{4,5},{troops_a20115=25,troops_a10007=45,troops_a10083=40}},
                {{6,10},{troops_a20115=20,troops_a10007=35,troops_a10083=30}},
            },
        },
        
        rankReward={  --前台排行榜奖励
            {{1,1},{o={{a20115=50,index=1},{a10007=60,index=2},{a10083=70,index=3}}}},
            {{2,2},{o={{a20115=40,index=1},{a10007=60,index=2},{a10083=60,index=3}}}},
            {{3,3},{o={{a20115=30,index=1},{a10007=50,index=2},{a10083=50,index=3}}}},
            {{4,5},{o={{a20115=25,index=1},{a10007=45,index=2},{a10083=40,index=3}}}},
            {{6,10},{o={{a20115=20,index=1},{a10007=35,index=2},{a10083=30,index=3}}}},
        },
        
        rankLimit=100,    --排行榜上榜限制
        
    },

	-----2017/9/18  新服	
    [3]={
        type=1,
        sortId=317,
        version=1,
        
        --任务配置
        change=28,    --换一批任务所需金币
        tnum=4,    --换一批刷新任务数量
        
        fixedTask={  --每日刷新，换一批不刷新  充值任务和购买任务
            --gu:购买礼包  needNum:礼包的价格
            --gb:充值金币  needNum:充值金币的数量
            {key="gu",needNum=388,reward={e={{p1=3,index=1},{p2=5,index=2}},p={{p3329=5,index=3},{p3328=5,index=4},{p3327=5,index=5}}},serverreward={accessory_p1=3,accessory_p2=5,props_p3329=5,props_p3328=5,props_p3327=5}},
            {key="gb",needNum=2000,reward={e={{p4=5000,index=1},{p3=300,index=2}},p={{p3329=25,index=3},{p3328=25,index=4}}},serverreward={accessory_p4=5000,accessory_p3=300,props_p3329=25,props_p3328=25}},
        },
        
        changedTask={    --可刷新的任务，每次点击换一批，从这个任务库里随机 4 个任务，然后再随机任务的品质，根据品质对应任务的奖励
            {key="cn",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p817=2,index=1},{p3327=1,index=2}}},{p={{p817=3,index=1},{p3327=2,index=2}}},{p={{p817=4,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p817=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p817=2,props_p3327=1},{props_p817=3,props_p3327=2},{props_p817=4,props_p3328=1,props_p3327=2},{props_p817=5,props_p3329=1,props_p3327=2}}},
            {key="pp",ratio={55,25,15,5},needNum={3,3,3,3},reward={{p={{p15=1,index=1},{p3327=1,index=2}}},{p={{p15=2,index=1},{p3327=2,index=2}}},{p={{p15=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p16=1,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p15=1,props_p3327=1},{props_p15=2,props_p3327=2},{props_p15=3,props_p3328=1,props_p3327=2},{props_p16=1,props_p3329=1,props_p3327=2}}},
            {key="pe",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p19=3,index=1},{p3327=1,index=2}}},{p={{p19=5,index=1},{p3327=2,index=2}}},{p={{p19=7,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p19=10,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p19=3,props_p3327=1},{props_p19=5,props_p3327=2},{props_p19=7,props_p3328=1,props_p3327=2},{props_p19=10,props_p3329=1,props_p3327=2}}},
            {key="au",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p6=1,index=1}},p={{p3327=1,index=2}}},{e={{p6=2,index=1}},p={{p3327=2,index=2}}},{e={{p6=3,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p6=5,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p6=1,props_p3327=1},{accessory_p6=2,props_p3327=2},{accessory_p6=3,props_p3328=1,props_p3327=2},{accessory_p6=5,props_p3329=1,props_p3327=2}}},
            {key="ab",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p3=5,index=1}},p={{p3327=1,index=2}}},{e={{p3=10,index=1}},p={{p3327=2,index=2}}},{e={{p2=4,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p1=3,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p3=5,props_p3327=1},{accessory_p3=10,props_p3327=2},{accessory_p2=4,props_p3328=1,props_p3327=2},{accessory_p1=3,props_p3329=1,props_p3327=2}}},
            {key="mb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p47=3,index=1},{p3327=1,index=2}}},{p={{p47=5,index=1},{p3327=2,index=2}}},{p={{p47=7,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p47=10,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p47=3,props_p3327=1},{props_p47=5,props_p3327=2},{props_p47=7,props_p3328=1,props_p3327=2},{props_p47=10,props_p3329=1,props_p3327=2}}},
            {key="mw",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p292=1,index=1},{p3327=1,index=2}}},{p={{p292=2,index=1},{p3327=2,index=2}}},{p={{p292=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p292=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p292=1,props_p3327=1},{props_p292=2,props_p3327=2},{props_p292=3,props_p3328=1,props_p3327=2},{props_p292=5,props_p3329=1,props_p3327=2}}},
            {key="rb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{e={{p4=300,index=1}},p={{p3327=1,index=2}}},{e={{p4=500,index=1}},p={{p3327=2,index=2}}},{e={{p4=700,index=1}},p={{p3328=1,index=2},{p3327=2,index=3}}},{e={{p4=1000,index=1}},p={{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{accessory_p4=300,props_p3327=1},{accessory_p4=500,props_p3327=2},{accessory_p4=700,props_p3328=1,props_p3327=2},{accessory_p4=1000,props_p3329=1,props_p3327=2}}},
            {key="eb",ratio={55,25,15,5},needNum={5,5,5,5},reward={{p={{p447=1,index=1},{p3327=1,index=2}}},{p={{p447=2,index=1},{p3327=2,index=2}}},{p={{p447=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p447=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p447=1,props_p3327=1},{props_p447=2,props_p3327=2},{props_p447=3,props_p3328=1,props_p3327=2},{props_p447=5,props_p3329=1,props_p3327=2}}},
            {key="eu",ratio={55,25,15,5},needNum={1,1,1,1},reward={{p={{p819=1,index=1},{p3327=1,index=2}}},{p={{p819=2,index=1},{p3327=2,index=2}}},{p={{p819=3,index=1},{p3328=1,index=2},{p3327=2,index=3}}},{p={{p819=5,index=1},{p3329=1,index=2},{p3327=2,index=3}}}},serverreward={{props_p819=1,props_p3327=1},{props_p819=2,props_p3327=2},{props_p819=3,props_p3328=1,props_p3327=2},{props_p819=5,props_p3329=1,props_p3327=2}}},
        },
        
        --抽奖配置
        need1={{p3327=1,p3328=1,p3329=1},{p={{p3327=1},{p3328=1},{p3329=1}}}},     --抽奖所需道具
        need2=10,    --10连抽所需道具翻倍
        
        showList={o={{a10083=1,index=1},{a10054=1,index=2},{a10064=1,index=3},{a10074=1,index=4},{a10044=1,index=5},{a10082=2,index=6},{a10063=2,index=7},{a10073=2,index=8},{a10053=2,index=9}},u={{r2=1000000,index=10},{r3=1000000,index=11},{r4=1000000,index=12},{gold=1000000,index=13}}},    --前台展示列表
        
        flick={1,1,1,1,1,1,1,1,1,0,0,0,0},    --前台闪光
        
        serverreward={
            randomPool={     --抽奖的随机奖池
                {100},
                {20,20,20,20,20,10,10,10,10,22,22,22,22},
                {{"troops_a10083",1},{"troops_a10054",1},{"troops_a10064",1},{"troops_a10074",1},{"troops_a10044",1},{"troops_a10082",2},{"troops_a10063",2},{"troops_a10073",2},{"troops_a10053",2},{"userinfo_r2",1000000},{"userinfo_r3",1000000},{"userinfo_r4",1000000},{"userinfo_gold",1000000}},
            },
            
            pointType={     --奖励顺序
                troops_a10083=1,
                troops_a10054=2,
                troops_a10064=3,
                troops_a10074=4,
                troops_a10044=5,
                troops_a10082=6,
                troops_a10063=7,
                troops_a10073=8,
                troops_a10053=9,
                userinfo_r2=10,
                userinfo_r3=11,
                userinfo_r4=12,
                userinfo_gold=13,
            },
            
            pointList={{36,54},{24,36},{18,27},{8,12},{8,12},{8,12},{8,12},{8,12},{4,6},{4,6},{4,6},{4,6},{4,6}},    --对应奖励顺序的随机增加点数范围
            
            rankReward={  --后台排行榜奖励
                {{1,1},{troops_a10083=50,troops_a10074=60,troops_a10054=70}},
                {{2,2},{troops_a10083=40,troops_a10074=60,troops_a10054=60}},
                {{3,3},{troops_a10083=30,troops_a10074=50,troops_a10054=50}},
                {{4,5},{troops_a10083=25,troops_a10074=45,troops_a10054=40}},
                {{6,10},{troops_a10083=20,troops_a10074=35,troops_a10054=30}},
            },
        },
        
        rankReward={  --前台排行榜奖励
            {{1,1},{o={{a10083=50,index=1},{a10074=60,index=2},{a10054=70,index=3}}}},
            {{2,2},{o={{a10083=40,index=1},{a10074=60,index=2},{a10054=60,index=3}}}},
            {{3,3},{o={{a10083=30,index=1},{a10074=50,index=2},{a10054=50,index=3}}}},
            {{4,5},{o={{a10083=25,index=1},{a10074=45,index=2},{a10054=40,index=3}}}},
            {{6,10},{o={{a10083=20,index=1},{a10074=35,index=2},{a10054=30,index=3}}}},
        },
        
        rankLimit=100,    --排行榜上榜限制
        
    },
}

return midautumn
