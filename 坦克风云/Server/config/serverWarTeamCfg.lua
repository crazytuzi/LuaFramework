local serverWarTeamCfg={
    jointime=24,  --报名前，加入军团不足24小时的玩家无法参加
    joinlv=30,  --报名玩家等级要求
    
    numberOfBattle=99,  --军团最大上场人数
    sevbattleAlliance=8,  --每次参战军团数
    winPointMax=150000,  --胜利所需点数
    warTime=1500,  --战斗最大时长，单位（秒）
    militaryrank=50,  --积分明细50条
    tankeTransRate=25,  --1：25的消耗比例,足的部分向上取整
    
    --buff相关信息
    --maxLv:最大等级
    --cost:购买所需金币数
    --per:每级提供的buff加成值
    --probability:每级的升级成功概率
    --donate:积分加成
    buffSkill={
        b1={maxLv=10,cost=18,per=0.03,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffSmeltExpert.png",name="serverwarteam_buffName1",des="serverwarteam_buffDesc1"},
        b2={maxLv=10,cost=18,per=0.03,probability={100,95,90,85,80,75,70,65,60,55},donate=5,icon="WarBuffCommander.png",name="serverwarteam_buffName2",des="serverwarteam_buffDesc2"},
        b3={maxLv=5,cost=28,per=0.1,probability={100,95,90,85,80},donate=5,icon="WarBuffNetget.png",name="serverwarteam_buffName3",des="serverwarteam_buffDesc3"},
        b4={maxLv=5,cost=28,per=0.1,probability={100,95,90,85,80},donate=5,icon="WarBuffStatistician.png",name="serverwarteam_buffName4",des="serverwarteam_buffDesc4"},
    },
    
    --加速的buff
    speedBuff={
        cost={10,20,40,80},  --花费
        per=0.5,  --加速效果
        minsec=1,  --能购买加速的最小秒数
    },
    
    startBattleTs={{19,0},{19,30},{20,0},{20,30}},  --开战时间
    --对应每天每场战斗的开始时间索引
    startBattleIndex={{1,2,3,4},{1,2},{1}},
    --不能献花的时间, 每个元素表示每一轮, 再下面第一个元素表示开战前献花的截止时间, 第二个元素表示每天最后一场战斗结束后
    flowerLimit={{{18,50},{20,55}},{{18,50},{19,55}},{{18,50},{19,25}}},
    --匹配列表
    matchList1={{1,8},{4,5},{2,7},{3,6}},
    matchList2={{1,8},{3,6},{5,4},{7,2}},
    produceRank={{5,8},{3,4},{1,2}},  --轮次对应出现的排名
    
    --押注分两个档次(最后3轮筹码加大)
    betStyle4Round={1,1,2},
    betTs_a={19,25},
    betTs_b={20,25},
    --押注类型1
    betGem_1={0,20,100,150},  --追加金币消耗
    winner_1={10,30,100,200},  --胜利积分获得（鲜花获得）
    failer_1={5,15,50,100},  --失败积分获得
    --押注类型2
    betGem_2={0,40,200,300},  --追加金币消耗
    winner_2={20,60,200,400},  --胜利积分获得（鲜花获得）
    failer_2={10,30,100,200},  --失败积分获得
    
    winDonate=100,  --战斗胜利贡献
    loseDonate=30,  --战斗失败贡献
    winPoint=6000,  --战争胜利总积分
    losePoint=2000,  --战争失败总积分
    personalWinPoint=200,  --胜利积分加成
    personalLosePoint=100,  --失败积分加成
    --排名奖励积分
    rankReward={
        {range={1,1},point=500},
        {range={2,2},point=300},
        {range={3,4},point=250},
        {range={5,8},point=200},
    },
    --前两名对应的全服奖励
    severReward={
        {reward={u={{r1=20000000},{r2=20000000},{r3=20000000}}},serverReward={userinfo_r1=20000000,userinfo_r2=20000000,userinfo_r3=20000000}},
        {reward={u={{r1=10000000},{r2=10000000},{r3=10000000}}},serverReward={userinfo_r1=10000000,userinfo_r2=10000000,userinfo_r3=10000000}},
    },
    
    --pShop是普通商店
    --aShop是参赛商店
    pShopItems={
        i1={id="i1",buynum=3,price=150,reward={e={{p11=1}}},serverReward={accessory_p11=1}},
        i2={id="i2",buynum=2,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
        i3={id="i3",buynum=3,price=250,reward={p={{p354=1}}},serverReward={props_p354=1}},
        i4={id="i4",buynum=3,price=225,reward={p={{p362=1}}},serverReward={props_p362=1}},
        i5={id="i5",buynum=3,price=250,reward={p={{p370=1}}},serverReward={props_p370=1}},
        i6={id="i6",buynum=3,price=275,reward={p={{p378=1}}},serverReward={props_p378=1}},
        i7={id="i7",buynum=3,price=300,reward={p={{p269=1}}},serverReward={props_p269=1}},
        i8={id="i8",buynum=3,price=50,reward={p={{p268=1}}},serverReward={props_p268=1}},
        i9={id="i9",buynum=5,price=20,reward={p={{p20=1}}},serverReward={props_p20=1}},
        i10={id="i10",buynum=10,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
        i11={id="i11",buynum=10,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
        i12={id="i12",buynum=10,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
        i13={id="i13",buynum=10,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
        i14={id="i14",buynum=50,price=40,reward={p={{p275=1}}},serverReward={props_p275=1}},
        i15={id="i15",buynum=50,price=40,reward={p={{p276=2}}},serverReward={props_p276=2}},
        i16={id="i16",buynum=50,price=40,reward={p={{p277=5}}},serverReward={props_p277=5}},
    },
    pShopItems2={
        i101={id="i1",buynum=2,price=440,reward={p={{p5066=1}}},serverReward={props_p5066=1}},
        i102={id="i2",buynum=2,price=400,reward={p={{p5074=1}}},serverReward={props_p5074=1}},
        i103={id="i3",buynum=2,price=440,reward={p={{p5082=1}}},serverReward={props_p5082=1}},
        i104={id="i4",buynum=2,price=490,reward={p={{p5090=1}}},serverReward={props_p5090=1}},
        i105={id="i5",buynum=3,price=150,reward={e={{p11=1}}},serverReward={accessory_p11=1}},
        i106={id="i6",buynum=2,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
        i107={id="i7",buynum=3,price=250,reward={p={{p354=1}}},serverReward={props_p354=1}},
        i108={id="i8",buynum=3,price=225,reward={p={{p362=1}}},serverReward={props_p362=1}},
        i109={id="i9",buynum=3,price=250,reward={p={{p370=1}}},serverReward={props_p370=1}},
        i110={id="i10",buynum=3,price=275,reward={p={{p378=1}}},serverReward={props_p378=1}},
        i111={id="i11",buynum=3,price=300,reward={p={{p269=1}}},serverReward={props_p269=1}},
        i112={id="i12",buynum=3,price=50,reward={p={{p268=1}}},serverReward={props_p268=1}},
        i113={id="i13",buynum=5,price=20,reward={p={{p20=1}}},serverReward={props_p20=1}},
        i114={id="i14",buynum=10,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
        i115={id="i15",buynum=10,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
        i116={id="i16",buynum=10,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
        i117={id="i17",buynum=10,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
        i118={id="i18",buynum=50,price=40,reward={p={{p275=1}}},serverReward={props_p275=1}},
        i119={id="i19",buynum=50,price=40,reward={p={{p276=2}}},serverReward={props_p276=2}},
        i120={id="i20",buynum=50,price=40,reward={p={{p277=5}}},serverReward={props_p277=5}},
    },

    aShopItems={
        a1={id="a1",buynum=1,price=1500,reward={p={{p804=1}}},serverReward={props_p804=1}},
        a2={id="a2",buynum=5,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
        a3={id="a3",buynum=5,price=250,reward={p={{p354=1}}},serverReward={props_p354=1}},
        a4={id="a4",buynum=5,price=225,reward={p={{p362=1}}},serverReward={props_p362=1}},
        a5={id="a5",buynum=5,price=250,reward={p={{p370=1}}},serverReward={props_p370=1}},
        a6={id="a6",buynum=5,price=275,reward={p={{p378=1}}},serverReward={props_p378=1}},
        a7={id="a7",buynum=1,price=1000,reward={p={{p270=1}}},serverReward={props_p270=1}},
        a8={id="a8",buynum=1,price=500,reward={p={{p90=1}}},serverReward={props_p90=1}},
    },
    aShopItems2={
        a101={id="a1",buynum=3,price=440,reward={p={{p5066=1}}},serverReward={props_p5066=1}},
        a102={id="a2",buynum=3,price=400,reward={p={{p5074=1}}},serverReward={props_p5074=1}},
        a103={id="a3",buynum=3,price=440,reward={p={{p5082=1}}},serverReward={props_p5082=1}},
        a104={id="a4",buynum=3,price=490,reward={p={{p5090=1}}},serverReward={props_p5090=1}},
        a105={id="a5",buynum=1,price=1500,reward={p={{p804=1}}},serverReward={props_p804=1}},
        a106={id="a6",buynum=5,price=600,reward={p={{p230=1}}},serverReward={props_p230=1}},
        a107={id="a7",buynum=5,price=250,reward={p={{p354=1}}},serverReward={props_p354=1}},
        a108={id="a8",buynum=5,price=225,reward={p={{p362=1}}},serverReward={props_p362=1}},
        a109={id="a9",buynum=5,price=250,reward={p={{p370=1}}},serverReward={props_p370=1}},
        a110={id="a10",buynum=5,price=275,reward={p={{p378=1}}},serverReward={props_p378=1}},
        a111={id="a11",buynum=1,price=1000,reward={p={{p270=1}}},serverReward={props_p270=1}},
        a112={id="a12",buynum=1,price=500,reward={p={{p90=1}}},serverReward={props_p90=1}},
    },

    --开战前可以设置部队的截止时间
    setTroopsLimit=600,
    --开战前5分钟可以进场买buff但是不能移动
    enterBattleTime=300,
    --开战前有几天预热时间，不能操作
    preparetime=2,
    --开战前准备时间，可以报名，上阵，设置部队，资金
    signuptime=1,
    --结束战斗后有几天购买时间
    shoppingtime=3,
    --持续时间+领奖时间（不算战前准备和报名）
    durationtime=6,
    --服内赛军团数（没用到）
    serverAlliance=8,
    --报名,设置上阵成员截止时间，开战的第一天，preparetime+signuptime+1
    applyedtime={12,0},
    --设置部队的截止时间
    settroopstime={18,50},
    
    --基地耐久
    baseBlood=500,
    --攻打1次损失
    lossBlood=20,
    --部队设置间隔，单位（秒）
    settingBattleMemLimit=60,
    --到达捐献次数给的部队总数
    maxBaseFleetNum=15,
    --基地捐献出兵数量
    baseDonateNum={1,2,3,4,5},
    --基地捐献出兵次数
    baseDonateTime={5,20,50,100,200},
    
    --基地部队信息
    baseFleetInfo={
        [60]={"a10005","a10015","a10025","a10035"},
        [70]={"a10006","a10016","a10026","a10036"},
        [80]={"a10074","a10054","a10044","a10083"},
        [90]={"a10006","a10016","a10026","a10036"},
        [100]={"a10007","a10017","a10027","a10037"},
        [110]={"a10007","a10017","a10027","a10037"},
    },
    baseFleetAttribute={
        [60]={skill={s101=60,s102=60,s103=60,s104=60},attributeUp={attack=3,life=3,accurate=1,avoid=1,critical=1,decritical=1}},
        [70]={skill={s101=70,s102=70,s103=70,s104=70},attributeUp={attack=4,life=4,accurate=1,avoid=1,critical=1,decritical=1}},
        [80]={skill={s101=80,s102=80,s103=80,s104=80},attributeUp={attack=5,life=5,accurate=1,avoid=1,critical=1,decritical=1}},
        [90]={skill={s101=80,s102=80,s103=80,s104=80},attributeUp={attack=5,life=5,accurate=1,avoid=1,critical=1,decritical=1}},
        [100]={skill={s101=90,s102=90,s103=90,s104=90},attributeUp={attack=5,life=5,accurate=1,avoid=1,critical=1,decritical=1}},
        [110]={skill={s101=100,s102=100,s103=100,s104=100},attributeUp={attack=6,life=6,accurate=1,avoid=1,critical=1,decritical=1}},
    },

    --80 90用的与70一致而不是坦克的,因为那批战舰还没出,测试时注意是否有问题
    --部队数量
    --Num =int (unLockLevel * unLockLevel / 4 )
    
    --基地捐献资源,q:前台 h:后台
    baseDonateRes={q={u={{r4=2000000,index=1}}},h={r4=2000000}},
    --基地捐献金币
    baseDonateGem=15,
    --小路出现时间，开战之后n秒钟之后才出现
    countryRoadTime=300,
    --在战斗中刷新整体数据的时间间隔
    battleRefreshTime=60,
    --死亡复活时间
    reviveTime=40,
    --死亡复活价格
    reviveCost=100,
    --部队设置限制没有金币设置
    settingTroopsLimit=60,
    --默认补充配置
    adminTroops={'a10001',1},
}


return serverWarTeamCfg
