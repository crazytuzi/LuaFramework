rebelCfg={
    expireTs=14400,    --叛军持续时间，单位（秒）
    refreshTime=3600,    --叛军刷新时间，单位（秒）
    rebelNum=12,    --每次刷新叛军数量
    
    levelExp={10000,30000,60000,100000,200000,300000,400000,600000,800000,1000000,1200000},    --世界经验对应叛军等级
    levelRange={-2,2},    --叛军等级分布范围 例：世界经验对应等级为5，则叛军等级为1级（5-5）到10级（5+5）
    maxAddExp=2000,    --击杀叛军增加世界经验 公式：maxAddExp*叛军剩余时间/expireTs（叛军持续时间）  向上取整，最少增加1经验
    reduceExp=100,  --叛军未被击杀减少世界经验
    
    overdue=86400,    --击杀奖励过期时间（奖励中心）, 单位：秒
    rewardLimit=20,    --每个军团每日获得叛军击杀奖励次数上限
    overReward={props_p2=1},   --超过每日次数(rewardLimit)上限后,击杀叛军，军团成员获得奖励
    
    vipBuyLimit={3,5,8,10,15,20,25,30,35,40,50,55,60,65},   --VIP可购买体力点数 vip0可购买1点体力，依次后推
    needMoney={20,20,40,40,40,60,60,60,80,80,80,80,100,100,100,100,120,120,120,120,120,140,140,140,140,140,160,160,160,160,160,180,180,180,180,180,200,200,200,200,200,200,200,200,200,200,200,200,200,200,220,220,220,220,220,220,220,220,220,220,240,240,240,240,240},   --每点体力所需金币，第一点需要5金币，依次后推
    recoverTime=7200,    --每点体力恢复时间，单位（秒）
    energyMax=5,    --玩家体力上限
    attackConsume1=1,    --普通攻击消耗点数
    attackConsume2=3,    --高级攻击消耗点数
    highAttack=3,    --高级攻击属性翻倍倍数，只增加攻击属性
    
    attackBuff=0.05,    --连续进攻BUFF，只增加攻击属性
    buffTime=3600,    --BUFF持续时间，单位（秒）
    damageRatio=0.01,    --战损比例
    startDamage=0.01,    --每次开场造成伤害比例
    
    troops={     --部队配置
        tanklv={1,4,8},     --根据叛军等级选择坦克方案号
        
        tank={   --坦克方案
            [1]={    --方案号[1]  {{},{}} ,第一个{}中的坦克编号，用于替换奖励中的 tank1,tank2,tank3  第二个{}中为坦克方案类型
                {{"troops_a10005"},{"a10005","a10005","a10005","a10015","a10025","a10035"}},
                {{"troops_a10015"},{"a10015","a10005","a10015","a10035","a10015","a10025"}},
                {{"troops_a10025"},{"a10025","a10025","a10005","a10025","a10035","a10015"}},
                {{"troops_a10035"},{"a10005","a10025","a10035","a10015","a10035","a10035"}},
            },
            [2]={
                {{"troops_a10005"},{"a10005","a10005","a10025","a10015","a10005","a10035"}},
                {{"troops_a10015"},{"a10005","a10025","a10015","a10015","a10035","a10015"}},
                {{"troops_a10025"},{"a10005","a10025","a10025","a10035","a10025","a10035"}},
                {{"troops_a10035"},{"a10005","a10005","a10025","a10035","a10035","a10035"}},
            },
            [3]={
                {{"troops_a10073"},{"a10074","a10074","a10043","a10133","a10074","a10082"}},
                {{"troops_a10053"},{"a10073","a10043","a10054","a10054","a10082","a10054"}},
                {{"troops_a10043"},{"a10093","a10044","a10044","a20153","a10044","a10143"}},
                {{"troops_a10082"},{"a10123","a10073","a10063","a10083","a10083","a10083"}},
                {{"troops_a10123"},{"a10124","a10124","a10124","a10043","a10143","a20153"}},
                {{"troops_a10113"},{"a10093","a10133","a10123","a10114","a10114","a10114"}},
                {{"troops_a20153"},{"a10043","a10073","a20154","a10143","a20154","a20154"}},
                {{"troops_a10133"},{"a10093","a10073","a10134","a10134","a10134","a10063"}},
                {{"troops_a10093"},{"a10094","a10094","a10094","a10143","a10113","a10082"}},
                {{"troops_a10143"},{"a10073","a10144","a10093","a10144","a10144","a10053"}},
                {{"troops_a10063"},{"a10123","a10093","a10064","a20153","a10064","a10064"}},
                {{"troops_a10163"},{"a10123","a10164","a10063","a10164","a10082","a10164"}},
            },
        },
        
        tankIcon={   --前台坦克图标，用于地图上叛军显示
            [1]={
                "a10005",
                "a10015",
                "a10025",
                "a10035",
            },
            [2]={
                "a10005",
                "a10015",
                "a10025",
                "a10035",
            },
            [3]={
                "a10073",
                "a10053",
                "a10043",
                "a10082",
                "a10123",
                "a10113",
                "a20153",
                "a10133",
                "a10093",
                "a10143",
                "a10063",
                "a10163",
            },
        },
        
        showList={   --前台奖励显示，对应每个等级的叛军       tank1,tank2,tank3通过坦克方案中的第一个{}中内容替换
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p19=1,index=4},{p21=1,index=5},{p22=1,index=6},{p23=1,index=7},{p24=1,index=8},{p25=1,index=9}}},
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p19=1,index=4},{p21=1,index=5},{p22=1,index=6},{p23=1,index=7},{p24=1,index=8},{p25=1,index=9}}},
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p19=1,index=4},{p21=1,index=5},{p22=1,index=6},{p23=1,index=7},{p24=1,index=8},{p25=1,index=9}}},
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=1,index=6},{p27=1,index=7},{p28=1,index=8},{p29=1,index=9},{p30=1,index=10}}},
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=1,index=6},{p27=1,index=7},{p28=1,index=8},{p29=1,index=9},{p30=1,index=10}}},
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=1,index=6},{p27=1,index=7},{p28=1,index=8},{p29=1,index=9},{p30=1,index=10}}},
            {o={{tank1=1,index=1}},p={{p446=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=1,index=6},{p27=1,index=7},{p28=1,index=8},{p29=1,index=9},{p30=1,index=10}}},
            {o={{tank1=1,index=1}},p={{p447=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=2,index=6},{p27=2,index=7},{p28=2,index=8},{p29=2,index=9},{p30=2,index=10}}},
            {o={{tank1=1,index=1}},p={{p447=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=2,index=6},{p27=2,index=7},{p28=2,index=8},{p29=2,index=9},{p30=2,index=10}}},
            {o={{tank1=1,index=1}},p={{p447=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=2,index=6},{p27=2,index=7},{p28=2,index=8},{p29=2,index=9},{p30=2,index=10}}},
            {o={{tank1=1,index=1}},p={{p447=1,index=2},{p20=1,index=3},{p3302=1,index=4},{p601=1,index=5},{p26=2,index=6},{p27=2,index=7},{p28=2,index=8},{p29=2,index=9},{p30=2,index=10}}},
        },
        
        nums={   --等级对应的部队数量配置
            {300,300,300,300,300,300},
            {360,360,360,360,360,360},
            {440,440,440,440,440,440},
            {530,530,530,530,530,530},
            {640,640,640,640,640,640},
            {770,770,770,770,770,770},
            {930,930,930,930,930,930},
            {1120,1120,1120,1120,1120,1120},
            {1350,1350,1350,1350,1350,1350},
            {1620,1620,1620,1620,1620,1620},
            {1950,1950,1950,1950,1950,1950},
        },
        
        attributeUp2={   --等级对应的属性配置  加法加成
            {attack=0,life=0,accurate=0.65,avoid=0.65,critical=0.65,decritical=0.65,arp=10,armor=10},
            {attack=0,life=0,accurate=0.8,avoid=0.8,critical=0.8,decritical=0.8,arp=20,armor=20},
            {attack=0,life=0,accurate=0.95,avoid=0.95,critical=0.95,decritical=0.95,arp=30,armor=30},
            {attack=0,life=0,accurate=1.1,avoid=1.1,critical=1.1,decritical=1.1,arp=40,armor=40},
            {attack=0,life=0,accurate=1.25,avoid=1.25,critical=1.25,decritical=1.25,arp=50,armor=50},
            {attack=0,life=0,accurate=1.4,avoid=1.4,critical=1.4,decritical=1.4,arp=60,armor=60},
            {attack=0,life=0,accurate=1.55,avoid=1.55,critical=1.55,decritical=1.55,arp=70,armor=70},
            {attack=1,life=1,accurate=1.7,avoid=1.7,critical=1.7,decritical=1.7,arp=80,armor=80},
            {attack=2,life=2,accurate=1.85,avoid=1.85,critical=1.85,decritical=1.85,arp=90,armor=90},
            {attack=3,life=3,accurate=2,avoid=2,critical=2,decritical=2,arp=100,armor=100},
            {attack=4,life=4,accurate=2.15,avoid=2.15,critical=2.15,decritical=2.15,arp=110,armor=110},
        },
        
        attributeUp={   --乘法加成
            {attack=3,life=3,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=4.2,life=4.2,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=5.9,life=5.9,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=8.3,life=8.3,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=11.7,life=11.7,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=16.4,life=16.4,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=23,life=23,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=32.2,life=32.2,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=45.1,life=45.1,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=63.2,life=63.2,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
            {attack=88.5,life=88.5,accurate=1,avoid=1,critical=1,decritical=1,arp=1,armor=1},
        },
        
        tankPoint={1,1,1,1,1,1,1,1,1,1,1},    --每次攻打叛军，获得军功数量    击毁坦克数量*1
        
        scoutConsume={6020,12000,21000,26900,33700,42500,53500,67200,84400,106000,135000},    --叛军侦查消耗（消耗水晶）
        
        reward1={   --每次必获得奖励的奖池,不论玩家伤害多少，都要获得一次reward1  tank1,tank2,tank3通过坦克方案替换
            {
                {100},
                {10},
                {{"props_p19",1}},
            },
            {
                {100},
                {10},
                {{"props_p19",1}},
            },
            {
                {100},
                {10},
                {{"props_p19",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
            {
                {100},
                {10},
                {{"props_p601",1}},
            },
        },
        
        needDamage={     --玩家每次进攻伤害达到叛军血量10%，获得1次reward2，伤害达到25%，获得2次reward2,以此类推，伤害达到100%，获得4次reward2  各等级所需伤害和奖励次数不同
            {2,5,15,35,100},
            {2,5,15,35,100},
            {2,5,15,35,100},
            {2,5,15,30,65,100},
            {2,5,15,30,65,100},
            {2,5,15,30,65,100},
            {2,5,15,30,65,100},
            {2,5,15,25,50,75,100},
            {2,5,15,25,50,75,100},
            {2,5,15,25,50,75,100},
            {2,5,15,25,50,75,100},
        },
        
        reward2={   ----根据伤害获得奖励的奖池
            {
                {100},
                {10,5,5,5,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p19",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1}},
            },
            {
                {100},
                {10,5,5,5,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p19",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1}},
            },
            {
                {100},
                {10,5,5,5,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p19",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1}},
            },
            {
                {100},
                {10,9,5,1,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p3302",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1}},
            },
            {
                {100},
                {10,9,5,1,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p3302",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1}},
            },
            {
                {100},
                {10,9,5,1,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p3302",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1}},
            },
            {
                {100},
                {10,9,5,1,15,15,15,15,15},
                {{"tank1",1},{"props_p446",1},{"props_p20",1},{"props_p3302",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1}},
            },
            {
                {100},
                {11,7,5,2,15,15,15,15,15},
                {{"tank1",1},{"props_p447",1},{"props_p20",1},{"props_p3302",1},{"props_p26",2},{"props_p27",2},{"props_p28",2},{"props_p29",2},{"props_p30",2}},
            },
            {
                {100},
                {11,7,5,2,15,15,15,15,15},
                {{"tank1",1},{"props_p447",1},{"props_p20",1},{"props_p3302",1},{"props_p26",2},{"props_p27",2},{"props_p28",2},{"props_p29",2},{"props_p30",2}},
            },
            {
                {100},
                {11,7,5,2,15,15,15,15,15},
                {{"tank1",1},{"props_p447",1},{"props_p20",1},{"props_p3302",1},{"props_p26",2},{"props_p27",2},{"props_p28",2},{"props_p29",2},{"props_p30",2}},
            },
            {
                {100},
                {11,7,5,2,15,15,15,15,15},
                {{"tank1",1},{"props_p447",1},{"props_p20",1},{"props_p3302",1},{"props_p26",2},{"props_p27",2},{"props_p28",2},{"props_p29",2},{"props_p30",2}},
            },
        },
        
        reward3={   --击杀奖励
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
            {tank1=1},
        },
    },
}

