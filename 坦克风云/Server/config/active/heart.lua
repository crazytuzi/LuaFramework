local heart ={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=38,
        --五连价格
        cost2=180,
        --总格子数
        cellCount=16,
        --大奖可领次数
        rewardLimit=20,
        --普通翻牌数
        normal=1,
        --暴击概率
        critRate=0.1,
        --暴击额外翻牌数
        critExtra=1,
        serverreward={
            --普通奖池
            pool1={
                {100},
                {10,10,10,10,10,5},
                {{"props_p275",1},{"props_p276",2},{"props_p277",10},{"props_p282",1},{"accessory_p6",2},{"props_p36",1}},
            },
            
            --大奖奖池
            pool2={
                {100},
                {10,10,15,15},
                {{"troops_a10083",6},{"troops_a10074",6},{"troops_a10064",6},{"troops_a10114",6}},
            },
            
        },
        rewardTb={
            pool={
                --普通奖池
                {e={{p6=2}},p={{p275=1},{p276=2},{p277=10},{p282=1},{p36=1}}},
                --大奖奖池
                {o={{a10083=6},{a10074=6},{a10064=6},{a10114=6}}},
            },
        },
    },
}

return heart 
