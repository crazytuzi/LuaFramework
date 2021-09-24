local bsmz={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=78,
        --十连价格
        cost2=750,
        --行列数（行影响判断，列影响最大额外奖池数）
        rowCount=3,
        columnCount=3,
        --奖池种类
        typeCount=6,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --排行榜上榜限制
        rLimit=300,
        --前三名额外奖励积分需求
        extraLimit=600,
        serverreward={
            --奖励随机(确定本次抽奖奖励个数，0->保底奖励，1->高级奖励*1,2->高级奖励*2……）
            rewardPool={
                {100},
                {82,16,1,1},
                {0,1,2,3},
            },
            
            --奖池随机（奖励个数确定后，高级奖励的类别按照本奖池权重确定，每个类别对应一个奖池，分别对应pool1、pool2……）
            rndPool={
                {100},
                {10,10,8,10,8,10},
                {1,2,3,4,5,6},
            },
            
            --保底奖池
            basePool={
                {100},
                {10,10,6,10,6,10},
                {{"ajewel_j5",1},{"ajewel_j15",1},{"ajewel_j25",1},{"ajewel_j35",1},{"ajewel_j45",1},{"ajewel_j55",1}},
            },
            
            --奖池1
            pool1_p={
                {100},
                {10},
                {{"ajewel_j7",1}},
                score={10},
            },
            
            --奖池2
            pool2_p={
                {100},
                {5},
                {{"ajewel_j17",1}},
                score={10},
            },
            
            --奖池3
            pool3_p={
                {100},
                {5},
                {{"ajewel_j27",1}},
                score={10},
            },
            
            --奖池4
            pool4_p={
                {100},
                {10},
                {{"ajewel_j37",1}},
                score={10},
            },
            
            --奖池5
            pool5_p={
                {100},
                {10},
                {{"ajewel_j47",1}},
                score={10},
            },
            
            --奖池6
            pool6_p={
                {100},
                {10},
                {{"ajewel_j57",1}},
                score={10},
            },
            
            --排行榜奖励1
            rank1={ajewel_j19=1,ajewel_j39=1,props_p4854=30},
            --排行榜奖励2
            rank2={ajewel_j19=1,props_p4854=20},
            --排行榜奖励3
            rank3={ajewel_j39=1,props_p4854=15},
            --排行榜奖励4
            rank4={ajewel_j18=1,props_p4854=10},
            --排行榜奖励5
            rank5={ajewel_j38=1,props_p4854=5},
            --排行榜额外奖励1
            exRank1={ajewel_j20=1,ajewel_j40=1},
            --排行榜额外奖励2
            exRank2={ajewel_j40=1},
            --排行榜额外奖励3
            exRank3={ajewel_j20=1},
        },
        rewardTb={
            --保底奖池
            basePool={aj={{j5=1},{j15=1},{j25=1},{j35=1},{j45=1},{j55=1}}},
            
            --前端展示
            pool={aj={{j7=1,index=1},{j17=1,index=2},{j27=1,index=3},{j37=1,index=4},{j47=1,index=5},{j57=1,index=6}}},
            rank={
                --排行榜奖励1
                {p={{p4854=30,index=3}},aj={{j19=1,index=1},{j39=1,index=2}}},
                
                --排行榜奖励2
                {p={{p4854=20,index=2}},aj={{j19=1,index=1}}},
                
                --排行榜奖励3
                {p={{p4854=15,index=2}},aj={{j39=1,index=1}}},
                
                --排行榜奖励4
                {p={{p4854=10,index=2}},aj={{j18=1,index=1}}},
                
                --排行榜奖励5
                {p={{p4854=5,index=3}},aj={{j38=1,index=2}}},
                
            },
            exRank={
                --排行榜额外奖励1
                {aj={{j20=1,index=1},{j40=1,index=2}}},
                
                --排行榜额外奖励2
                {aj={{j40=1,index=1}}},
                
                --排行榜额外奖励3
                {aj={{j20=1,index=1}}},
                
            },
        },
    },
}

return bsmz
