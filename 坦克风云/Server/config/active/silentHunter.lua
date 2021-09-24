local silentHunter={
    multiSelectType=true,
    [1]={
        sortid=205,
        type=1,
        -- 累计充值钻石
        accCharge ={
            --充值金额（钻石数）
            recharge=720,
            --领取次数限制
            limit=10,
            --奖励
            reward={reward={p={{p1292=1,index=1},{p30=3,index=2},{p13=1,index=3},{p19=2,index=4}}},
                flash={1,0,0,0},},
        },
        --限时商店
        limitSell={
            --原价
            price=1350,
            --售价
            cost=580,
            --限购次数
            buylimit=10,
            --商品
            goods={reward={o={{a10014=50,index=1}},r={{r1=1500,index=2},{r2=1500,index=3}}},
                flash={3,0,0},},
        },
        --任务列表
        taskList={
            --任务1
            --攻打X次补给线
            ab={num=5,index=1,reward={e={{p4=200,index=1},{p3=15,index=2}}}},
            --任务2
            --潜艇参战进行X次战斗（攻击矿点）
            ps={num=20,index=2,reward={o={{a10013=20,index=1},{a10014=5,index=2}}}},
            --任务3
            --使用钻石修理X次潜艇
            ms={num=20,index=3,reward={e={{p6=2,index=2}},o={{a10013=20,index=1}}}},
            --任务4
            --拥有X艘飞鱼级潜艇
            du={num=80,index=4,reward={e={{p4=600,index=1},{p6=5,index=2},{p5=1,index=3}}}},
            --任务5
            --升级X次常规潜艇相关异星科技
            rt={num=20,index=5,reward={e={{p1=2,index=1},{p2=5,index=2},{p3=20,index=3}}}},
            --任务6
            --进行X次潜艇配件的强化
            at={num=20,index=6,reward={p={{p19=3,index=2}},u={{gold=800000,index=1}}}},
        },
        taskFlashList={
            ab={0,0},
            ps={0,3},
            ms={0,0},
            du={0,0,2},
            rt={0,0,0},
            at={0,0},
        },
        serverreward={
            accCharge =
            {{"props_p1292",1},{"props_p30",3},{"props_p13",1},{"props_p19",2}},
            limitSell =
            {{"troops_a10014",50},{"alien_r1",1500},{"alien_r2",1500}},
            taskList ={
                --任务1
                --攻打X次补给线
                ab={{"accessory_p4",200},{"accessory_p3",15}},
                --任务2
                --潜艇参战进行X次战斗（攻击矿点）
                ps={{"troops_a10013",20},{"troops_a10014",5}},
                --任务3
                --使用钻石修理X次潜艇
                ms={{"troops_a10013",20},{"accessory_p6",2}},
                --任务4
                --拥有X艘飞鱼级潜艇
                du={{"accessory_p4",600},{"accessory_p6",5},{"accessory_p5",1}},
                --任务5
                --升级X次常规潜艇相关异星科技
                rt={{"accessory_p1",2},{"accessory_p2",5},{"accessory_p3",20}},
                --任务6
                --进行X次潜艇配件的强化
                at={{"userinfo_gold",800000},{"props_p19",3}},
            },
        },
    },
}

return silentHunter
