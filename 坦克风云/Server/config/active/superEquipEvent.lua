local superEquipEvent ={ -- 超级装备后续活动
    multiSelectType=true,
    -- 0白 1蓝 2紫 3橙 4红 5金
    -- 事件,事件个数,道具ID,道具个数,道具排位
    [1]={
        equipOpenLevel=23,
        type=1,
        sortId=317,
        reward={
            {t={q=3,n=1},p={{p4003=1,index=1},{p4001=5,index=2},{p19=4,index=3},{p20=2,index=4}}},
            {t={q=3,n=4},p={{p4004=1,index=1},{p4001=5,index=2},{p19=4,index=3},{p20=2,index=4}}},
            {t={q=4,n=1},p={{p4004=2,index=1},{p4001=25,index=2},{p19=8,index=3},{p20=2,index=4}}},
            {t={q=4,n=3},p={{p4004=2,index=1},{p4001=50,index=2},{p19=20,index=3},{p20=3,index=4}}},
            {t={q=4,n=5},p={{p4005=1,index=1},{p4001=70,index=2},{p19=20,index=3},{p20=3,index=4}}},
            {t={q=5,n=1},p={{p4005=1,index=1},{p4001=400,index=2},{p19=80,index=3},{p20=8,index=4}}},
        },
        serverreward={
            {condition={color=3,num=1},r={props_p4003=1,props_p4001=5,props_p19=4,props_p20=2}},
            {condition={color=3,num=4},r={props_p4004=1,props_p4001=5,props_p19=4,props_p20=2}},
            {condition={color=4,num=1},r={props_p4004=2,props_p4001=25,props_p19=8,props_p20=2}},
            {condition={color=4,num=3},r={props_p4004=2,props_p4001=50,props_p19=20,props_p20=3}},
            {condition={color=4,num=5},r={props_p4005=1,props_p4001=70,props_p19=20,props_p20=3}},
            {condition={color=5,num=1},r={props_p4005=1,props_p4001=400,props_p19=80,props_p20=8}},
        },
    },
}
return superEquipEvent 
