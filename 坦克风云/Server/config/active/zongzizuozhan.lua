local zongzizuozhan={
    multiSelectType = true,
    [1]={
        sortid=123,
        type=1,
        --材料获取
        show={"a","b","c","d"},
        getMaterial={
            a={get={"z3",1},rate=1,num=200},--每充值X钻石(红枣)
            b={get={"z4",1},rate=1,num=200},--每消耗X钻石(火腿)
            c={get={"z1",1},rate=0.7,num=1},--攻击野外资源矿或玩家(粽叶)
            d={get={"z2",1},rate=0.7,num=1},--关卡(糯米)
        },
        --粽子兑换
        exchange={
            [1]={n={{"z1",1},{"z2",1},{"z3",1}},reward="p4720",serverreward="props_p4720"},--甜粽子(ver1)
            [2]={n={{"z1",1},{"z2",1},{"z4",1}},reward="p4721",serverreward="props_p4721"},--咸粽子(ver1)
        },
    },
    [2]={
        sortid=123,
        type=1,
        --材料获取
        show={"a","b","c","d"},
        getMaterial={
            a={get={"z3",1},rate=1,num=200},--每充值X钻石(红枣)
            b={get={"z4",1},rate=1,num=200},--每消耗X钻石(火腿)
            c={get={"z1",1},rate=0.7,num=1},--攻击野外资源矿或玩家(粽叶)
            d={get={"z2",1},rate=0.7,num=1},--关卡(糯米)
        },
        --粽子兑换
        exchange={
            [1]={n={{"z1",1},{"z2",1},{"z3",1}},reward="p4722",serverreward="props_p4722"},--甜粽子(ver2)
            [2]={n={{"z1",1},{"z2",1},{"z4",1}},reward="p4723",serverreward="props_p4723"},--咸粽子(ver2)
        },
    },
}

return zongzizuozhan
