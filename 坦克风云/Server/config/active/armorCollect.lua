local armorCollect ={ -- 矩阵收集
    multiSelectType=true,
    -- 1白 2绿 3蓝 4紫 5橙
    -- 事件,事件个数,道具ID,道具个数,道具排位
    [1]={
        OpenLevel=4,
        type=1,
        sortId=318,
        reward={
            {t={q=3,n=2},r={p={{p4511=1,index=1}}}},
            {t={q=3,n=7},r={p={{p4510=1,index=1}},am={{exp=2000,index=2}}}},
            {t={q=4,n=2},r={p={{p4517=2,index=1}},am={{exp=4000,index=2}}}},
            {t={q=4,n=5},r={p={{p4604=1,index=1}},am={{exp=4000,index=2}}}},
            {t={q=4,n=10},r={p={{p4523=1,index=1}},am={{exp=10000,index=2}}}},
        },
        serverreward={
            {condition={color=3,num=2},r={props_p4511=1}},
            {condition={color=3,num=7},r={props_p4510=1,armor_exp=2000}},
            {condition={color=4,num=2},r={props_p4517=2,armor_exp=4000}},
            {condition={color=4,num=5},r={props_p4604=1,armor_exp=4000}},
            {condition={color=4,num=10},r={props_p4523=1,armor_exp=10000}},
        },
    },
}
return armorCollect 
