local oceanmorale={
    multiSelectType = true,
    --士气值系统
    [1]={
        sortid=231,
        type=1,
        --采集x点资源=1点士气值
        collect=100000,
        --生产军舰对应积分
        roShip={
            l2=1,
            l3=8,
            l4=20,
            l5=40,
            l6=115,
        },
        --消耗1点体力=x点士气值
        costPower=30,
        --充值300钻石,送80朵花,返利25%
        recharge={300,80},
    },
}
return oceanmorale
