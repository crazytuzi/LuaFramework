local jzxl ={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --单抽价格
        cost1={18,28,58},
        --十连价格
        cost2={162,252,522},
        --双倍分数限制(>=则奖励翻倍，且动画展示区分)
        doubleScore={8,8,8},
        serverreward={
            --玩法1分数奖池
            pool_s1={
                {100},
                {10,10,10,10,10,10,10,10,10,10},
                {1,2,3,4,5,6,7,8,9,10},
            },
            
            --玩法2分数奖池
            pool_s2={
                {100},
                {10,10,10,10,10,10,10,10,10,10},
                {1,2,3,4,5,6,7,8,9,10},
            },
            
            --玩法3分数奖池
            pool_s3={
                {100},
                {10,10,10,10,10,10,10,5,5,5},
                {1,2,3,4,5,6,7,8,9,10},
            },
            
            --奖池1
            pool_g1={
                {100},
                {10,10,10,10,10,10,10,10,10,10,10,10,10,10,8,8,8,8,8,8,8,8},
                {{"props_p621",2},{"props_p622",2},{"props_p623",2},{"props_p624",2},{"props_p625",2},{"props_p626",2},{"props_p627",2},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p634",1},{"props_p635",1},{"props_p636",1},{"props_p637",1},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1}},
            },
            
            --奖池2
            pool_g2={
                {100},
                {10,10,10,10,10,10,10,10,10,10,10,10,10,10,3,3,3,3,3,3,3,3},
                {{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2},{"props_p641",1},{"props_p642",1},{"props_p643",1},{"props_p644",1},{"props_p645",1},{"props_p646",1},{"props_p647",1},{"props_p611",2},{"props_p612",2},{"props_p613",2},{"props_p614",2},{"props_p615",2},{"props_p616",2},{"props_p617",2},{"props_p618",2}},
            },
            
            --奖池3
            pool_g3={
                {100},
                {10,10,10,10,10,10,10,10,10,10,10,10,10,10,3,3,3,3,3,3,3,3},
                {{"props_p641",2},{"props_p642",2},{"props_p643",2},{"props_p644",2},{"props_p645",2},{"props_p646",2},{"props_p647",2},{"props_p651",1},{"props_p652",1},{"props_p653",1},{"props_p654",1},{"props_p655",1},{"props_p656",1},{"props_p657",1},{"props_p611",3},{"props_p612",3},{"props_p613",3},{"props_p614",3},{"props_p615",3},{"props_p616",3},{"props_p617",3},{"props_p618",3}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --射击训练获得10分N次
                {type="jz1",num=1,index=1,serverreward={props_p956=10}},
                --阵型训练获得10分N次
                {type="jz2",num=1,index=2,serverreward={props_p959=10}},
                --协作训练获得10分N次
                {type="jz3",num=1,index=3,serverreward={props_p960=5}},
                --总获得N分
                {type="jz4",num=200,index=4,serverreward={props_p957=10,props_p958=5,props_p956=5}},
                --总获得N分
                {type="jz4",num=500,index=5,serverreward={props_p958=10,props_p959=5,props_p956=10}},
                --总获得N分
                {type="jz4",num=1000,index=6,serverreward={props_p959=10,props_p960=5,props_p956=20}},
            },
        },
        rewardTb={
            --奖池1
            pool_g1={p={{p621=2},{p622=2},{p623=2},{p624=2},{p625=2},{p626=2},{p627=2},{p631=1},{p632=1},{p633=1},{p634=1},{p635=1},{p636=1},{p637=1},{p611=1},{p612=1},{p613=1},{p614=1},{p615=1},{p616=1},{p617=1},{p618=1}}},
            
            --奖池2
            pool_g2={p={{p631=2},{p632=2},{p633=2},{p634=2},{p635=2},{p636=2},{p637=2},{p641=1},{p642=1},{p643=1},{p644=1},{p645=1},{p646=1},{p647=1},{p611=2},{p612=2},{p613=2},{p614=2},{p615=2},{p616=2},{p617=2},{p618=2}}},
            
            --奖池3
            pool_g3={p={{p641=2},{p642=2},{p643=2},{p644=2},{p645=2},{p646=2},{p647=2},{p651=1},{p652=1},{p653=1},{p654=1},{p655=1},{p656=1},{p657=1},{p611=3},{p612=3},{p613=3},{p614=3},{p615=3},{p616=3},{p617=3},{p618=3}}},
            
            --任务（标识，参数，奖励）
            taskList={
                {type="jz1",num=1,index=1,reward={p={{p956=10,index=1}}}},
                {type="jz2",num=1,index=2,reward={p={{p959=10,index=1}}}},
                {type="jz3",num=1,index=3,reward={p={{p960=5,index=1}}}},
                {type="jz4",num=200,index=4,reward={p={{p957=10,index=1},{p958=5,index=2},{p956=5,index=3}}}},
                {type="jz4",num=500,index=5,reward={p={{p958=10,index=1},{p959=5,index=2},{p956=10,index=3}}}},
                {type="jz4",num=1000,index=6,reward={p={{p959=10,index=1},{p960=5,index=2},{p956=20,index=3}}}},
            },
        },
    },
}

return jzxl 
