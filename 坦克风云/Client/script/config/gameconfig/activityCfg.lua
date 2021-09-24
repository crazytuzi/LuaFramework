activityCfg=
{
    discount = {},
    moscowGambling = {},
    firstRecharge ={},
    fbReward ={},

    -- 军备升级
    dayRechargeForEquip = {
        reward = {
            {p={{p88=1,index=1},{p47=1,index=2}}},
            {e={{p6=3,index=1}},p={{p41=1,index=2}}},
            {p={{p89=1,index=1},{p20=10,index=2}}},
            {e={{f0=1,index=1},{p1=5,index=2}}},
        },
        cost = {160,960,3420,8400},
    },

    fightRank ={
        {rank = {1},award={u={{gems=3888,index=1}}}},
{rank = {2},award={u={{gems=1888,index=1}}}},
{rank = {3},award={u={{gems=888,index=1}}}},
{rank = {4,5},award={u={{gems=588,index=1}}}},
{rank = {6,10},award={u={{gems=388,index=1}}}},
    {rank = {11,20},award={u={{gems=188,index=1}}}},
    {rank = {21,30},award={u={{gems=88,index=1}}}},
    },

    baseLeveling ={
{lv = 3, award={p={{p19=1,index=1}}}},
        {lv = 5, award={u={{gems=5,index=1}},p={{p19=3,index=2}}}},
        {lv = 10, award={u={{gems=10,index=1}},p={{p19=5,index=2}}}},
        {lv = 15, award={u={{gems=15,index=1}},p={{p19=10,index=2}}}},
        {lv = 16, award={u={{gems=20,index=1}},p={{p20=1,index=2}}}},
        {lv = 17, award={u={{gems=25,index=1}},p={{p20=1,index=2}}}},
        {lv = 18, award={u={{gems=30,index=1}},p={{p20=2,index=2}}}},
        {lv = 19, award={u={{gems=40,index=1}},p={{p20=3,index=2}}}},
        {lv = 20, award={u={{gems=50,index=1}},p={{p20=5,index=2},{p5=1,index=3}}}}
    },
    -- -- 幸运转盘
    -- wheelFortune = {
    --     type = 1,
    --     sortId = 60,
    --     serverreward = {            
    --         -- 排行奖励（前10名）
    --         r = {
    --             {p={p20=20},u={gems=1000}},--1
    --             {p={p20=15},u={gems=600}},--2
    --             {p={p20=12},u={gems=400}},--3
    --             {p={p20=8},u={gems=300}},--4~5
    --             {p={p20=6},u={gems=200}},--6~10
    --         },
    --         -- 奖池
    --         pool={u={{r1=80000,index=1},{r2=60000,index=2},{r3=40000,index=3},{r4=20000,index=4},{gems=25,index=5},{energy=5,index=6},{honors=50,index=7},{exp=4000,index=8},},o={{a10004=1,index=9},{a10014=1,index=10},{a10024=1,index=11},{a10034=1,index=12},}},
    --         -- 资源对应的积分数
    --         res4point = {
    --             r1={{100},{1,1,1},{2,3,4}},
    --             r2={{100},{1,1,1},{2,3,4}},
    --             r3={{100},{1,1,1},{2,3,4}},
    --             r4={{100},{1,1,1},{2,3,4}},
    --             gems={{100},{1,1,1},{4,5,6}},
    --             energy={{100},{1,1,1},{3,4,5}},
    --             honors={{100},{1,1,1},{2,3,4}},
    --             exp={{100},{1,1,1},{3,4,5}},
    --             a10004={{100},{1,1,1},{5,6,7}},
    --             a10014={{100},{1,1,1},{7,8,9}},
    --             a10024={{100},{1,1,1},{9,10,11}},
    --             a10034={{100},{1,1,1},{13,14,15}},
    --         },
    --         -- 进行排行需要的最低积分(后台)
    --         rankPoint = 200,
    --         -- 抽奖需要的金币
    --         lotteryConsume = 99,
    --         -- 积分对应的奖励 1是需要的积分，2号位是实际奖励
    --         pointReward = {20,{p={p20=1,p13=1},}},
    --     }, 
    -- },

    -- 幸运转盘
    wheelFortune={
        type=1,
        sortId=60,
        serverreward={
            --排行奖励（前10名）
            r={
                {p={p90=1,p1=2}},--1
                {p={p90=1,p1=1}},--2
                {p={p267=3,p1=1}},--3
                {p={p267=2,p19=40}},--4~5
                {p={p267=1,p19=30}},--6~10
            },
            --奖池
            pool={e={{p1=1,index=1},{p2=1,index=2},{p3=1,index=3},{p4=100,index=4},{p5=1,index=5},{p6=1,index=6},},p={{p267=1,index=7},{p266=1,index=8},},o={{a10004=1,index=9},{a10014=1,index=10},{a10024=1,index=11},{a10034=1,index=12},}},
            --资源对应的积分数
            res4point={
                accessory_p1={{100},{1,1,1},{4,5,6}},
                accessory_p2={{100},{1,1,1},{2,3,4}},
                accessory_p3={{100},{1,1,1},{1,2,3}},
                accessory_p4={{100},{1,1,1},{1,2,3}},
                accessory_p5={{100},{1,1,1},{10,11,12}},
                accessory_p6={{100},{1,1,1},{2,3,4}},
                props_p267={{100},{1,1,1},{20,21,22}},
                props_p266={{100},{1,1,1},{8,9,10}},
                troops_a10004={{100},{1,1,1},{3,4,5}},
                troops_a10014={{100},{1,1,1},{4,5,6}},
                troops_a10024={{100},{1,1,1},{6,7,8}},
                troops_a10034={{100},{1,1,1},{8,9,10}},
            },
            --进行排行需要的最低积分(后台）
            rankPoint=200,
            --抽奖需要的金币
            lotteryConsume=199,
            -- 积分对应的奖励 1是需要的积分，2号位是实际奖励
            pointReward = {20,{props_p20=1,props_p13=1}}
        },
    },

    -- 军团冲级奖励
    allianceLevel ={
        {rank={1},
         award={
                {p={{p19=60,index=1}},u={{gems=500,index=2}}},
                {p={{p19=40,index=1},{p5=1,index=2}}}
            }
        },
        {rank={2},
        award={
               {p={{p19=40,index=1}},u={{gems=300,index=2}}},
               {p={{p19=30,index=1},{p43=1,index=2}}}
            }
        },
        {rank={3},
        award={
                {p={{p19=30,index=1}},u={{gems=200,index=2}}},
                {p={{p19=20,index=1},{p42=1,index=2}}}
            }
        },
        {rank={4,5},
        award={
                {p={{p19=20,index=1}},u={{gems=100,index=2}}},
                {p={{p19=10,index=1},{p11=1,index=2}}}
            }
        },
        {rank={6,10},
        award={
                {p={{p19=10,index=1}},u={{gems=50,index=2}}},
                {p={{p19=3,index=1},{p47=1,index=2}}}
            }
        },
    },


    -- 军团战斗力争霸奖励
    allianceFight ={
        {rank = 1, award={u={gems=6000}}},
        {rank = 2, award={u={gems=3000}}},
        {rank = 3, award={u={gems=2000}}},
    },
    
    personalHonor ={
        {rank={1},award={p={{p20=20,index=1}},o={{a10004=20,index=2}}}}, 
        {rank={2},award={p={{p20=15,index=1}},o={{a10004=15,index=2}}}}, 
        {rank={3},award={p={{p20=10,index=1}},o={{a10004=10,index=2}}}}, 
        {rank={4,5},award={p={{p20=5,index=1}},o={{a10004=5,index=2}}}}, 
        {rank={6,10},award={p={{p20=3,index=1}},o={{a10004=3,index=2}}}}, 
    },
    
    personalCheckPoint ={
        {rank={1},award={u={{gems=500,index=1},{honors=800,index=2}}}}, 
        {rank={2},award={u={{gems=300,index=1},{honors=500,index=2}}}}, 
        {rank={3},award={u={{gems=200,index=1},{honors=300,index=2}}}}, 
        {rank={4,5},award={u={{gems=100,index=1},{honors=200,index=2}}}}, 
    },
    totalRecharge = {
        reward={
            {p={{p89=1,index=1},{p10=3,index=2}}}, 
            {e={{p6=5,index=1},{p2=10,index=2}}}, 
            {p={{p89=5,index=1}},e={{p3=15,index=2}}}, 
            {e={{f0=2,index=1}},p={{p1=1,index=2}}},
            {p={{p90=2,index=1},{p20=10,index=2}}}, 
        }, 
        cost = {1000,3000,9000,17000,26000},  
    },
    
    -- 水晶周
    crystalHarvest = {
        type = 1,
        sortId = 100,

        -- 每天可以领取一次【角色等级】* 3000 的【水晶】
        baseGoldNum = 3000, 

        -- 水晶产量翻倍
        baseGoldGrow = {gold=2}, 

        -- 活动期间内，可以购买 5 次折扣礼包
        props={
            p96=0.299,
        },
        maxCount={
            p96=10,
        },

    },
    --装备探索（碎片版本）
    equipSearch={
        -- 排行奖励（前10名）
        r = {
            {p={p90=2},e={f0=3}},--1 先进配件箱 * 2  万能碎片 * 3
            {p={p90=1},e={f0=3}},--2 先进配件箱 * 1  万能碎片 * 3
            {p={p90=1},e={f0=1}},--3 先进配件箱 * 1  万能碎片 * 1
            {p={p89=2},e={f0=1}},--4~5 精良配件箱 * 2  万能碎片 * 1
            {p={p89=2},e={p6=5}},--6~10 精良配件箱 * 2 工具箱 * 5
        },
        -- 进行排行需要的最低积分
        rankPoint = 300,
        -- 奖池
        pool={
            {index=1,aid="f2",content={    p={ {p181=1,index=1,wz={6,10},},    {p193=1,index=2,wz={6,10},},    {p205=1,index=3,wz={6,10},},    {p217=1,index=4,wz={6,10},},    },},},  
            {index=2,aid="f6",content={ p={ {p184=1,index=1,wz={6,10},},    {p196=1,index=2,wz={6,10},},    {p208=1,index=3,wz={6,10},},    {p220=1,index=4,wz={6,10},},    },},},  
            {index=3,aid="f10",content={    p={ {p187=1,index=1,wz={6,10},},    {p199=1,index=2,wz={6,10},},    {p211=1,index=3,wz={6,10},},    {p223=1,index=4,wz={6,10},},    },},},  
            {index=4,aid="f14",content={    p={ {p190=1,index=1,wz={6,10},},    {p202=1,index=2,wz={6,10},},    {p214=1,index=3,wz={6,10},},    {p226=1,index=4,wz={6,10},},    },},},  
            {index=5,aid="p3",content={ e={ {p3=5,index=1,wz={3,5},},               },},},  
            {index=6,aid="f18",content={    p={ {p181=2,index=1,wz={12,20},},   {p193=2,index=2,wz={12,20},},   {p205=2,index=3,wz={12,20},},   {p217=2,index=4,wz={12,20},},   },},},  
            {index=7,aid="f22",content={    p={ {p184=2,index=1,wz={12,20},},   {p196=2,index=2,wz={12,20},},   {p208=2,index=3,wz={12,20},},   {p220=2,index=4,wz={12,20},},   },},},  
            {index=8,aid="f26",content={    p={ {p187=2,index=1,wz={12,20},},   {p199=2,index=2,wz={12,20},},   {p211=2,index=3,wz={12,20},},   {p223=2,index=4,wz={12,20},},   },},},  
            {index=9,aid="f30",content={    p={ {p190=2,index=1,wz={12,20},},   {p202=2,index=2,wz={12,20},},   {p214=2,index=3,wz={12,20},},   {p226=2,index=4,wz={12,20},},   },},},  
            {index=10,aid="p2",content={    e={ {p2=2,index=1,wz={6,10},},              },},},  
            {index=11,aid="f34",content={   p={ {p181=3,index=1,wz={18,30},},   {p193=3,index=2,wz={18,30},},   {p205=3,index=3,wz={18,30},},   {p217=3,index=4,wz={18,30},},   },},},  
            {index=12,aid="f38",content={   p={ {p184=3,index=1,wz={18,30},},   {p196=3,index=2,wz={18,30},},   {p208=3,index=3,wz={18,30},},   {p220=3,index=4,wz={18,30},},   },},},  
            {index=13,aid="f42",content={   p={ {p187=3,index=1,wz={18,30},},   {p199=3,index=2,wz={18,30},},   {p211=3,index=3,wz={18,30},},   {p223=3,index=4,wz={18,30},},   },},},  
            {index=14,aid="f46",content={   p={ {p190=3,index=1,wz={18,30},},   {p202=3,index=2,wz={18,30},},   {p214=3,index=3,wz={18,30},},   {p226=3,index=4,wz={18,30},},   },},},  
            {index=15,aid="p1",content={    e={ {p1=1,index=1,wz={6,10},},              },},},  
            {index=16,aid="f51",content={   p={ {p182=1,index=1,wz={24,40},},   {p194=1,index=2,wz={24,40},},   {p206=1,index=3,wz={24,40},},   {p218=1,index=4,wz={24,40},},   },},},  
            {index=17,aid="f55",content={   p={ {p185=1,index=1,wz={24,40},},   {p197=1,index=2,wz={24,40},},   {p209=1,index=3,wz={24,40},},   {p221=1,index=4,wz={24,40},},   },},},  
            {index=18,aid="f59",content={   p={ {p188=1,index=1,wz={24,40},},   {p200=1,index=2,wz={24,40},},   {p212=1,index=3,wz={24,40},},   {p224=1,index=4,wz={24,40},},   },},},  
            {index=19,aid="f63",content={   p={ {p191=1,index=1,wz={24,40},},   {p203=1,index=2,wz={24,40},},   {p215=1,index=3,wz={24,40},},   {p227=1,index=4,wz={24,40},},   },},},  
            {index=20,aid="f0",content={    p={ {p230=1,index=1,wz={48,80},},               },},},  
        },        
        --探索1次花费
        oneCost={1,58},
        --探索10次花费   91折
        tenCost={10,{580,528},},
        
    },

    --装备探索 材料版本
    equipSearchForQihoo={
        -- 排行奖励（前10名）
        r = {
            {p={p90=2},e={f0=3}},--1 先进配件箱 * 2  万能碎片 * 3
            {p={p90=1},e={f0=3}},--2 先进配件箱 * 1  万能碎片 * 3
            {p={p90=1},e={f0=1}},--3 先进配件箱 * 1  万能碎片 * 1
            {p={p89=2},e={f0=1}},--4~5 精良配件箱 * 2  万能碎片 * 1
            {p={p89=2},e={p6=5}},--6~10 精良配件箱 * 2 工具箱 * 5
        },
        -- 进行排行需要的最低积分
        rankPoint = 300,
        -- 奖池
        pool={
           {index=1,aid="p3",content={ e={ {p3=5,index=1,wz={3,5},},    },},}, 
           {index=2,aid="p6",content={ e={ {p6=1,index=1,wz={3,5},},    },},}, 
           {index=3,aid="p3",content={ e={ {p3=10,index=1,wz={6,10},},    },},}, 
           {index=4,aid="p6",content={ e={ {p6=3,index=1,wz={9,15},},    },},}, 
           {index=5,aid="p3",content={ e={ {p3=15,index=1,wz={9,15},},    },},}, 
           {index=6,aid="f18",content={ p={ {p181=1,index=1,wz={24,40},}, {p193=1,index=2,wz={24,40},}, {p205=1,index=3,wz={24,40},}, {p217=1,index=4,wz={24,40},}, },},}, 
           {index=7,aid="p2",content={ e={ {p2=2,index=1,wz={6,10},},    },},}, 
           {index=8,aid="f22",content={ p={ {p184=1,index=1,wz={24,40},}, {p196=1,index=2,wz={24,40},}, {p208=1,index=3,wz={24,40},}, {p220=1,index=4,wz={24,40},}, },},}, 
           {index=9,aid="p2",content={ e={ {p2=4,index=1,wz={12,20},},    },},}, 
           {index=10,aid="f26",content={ p={ {p187=1,index=1,wz={24,40},}, {p199=1,index=2,wz={24,40},}, {p211=1,index=3,wz={24,40},}, {p223=1,index=4,wz={24,40},}, },},}, 
           {index=11,aid="p2",content={ e={ {p2=6,index=1,wz={18,30},},    },},}, 
           {index=12,aid="f30",content={ p={ {p190=1,index=1,wz={24,40},}, {p202=1,index=2,wz={24,40},}, {p214=1,index=3,wz={24,40},}, {p226=1,index=4,wz={24,40},}, },},}, 
           {index=13,aid="f51",content={ p={ {p182=1,index=1,wz={24,40},}, {p194=1,index=2,wz={24,40},}, {p206=1,index=3,wz={24,40},}, {p218=1,index=4,wz={24,40},}, },},}, 
           {index=14,aid="p1",content={ e={ {p1=1,index=1,wz={6,10},},    },},}, 
           {index=15,aid="f55",content={ p={ {p185=1,index=1,wz={24,40},}, {p197=1,index=2,wz={24,40},}, {p209=1,index=3,wz={24,40},}, {p221=1,index=4,wz={24,40},}, },},}, 
           {index=16,aid="p1",content={ e={ {p1=2,index=1,wz={12,20},},    },},}, 
           {index=17,aid="f59",content={ p={ {p188=1,index=1,wz={24,40},}, {p200=1,index=2,wz={24,40},}, {p212=1,index=3,wz={24,40},}, {p224=1,index=4,wz={24,40},}, },},}, 
           {index=18,aid="p1",content={ e={ {p1=3,index=1,wz={18,30},},    },},}, 
           {index=19,aid="f63",content={ p={ {p191=1,index=1,wz={24,40},}, {p203=1,index=2,wz={24,40},}, {p215=1,index=3,wz={24,40},}, {p227=1,index=4,wz={24,40},}, },},}, 
           {index=20,aid="f0",content={ p={ {p230=1,index=1,wz={48,80},},    },},}, 
        },        
        --探索1次花费
        oneCost={1,58},
        --探索10次花费   91折
        tenCost={10,{580,528},},
        
    },

    --充值返利
    rechargeRebate={
        discount=0.2
    },

    --巨兽再现
    monsterComeback = {
        ["raycommon"]={
            type = 1, 
            sortId = 130, 
            serverreward={
                pool={{100},{16,16,21,21,8,8,8,8,},{{"part1",2},{"part1",4},{"part2",2},{"part2",4},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},}},
                upgradePartConsume=20,
                tank4point = {a10001=5,a10002=190,a10003=5200,a10004=61000,a10005=1000000,a10011=11,a10012=420,a10013=9000,a10014=93000,a10015=1000000,a10021=26,a10022=880,a10023=15000,a10024=100000,a10025=2000000,a10031=50,a10032=1000,a10033=20000,a10034=170000,a10035=2000000,a10043=4400000,a10053=5900000,a10073=5900000,a10063=4400000,a10082=9000000,a10093=1000000,a10044=10000000,a10054=11000000,a10064=12000000,a10074=13000000,a10083=15000000,},
                gemCost=38,
                pointCost=30000000,
            },
        },
        ["3"]={
            type = 1, 
            sortId = 130, 
            serverreward={ 
                pool={{100},{16,16,20,20,7,7,7,7,},{{"part1",1},{"part1",2},{"part2",1},{"part2",2},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},}}, 
                upgradePartConsume=20, 
                tank4point = {a10001=5,a10002=190,a10003=5200,a10004=61000,a10005=1000000,a10011=11,a10012=420,a10013=9000,a10014=93000,a10015=1000000,a10021=26,a10022=880,a10023=15000,a10024=100000,a10025=2000000,a10031=50,a10032=1000,a10033=20000,a10034=170000,a10035=2000000,a10043=4400000,a10053=5900000,a10073=5900000,a10063=4400000,a10082=9000000,},
                gemCost=38, 
                pointCost=30000000, 
            }, 
        },
        ["efunandroidtw"]={
            type = 1, 
            sortId = 130, 
            serverreward={ 
                pool={{100},{16,16,20,20,7,7,7,7,},{{"part1",1},{"part1",2},{"part2",1},{"part2",2},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},}}, 
                upgradePartConsume=20, 
                tank4point = {a10001=5,a10002=190,a10003=5200,a10004=61000,a10005=1000000,a10011=11,a10012=420,a10013=9000,a10014=93000,a10015=1000000,a10021=26,a10022=880,a10023=15000,a10024=100000,a10025=2000000,a10031=50,a10032=1000,a10033=20000,a10034=170000,a10035=2000000,a10043=4400000,a10053=5900000,a10073=5900000,a10063=4400000,a10082=9000000,},
                gemCost=38, 
                pointCost=30000000, 
            }, 
        },
    },
 --老玩家回归
oldUserReturn = {
serverreward={
box1={
l10={u={{r1=4838400,index=1},{r2=3628800,index=2},{r3=2419200,index=3},{r4=1209600,index=4},{gold=1209600,index=5},{exp=812420,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l11={u={{r1=5322240,index=1},{r2=3991680,index=2},{r3=2661120,index=3},{r4=1330560,index=4},{gold=1330560,index=5},{exp=995400,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l12={u={{r1=5829120,index=1},{r2=4371840,index=2},{r3=2914560,index=3},{r4=1457280,index=4},{gold=1457280,index=5},{exp=1204000,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l13={u={{r1=6359040,index=1},{r2=4769280,index=2},{r3=3179520,index=3},{r4=1589760,index=4},{gold=1589760,index=5},{exp=1439900,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l14={u={{r1=6912000,index=1},{r2=5184000,index=2},{r3=3456000,index=3},{r4=1728000,index=4},{gold=1728000,index=5},{exp=1704780,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l15={u={{r1=7488000,index=1},{r2=5616000,index=2},{r3=3744000,index=3},{r4=1872000,index=4},{gold=1872000,index=5},{exp=2000320,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l16={u={{r1=8087040,index=1},{r2=6065280,index=2},{r3=4043520,index=3},{r4=2021760,index=4},{gold=2021760,index=5},{exp=2328200,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l17={u={{r1=8709120,index=1},{r2=6531840,index=2},{r3=4354560,index=3},{r4=2177280,index=4},{gold=2177280,index=5},{exp=2690100,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l18={u={{r1=9354240,index=1},{r2=7015680,index=2},{r3=4677120,index=3},{r4=2338560,index=4},{gold=2338560,index=5},{exp=3087700,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l19={u={{r1=10022400,index=1},{r2=7516800,index=2},{r3=5011200,index=3},{r4=2505600,index=4},{gold=2505600,index=5},{exp=3522680,index=6},{gems=200,index=7},},p={{p268=2,index=8},},h={{s7=10,index=9},},w={{c34=1,index=10},}},
l20={u={{r1=10713600,index=1},{r2=8035200,index=2},{r3=5356800,index=3},{r4=2678400,index=4},{gold=2678400,index=5},{exp=3996720,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l21={u={{r1=11427840,index=1},{r2=8570880,index=2},{r3=5713920,index=3},{r4=2856960,index=4},{gold=2856960,index=5},{exp=4511500,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l22={u={{r1=12165120,index=1},{r2=9123840,index=2},{r3=6082560,index=3},{r4=3041280,index=4},{gold=3041280,index=5},{exp=5068700,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l23={u={{r1=12925440,index=1},{r2=9694080,index=2},{r3=6462720,index=3},{r4=3231360,index=4},{gold=3231360,index=5},{exp=5670000,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l24={u={{r1=13708800,index=1},{r2=10281600,index=2},{r3=6854400,index=3},{r4=3427200,index=4},{gold=3427200,index=5},{exp=6317080,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l25={u={{r1=14515200,index=1},{r2=10886400,index=2},{r3=7257600,index=3},{r4=3628800,index=4},{gold=3628800,index=5},{exp=7011620,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l26={u={{r1=15344640,index=1},{r2=11508480,index=2},{r3=7672320,index=3},{r4=3836160,index=4},{gold=3836160,index=5},{exp=7755300,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l27={u={{r1=16197120,index=1},{r2=12147840,index=2},{r3=8098560,index=3},{r4=4049280,index=4},{gold=4049280,index=5},{exp=8549800,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l28={u={{r1=17072640,index=1},{r2=12804480,index=2},{r3=8536320,index=3},{r4=4268160,index=4},{gold=4268160,index=5},{exp=9396800,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l29={u={{r1=17971200,index=1},{r2=13478400,index=2},{r3=8985600,index=3},{r4=4492800,index=4},{gold=4492800,index=5},{exp=10297980,index=6},{gems=300,index=7},},p={{p269=2,index=8},},h={{s7=20,index=9},},w={{c34=1,index=10},}},
l30={u={{r1=18892800,index=1},{r2=14169600,index=2},{r3=9446400,index=3},{r4=4723200,index=4},{gold=4723200,index=5},{exp=11255020,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l31={u={{r1=19837440,index=1},{r2=14878080,index=2},{r3=9918720,index=3},{r4=4959360,index=4},{gold=4959360,index=5},{exp=12269600,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l32={u={{r1=20805120,index=1},{r2=15603840,index=2},{r3=10402560,index=3},{r4=5201280,index=4},{gold=5201280,index=5},{exp=13343400,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l33={u={{r1=21795840,index=1},{r2=16346880,index=2},{r3=10897920,index=3},{r4=5448960,index=4},{gold=5448960,index=5},{exp=14478100,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l34={u={{r1=22809600,index=1},{r2=17107200,index=2},{r3=11404800,index=3},{r4=5702400,index=4},{gold=5702400,index=5},{exp=15675380,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l35={u={{r1=23846400,index=1},{r2=17884800,index=2},{r3=11923200,index=3},{r4=5961600,index=4},{gold=5961600,index=5},{exp=16936920,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l36={u={{r1=24902400,index=1},{r2=18679680,index=2},{r3=12453120,index=3},{r4=6226560,index=4},{gold=6226560,index=5},{exp=18264400,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l37={u={{r1=25989120,index=1},{r2=19491840,index=2},{r3=12994560,index=3},{r4=6497280,index=4},{gold=6497280,index=5},{exp=19659500,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l38={u={{r1=27095040,index=1},{r2=20321280,index=2},{r3=13547520,index=3},{r4=6773760,index=4},{gold=6773760,index=5},{exp=21123900,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l39={u={{r1=28224000,index=1},{r2=21168000,index=2},{r3=14112000,index=3},{r4=7056000,index=4},{gold=7056000,index=5},{exp=22659280,index=6},{gems=400,index=7},},p={{p269=2,index=8},},h={{s7=30,index=9},},w={{c34=1,index=10},}},
l40={u={{r1=29376000,index=1},{r2=22032000,index=2},{r3=14688000,index=3},{r4=7344000,index=4},{gold=7344000,index=5},{exp=24267320,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l41={u={{r1=30451200,index=1},{r2=22905600,index=2},{r3=15283200,index=3},{r4=7632000,index=4},{gold=7632000,index=5},{exp=25949700,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l42={u={{r1=31824000,index=1},{r2=23808000,index=2},{r3=15888000,index=3},{r4=7958400,index=4},{gold=7958400,index=5},{exp=27708100,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l43={u={{r1=32918400,index=1},{r2=24748800,index=2},{r3=16492800,index=3},{r4=8236800,index=4},{gold=8236800,index=5},{exp=29544200,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l44={u={{r1=34291200,index=1},{r2=25680000,index=2},{r3=17116800,index=3},{r4=8563200,index=4},{gold=8563200,index=5},{exp=31459680,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l45={u={{r1=35385600,index=1},{r2=26611200,index=2},{r3=17750400,index=3},{r4=8889600,index=4},{gold=8889600,index=5},{exp=33456220,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l46={u={{r1=36758400,index=1},{r2=27705600,index=2},{r3=18384000,index=3},{r4=9216000,index=4},{gold=9216000,index=5},{exp=35535500,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l47={u={{r1=38131200,index=1},{r2=28531200,index=2},{r3=19036800,index=3},{r4=9552000,index=4},{gold=9552000,index=5},{exp=37699200,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l48={u={{r1=39504000,index=1},{r2=29625600,index=2},{r3=19728000,index=3},{r4=9878400,index=4},{gold=9878400,index=5},{exp=39949000,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l49={u={{r1=40876800,index=1},{r2=30720000,index=2},{r3=20380800,index=3},{r4=10204800,index=4},{gold=10204800,index=5},{exp=42286580,index=6},{gems=500,index=7},},p={{p269=2,index=8},},h={{s7=40,index=9},},w={{c34=1,index=10},}},
l50={u={{r1=42240000,index=1},{r2=31545600,index=2},{r3=21100800,index=3},{r4=10540800,index=4},{gold=10540800,index=5},{exp=44713620,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l51={u={{r1=43680000,index=1},{r2=32640000,index=2},{r3=21888000,index=3},{r4=10944000,index=4},{gold=10944000,index=5},{exp=47231800,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l52={u={{r1=45120000,index=1},{r2=33696000,index=2},{r3=22656000,index=3},{r4=11328000,index=4},{gold=11328000,index=5},{exp=49842800,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l53={u={{r1=46560000,index=1},{r2=34752000,index=2},{r3=23424000,index=3},{r4=11712000,index=4},{gold=11712000,index=5},{exp=52548300,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l54={u={{r1=47904000,index=1},{r2=35808000,index=2},{r3=24096000,index=3},{r4=12096000,index=4},{gold=12096000,index=5},{exp=55349980,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l55={u={{r1=49248000,index=1},{r2=36864000,index=2},{r3=24768000,index=3},{r4=12480000,index=4},{gold=12480000,index=5},{exp=58249520,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l56={u={{r1=50592000,index=1},{r2=37824000,index=2},{r3=25440000,index=3},{r4=12864000,index=4},{gold=12864000,index=5},{exp=73672200,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l57={u={{r1=51840000,index=1},{r2=38784000,index=2},{r3=26112000,index=3},{r4=13248000,index=4},{gold=13248000,index=5},{exp=140000000,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l58={u={{r1=53088000,index=1},{r2=39744000,index=2},{r3=26784000,index=3},{r4=13632000,index=4},{gold=13632000,index=5},{exp=210000000,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l59={u={{r1=54336000,index=1},{r2=40608000,index=2},{r3=27456000,index=3},{r4=14016000,index=4},{gold=14016000,index=5},{exp=280000000,index=6},{gems=600,index=7},},p={{p269=2,index=8},},h={{s7=50,index=9},},w={{c34=1,index=10},}},
l60={u={{r1=55488000,index=1},{r2=41472000,index=2},{r3=28032000,index=3},{r4=14304000,index=4},{gold=14304000,index=5},{exp=350000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l61={u={{r1=56640000,index=1},{r2=42336000,index=2},{r3=28608000,index=3},{r4=14592000,index=4},{gold=14592000,index=5},{exp=420000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l62={u={{r1=57696000,index=1},{r2=43200000,index=2},{r3=29184000,index=3},{r4=14880000,index=4},{gold=14880000,index=5},{exp=490000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l63={u={{r1=58752000,index=1},{r2=43968000,index=2},{r3=29760000,index=3},{r4=15168000,index=4},{gold=15168000,index=5},{exp=560000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l64={u={{r1=59808000,index=1},{r2=44736000,index=2},{r3=30336000,index=3},{r4=15456000,index=4},{gold=15456000,index=5},{exp=630000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l65={u={{r1=60768000,index=1},{r2=45504000,index=2},{r3=30816000,index=3},{r4=15744000,index=4},{gold=15744000,index=5},{exp=700000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l66={u={{r1=61728000,index=1},{r2=46176000,index=2},{r3=31296000,index=3},{r4=16032000,index=4},{gold=16032000,index=5},{exp=700000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l67={u={{r1=62592000,index=1},{r2=46848000,index=2},{r3=31776000,index=3},{r4=16320000,index=4},{gold=16320000,index=5},{exp=700000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l68={u={{r1=63456000,index=1},{r2=47520000,index=2},{r3=32256000,index=3},{r4=16608000,index=4},{gold=16608000,index=5},{exp=700000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l69={u={{r1=64320000,index=1},{r2=48192000,index=2},{r3=32736000,index=3},{r4=16896000,index=4},{gold=16896000,index=5},{exp=700000000,index=6},{gems=700,index=7},},p={{p270=2,index=8},},h={{s7=60,index=9},},w={{c34=1,index=10},}},
l70={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l71={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l72={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l73={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l74={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l75={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l76={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l77={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l78={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l79={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=800,index=7},},p={{p270=2,index=8},},h={{s7=70,index=9},},w={{c34=1,index=10},}},
l80={u={{r1=65088000,index=1},{r2=48768000,index=2},{r3=33216000,index=3},{r4=17184000,index=4},{gold=17184000,index=5},{exp=700000000,index=6},{gems=1000,index=7},},p={{p270=2,index=8},},h={{s7=100,index=9},},w={{c34=1,index=10},}},
},
            box2={u={{gems=200,index=1}},h={{s7=40,index=2}},w={{c34=1,index=3}},p={{p20=10,index=4}}},
            rewardTank=10124,
            staybehindreward ={ --ÎÞÓÃ
                {userinfo_gems=20,props_p20=1},
            },
            totalreward = { --ÎÞÓÃ
                {props_p19=1},
            },
            need = 2,
            minlevel = 10,
        },  
    },

    --配件进化，改造配件不降级的活动
    accessoryEvolution={
    [1]={  
    serverreward={
            maxBuyTime=3,
            moneyDecrease=0.15,
            originPrice=12000,
            price=3588
        }
    },
    [2]={  
    serverreward={
            maxBuyTime=3,
            moneyDecrease=0.15,
            originPrice=12000,
            price=3588
        }
    },
    [3]={  
    serverreward={
            maxBuyTime=3,
            moneyDecrease=0.15,
            originPrice=12000,
            price=2988
        }
    },
    },
    --攻击补给线伤害增加，重置补给线价格降低的活动
    accessoryFight={
        serverreward={
            reducePrice=0.5,
            powerAdd=0.3
        }
    },
    --军团金币捐献收益翻倍的活动
    allianceDonate={
        serverreward={
            percent=0.5
        }
    },
    equipSearchII={
        -- 排行奖励（前10名）
        r = {
            {p={p90=2},e={f0=3}},--1 先进配件箱 * 2  万能碎片 * 3
            {p={p90=1},e={f0=3}},--2 先进配件箱 * 1  万能碎片 * 3
            {p={p90=1},e={f0=1}},--3 先进配件箱 * 1  万能碎片 * 1
            {p={p89=2},e={f0=1}},--4~5 精良配件箱 * 2  万能碎片 * 1
            {p={p89=2},e={p6=5}},--6~10 精良配件箱 * 2 工具箱 * 5
        },
        -- 进行排行需要的最低积分
        rankPoint = 300,
        -- 奖池
        pool={
            {index=1,aid="f66",content={      p={ {p181=1,index=1,wz={6,10},},    {p193=1,index=2,wz={6,10},},    {p205=1,index=3,wz={6,10},},    {p217=1,index=4,wz={6,10}},   {p352=1,index=5,wz={6,10}},   {p356=1,index=6,wz={6,10}},    },},},  
            {index=2,aid="f74",content={      p={ {p184=1,index=1,wz={6,10},},    {p196=1,index=2,wz={6,10},},    {p208=1,index=3,wz={6,10},},    {p220=1,index=4,wz={6,10}},   {p360=1,index=5,wz={6,10}},   {p364=1,index=6,wz={6,10},    },},},},  
            {index=3,aid="f82",content={    p={ {p187=1,index=1,wz={6,10},},    {p199=1,index=2,wz={6,10},},    {p211=1,index=3,wz={6,10},},    {p223=1,index=4,wz={6,10}},   {p368=1,index=5,wz={6,10}},   {p372=1,index=6,wz={6,10}},     },},},  
            {index=4,aid="f90",content={    p={ {p190=1,index=1,wz={6,10},},    {p202=1,index=2,wz={6,10},},    {p214=1,index=3,wz={6,10},},    {p226=1,index=4,wz={6,10}},   {p376=1,index=5,wz={6,10}},   {p380=1,index=6,wz={6,10}},     },},},  
            {index=5,aid="p3",content={ e={ {p3=5,index=1,wz={3,5},},               },},},  
            {index=6,aid="f70",content={    p={ {p181=2,index=1,wz={12,20},},   {p193=2,index=2,wz={12,20},},   {p205=2,index=3,wz={12,20},},   {p217=2,index=4,wz={12,20}},   {p352=2,index=5,wz={12,20}},   {p356=2,index=6,wz={12,20}},   },},},  
            {index=7,aid="f78",content={    p={ {p184=2,index=1,wz={12,20},},   {p196=2,index=2,wz={12,20},},   {p208=2,index=3,wz={12,20},},   {p220=2,index=4,wz={12,20}},   {p360=2,index=5,wz={12,20}},   {p364=2,index=6,wz={12,20}},   },},},  
            {index=8,aid="f86",content={    p={ {p187=2,index=1,wz={12,20},},   {p199=2,index=2,wz={12,20},},   {p211=2,index=3,wz={12,20},},   {p223=2,index=4,wz={12,20}},   {p368=2,index=5,wz={12,20}},   {p372=2,index=6,wz={12,20}},   },},},  
            {index=9,aid="f94",content={    p={ {p190=2,index=1,wz={12,20},},   {p202=2,index=2,wz={12,20},},   {p214=2,index=3,wz={12,20},},   {p226=2,index=4,wz={12,20}},   {p376=2,index=5,wz={12,20}},   {p380=2,index=6,wz={12,20}},   },},},  
            {index=10,aid="p2",content={    e={ {p2=2,index=1,wz={6,10},},              },},},  
            {index=11,aid="f66",content={   p={ {p181=3,index=1,wz={18,30},},   {p193=3,index=2,wz={18,30},},   {p205=3,index=3,wz={18,30},},   {p217=3,index=4,wz={18,30}},   {p352=3,index=5,wz={18,30}},   {p356=3,index=6,wz={18,30}},   },},},  
            {index=12,aid="f74",content={   p={ {p184=3,index=1,wz={18,30},},   {p196=3,index=2,wz={18,30},},   {p208=3,index=3,wz={18,30},},   {p220=3,index=4,wz={18,30}},   {p360=3,index=5,wz={18,30}},   {p364=3,index=6,wz={18,30}},   },},},  
            {index=13,aid="f82",content={   p={ {p187=3,index=1,wz={18,30},},   {p199=3,index=2,wz={18,30},},   {p211=3,index=3,wz={18,30},},   {p223=3,index=4,wz={18,30}},   {p368=3,index=5,wz={18,30}},   {p372=3,index=6,wz={18,30}},   },},},  
            {index=14,aid="f90",content={   p={ {p190=3,index=1,wz={18,30},},   {p202=3,index=2,wz={18,30},},   {p214=3,index=3,wz={18,30},},   {p226=3,index=4,wz={18,30}},   {p376=3,index=5,wz={18,30}},   {p380=3,index=6,wz={18,30}},   },},},  
            {index=15,aid="p1",content={    e={ {p1=1,index=1,wz={6,10},},              },},},  
            {index=16,aid="f71",content={   p={ {p182=1,index=1,wz={24,40},},   {p194=1,index=2,wz={24,40},},   {p206=1,index=3,wz={24,40},},   {p218=1,index=4,wz={24,40}}, {p353=1,index=4,wz={24,40}}, {p357=1,index=4,wz={24,40},},   },},},  
            {index=17,aid="f79",content={   p={ {p185=1,index=1,wz={24,40},},   {p197=1,index=2,wz={24,40},},   {p209=1,index=3,wz={24,40},},   {p221=1,index=4,wz={24,40}}, {p361=1,index=4,wz={24,40}}, {p365=1,index=4,wz={24,40},},   },},},  
            {index=18,aid="f87",content={   p={ {p188=1,index=1,wz={24,40},},   {p200=1,index=2,wz={24,40},},   {p212=1,index=3,wz={24,40},},   {p224=1,index=4,wz={24,40}},     {p369=1,index=4,wz={24,40}}, {p373=1,index=4,wz={24,40},},   },},},  
            {index=19,aid="f95",content={   p={ {p191=1,index=1,wz={24,40},},   {p203=1,index=2,wz={24,40},},   {p215=1,index=3,wz={24,40},},   {p227=1,index=4,wz={24,40}},     {p377=1,index=4,wz={24,40}}, {p381=1,index=4,wz={24,40},},   },},},  
            {index=20,aid="f0",content={    p={ {p230=1,index=1,wz={48,80},},               },},},  
        },  
        showIconList={p={{p230=1,index=1},{p230=1,index=1},{p227=1,index=1},{p562=1,index=1},},},
        --探索1次花费
        oneCost={1,58},
        --探索10次花费   91折
        tenCost={10,{580,528},},
        
    },

    tendaysLogin=
    {
        award={
            {award={u={{gems=1000,index=1}},p={{p2=1,index=2},{p272=1,index=3}},o={{a10002=5,index=4}}}},
            {award={u={{gems=1000,index=1}},p={{p20=5,index=2},{p272=5,index=3}},o={{a10003=10,index=4}}}},
            {award={u={{gems=500,index=1}},p={{p15=1,index=2},{p47=5,index=3},{p102=1,index=4}}}},
            {award={u={{gems=500,index=1}},p={{p14=3,index=2},{p272=6,index=3}},o={{a10013=20,index=4}}}},
            {award={u={{gems=500,index=1}},p={{p3=1,index=2},{p47=5,index=3},{p118=1,index=4}}}},
            {award={u={{gems=600,index=1}},p={{p19=100,index=2},{p273=2,index=3}},o={{a10023=30,index=4}}}},
            {award={u={{gems=700,index=1}},p={{p20=10,index=2},{p47=10,index=3},{p106=1,index=4}}}},
            {award={u={{gems=800,index=1}},p={{p16=1,index=2},{p273=3,index=3}},o={{a10033=50,index=4}}}},
            {award={u={{gems=900,index=1}},p={{p45=1,index=2},{p47=10,index=3},{p154=1,index=4}}}},
            {award={u={{gems=1000,index=1}},p={{p5=1,index=2},{p274=1,index=3}},o={{a10004=50,index=4}}}},
        },

    },


     equipSearchIII={
        -- 排行奖励（前10名）
        r = {
            {p={p90=2},e={f0=3}},--1 先进配件箱 * 2  万能碎片 * 3
            {p={p90=1},e={f0=3}},--2 先进配件箱 * 1  万能碎片 * 3
            {p={p90=1},e={f0=1}},--3 先进配件箱 * 1  万能碎片 * 1
            {p={p89=2},e={f0=1}},--4~5 精良配件箱 * 2  万能碎片 * 1
            {p={p89=2},e={p6=5}},--6~10 精良配件箱 * 2 工具箱 * 5
        },
        -- 进行排行需要的最低积分
        rankPoint = 300,
-- 奖池
        pool={
        {index=1,aid="f98",content={p={{p181=1,index=1,wz={6,10},},{p193=1,index=2,wz={6,10},},{p205=1,index=3,wz={6,10},},{p217=1,index=4,wz={6,10}},{p352=1,index=5,wz={6,10}},{p356=1,index=6,wz={6,10}},{p533=1,index=7,wz={6,10}},{p537=1,index=8,wz={6,10}},},},},
        {index=2,aid="f106",content={p={{p184=1,index=1,wz={6,10},},{p196=1,index=2,wz={6,10},},{p208=1,index=3,wz={6,10},},{p220=1,index=4,wz={6,10}},{p360=1,index=5,wz={6,10}},{p364=1,index=6,wz={6,10}},{p541=1,index=7,wz={6,10}},{p545=1,index=8,wz={6,10}},},},},
        {index=3,aid="f114",content={p={{p187=1,index=1,wz={6,10},},{p199=1,index=2,wz={6,10},},{p211=1,index=3,wz={6,10},},{p223=1,index=4,wz={6,10}},{p368=1,index=5,wz={6,10}},{p372=1,index=6,wz={6,10}},{p549=1,index=7,wz={6,10}},{p553=1,index=8,wz={6,10}},},},},
        {index=4,aid="f122",content={p={{p190=1,index=1,wz={6,10},},{p202=1,index=2,wz={6,10},},{p214=1,index=3,wz={6,10},},{p226=1,index=4,wz={6,10}},{p376=1,index=5,wz={6,10}},{p380=1,index=6,wz={6,10}},{p557=1,index=7,wz={6,10}},{p561=1,index=8,wz={6,10}},},},},
        {index=5,aid="p3",content={e={{p3=5,index=1,wz={3,5},},},},},
        {index=6,aid="f98",content={p={{p181=2,index=1,wz={12,20},},{p193=2,index=2,wz={12,20},},{p205=2,index=3,wz={12,20},},{p217=2,index=4,wz={12,20}},{p352=2,index=5,wz={12,20}},{p356=2,index=6,wz={12,20}},{p533=2,index=7,wz={6,10}},{p537=2,index=8,wz={6,10}}},},},
        {index=7,aid="f106",content={p={{p184=2,index=1,wz={12,20},},{p196=2,index=2,wz={12,20},},{p208=2,index=3,wz={12,20},},{p220=2,index=4,wz={12,20}},{p360=2,index=5,wz={12,20}},{p364=2,index=6,wz={12,20}},{p541=2,index=7,wz={6,10}},{p545=2,index=8,wz={6,10}}},},},
        {index=8,aid="f114",content={p={{p187=2,index=1,wz={12,20},},{p199=2,index=2,wz={12,20},},{p211=2,index=3,wz={12,20},},{p223=2,index=4,wz={12,20}},{p368=2,index=5,wz={12,20}},{p372=2,index=6,wz={12,20}},{p549=2,index=7,wz={6,10}},{p553=2,index=8,wz={6,10}}},},},
        {index=9,aid="f122",content={p={{p190=2,index=1,wz={12,20},},{p202=2,index=2,wz={12,20},},{p214=2,index=3,wz={12,20},},{p226=2,index=4,wz={12,20}},{p376=2,index=5,wz={12,20}},{p380=2,index=6,wz={12,20}},{p557=2,index=7,wz={6,10}},{p561=2,index=8,wz={6,10}}},},},
        {index=10,aid="p2",content={e={{p2=2,index=1,wz={6,10},},},},},
        {index=11,aid="f98",content={p={{p181=3,index=1,wz={18,30},},{p193=3,index=2,wz={18,30},},{p205=3,index=3,wz={18,30},},{p217=3,index=4,wz={18,30}},{p352=3,index=5,wz={18,30}},{p356=3,index=6,wz={18,30}},{p533=3,index=7,wz={6,10}},{p537=3,index=8,wz={6,10}}},},},
        {index=12,aid="f106",content={p={{p184=3,index=1,wz={18,30},},{p196=3,index=2,wz={18,30},},{p208=3,index=3,wz={18,30},},{p220=3,index=4,wz={18,30}},{p360=3,index=5,wz={18,30}},{p364=3,index=6,wz={18,30}},{p541=3,index=7,wz={6,10}},{p545=3,index=8,wz={6,10}}},},},
        {index=13,aid="f114",content={p={{p187=3,index=1,wz={18,30},},{p199=3,index=2,wz={18,30},},{p211=3,index=3,wz={18,30},},{p223=3,index=4,wz={18,30}},{p368=3,index=5,wz={18,30}},{p372=3,index=6,wz={18,30}},{p549=3,index=7,wz={6,10}},{p553=3,index=8,wz={6,10}}},},},
        {index=14,aid="f122",content={p={{p190=3,index=1,wz={18,30},},{p202=3,index=2,wz={18,30},},{p214=3,index=3,wz={18,30},},{p226=3,index=4,wz={18,30}},{p376=3,index=5,wz={18,30}},{p380=3,index=6,wz={18,30}},{p557=3,index=7,wz={6,10}},{p561=3,index=8,wz={6,10}}},},},
        {index=15,aid="p1",content={e={{p1=1,index=1,wz={6,10},},},},},
        {index=16,aid="f99",content={p={{p182=1,index=1,wz={24,40},},{p194=1,index=2,wz={24,40},},{p206=1,index=3,wz={24,40},},{p218=1,index=4,wz={24,40}},{p353=1,index=4,wz={24,40}},{p357=1,index=4,wz={24,40}},{p534=1,index=7,wz={24,40}},{p538=1,index=8,wz={24,40}}},},},
        {index=17,aid="f107",content={p={{p185=1,index=1,wz={24,40},},{p197=1,index=2,wz={24,40},},{p209=1,index=3,wz={24,40},},{p221=1,index=4,wz={24,40}},{p361=1,index=4,wz={24,40}},{p365=1,index=4,wz={24,40}},{p542=1,index=7,wz={24,40}},{p546=1,index=8,wz={24,40}}},},},
        {index=18,aid="f115",content={p={{p188=1,index=1,wz={24,40},},{p200=1,index=2,wz={24,40},},{p212=1,index=3,wz={24,40},},{p224=1,index=4,wz={24,40}},{p369=1,index=4,wz={24,40}},{p373=1,index=4,wz={24,40}},{p550=1,index=7,wz={24,40}},{p554=1,index=8,wz={24,40}}},},},
        {index=19,aid="f123",content={p={{p191=1,index=1,wz={24,40},},{p203=1,index=2,wz={24,40},},{p215=1,index=3,wz={24,40},},{p227=1,index=4,wz={24,40}},{p377=1,index=4,wz={24,40}},{p381=1,index=4,wz={24,40}},{p558=1,index=7,wz={24,40}},{p562=1,index=8,wz={24,40}}},},},
        {index=20,aid="f0",content={p={{p230=1,index=1,wz={48,80},},},},},
        },   
        
        showIconList={p={{p230=1,index=1},{p534=1,index=11},{p538=1,index=12},{p542=1,index=13},{p546=1,index=14},{p550=1,index=15},{p554=1,index=16},{p558=1,index=17},{p562=1,index=18},{p353=1,index=19},{p357=1,index=20},{p361=1,index=21},{p365=1,index=22},{p369=1,index=23},{p373=1,index=24},{p377=1,index=25},{p381=1,index=26},{p182=1,index=27},{p194=1,index=28},{p206=1,index=29},{p218=1,index=30},{p185=1,index=31},{p197=1,index=32},{p209=1,index=33},{p221=1,index=34},{p188=1,index=35},{p200=1,index=36},{p212=1,index=37},{p224=1,index=38},{p191=1,index=39},{p203=1,index=40},{p215=1,index=41},{p227=1,index=42},{p533=1,index=51},{p537=1,index=52},{p541=1,index=53},{p545=1,index=54},{p549=1,index=55},{p553=1,index=56},{p557=1,index=57},{p561=1,index=58},{p352=1,index=59},{p356=1,index=60},{p360=1,index=61},{p364=1,index=62},{p368=1,index=63},{p372=1,index=64},{p376=1,index=65},{p380=1,index=66},{p181=1,index=67},{p193=1,index=68},{p205=1,index=69},{p217=1,index=70},{p184=1,index=71},{p196=1,index=72},{p208=1,index=73},{p220=1,index=74},{p187=1,index=75},{p199=1,index=76},{p211=1,index=77},{p223=1,index=78},{p190=1,index=79},{p202=1,index=80},{p214=1,index=81},{p226=1,index=82},},e={{p1=1,index=50},{p2=2,index=91},{p3=5,index=92},},},

--探索1次花费
        oneCost={1,58},
        --探索10次花费   91折
        tenCost={10,{580,528},},
        
    },

     equipSearchIV={
        -- 排行奖励（前10名）
        r = {
            {p={p90=2},e={f0=3}},--1 先进配件箱 * 2  万能碎片 * 3
            {p={p90=1},e={f0=3}},--2 先进配件箱 * 1  万能碎片 * 3
            {p={p90=1},e={f0=1}},--3 先进配件箱 * 1  万能碎片 * 1
            {p={p89=2},e={f0=1}},--4~5 精良配件箱 * 2  万能碎片 * 1
            {p={p89=2},e={p6=5}},--6~10 精良配件箱 * 2 工具箱 * 5
        },
        -- 进行排行需要的最低积分
        rankPoint = 300,
-- 奖池
        pool={
        {index=1,aid="f98",content={p={{p181=1,index=1,wz={6,10},},{p193=1,index=2,wz={6,10},},{p205=1,index=3,wz={6,10},},{p217=1,index=4,wz={6,10}},{p352=1,index=5,wz={6,10}},{p356=1,index=6,wz={6,10}},{p533=1,index=7,wz={6,10}},{p537=1,index=8,wz={6,10}},},},},
        {index=2,aid="f106",content={p={{p184=1,index=1,wz={6,10},},{p196=1,index=2,wz={6,10},},{p208=1,index=3,wz={6,10},},{p220=1,index=4,wz={6,10}},{p360=1,index=5,wz={6,10}},{p364=1,index=6,wz={6,10}},{p541=1,index=7,wz={6,10}},{p545=1,index=8,wz={6,10}},},},},
        {index=3,aid="f114",content={p={{p187=1,index=1,wz={6,10},},{p199=1,index=2,wz={6,10},},{p211=1,index=3,wz={6,10},},{p223=1,index=4,wz={6,10}},{p368=1,index=5,wz={6,10}},{p372=1,index=6,wz={6,10}},{p549=1,index=7,wz={6,10}},{p553=1,index=8,wz={6,10}},},},},
        {index=4,aid="f122",content={p={{p190=1,index=1,wz={6,10},},{p202=1,index=2,wz={6,10},},{p214=1,index=3,wz={6,10},},{p226=1,index=4,wz={6,10}},{p376=1,index=5,wz={6,10}},{p380=1,index=6,wz={6,10}},{p557=1,index=7,wz={6,10}},{p561=1,index=8,wz={6,10}},},},},
        {index=5,aid="p3",content={e={{p3=5,index=1,wz={3,5},},},},},
        {index=6,aid="f98",content={p={{p181=2,index=1,wz={12,20},},{p193=2,index=2,wz={12,20},},{p205=2,index=3,wz={12,20},},{p217=2,index=4,wz={12,20}},{p352=2,index=5,wz={12,20}},{p356=2,index=6,wz={12,20}},{p533=2,index=7,wz={6,10}},{p537=2,index=8,wz={6,10}}},},},
        {index=7,aid="f106",content={p={{p184=2,index=1,wz={12,20},},{p196=2,index=2,wz={12,20},},{p208=2,index=3,wz={12,20},},{p220=2,index=4,wz={12,20}},{p360=2,index=5,wz={12,20}},{p364=2,index=6,wz={12,20}},{p541=2,index=7,wz={6,10}},{p545=2,index=8,wz={6,10}}},},},
        {index=8,aid="f114",content={p={{p187=2,index=1,wz={12,20},},{p199=2,index=2,wz={12,20},},{p211=2,index=3,wz={12,20},},{p223=2,index=4,wz={12,20}},{p368=2,index=5,wz={12,20}},{p372=2,index=6,wz={12,20}},{p549=2,index=7,wz={6,10}},{p553=2,index=8,wz={6,10}}},},},
        {index=9,aid="f122",content={p={{p190=2,index=1,wz={12,20},},{p202=2,index=2,wz={12,20},},{p214=2,index=3,wz={12,20},},{p226=2,index=4,wz={12,20}},{p376=2,index=5,wz={12,20}},{p380=2,index=6,wz={12,20}},{p557=2,index=7,wz={6,10}},{p561=2,index=8,wz={6,10}}},},},
        {index=10,aid="p2",content={e={{p2=2,index=1,wz={6,10},},},},},
        {index=11,aid="f98",content={p={{p181=3,index=1,wz={18,30},},{p193=3,index=2,wz={18,30},},{p205=3,index=3,wz={18,30},},{p217=3,index=4,wz={18,30}},{p352=3,index=5,wz={18,30}},{p356=3,index=6,wz={18,30}},{p533=3,index=7,wz={6,10}},{p537=3,index=8,wz={6,10}}},},},
        {index=12,aid="f106",content={p={{p184=3,index=1,wz={18,30},},{p196=3,index=2,wz={18,30},},{p208=3,index=3,wz={18,30},},{p220=3,index=4,wz={18,30}},{p360=3,index=5,wz={18,30}},{p364=3,index=6,wz={18,30}},{p541=3,index=7,wz={6,10}},{p545=3,index=8,wz={6,10}}},},},
        {index=13,aid="f114",content={p={{p187=3,index=1,wz={18,30},},{p199=3,index=2,wz={18,30},},{p211=3,index=3,wz={18,30},},{p223=3,index=4,wz={18,30}},{p368=3,index=5,wz={18,30}},{p372=3,index=6,wz={18,30}},{p549=3,index=7,wz={6,10}},{p553=3,index=8,wz={6,10}}},},},
        {index=14,aid="f122",content={p={{p190=3,index=1,wz={18,30},},{p202=3,index=2,wz={18,30},},{p214=3,index=3,wz={18,30},},{p226=3,index=4,wz={18,30}},{p376=3,index=5,wz={18,30}},{p380=3,index=6,wz={18,30}},{p557=3,index=7,wz={6,10}},{p561=3,index=8,wz={6,10}}},},},
        {index=15,aid="p1",content={e={{p1=1,index=1,wz={6,10},},},},},
        {index=16,aid="f99",content={p={{p182=1,index=1,wz={24,40},},{p194=1,index=2,wz={24,40},},{p206=1,index=3,wz={24,40},},{p218=1,index=4,wz={24,40}},{p353=1,index=4,wz={24,40}},{p357=1,index=4,wz={24,40}},{p534=1,index=7,wz={24,40}},{p538=1,index=8,wz={24,40}}},},},
        {index=17,aid="f107",content={p={{p185=1,index=1,wz={24,40},},{p197=1,index=2,wz={24,40},},{p209=1,index=3,wz={24,40},},{p221=1,index=4,wz={24,40}},{p361=1,index=4,wz={24,40}},{p365=1,index=4,wz={24,40}},{p542=1,index=7,wz={24,40}},{p546=1,index=8,wz={24,40}}},},},
        {index=18,aid="f115",content={p={{p188=1,index=1,wz={24,40},},{p200=1,index=2,wz={24,40},},{p212=1,index=3,wz={24,40},},{p224=1,index=4,wz={24,40}},{p369=1,index=4,wz={24,40}},{p373=1,index=4,wz={24,40}},{p550=1,index=7,wz={24,40}},{p554=1,index=8,wz={24,40}}},},},
        {index=19,aid="f123",content={p={{p191=1,index=1,wz={24,40},},{p203=1,index=2,wz={24,40},},{p215=1,index=3,wz={24,40},},{p227=1,index=4,wz={24,40}},{p377=1,index=4,wz={24,40}},{p381=1,index=4,wz={24,40}},{p558=1,index=7,wz={24,40}},{p562=1,index=8,wz={24,40}}},},},
        {index=20,aid="f0",content={p={{p230=1,index=1,wz={48,80},},},},},
        },   
        
        showIconList={p={{p230=1,index=1},{p534=1,index=11},{p538=1,index=12},{p542=1,index=13},{p546=1,index=14},{p550=1,index=15},{p554=1,index=16},{p558=1,index=17},{p562=1,index=18},{p353=1,index=19},{p357=1,index=20},{p361=1,index=21},{p365=1,index=22},{p369=1,index=23},{p373=1,index=24},{p377=1,index=25},{p381=1,index=26},{p182=1,index=27},{p194=1,index=28},{p206=1,index=29},{p218=1,index=30},{p185=1,index=31},{p197=1,index=32},{p209=1,index=33},{p221=1,index=34},{p188=1,index=35},{p200=1,index=36},{p212=1,index=37},{p224=1,index=38},{p191=1,index=39},{p203=1,index=40},{p215=1,index=41},{p227=1,index=42},{p533=1,index=51},{p537=1,index=52},{p541=1,index=53},{p545=1,index=54},{p549=1,index=55},{p553=1,index=56},{p557=1,index=57},{p561=1,index=58},{p352=1,index=59},{p356=1,index=60},{p360=1,index=61},{p364=1,index=62},{p368=1,index=63},{p372=1,index=64},{p376=1,index=65},{p380=1,index=66},{p181=1,index=67},{p193=1,index=68},{p205=1,index=69},{p217=1,index=70},{p184=1,index=71},{p196=1,index=72},{p208=1,index=73},{p220=1,index=74},{p187=1,index=75},{p199=1,index=76},{p211=1,index=77},{p223=1,index=78},{p190=1,index=79},{p202=1,index=80},{p214=1,index=81},{p226=1,index=82},},e={{p1=1,index=50},{p2=2,index=91},{p3=5,index=92},},},

--探索1次花费
        oneCost={1,58},
        --探索10次花费   91折
        tenCost={10,{580,468},},
        
    },

     equipSearchVI={
        -- 排行奖励（前10名）
        r = {
            {e={p11=3,f0=3}}, -- 熔炼核心碎片 * 3 万能碎片 * 3
            {e={p11=2,f0=3}}, -- 熔炼核心碎片 * 2 万能碎片 * 3
            {e={p11=1,f0=2}}, -- 熔炼核心碎片 * 1 万能碎片 * 2
            {e={p11=1,f0=1}}, -- 熔炼核心碎片 * 1 万能碎片 * 1
            {e={p11=1,p6=5}}, -- 熔炼核心碎片 * 1 工具箱 * 5
        },
        -- 进行排行需要的最低积分
        rankPoint = 300,
-- 奖池
        pool={
        {index=1,aid="f2",content={p={{p181=3,index=1,wz={6,10},},{p184=3,index=2,wz={6,10},},{p187=3,index=3,wz={6,10},},{p190=3,index=4,wz={6,10},},{p352=3,index=5,wz={6,10},},{p356=3,index=6,wz={6,10},},{p533=3,index=7,wz={6,10},},{p537=3,index=8,wz={6,10},},},},},
        {index=2,aid="f18",content={p={{p193=3,index=1,wz={6,10},},{p196=3,index=2,wz={6,10},},{p199=3,index=3,wz={6,10},},{p202=3,index=4,wz={6,10},},{p360=3,index=5,wz={6,10},},{p364=3,index=6,wz={6,10},},{p541=3,index=7,wz={6,10},},{p545=3,index=8,wz={6,10},},},},},
        {index=3,aid="f34",content={p={{p205=3,index=1,wz={6,10},},{p208=3,index=2,wz={6,10},},{p211=3,index=3,wz={6,10},},{p214=3,index=4,wz={6,10},},{p368=3,index=5,wz={6,10},},{p372=3,index=6,wz={6,10},},{p549=3,index=7,wz={6,10},},{p553=3,index=8,wz={6,10},},},},},
        {index=4,aid="f50",content={p={{p217=3,index=1,wz={6,10},},{p220=3,index=2,wz={6,10},},{p223=3,index=3,wz={6,10},},{p226=3,index=4,wz={6,10},},{p376=3,index=5,wz={6,10},},{p380=3,index=6,wz={6,10},},{p557=3,index=7,wz={6,10},},{p561=3,index=8,wz={6,10},},},},},
        {index=5,aid="p2",content={e={{p2=2,index=1,wz={6,10},},{p3=5,index=2,wz={3,5},},},},},
        {index=6,aid="f3",content={p={{p182=1,index=1,wz={12,20},},{p185=1,index=2,wz={12,20},},{p188=1,index=3,wz={12,20},},{p191=1,index=4,wz={12,20},},{p353=1,index=5,wz={12,20},},{p357=1,index=6,wz={12,20},},{p534=1,index=7,wz={12,20},},{p538=1,index=8,wz={12,20},},},},},
        {index=7,aid="f19",content={p={{p194=1,index=1,wz={12,20},},{p197=1,index=2,wz={12,20},},{p200=1,index=3,wz={12,20},},{p203=1,index=4,wz={12,20},},{p361=1,index=5,wz={12,20},},{p365=1,index=6,wz={12,20},},{p542=1,index=7,wz={12,20},},{p546=1,index=8,wz={12,20},},},},},
        {index=8,aid="f35",content={p={{p206=1,index=1,wz={12,20},},{p209=1,index=2,wz={12,20},},{p212=1,index=3,wz={12,20},},{p215=1,index=4,wz={12,20},},{p369=1,index=5,wz={12,20},},{p373=1,index=6,wz={12,20},},{p550=1,index=7,wz={12,20},},{p554=1,index=8,wz={12,20},},},},},
        {index=9,aid="f51",content={p={{p218=1,index=1,wz={12,20},},{p221=1,index=2,wz={12,20},},{p224=1,index=3,wz={12,20},},{p227=1,index=4,wz={12,20},},{p377=1,index=5,wz={12,20},},{p381=1,index=6,wz={12,20},},{p558=1,index=7,wz={12,20},},{p562=1,index=8,wz={12,20},},},},},
        {index=10,aid="p1",content={e={{p1=1,index=1,wz={12,20},},},},},
        {index=11,aid="f3",content={p={{p182=2,index=1,wz={18,30},},{p185=2,index=2,wz={18,30},},{p188=2,index=3,wz={18,30},},{p191=2,index=4,wz={18,30},},{p353=2,index=5,wz={18,30},},{p357=2,index=6,wz={18,30},},{p534=2,index=7,wz={18,30},},{p538=2,index=8,wz={18,30},},},},},
        {index=12,aid="f19",content={p={{p194=2,index=1,wz={18,30},},{p197=2,index=2,wz={18,30},},{p200=2,index=3,wz={18,30},},{p203=2,index=4,wz={18,30},},{p361=2,index=5,wz={18,30},},{p365=2,index=6,wz={18,30},},{p542=2,index=7,wz={18,30},},{p546=2,index=8,wz={18,30},},},},},
        {index=13,aid="f35",content={p={{p206=2,index=1,wz={18,30},},{p209=2,index=2,wz={18,30},},{p212=2,index=3,wz={18,30},},{p215=2,index=4,wz={18,30},},{p369=2,index=5,wz={18,30},},{p373=2,index=6,wz={18,30},},{p550=2,index=7,wz={18,30},},{p554=2,index=8,wz={18,30},},},},},
        {index=14,aid="f51",content={p={{p218=2,index=1,wz={18,30},},{p221=2,index=2,wz={18,30},},{p224=2,index=3,wz={18,30},},{p227=2,index=4,wz={18,30},},{p377=2,index=5,wz={18,30},},{p381=2,index=6,wz={18,30},},{p558=2,index=7,wz={18,30},},{p562=2,index=8,wz={18,30},},},},},
        {index=15,aid="p11",content={e={{p11=1,index=1,wz={24,40},},},},},
        {index=16,aid="f4",content={p={{p183=1,index=1,wz={24,40},},{p186=1,index=2,wz={24,40},},{p189=1,index=3,wz={24,40},},{p192=1,index=4,wz={24,40},},},},},
        {index=17,aid="f20",content={p={{p195=1,index=1,wz={24,40},},{p198=1,index=2,wz={24,40},},{p201=1,index=3,wz={24,40},},{p204=1,index=4,wz={24,40},},},},},
        {index=18,aid="f36",content={p={{p207=1,index=1,wz={24,40},},{p210=1,index=2,wz={24,40},},{p213=1,index=3,wz={24,40},},{p216=1,index=4,wz={24,40},},},},},
        {index=19,aid="f52",content={p={{p219=1,index=1,wz={24,40},},{p222=1,index=2,wz={24,40},},{p225=1,index=3,wz={24,40},},{p228=1,index=4,wz={24,40},},},},},
        {index=20,aid="f0",content={p={{p230=1,index=1,wz={24,40},},},},},
        },   
        
        --showIconList={p={{p230=1,index=1},{p534=1,index=11},{p538=1,index=12},{p542=1,index=13},{p546=1,index=14},{p550=1,index=15},{p554=1,index=16},{p558=1,index=17},{p562=1,index=18},{p353=1,index=19},{p357=1,index=20},{p361=1,index=21},{p365=1,index=22},{p369=1,index=23},{p373=1,index=24},{p377=1,index=25},{p381=1,index=26},{p182=1,index=27},{p194=1,index=28},{p206=1,index=29},{p218=1,index=30},{p185=1,index=31},{p197=1,index=32},{p209=1,index=33},{p221=1,index=34},{p188=1,index=35},{p200=1,index=36},{p212=1,index=37},{p224=1,index=38},{p191=1,index=39},{p203=1,index=40},{p215=1,index=41},{p227=1,index=42},{p533=1,index=51},{p537=1,index=52},{p541=1,index=53},{p545=1,index=54},{p549=1,index=55},{p553=1,index=56},{p557=1,index=57},{p561=1,index=58},{p352=1,index=59},{p356=1,index=60},{p360=1,index=61},{p364=1,index=62},{p368=1,index=63},{p372=1,index=64},{p376=1,index=65},{p380=1,index=66},{p181=1,index=67},{p193=1,index=68},{p205=1,index=69},{p217=1,index=70},{p184=1,index=71},{p196=1,index=72},{p208=1,index=73},{p220=1,index=74},{p187=1,index=75},{p199=1,index=76},{p211=1,index=77},{p223=1,index=78},{p190=1,index=79},{p202=1,index=80},{p214=1,index=81},{p226=1,index=82},},e={{p1=1,index=50},{p2=2,index=91},{p3=5,index=92},},},
 
        flick={
           {},{},{},{},{},       
           {},{},{},{},{},       
           {},{},{},{},{flicker="y",inF={"y"}},       
           {flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y"}},       
         },
         
        --探索1次花费
        oneCost={1,98},
        --探索10次花费   95折
        tenCost={10,{980,928},},
        
    },

    equipSearchVII={
        r={
            {e={{p11=3},{f0=3}}},
            {e={{p11=2},{f0=3}}},
            {e={{p11=1},{f0=2}}},
            {e={{p11=1},{f0=1}}},
            {e={{p11=1},{p6=5}}},
        },
        -----aid：显示配件图标，content点击后里面的道具奖励；index：排序id;wz：积分范围
        pool={
            {index=1,aid="f2",content={p={{p181=3,index=1,wz={6,10}},{p184=3,index=2,wz={6,10}},{p187=3,index=3,wz={6,10}},{p190=3,index=4,wz={6,10}},{p352=3,index=5,wz={6,10}},{p356=3,index=6,wz={6,10}},{p533=3,index=7,wz={6,10}},{p537=3,index=8,wz={6,10}},}}},
            {index=2,aid="f18",content={p={{p193=3,index=1,wz={6,10}},{p196=3,index=2,wz={6,10}},{p199=3,index=3,wz={6,10}},{p202=3,index=4,wz={6,10}},{p360=3,index=5,wz={6,10}},{p364=3,index=6,wz={6,10}},{p541=3,index=7,wz={6,10}},{p545=3,index=8,wz={6,10}},}}},
            {index=3,aid="f34",content={p={{p205=3,index=1,wz={6,10}},{p208=3,index=2,wz={6,10}},{p211=3,index=3,wz={6,10}},{p214=3,index=4,wz={6,10}},{p368=3,index=5,wz={6,10}},{p372=3,index=6,wz={6,10}},{p549=3,index=7,wz={6,10}},{p553=3,index=8,wz={6,10}},}}},
            {index=4,aid="f50",content={p={{p217=3,index=1,wz={6,10}},{p220=3,index=2,wz={6,10}},{p223=3,index=3,wz={6,10}},{p226=3,index=4,wz={6,10}},{p376=3,index=5,wz={6,10}},{p380=3,index=6,wz={6,10}},{p557=3,index=7,wz={6,10}},{p561=3,index=8,wz={6,10}},}}},
            {index=4,aid="p2",content={e={{p2=2,index=1,wz={6,10}},{p3=5,index=2,wz={3,5}},}}},
            {index=6,aid="f3",content={p={{p182=2,index=1,wz={18,30}},{p185=2,index=2,wz={18,30}},{p188=2,index=3,wz={18,30}},{p191=2,index=4,wz={18,30}},{p353=2,index=5,wz={18,30}},{p357=2,index=6,wz={18,30}},{p534=2,index=7,wz={18,30}},{p538=2,index=8,wz={18,30}},}}},
            {index=7,aid="f19",content={p={{p194=2,index=1,wz={18,30}},{p197=2,index=2,wz={18,30}},{p200=2,index=3,wz={18,30}},{p203=2,index=4,wz={18,30}},{p361=2,index=5,wz={18,30}},{p365=2,index=6,wz={18,30}},{p542=2,index=7,wz={18,30}},{p546=2,index=8,wz={18,30}},}}},
            {index=8,aid="f35",content={p={{p206=2,index=1,wz={18,30}},{p209=2,index=2,wz={18,30}},{p212=2,index=3,wz={18,30}},{p215=2,index=4,wz={18,30}},{p369=2,index=5,wz={18,30}},{p373=2,index=6,wz={18,30}},{p550=2,index=7,wz={18,30}},{p554=2,index=8,wz={18,30}},}}},
            {index=9,aid="f51",content={p={{p218=2,index=1,wz={18,30}},{p221=2,index=2,wz={18,30}},{p224=2,index=3,wz={18,30}},{p227=2,index=4,wz={18,30}},{p377=2,index=5,wz={18,30}},{p381=2,index=6,wz={18,30}},{p558=2,index=7,wz={18,30}},{p562=2,index=8,wz={18,30}},}}},
            {index=10,aid="p1",content={e={{p1=1,index=1,wz={12,20}},}}},
            {index=11,aid="f4",content={p={{p183=1,index=1,wz={24,40}},{p186=1,index=2,wz={24,40}},{p189=1,index=3,wz={24,40}},}}},
            {index=12,aid="f20",content={p={{p195=1,index=1,wz={24,40}},{p198=1,index=2,wz={24,40}},{p201=1,index=3,wz={24,40}},}}},
            {index=13,aid="f36",content={p={{p207=1,index=1,wz={24,40}},{p210=1,index=2,wz={24,40}},{p213=1,index=3,wz={24,40}},}}},
            {index=14,aid="f52",content={p={{p219=1,index=1,wz={24,40}},{p222=1,index=2,wz={24,40}},{p225=1,index=3,wz={24,40}},}}},
            {index=15,aid="p11",content={e={{p11=1,index=1,wz={24,40}},}}},
            {index=16,aid="f16",content={p={{p192=1,index=1,wz={24,40}},{p354=1,index=2,wz={24,40}},{p358=1,index=3,wz={24,40}},}}},
            {index=17,aid="f32",content={p={{p204=1,index=1,wz={24,40}},{p362=1,index=2,wz={24,40}},{p366=1,index=3,wz={24,40}},}}},
            {index=18,aid="f48",content={p={{p216=1,index=1,wz={24,40}},{p370=1,index=2,wz={24,40}},{p374=1,index=3,wz={24,40}},}}},
            {index=19,aid="f64",content={p={{p228=1,index=1,wz={24,40}},{p378=1,index=2,wz={24,40}},{p382=1,index=3,wz={24,40}},}}},
            {index=20,aid="f0",content={p={{p230=1,index=1,wz={24,40}},}}},
        },
        ---闪光配置:flicker--是外部,inflicker是图标点击进去后的道具边框
        flick={
            {},{},{},{},{},
            {},{},{},{},{},
            {flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y"}},
            {flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y","y","y"}},{flicker="y",inF={"y"}},
        },
        -----oneCost：探索1次花费，tenCost：探索10次花费，打95折；-----rankPoint：进入排行榜所需积分
        oneCost={1,98,},
        tenCost={10,{980,928},},
        rankPoint=300,
    },

       equipSearchVIII={
        r={
            {e={{p11=3},{f0=3}}},
            {e={{p11=2},{f0=3}}},
            {e={{p11=1},{f0=2}}},
            {e={{p11=1},{f0=1}}},
            {e={{p11=1},{p6=5}}},
        },
        -----aid：显示配件图标，content点击后里面的道具奖励；index：排序id;wz：积分范围
        pool={
            {index=1,aid="f2",content={p={{p181=3,index=1,wz={6,10}},{p184=3,index=2,wz={6,10}},{p187=3,index=3,wz={6,10}},{p190=3,index=4,wz={6,10}},{p352=3,index=5,wz={6,10}},{p356=3,index=6,wz={6,10}},{p533=3,index=7,wz={6,10}},{p537=3,index=8,wz={6,10}},}}},
            {index=2,aid="f18",content={p={{p193=3,index=1,wz={6,10}},{p196=3,index=2,wz={6,10}},{p199=3,index=3,wz={6,10}},{p202=3,index=4,wz={6,10}},{p360=3,index=5,wz={6,10}},{p364=3,index=6,wz={6,10}},{p541=3,index=7,wz={6,10}},{p545=3,index=8,wz={6,10}},}}},
            {index=3,aid="f34",content={p={{p205=3,index=1,wz={6,10}},{p208=3,index=2,wz={6,10}},{p211=3,index=3,wz={6,10}},{p214=3,index=4,wz={6,10}},{p368=3,index=5,wz={6,10}},{p372=3,index=6,wz={6,10}},{p549=3,index=7,wz={6,10}},{p553=3,index=8,wz={6,10}},}}},
            {index=4,aid="f50",content={p={{p217=3,index=1,wz={6,10}},{p220=3,index=2,wz={6,10}},{p223=3,index=3,wz={6,10}},{p226=3,index=4,wz={6,10}},{p376=3,index=5,wz={6,10}},{p380=3,index=6,wz={6,10}},{p557=3,index=7,wz={6,10}},{p561=3,index=8,wz={6,10}},}}},
            {index=4,aid="p2",content={e={{p2=2,index=1,wz={6,10}},{p3=5,index=2,wz={3,5}},}}},
            {index=6,aid="f3",content={p={{p182=2,index=1,wz={18,30}},{p185=2,index=2,wz={18,30}},{p188=2,index=3,wz={18,30}},{p191=2,index=4,wz={18,30}},{p353=2,index=5,wz={18,30}},{p357=2,index=6,wz={18,30}},{p534=2,index=7,wz={18,30}},{p538=2,index=8,wz={18,30}},}}},
            {index=7,aid="f19",content={p={{p194=2,index=1,wz={18,30}},{p197=2,index=2,wz={18,30}},{p200=2,index=3,wz={18,30}},{p203=2,index=4,wz={18,30}},{p361=2,index=5,wz={18,30}},{p365=2,index=6,wz={18,30}},{p542=2,index=7,wz={18,30}},{p546=2,index=8,wz={18,30}},}}},
            {index=8,aid="f35",content={p={{p206=2,index=1,wz={18,30}},{p209=2,index=2,wz={18,30}},{p212=2,index=3,wz={18,30}},{p215=2,index=4,wz={18,30}},{p369=2,index=5,wz={18,30}},{p373=2,index=6,wz={18,30}},{p550=2,index=7,wz={18,30}},{p554=2,index=8,wz={18,30}},}}},
            {index=9,aid="f51",content={p={{p218=2,index=1,wz={18,30}},{p221=2,index=2,wz={18,30}},{p224=2,index=3,wz={18,30}},{p227=2,index=4,wz={18,30}},{p377=2,index=5,wz={18,30}},{p381=2,index=6,wz={18,30}},{p558=2,index=7,wz={18,30}},{p562=2,index=8,wz={18,30}},}}},
            {index=10,aid="p1",content={e={{p1=1,index=1,wz={12,20}},}}},
            {index=11,aid="f4",content={p={{p183=1,index=1,wz={24,40}},{p186=1,index=2,wz={24,40}},{p189=1,index=3,wz={24,40}},{p192=1,index=4,wz={24,40}},}}},
            {index=12,aid="f20",content={p={{p195=1,index=1,wz={24,40}},{p198=1,index=2,wz={24,40}},{p201=1,index=3,wz={24,40}},{p204=1,index=4,wz={24,40}},}}},
            {index=13,aid="f36",content={p={{p207=1,index=1,wz={24,40}},{p210=1,index=2,wz={24,40}},{p213=1,index=3,wz={24,40}},{p216=1,index=4,wz={24,40}},}}},
            {index=14,aid="f52",content={p={{p219=1,index=1,wz={24,40}},{p222=1,index=2,wz={24,40}},{p225=1,index=3,wz={24,40}},{p228=1,index=4,wz={24,40}},}}},
            {index=15,aid="p11",content={e={{p11=1,index=1,wz={24,40}},}}},
            {index=16,aid="f68",content={p={{p354=1,index=1,wz={24,40}},{p358=1,index=2,wz={24,40}},{p535=1,index=3,wz={24,40}},{p539=1,index=4,wz={24,40}},}}},
            {index=17,aid="f76",content={p={{p362=1,index=1,wz={24,40}},{p366=1,index=2,wz={24,40}},{p543=1,index=3,wz={24,40}},{p547=1,index=4,wz={24,40}},}}},
            {index=18,aid="f84",content={p={{p370=1,index=1,wz={24,40}},{p374=1,index=2,wz={24,40}},{p551=1,index=3,wz={24,40}},{p555=1,index=4,wz={24,40}},}}},
            {index=19,aid="f92",content={p={{p378=1,index=1,wz={24,40}},{p382=1,index=2,wz={24,40}},{p559=1,index=3,wz={24,40}},{p563=1,index=4,wz={24,40}},}}},
            {index=20,aid="f0",content={p={{p230=1,index=1,wz={24,40}},}}},
        },
        ---闪光配置:flicker--是外部,inflicker是图标点击进去后的道具边框
        flick={
            {},{},{},{},{},
            {},{},{},{},{},
            {flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y"}},
            {flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y","y","y","y"}},{flicker="y",inF={"y"}},
        },
        -----oneCost：探索1次花费，tenCost：探索10次花费，打95折；-----rankPoint：进入排行榜所需积分
        oneCost={1,98,},
        tenCost={10,{980,928},},
        rankPoint=300,
    },
    
    -- vipAction=
    -- { 
    --     totalRecharge={
    --         {cost = 12000, award= {p={{p273=1,index=1},{p267=5,index=2}}}},
    --         {cost = 12000, award= {p={{p273=1,index=1},{p267=5,index=2},{p267=5,index=2}}}}
    --     }, -- 累计充值金额(cost 代表消费金额，award 代表奖励配置)

    --     dayRecharge={
    --         {cost = 1, award= {p={{p273=1,index=1},{p267=5,index=2}}}},
    --         {cost = 1000, award= {p={{p273=1,index=1}}}}
    --     },-- 每日充值金额(cost 代表消费金额，award 代表奖励配置)     
    -- },
    
    --收获日
    harvestDay = {
        rewardRank=10,
        rewardNumTab={3,3,3,1},
    },
    --勤劳致富
    hardGetRich={
        personalGoal={4000000,20000000,60000000,120000000},
    },

    --钢铁之心
    heartOfIron = {
        --指挥中心升到10级
        blevel={name="activity_heartOfIron_name_1",pic="Icon_zhu_ji_di.png",desc="activity_heartOfIron_desc_1",method=1,addBg=false},
        --角色等级升到10级
        ulevel={name="activity_heartOfIron_name_2",pic="player_exp.png",desc="activity_heartOfIron_desc_2",method=2,addBg=false},
        --将任意配件强化到5级
        alevel={name="activity_heartOfIron_name_3",pic="mainBtnAccessory.png",desc="activity_heartOfIron_desc_3",method=3,addBg=true},
        --领取5个军团副本中击杀敌军获得的“军需宝箱”
        acrd={name="activity_heartOfIron_name_4",pic="tech_fight_exp_up.png",desc="activity_heartOfIron_desc_4",method=4,addBg=false},
        --关卡副本获得100个星数
        star={name="activity_heartOfIron_name_5",pic="mainBtnCheckpoint.png",desc="activity_heartOfIron_desc_5",method=5,addBg=true},
        --在“科研中心”将任意科技升到10级
        tech={name="activity_heartOfIron_name_6",pic="Icon_ke_yan_zhong_xin.png",desc="activity_heartOfIron_desc_6",method=6,addBg=false},
        --生产任意“重型”部队100辆
        troops={name="activity_heartOfIron_name_7",pic="Icon_tan_ke_gong_chang.png",desc="activity_heartOfIron_desc_7",method=7,addBg=false},

    },

    miBao={
        s1={name="piece_name_s1",des="piece_des_s",icon="a.png"},
        s2={name="piece_name_s2",des="piece_des_s",icon="b.png"},
        s3={name="piece_name_s3",des="piece_des_s",icon="c.png"},
        s4={name="piece_name_s4",des="piece_des_s",icon="d.png"},
    },

    --中秋狂欢
    autumnCarnival={
        b1={name="activity_AutumnCarnival_gift1",des="activity_AutumnCarnival_giftDesc1",icon="item_baoxiang_03.png"},
        b2={name="activity_AutumnCarnival_gift2",des="activity_AutumnCarnival_giftDesc2",icon="item_baoxiang_05.png"},
        b3={name="activity_AutumnCarnival_gift3",des="activity_AutumnCarnival_giftDesc3",icon="item_commandBox.png"},
        b4={name="activity_AutumnCarnival_gift4",des="activity_AutumnCarnival_giftDesc4",icon="item_baoxiang_04.png"},
        b5={name="activity_AutumnCarnival_gift5",des="activity_AutumnCarnival_giftDesc5",icon="item_developmentBox.png"},
        b6={name="activity_AutumnCarnival_gift6",des="activity_AutumnCarnival_giftDesc6",icon="item_baoxiang_07.png"},
    },

    --中秋狂欢通用版  补给拦截
    supplyIntercept={
        b1={name="activity_SupplyIntercept_gift1",des="activity_SupplyIntercept_giftDesc1",icon="item_baoxiang_03.png"},
        b2={name="activity_SupplyIntercept_gift2",des="activity_SupplyIntercept_giftDesc2",icon="item_baoxiang_05.png"},
        b3={name="activity_SupplyIntercept_gift3",des="activity_SupplyIntercept_giftDesc3",icon="item_commandBox.png"},
        b4={name="activity_SupplyIntercept_gift4",des="activity_SupplyIntercept_giftDesc4",icon="item_baoxiang_04.png"},
        b5={name="activity_SupplyIntercept_gift5",des="activity_SupplyIntercept_giftDesc5",icon="item_developmentBox.png"},
        b6={name="activity_SupplyIntercept_gift6",des="activity_SupplyIntercept_giftDesc6",icon="item_baoxiang_07.png"},
    },
   --共和国之辉
    republicHui={
        m1={name="activity_republicHui_partsName",des="activity_republicHui_partsDesc",icon="iconPiece_59Tank.png"},
    },

    --中秋狂欢通用版  补给拦截
    singles={
        mm_m1={name="activity_singles_token1",des="activity_singles_tokenDesc1",icon="guanggun.png"},
        mm_m2={name="activity_singles_token2",des="activity_singles_tokenDesc2",icon="jiyou.png"},
        mm_m3={name="activity_singles_token3",des="activity_singles_tokenDesc3",icon="nvshen.png"},
    },

    newPlatGift = {
        [1609]={reward={p={{p1118=1,index=1},},},serverReward={props_p1118=1},},
        [1797]={reward={p={{p1136=1,index=1},},},serverReward={props_p1136=1},},
        [1867]={reward={p={{p1147=1,index=1},},},serverReward={props_p1147=1},},
        

        [1802]={reward={p={{p1148=1,index=1},},},serverReward={props_p1148=1},},
        [1803]={reward={p={{p1149=1,index=1},},},serverReward={props_p1149=1},},

    },


    challengeranknew ={
        {rank={1},award={u={{gems=500,index=1},{honors=2500,index=2}}}}, 
        {rank={2},award={u={{gems=300,index=1},{honors=1500,index=2}}}}, 
        {rank={3},award={u={{gems=200,index=1},{honors=1000,index=2}}}}, 
        {rank={4,5},award={u={{gems=150,index=1},{honors=750,index=2}}}}, 
        {rank={6,10},award={u={{gems=100,index=1},{honors=500,index=2}}}}, 
        {rank={11,20},award={u={{gems=50,index=1},{honors=250,index=2}}}}, 
    },

    fightRanknew ={
        {rank = {1},award={u={{gems=3888,index=1}}}},
        {rank = {2},award={u={{gems=1988,index=1}}}},
        {rank = {3},award={u={{gems=988,index=1}}}},
        {rank = {4,5},award={u={{gems=688,index=1}}}},
        {rank = {6,10},award={u={{gems=388,index=1}}}},
        {rank = {11,20},award={u={{gems=288,index=1}}}},
        {rank = {21,30},award={u={{gems=188,index=1}}}},
        {rank = {31,50},award={u={{gems=88,index=1}}}},
    },
    cjms={
        multiSelectType=true,
        [1]={
            basicShop={
                {  -- 基础商店 1 -- 基础
                    i1={bn=80,p=480,g=240,r={p={p1=1}},sr={props_p1=1}},
                    i2={bn=80,p=560,g=280,r={p={p49=1}},sr={props_p49=1}},
                    i3={bn=80,p=210,g=105,r={p={p5=1}},sr={props_p5=1}},
                    i4={bn=80,p=28,g=14,r={p={p15=1}},sr={props_p15=1}},
                    i5={bn=80,p=98,g=49,r={p={p16=1}},sr={props_p16=1}},
                    i6={bn=80,p=2000,g=1000,r={p={p401=1}},sr={props_p401=1}},
                    i7={bn=80,p=2000,g=1000,r={p={p402=1}},sr={props_p402=1}},
                    i8={bn=80,p=2000,g=1000,r={p={p403=1}},sr={props_p403=1}},
                    i9={bn=80,p=2000,g=1000,r={p={p404=1}},sr={props_p404=1}},
                },
                {  -- 基础商店 2 -- 配件
                    i1={bn=80,p=800,g=400,r={p={p90=1}},sr={props_p90=1}},
                    i2={bn=80,p=1280,g=640,r={p={p270=1}},sr={props_p270=1}},
                    i3={bn=80,p=1280,g=640,r={p={p566=1}},sr={props_p566=1}},
                    i4={bn=80,p=1600,g=800,r={e={p3=400}},sr={accessory_p3=400}},
                    i5={bn=80,p=1600,g=800,r={e={p2=80}},sr={accessory_p2=80}},
                    i6={bn=80,p=1600,g=800,r={e={p1=40}},sr={accessory_p1=40}},
                },
                {  -- 基础商店 3 -- 异星科技
                    i1={bn=50,p=1000,g=500,r={p={p867=1}},sr={props_p867=1}},
                    i2={bn=50,p=1000,g=500,r={p={p868=1}},sr={props_p868=1}},
                    i3={bn=50,p=1000,g=500,r={p={p869=1}},sr={props_p869=1}},
                    i4={bn=50,p=2800,g=560,r={p={p4=1}},sr={props_p4=1}},
                    i5={bn=50,p=160,g=32,r={p={p32=1}},sr={props_p32=1}},
                    i6={bn=50,p=160,g=32,r={p={p33=1}},sr={props_p33=1}},
                    i7={bn=50,p=160,g=32,r={p={p34=1}},sr={props_p34=1}},
                    i8={bn=50,p=160,g=32,r={p={p35=1}},sr={props_p35=1}},
                    i9={bn=50,p=160,g=32,r={p={p36=1}},sr={props_p36=1}},
                },
                {  -- 基础商店 4 -- 融合齿轮
                    i1={bn=50,p=1000,g=500,r={w={p1=10000}},sr={weapon_p1=10000}},
                    i2={bn=50,p=58,g=29,r={p={p912=5}},sr={props_p912=5}},
                    i3={bn=50,p=2250,g=1125,r={w={c5=1}},sr={weapon_c5=1}},
                    i4={bn=50,p=2250,g=1125,r={w={c15=1}},sr={weapon_c15=1}},
                    i5={bn=50,p=2250,g=1125,r={w={c25=1}},sr={weapon_c25=1}},
                    i6={bn=50,p=2250,g=1125,r={w={c35=1}},sr={weapon_c35=1}},
                    i7={bn=50,p=2250,g=1125,r={w={c45=1}},sr={weapon_c45=1}},
                    i8={bn=50,p=2250,g=1125,r={w={c55=1}},sr={weapon_c55=1}},
                    i9={bn=50,p=2250,g=1125,r={w={c65=1}},sr={weapon_c65=1}},
                    i10={bn=50,p=2250,g=1125,r={w={c75=1}},sr={weapon_c75=1}},
                    i11={bn=50,p=2250,g=1125,r={w={c85=1}},sr={weapon_c85=1}},
                    i12={bn=50,p=2250,g=1125,r={w={c95=1}},sr={weapon_c95=1}},
                },
                {  -- 基础商店 5 -- 坦克
                    i1={bn=50,p=6000,g=2400,r={o={a10095=50}},sr={troops_a10095=50}},
                    i2={bn=50,p=6000,g=2400,r={o={a20155=50}},sr={troops_a20155=50}},
                    i3={bn=50,p=6000,g=2400,r={o={a10045=50}},sr={troops_a10045=50}},
                    i4={bn=50,p=6000,g=2400,r={o={a20055=50}},sr={troops_a20055=50}},
                    i5={bn=50,p=6000,g=2400,r={o={a10135=50}},sr={troops_a10135=50}},
                    i6={bn=50,p=6000,g=2400,r={o={a10075=50}},sr={troops_a10075=50}},
                    i7={bn=50,p=6000,g=2400,r={o={a10145=50}},sr={troops_a10145=50}},
                    i8={bn=50,p=6000,g=2400,r={o={a20115=50}},sr={troops_a20115=50}},
                    i9={bn=50,p=6000,g=2400,r={o={a20125=50}},sr={troops_a20125=50}},
                    i10={bn=50,p=2500,g=1000,r={o={a10163=50}},sr={troops_a10163=50}},
                    i11={bn=50,p=4000,g=1600,r={o={a10164=50}},sr={troops_a10164=50}},          
                },
                {  -- 基础商店 6 -- 将领
                    i1={bn=50,p=3200,g=1600,r={p={p601=100}},sr={props_p601=100}},
                    i2={bn=50,p=4900,g=2450,r={h={s2=50}},sr={hero_s2=50}},
                    i3={bn=50,p=4900,g=2450,r={h={s3=50}},sr={hero_s3=50}},
                    i4={bn=50,p=1900,g=950,r={h={s33=50}},sr={hero_s33=50}},
                    i5={bn=50,p=1900,g=950,r={h={s34=50}},sr={hero_s34=50}},
                    i6={bn=50,p=1900,g=950,r={h={s35=50}},sr={hero_s35=50}},
                    i7={bn=50,p=1900,g=950,r={h={s36=50}},sr={hero_s36=50}},
                    i8={bn=50,p=1900,g=950,r={h={s37=50}},sr={hero_s37=50}},
                    i9={bn=50,p=1900,g=950,r={h={s31=50}},sr={hero_s31=50}},
                    i10={bn=50,p=1900,g=950,r={h={s19=50}},sr={hero_s19=50}},
                    i11={bn=50,p=1900,g=950,r={h={s38=50}},sr={hero_s38=50}},
                    i12={bn=50,p=1900,g=950,r={h={s40=50}},sr={hero_s40=50}},
                },
                {  -- 基础商店 7 -- 攻击型道具
                    i1={bn=50,p=1200,g=600,r={p={p421=6}},sr={props_p421=6}},
                    i2={bn=50,p=708,g=354,r={p={p46=6}},sr={props_p46=6}},
                    i3={bn=50,p=600,g=300,r={p={p423=6}},sr={props_p423=6}},
                    i4={bn=50,p=1500,g=750,r={p={p427=3}},sr={props_p427=3}},
                    i5={bn=50,p=1500,g=750,r={p={p428=3}},sr={props_p428=3}},
                    i6={bn=50,p=1500,g=750,r={p={p429=3}},sr={props_p429=3}},
                    i7={bn=50,p=1500,g=750,r={p={p430=3}},sr={props_p430=3}},
                },
                {  -- 基础商店 8 -- 将领装备
                    i1={bn=50,p=250,g=125,r={p={p469=10}},sr={props_p469=10}},
                    i2={bn=50,p=250,g=125,r={p={p470=10}},sr={props_p470=10}},
                    i3={bn=50,p=250,g=125,r={p={p471=10}},sr={props_p471=10}},
                    i4={bn=50,p=500,g=250,r={p={p472=10}},sr={props_p472=10}},
                    i5={bn=50,p=500,g=250,r={p={p473=10}},sr={props_p473=10}},
                    i6={bn=50,p=500,g=250,r={p={p474=10}},sr={props_p474=10}},
                    i7={bn=50,p=1000,g=500,r={p={p475=10}},sr={props_p475=10}},
                    i8={bn=50,p=1000,g=500,r={p={p476=10}},sr={props_p476=10}},
                    i9={bn=50,p=1000,g=500,r={p={p477=10}},sr={props_p477=10}},
                },
                {  -- 基础商店 9 -- 军徽
                    i1={bn=50,p=100,g=80,r={p={p4001=100}},sr={props_p4001=100}},
                    i2={bn=50,p=90,g=72,r={p={p4003=5}},sr={props_p4003=5}},
                    i3={bn=50,p=196,g=157,r={p={p4004=2}},sr={props_p4004=2}},
                },
                {  -- 基础商店 10 -- 飞机
                    i1={bn=20,p=2226,g=1781,r={p={p4618=1}},sr={props_p4618=1}},
                    i2={bn=20,p=288,g=230,r={p={p4617=1}},sr={props_p4617=1}},
                    i3={bn=20,p=250,g=200,r={p={p4201=50}},sr={props_p4201=50}},
                    i4={bn=20,p=498,g=398,r={p={p4205=1}},sr={props_p4205=1}},
                    i5={bn=20,p=540,g=432,r={p={p4204=5}},sr={props_p4204=5}},
                    i6={bn=20,p=270,g=216,r={p={p4203=15}},sr={props_p4203=15}},
                },
                {  -- 基础商店 11 -- 矩阵
                    i1={bn=20,p=3000,g=2400,r={p={p4604=1}},sr={props_p4604=1}},
                    i2={bn=40,p=500,g=400,r={p={p4603=1}},sr={props_p4603=1}},
                    i3={bn=20,p=1500,g=1200,r={am={exp=30000}},sr={armor_exp=30000}},
                    i4={bn=20,p=1000,g=800,r={am={exp=20000}},sr={armor_exp=20000}},
                    i5={bn=20,p=500,g=400,r={am={exp=10000}},sr={armor_exp=10000}},
                    i6={bn=20,p=250,g=200,r={am={exp=5000}},sr={armor_exp=5000}},
                    i7={bn=20,p=100,g=80,r={am={exp=2000}},sr={armor_exp=2000}},
                },
            },
            specialShop={
                {  -- 特殊商店 1 -- 基础
                    s1={bn=5,p=480,g=48,r={p={p1=1}},sr={props_p1=1}},
                    s2={bn=5,p=560,g=56,r={p={p49=1}},sr={props_p49=1}},
                    s3={bn=5,p=210,g=21,r={p={p5=1}},sr={props_p5=1}},
                    s4={bn=5,p=140,g=14,r={p={p15=5}},sr={props_p15=5}},
                    s5={bn=5,p=98,g=10,r={p={p16=1}},sr={props_p16=1}},
                    s6={bn=5,p=2000,g=200,r={p={p401=1}},sr={props_p401=1}},
                    s7={bn=5,p=2000,g=200,r={p={p402=1}},sr={props_p402=1}},
                    s8={bn=5,p=2000,g=200,r={p={p403=1}},sr={props_p403=1}},
                    s9={bn=5,p=2000,g=200,r={p={p404=1}},sr={props_p404=1}},
                    s10={bn=5,p=100,g=10,r={p={p419=1}},sr={props_p419=1}},
                },
                {  -- 特殊商店 2 -- 配件
                    s1={bn=5,p=800,g=80,r={p={p90=1}},sr={props_p90=1}},
                    s2={bn=5,p=1280,g=128,r={p={p270=1}},sr={props_p270=1}},
                    s3={bn=5,p=1280,g=128,r={p={p566=1}},sr={props_p566=1}},
                    s4={bn=5,p=800,g=80,r={p={p267=1}},sr={props_p267=1}},
                    s5={bn=5,p=4000,g=400,r={e={p3=1000}},sr={accessory_p3=1000}},
                    s6={bn=5,p=4000,g=400,r={e={p2=200}},sr={accessory_p2=200}},
                    s7={bn=5,p=4000,g=400,r={e={p1=100}},sr={accessory_p1=100}},
                    s8={bn=5,p=1000,g=100,r={e={p6=50}},sr={accessory_p6=50}},
                    s9={bn=5,p=1000,g=100,r={e={p5=10}},sr={accessory_p5=10}},
                    s10={bn=5,p=800,g=80,r={p={p565=1}},sr={props_p565=1}},
                },
                {  -- 特殊商店 3 -- 异星科技
                    s1={bn=5,p=1000,g=100,r={p={p867=1}},sr={props_p867=1}},
                    s2={bn=5,p=1000,g=100,r={p={p868=1}},sr={props_p868=1}},
                    s3={bn=5,p=1000,g=100,r={p={p869=1}},sr={props_p869=1}},
                    s4={bn=5,p=10000,g=1000,r={p={p870=1}},sr={props_p870=1}},
                    s5={bn=5,p=10000,g=1000,r={p={p871=1}},sr={props_p871=1}},
                    s6={bn=5,p=10000,g=1000,r={p={p872=1}},sr={props_p872=1}},
                },
                {  -- 特殊商店 4 -- 融合齿轮
                    s1={bn=5,p=1000,g=100,r={w={p1=10000}},sr={weapon_p1=10000}},
                    s2={bn=5,p=58,g=6,r={p={p912=20}},sr={props_p912=20}},
                    s3={bn=5,p=14520,g=1452,r={w={c7=1}},sr={weapon_c7=1}},
                    s4={bn=5,p=14520,g=1452,r={w={c17=1}},sr={weapon_c17=1}},
                    s5={bn=5,p=14520,g=1452,r={w={c27=1}},sr={weapon_c27=1}},
                    s6={bn=5,p=14520,g=1452,r={w={c37=1}},sr={weapon_c37=1}},
                    s7={bn=5,p=14520,g=1452,r={w={c47=1}},sr={weapon_c47=1}},
                    s8={bn=5,p=14520,g=1452,r={w={c57=1}},sr={weapon_c57=1}},
                    s9={bn=5,p=14520,g=1452,r={w={c67=1}},sr={weapon_c67=1}},
                    s10={bn=5,p=14520,g=1452,r={w={c77=1}},sr={weapon_c77=1}},
                    s11={bn=5,p=14520,g=1452,r={w={c87=1}},sr={weapon_c87=1}},
                    s12={bn=5,p=14520,g=1452,r={w={c97=1}},sr={weapon_c97=1}},
                },
                {  -- 特殊商店 5 -- 坦克
                    s1={bn=5,p=12000,g=1200,r={o={a10095=100}},sr={troops_a10095=100}},
                    s2={bn=5,p=12000,g=1200,r={o={a20155=100}},sr={troops_a20155=100}},
                    s3={bn=5,p=12000,g=1200,r={o={a10045=100}},sr={troops_a10045=100}},
                    s4={bn=5,p=12000,g=1200,r={o={a20055=100}},sr={troops_a20055=100}},
                    s5={bn=5,p=12000,g=1200,r={o={a10135=100}},sr={troops_a10135=100}},
                    s6={bn=5,p=12000,g=1200,r={o={a10075=100}},sr={troops_a10075=100}},
                    s7={bn=5,p=12000,g=1200,r={o={a10145=100}},sr={troops_a10145=100}},
                    s8={bn=5,p=12000,g=1200,r={o={a20115=100}},sr={troops_a20115=100}},
                    s9={bn=5,p=12000,g=1200,r={o={a20125=100}},sr={troops_a20125=100}},
                    s10={bn=8,p=5000,g=500,r={o={a10163=100}},sr={troops_a10163=100}},
                    s11={bn=8,p=8000,g=800,r={o={a10164=100}},sr={troops_a10164=100}},
                },
                {  -- 特殊商店 6 -- 将领
                    s1={bn=5,p=1600,g=160,r={p={p601=50}},sr={props_p601=50}},
                    s2={bn=5,p=4900,g=490,r={h={s25=50}},sr={hero_s25=50}},
                    s3={bn=5,p=4900,g=490,r={h={s13=50}},sr={hero_s13=50}},
                    s4={bn=5,p=4900,g=490,r={h={s24=50}},sr={hero_s24=50}},
                    s5={bn=5,p=4900,g=490,r={h={s15=50}},sr={hero_s15=50}},
                    s6={bn=5,p=4900,g=490,r={h={s1=50}},sr={hero_s1=50}},
                    s7={bn=5,p=4900,g=490,r={h={s4=50}},sr={hero_s4=50}},
                    s8={bn=5,p=4900,g=490,r={h={s5=50}},sr={hero_s5=50}},
                    s9={bn=5,p=1900,g=190,r={h={s23=50}},sr={hero_s23=50}},
                    s10={bn=5,p=1900,g=190,r={h={s22=50}},sr={hero_s22=50}},
                    s11={bn=5,p=1900,g=190,r={h={s11=50}},sr={hero_s11=50}},
                    s12={bn=5,p=1900,g=190,r={h={s27=50}},sr={hero_s27=50}},
                },
                {  -- 特殊商店 7 -- 攻击型道具
                    s1={bn=5,p=1350,g=135,r={p={p424=3}},sr={props_p424=3}},
                    s2={bn=5,p=1350,g=135,r={p={p425=3}},sr={props_p425=3}},
                    s3={bn=5,p=1350,g=135,r={p={p426=3}},sr={props_p426=3}},
                    s4={bn=5,p=3000,g=300,r={p={p431=3}},sr={props_p431=3}},
                    s5={bn=5,p=3000,g=300,r={p={p432=3}},sr={props_p432=3}},
                    s6={bn=5,p=3000,g=300,r={p={p433=3}},sr={props_p433=3}},
                    s7={bn=5,p=3000,g=300,r={p={p434=3}},sr={props_p434=3}},
                },
                {  -- 特殊商店 8 -- 将领装备
                    s1={bn=5,p=1000,g=100,r={p={p472=20}},sr={props_p472=20}},
                    s2={bn=5,p=1000,g=100,r={p={p473=20}},sr={props_p473=20}},
                    s3={bn=5,p=1000,g=100,r={p={p474=20}},sr={props_p474=20}},
                    s4={bn=5,p=2000,g=200,r={p={p475=20}},sr={props_p475=20}},
                    s5={bn=5,p=2000,g=200,r={p={p476=20}},sr={props_p476=20}},
                    s6={bn=5,p=2000,g=200,r={p={p477=20}},sr={props_p477=20}},
                    s7={bn=5,p=1000,g=100,r={p={p454=10}},sr={props_p454=10}},
                    s8={bn=5,p=1000,g=100,r={p={p455=10}},sr={props_p455=10}},
                    s9={bn=5,p=1000,g=100,r={p={p456=10}},sr={props_p456=10}},
                    s10={bn=5,p=1000,g=100,r={p={p457=10}},sr={props_p457=10}},
                    s11={bn=5,p=2000,g=200,r={p={p458=10}},sr={props_p458=10}},
                    s12={bn=5,p=1200,g=120,r={p={p481=2}},sr={props_p481=2}},
                },
                {  -- 特殊商店 9 -- 军徽
                    s1={bn=10,p=1888,g=1133,r={p={p4002=1}},sr={props_p4002=1}},
                    s2={bn=10,p=498,g=299,r={p={p4005=1}},sr={props_p4005=1}},
                    s3={bn=10,p=998,g=599,r={p={p4006=1}},sr={props_p4006=1}},
                },
                {  -- 特殊商店 10 -- 飞机
                    s1={bn=5,p=2226,g=1336,r={p={p4618=1}},sr={props_p4618=1}},
                    s2={bn=5,p=288,g=173,r={p={p4617=1}},sr={props_p4617=1}},
                    s3={bn=5,p=250,g=150,r={p={p4201=50}},sr={props_p4201=50}},
                    s4={bn=5,p=498,g=299,r={p={p4205=1}},sr={props_p4205=1}},
                    s5={bn=5,p=998,g=599,r={p={p4206=1}},sr={props_p4206=1}},
                    s6={bn=5,p=540,g=324,r={p={p4204=5}},sr={props_p4204=5}},
                    s7={bn=5,p=540,g=324,r={p={p4203=30}},sr={props_p4203=30}},
                },
                {  -- 特殊商店 11 -- 矩阵
                    s1={bn=10,p=3000,g=1800,r={p={p4604=1}},sr={props_p4604=1}},
                    s2={bn=10,p=500,g=300,r={p={p4603=1}},sr={props_p4603=1}},
                    s3={bn=20,p=1500,g=900,r={am={exp=30000}},sr={armor_exp=30000}},
                    s4={bn=20,p=1000,g=600,r={am={exp=20000}},sr={armor_exp=20000}},
                    s5={bn=20,p=500,g=300,r={am={exp=10000}},sr={armor_exp=10000}},
                    s6={bn=20,p=250,g=150,r={am={exp=5000}},sr={armor_exp=5000}},
                    s7={bn=20,p=100,g=60,r={am={exp=2000}},sr={armor_exp=2000}},
                },
            },
        },
        [2]={
            basicShop={
                {  -- 基础商店 1 -- 基础
                    i1={bn=80,p=480,g=240,r={p={p1=1}},sr={props_p1=1}},
                    i2={bn=80,p=560,g=280,r={p={p49=1}},sr={props_p49=1}},
                    i3={bn=80,p=210,g=105,r={p={p5=1}},sr={props_p5=1}},
                    i4={bn=80,p=28,g=14,r={p={p15=1}},sr={props_p15=1}},
                    i5={bn=80,p=98,g=49,r={p={p16=1}},sr={props_p16=1}},
                    i6={bn=80,p=2000,g=1000,r={p={p401=1}},sr={props_p401=1}},
                    i7={bn=80,p=2000,g=1000,r={p={p402=1}},sr={props_p402=1}},
                    i8={bn=80,p=2000,g=1000,r={p={p403=1}},sr={props_p403=1}},
                    i9={bn=80,p=2000,g=1000,r={p={p404=1}},sr={props_p404=1}},
                },
                {  -- 基础商店 2 -- 配件
                    i1={bn=80,p=800,g=400,r={p={p90=1}},sr={props_p90=1}},
                    i2={bn=80,p=1280,g=640,r={p={p270=1}},sr={props_p270=1}},
                    i3={bn=80,p=1280,g=640,r={p={p566=1}},sr={props_p566=1}},
                    i4={bn=80,p=1600,g=800,r={e={p3=400}},sr={accessory_p3=400}},
                    i5={bn=80,p=1600,g=800,r={e={p2=80}},sr={accessory_p2=80}},
                    i6={bn=80,p=1600,g=800,r={e={p1=40}},sr={accessory_p1=40}},
                },
                {  -- 基础商店 3 -- 异星科技
                    i1={bn=50,p=1000,g=500,r={p={p867=1}},sr={props_p867=1}},
                    i2={bn=50,p=1000,g=500,r={p={p868=1}},sr={props_p868=1}},
                    i3={bn=50,p=1000,g=500,r={p={p869=1}},sr={props_p869=1}},
                    i4={bn=50,p=2800,g=560,r={p={p4=1}},sr={props_p4=1}},
                    i5={bn=50,p=160,g=32,r={p={p32=1}},sr={props_p32=1}},
                    i6={bn=50,p=160,g=32,r={p={p33=1}},sr={props_p33=1}},
                    i7={bn=50,p=160,g=32,r={p={p34=1}},sr={props_p34=1}},
                    i8={bn=50,p=160,g=32,r={p={p35=1}},sr={props_p35=1}},
                    i9={bn=50,p=160,g=32,r={p={p36=1}},sr={props_p36=1}},
                },
                {  -- 基础商店 4 -- 融合齿轮
                    i1={bn=50,p=1000,g=500,r={w={p1=10000}},sr={weapon_p1=10000}},
                    i2={bn=50,p=58,g=29,r={p={p912=5}},sr={props_p912=5}},
                    i3={bn=50,p=2250,g=1125,r={w={c5=1}},sr={weapon_c5=1}},
                    i4={bn=50,p=2250,g=1125,r={w={c15=1}},sr={weapon_c15=1}},
                    i5={bn=50,p=2250,g=1125,r={w={c25=1}},sr={weapon_c25=1}},
                    i6={bn=50,p=2250,g=1125,r={w={c35=1}},sr={weapon_c35=1}},
                    i7={bn=50,p=2250,g=1125,r={w={c45=1}},sr={weapon_c45=1}},
                    i8={bn=50,p=2250,g=1125,r={w={c55=1}},sr={weapon_c55=1}},
                    i9={bn=50,p=2250,g=1125,r={w={c65=1}},sr={weapon_c65=1}},
                    i10={bn=50,p=2250,g=1125,r={w={c75=1}},sr={weapon_c75=1}},
                    i11={bn=50,p=2250,g=1125,r={w={c85=1}},sr={weapon_c85=1}},
                    i12={bn=50,p=2250,g=1125,r={w={c95=1}},sr={weapon_c95=1}},
                },
                {  -- 基础商店 5 -- 坦克
                    i1={bn=50,p=6000,g=2400,r={o={a10095=50}},sr={troops_a10095=50}},
                    i2={bn=50,p=6000,g=2400,r={o={a20155=50}},sr={troops_a20155=50}},
                    i3={bn=50,p=6000,g=2400,r={o={a10045=50}},sr={troops_a10045=50}},
                    i4={bn=50,p=6000,g=2400,r={o={a20055=50}},sr={troops_a20055=50}},
                    i5={bn=50,p=6000,g=2400,r={o={a10135=50}},sr={troops_a10135=50}},
                    i6={bn=50,p=6000,g=2400,r={o={a10075=50}},sr={troops_a10075=50}},
                    i7={bn=50,p=6000,g=2400,r={o={a10145=50}},sr={troops_a10145=50}},
                    i8={bn=50,p=6000,g=2400,r={o={a20115=50}},sr={troops_a20115=50}},
                    i9={bn=50,p=6000,g=2400,r={o={a20125=50}},sr={troops_a20125=50}},
                    i10={bn=50,p=2500,g=1000,r={o={a10163=50}},sr={troops_a10163=50}},
                    i11={bn=50,p=4000,g=1600,r={o={a10164=50}},sr={troops_a10164=50}},
                    i12={bn=50,p=6000,g=2400,r={o={a10084=50}},sr={troops_a10084=50}},
                    i13={bn=50,p=6000,g=2400,r={o={a10165=50}},sr={troops_a10165=50}},
                    i14={bn=50,p=6000,g=2400,r={o={a20065=50}},sr={troops_a20065=50}},
                },
                {  -- 基础商店 6 -- 将领
                    i1={bn=50,p=3200,g=1600,r={p={p601=100}},sr={props_p601=100}},
                    i2={bn=50,p=4900,g=2450,r={h={s2=50}},sr={hero_s2=50}},
                    i3={bn=50,p=4900,g=2450,r={h={s3=50}},sr={hero_s3=50}},
                    i4={bn=50,p=1900,g=950,r={h={s33=50}},sr={hero_s33=50}},
                    i5={bn=50,p=1900,g=950,r={h={s34=50}},sr={hero_s34=50}},
                    i6={bn=50,p=1900,g=950,r={h={s35=50}},sr={hero_s35=50}},
                    i7={bn=50,p=1900,g=950,r={h={s36=50}},sr={hero_s36=50}},
                    i8={bn=50,p=1900,g=950,r={h={s37=50}},sr={hero_s37=50}},
                    i9={bn=50,p=1900,g=950,r={h={s31=50}},sr={hero_s31=50}},
                    i10={bn=50,p=1900,g=950,r={h={s19=50}},sr={hero_s19=50}},
                    i11={bn=50,p=1900,g=950,r={h={s38=50}},sr={hero_s38=50}},
                    i12={bn=50,p=1900,g=950,r={h={s40=50}},sr={hero_s40=50}},
                },
                {  -- 基础商店 7 -- 攻击型道具
                    i1={bn=50,p=1200,g=600,r={p={p421=6}},sr={props_p421=6}},
                    i2={bn=50,p=708,g=354,r={p={p46=6}},sr={props_p46=6}},
                    i3={bn=50,p=600,g=300,r={p={p423=6}},sr={props_p423=6}},
                    i4={bn=50,p=1500,g=750,r={p={p427=3}},sr={props_p427=3}},
                    i5={bn=50,p=1500,g=750,r={p={p428=3}},sr={props_p428=3}},
                    i6={bn=50,p=1500,g=750,r={p={p429=3}},sr={props_p429=3}},
                    i7={bn=50,p=1500,g=750,r={p={p430=3}},sr={props_p430=3}},
                },
                {  -- 基础商店 8 -- 将领装备
                    i1={bn=50,p=250,g=125,r={p={p469=10}},sr={props_p469=10}},
                    i2={bn=50,p=250,g=125,r={p={p470=10}},sr={props_p470=10}},
                    i3={bn=50,p=250,g=125,r={p={p471=10}},sr={props_p471=10}},
                    i4={bn=50,p=500,g=250,r={p={p472=10}},sr={props_p472=10}},
                    i5={bn=50,p=500,g=250,r={p={p473=10}},sr={props_p473=10}},
                    i6={bn=50,p=500,g=250,r={p={p474=10}},sr={props_p474=10}},
                    i7={bn=50,p=1000,g=500,r={p={p475=10}},sr={props_p475=10}},
                    i8={bn=50,p=1000,g=500,r={p={p476=10}},sr={props_p476=10}},
                    i9={bn=50,p=1000,g=500,r={p={p477=10}},sr={props_p477=10}},
                },
                {  -- 基础商店 9 -- 军徽
                    i1={bn=50,p=100,g=80,r={p={p4001=100}},sr={props_p4001=100}},
                    i2={bn=50,p=90,g=72,r={p={p4003=5}},sr={props_p4003=5}},
                    i3={bn=50,p=196,g=157,r={p={p4004=2}},sr={props_p4004=2}},
                },
                {  -- 基础商店 10 -- 飞机
                    i1={bn=20,p=2226,g=1781,r={p={p4618=1}},sr={props_p4618=1}},
                    i2={bn=20,p=288,g=230,r={p={p4617=1}},sr={props_p4617=1}},
                    i3={bn=20,p=250,g=200,r={p={p4201=50}},sr={props_p4201=50}},
                    i4={bn=20,p=498,g=398,r={p={p4205=1}},sr={props_p4205=1}},
                    i5={bn=20,p=540,g=432,r={p={p4204=5}},sr={props_p4204=5}},
                    i6={bn=20,p=270,g=216,r={p={p4203=15}},sr={props_p4203=15}},
                    i7={bn=20,p=250,g=200,r={p={p4630=5}},sr={props_p4630=5}},
                },
                {  -- 基础商店 11 -- 矩阵
                    i1={bn=20,p=3000,g=2400,r={p={p4604=1}},sr={props_p4604=1}},
                    i2={bn=40,p=500,g=400,r={p={p4603=1}},sr={props_p4603=1}},
                    i3={bn=20,p=1500,g=1200,r={am={exp=30000}},sr={armor_exp=30000}},
                    i4={bn=20,p=1000,g=800,r={am={exp=20000}},sr={armor_exp=20000}},
                    i5={bn=20,p=500,g=400,r={am={exp=10000}},sr={armor_exp=10000}},
                    i6={bn=20,p=250,g=200,r={am={exp=5000}},sr={armor_exp=5000}},
                    i7={bn=20,p=100,g=80,r={am={exp=2000}},sr={armor_exp=2000}},
                },
            },
            specialShop={
                {  -- 特殊商店 1 -- 基础
                    s1={bn=5,p=480,g=48,r={p={p1=1}},sr={props_p1=1}},
                    s2={bn=5,p=560,g=56,r={p={p49=1}},sr={props_p49=1}},
                    s3={bn=5,p=210,g=21,r={p={p5=1}},sr={props_p5=1}},
                    s4={bn=5,p=140,g=14,r={p={p15=5}},sr={props_p15=5}},
                    s5={bn=5,p=98,g=10,r={p={p16=1}},sr={props_p16=1}},
                    s6={bn=5,p=2000,g=200,r={p={p401=1}},sr={props_p401=1}},
                    s7={bn=5,p=2000,g=200,r={p={p402=1}},sr={props_p402=1}},
                    s8={bn=5,p=2000,g=200,r={p={p403=1}},sr={props_p403=1}},
                    s9={bn=5,p=2000,g=200,r={p={p404=1}},sr={props_p404=1}},
                    s10={bn=5,p=100,g=10,r={p={p419=1}},sr={props_p419=1}},
                },
                {  -- 特殊商店 2 -- 配件
                    s1={bn=5,p=800,g=80,r={p={p90=1}},sr={props_p90=1}},
                    s2={bn=5,p=1280,g=128,r={p={p270=1}},sr={props_p270=1}},
                    s3={bn=5,p=1280,g=128,r={p={p566=1}},sr={props_p566=1}},
                    s4={bn=5,p=800,g=80,r={p={p267=1}},sr={props_p267=1}},
                    s5={bn=5,p=4000,g=400,r={e={p3=1000}},sr={accessory_p3=1000}},
                    s6={bn=5,p=4000,g=400,r={e={p2=200}},sr={accessory_p2=200}},
                    s7={bn=5,p=4000,g=400,r={e={p1=100}},sr={accessory_p1=100}},
                    s8={bn=5,p=1000,g=100,r={e={p6=50}},sr={accessory_p6=50}},
                    s9={bn=5,p=1000,g=100,r={e={p5=10}},sr={accessory_p5=10}},
                    s10={bn=5,p=800,g=80,r={p={p565=1}},sr={props_p565=1}},
                },
                {  -- 特殊商店 3 -- 异星科技
                    s1={bn=5,p=1000,g=100,r={p={p867=1}},sr={props_p867=1}},
                    s2={bn=5,p=1000,g=100,r={p={p868=1}},sr={props_p868=1}},
                    s3={bn=5,p=1000,g=100,r={p={p869=1}},sr={props_p869=1}},
                    s4={bn=5,p=10000,g=1000,r={p={p870=1}},sr={props_p870=1}},
                    s5={bn=5,p=10000,g=1000,r={p={p871=1}},sr={props_p871=1}},
                    s6={bn=5,p=10000,g=1000,r={p={p872=1}},sr={props_p872=1}},
                },
                {  -- 特殊商店 4 -- 融合齿轮
                    s1={bn=5,p=1000,g=100,r={w={p1=10000}},sr={weapon_p1=10000}},
                    s2={bn=5,p=58,g=6,r={p={p912=20}},sr={props_p912=20}},
                    s3={bn=5,p=14520,g=1452,r={w={c7=1}},sr={weapon_c7=1}},
                    s4={bn=5,p=14520,g=1452,r={w={c17=1}},sr={weapon_c17=1}},
                    s5={bn=5,p=14520,g=1452,r={w={c27=1}},sr={weapon_c27=1}},
                    s6={bn=5,p=14520,g=1452,r={w={c37=1}},sr={weapon_c37=1}},
                    s7={bn=5,p=14520,g=1452,r={w={c47=1}},sr={weapon_c47=1}},
                    s8={bn=5,p=14520,g=1452,r={w={c57=1}},sr={weapon_c57=1}},
                    s9={bn=5,p=14520,g=1452,r={w={c67=1}},sr={weapon_c67=1}},
                    s10={bn=5,p=14520,g=1452,r={w={c77=1}},sr={weapon_c77=1}},
                    s11={bn=5,p=14520,g=1452,r={w={c87=1}},sr={weapon_c87=1}},
                    s12={bn=5,p=14520,g=1452,r={w={c97=1}},sr={weapon_c97=1}},
                },
                {  -- 特殊商店 5 -- 坦克
                    s1={bn=5,p=12000,g=1200,r={o={a10095=100}},sr={troops_a10095=100}},
                    s2={bn=5,p=12000,g=1200,r={o={a20155=100}},sr={troops_a20155=100}},
                    s3={bn=5,p=12000,g=1200,r={o={a10045=100}},sr={troops_a10045=100}},
                    s4={bn=5,p=12000,g=1200,r={o={a20055=100}},sr={troops_a20055=100}},
                    s5={bn=5,p=12000,g=1200,r={o={a10135=100}},sr={troops_a10135=100}},
                    s6={bn=5,p=12000,g=1200,r={o={a10075=100}},sr={troops_a10075=100}},
                    s7={bn=5,p=12000,g=1200,r={o={a10145=100}},sr={troops_a10145=100}},
                    s8={bn=5,p=12000,g=1200,r={o={a20115=100}},sr={troops_a20115=100}},
                    s9={bn=5,p=12000,g=1200,r={o={a20125=100}},sr={troops_a20125=100}},
                    s10={bn=8,p=5000,g=500,r={o={a10163=100}},sr={troops_a10163=100}},
                    s11={bn=8,p=8000,g=800,r={o={a10164=100}},sr={troops_a10164=100}},
                    s12={bn=8,p=12000,g=1200,r={o={a10084=100}},sr={troops_a10084=100}},
                    s13={bn=8,p=12000,g=1200,r={o={a10165=100}},sr={troops_a10165=100}},
                    s14={bn=8,p=12000,g=1200,r={o={a20065=100}},sr={troops_a20065=100}},
                },
                {  -- 特殊商店 6 -- 将领
                    s1={bn=5,p=1600,g=160,r={p={p601=50}},sr={props_p601=50}},
                    s2={bn=5,p=4900,g=490,r={h={s25=50}},sr={hero_s25=50}},
                    s3={bn=5,p=4900,g=490,r={h={s13=50}},sr={hero_s13=50}},
                    s4={bn=5,p=4900,g=490,r={h={s24=50}},sr={hero_s24=50}},
                    s5={bn=5,p=4900,g=490,r={h={s15=50}},sr={hero_s15=50}},
                    s6={bn=5,p=4900,g=490,r={h={s1=50}},sr={hero_s1=50}},
                    s7={bn=5,p=4900,g=490,r={h={s4=50}},sr={hero_s4=50}},
                    s8={bn=5,p=4900,g=490,r={h={s5=50}},sr={hero_s5=50}},
                    s9={bn=5,p=1900,g=190,r={h={s23=50}},sr={hero_s23=50}},
                    s10={bn=5,p=1900,g=190,r={h={s22=50}},sr={hero_s22=50}},
                    s11={bn=5,p=1900,g=190,r={h={s11=50}},sr={hero_s11=50}},
                    s12={bn=5,p=1900,g=190,r={h={s27=50}},sr={hero_s27=50}},
                },
                {  -- 特殊商店 7 -- 攻击型道具
                    s1={bn=5,p=1350,g=135,r={p={p424=3}},sr={props_p424=3}},
                    s2={bn=5,p=1350,g=135,r={p={p425=3}},sr={props_p425=3}},
                    s3={bn=5,p=1350,g=135,r={p={p426=3}},sr={props_p426=3}},
                    s4={bn=5,p=3000,g=300,r={p={p431=3}},sr={props_p431=3}},
                    s5={bn=5,p=3000,g=300,r={p={p432=3}},sr={props_p432=3}},
                    s6={bn=5,p=3000,g=300,r={p={p433=3}},sr={props_p433=3}},
                    s7={bn=5,p=3000,g=300,r={p={p434=3}},sr={props_p434=3}},
                },
                {  -- 特殊商店 8 -- 将领装备
                    s1={bn=5,p=1000,g=100,r={p={p472=20}},sr={props_p472=20}},
                    s2={bn=5,p=1000,g=100,r={p={p473=20}},sr={props_p473=20}},
                    s3={bn=5,p=1000,g=100,r={p={p474=20}},sr={props_p474=20}},
                    s4={bn=5,p=2000,g=200,r={p={p475=20}},sr={props_p475=20}},
                    s5={bn=5,p=2000,g=200,r={p={p476=20}},sr={props_p476=20}},
                    s6={bn=5,p=2000,g=200,r={p={p477=20}},sr={props_p477=20}},
                    s7={bn=5,p=1000,g=100,r={p={p454=10}},sr={props_p454=10}},
                    s8={bn=5,p=1000,g=100,r={p={p455=10}},sr={props_p455=10}},
                    s9={bn=5,p=1000,g=100,r={p={p456=10}},sr={props_p456=10}},
                    s10={bn=5,p=1000,g=100,r={p={p457=10}},sr={props_p457=10}},
                    s11={bn=5,p=2000,g=200,r={p={p458=10}},sr={props_p458=10}},
                    s12={bn=5,p=1200,g=120,r={p={p481=2}},sr={props_p481=2}},
                },
                {  -- 特殊商店 9 -- 军徽
                    s1={bn=10,p=1888,g=1133,r={p={p4002=1}},sr={props_p4002=1}},
                    s2={bn=10,p=498,g=299,r={p={p4005=1}},sr={props_p4005=1}},
                    s3={bn=10,p=998,g=599,r={p={p4006=1}},sr={props_p4006=1}},
                },
                {  -- 特殊商店 10 -- 飞机
                    s1={bn=5,p=2226,g=1336,r={p={p4618=1}},sr={props_p4618=1}},
                    s2={bn=5,p=288,g=173,r={p={p4617=1}},sr={props_p4617=1}},
                    s3={bn=5,p=250,g=150,r={p={p4201=50}},sr={props_p4201=50}},
                    s4={bn=5,p=498,g=299,r={p={p4205=1}},sr={props_p4205=1}},
                    s5={bn=5,p=998,g=599,r={p={p4206=1}},sr={props_p4206=1}},
                    s6={bn=5,p=540,g=324,r={p={p4204=5}},sr={props_p4204=5}},
                    s7={bn=5,p=540,g=324,r={p={p4203=30}},sr={props_p4203=30}},
                    s8={bn=5,p=500,g=300,r={p={p4630=10}},sr={props_p4630=10}},
                },
                {  -- 特殊商店 11 -- 矩阵
                    s1={bn=10,p=3000,g=1800,r={p={p4604=1}},sr={props_p4604=1}},
                    s2={bn=10,p=500,g=300,r={p={p4603=1}},sr={props_p4603=1}},
                    s3={bn=20,p=1500,g=900,r={am={exp=30000}},sr={armor_exp=30000}},
                    s4={bn=20,p=1000,g=600,r={am={exp=20000}},sr={armor_exp=20000}},
                    s5={bn=20,p=500,g=300,r={am={exp=10000}},sr={armor_exp=10000}},
                    s6={bn=20,p=250,g=150,r={am={exp=5000}},sr={armor_exp=5000}},
                    s7={bn=20,p=100,g=60,r={am={exp=2000}},sr={armor_exp=2000}},
                },
            },
        },
        [3]={
            basicShop={
                {  -- 基础商店 1 -- 基础
                    i1={bn=80,p=480,g=240,r={p={p1=1}},sr={props_p1=1}},
                    i2={bn=80,p=560,g=280,r={p={p49=1}},sr={props_p49=1}},
                    i3={bn=80,p=210,g=105,r={p={p5=1}},sr={props_p5=1}},
                    i4={bn=80,p=28,g=14,r={p={p15=1}},sr={props_p15=1}},
                    i5={bn=80,p=98,g=49,r={p={p16=1}},sr={props_p16=1}},
                    i6={bn=80,p=2000,g=1000,r={p={p401=1}},sr={props_p401=1}},
                    i7={bn=80,p=2000,g=1000,r={p={p402=1}},sr={props_p402=1}},
                    i8={bn=80,p=2000,g=1000,r={p={p403=1}},sr={props_p403=1}},
                    i9={bn=80,p=2000,g=1000,r={p={p404=1}},sr={props_p404=1}},
                },
                {  -- 基础商店 2 -- 配件
                    i1={bn=80,p=800,g=400,r={p={p90=1}},sr={props_p90=1}},
                    i2={bn=80,p=1280,g=640,r={p={p270=1}},sr={props_p270=1}},
                    i3={bn=80,p=1280,g=640,r={p={p566=1}},sr={props_p566=1}},
                    i4={bn=80,p=1600,g=800,r={e={p3=400}},sr={accessory_p3=400}},
                    i5={bn=80,p=1600,g=800,r={e={p2=80}},sr={accessory_p2=80}},
                    i6={bn=80,p=1600,g=800,r={e={p1=40}},sr={accessory_p1=40}},
                },
                {  -- 基础商店 3 -- 异星科技
                    i1={bn=50,p=1000,g=500,r={p={p867=1}},sr={props_p867=1}},
                    i2={bn=50,p=1000,g=500,r={p={p868=1}},sr={props_p868=1}},
                    i3={bn=50,p=1000,g=500,r={p={p869=1}},sr={props_p869=1}},
                    i4={bn=50,p=2800,g=560,r={p={p4=1}},sr={props_p4=1}},
                    i5={bn=50,p=160,g=32,r={p={p32=1}},sr={props_p32=1}},
                    i6={bn=50,p=160,g=32,r={p={p33=1}},sr={props_p33=1}},
                    i7={bn=50,p=160,g=32,r={p={p34=1}},sr={props_p34=1}},
                    i8={bn=50,p=160,g=32,r={p={p35=1}},sr={props_p35=1}},
                    i9={bn=50,p=160,g=32,r={p={p36=1}},sr={props_p36=1}},
                },
                {  -- 基础商店 4 -- 融合齿轮
                    i1={bn=50,p=1000,g=500,r={w={p1=10000}},sr={weapon_p1=10000}},
                    i2={bn=50,p=290,g=145,r={p={p912=5}},sr={props_p912=5}},
                    i3={bn=50,p=2250,g=1125,r={w={c5=1}},sr={weapon_c5=1}},
                    i4={bn=50,p=2250,g=1125,r={w={c15=1}},sr={weapon_c15=1}},
                    i5={bn=50,p=2250,g=1125,r={w={c25=1}},sr={weapon_c25=1}},
                    i6={bn=50,p=2250,g=1125,r={w={c35=1}},sr={weapon_c35=1}},
                    i7={bn=50,p=2250,g=1125,r={w={c45=1}},sr={weapon_c45=1}},
                    i8={bn=50,p=2250,g=1125,r={w={c55=1}},sr={weapon_c55=1}},
                    i9={bn=50,p=2250,g=1125,r={w={c65=1}},sr={weapon_c65=1}},
                    i10={bn=50,p=2250,g=1125,r={w={c75=1}},sr={weapon_c75=1}},
                    i11={bn=50,p=2250,g=1125,r={w={c85=1}},sr={weapon_c85=1}},
                    i12={bn=50,p=2250,g=1125,r={w={c95=1}},sr={weapon_c95=1}},
                },
                {  -- 基础商店 5 -- 坦克
                    i1={bn=50,p=6000,g=2400,r={o={a10095=50}},sr={troops_a10095=50}},
                    i2={bn=50,p=6000,g=2400,r={o={a20155=50}},sr={troops_a20155=50}},
                    i3={bn=50,p=6000,g=2400,r={o={a10045=50}},sr={troops_a10045=50}},
                    i4={bn=50,p=6000,g=2400,r={o={a20055=50}},sr={troops_a20055=50}},
                    i5={bn=50,p=6000,g=2400,r={o={a10135=50}},sr={troops_a10135=50}},
                    i6={bn=50,p=6000,g=2400,r={o={a10075=50}},sr={troops_a10075=50}},
                    i7={bn=50,p=6000,g=2400,r={o={a10145=50}},sr={troops_a10145=50}},
                    i8={bn=50,p=6000,g=2400,r={o={a20115=50}},sr={troops_a20115=50}},
                    i9={bn=50,p=6000,g=2400,r={o={a20125=50}},sr={troops_a20125=50}},
                    i10={bn=50,p=2500,g=1000,r={o={a10163=50}},sr={troops_a10163=50}},
                    i11={bn=50,p=4000,g=1600,r={o={a10164=50}},sr={troops_a10164=50}},
                },
                {  -- 基础商店 6 -- 将领
                    i1={bn=50,p=3200,g=1600,r={p={p601=100}},sr={props_p601=100}},
                    i2={bn=50,p=4900,g=2450,r={h={s2=50}},sr={hero_s2=50}},
                    i3={bn=50,p=4900,g=2450,r={h={s3=50}},sr={hero_s3=50}},
                    i4={bn=50,p=1900,g=950,r={h={s33=50}},sr={hero_s33=50}},
                    i5={bn=50,p=1900,g=950,r={h={s34=50}},sr={hero_s34=50}},
                    i6={bn=50,p=1900,g=950,r={h={s35=50}},sr={hero_s35=50}},
                    i7={bn=50,p=1900,g=950,r={h={s36=50}},sr={hero_s36=50}},
                    i8={bn=50,p=1900,g=950,r={h={s37=50}},sr={hero_s37=50}},
                    i9={bn=50,p=1900,g=950,r={h={s31=50}},sr={hero_s31=50}},
                    i10={bn=50,p=1900,g=950,r={h={s19=50}},sr={hero_s19=50}},
                    i11={bn=50,p=1900,g=950,r={h={s38=50}},sr={hero_s38=50}},
                    i12={bn=50,p=1900,g=950,r={h={s40=50}},sr={hero_s40=50}},
                },
                {  -- 基础商店 7 -- 攻击型道具
                    i1={bn=50,p=1200,g=600,r={p={p421=6}},sr={props_p421=6}},
                    i2={bn=50,p=708,g=354,r={p={p46=6}},sr={props_p46=6}},
                    i3={bn=50,p=600,g=300,r={p={p423=6}},sr={props_p423=6}},
                    i4={bn=50,p=1500,g=750,r={p={p427=3}},sr={props_p427=3}},
                    i5={bn=50,p=1500,g=750,r={p={p428=3}},sr={props_p428=3}},
                    i6={bn=50,p=1500,g=750,r={p={p429=3}},sr={props_p429=3}},
                    i7={bn=50,p=1500,g=750,r={p={p430=3}},sr={props_p430=3}},
                },
                {  -- 基础商店 8 -- 将领装备
                    i1={bn=50,p=250,g=125,r={p={p469=10}},sr={props_p469=10}},
                    i2={bn=50,p=250,g=125,r={p={p470=10}},sr={props_p470=10}},
                    i3={bn=50,p=250,g=125,r={p={p471=10}},sr={props_p471=10}},
                    i4={bn=50,p=500,g=250,r={p={p472=10}},sr={props_p472=10}},
                    i5={bn=50,p=500,g=250,r={p={p473=10}},sr={props_p473=10}},
                    i6={bn=50,p=500,g=250,r={p={p474=10}},sr={props_p474=10}},
                    i7={bn=50,p=1000,g=500,r={p={p475=10}},sr={props_p475=10}},
                    i8={bn=50,p=1000,g=500,r={p={p476=10}},sr={props_p476=10}},
                    i9={bn=50,p=1000,g=500,r={p={p477=10}},sr={props_p477=10}},
                },
                {  -- 基础商店 9 -- 军徽
                    i1={bn=50,p=100,g=80,r={p={p4001=100}},sr={props_p4001=100}},
                    i2={bn=50,p=90,g=72,r={p={p4003=5}},sr={props_p4003=5}},
                    i3={bn=50,p=196,g=157,r={p={p4004=2}},sr={props_p4004=2}},
                },
                {  -- 基础商店 10 -- 飞机
                    i1={bn=20,p=2226,g=1781,r={p={p4618=1}},sr={props_p4618=1}},
                    i2={bn=20,p=288,g=230,r={p={p4617=1}},sr={props_p4617=1}},
                    i3={bn=20,p=250,g=200,r={p={p4201=50}},sr={props_p4201=50}},
                    i4={bn=20,p=498,g=398,r={p={p4205=1}},sr={props_p4205=1}},
                    i5={bn=20,p=540,g=432,r={p={p4204=5}},sr={props_p4204=5}},
                    i6={bn=20,p=270,g=216,r={p={p4203=15}},sr={props_p4203=15}},
                    i7={bn=20,p=250,g=200,r={p={p4630=5}},sr={props_p4630=5}},
                },
                {  -- 基础商店 11 -- 矩阵
                    i1={bn=20,p=3000,g=2400,r={p={p4604=1}},sr={props_p4604=1}},
                    i2={bn=40,p=500,g=400,r={p={p4603=1}},sr={props_p4603=1}},
                    i3={bn=20,p=1500,g=1200,r={am={exp=30000}},sr={armor_exp=30000}},
                    i4={bn=20,p=1000,g=800,r={am={exp=20000}},sr={armor_exp=20000}},
                    i5={bn=20,p=500,g=400,r={am={exp=10000}},sr={armor_exp=10000}},
                    i6={bn=20,p=250,g=200,r={am={exp=5000}},sr={armor_exp=5000}},
                    i7={bn=20,p=100,g=80,r={am={exp=2000}},sr={armor_exp=2000}},
                },
            },
            specialShop={
                {  -- 特殊商店 1 -- 基础
                    s1={bn=5,p=480,g=48,r={p={p1=1}},sr={props_p1=1}},
                    s2={bn=5,p=560,g=56,r={p={p49=1}},sr={props_p49=1}},
                    s3={bn=5,p=210,g=21,r={p={p5=1}},sr={props_p5=1}},
                    s4={bn=5,p=140,g=14,r={p={p15=5}},sr={props_p15=5}},
                    s5={bn=5,p=98,g=10,r={p={p16=1}},sr={props_p16=1}},
                    s6={bn=20,p=500,g=50,r={p={p393=50}},sr={props_p393=50}},
                    s7={bn=20,p=500,g=50,r={p={p394=50}},sr={props_p394=50}},
                    s8={bn=20,p=500,g=50,r={p={p395=50}},sr={props_p395=50}},
                    s9={bn=20,p=500,g=50,r={p={p396=50}},sr={props_p396=50}},
                    s10={bn=5,p=100,g=10,r={p={p419=1}},sr={props_p419=1}},
                },
                {  -- 特殊商店 2 -- 配件
                    s1={bn=5,p=800,g=80,r={p={p90=1}},sr={props_p90=1}},
                    s2={bn=5,p=1280,g=128,r={p={p270=1}},sr={props_p270=1}},
                    s3={bn=5,p=1280,g=128,r={p={p566=1}},sr={props_p566=1}},
                    s4={bn=5,p=800,g=80,r={p={p267=1}},sr={props_p267=1}},
                    s5={bn=50,p=400,g=40,r={e={p3=100}},sr={accessory_p3=100}},
                    s6={bn=50,p=400,g=40,r={e={p2=20}},sr={accessory_p2=20}},
                    s7={bn=50,p=400,g=40,r={e={p1=10}},sr={accessory_p1=10}},
                    s8={bn=50,p=100,g=10,r={e={p6=5}},sr={accessory_p6=5}},
                    s9={bn=10,p=500,g=50,r={e={p5=5}},sr={accessory_p5=5}},
                    s10={bn=5,p=800,g=80,r={p={p565=1}},sr={props_p565=1}},
                },
                {  -- 特殊商店 3 -- 异星科技
                    s1={bn=5,p=1000,g=100,r={p={p867=1}},sr={props_p867=1}},
                    s2={bn=5,p=1000,g=100,r={p={p868=1}},sr={props_p868=1}},
                    s3={bn=5,p=1000,g=100,r={p={p869=1}},sr={props_p869=1}},
                    s4={bn=5,p=10000,g=1000,r={p={p870=1}},sr={props_p870=1}},
                    s5={bn=5,p=10000,g=1000,r={p={p871=1}},sr={props_p871=1}},
                    s6={bn=5,p=10000,g=1000,r={p={p872=1}},sr={props_p872=1}},
                },
                {  -- 特殊商店 4 -- 融合齿轮
                    s1={bn=50,p=100,g=10,r={w={p1=1000}},sr={weapon_p1=1000}},
                    s2={bn=20,p=290,g=29,r={p={p912=5}},sr={props_p912=5}},
                    s3={bn=5,p=14520,g=1452,r={w={c7=1}},sr={weapon_c7=1}},
                    s4={bn=5,p=14520,g=1452,r={w={c17=1}},sr={weapon_c17=1}},
                    s5={bn=5,p=14520,g=1452,r={w={c27=1}},sr={weapon_c27=1}},
                    s6={bn=5,p=14520,g=1452,r={w={c37=1}},sr={weapon_c37=1}},
                    s7={bn=5,p=14520,g=1452,r={w={c47=1}},sr={weapon_c47=1}},
                    s8={bn=5,p=14520,g=1452,r={w={c57=1}},sr={weapon_c57=1}},
                    s9={bn=5,p=14520,g=1452,r={w={c67=1}},sr={weapon_c67=1}},
                    s10={bn=5,p=14520,g=1452,r={w={c77=1}},sr={weapon_c77=1}},
                    s11={bn=5,p=14520,g=1452,r={w={c87=1}},sr={weapon_c87=1}},
                    s12={bn=5,p=14520,g=1452,r={w={c97=1}},sr={weapon_c97=1}},
                },
                {  -- 特殊商店 5 -- 坦克
                    s1={bn=25,p=2400,g=240,r={o={a10095=20}},sr={troops_a10095=20}},
                    s2={bn=25,p=2400,g=240,r={o={a20155=20}},sr={troops_a20155=20}},
                    s3={bn=25,p=2400,g=240,r={o={a10045=20}},sr={troops_a10045=20}},
                    s4={bn=25,p=2400,g=240,r={o={a20055=20}},sr={troops_a20055=20}},
                    s5={bn=25,p=2400,g=240,r={o={a10135=20}},sr={troops_a10135=20}},
                    s6={bn=25,p=2400,g=240,r={o={a10075=20}},sr={troops_a10075=20}},
                    s7={bn=25,p=2400,g=240,r={o={a10145=20}},sr={troops_a10145=20}},
                    s8={bn=25,p=2400,g=240,r={o={a20115=20}},sr={troops_a20115=20}},
                    s9={bn=25,p=2400,g=240,r={o={a20125=20}},sr={troops_a20125=20}},
                    s10={bn=80,p=500,g=50,r={o={a10163=10}},sr={troops_a10163=10}},
                    s11={bn=80,p=800,g=80,r={o={a10164=10}},sr={troops_a10164=10}},
                },
                {  -- 特殊商店 6 -- 将领
                    s1={bn=25,p=640,g=64,r={p={p601=20}},sr={props_p601=20}},
                    s2={bn=25,p=1960,g=196,r={h={s25=20}},sr={hero_s25=20}},
                    s3={bn=25,p=1960,g=196,r={h={s13=20}},sr={hero_s13=20}},
                    s4={bn=25,p=1960,g=196,r={h={s24=20}},sr={hero_s24=20}},
                    s5={bn=25,p=1960,g=196,r={h={s15=20}},sr={hero_s15=20}},
                    s6={bn=25,p=1960,g=196,r={h={s1=20}},sr={hero_s1=20}},
                    s7={bn=25,p=1960,g=196,r={h={s4=20}},sr={hero_s4=20}},
                    s8={bn=25,p=1960,g=196,r={h={s5=20}},sr={hero_s5=20}},
                    s9={bn=25,p=760,g=76,r={h={s23=20}},sr={hero_s23=20}},
                    s10={bn=25,p=760,g=76,r={h={s22=20}},sr={hero_s22=20}},
                    s11={bn=25,p=760,g=76,r={h={s11=20}},sr={hero_s11=20}},
                    s12={bn=25,p=760,g=76,r={h={s27=20}},sr={hero_s27=20}},
                },
                {  -- 特殊商店 7 -- 攻击型道具
                    s1={bn=15,p=450,g=45,r={p={p424=1}},sr={props_p424=1}},
                    s2={bn=15,p=450,g=45,r={p={p425=1}},sr={props_p425=1}},
                    s3={bn=15,p=450,g=45,r={p={p426=1}},sr={props_p426=1}},
                    s4={bn=15,p=1000,g=100,r={p={p431=1}},sr={props_p431=1}},
                    s5={bn=15,p=1000,g=100,r={p={p432=1}},sr={props_p432=1}},
                    s6={bn=15,p=1000,g=100,r={p={p433=1}},sr={props_p433=1}},
                    s7={bn=15,p=1000,g=100,r={p={p434=1}},sr={props_p434=1}},
                },
                {  -- 特殊商店 8 -- 将领装备
                    s1={bn=20,p=250,g=25,r={p={p472=5}},sr={props_p472=5}},
                    s2={bn=20,p=250,g=25,r={p={p473=5}},sr={props_p473=5}},
                    s3={bn=20,p=250,g=25,r={p={p474=5}},sr={props_p474=5}},
                    s4={bn=20,p=500,g=50,r={p={p475=5}},sr={props_p475=5}},
                    s5={bn=20,p=500,g=50,r={p={p476=5}},sr={props_p476=5}},
                    s6={bn=20,p=500,g=50,r={p={p477=5}},sr={props_p477=5}},
                    s7={bn=10,p=500,g=50,r={p={p454=5}},sr={props_p454=5}},
                    s8={bn=10,p=500,g=50,r={p={p455=5}},sr={props_p455=5}},
                    s9={bn=10,p=500,g=50,r={p={p456=5}},sr={props_p456=5}},
                    s10={bn=10,p=500,g=50,r={p={p457=5}},sr={props_p457=5}},
                    s11={bn=10,p=1000,g=100,r={p={p458=5}},sr={props_p458=5}},
                    s12={bn=10,p=600,g=60,r={p={p481=1}},sr={props_p481=1}},
                },
                {  -- 特殊商店 9 -- 军徽
                    s1={bn=10,p=1888,g=1133,r={p={p4002=1}},sr={props_p4002=1}},
                    s2={bn=10,p=498,g=299,r={p={p4005=1}},sr={props_p4005=1}},
                    s3={bn=10,p=998,g=599,r={p={p4006=1}},sr={props_p4006=1}},
                },
                {  -- 特殊商店 10 -- 飞机
                    s1={bn=5,p=2226,g=1336,r={p={p4618=1}},sr={props_p4618=1}},
                    s2={bn=5,p=288,g=173,r={p={p4617=1}},sr={props_p4617=1}},
                    s3={bn=50,p=25,g=15,r={p={p4201=5}},sr={props_p4201=5}},
                    s4={bn=5,p=498,g=299,r={p={p4205=1}},sr={props_p4205=1}},
                    s5={bn=5,p=998,g=599,r={p={p4206=1}},sr={props_p4206=1}},
                    s6={bn=25,p=108,g=65,r={p={p4204=1}},sr={props_p4204=1}},
                    s7={bn=50,p=54,g=32,r={p={p4203=3}},sr={props_p4203=3}},
                    s8={bn=25,p=100,g=60,r={p={p4630=2}},sr={props_p4630=2}},
                },
                {  -- 特殊商店 11 -- 矩阵
                    s1={bn=10,p=3000,g=1800,r={p={p4604=1}},sr={props_p4604=1}},
                    s2={bn=10,p=500,g=300,r={p={p4603=1}},sr={props_p4603=1}},
                    s3={bn=50,p=600,g=360,r={am={exp=12000}},sr={armor_exp=12000}},
                    s4={bn=50,p=400,g=240,r={am={exp=8000}},sr={armor_exp=8000}},
                    s5={bn=50,p=200,g=120,r={am={exp=4000}},sr={armor_exp=4000}},
                    s6={bn=50,p=100,g=60,r={am={exp=2000}},sr={armor_exp=2000}},
                    s7={bn=50,p=40,g=24,r={am={exp=800}},sr={armor_exp=800}},
                },
            },
        },
    [4]={        
            basicShop={
                {  -- 基础商店 1 -- 基础
                    i1={bn=80,p=480,g=240,r={p={p1=1}},sr={props_p1=1}},
                    i2={bn=80,p=560,g=280,r={p={p49=1}},sr={props_p49=1}},
                    i3={bn=80,p=210,g=105,r={p={p5=1}},sr={props_p5=1}},
                    i4={bn=80,p=28,g=14,r={p={p15=1}},sr={props_p15=1}},
                    i5={bn=80,p=98,g=49,r={p={p16=1}},sr={props_p16=1}},
                    i6={bn=80,p=2000,g=1000,r={p={p401=1}},sr={props_p401=1}},
                    i7={bn=80,p=2000,g=1000,r={p={p402=1}},sr={props_p402=1}},
                    i8={bn=80,p=2000,g=1000,r={p={p403=1}},sr={props_p403=1}},
                    i9={bn=80,p=2000,g=1000,r={p={p404=1}},sr={props_p404=1}},
                    i10={bn=20,p=400,g=200,r={p={p5033=10}},sr={props_p5033=10}},
                    i11={bn=20,p=440,g=220,r={p={p4945=5}},sr={props_p4945=5}},
                },
                {  -- 基础商店 2 -- 配件
                    i1={bn=80,p=800,g=400,r={p={p90=1}},sr={props_p90=1}},
                    i2={bn=80,p=1280,g=640,r={p={p270=1}},sr={props_p270=1}},
                    i3={bn=80,p=1280,g=640,r={p={p566=1}},sr={props_p566=1}},
                    i4={bn=80,p=1600,g=800,r={e={p3=400}},sr={accessory_p3=400}},
                    i5={bn=80,p=1600,g=800,r={e={p2=80}},sr={accessory_p2=80}},
                    i6={bn=80,p=1600,g=800,r={e={p1=40}},sr={accessory_p1=40}},
                    i7={bn=50,p=100,g=50,r={e={p6=5}},sr={accessory_p6=5}},
                    i8={bn=20,p=500,g=250,r={e={p5=5}},sr={accessory_p5=5}},
                    i9={bn=20,p=950,g=475,r={p={p4824=5}},sr={props_p4824=5}},
                    i10={bn=20,p=950,g=475,r={p={p4825=5}},sr={props_p4825=5}},
                },
                {  -- 基础商店 3 -- 异星科技
                    i1={bn=50,p=1000,g=500,r={p={p867=1}},sr={props_p867=1}},
                    i2={bn=50,p=1000,g=500,r={p={p868=1}},sr={props_p868=1}},
                    i3={bn=50,p=1000,g=500,r={p={p869=1}},sr={props_p869=1}},
                    i4={bn=50,p=2800,g=560,r={p={p4=1}},sr={props_p4=1}},
                    i5={bn=50,p=160,g=32,r={p={p32=1}},sr={props_p32=1}},
                    i6={bn=50,p=160,g=32,r={p={p33=1}},sr={props_p33=1}},
                    i7={bn=50,p=160,g=32,r={p={p34=1}},sr={props_p34=1}},
                    i8={bn=50,p=160,g=32,r={p={p35=1}},sr={props_p35=1}},
                    i9={bn=50,p=160,g=32,r={p={p36=1}},sr={props_p36=1}},
                },
                {  -- 基础商店 4 -- 融合齿轮
                    i1={bn=50,p=1000,g=500,r={w={p1=10000}},sr={weapon_p1=10000}},
                    i2={bn=50,p=290,g=145,r={p={p912=5}},sr={props_p912=5}},
                    i3={bn=50,p=2250,g=1125,r={w={c5=1}},sr={weapon_c5=1}},
                    i4={bn=50,p=2250,g=1125,r={w={c15=1}},sr={weapon_c15=1}},
                    i5={bn=50,p=2250,g=1125,r={w={c25=1}},sr={weapon_c25=1}},
                    i6={bn=50,p=2250,g=1125,r={w={c35=1}},sr={weapon_c35=1}},
                    i7={bn=50,p=2250,g=1125,r={w={c45=1}},sr={weapon_c45=1}},
                    i8={bn=50,p=2250,g=1125,r={w={c55=1}},sr={weapon_c55=1}},
                    i9={bn=50,p=2250,g=1125,r={w={c65=1}},sr={weapon_c65=1}},
                    i10={bn=50,p=2250,g=1125,r={w={c75=1}},sr={weapon_c75=1}},
                    i11={bn=50,p=2250,g=1125,r={w={c85=1}},sr={weapon_c85=1}},
                    i12={bn=50,p=2250,g=1125,r={w={c95=1}},sr={weapon_c95=1}},
                },
                {  -- 基础商店 5 -- 坦克
                    i1={bn=50,p=6000,g=2400,r={o={a10095=50}},sr={troops_a10095=50}},
                    i2={bn=50,p=6000,g=2400,r={o={a20155=50}},sr={troops_a20155=50}},
                    i3={bn=50,p=6000,g=2400,r={o={a10045=50}},sr={troops_a10045=50}},
                    i4={bn=50,p=6000,g=2400,r={o={a20055=50}},sr={troops_a20055=50}},
                    i5={bn=50,p=6000,g=2400,r={o={a10135=50}},sr={troops_a10135=50}},
                    i6={bn=50,p=6000,g=2400,r={o={a10075=50}},sr={troops_a10075=50}},
                    i7={bn=50,p=6000,g=2400,r={o={a10145=50}},sr={troops_a10145=50}},
                    i8={bn=50,p=6000,g=2400,r={o={a20115=50}},sr={troops_a20115=50}},
                    i9={bn=50,p=6000,g=2400,r={o={a20125=50}},sr={troops_a20125=50}},
                    i10={bn=50,p=2500,g=1000,r={o={a10163=50}},sr={troops_a10163=50}},
                    i11={bn=50,p=4000,g=1600,r={o={a10164=50}},sr={troops_a10164=50}},
                },
                {  -- 基础商店 6 -- 将领
                    i1={bn=50,p=3200,g=1600,r={p={p601=100}},sr={props_p601=100}},
                    i2={bn=50,p=4900,g=2450,r={h={s2=50}},sr={hero_s2=50}},
                    i3={bn=50,p=4900,g=2450,r={h={s3=50}},sr={hero_s3=50}},
                    i4={bn=50,p=1900,g=950,r={h={s33=50}},sr={hero_s33=50}},
                    i5={bn=50,p=1900,g=950,r={h={s34=50}},sr={hero_s34=50}},
                    i6={bn=50,p=1900,g=950,r={h={s35=50}},sr={hero_s35=50}},
                    i7={bn=50,p=1900,g=950,r={h={s36=50}},sr={hero_s36=50}},
                    i8={bn=50,p=1900,g=950,r={h={s37=50}},sr={hero_s37=50}},
                    i9={bn=50,p=1900,g=950,r={h={s31=50}},sr={hero_s31=50}},
                    i10={bn=50,p=1900,g=950,r={h={s19=50}},sr={hero_s19=50}},
                    i11={bn=50,p=1900,g=950,r={h={s38=50}},sr={hero_s38=50}},
                    i12={bn=50,p=1900,g=950,r={h={s40=50}},sr={hero_s40=50}},
                    i13={bn=50,p=4900,g=2450,r={h={s4=50}},sr={hero_s4=50}},
                    i14={bn=50,p=4900,g=2450,r={h={s39=50}},sr={hero_s39=50}},
                    i15={bn=50,p=1900,g=950,r={h={s21=50}},sr={hero_s21=50}},
                    i16={bn=50,p=1900,g=950,r={h={s11=50}},sr={hero_s11=50}},
                    i17={bn=50,p=1900,g=950,r={h={s8=50}},sr={hero_s8=50}},
                },
                {  -- 基础商店 7 -- 攻击型道具
                    i1={bn=50,p=1200,g=600,r={p={p421=6}},sr={props_p421=6}},
                    i2={bn=50,p=708,g=354,r={p={p46=6}},sr={props_p46=6}},
                    i3={bn=50,p=600,g=300,r={p={p423=6}},sr={props_p423=6}},
                    i4={bn=50,p=1500,g=750,r={p={p427=3}},sr={props_p427=3}},
                    i5={bn=50,p=1500,g=750,r={p={p428=3}},sr={props_p428=3}},
                    i6={bn=50,p=1500,g=750,r={p={p429=3}},sr={props_p429=3}},
                    i7={bn=50,p=1500,g=750,r={p={p430=3}},sr={props_p430=3}},
                },
                {  -- 基础商店 8 -- 将领装备
                    i1={bn=50,p=250,g=125,r={p={p469=10}},sr={props_p469=10}},
                    i2={bn=50,p=250,g=125,r={p={p470=10}},sr={props_p470=10}},
                    i3={bn=50,p=250,g=125,r={p={p471=10}},sr={props_p471=10}},
                    i4={bn=50,p=500,g=250,r={p={p472=10}},sr={props_p472=10}},
                    i5={bn=50,p=500,g=250,r={p={p473=10}},sr={props_p473=10}},
                    i6={bn=50,p=500,g=250,r={p={p474=10}},sr={props_p474=10}},
                    i7={bn=50,p=1000,g=500,r={p={p475=10}},sr={props_p475=10}},
                    i8={bn=50,p=1000,g=500,r={p={p476=10}},sr={props_p476=10}},
                    i9={bn=50,p=1000,g=500,r={p={p477=10}},sr={props_p477=10}},
                    i10={bn=50,p=580,g=290,r={p={p4971=10}},sr={props_p4971=10}},
                },
                {  -- 基础商店 9 -- 军徽
                    i1={bn=50,p=100,g=80,r={p={p4001=100}},sr={props_p4001=100}},
                    i2={bn=50,p=90,g=72,r={p={p4003=5}},sr={props_p4003=5}},
                    i3={bn=50,p=196,g=157,r={p={p4004=2}},sr={props_p4004=2}},
                },
                {  -- 基础商店 10 -- 飞机
                    i1={bn=20,p=2226,g=1781,r={p={p4618=1}},sr={props_p4618=1}},
                    i2={bn=20,p=288,g=230,r={p={p4617=1}},sr={props_p4617=1}},
                    i3={bn=20,p=250,g=200,r={p={p4201=50}},sr={props_p4201=50}},
                    i4={bn=20,p=498,g=398,r={p={p4205=1}},sr={props_p4205=1}},
                    i5={bn=20,p=540,g=432,r={p={p4204=5}},sr={props_p4204=5}},
                    i6={bn=20,p=270,g=216,r={p={p4203=15}},sr={props_p4203=15}},
                    i7={bn=20,p=250,g=200,r={p={p4630=5}},sr={props_p4630=5}},
                },
                {  -- 基础商店 11 -- 矩阵
                    i1={bn=20,p=3000,g=2400,r={p={p4604=1}},sr={props_p4604=1}},
                    i2={bn=40,p=500,g=400,r={p={p4603=1}},sr={props_p4603=1}},
                    i3={bn=20,p=1500,g=1200,r={am={exp=30000}},sr={armor_exp=30000}},
                    i4={bn=20,p=1000,g=800,r={am={exp=20000}},sr={armor_exp=20000}},
                    i5={bn=20,p=500,g=400,r={am={exp=10000}},sr={armor_exp=10000}},
                    i6={bn=20,p=250,g=200,r={am={exp=5000}},sr={armor_exp=5000}},
                    i7={bn=20,p=100,g=80,r={am={exp=2000}},sr={armor_exp=2000}},
                },
            },
            specialShop={
                {  -- 特殊商店 1 -- 基础
                    s1={bn=5,p=480,g=48,r={p={p1=1}},sr={props_p1=1}},
                    s2={bn=5,p=560,g=56,r={p={p49=1}},sr={props_p49=1}},
                    s3={bn=5,p=210,g=21,r={p={p5=1}},sr={props_p5=1}},
                    s4={bn=5,p=140,g=14,r={p={p15=5}},sr={props_p15=5}},
                    s5={bn=5,p=98,g=10,r={p={p16=1}},sr={props_p16=1}},
                    s6={bn=20,p=500,g=50,r={p={p393=50}},sr={props_p393=50}},
                    s7={bn=20,p=500,g=50,r={p={p394=50}},sr={props_p394=50}},
                    s8={bn=20,p=500,g=50,r={p={p395=50}},sr={props_p395=50}},
                    s9={bn=20,p=500,g=50,r={p={p396=50}},sr={props_p396=50}},
                    s10={bn=5,p=100,g=10,r={p={p419=1}},sr={props_p419=1}},
                    s11={bn=10,p=200,g=20,r={p={p5033=5}},sr={props_p5033=5}},
                    s12={bn=10,p=440,g=44,r={p={p4945=5}},sr={props_p4945=5}},
                },
                {  -- 特殊商店 2 -- 配件
                    s1={bn=5,p=800,g=80,r={p={p90=1}},sr={props_p90=1}},
                    s2={bn=5,p=1280,g=128,r={p={p270=1}},sr={props_p270=1}},
                    s3={bn=5,p=1280,g=128,r={p={p566=1}},sr={props_p566=1}},
                    s4={bn=5,p=800,g=80,r={p={p267=1}},sr={props_p267=1}},
                    s5={bn=50,p=400,g=40,r={e={p3=100}},sr={accessory_p3=100}},
                    s6={bn=50,p=400,g=40,r={e={p2=20}},sr={accessory_p2=20}},
                    s7={bn=50,p=400,g=40,r={e={p1=10}},sr={accessory_p1=10}},
                    s8={bn=50,p=100,g=10,r={e={p6=5}},sr={accessory_p6=5}},
                    s9={bn=10,p=500,g=50,r={e={p5=5}},sr={accessory_p5=5}},
                    s10={bn=5,p=800,g=80,r={p={p565=1}},sr={props_p565=1}},
                    s11={bn=10,p=190,g=19,r={p={p4824=1}},sr={props_p4824=1}},
                    s12={bn=10,p=190,g=19,r={p={p4825=1}},sr={props_p4825=1}},
                },
                {  -- 特殊商店 3 -- 异星科技
                    s1={bn=5,p=1000,g=100,r={p={p867=1}},sr={props_p867=1}},
                    s2={bn=5,p=1000,g=100,r={p={p868=1}},sr={props_p868=1}},
                    s3={bn=5,p=1000,g=100,r={p={p869=1}},sr={props_p869=1}},
                    s4={bn=5,p=10000,g=1000,r={p={p870=1}},sr={props_p870=1}},
                    s5={bn=5,p=10000,g=1000,r={p={p871=1}},sr={props_p871=1}},
                    s6={bn=5,p=10000,g=1000,r={p={p872=1}},sr={props_p872=1}},
                },
                {  -- 特殊商店 4 -- 融合齿轮
                    s1={bn=50,p=100,g=10,r={w={p1=1000}},sr={weapon_p1=1000}},
                    s2={bn=20,p=290,g=29,r={p={p912=5}},sr={props_p912=5}},
                    s3={bn=5,p=14520,g=1452,r={w={c7=1}},sr={weapon_c7=1}},
                    s4={bn=5,p=14520,g=1452,r={w={c17=1}},sr={weapon_c17=1}},
                    s5={bn=5,p=14520,g=1452,r={w={c27=1}},sr={weapon_c27=1}},
                    s6={bn=5,p=14520,g=1452,r={w={c37=1}},sr={weapon_c37=1}},
                    s7={bn=5,p=14520,g=1452,r={w={c47=1}},sr={weapon_c47=1}},
                    s8={bn=5,p=14520,g=1452,r={w={c57=1}},sr={weapon_c57=1}},
                    s9={bn=5,p=14520,g=1452,r={w={c67=1}},sr={weapon_c67=1}},
                    s10={bn=5,p=14520,g=1452,r={w={c77=1}},sr={weapon_c77=1}},
                    s11={bn=5,p=14520,g=1452,r={w={c87=1}},sr={weapon_c87=1}},
                    s12={bn=5,p=14520,g=1452,r={w={c97=1}},sr={weapon_c97=1}},
                },
                {  -- 特殊商店 5 -- 坦克
                    s1={bn=25,p=2400,g=240,r={o={a10095=20}},sr={troops_a10095=20}},
                    s2={bn=25,p=2400,g=240,r={o={a20155=20}},sr={troops_a20155=20}},
                    s3={bn=25,p=2400,g=240,r={o={a10045=20}},sr={troops_a10045=20}},
                    s4={bn=25,p=2400,g=240,r={o={a20055=20}},sr={troops_a20055=20}},
                    s5={bn=25,p=2400,g=240,r={o={a10135=20}},sr={troops_a10135=20}},
                    s6={bn=25,p=2400,g=240,r={o={a10075=20}},sr={troops_a10075=20}},
                    s7={bn=25,p=2400,g=240,r={o={a10145=20}},sr={troops_a10145=20}},
                    s8={bn=25,p=2400,g=240,r={o={a20115=20}},sr={troops_a20115=20}},
                    s9={bn=25,p=2400,g=240,r={o={a20125=20}},sr={troops_a20125=20}},
                    s10={bn=80,p=500,g=50,r={o={a10163=10}},sr={troops_a10163=10}},
                    s11={bn=80,p=800,g=80,r={o={a10164=10}},sr={troops_a10164=10}},
                },
                {  -- 特殊商店 6 -- 将领
                    s1={bn=25,p=640,g=64,r={p={p601=20}},sr={props_p601=20}},
                    s2={bn=25,p=1960,g=196,r={h={s25=20}},sr={hero_s25=20}},
                    s3={bn=25,p=1960,g=196,r={h={s13=20}},sr={hero_s13=20}},
                    s4={bn=25,p=1960,g=196,r={h={s24=20}},sr={hero_s24=20}},
                    s5={bn=25,p=1960,g=196,r={h={s15=20}},sr={hero_s15=20}},
                    s6={bn=25,p=1960,g=196,r={h={s1=20}},sr={hero_s1=20}},
                    s7={bn=25,p=1960,g=196,r={h={s4=20}},sr={hero_s4=20}},
                    s8={bn=25,p=1960,g=196,r={h={s5=20}},sr={hero_s5=20}},
                    s9={bn=25,p=760,g=76,r={h={s23=20}},sr={hero_s23=20}},
                    s10={bn=25,p=760,g=76,r={h={s22=20}},sr={hero_s22=20}},
                    s11={bn=25,p=760,g=76,r={h={s11=20}},sr={hero_s11=20}},
                    s12={bn=25,p=760,g=76,r={h={s27=20}},sr={hero_s27=20}},
                    s13={bn=25,p=1960,g=196,r={h={s39=20}},sr={hero_s39=20}},
                },
                {  -- 特殊商店 7 -- 攻击型道具
                    s1={bn=15,p=450,g=45,r={p={p424=1}},sr={props_p424=1}},
                    s2={bn=15,p=450,g=45,r={p={p425=1}},sr={props_p425=1}},
                    s3={bn=15,p=450,g=45,r={p={p426=1}},sr={props_p426=1}},
                    s4={bn=15,p=1000,g=100,r={p={p431=1}},sr={props_p431=1}},
                    s5={bn=15,p=1000,g=100,r={p={p432=1}},sr={props_p432=1}},
                    s6={bn=15,p=1000,g=100,r={p={p433=1}},sr={props_p433=1}},
                    s7={bn=15,p=1000,g=100,r={p={p434=1}},sr={props_p434=1}},
                },
                {  -- 特殊商店 8 -- 将领装备
                    s1={bn=20,p=250,g=25,r={p={p472=5}},sr={props_p472=5}},
                    s2={bn=20,p=250,g=25,r={p={p473=5}},sr={props_p473=5}},
                    s3={bn=20,p=250,g=25,r={p={p474=5}},sr={props_p474=5}},
                    s4={bn=20,p=500,g=50,r={p={p475=5}},sr={props_p475=5}},
                    s5={bn=20,p=500,g=50,r={p={p476=5}},sr={props_p476=5}},
                    s6={bn=20,p=500,g=50,r={p={p477=5}},sr={props_p477=5}},
                    s7={bn=10,p=500,g=50,r={p={p454=5}},sr={props_p454=5}},
                    s8={bn=10,p=500,g=50,r={p={p455=5}},sr={props_p455=5}},
                    s9={bn=10,p=500,g=50,r={p={p456=5}},sr={props_p456=5}},
                    s10={bn=10,p=500,g=50,r={p={p457=5}},sr={props_p457=5}},
                    s11={bn=10,p=1000,g=100,r={p={p458=5}},sr={props_p458=5}},
                    s12={bn=10,p=600,g=60,r={p={p481=1}},sr={props_p481=1}},
                    s13={bn=10,p=190,g=19,r={p={p4970=5}},sr={props_p4970=5}},
                    s14={bn=10,p=290,g=29,r={p={p4971=5}},sr={props_p4971=5}},
                },
                {  -- 特殊商店 9 -- 军徽
                    s1={bn=10,p=1888,g=1133,r={p={p4002=1}},sr={props_p4002=1}},
                    s2={bn=10,p=498,g=299,r={p={p4005=1}},sr={props_p4005=1}},
                    s3={bn=10,p=998,g=599,r={p={p4006=1}},sr={props_p4006=1}},
                },
                {  -- 特殊商店 10 -- 飞机
                    s1={bn=5,p=2226,g=1336,r={p={p4618=1}},sr={props_p4618=1}},
                    s2={bn=5,p=288,g=173,r={p={p4617=1}},sr={props_p4617=1}},
                    s3={bn=50,p=25,g=15,r={p={p4201=5}},sr={props_p4201=5}},
                    s4={bn=5,p=498,g=299,r={p={p4205=1}},sr={props_p4205=1}},
                    s5={bn=5,p=998,g=599,r={p={p4206=1}},sr={props_p4206=1}},
                    s6={bn=25,p=108,g=65,r={p={p4204=1}},sr={props_p4204=1}},
                    s7={bn=50,p=54,g=32,r={p={p4203=3}},sr={props_p4203=3}},
                    s8={bn=25,p=100,g=60,r={p={p4630=2}},sr={props_p4630=2}},
                },
                {  -- 特殊商店 11 -- 矩阵
                    s1={bn=10,p=3000,g=1800,r={p={p4604=1}},sr={props_p4604=1}},
                    s2={bn=10,p=500,g=300,r={p={p4603=1}},sr={props_p4603=1}},
                    s3={bn=50,p=600,g=360,r={am={exp=12000}},sr={armor_exp=12000}},
                    s4={bn=50,p=400,g=240,r={am={exp=8000}},sr={armor_exp=8000}},
                    s5={bn=50,p=200,g=120,r={am={exp=4000}},sr={armor_exp=4000}},
                    s6={bn=50,p=100,g=60,r={am={exp=2000}},sr={armor_exp=2000}},
                    s7={bn=50,p=40,g=24,r={am={exp=800}},sr={armor_exp=800}},
                },
            },
        
        },
    },

    --蒸蒸日上
zzrsCfg={
    multiSelectType=true,
     [1]={
         type=1,
         version=1,
         sortId=319,
        
                    bonusPointReward={  --最终大奖各阶段奖励(前台)
                            {r={{r4=1000,index=1},{r5=1000,index=2},{r6=500,index=3}}},
                            {r={{r4=2000,index=1},{r5=2000,index=2},{r6=1000,index=3}}},
                            {r={{r4=3000,index=1},{r5=3000,index=2},{r6=1500,index=3}}},
                            {r={{r4=4000,index=1},{r5=4000,index=2},{r6=2000,index=3}}},
                            {r={{r4=5000,index=1},{r5=5000,index=2},{r6=2500,index=3}}},
                            {r={{r4=6000,index=1},{r5=6000,index=2},{r6=3000,index=3}}},
                            {r={{r4=7000,index=1},{r5=7000,index=2},{r6=3500,index=3}}},
                            {r={{r4=8000,index=1},{r5=8000,index=2},{r6=4000,index=3}}},
                            {r={{r4=9000,index=1},{r5=9000,index=2},{r6=4500,index=3}}},
                            {r={{r4=10000,index=1},{r5=10000,index=2},{r6=5000,index=3}}},
                    },
                    qtype={ --每日的任务类型,每天为一个TABLE
                            {"fa","bn","cn","pp","pe"},
                            {"hy","up","ht","aj","rc"},
                            {"gba","fb","uh","th","ta"},
                            {"mb","bc","hu","ua","ab"},
                            {"tp","wp","ut","we","rg"},
                    },
                    taskList={  --每日任务详情
                            d1={
                                    q1={
                                            need={1,2,4,8},
                                            reward={
                                                {p={{p13=1,index=1}}},
                                                {p={{p20=2,index=1},{p19=5,index=2}}},
                                                {p={{p20=3,index=1},{p19=10,index=2}}},
                                                {p={{p20=5,index=1},{p19=20,index=2},{p47=3,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q2={
                                            need={1,3,5,10},
                                            reward={
                                                {r={{r3=100,index=1}}},
                                                {p={{p47=2,index=1},{p14=1,index=2}}},
                                                {p={{p20=2,index=1},{p19=5,index=2}}},
                                                {p={{p20=4,index=1},{p19=10,index=2},{p435=1,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q3={
                                            need={20,40,70,100},
                                            reward={
                                                {p={{p19=5,index=1}}},
                                                {p={{p19=5,index=1},{p447=2,index=2}}},
                                                {p={{p19=10,index=1},{p447=2,index=2},{p393=5,index=3}}},
                                                {p={{p394=8,index=1},{p395=8,index=2},{p396=8,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q4={
                                            need={5,15,30,50},
                                            reward={
                                                {p={{p13=1,index=1}}},
                                                {p={{p13=1,index=1},{p15=1,index=2}}},
                                                {p={{p11=1,index=1},{p12=1,index=2},{p44=1,index=3}}},
                                                {p={{p42=1,index=1},{p43=1,index=2},{p46=1,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q5={
                                            need={5,10,20,30},
                                            reward={
                                                {r={{r1=100,index=1}}},
                                                {r={{r1=150,index=1},{r2=150,index=2}}},
                                                {r={{r2=200,index=1},{r3=200,index=2}}},
                                                {r={{r4=100,index=1},{r5=100,index=2},{r6=50,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                            },
                            d2={
                                    q1={
                                            need={1,3,5,7},
                                            reward={
                                                {f={{e1=500,index=1}}},
                                                {f={{e2=500,index=1},{e3=500,index=2}}},
                                                {f={{e1=1000,index=1}},p={{p933=1,index=2}}},
                                                {f={{e1=1000,index=1},{e3=1000,index=2}},p={{p933=2,index=3}}},
                                            },
                                            flicker={{},{},{ "b","y"},{ "b","b","y"}},
                                    },
                                    q2={
                                            need={3,6,9,12},
                                            reward={
                                                {p={{p14=1,index=1}}},
                                                {p={{p12=1,index=1},{p11=1,index=2}}},
                                                {p={{p42=1,index=1},{p43=1,index=2}}},
                                                {p={{p44=1,index=1},{p45=1,index=2},{p47=3,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q3={
                                            need={10,25,40,60},
                                            reward={
                                                {f={{e1=800,index=1}}},
                                                {f={{e1=1000,index=1}},p={{p447=5,index=2}}},
                                                {p={{p472=3,index=1},{p473=3,index=2},{p474=3,index=3}}},
                                                {p={{p475=3,index=1},{p476=3,index=2},{p477=3,index=3}}},
                                            },
                                            flicker={{},{ "b",""},{ "b","b","b"},{ "p","p","p"}},
                                    },
                                    q4={
                                            need={3,6,10,15},
                                            reward={
                                                {p={{p35=1,index=1}}},
                                                {e={{p8=150,index=2}},p={{p35=1,index=1}}},
                                                {e={{p8=150,index=1},{p9=150,index=2}}},
                                                {e={{p8=150,index=1},{p9=150,index=2},{p10=150,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q5={
                                            need={1,2,3,5},
                                            reward={
                                                {r={{r1=200,index=1}}},
                                                {r={{r1=200,index=1},{r2=200,index=2}}},
                                                {r={{r2=300,index=1},{r3=300,index=2}}},
                                                {r={{r4=300,index=1},{r5=300,index=2},{r6=300,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                            },
                            d3={
                                    q1={
                                            need={50,300,2000,8400},
                                            reward={
                                                {r={{r3=100,index=1}}},
                                                {r={{r3=200,index=1},{r4=200,index=2}}},
                                                {r={{r3=300,index=1},{r4=300,index=2},{r5=300,index=3}}},
                                                {r={{r4=500,index=1},{r5=500,index=2},{r6=500,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q2={
                                            need={6,12,18,24},
                                            reward={
                                                {p={{p4003=1,index=1}}},
                                                {p={{p4003=1,index=1},{p4001=100,index=2}}},
                                                {p={{p4003=2,index=1},{p4001=150,index=2}}},
                                                {p={{p4003=2,index=1},{p4004=1,index=2},{p4001=200,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q3={
                                            need={1,2,3,5},
                                            reward={
                                                {p={{p447=1,index=1}}},
                                                {p={{p447=1,index=1},{p601=1,index=2}}},
                                                {p={{p447=2,index=1},{p601=2,index=2}}},
                                                {p={{p447=3,index=1},{p601=3,index=2},{p607=3,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q4={
                                            need={4,8,12,18},
                                            reward={
                                                {p={{p601=2,index=1}}},
                                                {p={{p601=3,index=1},{p606=3,index=2}}},
                                                {p={{p601=5,index=1},{p606=5,index=2}}},
                                                {p={{p601=8,index=1},{p606=8,index=2},{p607=8,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q5={
                                            need={5,12,20,30},
                                            reward={
                                                {am={{exp=300,index=1}}},
                                                {am={{exp=500,index=1}}},
                                                {p={{p19=5,index=2}},am={{exp=800,index=1}}},
                                                {p={{p19=10,index=2},{p4602=1,index=3}},am={{exp=1000,index=1}}},
                                            },
                                            flicker={{},{},{},{ "b","",""}},
                                    },
                            },
                            d4={
                                    q1={
                                            need={5,10,15,20},
                                            reward={
                                                {p={{p881=1,index=1}}},
                                                {f={{e2=500,index=2}},p={{p881=2,index=1}}},
                                                {p={{p933=1,index=1},{p881=2,index=2}}},
                                                {f={{e1=500,index=2}},p={{p933=2,index=1},{p881=3,index=3}}},
                                            },
                                            flicker={{},{},{ "y",""},{ "y","",""}},
                                    },
                                    q2={
                                            need={5,10,15,20},
                                            reward={
                                                {p={{p19=5,index=1}}},
                                                {p={{p19=5,index=1},{p447=2,index=2}}},
                                                {p={{p19=10,index=1},{p447=3,index=2},{p393=5,index=3}}},
                                                {p={{p394=10,index=1},{p395=10,index=2},{p396=10,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q3={
                                            need={1,3,5,8},
                                            reward={
                                                {f={{e1=500,index=1}}},
                                                {f={{e2=500,index=1},{e3=500,index=2}}},
                                                {f={{e1=800,index=1},{e2=800,index=2}}},
                                                {f={{e1=1000,index=1},{e3=1000,index=2}},p={{p933=1,index=3}}},
                                            },
                                            flicker={{},{},{},{ "b","b","y"}},
                                    },
                                    q4={
                                            need={2,4,7,10},
                                            reward={
                                                {am={{exp=300,index=1}}},
                                                {am={{exp=500,index=1}}},
                                                {p={{p19=5,index=2}},am={{exp=800,index=1}}},
                                                {p={{p19=10,index=2},{p4602=1,index=3}},am={{exp=1000,index=1}}},
                                            },
                                            flicker={{},{},{},{ "b","",""}},
                                    },
                                    q5={
                                            need={3,7,12,20},
                                            reward={
                                                {p={{p881=1,index=1}}},
                                                {p={{p881=1,index=1},{p417=1,index=2}}},
                                                {p={{p881=1,index=1},{p417=2,index=2}}},
                                                {e={{p5=1,index=3}},p={{p881=2,index=1},{p417=2,index=2}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                            },
                            d5={
                                    q1={
                                            need={2,4,7,10},
                                            reward={
                                                {p={{p4203=1,index=1}}},
                                                {p={{p4203=2,index=1},{p4201=10,index=2}}},
                                                {p={{p4203=2,index=1},{p4201=15,index=2}}},
                                                {p={{p4203=3,index=1},{p4201=20,index=2}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                                    q2={
                                            need={5,8,15,20},
                                            reward={
                                                {w={{p1=300,index=1}}},
                                                {p={{p912=1,index=2}},w={{p1=500,index=1}}},
                                                {w={{f1=1,index=1},{p1=700,index=2}}},
                                                {w={{f21=1,index=1},{p1=1000,index=2}}},
                                            },
                                            flicker={{},{},{ "b",""},{ "p",""}},
                                    },
                                    q3={
                                            need={20,40,70,100},
                                            reward={
                                                {p={{p3411=2,index=1}}},
                                                {p={{p3412=1,index=1}}},
                                                {p={{p3411=1,index=1},{p3412=1,index=2}}},
                                                {p={{p3413=1,index=1},{p3412=2,index=2}}},
                                            },
                                            flicker={{},{},{},{ "b",""}},
                                    },
                                    q4={
                                            need={15,30,45,75},
                                            reward={
                                                {w={{c31=1,index=1}}},
                                                {w={{c32=1,index=1}}},
                                                {w={{c81=1,index=1},{c82=1,index=2}}},
                                                {w={{f27=1,index=1},{c1=2,index=2},{c2=2,index=3}}},
                                            },
                                            flicker={{},{},{},{ "p","",""}},
                                    },
                                    q5={
                                            need={2,4,7,10},
                                            reward={
                                                {r={{r3=100,index=1}}},
                                                {r={{r3=200,index=1},{r4=100,index=2}}},
                                                {r={{r3=300,index=1},{r4=200,index=2},{r5=200,index=3}}},
                                                {r={{r4=300,index=1},{r5=300,index=2},{r6=100,index=3}}},
                                            },
                                            flicker={{},{},{},{}},
                                    },
                            },
                    },
            },
},
cflm={
    multiSelectType=true,
    [1]={
        _activeCfg=true,
        hx=1,
        --限制等级
        levelLimit=30,
        --A基金限制(vip等级)
        vipLimit=3,
        --A基金投资金额
        fundA=2000,
        --B基金限制(充值金额)
        rechargeLimit=2000,
        --B基金投资金额
        fundB=6000,
        --手动领取系数
        needValue=1.3,
        --充值档位
        rechargLevel={50,300,800,2000},
        --延长时间('天)
        prolongTime=4,
        --连续冲几天获得大奖
        rechargDay=5,
        --前端展示大奖
        exhibitReward={p={{p4840=8,index=1}}},
        rechargereward={  --前台每日充值奖励
            {50,{p={{p447=1,index=1},{p19=1,index=2},{p20=1,index=3}}}},
            {300,{p={{p447=2,index=1},{p19=2,index=2},{p20=1,index=3}}}},
            {800,{p={{p447=4,index=1},{p19=2,index=2},{p20=1,index=3}}}},
            {2000,{p={{p4840=1,index=1},{p19=2,index=2},{p20=1,index=3}}}},
        },
        finalreward={  --终极大奖
            {50,{p={{p4204=1,index=1},{p4203=4,index=2}},am={{exp=800,index=3}}}},
            {300,{p={{p4840=1,index=1},{p4203=10,index=2}},am={{exp=3000,index=3}}}},
            {800,{p={{p4840=3,index=1},{p4203=20,index=2}},am={{exp=6000,index=3}}}},
            {2000,{p={{p4840=8,index=1},{p4203=50,index=2}},am={{exp=15000,index=3}}}},
        },
        fundAreward={  --前台A基金奖励
            {1,{e={{p4=1800,index=2}},u={{gems=680,index=1}},am={{exp=2000,index=3}}}},
            {2,{e={{p4=600,index=2}},u={{gems=680,index=1}},am={{exp=1000,index=3}}}},
            {3,{e={{p4=1200,index=2}},u={{gems=680,index=1}},am={{exp=1500,index=3}}}},
            {4,{e={{p4=600,index=2}},u={{gems=680,index=1}},am={{exp=1000,index=3}}}},
            {5,{e={{p4=1800,index=2}},u={{gems=680,index=1}},am={{exp=2000,index=3}}}},
        },
        fundBreward={  --前台B基金奖励
            {1,{e={{p4=4500,index=2}},u={{gems=1300,index=1}},am={{exp=6000,index=3}}}},
            {2,{e={{p4=1500,index=2}},u={{gems=1300,index=1}},am={{exp=2000,index=3}}}},
            {3,{e={{p4=3000,index=2}},u={{gems=1300,index=1}},am={{exp=4000,index=3}}}},
            {4,{e={{p4=1500,index=2}},u={{gems=1300,index=1}},am={{exp=2000,index=3}}}},
            {5,{e={{p4=4500,index=2}},u={{gems=1300,index=1}},am={{exp=6000,index=3}}}},
        },
    },
    [2]={
        _activeCfg=true,
        hx=1,
        --限制等级
        levelLimit=30,
        --A基金限制(vip等级)
        vipLimit=3,
        --A基金投资金额
        fundA=2000,
        --B基金限制(充值金额)
        rechargeLimit=2000,
        --B基金投资金额
        fundB=6000,
        --手动领取系数
        needValue=1.3,
        --充值档位
        rechargLevel={50,300,800,2000},
        --延长时间('天)
        prolongTime=4,
        --连续冲几天获得大奖
        rechargDay=5,
        --前端展示大奖
        exhibitReward={p={{p4843=8,index=1}}},
        rechargereward={  --前台每日充值奖励
            {50,{p={{p866=3,index=1},{p19=2,index=2},{p3326=2,index=3}}}},
            {300,{p={{p866=5,index=1},{p19=4,index=2},{p3326=4,index=3}}}},
            {800,{p={{p866=8,index=1},{p19=8,index=2},{p3326=8,index=3}}}},
            {2000,{p={{p4843=3,index=1},{p19=12,index=2},{p3326=12,index=3}}}},
        },
        finalreward={  --终极大奖
            {50,{p={{p4204=3,index=1},{p4631=4,index=2}},am={{exp=800,index=3}}}},
            {300,{p={{p4843=1,index=1},{p4631=10,index=2}},am={{exp=3000,index=3}}}},
            {800,{p={{p4843=3,index=1},{p4631=20,index=2}},am={{exp=6000,index=3}}}},
            {2000,{p={{p4843=8,index=1},{p4631=50,index=2}},am={{exp=15000,index=3}}}},
        },
        fundAreward={  --前台A基金奖励
            {1,{e={{p12=10,index=2}},u={{gems=500,index=1}},am={{exp=2000,index=3}}}},
            {2,{e={{p12=10,index=2}},u={{gems=500,index=1}},am={{exp=1000,index=3}}}},
            {3,{e={{p12=10,index=2}},u={{gems=500,index=1}},am={{exp=1500,index=3}}}},
            {4,{e={{p12=10,index=2}},u={{gems=500,index=1}},am={{exp=1000,index=3}}}},
            {5,{e={{p12=10,index=2}},u={{gems=500,index=1}},am={{exp=2000,index=3}}}},
        },
        fundBreward={  --前台B基金奖励
            {1,{e={{p12=30,index=2}},u={{gems=1300,index=1}},am={{exp=6000,index=3}}}},
            {2,{e={{p12=10,index=2}},u={{gems=1300,index=1}},am={{exp=2000,index=3}}}},
            {3,{e={{p12=20,index=2}},u={{gems=1300,index=1}},am={{exp=4000,index=3}}}},
            {4,{e={{p12=10,index=2}},u={{gems=1300,index=1}},am={{exp=2000,index=3}}}},
            {5,{e={{p12=30,index=2}},u={{gems=1300,index=1}},am={{exp=6000,index=3}}}},
        },
    },
},


          wpbdCfg={
                    multiSelectType=true,
                    [1]={
                        _activeCfg=true,
                        hx=1,
                        --☆锁定价格：对应坦克，歼击车，自行火炮，火箭车
                        lockCost={8,5,5,8},
                        --☆抽奖价格：{普通价格/高级抽奖价格}
                        cost={58,158},
                        --☆抽奖给的积分,普通高级抽奖励积分相同
                        score={50,150},
                        --☆抽奖倍率转盘(前端）：第一组为普通倍率，第二组为高级倍率库
                        rateShow={{1,3,2,1,2,3},{3,4,5,2,6,3},},
                        -----坦克类型库的奖池和初始奖池配置（前端）,firstpool为初始奖池配置，pool1--坦克库，pool2歼击车，pool3自行火炮，pool4火箭车
                        reward={
                            firstpool={
                                {o={{a10075=1,index=1},{a10074=1,index=2},{a10123=1,index=3},{a10054=1,index=4},{a10114=1,index=5},{a10135=1,index=6},{a10043=1,index=7},{a10045=1,index=8},{a10044=1,index=9},{a10084=1,index=10},{a10083=1,index=11},{a10164=1,index=11}}},
                            },
                            pool1={o={{a10073=1,index=1},{a10093=1,index=2},{a10123=1,index=3},{a10074=1,index=4},{a10094=1,index=5},{a10124=1,index=6},{a10075=1,index=7},{a10095=1,index=8}}},
                            pool2={o={{a10053=1,index=1},{a10113=1,index=2},{a10133=1,index=3},{a10143=1,index=4},{a10054=1,index=5},{a10114=1,index=6},{a10134=1,index=7},{a10144=1,index=8},{a10135=1,index=9},{a10145=1,index=10}}},
                            pool3={o={{a10043=1,index=1},{a10063=1,index=2},{a10044=1,index=3},{a10064=1,index=4},{a10045=1,index=5}}},
                            pool4={o={{a10082=1,index=1},{a10163=1,index=2},{a10083=1,index=3},{a10164=1,index=4},{a10084=1,index=5},{a10165=1,index=6}}},
                        },
                        -----消耗玩家有的金币坦克来兑换活动积分，score--兑换给积分，limitNum--兑换数量上限，tid---坦克id, consume----消耗的坦克
                        exchange={
                            {id=1,score=5,limitNum=70,tid=10073},
                            {id=2,score=5,limitNum=70,tid=10093},
                            {id=3,score=5,limitNum=70,tid=10123},
                            {id=4,score=5,limitNum=70,tid=10053},
                            {id=5,score=5,limitNum=70,tid=10113},
                            {id=6,score=5,limitNum=70,tid=10133},
                            {id=7,score=5,limitNum=70,tid=10143},
                            {id=8,score=5,limitNum=70,tid=10043},
                            {id=9,score=5,limitNum=70,tid=10063},
                            {id=10,score=5,limitNum=70,tid=10082},
                            {id=11,score=5,limitNum=70,tid=10163},
                            {id=12,score=18,limitNum=40,tid=10074},
                            {id=13,score=18,limitNum=40,tid=10094},
                            {id=14,score=18,limitNum=40,tid=10124},
                            {id=15,score=18,limitNum=40,tid=10054},
                            {id=16,score=18,limitNum=40,tid=10114},
                            {id=17,score=18,limitNum=40,tid=10134},
                            {id=18,score=18,limitNum=40,tid=10144},
                            {id=19,score=18,limitNum=40,tid=10044},
                            {id=20,score=18,limitNum=40,tid=10064},
                            {id=21,score=18,limitNum=40,tid=10083},
                            {id=22,score=18,limitNum=40,tid=10164},
                            {id=23,score=36,limitNum=30,tid=10075},
                            {id=24,score=36,limitNum=30,tid=10095},
                            {id=25,score=36,limitNum=30,tid=10135},
                            {id=26,score=36,limitNum=30,tid=10145},
                            {id=27,score=36,limitNum=30,tid=10045},
                            {id=28,score=36,limitNum=30,tid=10084},
                            {id=29,score=36,limitNum=30,tid=10165},
                        },
                        ----消耗积分换道具,p---消耗积分值,limitNum--可购买数量，costNum--可抽奖次数
                        shoplist={
                            {id=1,costNum=20,p=750,limitNum=50,reward={o={a10008=1}}},
                            {id=2,costNum=15,p=750,limitNum=50,reward={o={a10018=1}}},
                            {id=3,costNum=12,p=750,limitNum=50,reward={o={a10038=1}}},
                            {id=4,costNum=10,p=750,limitNum=50,reward={o={a10028=1}}},
                            {id=5,costNum=8,p=50,limitNum=50,reward={p={p393=1}}},
                            {id=6,costNum=6,p=50,limitNum=50,reward={p={p394=1}}},
                            {id=7,costNum=4,p=50,limitNum=50,reward={p={p395=1}}},
                            {id=8,costNum=2,p=50,limitNum=50,reward={p={p396=1}}},
                            {id=9,costNum=1,p=10,limitNum=10000,reward={u={gold=10000}}},
                        },
                    },
                },

smcj={
    multiSelectType=true,
    [1]={
        _activeCfg=true,
        ----活动开启等级
        openLv=60,
        ----最低累计充值金币
        rechargeMin=3240,
        ----活动持续时间
        lastDay=7,
        ----排行榜取并列前X名
        rankingNum=10,
        ----排行榜展示前X名
        rShowNum=20,
        ----充值礼包每天限购次数
        dailyGiftNum=5,
        ----充值礼包充值金额
        giftGold=200,
        ----每天总积分({第1天，第2天}）
        dailytotScore={800,800,800,800,800,800,800,},
        --每日充值奖励礼包;[x]--第X天；reward前台配置
        dailyGiftList={
            [1]={reward={p={{p3203=5,index=1},{p3204=5,index=2},{p3205=5,index=3}}}},
            [2]={reward={w={{c200=1,index=1},{c201=1,index=2},{p1=10000,index=3}}}},
            [3]={reward={e={{p1=10,index=1},{p2=10,index=2},{p3=40,index=3}}}},
            [4]={reward={p={{p3106=20,index=1},{p911=2,index=2},{p4949=2,index=3}}}},
            [5]={reward={p={{p4001=200,index=1},{p4916=5,index=3},{p19=10,index=2}}}},
            [6]={reward={p={{p4631=50,index=1},{p4630=1,index=2},{p4201=50,index=3}}}},
            [7]={reward={p={{p4986=1,index=2},{p4984=1,index=3}},at={{p1=10,index=1}}}},
        },
        ---累计积分库；needScore所需积分数
        scoreReward={
            {needScore=300,reward={p={{p601=10,index=1},{p4001=100,index=2}}}},
            {needScore=1000,reward={p={{p601=30,index=1},{p4001=200,index=2}}}},
            {needScore=2000,reward={p={{p4986=2,index=1},{p606=10,index=2},{p4001=500,index=3}}}},
            {needScore=4000,reward={p={{p607=20,index=1},{p3302=30,index=2},{p4001=1500,index=3}}}},
            {needScore=5500,reward={p={{p230=1,index=1},{p608=10,index=2},{p4001=2000,index=3}}}},
        },
        dailytask={
            ----每天任务类型
            {"gb","ht","hu","hy"},
            {"gb","wp","wh","we"},
            {"gb","aj","au","av"},
            {"gb","cn","pe","pp"},
            {"gb","eb","st","sj"},
            {"gb","jb","pr","mb"},
            {"gb","ac","ai1","ai2"},
        },
        dailyTaskList={
            -----每日任务类型和奖励；gb充值，将领（ht装备探索次数;hu装备强化次数；hy深度研究次数）；超武（wp掠夺玩家次数；we神秘组织次数;wh宝石合成次数）;配件（au强化次数；ab补给线次数；aj精炼次数）
            -----打架（cn攻打关卡；pp攻打玩家；pe攻打资源）；eb远征次数；st训练军徽部队；sj军徽进阶次数；pr飞机融合；jb消费金币；mb军演次数;ac消耗ai部队经验道具数；ai1生产任意级别ai部队次数；ai2生产中级及中级以上ai部队的次数
            [1]={
                t1={
                    {needNum=50,score=200,reward={p={{p601=10,index=1},{p3203=5,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p601=5,index=1},{p3203=2,index=2}}}},
                    {needNum=10,score=50,reward={p={{p606=2,index=1},{p3204=2,index=2}}}},
                    {needNum=20,score=120,reward={p={{p607=2,index=1},{p3205=5,index=2}}}},
                },
                t3={
                    {needNum=1,score=30,reward={p={{p482=1,index=1},{p3203=2,index=2}}}},
                    {needNum=3,score=50,reward={p={{p483=1,index=1},{p3204=2,index=2}}}},
                    {needNum=5,score=120,reward={p={{p484=1,index=1},{p3205=5,index=2}}}},
                },
                t4={
                    {needNum=1,score=30,reward={p={{p485=1,index=1},{p933=1,index=2}}}},
                    {needNum=2,score=50,reward={p={{p486=1,index=1},{p933=3,index=2}}}},
                    {needNum=3,score=120,reward={p={{p487=1,index=1},{p481=1,index=2}}}},
                },
            },
            [2]={
                t1={
                    {needNum=50,score=200,reward={p={{p911=2,index=1},{p265=1,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p911=1,index=1},{p912=2,index=2}}}},
                    {needNum=15,score=50,reward={p={{p918=1,index=1},{p913=3,index=2}}}},
                    {needNum=30,score=120,reward={p={{p919=1,index=1},{p914=3,index=2}}}},
                },
                t3={
                    {needNum=1,score=30,reward={w={{c201=1,index=1},{p1=1000,index=2}}}},
                    {needNum=3,score=50,reward={w={{c200=2,index=1},{p1=2000,index=2}}}},
                    {needNum=5,score=120,reward={w={{c200=3,index=1},{c201=2,index=2}}}},
                },
                t4={
                    {needNum=20,score=30,reward={p={{p263=1,index=1},{p913=2,index=2}}}},
                    {needNum=60,score=50,reward={p={{p264=1,index=1},{p914=2,index=2}}}},
                    {needNum=120,score=120,reward={p={{p265=1,index=1},{p911=5,index=2}}}},
                },
            },
            [3]={
                t1={
                    {needNum=50,score=200,reward={e={{p10=1000,index=1}},p={{p19=20,index=2}}}},
                },
                t2={
                    {needNum=10,score=30,reward={e={{p8=500,index=1}},p={{p19=5,index=2}}}},
                    {needNum=20,score=50,reward={e={{p9=500,index=1},{p10=500,index=2}}}},
                    {needNum=50,score=120,reward={e={{p10=1000,index=1},{p9=1000,index=2}}}},
                },
                t3={
                    {needNum=2,score=30,reward={e={{p4=200,index=2}},p={{p96=1,index=1}}}},
                    {needNum=5,score=50,reward={e={{p6=2,index=1},{p4=500,index=2}}}},
                    {needNum=10,score=120,reward={e={{p6=3,index=2}},p={{p812=2,index=1}}}},
                },
                t4={
                    {needNum=1,score=30,reward={e={{p4=200,index=2}},p={{p417=2,index=1}}}},
                    {needNum=2,score=50,reward={e={{p5=3,index=1},{p4=500,index=2}}}},
                    {needNum=3,score=120,reward={p={{p815=2,index=1},{p417=5,index=2}}}},
                },
            },
            [4]={
                t1={
                    {needNum=50,score=200,reward={p={{p3302=2,index=1},{p20=10,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p3326=10,index=1},{p19=10,index=2}}}},
                    {needNum=10,score=50,reward={p={{p4949=1,index=1},{p19=20,index=2}}}},
                    {needNum=20,score=120,reward={p={{p3302=2,index=1},{p4949=2,index=2}}}},
                },
                t3={
                    {needNum=5,score=30,reward={o={{a10103=5,index=1}},p={{p51=1,index=2}}}},
                    {needNum=10,score=50,reward={o={{a10104=5,index=1}},p={{p51=1,index=2}}}},
                    {needNum=20,score=120,reward={o={{a10104=10,index=1},{a10103=10,index=2}}}},
                },
                t4={
                    {needNum=5,score=30,reward={p={{p3412=2,index=1},{p5=1,index=2}}}},
                    {needNum=10,score=50,reward={p={{p3413=2,index=1},{p13=1,index=2}}}},
                    {needNum=20,score=120,reward={p={{p435=2,index=1},{p423=2,index=2}}}},
                },
            },
            [5]={
                t1={
                    {needNum=50,score=200,reward={p={{p818=5,index=1},{p4001=200,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p601=5,index=1},{p19=5,index=2}}}},
                    {needNum=10,score=50,reward={p={{p819=5,index=1},{p19=10,index=2}}}},
                    {needNum=15,score=120,reward={p={{p818=10,index=1},{p601=10,index=2}}}},
                },
                t3={
                    {needNum=50,score=30,reward={p={{p4916=5,index=1},{p4001=50,index=2}}}},
                    {needNum=150,score=50,reward={p={{p4916=20,index=1},{p4001=100,index=2}}}},
                    {needNum=300,score=120,reward={p={{p4916=50,index=1},{p4001=200,index=2}}}},
                },
                t4={
                    {needNum=1,score=30,reward={p={{p4003=1,index=1},{p4001=100,index=2}}}},
                    {needNum=2,score=50,reward={p={{p4004=1,index=1},{p4001=200,index=2}}}},
                    {needNum=5,score=120,reward={p={{p4005=1,index=1},{p4001=500,index=2}}}},
                },
            },
            [6]={
                t1={
                    {needNum=50,score=200,reward={p={{p4631=50,index=1},{p4944=1,index=2}}}},
                },
                t2={
                    {needNum=50,score=30,reward={p={{p47=10,index=1},{p1365=5,index=2}}}},
                    {needNum=200,score=50,reward={p={{p4630=2,index=1},{p1365=10,index=2}}}},
                    {needNum=500,score=120,reward={p={{p4631=50,index=1},{p47=10,index=2}}}},
                },
                t3={
                    {needNum=1,score=30,reward={p={{p4203=1,index=1},{p4201=50,index=2}}}},
                    {needNum=2,score=50,reward={p={{p4204=1,index=1},{p4201=100,index=2}}}},
                    {needNum=5,score=120,reward={p={{p4202=1,index=1},{p4631=50,index=2}}}},
                },
                t4={
                    {needNum=5,score=30,reward={p={{p959=2,index=1},{p20=10,index=2}}}},
                    {needNum=10,score=50,reward={p={{p3506=2,index=1},{p19=10,index=2}}}},
                    {needNum=15,score=120,reward={p={{p3506=5,index=1},{p959=5,index=2}}}},
                },
            },
            [7]={
                t1={
                    {needNum=50,score=200,reward={p={{p988=10,index=2}},at={{p1=10,index=1}}}},
                },
                t2={
                    {needNum=50,score=30,reward={p={{p4964=2,index=2}},at={{p1=5,index=1}}}},
                    {needNum=100,score=50,reward={p={{p4965=2,index=2}},at={{p1=10,index=1}}}},
                    {needNum=200,score=120,reward={p={{p4965=5,index=2}},at={{p1=30,index=1}}}},
                },
                t3={
                    {needNum=10,quality=0,score=30,reward={p={{p877=20,index=1},{p19=5,index=2}}}},
                    {needNum=20,quality=0,score=50,reward={p={{p878=20,index=1},{p19=10,index=2}}}},
                    {needNum=40,quality=0,score=120,reward={p={{p1363=30,index=1},{p19=20,index=2}}}},
                },
                t4={
                    {needNum=5,quality={2,3},score=30,reward={p={{p983=10,index=2}},at={{p1=10,index=1}}}},
                    {needNum=15,quality={2,3},score=50,reward={p={{p4948=10,index=2}},at={{p1=20,index=1}}}},
                    {needNum=30,quality={2,3},score=120,reward={p={{p1363=10,index=2}},at={{p1=40,index=1}}}},
                },
            },
        },
        rankingReward={
            ---排行榜奖励
            {rank={1,1},reward={p={{p3303=5,index=1},{p4985=10,index=2}}}},
            {rank={2,2},reward={p={{p3303=4,index=1},{p4985=8,index=2}}}},
            {rank={3,5},reward={p={{p3303=3,index=1},{p4985=6,index=2}}}},
            {rank={6,10},reward={p={{p3303=2,index=1},{p4985=5,index=2}}}},
        },
    },
    [2]={
        _activeCfg=true,
        ----活动开启等级
        openLv=60,
        ----最低累计充值金币
        rechargeMin=1200,
        ----活动持续时间
        lastDay=7,
        ----排行榜取并列前X名
        rankingNum=10,
        ----排行榜展示前X名
        rShowNum=20,
        ----充值礼包每天限购次数
        dailyGiftNum=5,
        ----充值礼包充值金额
        giftGold=200,
        ----每天总积分({第1天，第2天}）
        dailytotScore={800,800,800,800,800,800,800,},
        --每日充值奖励礼包;[x]--第X天；reward前台配置
        dailyGiftList={
            [1]={reward={p={{p3203=5,index=1},{p3204=5,index=2},{p3205=5,index=3}}}},
            [2]={reward={w={{c200=1,index=1},{c201=1,index=2},{p1=10000,index=3}}}},
            [3]={reward={e={{p1=10,index=1},{p2=10,index=2},{p3=40,index=3}}}},
            [4]={reward={p={{p3106=20,index=1},{p911=2,index=2},{p4949=2,index=3}}}},
            [5]={reward={p={{p4001=200,index=1},{p4916=5,index=3},{p19=10,index=2}}}},
            [6]={reward={p={{p4631=50,index=1},{p4630=1,index=2},{p4201=50,index=3}}}},
            [7]={reward={p={{p4986=1,index=2},{p4984=1,index=3}},at={{p1=10,index=1}}}},
        },
        ---累计积分库；needScore所需积分数
        scoreReward={
            {needScore=300,reward={p={{p601=10,index=1},{p4001=100,index=2}}}},
            {needScore=1000,reward={p={{p601=30,index=1},{p4001=200,index=2}}}},
            {needScore=2000,reward={p={{p4986=2,index=1},{p606=10,index=2},{p4001=500,index=3}}}},
            {needScore=4000,reward={p={{p607=20,index=1},{p3302=30,index=2},{p4001=1500,index=3}}}},
            {needScore=5200,reward={p={{p230=1,index=1},{p608=10,index=2},{p4001=2000,index=3}}}},
        },
        dailytask={
            ----每天任务类型
            {"gb","ht","hu","hy"},
            {"gb","wp","wh","we"},
            {"gb","aj","au","av"},
            {"gb","cn","pe","pp"},
            {"gb","eb","st","sj"},
            {"gb","jb","pr","mb"},
            {"gb","ac","ai1","ai2"},
        },
        dailyTaskList={
            -----每日任务类型和奖励；gb充值，将领（ht装备探索次数;hu装备强化次数；hy深度研究次数）；超武（wp掠夺玩家次数；we神秘组织次数;wh宝石合成次数）;配件（au强化次数；ab补给线次数；aj精炼次数）
            -----打架（cn攻打关卡；pp攻打玩家；pe攻打资源）；eb远征次数；st训练军徽部队；sj军徽进阶次数；pr飞机融合；jb消费金币；mb军演次数;ac消耗ai部队经验道具数；ai1生产任意级别ai部队次数；ai2生产中级及中级以上ai部队的次数
            [1]={
                t1={
                    {needNum=40,score=200,reward={p={{p601=10,index=1},{p3203=5,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p601=5,index=1},{p3203=2,index=2}}}},
                    {needNum=10,score=50,reward={p={{p606=2,index=1},{p3204=2,index=2}}}},
                    {needNum=20,score=120,reward={p={{p607=2,index=1},{p3205=5,index=2}}}},
                },
                t3={
                    {needNum=1,score=30,reward={p={{p482=1,index=1},{p3203=2,index=2}}}},
                    {needNum=3,score=50,reward={p={{p483=1,index=1},{p3204=2,index=2}}}},
                    {needNum=5,score=120,reward={p={{p484=1,index=1},{p3205=5,index=2}}}},
                },
                t4={
                    {needNum=1,score=30,reward={p={{p485=1,index=1},{p933=1,index=2}}}},
                    {needNum=2,score=50,reward={p={{p486=1,index=1},{p933=3,index=2}}}},
                    {needNum=3,score=120,reward={p={{p487=1,index=1},{p481=1,index=2}}}},
                },
            },
            [2]={
                t1={
                    {needNum=40,score=200,reward={p={{p911=2,index=1},{p265=1,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p911=1,index=1},{p912=2,index=2}}}},
                    {needNum=15,score=50,reward={p={{p918=1,index=1},{p913=3,index=2}}}},
                    {needNum=30,score=120,reward={p={{p919=1,index=1},{p914=3,index=2}}}},
                },
                t3={
                    {needNum=1,score=30,reward={w={{c201=1,index=1},{p1=1000,index=2}}}},
                    {needNum=3,score=50,reward={w={{c200=2,index=1},{p1=2000,index=2}}}},
                    {needNum=5,score=120,reward={w={{c200=3,index=1},{c201=2,index=2}}}},
                },
                t4={
                    {needNum=20,score=30,reward={p={{p263=1,index=1},{p913=2,index=2}}}},
                    {needNum=60,score=50,reward={p={{p264=1,index=1},{p914=2,index=2}}}},
                    {needNum=120,score=120,reward={p={{p265=1,index=1},{p911=5,index=2}}}},
                },
            },
            [3]={
                t1={
                    {needNum=40,score=200,reward={e={{p10=1000,index=1}},p={{p19=20,index=2}}}},
                },
                t2={
                    {needNum=10,score=30,reward={e={{p8=500,index=1}},p={{p19=5,index=2}}}},
                    {needNum=20,score=50,reward={e={{p9=500,index=1},{p10=500,index=2}}}},
                    {needNum=50,score=120,reward={e={{p10=1000,index=1},{p9=1000,index=2}}}},
                },
                t3={
                    {needNum=2,score=30,reward={e={{p4=200,index=2}},p={{p96=1,index=1}}}},
                    {needNum=5,score=50,reward={e={{p6=2,index=1},{p4=500,index=2}}}},
                    {needNum=10,score=120,reward={e={{p6=3,index=2}},p={{p812=2,index=1}}}},
                },
                t4={
                    {needNum=1,score=30,reward={e={{p4=200,index=2}},p={{p417=2,index=1}}}},
                    {needNum=2,score=50,reward={e={{p5=3,index=1},{p4=500,index=2}}}},
                    {needNum=3,score=120,reward={p={{p815=2,index=1},{p417=5,index=2}}}},
                },
            },
            [4]={
                t1={
                    {needNum=40,score=200,reward={p={{p3302=2,index=1},{p20=10,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p3326=10,index=1},{p19=10,index=2}}}},
                    {needNum=10,score=50,reward={p={{p4949=1,index=1},{p19=20,index=2}}}},
                    {needNum=20,score=120,reward={p={{p3302=2,index=1},{p4949=2,index=2}}}},
                },
                t3={
                    {needNum=5,score=30,reward={o={{a10103=5,index=1}},p={{p51=1,index=2}}}},
                    {needNum=10,score=50,reward={o={{a10104=5,index=1}},p={{p51=1,index=2}}}},
                    {needNum=20,score=120,reward={o={{a10104=10,index=1},{a10103=10,index=2}}}},
                },
                t4={
                    {needNum=5,score=30,reward={p={{p3412=2,index=1},{p5=1,index=2}}}},
                    {needNum=10,score=50,reward={p={{p3413=2,index=1},{p13=1,index=2}}}},
                    {needNum=20,score=120,reward={p={{p435=2,index=1},{p423=2,index=2}}}},
                },
            },
            [5]={
                t1={
                    {needNum=40,score=200,reward={p={{p818=5,index=1},{p4001=200,index=2}}}},
                },
                t2={
                    {needNum=5,score=30,reward={p={{p601=5,index=1},{p19=5,index=2}}}},
                    {needNum=10,score=50,reward={p={{p819=5,index=1},{p19=10,index=2}}}},
                    {needNum=15,score=120,reward={p={{p818=10,index=1},{p601=10,index=2}}}},
                },
                t3={
                    {needNum=50,score=30,reward={p={{p4916=5,index=1},{p4001=50,index=2}}}},
                    {needNum=150,score=50,reward={p={{p4916=20,index=1},{p4001=100,index=2}}}},
                    {needNum=300,score=120,reward={p={{p4916=50,index=1},{p4001=200,index=2}}}},
                },
                t4={
                    {needNum=1,score=30,reward={p={{p4003=1,index=1},{p4001=100,index=2}}}},
                    {needNum=2,score=50,reward={p={{p4004=1,index=1},{p4001=200,index=2}}}},
                    {needNum=3,score=120,reward={p={{p4005=1,index=1},{p4001=500,index=2}}}},
                },
            },
            [6]={
                t1={
                    {needNum=40,score=200,reward={p={{p4631=50,index=1},{p4944=1,index=2}}}},
                },
                t2={
                    {needNum=50,score=30,reward={p={{p47=10,index=1},{p1365=5,index=2}}}},
                    {needNum=200,score=50,reward={p={{p4630=2,index=1},{p1365=10,index=2}}}},
                    {needNum=500,score=120,reward={p={{p4631=50,index=1},{p47=10,index=2}}}},
                },
                t3={
                    {needNum=1,score=30,reward={p={{p4203=1,index=1},{p4201=50,index=2}}}},
                    {needNum=2,score=50,reward={p={{p4204=1,index=1},{p4201=100,index=2}}}},
                    {needNum=3,score=120,reward={p={{p4202=1,index=1},{p4631=50,index=2}}}},
                },
                t4={
                    {needNum=5,score=30,reward={p={{p959=2,index=1},{p20=10,index=2}}}},
                    {needNum=10,score=50,reward={p={{p3506=2,index=1},{p19=10,index=2}}}},
                    {needNum=15,score=120,reward={p={{p3506=5,index=1},{p959=5,index=2}}}},
                },
            },
            [7]={
                t1={
                    {needNum=40,score=200,reward={p={{p988=10,index=2}},at={{p1=10,index=1}}}},
                },
                t2={
                    {needNum=20,score=30,reward={p={{p4964=2,index=2}},at={{p1=5,index=1}}}},
                    {needNum=50,score=50,reward={p={{p4965=2,index=2}},at={{p1=10,index=1}}}},
                    {needNum=80,score=120,reward={p={{p4965=5,index=2}},at={{p1=30,index=1}}}},
                },
                t3={
                    {needNum=2,quality=0,score=30,reward={p={{p877=20,index=1},{p19=5,index=2}}}},
                    {needNum=5,quality=0,score=50,reward={p={{p878=20,index=1},{p19=10,index=2}}}},
                    {needNum=10,quality=0,score=120,reward={p={{p1363=30,index=1},{p19=20,index=2}}}},
                },
                t4={
                    {needNum=1,quality={2,3},score=30,reward={p={{p983=10,index=2}},at={{p1=10,index=1}}}},
                    {needNum=3,quality={2,3},score=50,reward={p={{p4948=10,index=2}},at={{p1=20,index=1}}}},
                    {needNum=5,quality={2,3},score=120,reward={p={{p1363=10,index=2}},at={{p1=40,index=1}}}},
                },
            },
        },
        rankingReward={
            ---排行榜奖励
            {rank={1,1},reward={p={{p3303=5,index=1},{p4985=10,index=2}}}},
            {rank={2,2},reward={p={{p3303=4,index=1},{p4985=8,index=2}}}},
            {rank={3,5},reward={p={{p3303=3,index=1},{p4985=6,index=2}}}},
            {rank={6,10},reward={p={{p3303=2,index=1},{p4985=5,index=2}}}},
        },
    },
},

    zncf={
    [1]={
        type=1,
        _activeCfg=true,
        --开启等级
        openLv=30,
        --使用随机语句的系统
        desc={2,3,4,5,6,7},
        --超越百分比范围对应第1-3个随机描述语句
        descType={{0,49},{50,79},{80,100}},
        --每日登陆奖励reward 前端奖励；severreward 后端奖励
        dailyReward={
            {reward={p={{p5079=10,index=1}},am={{exp=10000,index=2}},w={{p1=10000,index=3}}}},
        },
        ----每个系统成就奖励对应系统标签  (1=成长成就，2=将领成就，3=配件成就，4=矩阵成就，5=超级武器成就，6=军徽成就，7=战机成就，8=装扮成就），type（对应系统下成就类型）；value1（参数1，值）,value2（参数2，配件--3=紫色及以上品质，4=橙色及以上品质，5=红色及以上品质；矩阵/飞机/军徽--4=紫色及以上品质，5=橙色及以上品质） reward 前端奖励；severreward 后端奖励
        rewardList={
            --1成长成就(type=1，创角总天数达到x天领奖；type=2，当前总战力达到x领奖）
            [1]={
                [1]={type=1,value1=100,reward={p={{p20=1,index=2}}}},
                [2]={type=1,value1=365,reward={p={{p3302=1,index=1}}}},
                [3]={type=1,value1=1000,reward={p={{p3303=1,index=1},{p3302=1,index=2}},u={{gems=100,index=3}}}},
                [4]={type=2,value1=10000000000,reward={p={{p264=1,index=1}}}},
                [5]={type=2,value1=100000000000,reward={p={{p265=2,index=1},{p19=15,index=2}}}},
            },
            --2将领(type=1，已授勋将领个数达到x领奖；type=2，将领装备总强度达到x领奖）
            [2]={
                [1]={type=1,value1=1,reward={p={{p601=1,index=1}}}},
                [2]={type=1,value1=10,reward={p={{p933=5,index=1}}}},
                [3]={type=1,value1=30,reward={p={{p933=5,index=1},{p866=8,index=2}}}},
                [4]={type=2,value1=10000,reward={f={{e1=500,index=1}}}},
                [5]={type=2,value1=20000,reward={p={{p608=1,index=1},{p4980=2,index=2}}}},
            },
            --3配件(type=1，装配x个y色及以上品质配件领奖；type=2，配件总强度达到x领奖）
            [3]={
                [1]={type=1,value1=1,value2=4,reward={p={{p881=1,index=1}}}},
                [2]={type=1,value1=5,value2=4,reward={e={{p6=5,index=1}}}},
                [3]={type=1,value1=1,value2=5,reward={e={{p5=2,index=1}},p={{p881=5,index=2}}}},
                [4]={type=2,value1=40000,reward={e={{p6=1,index=1}}}},
                [5]={type=2,value1=80000,reward={e={{p5=1,index=1},{p6=10,index=2}}}},
            },
            --4矩阵(type=1，装配x个y色及以上品质矩阵领奖；type=2，装配紫色及以上矩阵总等级达到x领奖，x级橙色=(50+x)级紫色）
            [4]={
                [1]={type=1,value1=6,value2=4,reward={am={{exp=1000,index=1}}}},
                [2]={type=1,value1=1,value2=5,reward={p={{p4942=1,index=1}},am={{exp=2000,index=2}}}},
                [3]={type=1,value1=2,value2=5,reward={u={{gems=100,index=1}},am={{exp=5000,index=2}}}},
                [4]={type=2,value1=360,reward={am={{exp=1000,index=1}}}},
                [5]={type=2,value1=720,reward={p={{p4934=1,index=1}},am={{exp=3000,index=2}}}},
            },
            --5超级武器(type=1，超级武器总等级达到x领奖；type=2，所有超级武器镶嵌晶体总等级达到x领奖）
            [5]={
                [1]={type=1,value1=60,reward={w={{p1=500,index=1}}}},
                [2]={type=1,value1=100,reward={p={{p911=2,index=1}}}},
                [3]={type=1,value1=140,reward={p={{p919=1,index=1}},w={{p1=2000,index=1}}}},
                [4]={type=2,value1=90,reward={p={{p913=1,index=1}}}},
                [5]={type=2,value1=180,reward={p={{p913=5,index=1}}}},
            },
            --6军徽(type=1，拥有x个y色及以上品质军徽领奖；type=2，军徽部队总强度达到x领奖）
            [6]={
                [1]={type=1,value1=1,value2=5,reward={p={{p4916=3,index=1}}}},
                [2]={type=1,value1=3,value2=5,reward={p={{p4001=500,index=1}}}},
                [3]={type=1,value1=6,value2=5,reward={u={{gems=100,index=1}},p={{p4001=500,index=2}}}},
                [4]={type=2,value1=4000,reward={p={{p4001=150,index=1}}}},
                [5]={type=2,value1=8000,reward={p={{p4001=1500,index=1}}}},
            },
            --7战机(type=1，装配x个y色及以上品质飞机技能领奖；type=2，战机总威力达到x领奖）
            [7]={
                [1]={type=1,value1=1,value2=4,reward={p={{p4631=3,index=1}}}},
                [2]={type=1,value1=1,value2=5,reward={p={{p4204=1,index=1}}}},
                [3]={type=1,value1=4,value2=5,reward={u={{gems=100,index=1}},p={{p4631=10,index=2}}}},
                [4]={type=2,value1=10000,reward={p={{p4201=10,index=1}}}},
                [5]={type=2,value1=25000,reward={p={{p4201=50,index=1},{p4631=20,index=2}}}},
            },
            --8装扮(type=1，拥有永久装扮类物品总个数：永久建筑装扮+永久坦克涂装+永久头像框）
            [8]={
                [1]={type=1,value1=5,reward={p={{p4945=1,index=1}}}},
                [2]={type=1,value1=10,reward={p={{p4969=5,index=1}}}},
                [3]={type=1,value1=20,reward={p={{p5073=1,index=1}},u={{gems=100,index=2}}}},
            },
        },
    },
}

}
