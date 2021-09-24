local shoot ={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=58,
        --十连价格
        cost2=550,
        --目标数
        targetNum=12,
        --品质分类
        qualityNum=3,
        --暴击率
        critRate=0.1,
        serverreward={
            --N种颜色奖池
            colorPool={
                {100},
                {50,60,40},
                {1,2,3},
            },
            
            --奖池1
            pool1={
                {100},
                {20,30,50,50,50,50},
                {{"props_p606",2},{"props_p601",5},{"equip_e1",300},{"equip_e2",300},{"equip_e3",300},{"props_p446",10}},
            },
            
            --奖池2
            pool2={
                {100},
                {20,30,50,50,50,30},
                {{"props_p607",2},{"props_p601",10},{"equip_e1",1000},{"equip_e2",1000},{"equip_e3",1000},{"props_p447",2}},
            },
            
            --奖池3
            pool3={
                {100},
                {10,30,50,50,50,50},
                {{"props_p608",2},{"props_p601",20},{"equip_e1",2000},{"equip_e2",2000},{"equip_e3",2000},{"props_p448",1}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --射击N次
                {type="s1",num=5,index=1,serverreward={props_p606=10,equip_e1=2000}},
                --射击N次
                {type="s1",num=50,index=2,serverreward={props_p607=15,equip_e3=2000,equip_e2=2000}},
                --射击N次
                {type="s1",num=300,index=3,serverreward={props_p608=20}},
                --击沉绿色N艘
                {type="s2",num=30,index=4,serverreward={equip_e1=10000,props_p448=1}},
                --击沉蓝色N艘
                {type="s3",num=30,index=5,serverreward={equip_e3=5000,equip_e2=5000,props_p448=1}},
                --击沉紫色N艘
                {type="s4",num=30,index=6,serverreward={props_p608=5,props_p448=1}},
            },
        },
        rewardTb={
            --N种颜色奖池
            colorPool={1,2,3},
            
            --奖池1
            pool1={f={{e1=300,index=3},{e2=300,index=4},{e3=300,index=5}},p={{p606=2,index=1},{p601=5,index=2},{p446=10,index=6}}},
            
            --奖池2
            pool2={f={{e1=1000,index=3},{e2=1000,index=4},{e3=1000,index=5}},p={{p607=2,index=1},{p601=10,index=2},{p447=2,index=6}}},
            
            --奖池3
            pool3={f={{e1=2000,index=2},{e2=2000,index=3},{e3=2000,index=4}},p={{p608=2,index=1},{p601=20,index=2},{p448=1,index=5}}},
            
            --任务（标识，参数，奖励）
            taskList={
                {type="s1",num=5,index=1,reward={f={{e1=2000,index=2}},p={{p606=10,index=1}}}},
                {type="s1",num=50,index=2,reward={f={{e3=2000,index=2},{e2=2000,index=3}},p={{p607=15,index=1}}}},
                {type="s1",num=300,index=3,reward={p={{p608=20,index=1}}}},
                {type="s2",num=30,index=4,reward={f={{e1=10000,index=1}},p={{p448=1,index=2}}}},
                {type="s3",num=30,index=5,reward={f={{e3=5000,index=1},{e2=5000,index=2}},p={{p448=1,index=3}}}},
                {type="s4",num=30,index=6,reward={p={{p608=5,index=1},{p448=1,index=2}}}},
            },
        },
    },
    [2]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=58,
        --十连价格
        cost2=550,
        --目标数
        targetNum=12,
        --品质分类
        qualityNum=3,
        --暴击率
        critRate=0.1,
        serverreward={
            --N种颜色奖池
            colorPool={
                {100},
                {50,50,50},
                {1,2,3},
            },
            
            --奖池1
            pool1={
                {100},
                {20,50,50,50,50,50},
                {{"props_p606",2},{"props_p601",8},{"equip_e1",500},{"equip_e2",500},{"equip_e3",500},{"props_p446",10}},
            },
            
            --奖池2
            pool2={
                {100},
                {20,50,50,50,50,30},
                {{"props_p607",2},{"props_p601",15},{"equip_e1",1000},{"equip_e2",1000},{"equip_e3",1000},{"props_p447",5}},
            },
            
            --奖池3
            pool3={
                {100},
                {10,50,50,50,50,50},
                {{"props_p608",2},{"props_p601",30},{"equip_e1",3000},{"equip_e2",3000},{"equip_e3",3000},{"props_p448",2}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --射击N次
                {type="s1",num=5,index=1,serverreward={props_p606=10,equip_e1=5000}},
                --射击N次
                {type="s1",num=50,index=2,serverreward={props_p607=15,equip_e3=5000,equip_e2=5000}},
                --射击N次
                {type="s1",num=300,index=3,serverreward={props_p608=20}},
                --击沉绿色N艘
                {type="s2",num=30,index=4,serverreward={equip_e1=30000,props_p448=2}},
                --击沉蓝色N艘
                {type="s3",num=30,index=5,serverreward={equip_e3=10000,equip_e2=10000,props_p448=2}},
                --击沉紫色N艘
                {type="s4",num=30,index=6,serverreward={props_p608=5,props_p448=2}},
            },
        },
        rewardTb={
            --N种颜色奖池
            colorPool={1,2,3},
            
            --奖池1
            pool1={f={{e1=500,index=3},{e2=500,index=4},{e3=500,index=5}},p={{p606=2,index=1},{p601=8,index=2},{p446=10,index=6}}},
            
            --奖池2
            pool2={f={{e1=1000,index=3},{e2=1000,index=4},{e3=1000,index=5}},p={{p607=2,index=1},{p601=15,index=2},{p447=5,index=6}}},
            
            --奖池3
            pool3={f={{e1=3000,index=3},{e2=3000,index=4},{e3=3000,index=5}},p={{p608=2,index=1},{p601=30,index=2},{p448=2,index=6}}},
            
            --任务（标识，参数，奖励）
            taskList={
                {type="s1",num=5,index=1,reward={f={{e1=5000,index=2}},p={{p606=10,index=1}}}},
                {type="s1",num=50,index=2,reward={f={{e3=5000,index=2},{e2=5000,index=3}},p={{p607=15,index=1}}}},
                {type="s1",num=300,index=3,reward={p={{p608=20,index=1}}}},
                {type="s2",num=30,index=4,reward={f={{e1=30000,index=1}},p={{p448=2,index=2}}}},
                {type="s3",num=30,index=5,reward={f={{e3=10000,index=1},{e2=10000,index=2}},p={{p448=2,index=3}}}},
                {type="s4",num=30,index=6,reward={p={{p608=5,index=1},{p448=2,index=2}}}},
            },
        },
    },
    [3]={
        sortid=231,
        type=1,
        --单抽价格
        cost1=68,
        --十连价格
        cost2=630,
        --目标数
        targetNum=12,
        --品质分类
        qualityNum=3,
        --暴击率
        critRate=0.1,
        serverreward={
            --N种颜色奖池
            colorPool={
                {100},
                {50,50,50},
                {2,3,4},
            },
            
            --奖池1
            pool2={
                {100},
                {20,50,50,50,50,30},
                {{"props_p607",2},{"props_p601",15},{"equip_e1",1000},{"equip_e2",1000},{"equip_e3",1000},{"props_p447",5}},
            },
            
            --奖池2
            pool3={
                {100},
                {10,50,50,50,50,50},
                {{"props_p608",2},{"props_p601",30},{"equip_e1",3000},{"equip_e2",3000},{"equip_e3",3000},{"props_p448",2}},
            },
            
            --奖池3
            pool4={
                {100},
                {10,50,50,50,50,50},
                {{"props_p608",5},{"props_p601",50},{"equip_e1",5000},{"equip_e2",5000},{"equip_e3",5000},{"props_p448",5}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --射击N次
                {type="s1",num=5,index=1,serverreward={props_p606=20,equip_e1=10000}},
                --射击N次
                {type="s1",num=50,index=2,serverreward={props_p607=30,equip_e3=10000,equip_e2=10000}},
                --射击N次
                {type="s1",num=300,index=3,serverreward={props_p608=30}},
                --击沉蓝色N艘
                {type="s3",num=30,index=4,serverreward={equip_e1=50000,props_p448=5}},
                --击沉紫色N艘
                {type="s4",num=30,index=5,serverreward={equip_e3=20000,equip_e2=20000,props_p448=5}},
                --击沉橙色N艘
                {type="s5",num=30,index=6,serverreward={props_p608=10,props_p448=5}},
            },
        },
        rewardTb={
            --N种颜色奖池
            colorPool={2,3,4},
            
            --奖池1
            pool2={f={{e1=1000,index=3},{e2=1000,index=4},{e3=1000,index=5}},p={{p607=2,index=1},{p601=15,index=2},{p447=5,index=6}}},
            
            --奖池2
            pool3={f={{e1=3000,index=3},{e2=3000,index=4},{e3=3000,index=5}},p={{p608=2,index=1},{p601=30,index=2},{p448=2,index=6}}},
            
            --奖池3
            pool4={f={{e1=5000,index=3},{e2=5000,index=4},{e3=5000,index=5}},p={{p608=5,index=1},{p601=50,index=2},{p448=5,index=6}}},
            
            --任务（标识，参数，奖励）
            taskList={
                {type="s1",num=5,index=1,reward={f={{e1=10000,index=2}},p={{p606=20,index=1}}}},
                {type="s1",num=50,index=2,reward={f={{e3=10000,index=2},{e2=10000,index=3}},p={{p607=30,index=1}}}},
                {type="s1",num=300,index=3,reward={p={{p608=30,index=1}}}},
                {type="s3",num=30,index=4,reward={f={{e1=50000,index=1}},p={{p448=5,index=2}}}},
                {type="s4",num=30,index=5,reward={f={{e3=20000,index=1},{e2=20000,index=2}},p={{p448=5,index=3}}}},
                {type="s5",num=30,index=6,reward={p={{p608=10,index=1},{p448=5,index=2}}}},
            },
        },
    },
}

return shoot 
