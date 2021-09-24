tankSkinCfg={
    ----强化道具
    upgradeCostItem="p4969",
    ----拥有涂装转化升级道具个数
    exchangeItemNum={props_p4969=50},
    tankList={
        ------坦克id={所有该坦克的涂装id},每次新增坦克涂装，此处需要对应添加坦克内容
        a10095={"s1"},
        a20155={"s2","s13"},
        a20115={"s3","s14"},
        a20065={"s4"},
        a20125={"s5","s16"},
        a10084={"s6"},
        a10135={"s7"},
        a10045={"s8","s15"},
        a10075={"s9"},
        a10165={"s10"},
        a10145={"s11"},
        a20055={"s12"},
    },
    ------tankId坦克id(普通坦克和精英坦克都生效）;timeLimit时效性；attType属性类型；value属性值;lvMax最大强化值;upgradeCost强化消耗；skip获取跳转对应的活动；restain里面是克制的坦克的类型id；isOpen是否投放；special是否在金币商店投放
    -------skinType皮肤类型1为沙漠版，2为海军版
    skinCfg={
        s1={tankId="a10095",skinType=1,timeLimit=0,isOpen=1,attType={"accuracy"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=8,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s2={tankId="a20155",skinType=2,timeLimit=0,isOpen=1,attType={"crit"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=4,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s3={tankId="a20115",skinType=3,timeLimit=0,isOpen=1,attType={"evade"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=1,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s4={tankId="a20065",skinType=4,timeLimit=0,isOpen=1,attType={"anticrit"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=2,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s5={tankId="a20125",skinType=5,timeLimit=0,isOpen=1,attType={"anticrit"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=8,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s6={tankId="a10084",skinType=6,timeLimit=0,isOpen=1,attType={"evade"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=4,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s7={tankId="a10135",skinType=9,timeLimit=0,isOpen=1,attType={"accuracy"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=1,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s8={tankId="a10045",skinType=10,timeLimit=0,isOpen=1,attType={"evade"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=2,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s9={tankId="a10075",skinType=11,timeLimit=0,isOpen=1,attType={"accuracy"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=8,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s10={tankId="a10165",skinType=12,timeLimit=0,isOpen=1,attType={"anticrit"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=4,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s11={tankId="a10145",skinType=13,timeLimit=0,isOpen=1,attType={"accuracy"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=1,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s12={tankId="a20055",skinType=14,timeLimit=0,isOpen=1,attType={"anticrit"},value={{0.002,0.004,0.006,0.008,0.01,0.014,0.02,0.03,0.05,0.08}},restrain=1,restrainValue={0.01,0.02,0.03,0.04,0.05,0.07,0.09,0.12,0.15,0.2},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",},
        s13={tankId="a20155",skinType=15,timeLimit=0,isOpen=1,attType={"critDmg","first"},value={{0.045,0.057,0.068,0.08,0.092,0.103,0.115,0.127,0.138,0.15},{6,8,9,11,12,14,15,17,18,20}},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",special=1,},
        s14={tankId="a20115",skinType=15,timeLimit=0,isOpen=1,attType={"accuracy","anticrit"},value={{0.045,0.057,0.068,0.08,0.092,0.103,0.115,0.127,0.138,0.15},{0.045,0.057,0.068,0.08,0.092,0.103,0.115,0.127,0.138,0.15}},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",special=1,},
        s15={tankId="a10045",skinType=15,timeLimit=0,isOpen=1,attType={"evade","antifirst"},value={{0.045,0.057,0.068,0.08,0.092,0.103,0.115,0.127,0.138,0.15},{6,8,9,11,12,14,15,17,18,20}},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",special=1,},
        s16={tankId="a20125",skinType=15,timeLimit=0,isOpen=1,attType={"anticrit","decritDmg"},value={{0.045,0.057,0.068,0.08,0.092,0.103,0.115,0.127,0.138,0.15},{0.045,0.057,0.068,0.08,0.092,0.103,0.115,0.127,0.138,0.15}},lvMax=10,upgradeCost={10,20,40,80,120,160,200,300,400},skip="",special=1,},
},
    -------------------shopList涂装商店,order排序;bn限购数量;price价格;reward奖励;type商品类型1是道具2是涂装；isSell是否出售1是，0不出售
    shopList={
        i1={order=999,type=1,desc="sample_prop_des_4969",isSell=1,bn=0,price=15,reward={p={p4969=1}}},
        i2={order=4,type=2,desc="tankskin_s1_desc",isSell=1,bn=1,price=1000,reward={sk={s1=1}}},
        i3={order=3,type=2,desc="tankskin_s2_desc",isSell=1,bn=1,price=1000,reward={sk={s2=1}}},
        i4={order=2,type=2,desc="tankskin_s3_desc",isSell=1,bn=1,price=1000,reward={sk={s3=1}}},
        i5={order=1,type=2,desc="tankskin_s4_desc",isSell=1,bn=1,price=1000,reward={sk={s4=1}}},
        i6={order=6,type=2,desc="tankskin_s5_desc",isSell=1,bn=1,price=1000,reward={sk={s5=1}}},
        i7={order=5,type=2,desc="tankskin_s6_desc",isSell=1,bn=1,price=1000,reward={sk={s6=1}}},
        i8={order=8,type=2,desc="tankskin_s7_desc",isSell=1,bn=1,price=1000,reward={sk={s7=1}}},
        i9={order=7,type=2,desc="tankskin_s8_desc",isSell=1,bn=1,price=1000,reward={sk={s8=1}}},
        i10={order=10,type=2,desc="tankskin_s9_desc",isSell=1,bn=1,price=1000,reward={sk={s9=1}}},
        i11={order=9,type=2,desc="tankskin_s10_desc",isSell=1,bn=1,price=1000,reward={sk={s10=1}}},
        i12={order=12,type=2,desc="tankskin_s11_desc",isSell=1,bn=1,price=1000,reward={sk={s11=1}}},
        i13={order=11,type=2,desc="tankskin_s12_desc",isSell=1,bn=1,price=1000,reward={sk={s12=1}}},
    },
}
