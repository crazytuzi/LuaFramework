local cpem={
    _isAllianceActivity = true,
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        ----排行榜奖励领取数量限制
        rGetLimit=40,
        --排行榜最高伤害奖励限制领取人数
        rLeaderLimit=1,
        --排行榜上榜限制
        rLimit=500,
        --排行榜排名上限（因为是跨服所以需要有个限制）
        rNumLimit=10,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --领奖时间（天）（废弃）
        prizeTime=2,
        --boss血量
        bossHp=5000,
        --每次被击杀增加血量
        hpUp=1000,
        --伤害值（普通炮弹非克制攻击伤害，普通炮弹克制攻击伤害，特种炮弹伤害）
        damage={100,150,200},
        --N轮boss被清除后转换形态（注意两次转换形态不能一样）
        changeSpace=3,
        --对应三种形态的三种炮弹（1、2、3分别对应boss形态的1、2、3，同时这些投掷时给予pool1的奖励）
        bombMatch={"cpem_a1","cpem_a2","cpem_a3"},
        --特种炮弹（对应pool2的奖励）
        spBomb="cpem_a4",
        serverreward={
            --boss属性随机奖池（1-红，2-蓝，3-绿，4-无属性）
            bossPool={
                {100},
                {8,8,8,8},
                {1,2,3,4},
            },
            --普通任务奖池
            p1={
                {100},
                {50,50,50,20},
                {{"cpem_a1",1},{"cpem_a2",1},{"cpem_a3",1},{"cpem_a4",1}},
            },
            --消费任务奖池
            p2={
                {100},
                {15,15,15,15},
                {{"cpem_a1",1},{"cpem_a2",1},{"cpem_a3",1},{"cpem_a4",1}},
            },
            --获取炮弹(limit：根据天数读取获取炮弹总数限制（修改为任务完成次数限制，即每天前N次有几率获得道具），如果超过元素数量则读取最后一个数值，有r的话即有奖励，没有r没有奖励。getType：1-直接发放，2-手动领取。Pool为绑定的奖池，rate：获取奖池奖励的概率）
            taskList={
                --采集X的铁铝钛油土（任一地图老五样资源）
                {type="cj",num=1000000,index=1,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --攻打X次海盗
                {type="fa",num=1,index=2,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --击杀X次海盗
                {type="fs",num=1,index=3,limit={10,10,20,20,30,30,30},rate=1,pool="p1",getType=1},
                --攻打X次关卡胜利
                {type="cn",num=1,index=4,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --购买礼包（花费X钻石，需要扣钻石）
                {type="hf",num=300,index=5,limit={50,50,50,50,50,50,50},rate=1,r={equip_e1=2000,props_p5160=2,props_p5159=5,cpem_a4=1},pool="p2",getType=2},
            },
            --普通炮弹奖池
            pool1={
                {100},
                {5,100,5,5,5,10,10,5,20,20,20,20,20,20,100,100,100,100},
                {{"props_p5160",1},{"props_p5159",1},{"props_p608",1},{"props_p960",1},{"props_p4858",1},{"props_p4854",1},{"props_p4812",1},{"props_p4852",1},{"props_p607",1},{"props_p959",1},{"props_p4875",1},{"props_p4853",5},{"props_p4811",1},{"props_p933",1},{"props_p606",1},{"props_p958",1},{"props_p4873",1},{"props_p4810",1}},
            },
            --特殊炮弹奖池
            pool2={
                {100},
                {20,20,5,5,5,10,10,5},
                {{"props_p5160",2},{"props_p5159",5},{"props_p608",1},{"props_p960",1},{"props_p4858",1},{"props_p4854",1},{"props_p4812",1},{"props_p4852",1}},
            },
            rank={
                {props_p4806=10,props_p4887=1,props_p4772=1,props_p3011=10},
                {props_p4806=5,props_p4886=1,props_p3011=6},
                {props_p4806=3,props_p4885=1,props_p3011=3},
                {props_p4806=2,props_p4884=1,props_p3011=2},
                {props_p4806=1,props_p4883=1,props_p3011=1},
            },
            trank={
                {props_p4900=2,props_p4852=50},
                {props_p4900=1,props_p4852=30},
                {props_p4852=20},
                {props_p4852=10},
                {props_p4852=5},
            },
        },
        rewardTb={
            --获取炮弹(limit：根据天数读取获取炮弹总数限制（修改为任务完成次数限制，即每天前N次有几率获得道具），如果超过元素数量则读取最后一个数值，有r的话即有奖励，没有r没有奖励。getType：1-直接发放，2-手动领取。Pool为绑定的奖池，rate：获取奖池奖励的概率）
            taskList={
                --采集X的铁铝钛油土（任一地图老五样资源）
                {type="cj",num=1000000,index=1,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --攻打X次海盗
                {type="fa",num=1,index=2,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --击杀X次海盗
                {type="fs",num=1,index=3,limit={10,10,20,20,30,30,30},rate=1,pool="p1",getType=1},
                --攻打X次关卡胜利
                {type="cn",num=1,index=4,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --购买礼包（花费X钻石，需要扣钻石）
                {type="hf",num=300,index=5,limit={50,50,50,50,50,50,50},rate=1,r={f={{e1=2000,index=1}},p={{p5160=2,index=2},{p5159=5,index=3}},cpem={{cpem_a4=1,index=4}}},pool="p2",getType=2},
            },
            --普通炮弹奖池
            pool1={p={{p5160=1,index=1},{p5159=1,index=2},{p608=1,index=3},{p960=1,index=4},{p4858=1,index=5},{p4854=1,index=6},{p4812=1,index=7},{p4852=1,index=8},{p607=1,index=9},{p959=1,index=10},{p4875=1,index=11},{p4853=5,index=12},{p4811=1,index=13},{p933=1,index=14},{p606=1,index=15},{p958=1,index=16},{p4873=1,index=17},{p4810=1,index=18}}},
            --特殊炮弹奖池
            pool2={p={{p5160=2,index=1},{p5159=5,index=2},{p608=1,index=3},{p960=1,index=4},{p4858=1,index=5},{p4854=1,index=6},{p4812=1,index=7},{p4852=1,index=8}}},
            rank={
                {p={{p4806=10,index=1},{p4887=1,index=2},{p4772=1,index=3},{p3011=10,index=4}}},
                {p={{p4806=5,index=1},{p4886=1,index=2},{p3011=6,index=3}}},
                {p={{p4806=3,index=1},{p4885=1,index=2},{p3011=3,index=3}}},
                {p={{p4806=2,index=1},{p4884=1,index=2},{p3011=2,index=3}}},
                {p={{p4806=1,index=1},{p4883=1,index=2},{p3011=1,index=3}}},
            },
            trank={
                {p={{p4900=2,index=1},{p4852=50,index=2}}},
                {p={{p4900=1,index=1},{p4852=30,index=2}}},
                {p={{p4852=20,index=1}}},
                {p={{p4852=10,index=1}}},
                {p={{p4852=5,index=1}}},
            },
        },
    },
    [2]={
        sortid=231,
        type=1,
        ----排行榜奖励领取数量限制
        rGetLimit=40,
        --排行榜最高伤害奖励限制领取人数
        rLeaderLimit=1,
        --排行榜上榜限制
        rLimit=500,
        --排行榜排名上限（因为是跨服所以需要有个限制）
        rNumLimit=10,
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --领奖时间（天）（废弃）
        prizeTime=2,
        --boss血量
        bossHp=5000,
        --每次被击杀增加血量
        hpUp=1000,
        --伤害值（普通炮弹非克制攻击伤害，普通炮弹克制攻击伤害，特种炮弹伤害）
        damage={100,150,200},
        --N轮boss被清除后转换形态（注意两次转换形态不能一样）
        changeSpace=3,
        --对应三种形态的三种炮弹（1、2、3分别对应boss形态的1、2、3，同时这些投掷时给予pool1的奖励）
        bombMatch={"cpem_a1","cpem_a2","cpem_a3"},
        --特种炮弹（对应pool2的奖励）
        spBomb="cpem_a4",
        serverreward={
            --boss属性随机奖池（1-红，2-蓝，3-绿，4-无属性）
            bossPool={
                {100},
                {8,8,8,8},
                {1,2,3,4},
            },
            --普通任务奖池
            p1={
                {100},
                {50,50,50,20},
                {{"cpem_a1",1},{"cpem_a2",1},{"cpem_a3",1},{"cpem_a4",1}},
            },
            --消费任务奖池
            p2={
                {100},
                {15,15,15,15},
                {{"cpem_a1",1},{"cpem_a2",1},{"cpem_a3",1},{"cpem_a4",1}},
            },
            --获取炮弹(limit：根据天数读取获取炮弹总数限制（修改为任务完成次数限制，即每天前N次有几率获得道具），如果超过元素数量则读取最后一个数值，有r的话即有奖励，没有r没有奖励。getType：1-直接发放，2-手动领取。Pool为绑定的奖池，rate：获取奖池奖励的概率）
            taskList={
                --采集X的铁铝钛油土（任一地图老五样资源）
                {type="cj",num=1000000,index=1,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --攻打X次海盗
                {type="fa",num=1,index=2,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --击杀X次海盗
                {type="fs",num=1,index=3,limit={10,10,20,20,30,30,30},rate=1,pool="p1",getType=1},
                --攻打X次关卡胜利
                {type="cn",num=1,index=4,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --购买礼包（花费X钻石，需要扣钻石）
                {type="hf",num=300,index=5,limit={50,50,50,50,50,50,50},rate=1,r={equip_e1=2000,props_p5160=2,props_p5159=5,cpem_a4=1},pool="p2",getType=2},
            },
            --普通炮弹奖池
            pool1={
                {100},
                {5,100,5,5,5,10,10,5,20,20,20,20,20,20,100,100,100,100},
                {{"props_p5160",1},{"props_p5159",1},{"props_p608",1},{"props_p960",1},{"props_p4858",1},{"props_p4854",1},{"props_p4812",1},{"props_p4852",1},{"props_p607",1},{"props_p959",1},{"props_p4875",1},{"props_p4853",5},{"props_p4811",1},{"props_p933",1},{"props_p606",1},{"props_p958",1},{"props_p4873",1},{"props_p4810",1}},
            },
            --特殊炮弹奖池
            pool2={
                {100},
                {20,20,5,5,5,10,10,5},
                {{"props_p5160",2},{"props_p5159",5},{"props_p608",1},{"props_p960",1},{"props_p4858",1},{"props_p4854",1},{"props_p4812",1},{"props_p4852",1}},
            },
            rank={
                {props_p4806=10,props_p4887=1,props_p4773=1,props_p3011=10},
                {props_p4806=5,props_p4886=1,props_p3011=6},
                {props_p4806=3,props_p4885=1,props_p3011=3},
                {props_p4806=2,props_p4884=1,props_p3011=2},
                {props_p4806=1,props_p4883=1,props_p3011=1},
            },
            trank={
                {props_p4900=2,props_p4852=50},
                {props_p4900=1,props_p4852=30},
                {props_p4852=20},
                {props_p4852=10},
                {props_p4852=5},
            },
        },
        rewardTb={
            --获取炮弹(limit：根据天数读取获取炮弹总数限制（修改为任务完成次数限制，即每天前N次有几率获得道具），如果超过元素数量则读取最后一个数值，有r的话即有奖励，没有r没有奖励。getType：1-直接发放，2-手动领取。Pool为绑定的奖池，rate：获取奖池奖励的概率）
            taskList={
                --采集X的铁铝钛油土（任一地图老五样资源）
                {type="cj",num=1000000,index=1,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --攻打X次海盗
                {type="fa",num=1,index=2,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --击杀X次海盗
                {type="fs",num=1,index=3,limit={10,10,20,20,30,30,30},rate=1,pool="p1",getType=1},
                --攻打X次关卡胜利
                {type="cn",num=1,index=4,limit={15,15,30,30,45,45,45},rate=0.7,pool="p1",getType=1},
                --购买礼包（花费X钻石，需要扣钻石）
                {type="hf",num=300,index=5,limit={50,50,50,50,50,50,50},rate=1,r={f={{e1=2000,index=1}},p={{p5160=2,index=2},{p5159=5,index=3}},cpem={{cpem_a4=1,index=4}}},pool="p2",getType=2},
            },
            --普通炮弹奖池
            pool1={p={{p5160=1,index=1},{p5159=1,index=2},{p608=1,index=3},{p960=1,index=4},{p4858=1,index=5},{p4854=1,index=6},{p4812=1,index=7},{p4852=1,index=8},{p607=1,index=9},{p959=1,index=10},{p4875=1,index=11},{p4853=5,index=12},{p4811=1,index=13},{p933=1,index=14},{p606=1,index=15},{p958=1,index=16},{p4873=1,index=17},{p4810=1,index=18}}},
            --特殊炮弹奖池
            pool2={p={{p5160=2,index=1},{p5159=5,index=2},{p608=1,index=3},{p960=1,index=4},{p4858=1,index=5},{p4854=1,index=6},{p4812=1,index=7},{p4852=1,index=8}}},
            rank={
                {p={{p4806=10,index=1},{p4887=1,index=2},{p4773=1,index=3},{p3011=10,index=4}}},
                {p={{p4806=5,index=1},{p4886=1,index=2},{p3011=6,index=3}}},
                {p={{p4806=3,index=1},{p4885=1,index=2},{p3011=3,index=3}}},
                {p={{p4806=2,index=1},{p4884=1,index=2},{p3011=2,index=3}}},
                {p={{p4806=1,index=1},{p4883=1,index=2},{p3011=1,index=3}}},
            },
            trank={
                {p={{p4900=2,index=1},{p4852=50,index=2}}},
                {p={{p4900=1,index=1},{p4852=30,index=2}}},
                {p={{p4852=20,index=1}}},
                {p={{p4852=10,index=1}}},
                {p={{p4852=5,index=1}}},
            },
        },
    },
}

return cpem
