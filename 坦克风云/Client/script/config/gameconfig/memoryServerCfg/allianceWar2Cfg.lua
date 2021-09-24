allianceWar2Cfg={ -- 军团战 2016年 超豪华萌萌加强版本
    minRegistrationFee=500, --军团报名花费
    cdTime=120, --战斗复活时间(s)
    winPointMax=500000, --胜利所需胜利点数
    maxBattleTime=1800, --战斗最大战斗时间
    prepareTime=600, --开战前的准备阶段时长
    mvpDonate=200, --MVP 贡献加成
    winDonate=150, --胜利 贡献结算
    failDonate=50, --失败 贡献结算
    winPointToDonate=0.005, --积分换成贡献
    maxTankDonate=1000, --最大击毁坦克贡献获得
    tankeTransRate=100, --坦克消耗兑换的比例
    tankeDonateFix=0.1, --坦克贡献的比例修正
    startWarTime={{20,0},{20,0},{20,0},{20,0}},
    winExp = {500,300},   -- 胜利获得的军团经验
    failExp = {500,300},   -- 失败获得的军团经验
    resourceAddition={200,100,200,200},    --  占领 优化版资源加成
    openDate=1,    --  开启的单双天
    signUpTime={     --  报名时间
        start={9,0},--报名的开始时间 {时,分}
        finish={14,0},--报名的结束时间 {时,分}
    },
    stronghold={ --战斗场景--城池相关配置
        h1={icon="serverWarLocalCity4.png",name="hold_name1",winPoint=40,x=187,y=601,lanform={1,1}},
        h2={icon="serverWarLocalCity4.png",name="hold_name2",winPoint=45,x=525,y=406,lanform={2,2}},
        h3={icon="serverWarLocalCity4.png",name="hold_name3",winPoint=50,x=238,y=240,lanform={1,1}},
        h4={icon="serverWarLocalCity4.png",name="hold_name4",winPoint=60,x=133,y=339,lanform={2,2}},
        h5={icon="serverWarLocalCity3.png",name="hold_name5",winPoint=70,x=432,y=251,lanform={1,1}},
        h6={icon="serverWarLocalCity3.png",name="hold_name6",winPoint=75,x=85,y=474,lanform={2,3}},
        h7={icon="serverWarLocalCity3.png",name="hold_name7",winPoint=80,x=346,y=600,lanform={1,1}},
        h8={icon="serverWarLocalCity3.png",name="hold_name8",winPoint=90,x=565,y=588,lanform={2,2}},
        h9={icon="serverWarLocalCity2.png",name="hold_name9",winPoint=100,x=319,y=422,lanform={3,3}},
    },
    city={ --报名场景--战场相关配置
        {id=1,icon="serverWarLocalCity10.png",name="allianceWar_cityName_1",type=1,area=1,pos={151,385}},
        {id=2,icon="serverWarLocalCity1.png",name="allianceWar_cityName_7",type=2,area=1,pos={388,324}},
    },
    buffSkill={ --战场buff--科技配置
        b1={
            icon="WarBuffSmeltExpert.png",name="buff1Name",des="warbuffdes1",
            maxLv=10,cost=8,per=0.05,donate=5,probability={100,95,90,85,80,75,70,65,60,55}
        },
        b2={
            icon="WarBuffCommander.png",name="buff2Name",des="warbuffdes2",
            maxLv=10,cost=8,per=0.03,donate=5,probability={100,95,90,85,80,75,70,65,60,55}
        },
        b3={
            icon="WarBuffNetget.png",name="buff3Name",des="warbuffdes3",
            maxLv=5,cost=18,per=0.1,donate=10,probability={100,95,90,85,80}
        },
        b4={
            icon="WarBuffStatistician.png",name="buff4Name",des="warbuffdes4",
            maxLv=5,cost=18,per=0.05,donate=10,probability={100,95,90,85,80}
        },
    },
    task={ -- 任务目标参数  和 前台描述
        t1={1,"taskDes1"},
        t2={5000,"taskDes2"},
        t3={1,"taskDes3"},
        t4={5,"taskDes3"},
        t5={1,"taskDes5"},
        t6={5,"taskDes5"},
        t7={3,"taskDes7"},
    },
    taskreward={ -- 任务奖励
        { -- NB 场的奖励
            t1={{p={{p3326=10}}},{props_p3326=10}},
            t2={{p={{p20=5}}},{props_p20=5}},
            t3={{p={{p19=30}}},{props_p19=30}},
            t4={{p={{p447=5}}},{props_p447=5}},
            t5={{p={{p601=15}}},{props_p601=15}},
            t6={{p={{p4=3}}},{props_p4=3}},
            t7={{p={{p982=10}}},{props_p982=10}},
        },
        { -- SB 场的奖励
            t1={{p={{p3326=5}}},{props_p3326=5}},
            t2={{p={{p20=3}}},{props_p20=3}},
            t3={{p={{p19=15}}},{props_p19=15}},
            t4={{p={{p447=3}}},{props_p447=3}},
            t5={{p={{p601=10}}},{props_p601=10}},
            t6={{p={{p4=1}}},{props_p4=1}},
            t7={{p={{p982=5}}},{props_p982=5}},
        },
    },
    reward1={reward={e={{p4=1500,index=3},{p6=5,index=4}},p={{p975=0,index=1},{p448=1,index=2}}},serverReward={props_p975=0,props_p448=1,accessory_p4=1500,accessory_p6=5}},
    reward2={reward={e={{p4=800,index=3},{p6=3,index=4}},p={{p976=0,index=1},{p447=3,index=2}}},serverReward={props_p976=0,props_p447=3,accessory_p4=800,accessory_p6=3}},
    activeReward1={reward={p={{p982=10,index=1},{p447=5,index=2},{p20=5,index=3},{p19=15,index=4}}}},
    activeReward2={reward={p={{p982=5,index=1},{p447=3,index=2},{p20=3,index=3},{p19=5,index=4}}}},
}

