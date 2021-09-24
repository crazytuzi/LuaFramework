local hundredactive ={ -- 百服活动
    multiSelectType=true,
    [1]={
        type=1,
        sortId=317,
        version=0,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},price=现价,buyCnt=购买上限,needRes=资源解锁总量G}
            [1]={r={props_p1=1},price=120,buyCnt=5,needRes=10000000000},
            [2]={r={props_p49=1},price=336,buyCnt=5,needRes=20000000000},
            [3]={r={props_p1548=1},price=1600,buyCnt=3,needRes=30000000000},
            [4]={r={props_p1549=1},price=2000,buyCnt=3,needRes=40000000000},
            [5]={r={props_p1546=1},price=2400,buyCnt=20,needRes=60000000000},
            [6]={r={props_p1547=1},price=3600,buyCnt=20,needRes=80000000000},
            [7]={r={props_p1553=1},price=3420,buyCnt=1,needRes=100000000000},
            [8]={r={props_p1550=1},price=6900,buyCnt=3,needRes=150000000000},
            [9]={r={props_p1551=1},price=9000,buyCnt=3,needRes=200000000000},
            [10]={r={props_p1552=1},price=9000,buyCnt=3,needRes=300000000000},
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},nprice=原价,price=现价,dis=折扣,buyCnt=购买上限,needRes=资源解锁总量G}
            [1]={r={p={p1=1,index=1}},nprice=480,dis=0.25,price=120,buyCnt=5,needRes=10000000000},
            [2]={r={p={p49=1,index=2}},nprice=560,dis=0.6,price=336,buyCnt=5,needRes=20000000000},
            [3]={r={p={p1548=1,index=3}},nprice=2000,dis=0.8,price=1600,buyCnt=3,needRes=30000000000},
            [4]={r={p={p1549=1,index=4}},nprice=20000,dis=0.1,price=2000,buyCnt=3,needRes=40000000000},
            [5]={r={p={p1546=1,index=5}},nprice=24000,dis=0.1,price=2400,buyCnt=20,needRes=60000000000},
            [6]={r={p={p1547=1,index=6}},nprice=36000,dis=0.1,price=3600,buyCnt=20,needRes=80000000000},
            [7]={r={p={p1553=1,index=7}},nprice=3800,dis=0.9,price=3420,buyCnt=1,needRes=100000000000},
            [8]={r={p={p1550=1,index=8}},nprice=13800,dis=0.5,price=6900,buyCnt=3,needRes=150000000000},
            [9]={r={p={p1551=1,index=9}},nprice=45000,dis=0.2,price=9000,buyCnt=3,needRes=200000000000},
            [10]={r={p={p1552=1,index=10}},nprice=45000,dis=0.2,price=9000,buyCnt=3,needRes=300000000000},
        },
    },
    [2]={
        type=1,
        sortId=317,
        version=1,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},price=现价,buyCnt=购买上限,needRes=资源解锁总量G}
            [1]={r={props_p1554=1},price=160,buyCnt=20,needRes=3000000000},
            [2]={r={props_p1555=1},price=240,buyCnt=20,needRes=6000000000},
            [3]={r={props_p1=1},price=240,buyCnt=5,needRes=10000000000},
            [4]={r={props_p49=1},price=336,buyCnt=5,needRes=14000000000},
            [5]={r={props_p289=1},price=450,buyCnt=3,needRes=20000000000},
            [6]={r={props_p1561=1},price=684,buyCnt=1,needRes=26000000000},
            [7]={r={props_p1548=1},price=1600,buyCnt=3,needRes=30000000000},
            [8]={r={props_p1558=1},price=5000,buyCnt=3,needRes=50000000000},
            [9]={r={props_p1549=1},price=10000,buyCnt=3,needRes=70000000000},
            [10]={r={props_p1550=1},price=22500,buyCnt=3,needRes=100000000000},
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},nprice=原价,price=现价,dis=折扣,buyCnt=购买上限,needRes=资源解锁总量G}
            [1]={r={p={p1554=1,index=1}},nprice=320,dis=0.5,price=160,buyCnt=20,needRes=3000000000},
            [2]={r={p={p1555=1,index=2}},nprice=480,dis=0.5,price=240,buyCnt=20,needRes=6000000000},
            [3]={r={p={p1=1,index=3}},nprice=480,dis=0.5,price=240,buyCnt=5,needRes=10000000000},
            [4]={r={p={p49=1,index=4}},nprice=560,dis=0.6,price=336,buyCnt=5,needRes=14000000000},
            [5]={r={p={p289=1,index=9}},nprice=900,dis=0.5,price=450,buyCnt=3,needRes=20000000000},
            [6]={r={p={p1561=1,index=8}},nprice=760,dis=0.9,price=684,buyCnt=1,needRes=26000000000},
            [7]={r={p={p1548=1,index=6}},nprice=2000,dis=0.8,price=1600,buyCnt=3,needRes=30000000000},
            [8]={r={p={p1558=1,index=5}},nprice=10000,dis=0.5,price=5000,buyCnt=3,needRes=50000000000},
            [9]={r={p={p1549=1,index=7}},nprice=20000,dis=0.5,price=10000,buyCnt=3,needRes=70000000000},
            [10]={r={p={p1550=1,index=10}},nprice=45000,dis=0.5,price=22500,buyCnt=3,needRes=100000000000},
        },
    },
}
return hundredactive
