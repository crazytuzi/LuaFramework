local bfqx={
    multiSelectType=true,  --支持多版本
    
    [1]={
        
        type=1,
        sortId=200,
        
        flickReward={p={{p3305=1},{p3304=1}}},     --奖励加闪框
        
        need={2000,4000,8000,18000,40000},     --所需任务点数
        
        needNotice={{2000,"bfqx_notice1"},{8000,"bfqx_notice3"},{40000,"bfqx_notice5"}},   --需要加公告，{任务额度,公告内容}
        
        reward={     --前台奖励
            {p={{p3304=1,index=1},{p13=1,index=2}}},
            {p={{p3304=1,index=1},{p11=1,index=2}}},
            {p={{p3305=1,index=1},{p12=2,index=2}}},
            {p={{p3305=1,index=1},{p19=5,index=2},{p15=1,index=3}}},
            {p={{p3305=3,index=1},{p20=5,index=2},{p19=10,index=3}}},
        },
        
        serverreward={       --后台奖励
            {props_p3304=1,props_p13=1},
            {props_p3304=1,props_p11=1},
            {props_p3305=1,props_p12=2},
            {props_p3305=1,props_p19=5,props_p15=1},
            {props_p3305=3,props_p20=5,props_p19=10},
        },
        
        --t1:攻打玩家    t2:攻打野外资源点   t3:协防     t4:获取军功     t5:充值金币
        --例：t1={15,20}  15：任务次数上限   20：每完成一次任务获得任务点数
        task={
            t1={20,35,1},
            t2={40,50,2},
            t3={20,15,3},
            t4={700000,0.01,4},
            t5={40000,1,5},
        },
    },
}

return bfqx
