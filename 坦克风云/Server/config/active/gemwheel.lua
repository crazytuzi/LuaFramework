local gemwheel={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --额度限制（下限、上限）
        rcLimit={50,8000},
        --次数限制
        numLimit=3,
        serverreward={
            --防配置错误返利上限（因为有固定值，防止出错，大于此值的返利报错即可）
            rebateLimit=200,
            --浮动权重位置（相应位置的权重会加上玩家充值的钻数）如果没有浮动权重，则不需填写。
            floatWeight={1,2,3,4,5,6,7,8,9,10,11,12},
            --奖池
            pool={
                {100},
                {2000,6000,2,3000,6000,1,3000,3000,2,2000,6000,10},
                {{"gemwheel_a1",100},{"gemwheel_a1",20},{"userinfo_gems",1000},{"gemwheel_a1",50},{"gemwheel_a1",30},{"userinfo_gems",3000},{"gemwheel_a1",50},{"gemwheel_a1",60},{"userinfo_gems",1000},{"gemwheel_a1",80},{"gemwheel_a1",30},{"userinfo_gems",500}},
            },
            
        },
        rewardTb={
            --奖池
            pool={u={{gems=1000,index=3},{gems=3000,index=6},{gems=1000,index=9},{gems=500,index=12}},gemwheel={{gemwheel_a1=100,index=1},{gemwheel_a1=20,index=2},{gemwheel_a1=50,index=4},{gemwheel_a1=30,index=5},{gemwheel_a1=50,index=7},{gemwheel_a1=60,index=8},{gemwheel_a1=80,index=10},{gemwheel_a1=30,index=11}}},
            flash={3,1,2,3,2,3,3,3,2,3,2,1},
            announce={1,0,0,0,0,1,0,0,0,1,0,0},
            
        },
    },
    [2]={
        sortid=231,
        type=1,
        --额度限制（下限、上限）
        rcLimit={50,8000},
        --次数限制
        numLimit=3,
        serverreward={
            --防配置错误返利上限（因为有固定值，防止出错，大于此值的返利报错即可）
            rebateLimit=200,
            --浮动权重位置（相应位置的权重会加上玩家充值的钻数）如果没有浮动权重，则不需填写。
            floatWeight={},
            --奖池
            pool={
                {100},
                {500,1000,200,1000,1000,200,1000,1000,20,500,1000,200},
                {{"gemwheel_a1",100},{"gemwheel_a1",20},{"userinfo_gems",500},{"gemwheel_a1",50},{"gemwheel_a1",30},{"userinfo_gems",100},{"gemwheel_a1",50},{"gemwheel_a1",60},{"userinfo_gems",1000},{"gemwheel_a1",80},{"gemwheel_a1",30},{"userinfo_gems",300}},
            },
            
        },
        rewardTb={
            --奖池
            pool={u={{gems=500,index=3},{gems=100,index=6},{gems=1000,index=9},{gems=300,index=12}},gemwheel={{gemwheel_a1=100,index=1},{gemwheel_a1=20,index=2},{gemwheel_a1=50,index=4},{gemwheel_a1=30,index=5},{gemwheel_a1=50,index=7},{gemwheel_a1=60,index=8},{gemwheel_a1=80,index=10},{gemwheel_a1=30,index=11}}},
            flash={3,1,1,3,2,1,3,3,2,3,2,1},
            announce={1,0,0,0,0,0,0,0,0,1,0,0},
            
        },
    },
}

return gemwheel
