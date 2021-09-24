local flyskill={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        ----单抽消耗
        cost1=68,
        ----十连消耗
        cost2=640,
        ----彩灯数量
        lightNum=8,
        serverreward={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            ----第N个彩灯点亮概率
            lightRate={0.2,0.08,0.05,0.03,0.01,0.01,0.005,0.005},
            ----每次失败增加概率
            rateAdd=0.001,
            --普通奖池
            pool1={
                {100},
                {10,20,50,100,300,100,100,100,100,50,50,50,50,100,100,1},
                {{"flyskill_a1",12},{"flyskill_a1",8},{"flyskill_a1",6},{"flyskill_a1",3},{"flyskill_a1",1},{"plane_s802",1},{"plane_s902",1},{"plane_s2402",1},{"plane_s2502",1},{"plane_s201",1},{"plane_s301",1},{"plane_s1601",1},{"plane_s1701",1},{"props_p4201",1},{"props_p4203",1},{"props_p4204",1}},
            },
            --大奖奖池
            pool2={
                {100},
                {30},
                {{"props_p4925",1}},
            },
            --商店
            shopList={
                [1]={serverreward={props_p4202=1},price=120,limit=10},
                [2]={serverreward={props_p4204=1},price=18,limit=30},
                [3]={serverreward={props_p4205=1},price=80,limit=6},
                [4]={serverreward={props_p4206=1},price=160,limit=2},
            },
        },
        rewardTb={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            --普通奖池
            pool1={p={{p4201=1,index=14},{p4203=1,index=15},{p4204=1,index=16}},flyskill={{flyskill_a1=12,index=1},{flyskill_a1=8,index=2},{flyskill_a1=6,index=3},{flyskill_a1=3,index=4},{flyskill_a1=1,index=5}},pl={{s802=1,index=6},{s902=1,index=7},{s2402=1,index=8},{s2502=1,index=9},{s201=1,index=10},{s301=1,index=11},{s1601=1,index=12},{s1701=1,index=13}}},
            
            --大奖奖池
            pool2={p={{p4925=1,index=1}}},
            
            --商店
            shopList={
                {reward={p={p4202=1}},index=1,price=120,limit=10},
                {reward={p={p4204=1}},index=2,price=18,limit=30},
                {reward={p={p4205=1}},index=3,price=80,limit=6},
                {reward={p={p4206=1}},index=4,price=160,limit=2},
                
            },
        },
    },
    [2]={
        sortid=231,
        type=1,
        ----单抽消耗
        cost1=68,
        ----十连消耗
        cost2=640,
        ----彩灯数量
        lightNum=8,
        serverreward={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            ----第N个彩灯点亮概率
            lightRate={0.2,0.06,0.04,0.02,0.01,0.005,0.002,0.001},
            ----每次失败增加概率
            rateAdd=0.001,
            --普通奖池
            pool1={
                {100},
                {10,20,50,100,300,100,100,100,100,50,50,50,50,100,100,1},
                {{"flyskill_a1",12},{"flyskill_a1",8},{"flyskill_a1",6},{"flyskill_a1",3},{"flyskill_a1",1},{"plane_s802",1},{"plane_s902",1},{"plane_s2402",1},{"plane_s2502",1},{"plane_s201",1},{"plane_s301",1},{"plane_s1601",1},{"plane_s1701",1},{"props_p4201",1},{"props_p4203",1},{"props_p4204",1}},
            },
            --大奖奖池
            pool2={
                {100},
                {30},
                {{"plane_s2025",1}},
            },
            --商店
            shopList={
                [1]={serverreward={props_p4202=1},price=120,limit=10},
                [2]={serverreward={props_p4204=1},price=18,limit=30},
                [3]={serverreward={props_p4205=1},price=80,limit=6},
                [4]={serverreward={props_p4206=1},price=160,limit=2},
            },
        },
        rewardTb={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            --普通奖池
            pool1={p={{p4201=1,index=14},{p4203=1,index=15},{p4204=1,index=16}},flyskill={{flyskill_a1=12,index=1},{flyskill_a1=8,index=2},{flyskill_a1=6,index=3},{flyskill_a1=3,index=4},{flyskill_a1=1,index=5}},pl={{s802=1,index=6},{s902=1,index=7},{s2402=1,index=8},{s2502=1,index=9},{s201=1,index=10},{s301=1,index=11},{s1601=1,index=12},{s1701=1,index=13}}},
            
            --大奖奖池
            pool2={pl={{s2025=1,index=1}}},
            
            --商店
            shopList={
                {reward={p={p4202=1}},index=1,price=120,limit=10},
                {reward={p={p4204=1}},index=2,price=18,limit=30},
                {reward={p={p4205=1}},index=3,price=80,limit=6},
                {reward={p={p4206=1}},index=4,price=160,limit=2},
                
            },
        },
    },
    [3]={
        sortid=231,
        type=1,
        ----单抽消耗
        cost1=68,
        ----十连消耗
        cost2=640,
        ----彩灯数量
        lightNum=8,
        serverreward={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            ----第N个彩灯点亮概率
            lightRate={0.2,0.06,0.04,0.02,0.01,0.005,0.002,0.001},
            ----每次失败增加概率
            rateAdd=0.001,
            --普通奖池
            pool1={
                {100},
                {10,20,50,100,300,100,100,100,100,50,50,50,50,100,100,1},
                {{"flyskill_a1",12},{"flyskill_a1",8},{"flyskill_a1",6},{"flyskill_a1",3},{"flyskill_a1",1},{"plane_s802",1},{"plane_s902",1},{"plane_s2402",1},{"plane_s2502",1},{"plane_s201",1},{"plane_s301",1},{"plane_s1601",1},{"plane_s1701",1},{"props_p4201",1},{"props_p4203",1},{"props_p4204",1}},
            },
            --大奖奖池
            pool2={
                {100},
                {30},
                {{"plane_s2325",1}},
            },
            --商店
            shopList={
                [1]={serverreward={props_p4202=1},price=120,limit=10},
                [2]={serverreward={props_p4204=1},price=18,limit=30},
                [3]={serverreward={props_p4205=1},price=80,limit=6},
                [4]={serverreward={props_p4206=1},price=160,limit=2},
            },
        },
        rewardTb={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            --普通奖池
            pool1={p={{p4201=1,index=14},{p4203=1,index=15},{p4204=1,index=16}},flyskill={{flyskill_a1=12,index=1},{flyskill_a1=8,index=2},{flyskill_a1=6,index=3},{flyskill_a1=3,index=4},{flyskill_a1=1,index=5}},pl={{s802=1,index=6},{s902=1,index=7},{s2402=1,index=8},{s2502=1,index=9},{s201=1,index=10},{s301=1,index=11},{s1601=1,index=12},{s1701=1,index=13}}},
            
            --大奖奖池
            pool2={pl={{s2325=1,index=1}}},
            
            --商店
            shopList={
                {reward={p={p4202=1}},index=1,price=120,limit=10},
                {reward={p={p4204=1}},index=2,price=18,limit=30},
                {reward={p={p4205=1}},index=3,price=80,limit=6},
                {reward={p={p4206=1}},index=4,price=160,limit=2},
                
            },
        },
    },
    [4]={
        sortid=231,
        type=1,
        ----单抽消耗
        cost1=68,
        ----十连消耗
        cost2=640,
        ----彩灯数量
        lightNum=8,
        serverreward={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            ----第N个彩灯点亮概率
            lightRate={0.2,0.06,0.03,0.01,0.01,0.005,0.002,0.001},
            ----每次失败增加概率
            rateAdd=0.001,
            --普通奖池
            pool1={
                {100},
                {10,20,50,100,300,100,100,100,100,50,50,50,50,100,100,1},
                {{"flyskill_a1",12},{"flyskill_a1",8},{"flyskill_a1",6},{"flyskill_a1",3},{"flyskill_a1",1},{"plane_s802",1},{"plane_s902",1},{"plane_s2402",1},{"plane_s2502",1},{"plane_s201",1},{"plane_s301",1},{"plane_s1601",1},{"plane_s1701",1},{"props_p4201",1},{"props_p4203",1},{"props_p4204",1}},
            },
            --大奖奖池
            pool2={
                {100},
                {30},
                {{"props_p4928",1}},
            },
            --商店
            shopList={
                [1]={serverreward={props_p4202=1},price=120,limit=10},
                [2]={serverreward={props_p4204=1},price=18,limit=30},
                [3]={serverreward={props_p4205=1},price=80,limit=6},
                [4]={serverreward={props_p4206=1},price=160,limit=2},
            },
        },
        rewardTb={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            --普通奖池
            pool1={p={{p4201=1,index=14},{p4203=1,index=15},{p4204=1,index=16}},flyskill={{flyskill_a1=12,index=1},{flyskill_a1=8,index=2},{flyskill_a1=6,index=3},{flyskill_a1=3,index=4},{flyskill_a1=1,index=5}},pl={{s802=1,index=6},{s902=1,index=7},{s2402=1,index=8},{s2502=1,index=9},{s201=1,index=10},{s301=1,index=11},{s1601=1,index=12},{s1701=1,index=13}}},
            
            --大奖奖池
            pool2={p={{p4928=1,index=1}}},
            
            --商店
            shopList={
                {reward={p={p4202=1}},index=1,price=120,limit=10},
                {reward={p={p4204=1}},index=2,price=18,limit=30},
                {reward={p={p4205=1}},index=3,price=80,limit=6},
                {reward={p={p4206=1}},index=4,price=160,limit=2},
                
            },
        },
    },
    [5]={
        sortid=231,
        type=1,
        ----单抽消耗
        cost1=68,
        ----十连消耗
        cost2=640,
        ----彩灯数量
        lightNum=8,
        serverreward={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            ----第N个彩灯点亮概率
            lightRate={0.2,0.06,0.03,0.01,0.01,0.005,0.002,0.001},
            ----每次失败增加概率
            rateAdd=0.001,
            --普通奖池
            pool1={
                {100},
                {10,20,50,100,300,100,100,100,100,50,50,50,50,100,100,1},
                {{"flyskill_a1",12},{"flyskill_a1",8},{"flyskill_a1",6},{"flyskill_a1",3},{"flyskill_a1",1},{"plane_s802",1},{"plane_s902",1},{"plane_s2402",1},{"plane_s2502",1},{"plane_s201",1},{"plane_s301",1},{"plane_s1601",1},{"plane_s1701",1},{"props_p4201",1},{"props_p4203",1},{"props_p4204",1}},
            },
            --大奖奖池
            pool2={
                {100},
                {30},
                {{"plane_s3725",1}},
            },
            --商店
            shopList={
                [1]={serverreward={props_p4202=1},price=120,limit=10},
                [2]={serverreward={props_p4204=1},price=18,limit=30},
                [3]={serverreward={props_p4205=1},price=80,limit=6},
                [4]={serverreward={props_p4206=1},price=160,limit=2},
            },
        },
        rewardTb={
            ----兑换道具
            itemNeed={"flyskill_a1"},
            --普通奖池
            pool1={p={{p4201=1,index=14},{p4203=1,index=15},{p4204=1,index=16}},flyskill={{flyskill_a1=12,index=1},{flyskill_a1=8,index=2},{flyskill_a1=6,index=3},{flyskill_a1=3,index=4},{flyskill_a1=1,index=5}},pl={{s802=1,index=6},{s902=1,index=7},{s2402=1,index=8},{s2502=1,index=9},{s201=1,index=10},{s301=1,index=11},{s1601=1,index=12},{s1701=1,index=13}}},
            
            --大奖奖池
            pool2={pl={{s3725=1,index=1}}},
            
            --商店
            shopList={
                {reward={p={p4202=1}},index=1,price=120,limit=10},
                {reward={p={p4204=1}},index=2,price=18,limit=30},
                {reward={p={p4205=1}},index=3,price=80,limit=6},
                {reward={p={p4206=1}},index=4,price=160,limit=2},
                
            },
        },
    },
}

return flyskill
