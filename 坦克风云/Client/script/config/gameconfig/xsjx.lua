local xsjxCfg={
    multiSelectType = true,
    sortid=231,
    type=1,
    --开启等级限制
    levelLimit=10,
    --档位需求
    rechargeNeed={20000,50000,100000,200000},
    --档位区分
    rechargeCut={320,960,1920,3420},
    --档位权重
    rechargeRate={50,200,1000,5000},
    --无充值判定时间区间
    recallTime={{5,11},{5,10},{5,9},{4,8}},
    --未购买判定时间区间（充值行为将清除此判定记录）
    reBuyTime={{3,6},{3,6},{3,5},{3,5}},
    rewardTb={
        --礼包列表（recharge：充值额度。price：礼包显示价值。index：编号。Color：对应道具的颜色，1-白，2-绿，3-蓝，4-紫，5-橙。reward、serverreward：奖励内容）
        giftList={
            {
                {recharge=320,color={4,2},price=700,index=1,reward={p={{p4919=3,index=1},{p917=4,index=2}}}},
                {recharge=320,color={4,2},price=700,index=2,reward={p={{p4920=3,index=1},{p917=4,index=2}}}},
                {recharge=320,color={4,3},price=1100,index=3,reward={p={{p3345=1,index=1}},u={{gold=300000,index=2}}}},
                {recharge=320,color={3,2,2},price=700,index=4,reward={f={{e1=3000,index=1},{e3=1500,index=2},{e2=2000,index=3}}}},
                {recharge=320,color={3,2},price=600,index=5,reward={p={{p933=10,index=1},{p4928=5,index=2}}}},
                {recharge=320,color={4,1},price=500,index=6,reward={p={{p918=2,index=1},{p917=5,index=2}}}},
                {recharge=320,color={5},price=600,index=7,reward={am={{exp=12000,index=1}}}},
                {recharge=320,color={3,2},price=700,index=8,reward={r={{r4=200,index=1},{r5=400,index=2}}}},
                {recharge=320,color={3,3},price=600,index=9,reward={e={{p1=10,index=1},{p2=10,index=2}}}},
                {recharge=320,color={2,2},price=800,index=10,reward={e={{p3=100,index=1},{p4=5000,index=2}}}},
            },
            {
                {recharge=960,color={5,4,3},price=1300,index=101,reward={p={{p4214=5,index=1},{p959=15,index=2},{p3506=10,index=3}}}},
                {recharge=960,color={5,5},price=2100,index=102,reward={p={{p4215=5,index=1},{p960=20,index=2}}}},
                {recharge=960,color={5,3},price=3500,index=103,reward={p={{p4216=5,index=1},{p448=30,index=2}}}},
                {recharge=960,color={4,3},price=2000,index=104,reward={p={{p4919=5,index=1},{p918=10,index=2}}}},
                {recharge=960,color={4,3},price=2000,index=105,reward={p={{p4920=5,index=1},{p918=10,index=2}}}},
                {recharge=960,color={5,3},price=2200,index=106,reward={p={{p4921=5,index=1},{p918=10,index=2}}}},
                {recharge=960,color={5,3},price=2200,index=107,reward={p={{p4922=5,index=1},{p918=10,index=2}}}},
                {recharge=960,color={5,3},price=2400,index=108,reward={p={{p4923=3,index=1},{p918=10,index=2}}}},
                {recharge=960,color={4,2},price=1600,index=109,reward={p={{p3346=1,index=1},{p279=10,index=2}}}},
                {recharge=960,color={4,2},price=1800,index=110,reward={p={{p4820=5,index=1},{p279=40,index=2}}}},
                {recharge=960,color={4,2},price=2100,index=111,reward={p={{p672=20,index=1},{p279=40,index=2}}}},
                {recharge=960,color={4,3},price=4600,index=112,reward={p={{p4519=1,index=1}},am={{exp=2000,index=2}}}},
                {recharge=960,color={4,3},price=4600,index=113,reward={p={{p4520=1,index=1}},am={{exp=2000,index=2}}}},
                {recharge=960,color={4,3},price=4600,index=114,reward={p={{p4521=1,index=1}},am={{exp=2000,index=2}}}},
                {recharge=960,color={4,3},price=4600,index=115,reward={p={{p4524=1,index=1}},am={{exp=2000,index=2}}}},
                {recharge=960,color={4,3},price=1800,index=116,reward={f={{e1=8000,index=1}},p={{p4928=20,index=2}}}},
                {recharge=960,color={3,3},price=1900,index=117,reward={p={{p933=30,index=1},{p4928=20,index=2}}}},
                {recharge=960,color={4,4},price=1900,index=118,reward={p={{p920=1,index=1},{p919=2,index=2}}}},
                {recharge=960,color={5},price=2000,index=119,reward={am={{exp=40000,index=1}}}},
                {recharge=960,color={5,3},price=1800,index=120,reward={r={{r6=100,index=1},{r2=3000,index=2}}}},
            },
            {
                {recharge=1920,color={5,4,3},price=2800,index=201,reward={p={{p4217=10,index=1},{p959=30,index=2},{p3506=25,index=3}}}},
                {recharge=1920,color={5,5},price=4800,index=202,reward={p={{p4218=10,index=1},{p960=50,index=2}}}},
                {recharge=1920,color={4,4},price=3700,index=203,reward={p={{p4919=15,index=1},{p919=4,index=2}}}},
                {recharge=1920,color={4,4},price=3700,index=204,reward={p={{p4920=15,index=1},{p919=4,index=2}}}},
                {recharge=1920,color={5,4},price=4200,index=205,reward={p={{p4921=12,index=1},{p919=5,index=2}}}},
                {recharge=1920,color={5,4},price=4200,index=206,reward={p={{p4922=12,index=1},{p919=5,index=2}}}},
                {recharge=1920,color={5,4},price=5000,index=207,reward={p={{p4923=9,index=1},{p919=4,index=2}}}},
                {recharge=1920,color={5,4},price=5000,index=208,reward={p={{p4924=9,index=1},{p919=4,index=2}}}},
                {recharge=1920,color={4,2},price=3500,index=209,reward={p={{p4001=800,index=2}},se={{e101=1,index=1}}}},
                {recharge=1920,color={4,2},price=3500,index=210,reward={p={{p4001=800,index=2}},se={{e111=1,index=1}}}},
                {recharge=1920,color={4},price=10000,index=211,reward={se={{e801=1,index=1}}}},
                {recharge=1920,color={4},price=10000,index=212,reward={se={{e812=1,index=1}}}},
                {recharge=1920,color={4},price=10000,index=213,reward={se={{e822=1,index=1}}}},
                {recharge=1920,color={4,2,2},price=3400,index=214,reward={e={{p4=2000,index=3}},p={{p4821=10,index=1},{p672=10,index=2}}}},
                {recharge=1920,color={4,2,2},price=3000,index=215,reward={e={{p4=2000,index=3}},p={{p4822=10,index=1},{p672=10,index=2}}}},
                {recharge=1920,color={4,2,2},price=4600,index=216,reward={e={{p11=1,index=1},{p4=2000,index=3}},p={{p672=10,index=2}}}},
                {recharge=1920,color={2,2,2},price=2500,index=217,reward={e={{p4=10000,index=3}},p={{p279=20,index=1},{p672=20,index=2}}}},
                {recharge=1920,color={4,5},price=3500,index=218,reward={p={{p4521=1,index=1}},am={{exp=10000,index=2}}}},
                {recharge=1920,color={4,5},price=3500,index=219,reward={p={{p4524=1,index=1}},am={{exp=10000,index=2}}}},
                {recharge=1920,color={5,3,3,4},price=3800,index=220,reward={f={{e1=10000,index=1},{e3=9000,index=2},{e2=9000,index=3}},p={{p4929=10,index=4}}}},
                {recharge=1920,color={3,4},price=3300,index=221,reward={p={{p933=60,index=1},{p4929=15,index=2}}}},
                {recharge=1920,color={5,4},price=3500,index=222,reward={p={{p4930=1,index=1},{p4929=25,index=2}}}},
                {recharge=1920,color={5,4,3},price=3900,index=223,reward={p={{p920=3,index=1}},w={{c200=1,index=2},{c201=1,index=3}}}},
                {recharge=1920,color={5},price=5000,index=224,reward={am={{exp=100000,index=1}}}},
                {recharge=1920,color={5,3,3},price=3400,index=225,reward={r={{r6=150,index=1},{r4=600,index=2},{r5=600,index=3}}}},
            },
            {
                {recharge=3420,color={5,3},price=9000,index=301,reward={p={{p4214=40,index=1},{p448=50,index=2}}}},
                {recharge=3420,color={5,3},price=9000,index=302,reward={p={{p4215=40,index=1},{p448=50,index=2}}}},
                {recharge=3420,color={5,3},price=9000,index=303,reward={p={{p4216=40,index=1},{p448=50,index=2}}}},
                {recharge=3420,color={5,3},price=9000,index=304,reward={p={{p4217=40,index=1},{p448=50,index=2}}}},
                {recharge=3420,color={5,3},price=9000,index=305,reward={p={{p4218=40,index=1},{p448=50,index=2}}}},
                {recharge=3420,color={5,5,4,4},price=6700,index=306,reward={p={{p960=50,index=1},{p608=20,index=2},{p959=50,index=3},{p607=20,index=4}}}},
                {recharge=3420,color={5,5},price=9500,index=307,reward={p={{p4924=18,index=1},{p920=2,index=2}}}},
                {recharge=3420,color={5,5},price=9500,index=308,reward={p={{p4923=18,index=1},{p920=2,index=2}}}},
                {recharge=3420,color={5,5},price=9500,index=309,reward={p={{p4925=18,index=1},{p920=2,index=2}}}},
                {recharge=3420,color={5,5},price=9500,index=310,reward={p={{p4926=18,index=1},{p920=2,index=2}}}},
                {recharge=3420,color={4,5},price=5800,index=311,reward={p={{p4001=2000,index=1},{p4002=2,index=2}}}},
                {recharge=3420,color={4,5},price=6200,index=312,reward={p={{p4916=20,index=1},{p4002=3,index=2}}}},
                {recharge=3420,color={4,4,3,2},price=5200,index=313,reward={e={{p1=50,index=2},{p2=50,index=3},{p3=50,index=4}},p={{p4821=10,index=1}}}},
                {recharge=3420,color={4,4,3,2},price=4100,index=314,reward={e={{p1=30,index=2},{p2=30,index=3},{p3=30,index=4}},p={{p4822=10,index=1}}}},
                {recharge=3420,color={4,4,3,2},price=3900,index=315,reward={e={{p1=30,index=2},{p2=30,index=3},{p3=10,index=4}},p={{p4820=10,index=1}}}},
                {recharge=3420,color={4,4,3,2},price=4900,index=316,reward={e={{p1=30,index=2},{p2=30,index=3},{p3=10,index=4}},p={{p3346=2,index=1}}}},
                {recharge=3420,color={4,3,2,2},price=5300,index=317,reward={e={{p1=50,index=1},{p2=50,index=2},{p3=50,index=3},{p4=20000,index=4}}}},
                {recharge=3420,color={5,5},price=6500,index=318,reward={e={{p11=1,index=2}},p={{p4821=10,index=1}}}},
                {recharge=3420,color={4,5},price=6000,index=319,reward={p={{p4522=1,index=1}},am={{exp=60000,index=2}}}},
                {recharge=3420,color={4,5},price=6000,index=320,reward={p={{p4523=1,index=1}},am={{exp=60000,index=2}}}},
                {recharge=3420,color={5,4,3},price=6500,index=321,reward={f={{e1=20000,index=1}},p={{p4929=30,index=2},{p933=50,index=3}}}},
                {recharge=3420,color={5,5},price=6800,index=322,reward={p={{p4930=2,index=1},{p481=8,index=2}}}},
                {recharge=3420,color={5,4,3},price=22800,index=323,reward={p={{p922=1,index=1}},w={{c200=5,index=2},{c201=5,index=3}}}},
                {recharge=3420,color={5},price=7500,index=324,reward={am={{exp=150000,index=1}}}},
                {recharge=3420,color={5,3,3},price=4700,index=325,reward={r={{r6=300,index=1},{r4=800,index=2},{r5=800,index=3}}}},
            },
        },
    },
}

return xsjxCfg
