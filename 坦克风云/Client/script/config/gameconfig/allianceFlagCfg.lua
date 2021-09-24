allianceFlagCfg={
    ----------sortId 排序用（按类别） 数值越大越靠前;isShow 是否展示
    ----------type 获得条件类型  1为所需军团等级2为活动投放；condition:等级多少
    ------------att 战斗属性（算法按照配件来计算）；buff为非战斗属性。所有属性值会除以100
    icon={                     ---军团锦旗图标
        i1={sortId=1,type=1,condition=1,pic="allianceFlagIcon1",att={crit=0.2},isShow=1,},
        i2={sortId=2,type=1,condition=10,pic="allianceFlagIcon2",att={crit=0.6},isShow=1,},
        i3={sortId=3,type=1,condition=20,pic="allianceFlagIcon3",att={crit=1.2},isShow=1,},
        i4={sortId=4,type=1,condition=30,pic="allianceFlagIcon4",att={crit=1.8},isShow=1,},
        i5={sortId=5,type=1,condition=40,pic="allianceFlagIcon5",att={crit=2.4},isShow=1,},
        i6={sortId=6,type=1,condition=50,pic="allianceFlagIcon6",att={crit=3.8},isShow=1,},
        i7={sortId=7,type=2,condition="jtxlh",pic="allianceFlagIcon7",att={anticrit=5},isShow=1,},
        i8={sortId=8,type=2,condition="allianceGift",pic="allianceFlagIcon8",att={evade=5},isShow=1,},
        i9={sortId=9,type=2,condition="jtxlh",pic="allianceFlagIcon9",att={accuracy=5},isShow=1,},
        i10={sortId=10,type=2,condition="exerwar",pic="allianceFlagIcon10",att={anticrit=3},isShow=1,},

    },
    ----------type 获得条件类型  1为默认初始；
    ------------condtion 对type的限制,0为无条件;buff 非战斗属性load载重百分比collect采集速度
    frame={                     ---军团锦旗边框
        if1={sortId=1,type=1,condition=0,pic="allianceFlagFrame1",buff={load=0.5},isShow=1,},
        if2={sortId=2,type=1,condition=0,pic="allianceFlagFrame2",buff={load=0.5},isShow=1,},
        if3={sortId=3,type=1,condition=0,pic="allianceFlagFrame3",buff={load=0.5},isShow=1,},
        if4={sortId=4,type=2,condition="jtxlh",pic="allianceFlagFrame4",buff={collect=4},isShow=1,},
        if5={sortId=5,type=2,condition="allianceGift",pic="allianceFlagFrame5",buff={load=0.5},isShow=1,},
        if6={sortId=6,type=2,condition="jtxlh",pic="allianceFlagFrame6",buff={collect=4},isShow=1,},
    },
    ----------type 获得条件类型  1为军团科技等级；
    ----------condtion 对type的限制,1={军团科技id=最小解锁科技等级（大于等于）}
    ----------color里面配的RBG的数字
    color={                     ---军团锦旗底色
        ic1={sortId=1,type=1,condition={s24=0},color={255,255,255},isShow=1,},
        ic2={sortId=2,type=1,condition={s24=1},color={190,214,174},isShow=1,},
        ic3={sortId=3,type=1,condition={s24=2},color={16,178,62},isShow=1,},
        ic4={sortId=4,type=1,condition={s24=3},color={41,152,230},isShow=1,},
        ic5={sortId=5,type=1,condition={s24=4},color={168,55,220},isShow=1,},
        ic6={sortId=6,type=1,condition={s24=5},color={249,150,9},isShow=1,},
    },
    saveCd=43200,        ----保存旗帜冷却时间（单位：秒）
}
