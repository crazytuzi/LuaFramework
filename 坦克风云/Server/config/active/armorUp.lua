local armorUp ={ -- 矩阵升级
    multiSelectType=true,
    -- 1白 2绿 3蓝 4紫 5橙
    -- 事件,事件个数,道具ID,道具个数,道具排位
    -- q矩阵品质服务器为color,lv升级的等级
    [1]={
        OpenLevel=4,
        type=1,
        sortId=318,
        reward={
            {t={q=2,lv=30},r={am={{exp=2000,index=1}}}},
            {t={q=3,lv=20},r={am={{exp=2000,index=1}}}},
            {t={q=4,lv=15},r={am={{exp=2000,index=1}}}},
            {t={q=4,lv=30},r={am={{exp=10000,index=1}}}},
        },
        serverreward={
            {condition={color=2,lv=30},r={armor_exp=2000}},
            {condition={color=3,lv=20},r={armor_exp=2000}},
            {condition={color=4,lv=15},r={armor_exp=2000}},
            {condition={color=4,lv=30},r={armor_exp=10000}},
        },
    },
}
return armorUp 
