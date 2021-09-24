local unitepower={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --红包积分消耗
        scoreCost={100,500,1000},
        --红包总代金券量
        bagValue={100,500,1000},
        --发红包赠送代金券
        extraGet={10,50,100},
        --红包个数
        bagNum={10,10,10},
        --积分奖励需求
        scoreNeed1={1000,5000,10000,20000,30000,40000,50000},
        --商店解锁需求
        scoreNeed2={1000,10000,30000,50000},
        --商店代金券抵扣上限
        discount={0.3,0.4,0.5,0.6},
        serverreward={
            --奖励1
            gift1={props_p5055=1},
            --奖励2
            gift2={props_p5055=5},
            --奖励3
            gift3={props_p5055=10},
            --奖励4
            gift4={props_p5055=20},
            --奖励5
            gift5={props_p5055=30},
            --奖励6
            gift6={alien_r2=10000},
            --奖励7
            gift7={alien_r6=200},
            --任务（标识，参数，排序，限制次数，积分获得，奖励）
            taskList={
                --军团捐献X次
                {type="ad",num=5,index=1,limit=8,serverreward={props_p5055=1,unitepower_a1=30,unitepower_a2=30}},
                --军团充能X次
                {type="zh",num=1,index=2,limit=5,serverreward={props_p5055=1,unitepower_a1=30,unitepower_a2=30}},
                --采集X军团资源
                {type="jc",num=1000000,index=3,limit=10,serverreward={alien_r2=200,unitepower_a1=30,unitepower_a2=30}},
                --军团互助X次
                {type="hz",num=2,index=4,limit=10,serverreward={props_p5055=1,unitepower_a1=30,unitepower_a2=30}},
                --充值钻石
                {type="gb",num=300,index=5,limit=20,serverreward={alien_r6=20,unitepower_a1=50,unitepower_a2=50}},
            },
            --商店1
            shopList1={
                [1]={serverreward={alien_r2=2000},price=400,limit=200},
            },
            --商店2
            shopList2={
                [1]={serverreward={alien_r4=100},price=80,limit=200},
                [2]={serverreward={alien_r5=100},price=88,limit=200},
            },
            --商店3
            shopList3={
                [1]={serverreward={alien_r2=3000},price=600,limit=80},
                [2]={serverreward={alien_r6=50},price=400,limit=80},
            },
            --商店4
            shopList4={
                [1]={serverreward={alien_r2=5000},price=1000,limit=20},
                [2]={serverreward={alien_r6=100},price=800,limit=20},
            },
        },
        rewardTb={
            gift={
                --奖励1
                {p={{p5055=1,index=1}}},
                --奖励2
                {p={{p5055=5,index=1}}},
                --奖励3
                {p={{p5055=10,index=1}}},
                --奖励4
                {p={{p5055=20,index=1}}},
                --奖励5
                {p={{p5055=30,index=1}}},
                --奖励6
                {r={{r2=10000,index=1}}},
                --奖励7
                {r={{r6=200,index=1}}},
            },
            --任务（标识，参数，排序，限制次数，积分获得，奖励）
            taskList={
                --军团捐献X次
                {type="ad",num=5,index=1,limit=8,reward={p={{p5055=1,index=1}},unitepower={{unitepower_a1=30,index=2},{unitepower_a2=30,index=3}}}},
                --军团充能X次
                {type="zh",num=1,index=2,limit=5,reward={p={{p5055=1,index=1}},unitepower={{unitepower_a1=30,index=2},{unitepower_a2=30,index=3}}}},
                --采集X军团资源
                {type="jc",num=1000000,index=3,limit=10,reward={r={{r2=200,index=1}},unitepower={{unitepower_a1=30,index=2},{unitepower_a2=30,index=3}}}},
                --军团互助X次
                {type="hz",num=2,index=4,limit=10,reward={p={{p5055=1,index=1}},unitepower={{unitepower_a1=30,index=2},{unitepower_a2=30,index=3}}}},
                --充值钻石
                {type="gb",num=300,index=5,limit=20,reward={r={{r6=20,index=1}},unitepower={{unitepower_a1=50,index=2},{unitepower_a2=50,index=3}}}},
            },
            shopList={
                --商店1
                {
                    {reward={r={r2=2000}},index=1,price=400,yuanjia=500,limit=200},
                },
                --商店2
                {
                    {reward={r={r4=100}},index=1,price=80,yuanjia=100,limit=200},
                    {reward={r={r5=100}},index=2,price=88,yuanjia=110,limit=200},
                },
                --商店3
                {
                    {reward={r={r2=3000}},index=1,price=600,yuanjia=750,limit=80},
                    {reward={r={r6=50}},index=2,price=400,yuanjia=500,limit=80},
                },
                --商店4
                {
                    {reward={r={r2=5000}},index=1,price=1000,yuanjia=1250,limit=20},
                    {reward={r={r6=100}},index=2,price=800,yuanjia=1000,limit=20},
                },
            },
        },
    },
}

return unitepower
