local yxclt={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        ----单抽消耗
        cost1=68,
        ----X连消耗(6,5,4,3,2,1)
        cost2={367,312,255,195,133,68},
        ----第二个按钮为X连抽
        costMul=6,
        ----中间乘数（前端展示用）
        giftMul=2,
        serverreward={
            --普通奖池
            pool1={
                {100},
                {10,10,20,20,20,20,20,20,30,30,30,30,30,30,5,20,50,100,100},
                {{"aweapon_af25",1},{"aweapon_af26",1},{"aweapon_af19",1},{"aweapon_af20",1},{"aweapon_af21",1},{"aweapon_af22",1},{"aweapon_af23",1},{"aweapon_af24",1},{"aweapon_af13",1},{"aweapon_af14",1},{"aweapon_af15",1},{"aweapon_af16",1},{"aweapon_af17",1},{"aweapon_af18",1},{"aweapon_exp",5000},{"aweapon_exp",2000},{"aweapon_exp",1000},{"aweapon_exp",200},{"aweapon_exp",100}},
            },
            --大奖奖池
            pool2={
                {100},
                {20,20,30,30,30,30,30,30},
                {{"aweapon_af25",2},{"aweapon_af26",2},{"aweapon_af19",2},{"aweapon_af20",2},{"aweapon_af21",2},{"aweapon_af22",2},{"aweapon_af23",2},{"aweapon_af24",2}},
            },
            --任务列表
            taskList={
                ----单次抽奖X次
                {num=5,type="m1",index=1,r={aweapon_af26=1,aweapon_exp=1000}},
                ----通关X次（单次抽奖/多次抽奖只要达到一轮的次数，即可完成一次）
                {num=3,type="m2",index=2,r={aweapon_af26=2,aweapon_exp=2000}},
                ----获得紫色碎片X个
                {num=15,type="m3",index=3,r={aweapon_af26=3,aweapon_exp=3000}},
                ----获得橙色碎片X个
                {num=35,type="m4",index=4,r={aweapon_af26=6,aweapon_exp=6000}},
                ----抽奖消耗钻石X
                {num=10000,type="m5",index=5,r={aweapon_af26=12,aweapon_exp=12000}},
            },
        },
        rewardTb={
            --普通奖池
            pool1={aw={{af25=1,index=1},{af26=1,index=2},{af19=1,index=3},{af20=1,index=4},{af21=1,index=5},{af22=1,index=6},{af23=1,index=7},{af24=1,index=8},{af13=1,index=9},{af14=1,index=10},{af15=1,index=11},{af16=1,index=12},{af17=1,index=13},{af18=1,index=14},{exp=5000,index=15},{exp=2000,index=16},{exp=1000,index=17},{exp=200,index=18},{exp=100,index=19}}},
            --大奖奖池
            pool2={aw={{af25=2,index=1},{af26=2,index=2},{af19=2,index=3},{af20=2,index=4},{af21=2,index=5},{af22=2,index=6},{af23=2,index=7},{af24=2,index=8}}},
            --任务列表
            taskList={
                ----单次抽奖X次
                {num=5,type="m1",index=1,r={aw={{af26=1,index=1},{exp=1000,index=2}}}},
                ----通关X次（单次抽奖/多次抽奖只要达到一轮的次数，即可完成一次）
                {num=3,type="m2",index=2,r={aw={{af26=2,index=1},{exp=2000,index=2}}}},
                ----获得紫色碎片X个
                {num=15,type="m3",index=3,r={aw={{af26=3,index=1},{exp=3000,index=2}}}},
                ----获得橙色碎片X个
                {num=35,type="m4",index=4,r={aw={{af26=6,index=1},{exp=6000,index=2}}}},
                ----抽奖消耗钻石X
                {num=10000,type="m5",index=5,r={aw={{af26=12,index=1},{exp=12000,index=2}}}},
            },
        },
    },
}

return yxclt