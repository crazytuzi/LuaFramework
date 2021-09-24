allianceWarCfg={
    minRegistrationFee=1000,		-- 报名 最少花费
    startWarTime={g1={10,20}},
    numberOfBattle=15,			-- 最大 上阵人数
    cdTime=120,			-- 战斗 冷却时间 120秒 （2分钟）
    stronghold={
    h1={icon="CheckPointIcon1.png",winPoint=40,name="hold_name1",x=147,y=607},
    h2={icon="CheckPointIcon1.png",winPoint=40,name="hold_name2",x=525,y=406},
    h3={icon="CheckPointIcon1.png",winPoint=40,name="hold_name3",x=238,y=240},
    h4={icon="CheckPointIcon1.png",winPoint=40,name="hold_name4",x=133,y=365},
    h5={icon="CheckPointIcon3.png",winPoint=70,name="hold_name5",x=432,y=251},
    h6={icon="CheckPointIcon3.png",winPoint=70,name="hold_name6",x=85,y=500},
    h7={icon="CheckPointIcon3.png",winPoint=70,name="hold_name7",x=346,y=606},
    h8={icon="CheckPointIcon3.png",winPoint=70,name="hold_name8",x=565,y=588},
    h9={icon="CheckPointIcon6.png",winPoint=100,name="hold_name9",x=319,y=448},
    },
    winPointMax=500000,		--  胜利所需胜利点数 50 万
    warTime=1800,			--  战斗最大战斗时间 30 分钟
    buffSkill={
    b1={maxLv=10,cost=8,per=0.05,probability={1,0.95,0.9,0.85,0.8,0.75,0.7,0.65,0.6,0.55},donate=3,icon="WarBuffSmeltExpert.png",name="buff1Name",des="warbuffdes1"},
    b2={maxLv=10,cost=8,per=0.03,probability={1,0.95,0.9,0.85,0.8,0.75,0.7,0.65,0.6,0.55},donate=3,icon="WarBuffCommander.png",name="buff2Name",des="warbuffdes2"},
    b3={maxLv=5,cost=18,per=0.10,probability={1,0.95,0.9,0.85,0.8},donate=6,icon="WarBuffNetget.png",name="buff3Name",des="warbuffdes3"},
    b4={maxLv=5,cost=18,per=0.05,probability={1,0.95,0.9,0.85,0.8},donate=6,icon="WarBuffStatistician.png",name="buff4Name",des="warbuffdes4"},
    },
    --开战前的准备进场阶段的时长, 单位: 秒
    prepareTime=600,
    --最长战斗时间, 单位: 秒
    maxBattleTime=1800,
    --各个城市的信息
    --id 城市的唯一标示
    --area 城市属于东线还是西线
    --pos 城市在面板地图上的坐标
    --startTime 城市开战的时间
    --type 是大城市还是小城市, 2是大城市, 1是小城市
    city=
    {
        {id=1,area=1,pos={170,330},name="allianceWar_cityName_1",type=2},
        {id=2,area=1,pos={430,400},name="allianceWar_cityName_2",type=1},
        {id=3,area=1,pos={450,170},name="allianceWar_cityName_3",type=1},
        {id=4,area=1,pos={100,100},name="allianceWar_cityName_4",type=2},
        {id=5,area=2,pos={170,330},name="allianceWar_cityName_5",type=1},
        {id=6,area=2,pos={430,400},name="allianceWar_cityName_6",type=2},
        {id=7,area=2,pos={450,170},name="allianceWar_cityName_7",type=1},
        {id=8,area=2,pos={100,100},name="allianceWar_cityName_8",type=2},
    },

    mvpDonate=200,	-- MVP 贡献加成
    winDonate=150,		-- 胜利 贡献结算
    failDonate=50,		-- 失败 贡献结算
    occupiedRes=100,	-- 占领 资源加成
    resourceAddition={200,100,100,200,100,200,100,200},    --  占领 优化版资源加成
    winPointToDonate = 0.005, -- 积分换成贡献
    tankDonate={a10001=0.002,a10002=0.004,a10003=0.008,a10004=0.015,a10005=0.03,a10006=0.06,a10011=0.002,a10012=0.004,a10013=0.008,a10014=0.015,a10015=0.03,a10016=0.06,a10021=0.002,a10022=0.004,a10023=0.008,a10024=0.015,a10025=0.03,a10026=0.06,a10031=0.002,a10032=0.004,a10033=0.008,a10034=0.015,a10035=0.03,a10036=0.06,a10043=0.045,a10044=0.07,a10053=0.05,a10063=0.045,a10073=0.05,a10082=0.05,a10093=0.04,a10113=0.05,a10123=0.05}

}

--stronghold 据点配置表 h1:据点1 -据点9 icon:图片名称  x,y 为前台显示坐标 winPoint每秒胜利点数(后台用到)
--startWarTime  g1战场 战争开始时间10点20 g1-g4 四个战场
--buffSkill buff配置 b1-b4 maxLv:buff最大等级 cost:花费金币 per:每级增加的百分比 probability:升每一级的成功几率 donate:buff提供的每级的贡献


-- winPointToDonate = 0.005,
