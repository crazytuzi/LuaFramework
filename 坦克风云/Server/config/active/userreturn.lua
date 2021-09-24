local userreturn={
    multiSelectType = true,
    [1]={
        sortid=1,
        type=1,
        --限制等级
        levelLimit=30,
        --距离上次登录时差（天）
        lastLogin=15,
        --VIP等级限制
        vipLimit=0,
        --版本控制 
        version=1,
        --奖励
        reward={o={{a10005=20,index=3},{a10015=20,index=4},{a10025=10,index=5},{a10035=10,index=6}},p={{p3=2,index=2},{p5=1,index=7},{p42=1,index=8}},u={{gems=188,index=1}}},
        serverreward={{"userinfo_gems",188},{"props_p3",2},{"troops_a10005",20},{"troops_a10015",20},{"troops_a10025",10},{"troops_a10035",10},{"props_p5",1},{"props_p42",1}},
    },
    [2]={
        sortid=1,
        type=1,
        --限制等级
        levelLimit=30,
        --距离上次登录时差（天）
        lastLogin=15,
        --VIP等级限制
        vipLimit=0,
        --版本控制 
        version=2,
        --奖励
        reward={o={{a10073=18,index=3},{a10113=18,index=4},{a10043=8,index=5},{a10082=8,index=6}},p={{p4=1,index=2},{p5=2,index=7},{p47=30,index=8}},u={{gems=188,index=1}}},
        serverreward={{"userinfo_gems",188},{"props_p4",1},{"troops_a10073",18},{"troops_a10113",18},{"troops_a10043",8},{"troops_a10082",8},{"props_p5",2},{"props_p47",30}},
    },
}

return userreturn
