local qxtw={
    multiSelectType=true,  --支持多版本
    [1]={
        _activeCfg=true,
        type=1,
        sortId=200,
        
        --突围1次
        cost1=58,
        --全速突围,5个坦克
        cost2=290,
        
        --兑换超级装备
        --get:可兑换的超级装备，第一个{}后台，第二个{}前台
        --need:超级装备所需道具，第一个{}后台，第二个{}前台
        exchange={get={{sequip_e131=1},{e131=1}},need={{p4101=20},{p={{p4101=20}}}}},
        
        --总共3条线路
        --maxPoint:每条线路总共有几个点
        --include:每条线路包含点的编号
        --random:线路上每个点的随机库类型
        map={
            [1]={maxPoint=4,include={1,2,4,8},random={1,2,3,4}},
            [2]={maxPoint=3,include={1,5,8},random={1,2,4}},
            [3]={maxPoint=5,include={1,3,6,7,8},random={1,1,2,3,4}},
        },
        
        --前台展示，对应四个奖池   绿、蓝、紫、橙
        reward={
            [1]={p={{p4003=1,index=1}}},
            [2]={p={{p4003=3,index=11}},se2={{e21=1,index=1},{e22=1,index=2},{e23=1,index=3},{e24=1,index=4},{e25=1,index=5},{e26=1,index=6},{e31=1,index=7},{e32=1,index=8},{e33=1,index=9},{e34=1,index=10}}},
            [3]={p={{p4004=1,index=11}},se2={{e41=1,index=1},{e42=1,index=2},{e43=1,index=3},{e44=1,index=4},{e45=1,index=5},{e51=1,index=6},{e61=1,index=7},{e71=1,index=8},{e81=1,index=9},{e91=1,index=10}}},
            [4]={p={{p4101=1,index=1}}},
        },
        
        serverreward={
            --随机出1,2,3,4,5的权重
            randomNum={26,56,11,6,1},
            --随机3条路线的权重
            randomRoad={29,10,61},
            
            --绿奖池
            pool1={
                {100},
                {50},
                {{"props_p4003",1}},
            },
            --蓝奖池
            pool2={
                {100},
                {94,94,94,94,94,94,94,94,94,94,60},
                {{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1},{"props_p4003",3}},
            },
            --紫奖池
            pool3={
                {100},
                {80,80,80,80,80,80,80,80,80,80,200},
                {{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1},{"props_p4004",1}},
            },
            --橙奖池
            pool4={
                {100},
                {1},
                {{"props_p4101",1}},
            },
        },
        
        --type:任务类型  1：抽取X次超级装备（稀土+金币）  2：突围X次  3：分解X次超级装备  4：进阶X次超级装备  5：升级X次超级装备
        --index:排序
        --needNum:完成条件
        dailyTask={
            {type=1,index=1,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=2,index=2,needNum=5,reward={p={{p4003=2,index=1},{p4001=30,index=2}}},serverreward={props_p4003=2,props_p4001=30}},
            {type=3,index=3,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=4,index=4,needNum=3,reward={p={{p4003=1,index=1},{p4001=30,index=2}}},serverreward={props_p4003=1,props_p4001=30}},
            {type=5,index=5,needNum=1,reward={p={{p4004=1,index=1},{p4001=50,index=2}}},serverreward={props_p4004=1,props_p4001=50}},
        },
    },
    [2]={
        _activeCfg=true,
        type=1,
        sortId=200,
        
        --突围1次
        cost1=58,
        --全速突围,5个坦克
        cost2=290,
        
        --兑换超级装备
        --get:可兑换的超级装备，第一个{}后台，第二个{}前台
        --need:超级装备所需道具，第一个{}后台，第二个{}前台
        exchange={get={{sequip_e112=1},{e112=1}},need={{p4102=20},{p={{p4102=20}}}}},
        
        --总共3条线路
        --maxPoint:每条线路总共有几个点
        --include:每条线路包含点的编号
        --random:线路上每个点的随机库类型
        map={
            [1]={maxPoint=4,include={1,2,4,8},random={1,2,3,4}},
            [2]={maxPoint=3,include={1,5,8},random={1,2,4}},
            [3]={maxPoint=5,include={1,3,6,7,8},random={1,1,2,3,4}},
        },
        
        --前台展示，对应四个奖池   绿、蓝、紫、橙
        reward={
            [1]={p={{p4003=1,index=1}}},
            [2]={p={{p4003=3,index=11}},se2={{e21=1,index=1},{e22=1,index=2},{e23=1,index=3},{e24=1,index=4},{e25=1,index=5},{e26=1,index=6},{e31=1,index=7},{e32=1,index=8},{e33=1,index=9},{e34=1,index=10}}},
            [3]={p={{p4004=1,index=11}},se2={{e41=1,index=1},{e42=1,index=2},{e43=1,index=3},{e44=1,index=4},{e45=1,index=5},{e51=1,index=6},{e61=1,index=7},{e71=1,index=8},{e81=1,index=9},{e91=1,index=10}}},
            [4]={p={{p4102=1,index=1}}},
        },
        
        serverreward={
            --随机出1,2,3,4,5的权重
            randomNum={26,56,11,6,1},
            --随机3条路线的权重
            randomRoad={29,10,61},
            
            --绿奖池
            pool1={
                {100},
                {50},
                {{"props_p4003",1}},
            },
            --蓝奖池
            pool2={
                {100},
                {94,94,94,94,94,94,94,94,94,94,60},
                {{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1},{"props_p4003",3}},
            },
            --紫奖池
            pool3={
                {100},
                {80,80,80,80,80,80,80,80,80,80,200},
                {{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1},{"props_p4004",1}},
            },
            --橙奖池
            pool4={
                {100},
                {1},
                {{"props_p4102",1}},
            },
        },
        
        --type:任务类型  1：抽取X次超级装备（稀土+金币）  2：突围X次  3：分解X次超级装备  4：进阶X次超级装备  5：升级X次超级装备
        --index:排序
        --needNum:完成条件
        dailyTask={
            {type=1,index=1,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=2,index=2,needNum=5,reward={p={{p4003=2,index=1},{p4001=30,index=2}}},serverreward={props_p4003=2,props_p4001=30}},
            {type=3,index=3,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=4,index=4,needNum=3,reward={p={{p4003=1,index=1},{p4001=30,index=2}}},serverreward={props_p4003=1,props_p4001=30}},
            {type=5,index=5,needNum=1,reward={p={{p4004=1,index=1},{p4001=50,index=2}}},serverreward={props_p4004=1,props_p4001=50}},
        },
    },
    [3]={
        _activeCfg=true,
        type=1,
        sortId=200,
        
        --突围1次
        cost1=58,
        --全速突围,5个坦克
        cost2=290,
        
        --兑换超级装备
        --get:可兑换的超级装备，第一个{}后台，第二个{}前台
        --need:超级装备所需道具，第一个{}后台，第二个{}前台
        exchange={get={{sequip_e121=1},{e121=1}},need={{p4103=20},{p={{p4103=20}}}}},
        
        --总共3条线路
        --maxPoint:每条线路总共有几个点
        --include:每条线路包含点的编号
        --random:线路上每个点的随机库类型
        map={
            [1]={maxPoint=4,include={1,2,4,8},random={1,2,3,4}},
            [2]={maxPoint=3,include={1,5,8},random={1,2,4}},
            [3]={maxPoint=5,include={1,3,6,7,8},random={1,1,2,3,4}},
        },
        
        --前台展示，对应四个奖池   绿、蓝、紫、橙
        reward={
            [1]={p={{p4003=1,index=1}}},
            [2]={p={{p4003=3,index=11}},se2={{e21=1,index=1},{e22=1,index=2},{e23=1,index=3},{e24=1,index=4},{e25=1,index=5},{e26=1,index=6},{e31=1,index=7},{e32=1,index=8},{e33=1,index=9},{e34=1,index=10}}},
            [3]={p={{p4004=1,index=11}},se2={{e41=1,index=1},{e42=1,index=2},{e43=1,index=3},{e44=1,index=4},{e45=1,index=5},{e51=1,index=6},{e61=1,index=7},{e71=1,index=8},{e81=1,index=9},{e91=1,index=10}}},
            [4]={p={{p4103=1,index=1}}},
        },
        
        serverreward={
            --随机出1,2,3,4,5的权重
            randomNum={26,57,12,4,1},
            --随机3条路线的权重
            randomRoad={25,8,67},
            
            --绿奖池
            pool1={
                {100},
                {50},
                {{"props_p4003",1}},
            },
            --蓝奖池
            pool2={
                {100},
                {94,94,94,94,94,94,94,94,94,94,60},
                {{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1},{"props_p4003",3}},
            },
            --紫奖池
            pool3={
                {100},
                {70,70,70,70,70,70,70,70,70,70,300},
                {{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1},{"props_p4004",1}},
            },
            --橙奖池
            pool4={
                {100},
                {1},
                {{"props_p4103",1}},
            },
        },
        
        --type:任务类型  1：抽取X次超级装备（稀土+金币）  2：突围X次  3：分解X次超级装备  4：进阶X次超级装备  5：升级X次超级装备
        --index:排序
        --needNum:完成条件
        dailyTask={
            {type=1,index=1,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=2,index=2,needNum=5,reward={p={{p4003=2,index=1},{p4001=30,index=2}}},serverreward={props_p4003=2,props_p4001=30}},
            {type=3,index=3,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=4,index=4,needNum=3,reward={p={{p4003=1,index=1},{p4001=30,index=2}}},serverreward={props_p4003=1,props_p4001=30}},
            {type=5,index=5,needNum=1,reward={p={{p4004=1,index=1},{p4001=50,index=2}}},serverreward={props_p4004=1,props_p4001=50}},
        },
    },
    [4]={
        _activeCfg=true,
        type=1,
        sortId=200,
        
        --突围1次
        cost1=58,
        --全速突围,5个坦克
        cost2=290,
        
        --兑换超级装备
        --get:可兑换的超级装备，第一个{}后台，第二个{}前台
        --need:超级装备所需道具，第一个{}后台，第二个{}前台
        exchange={get={{sequip_e102=1},{e102=1}},need={{p4104=20},{p={{p4104=20}}}}},
        
        --总共3条线路
        --maxPoint:每条线路总共有几个点
        --include:每条线路包含点的编号
        --random:线路上每个点的随机库类型
        map={
            [1]={maxPoint=4,include={1,2,4,8},random={1,2,3,4}},
            [2]={maxPoint=3,include={1,5,8},random={1,2,4}},
            [3]={maxPoint=5,include={1,3,6,7,8},random={1,1,2,3,4}},
        },
        
        --前台展示，对应四个奖池   绿、蓝、紫、橙
        reward={
            [1]={p={{p4003=1,index=1}}},
            [2]={p={{p4003=3,index=11}},se2={{e21=1,index=1},{e22=1,index=2},{e23=1,index=3},{e24=1,index=4},{e25=1,index=5},{e26=1,index=6},{e31=1,index=7},{e32=1,index=8},{e33=1,index=9},{e34=1,index=10}}},
            [3]={p={{p4004=1,index=11}},se2={{e41=1,index=1},{e42=1,index=2},{e43=1,index=3},{e44=1,index=4},{e45=1,index=5},{e51=1,index=6},{e61=1,index=7},{e71=1,index=8},{e81=1,index=9},{e91=1,index=10}}},
            [4]={p={{p4104=1,index=1}}},
        },
        
        serverreward={
            --随机出1,2,3,4,5的权重
            randomNum={26,58,11,4,1},
            --随机3条路线的权重
            randomRoad={30,5,65},
            
            --绿奖池
            pool1={
                {100},
                {50},
                {{"props_p4003",1}},
            },
            --蓝奖池
            pool2={
                {100},
                {94,94,94,94,94,94,94,94,94,94,60},
                {{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1},{"props_p4003",3}},
            },
            --紫奖池
            pool3={
                {100},
                {70,70,70,70,70,70,70,70,70,70,300},
                {{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1},{"props_p4004",1}},
            },
            --橙奖池
            pool4={
                {100},
                {1},
                {{"props_p4104",1}},
            },
        },
        
        --type:任务类型  1：抽取X次超级装备（稀土+金币）  2：突围X次  3：分解X次超级装备  4：进阶X次超级装备  5：升级X次超级装备
        --index:排序
        --needNum:完成条件
        dailyTask={
            {type=1,index=1,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=2,index=2,needNum=5,reward={p={{p4003=2,index=1},{p4001=30,index=2}}},serverreward={props_p4003=2,props_p4001=30}},
            {type=3,index=3,needNum=5,reward={p={{p4003=1,index=1},{p4001=10,index=2}}},serverreward={props_p4003=1,props_p4001=10}},
            {type=4,index=4,needNum=3,reward={p={{p4003=1,index=1},{p4001=30,index=2}}},serverreward={props_p4003=1,props_p4001=30}},
            {type=5,index=5,needNum=1,reward={p={{p4004=1,index=1},{p4001=50,index=2}}},serverreward={props_p4004=1,props_p4001=50}},
        },
    },
}

return qxtw
