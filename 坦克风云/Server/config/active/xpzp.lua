local xpzp={
    multiSelectType=true,
    [1]={
        version=1,
        sortid=201,
        type=1,
        
        cost1=38,
        cost2={205,175,140,110,75,38},     --全面激活（分别剩6、5、4、3、2、1次）所需金币
        poolNum=6,
        pool2Rate=1,
        
        rechargeNum=900,     --充值达到额度后可以购买限购商品
        buyLimit=10,     --限购数量，活动期间不重置
        price=180,     --原价
        value=80,     --售价
        buyItem={p={p4032=1}},     --尖端异星武器碎片选择包
        serverreward={
            buyItem={props_p4032=1},     --尖端异星武器碎片选择包
            randomPool1={
                {100},
                {70,70,90,90,90,90,120,120,120,120,100,100,100,100},
                {{"aweapon_af17",1},{"aweapon_af18",1},{"aweapon_af13",1},{"aweapon_af14",1},{"aweapon_af15",1},{"aweapon_af16",1},{"aweapon_af7",1},{"aweapon_af8",1},{"aweapon_af9",1},{"aweapon_af10",1},{"aweapon_af1",1},{"aweapon_af2",1},{"aweapon_af3",1},{"aweapon_af4",1}},
            },
            randomPool2={
                {100},
                {100,100,80,80,60,60,50,50},
                {{"aweapon_af19",1},{"aweapon_af20",1},{"aweapon_af21",1},{"aweapon_af22",1},{"aweapon_af23",1},{"aweapon_af24",1},{"aweapon_af25",1},{"aweapon_af26",1}},
            },
        },
        normalReward={aw={{af17=1,index=1},{af18=1,index=2},{af13=1,index=3},{af14=1,index=4},{af15=1,index=5},{af16=1,index=6},{af7=1,index=7},{af8=1,index=8},{af9=1,index=9},{af10=1,index=10},{af1=1,index=11},{af2=1,index=12},{af3=1,index=13},{af4=1,index=14}}},
        flickReward={
            aw={{af19=1},{af20=1},{af21=1},{af22=1},{af23=1},{af24=1},{af25=1},{af26=1}}
        },
    },
}

return xpzp
