local zjdz={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --充值额度（第一个是单次，第二个是累积）
        rechargeNum={500,3000},
        --赠送抽奖券数量
        lotteryNum={1,5},
        --排行榜上榜限制
        rLimit=1200,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --充值钻石数的积分乘数
        scoreMul=10,
        serverreward={
            --积分道具
            itemNeed={"zjdz_a1",1},
            --排行榜奖励1
            rank1={props_p3303=12,props_p3302=50,props_p19=500},
            --排行榜奖励2
            rank2={props_p3303=9,props_p3302=30,props_p19=300},
            --排行榜奖励3
            rank3={props_p3303=6,props_p3302=15,props_p19=150},
            --排行榜奖励4
            rank4={props_p3303=3,props_p3302=10,props_p19=100},
            --排行榜奖励5
            rank5={props_p3302=10,props_p19=100},
            --抽奖奖池
            pool={
                {100},
                {50,50,50,50,30,30,30,30,20,30,20,10},
                {{"troops_a10074",1},{"troops_a20154",1},{"troops_a10044",1},{"troops_a10114",1},{"troops_a10043",2},{"troops_a10113",2},{"props_p19",8},{"props_p20",5},{"props_p3302",1},{"props_p1",1},{"troops_a10075",2},{"troops_a20155",2}},
            },
        },
        rewardTb={
            --积分道具
            itemNeed={"zjdz_a1",1},
            rank={
                --排行榜奖励1
                {p={{p3303=12,index=1},{p3302=50,index=2},{p19=500,index=3}}},
                
                --排行榜奖励2
                {p={{p3303=9,index=1},{p3302=30,index=2},{p19=300,index=3}}},
                
                --排行榜奖励3
                {p={{p3303=6,index=1},{p3302=15,index=2},{p19=150,index=3}}},
                
                --排行榜奖励4
                {p={{p3303=3,index=1},{p3302=10,index=2},{p19=100,index=3}}},
                
                --排行榜奖励5
                {p={{p3302=10,index=2},{p19=100,index=3}}},
                
            },
            showList={
                --普通奖励展示（固定8个）
                {o={{a10074=1,index=1},{a20154=1,index=2},{a10044=1,index=3},{a10114=1,index=4},{a10043=2,index=5},{a10113=2,index=6}},p={{p19=8,index=7},{p20=5,index=8}}},
                
                --大奖展示（最多4个）
                {o={{a10075=2,index=3},{a20155=2,index=4}},p={{p3302=1,index=1},{p1=1,index=2}}},
                
            },
        },
    },
    [2]={
        sortid=231,
        type=1,
        --充值额度（第一个是单次，第二个是累积）
        rechargeNum={500,3000},
        --赠送抽奖券数量
        lotteryNum={1,5},
        --排行榜上榜限制
        rLimit=3000,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --充值钻石数的积分乘数
        scoreMul=10,
        serverreward={
            --积分道具
            itemNeed={"zjdz_a1",1},
            --排行榜奖励1
            rank1={props_p4706=8,props_p5059=300},
            --排行榜奖励2
            rank2={props_p4706=4,props_p5059=200},
            --排行榜奖励3
            rank3={props_p4706=2,props_p5059=150},
            --排行榜奖励4
            rank4={props_p4706=1,props_p5059=100},
            --排行榜奖励5
            rank5={props_p4706=1,props_p5059=50},
            --抽奖奖池
            pool={
                {100},
                {20,20,20,50,50,50,50,50,10,10,10,10},
                {{"props_p4820",1},{"props_p4821",1},{"props_p278",1},{"props_p279",1},{"props_p275",1},{"props_p276",2},{"props_p277",10},{"props_p282",1},{"props_p969",20},{"props_p970",20},{"props_p971",20},{"props_p972",20}},
            },
        },
        rewardTb={
            --积分道具
            itemNeed={"zjdz_a1",1},
            rank={
                --排行榜奖励1
                {p={{p4706=8,index=1},{p5059=300,index=2}}},
                
                --排行榜奖励2
                {p={{p4706=4,index=1},{p5059=200,index=2}}},
                
                --排行榜奖励3
                {p={{p4706=2,index=1},{p5059=150,index=2}}},
                
                --排行榜奖励4
                {p={{p4706=1,index=1},{p5059=100,index=2}}},
                
                --排行榜奖励5
                {p={{p4706=1,index=1},{p5059=50,index=2}}},
                
            },
            showList={
                --普通奖励展示（固定8个）
                {p={{p4820=1,index=1},{p4821=1,index=2},{p278=1,index=3},{p279=1,index=4},{p275=1,index=5},{p276=2,index=6},{p277=10,index=7},{p282=1,index=8}}},
                
                --大奖展示（最多4个）
                {p={{p969=20,index=1},{p970=20,index=2},{p971=20,index=3},{p972=20,index=4}}},
                
            },
        },
    },
}

return zjdz
