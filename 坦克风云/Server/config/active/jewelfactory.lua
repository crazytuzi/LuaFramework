local jewelfactory ={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=88,
        --五连价格
        cost2=396,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --排行榜上榜限制
        rLimit=350,
        --大奖相应颜色需求数量
        colorNeed={1,2,3,4,5,6},
        colorNum={1,1,1,1,1,1},
        colorRate={0.2,0.2,0.2,0.2,0.2,0.2},
        serverreward={
            --抽奖奖池
            pool1={
                {100},
                {2,2,1,2,1,2,5,5,3,5,3,5,20,20,15,20,15,20,50,50,37,50,37,50,200,200,175,200,175,200,800,800,650,800,650,800},
                {{"ajewel_j8",1},{"ajewel_j18",1},{"ajewel_j28",1},{"ajewel_j38",1},{"ajewel_j48",1},{"ajewel_j58",1},{"ajewel_j7",1},{"ajewel_j17",1},{"ajewel_j27",1},{"ajewel_j37",1},{"ajewel_j47",1},{"ajewel_j57",1},{"ajewel_j6",1},{"ajewel_j16",1},{"ajewel_j26",1},{"ajewel_j36",1},{"ajewel_j46",1},{"ajewel_j56",1},{"ajewel_j5",1},{"ajewel_j15",1},{"ajewel_j25",1},{"ajewel_j35",1},{"ajewel_j45",1},{"ajewel_j55",1},{"ajewel_j4",1},{"ajewel_j14",1},{"ajewel_j24",1},{"ajewel_j34",1},{"ajewel_j44",1},{"ajewel_j54",1},{"ajewel_j3",1},{"ajewel_j13",1},{"ajewel_j23",1},{"ajewel_j33",1},{"ajewel_j43",1},{"ajewel_j53",1}},
                score={20,20,20,20,20,20,10,10,10,10,10,10,5,5,5,5,5,5,3,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1},
            },
            
            --大奖奖池
            pool2={
                {100},
                {2,2,1,2,1,2,20,20,15,20,15,20,80,80,65,80,65,80},
                {{"ajewel_j9",1},{"ajewel_j19",1},{"ajewel_j29",1},{"ajewel_j39",1},{"ajewel_j49",1},{"ajewel_j59",1},{"ajewel_j8",1},{"ajewel_j18",1},{"ajewel_j28",1},{"ajewel_j38",1},{"ajewel_j48",1},{"ajewel_j58",1},{"ajewel_j7",1},{"ajewel_j17",1},{"ajewel_j27",1},{"ajewel_j37",1},{"ajewel_j47",1},{"ajewel_j57",1}},
                score={50,50,50,50,50,50,20,20,20,20,20,20,10,10,10,10,10,10},
            },
            
            --排行榜奖励1
            rank1={props_p4909=1,props_p4854=20},
            --排行榜奖励2
            rank2={props_p4879=2,props_p4854=10},
            --排行榜奖励3
            rank3={props_p4879=1,props_p4854=5},
            --排行榜奖励4
            rank4={props_p4878=2,props_p4854=3},
            --排行榜奖励5
            rank5={props_p4878=1,props_p4854=1},
        },
        rewardTb={
            --抽奖奖池
            pool1={aj={{j8=1,index=1},{j18=1,index=2},{j28=1,index=3},{j38=1,index=4},{j48=1,index=5},{j58=1,index=6},{j7=1,index=7},{j17=1,index=8},{j27=1,index=9},{j37=1,index=10},{j47=1,index=11},{j57=1,index=12},{j6=1,index=13},{j16=1,index=14},{j26=1,index=15},{j36=1,index=16},{j46=1,index=17},{j56=1,index=18},{j5=1,index=19},{j15=1,index=20},{j25=1,index=21},{j35=1,index=22},{j45=1,index=23},{j55=1,index=24},{j4=1,index=25},{j14=1,index=26},{j24=1,index=27},{j34=1,index=28},{j44=1,index=29},{j54=1,index=30},{j3=1,index=31},{j13=1,index=32},{j23=1,index=33},{j33=1,index=34},{j43=1,index=35},{j53=1,index=36}}},
            
            --大奖奖池
            pool2={aj={{j9=1,index=1},{j19=1,index=2},{j29=1,index=3},{j39=1,index=4},{j49=1,index=5},{j59=1,index=6},{j8=1,index=7},{j18=1,index=8},{j28=1,index=9},{j38=1,index=10},{j48=1,index=11},{j58=1,index=12},{j7=1,index=13},{j17=1,index=14},{j27=1,index=15},{j37=1,index=16},{j47=1,index=17},{j57=1,index=18}}},
            
            rank={
                --排行榜奖励1
                {p={{p4909=1,index=1},{p4854=20,index=2}}},
                
                --排行榜奖励2
                {p={{p4879=2,index=1},{p4854=10,index=2}}},
                
                --排行榜奖励3
                {p={{p4879=1,index=1},{p4854=5,index=2}}},
                
                --排行榜奖励4
                {p={{p4878=2,index=1},{p4854=3,index=2}}},
                
                --排行榜奖励5
                {p={{p4878=1,index=1},{p4854=1,index=2}}},
                
            },
        },
    },
    [2]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=88,
        --五连价格
        cost2=396,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --排行榜上榜限制
        rLimit=450,
        --大奖相应颜色需求数量
        colorNeed={1,2,3,4,5,6},
        colorNum={1,1,1,1,1,1},
        colorRate={0.35,0.35,0.35,0.35,0.35,0.35},
        serverreward={
            --抽奖奖池
            pool1={
                {100},
                {2,2,1,2,1,2,5,5,3,5,3,5,20,20,15,20,15,20,50,50,37,50,37,50,300,300,225,300,225,300,650,650,500,650,500,650},
                {{"ajewel_j8",1},{"ajewel_j18",1},{"ajewel_j28",1},{"ajewel_j38",1},{"ajewel_j48",1},{"ajewel_j58",1},{"ajewel_j7",1},{"ajewel_j17",1},{"ajewel_j27",1},{"ajewel_j37",1},{"ajewel_j47",1},{"ajewel_j57",1},{"ajewel_j6",1},{"ajewel_j16",1},{"ajewel_j26",1},{"ajewel_j36",1},{"ajewel_j46",1},{"ajewel_j56",1},{"ajewel_j5",1},{"ajewel_j15",1},{"ajewel_j25",1},{"ajewel_j35",1},{"ajewel_j45",1},{"ajewel_j55",1},{"ajewel_j4",1},{"ajewel_j14",1},{"ajewel_j24",1},{"ajewel_j34",1},{"ajewel_j44",1},{"ajewel_j54",1},{"ajewel_j3",1},{"ajewel_j13",1},{"ajewel_j23",1},{"ajewel_j33",1},{"ajewel_j43",1},{"ajewel_j53",1}},
                score={20,20,20,20,20,20,10,10,10,10,10,10,5,5,5,5,5,5,3,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1},
            },
            
            --大奖奖池
            pool2={
                {100},
                {2,2,1,2,1,2,20,20,15,20,15,20,60,60,45,60,45,60},
                {{"ajewel_j9",1},{"ajewel_j19",1},{"ajewel_j29",1},{"ajewel_j39",1},{"ajewel_j49",1},{"ajewel_j59",1},{"ajewel_j8",1},{"ajewel_j18",1},{"ajewel_j28",1},{"ajewel_j38",1},{"ajewel_j48",1},{"ajewel_j58",1},{"ajewel_j7",1},{"ajewel_j17",1},{"ajewel_j27",1},{"ajewel_j37",1},{"ajewel_j47",1},{"ajewel_j57",1}},
                score={50,50,50,50,50,50,20,20,20,20,20,20,10,10,10,10,10,10},
            },
            
            --排行榜奖励1
            rank1={props_p4909=1,props_p4854=20},
            --排行榜奖励2
            rank2={props_p4879=2,props_p4854=10},
            --排行榜奖励3
            rank3={props_p4879=1,props_p4854=5},
            --排行榜奖励4
            rank4={props_p4878=2,props_p4854=3},
            --排行榜奖励5
            rank5={props_p4878=1,props_p4854=1},
        },
        rewardTb={
            --抽奖奖池
            pool1={aj={{j8=1,index=1},{j18=1,index=2},{j28=1,index=3},{j38=1,index=4},{j48=1,index=5},{j58=1,index=6},{j7=1,index=7},{j17=1,index=8},{j27=1,index=9},{j37=1,index=10},{j47=1,index=11},{j57=1,index=12},{j6=1,index=13},{j16=1,index=14},{j26=1,index=15},{j36=1,index=16},{j46=1,index=17},{j56=1,index=18},{j5=1,index=19},{j15=1,index=20},{j25=1,index=21},{j35=1,index=22},{j45=1,index=23},{j55=1,index=24},{j4=1,index=25},{j14=1,index=26},{j24=1,index=27},{j34=1,index=28},{j44=1,index=29},{j54=1,index=30},{j3=1,index=31},{j13=1,index=32},{j23=1,index=33},{j33=1,index=34},{j43=1,index=35},{j53=1,index=36}}},
            
            --大奖奖池
            pool2={aj={{j9=1,index=1},{j19=1,index=2},{j29=1,index=3},{j39=1,index=4},{j49=1,index=5},{j59=1,index=6},{j8=1,index=7},{j18=1,index=8},{j28=1,index=9},{j38=1,index=10},{j48=1,index=11},{j58=1,index=12},{j7=1,index=13},{j17=1,index=14},{j27=1,index=15},{j37=1,index=16},{j47=1,index=17},{j57=1,index=18}}},
            
            rank={
                --排行榜奖励1
                {p={{p4909=1,index=1},{p4854=20,index=2}}},
                
                --排行榜奖励2
                {p={{p4879=2,index=1},{p4854=10,index=2}}},
                
                --排行榜奖励3
                {p={{p4879=1,index=1},{p4854=5,index=2}}},
                
                --排行榜奖励4
                {p={{p4878=2,index=1},{p4854=3,index=2}}},
                
                --排行榜奖励5
                {p={{p4878=1,index=1},{p4854=1,index=2}}},
                
            },
        },
    },
    [3]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=88,
        --五连价格
        cost2=396,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --排行榜上榜限制
        rLimit=600,
        --大奖相应颜色需求数量
        colorNeed={1,2,3,4,5,6},
        colorNum={1,1,1,1,1,1},
        colorRate={1,1,1,1,1,1},
        serverreward={
            --抽奖奖池
            pool1={
                {100},
                {2,2,1,2,1,2,5,5,3,5,3,5,20,20,15,20,15,20,50,50,37,50,37,50,300,300,225,300,225,300,600,600,450,600,450,600},
                {{"ajewel_j8",1},{"ajewel_j18",1},{"ajewel_j28",1},{"ajewel_j38",1},{"ajewel_j48",1},{"ajewel_j58",1},{"ajewel_j7",1},{"ajewel_j17",1},{"ajewel_j27",1},{"ajewel_j37",1},{"ajewel_j47",1},{"ajewel_j57",1},{"ajewel_j6",1},{"ajewel_j16",1},{"ajewel_j26",1},{"ajewel_j36",1},{"ajewel_j46",1},{"ajewel_j56",1},{"ajewel_j5",1},{"ajewel_j15",1},{"ajewel_j25",1},{"ajewel_j35",1},{"ajewel_j45",1},{"ajewel_j55",1},{"ajewel_j4",1},{"ajewel_j14",1},{"ajewel_j24",1},{"ajewel_j34",1},{"ajewel_j44",1},{"ajewel_j54",1},{"ajewel_j3",1},{"ajewel_j13",1},{"ajewel_j23",1},{"ajewel_j33",1},{"ajewel_j43",1},{"ajewel_j53",1}},
                score={20,20,20,20,20,20,10,10,10,10,10,10,5,5,5,5,5,5,3,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1},
            },
            
            --大奖奖池
            pool2={
                {100},
                {2,2,1,2,1,2,20,20,15,20,15,20,50,50,40,50,40,50},
                {{"ajewel_j9",1},{"ajewel_j19",1},{"ajewel_j29",1},{"ajewel_j39",1},{"ajewel_j49",1},{"ajewel_j59",1},{"ajewel_j8",1},{"ajewel_j18",1},{"ajewel_j28",1},{"ajewel_j38",1},{"ajewel_j48",1},{"ajewel_j58",1},{"ajewel_j7",1},{"ajewel_j17",1},{"ajewel_j27",1},{"ajewel_j37",1},{"ajewel_j47",1},{"ajewel_j57",1}},
                score={50,50,50,50,50,50,20,20,20,20,20,20,10,10,10,10,10,10},
            },
            
            --排行榜奖励1
            rank1={props_p4909=1,props_p4854=20},
            --排行榜奖励2
            rank2={props_p4879=2,props_p4854=10},
            --排行榜奖励3
            rank3={props_p4879=1,props_p4854=5},
            --排行榜奖励4
            rank4={props_p4878=2,props_p4854=3},
            --排行榜奖励5
            rank5={props_p4878=1,props_p4854=1},
        },
        rewardTb={
            --抽奖奖池
            pool1={aj={{j8=1,index=1},{j18=1,index=2},{j28=1,index=3},{j38=1,index=4},{j48=1,index=5},{j58=1,index=6},{j7=1,index=7},{j17=1,index=8},{j27=1,index=9},{j37=1,index=10},{j47=1,index=11},{j57=1,index=12},{j6=1,index=13},{j16=1,index=14},{j26=1,index=15},{j36=1,index=16},{j46=1,index=17},{j56=1,index=18},{j5=1,index=19},{j15=1,index=20},{j25=1,index=21},{j35=1,index=22},{j45=1,index=23},{j55=1,index=24},{j4=1,index=25},{j14=1,index=26},{j24=1,index=27},{j34=1,index=28},{j44=1,index=29},{j54=1,index=30},{j3=1,index=31},{j13=1,index=32},{j23=1,index=33},{j33=1,index=34},{j43=1,index=35},{j53=1,index=36}}},
            
            --大奖奖池
            pool2={aj={{j9=1,index=1},{j19=1,index=2},{j29=1,index=3},{j39=1,index=4},{j49=1,index=5},{j59=1,index=6},{j8=1,index=7},{j18=1,index=8},{j28=1,index=9},{j38=1,index=10},{j48=1,index=11},{j58=1,index=12},{j7=1,index=13},{j17=1,index=14},{j27=1,index=15},{j37=1,index=16},{j47=1,index=17},{j57=1,index=18}}},
            
            rank={
                --排行榜奖励1
                {p={{p4909=1,index=1},{p4854=20,index=2}}},
                
                --排行榜奖励2
                {p={{p4879=2,index=1},{p4854=10,index=2}}},
                
                --排行榜奖励3
                {p={{p4879=1,index=1},{p4854=5,index=2}}},
                
                --排行榜奖励4
                {p={{p4878=2,index=1},{p4854=3,index=2}}},
                
                --排行榜奖励5
                {p={{p4878=1,index=1},{p4854=1,index=2}}},
                
            },
        },
    },
}

return jewelfactory 
