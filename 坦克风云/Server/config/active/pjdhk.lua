local pjdhk={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --充值解锁商店需求
        rechargeNum=300,
        --体力消耗需求
        energyNeed={30,30},
        serverreward={
            --体力消耗获得道具
            getItem={{props_p4716=1},{props_p4717=1}},
            --商店
            shopList={
                [1]={serverreward={props_p4718=1},price=800,limit=1},
                [2]={serverreward={props_p813=1},price=640,limit=1},
                [3]={serverreward={props_p4719=1},price=1200,limit=1},
                [4]={serverreward={props_p816=1},price=1040,limit=1},
            },
        },
        rewardTb={
            --体力消耗获得道具
            getItem={p={{p4716=1,index=1},{p4717=1,index=2}}},
            --商店
            shopList={
                {reward={p={p4718=1}},index=1,showValue=2000,price=800,limit=1},
                {reward={p={p813=1}},index=1,showValue=1600,price=640,limit=1},
                {reward={p={p4719=1}},index=1,showValue=3000,price=1200,limit=1},
                {reward={p={p816=1}},index=1,showValue=2600,price=1040,limit=1},
                
            },
        },
    },
}

return pjdhk
