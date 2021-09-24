local serverWarExerciseCfg ={
    --每场战斗积分运算规则（胜利获取积分=winPoint+livePoint*该场战斗胜方剩余坦克/该场战斗胜方上阵总坦克；失败积分=lossPoint）
    --需求玩家等级
    levelLimit=60,
    --服内PVP持续时间
    pvp1Time=5,
    --跨服PVP持续时间
    pvp2Time=2,
    --总持续时间
    allTime=14,
    --玩家初始带兵量
    playerTroops=1200,
    --玩家初始先手值
    playerFirst=1000,
    --决赛先手值相同时，增加先手值
    firstAdd=100,
    --默认晋级人数
    severWinner=5,
    --服务器对应晋级人数
    plat={
        efun_tw={
            severWinner=5,
        },
        efun_nm={
            severWinner=5,
        },
    },
    --服内PVP
    --服内PVP积分排行为取积分最大的pointCount天的积分和用作排行（不可消耗），取服内PVP总天数pvp1Time的积分和用作积分商店购买物品
    PVP1={
        --服内对战晋级人数
        winNum=3,
        --军演名次对应晋级
        winRank=1,
        --设置部队数量
        armyNum=1,
        --晋级门票起拍价格（金币）
        buyCost=1000,
        --晋级门票上限价格（金币）
        tickeCost1=1000000,
        --晋级门票加价单位（金币）
        tickeCost2=100,
        --晋级门票数量
        ticketNum=1,
        --服内PVP随机镜像数量
        robotNum=3,
        --排行选取积分最大的几天
        pointCount=3,
        --胜利积分
        winPoint=280,
        --失败积分
        lossPoint=220,
        --生存率积分上限
        livePoint=120,
        --报名截至时间(每日设置部队截至时间)
        joinTime=64500,
        --战斗结束时间(每日战报查看时间)
        overTime=68400,
        --门票竞拍时间(周五0点-17点55)
        ticketTime=64500,
        --排行榜显示人数
        rankNum=10,
        --镜像选择规则（range--战力区间（战力排序，这里填的是百分比，例如{a,b,c}，则分为大于0小于等于a;大于a小于等于b;大于b小于等于c;三个范围，相应抽取对应个数个镜像），num--对应战力区间随机镜像个数）
        robotChoice={
            range={0.33,0.66,1},
            num={1,1,1},
        },
        --坦克可选(tankNum--坦克上阵组数上限，tankMax--每期抽取坦克类型上限，poolChoice--随机池抽取次数（tankMax-poolChoice=顺序抽取次数，先顺序抽，然后随机在任意池抽取与顺序抽不同的poolChoice种坦克），id--池id（顺序抽时顺序为1-4-1）)
        tankChoice={
            tankNum=6,
            tankMax=10,
            poolChoice=2,
            tankPool={
                {"a10008","a10075","a10095","a20125"},
                {"a10018","a20114","a20055","a10135","a20115","a10145"},
                {"a10028","a10045","a20065"},
                {"a10038","a10084","a10165","a20155"},
            },
        },
        --飞机可选（grade--飞机等级，skillId--飞机技能可选池）
        planeChoice={
            grade=1,
            planeId={"p1","p2","p3","p4"},
            skillId={"s1034","s1066","s1098","s1130","s1162","s1194","s1354","s1386"},
        },
        --AI可选（Ainum--最大可上阵数量，AIgrade--AI等级，AIquality--AI等阶，AIskillGrade--AI技能等级，AI--AI可选池）
        AIchoice={
            AInum=3,
            AIgrade=20,
            AIquality=2,
            AIskillGrade=2,
            AI={"a17","a16","a15","a14","a13","a12","a11","a10","a9","a8","a7","a6"},
        },
        --将领可选（heroMax--将领上阵上限，heroNum--随机将领个数，heroStar--将领星级，heroGrade--将领等级，skillGrade--将领技能等级，specialHero--每期固定将领（全选），hero--将领池（随机heroNum个），heroAbility--将领属性）
        heroChoice={
            heroMax=6,
            heroNum=16,
            heroStar=5,
            heroGrade=70,
            skillGrade=20,
            specialHero={"h1","h2","h3","h24"},
            hero={"h4","h5","h6","h7","h8","h9","h10","h11","h12","h13","h14","h15","h16","h17","h18","h19","h20","h21","h22","h23","h25","h26","h27","h28","h29","h30","h31","h32","h33","h34","h35","h36","h37","h38","h39","h40","h51","h52","h53","h55","h56","h57","h81","h82","h59","h60","h67","h68"},
        },
        --军徽可选(equipId--军徽Id)
        equipChoice={
            equipId={"e103","e104","e122"},
        },
        --随机主题（id--主题序号，weight--主题权重，type--主题类型，d1/d2--参数，specialHero--推荐将领（特殊显示），类型（1-阵容相关，2-克制相关，3-属性相关，4-地形相关），类型为1时：d1-坦克类型（1-坦克，2-歼击车，4-自行火炮，8-火箭车），d2-上阵限制组数（{0,x}前者为类型参数（0为必须上阵x组，1为上阵不可超过x组），后者为上阵组数）；类型为2时：d1-克制类型（1-坦克，2-歼击车，4-自行火炮，8-火箭车），d2-克制坦克（1-坦克，2-歼击车，4-自行火炮，8-火箭车），d3-提升百分比；类型为3时：d1-属性增长号位，d2-提升属性类型及提升百分比；类型为4时：d1-地形类型（1-山地，2-沙漠，3-平原，4-森林，5-沼泽，6-城市））
        themeChoice={
            {id=1,weight=20,type=1,d1=1,d2={1,1},first=200},
            {id=2,weight=20,type=1,d1=2,d2={1,1},first=400},
            {id=3,weight=20,type=1,d1=4,d2={1,1},first=600},
            {id=4,weight=20,type=1,d1=8,d2={1,1},first=200},
            {id=5,weight=20,type=1,d1=1,d2={1,2},first=400},
            {id=6,weight=20,type=1,d1=2,d2={1,2},first=600},
            {id=7,weight=20,type=1,d1=4,d2={1,2},first=200},
            {id=8,weight=20,type=1,d1=8,d2={1,2},first=400},
            {id=9,weight=20,type=1,d1=1,d2={0,1},first=600},
            {id=10,weight=20,type=1,d1=2,d2={0,1},first=200},
            {id=11,weight=20,type=1,d1=4,d2={0,1},first=400},
            {id=12,weight=20,type=1,d1=8,d2={0,1},first=600},
            {id=13,weight=20,type=1,d1=1,d2={0,2},first=200},
            {id=14,weight=20,type=1,d1=2,d2={0,2},first=400},
            {id=15,weight=20,type=1,d1=4,d2={0,2},first=600},
            {id=16,weight=20,type=1,d1=8,d2={0,2},first=200},
            {id=17,weight=20,type=2,d1=1,d2=8,d3=0.2,first=400},
            {id=18,weight=20,type=2,d1=2,d2=1,d3=0.2,first=600},
            {id=19,weight=20,type=2,d1=4,d2=2,d3=0.2,first=200},
            {id=20,weight=20,type=2,d1=8,d2=4,d3=0.2,first=400},
            {id=21,weight=5,type=3,d1=2,d2={accuracy=0.2},first=600},
            {id=22,weight=5,type=3,d1=3,d2={accuracy=0.2},first=200},
            {id=23,weight=5,type=3,d1=5,d2={accuracy=0.2},first=400},
            {id=24,weight=5,type=3,d1=6,d2={accuracy=0.2},first=600},
            {id=25,weight=5,type=3,d1=2,d2={anticrit=0.2},first=200},
            {id=26,weight=5,type=3,d1=3,d2={anticrit=0.2},first=400},
            {id=27,weight=5,type=3,d1=5,d2={anticrit=0.2},first=600},
            {id=28,weight=5,type=3,d1=6,d2={anticrit=0.2},first=200},
            {id=29,weight=5,type=4,d1=1,first=400,specialhero={"h3"}},
            {id=30,weight=5,type=4,d1=2,first=600,specialhero={"h1"}},
            {id=31,weight=5,type=4,d1=3,first=200,specialhero={"h4"}},
            {id=32,weight=5,type=4,d1=4,first=400,specialhero={"h24"}},
            {id=33,weight=5,type=4,d1=5,first=600,specialhero={"h13"}},
            {id=34,weight=5,type=4,d1=6,first=200,specialhero={"h2","h25","h26"}},
        },
    },
    --跨服PVP
    --跨服初赛战斗获得积分和（armyNum队*robotNum场战斗所获得的积分总和，既用做排行又用作积分商店购买物品，存储时需要区分，排行的积分不可消耗），16强决赛不获得积分
    PVP2={
        --跨服初赛对战晋级人数（除去保送）
        winNum=14,
        --战力保送晋级人数（参加跨服初赛的玩家中外部战力最大的从上到下选出X个晋级）
        winRank=2,
        --设置部队数量
        armyNum=3,
        --跨服PVP随机镜像数量
        robotNum=5,
        --初赛胜利积分
        winPoint=240,
        --初赛失败积分
        lossPoint=200,
        --初赛生存率积分上限
        livePoint=120,
        --决赛点赞获得积分（只能获得1次）
        praisePoint=200,
        --配件继承比值
        succeedPercent=0.15,
        --报名截至时间(周六设置部队截至时间)
        joinTime=60900,
        --战斗结束时间(周六战报查看时间)
        overTime=72000,
        --决赛战报时间(周日第一轮战报查看时间)
        lastTime=43200,
        --决赛战报间隔时间(周日两轮轮战报放出时间间隔)
        intervalTime=3600,
        --镜像选择规则（range--战力区间（战力排序，这里填的是百分比，例如{a,b,c}，则分为大于0小于等于a;大于a小于等于b;大于b小于等于c;三个范围，相应抽取对应个数个镜像），num--对应战力区间随机镜像个数）
        robotChoice={
            range={0.33,0.66,1},
            num={2,2,1},
        },
        --坦克可选（tankNum--每队坦克上阵组数上限specialTank--固定坦克，choiceNum--随机坦克种类个数，tankPool--坦克随机池）
        tankChoice={
            tankNum=6,
            specialTank={"a10006","a10016","a10026","a10036","a10007","a10017","a10027","a10037","a10008","a10018","a10028","a10038"},
            choiceNum=18,
            tankPool={"a10044","a10054","a10064","a10074","a10083","a10094","a10114","a10124","a10134","a10144","a10164","a10045","a10075","a10084","a10095","a10135","a10145","a10165","a20054","a20114","a20154","a20055","a20065","a20115","a20125","a20155"},
        },
        --飞机可选（grade--飞机等级，skillId--飞机技能可选池）
        planeChoice={
            grade=1,
            planeId={"p1","p2","p3","p4"},
            skillId={"s1034","s1066","s1098","s1130","s1162","s1194","s1354","s1386"},
        },
        --AI可选（Ainum--每个阵型最大可上阵数量，AIgrade--AI等级，AIquality--AI等阶，AIskillGrade--AI技能等级，AI--AI可选池）
        AIchoice={
            AInum=3,
            AIgrade=20,
            AIquality=2,
            AIskillGrade=4,
            AI={"a17","a16","a15","a14","a13","a12","a11","a10","a9","a8","a7","a6"},
        },
        --将领可选（heroMax--每队将领上阵上限，heroNum--随机将领个数，heroStar--将领星级，heroGrade--将领等级，skillGrade--将领技能等级，specialHero--每期固定将领（全选），hero--将领池（随机heroNum个），heroAbility--将领属性）
        heroChoice={
            heroMax=6,
            heroNum=26,
            heroStar=5,
            heroGrade=70,
            skillGrade=20,
            specialHero={"h1","h2","h3","h24"},
            hero={"h4","h5","h6","h7","h8","h9","h10","h11","h12","h13","h14","h15","h16","h17","h18","h19","h20","h21","h22","h23","h25","h26","h27","h28","h29","h30","h31","h32","h33","h34","h35","h36","h37","h38","h39","h40","h51","h52","h53","h55","h56","h57","h81","h82","h59","h60","h67","h68"},
        },
        --军徽可选(equipId--军徽Id)
        equipChoice={
            equipId={"e102","e103","e104","e122"},
        },
    },
    --排行榜奖励（跨服16强决赛胜利战斗不获得积分，根据排行奖励积分，用作积分商店购买物品）
    rankReward={
        {range={1,1},point=5000,reward={e={{p7=1,index=4}},p={{p5031=1,index=2},{p5028=1,index=3},{p4971=30,index=5},{p4970=50,index=6}},al={{i10=1,index=1}}}},
        {range={2,2},point=4000,reward={e={{p11=8,index=4}},p={{p5031=1,index=2},{p5029=1,index=3},{p4971=25,index=5},{p4970=40,index=6}},al={{i10=1,index=1}}}},
        {range={3,3},point=3500,reward={e={{p11=6,index=4}},p={{p5031=1,index=2},{p5029=1,index=3},{p4971=20,index=5},{p4970=35,index=6}},al={{i10=1,index=1}}}},
        {range={4,4},point=2500,reward={e={{p11=4,index=3}},p={{p5031=1,index=1},{p5029=1,index=2},{p4971=15,index=4},{p4970=30,index=5}}}},
        {range={5,8},point=1500,reward={e={{p11=2,index=3}},p={{p5032=1,index=1},{p5030=1,index=2},{p4971=10,index=4},{p4970=20,index=5}}}},
        {range={9,16},point=1000,reward={e={{p11=1,index=3}},p={{p5032=1,index=1},{p5030=1,index=2},{p4971=5,index=4},{p4970=20,index=5}}}},
    },
    --积分商店(id--商品序号，item--商品，cost--消耗积分，num--购买上限，type--购买类型（1--通用，2--参加决赛可买，3--进入16强可买）)
    pointShop={
        {id=1,item={p={p4840=1,index=1}},cost=900,num=2,type=1},
        {id=2,item={p={p4840=1,index=2}},cost=900,num=3,type=2},
        {id=3,item={p={p4840=1,index=3}},cost=900,num=5,type=3},
        {id=4,item={p={p4841=1,index=4}},cost=1000,num=2,type=1},
        {id=5,item={p={p4841=1,index=5}},cost=1000,num=3,type=2},
        {id=6,item={p={p4841=1,index=6}},cost=1000,num=5,type=3},
        {id=7,item={p={p3360=1,index=7}},cost=4500,num=1,type=1},
        {id=8,item={p={p3369=1,index=8}},cost=6000,num=1,type=2},
        {id=9,item={p={p3369=1,index=9}},cost=6000,num=1,type=3},
        {id=10,item={p={p3346=1,index=10}},cost=2000,num=1,type=1},
        {id=11,item={p={p3346=1,index=11}},cost=2000,num=2,type=2},
        {id=12,item={p={p3346=1,index=12}},cost=2000,num=2,type=3},
        {id=13,item={p={p3345=1,index=13}},cost=1400,num=3,type=1},
        {id=14,item={p={p3340=1,index=14}},cost=1000,num=3,type=1},
        {id=15,item={p={p3336=1,index=15}},cost=1000,num=3,type=1},
        {id=16,item={p={p4957=1,index=16}},cost=1000,num=2,type=1},
        {id=17,item={p={p4604=1,index=17}},cost=4000,num=1,type=2},
        {id=18,item={p={p4604=1,index=18}},cost=4000,num=1,type=3},
        {id=19,item={p={p5027=5,index=19}},cost=300,num=15,type=1},
        {id=20,item={p={p4990=5,index=20}},cost=500,num=15,type=2},
        {id=21,item={p={p4991=5,index=21}},cost=750,num=10,type=3},
        {id=22,item={p={p282=1,index=22}},cost=50,num=20,type=1},
        {id=23,item={p={p283=1,index=23}},cost=200,num=10,type=2},
        {id=24,item={p={p283=1,index=24}},cost=200,num=10,type=3},
        {id=25,item={p={p275=5,index=25}},cost=240,num=10,type=1},
        {id=26,item={p={p277=10,index=26}},cost=50,num=10,type=1},
        {id=27,item={p={p276=5,index=27}},cost=120,num=10,type=1},
        {id=28,item={p={p279=5,index=28}},cost=120,num=10,type=3},
        {id=29,item={p={p278=1,index=29}},cost=150,num=10,type=3},
        {id=30,item={p={p4970=1,index=30}},cost=50,num=30,type=1},
        {id=31,item={p={p4944=1,index=31}},cost=100,num=10,type=1},
        {id=32,item={p={p877=5,index=32}},cost=50,num=10,type=2},
        {id=33,item={p={p878=5,index=33}},cost=50,num=10,type=2},
        {id=34,item={p={p1358=5,index=34}},cost=50,num=10,type=3},
    },
}

return serverWarExerciseCfg 
