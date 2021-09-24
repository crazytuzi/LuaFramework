local djjy={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        ----充值天数
        days=3,
        ----每天充值礼上限（前端展示用）
        rechargeMax={268,910,1920},
        ----积分领取礼包
        scoreNeed={20,40,60,80},
        ----积分道具
        scoreItem="djjy_a1",
        serverreward={
            --任务（标识，参数，奖励）
            taskList={
                day1={
                    {num=268,index=1,r={props_p4024=1,aweapon_exp=1000,djjy_a1=10}},
                },
                day2={
                    {num=268,index=1,r={props_p4024=1,aweapon_exp=1000,djjy_a1=10}},
                    {num=910,index=2,r={props_p4024=3,aweapon_exp=2000,djjy_a1=20}},
                },
                day3={
                    {num=268,index=1,r={props_p4024=1,aweapon_exp=1000,djjy_a1=10}},
                    {num=910,index=2,r={props_p4024=3,aweapon_exp=2000,djjy_a1=20}},
                    {num=1920,index=3,r={props_p4024=6,aweapon_exp=3000,djjy_a1=30}},
                },
            },
            gift={
                {props_p4032=1,aweapon_exp=1000},
                {props_p4032=2,aweapon_exp=2000},
                {props_p4032=3,aweapon_exp=5000},
                {props_p4032=6,aweapon_exp=8000},
            },
        },
        rewardTb={
            --任务（标识，参数，奖励）
            taskList={
                day1={
                    {num=268,index=1,r={p={{p4024=1,index=1}},aw={{exp=1000,index=2}},djjy={{djjy_a1=10,index=3}}}},
                },
                day2={
                    {num=268,index=1,r={p={{p4024=1,index=1}},aw={{exp=1000,index=2}},djjy={{djjy_a1=10,index=3}}}},
                    {num=910,index=2,r={p={{p4024=3,index=1}},aw={{exp=2000,index=2}},djjy={{djjy_a1=20,index=3}}}},
                },
                day3={
                    {num=268,index=1,r={p={{p4024=1,index=1}},aw={{exp=1000,index=2}},djjy={{djjy_a1=10,index=3}}}},
                    {num=910,index=2,r={p={{p4024=3,index=1}},aw={{exp=2000,index=2}},djjy={{djjy_a1=20,index=3}}}},
                    {num=1920,index=3,r={p={{p4024=6,index=1}},aw={{exp=3000,index=2}},djjy={{djjy_a1=30,index=3}}}},
                },
            },
            gift={
                {p={{p4032=1,index=1}},aw={{exp=1000,index=2}}},
                {p={{p4032=2,index=1}},aw={{exp=2000,index=2}}},
                {p={{p4032=3,index=1}},aw={{exp=5000,index=2}}},
                {p={{p4032=6,index=1}},aw={{exp=8000,index=2}}},
            },
        },
    },
    [2]={
        sortid=231,
        type=1,
        ----充值天数
        days=3,
        ----每天充值礼上限（前端展示用）
        rechargeMax={268,910,1920},
        ----积分领取礼包
        scoreNeed={20,40,60,80},
        ----积分道具
        scoreItem="djjy_a1",
        serverreward={
            --任务（标识，参数，奖励）
            taskList={
                day1={
                    {num=268,index=1,r={props_p3436=5,props_p960=1,djjy_a1=10}},
                },
                day2={
                    {num=268,index=1,r={props_p3436=5,props_p960=1,djjy_a1=10}},
                    {num=910,index=2,r={props_p3436=10,props_p960=2,djjy_a1=20}},
                },
                day3={
                    {num=268,index=1,r={props_p3436=5,props_p960=1,djjy_a1=10}},
                    {num=910,index=2,r={props_p3436=10,props_p960=2,djjy_a1=20}},
                    {num=1920,index=3,r={props_p3436=20,props_p960=5,djjy_a1=30}},
                },
            },
            gift={
                {props_p5193=3,props_p608=1},
                {props_p5193=6,props_p608=1},
                {props_p5193=9,props_p608=3},
                {props_p5193=15,props_p608=3},
            },
        },
        rewardTb={
            --任务（标识，参数，奖励）
            taskList={
                day1={
                    {num=268,index=1,r={p={{p3436=5,index=1},{p960=1,index=2}},djjy={{djjy_a1=10,index=3}}}},
                },
                day2={
                    {num=268,index=1,r={p={{p3436=5,index=1},{p960=1,index=2}},djjy={{djjy_a1=10,index=3}}}},
                    {num=910,index=2,r={p={{p3436=10,index=1},{p960=2,index=2}},djjy={{djjy_a1=20,index=3}}}},
                },
                day3={
                    {num=268,index=1,r={p={{p3436=5,index=1},{p960=1,index=2}},djjy={{djjy_a1=10,index=3}}}},
                    {num=910,index=2,r={p={{p3436=10,index=1},{p960=2,index=2}},djjy={{djjy_a1=20,index=3}}}},
                    {num=1920,index=3,r={p={{p3436=20,index=1},{p960=5,index=2}},djjy={{djjy_a1=30,index=3}}}},
                },
            },
            gift={
                {p={{p5193=3,index=1},{p608=1,index=2}}},
                {p={{p5193=6,index=1},{p608=1,index=2}}},
                {p={{p5193=9,index=1},{p608=3,index=2}}},
                {p={{p5193=15,index=1},{p608=3,index=2}}},
            },
        },
    },
}

return djjy
