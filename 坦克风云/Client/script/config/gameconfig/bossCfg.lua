bossCfg={
    startLevel=20, --BOSS起始等级
    levelLimite=20, --功能开放等级
    opentime={{21,0},{21,30}}, --开放时间
    reBorn=28, --复活价格
    reBornTime=30, --复活时间
    paotou={1,3,2,4,6,5}, --炮头死亡顺序
    vipLimit=3, --VIP¼¸½âËø×Ô¶¯¹¥»÷
    inTime=600, --ÌáÇ°xÃë½øÈë½çÃæ
    ---海德拉等级奖励区间，配置海德拉等级下限，即{20,40,60}第一库是从20到39，第二库从40到59，第三库是60到无穷大
    rewardInterval={20,60,120,200,},
    ----溅射百分比
    rebound=0.15,

    buffSkill={
    b1={maxLv=10,cost={u={r4=500000}},serverCost={r4=500000},per=0.05,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffSmeltExpert.png",name="BossBattle_buffName1",des="BossBattle_buffDesc1"},
    b2={maxLv=10,cost={u={r4=500000}},serverCost={r4=500000},per=0.05,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffCommander.png",name="BossBattle_buffName2",des="BossBattle_buffDesc2"},
    b3={maxLv=10,cost={u={gems=18}},serverCost={gems=18},per=0.05,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffNetget.png",name="BossBattle_buffName3",des="BossBattle_buffDesc3"},
    b4={maxLv=10,cost={u={gems=8}},serverCost={gems=8},per=0.02,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffStatistician.png",name="BossBattle_buffName4",des="BossBattle_buffDesc4"},
    },
    specialBuffSkill={
        ----海德拉专属光环(grade--光环等级，tankType--上阵坦克类型数，buff1--光环增加属性类型1，tank1--属性1生效的坦克类型，buff2--光环增加属性类型2，tank2--属性2生效的坦克类型，icon--光环图标)
        {grade=1,tankType=1,buff1={crit=0.01},tank1={1,2,4,8},icon="hydraBuff1.png"},
        {grade=2,tankType=2,buff1={crit=0.05},tank1={2,8},buff2={atk={0.1}},tank2={{1,4}},icon="hydraBuff2.png"},
        {grade=3,tankType=3,buff1={crit=0.10},tank1={2},buff2={atk={0.1,0.2}},tank2={{4,8},{1}},icon="hydraBuff3.png"},
        {grade=4,tankType=4,buff1={crit=0.10},tank1={1,2,4,8},buff2={atk={0.1,0.2,0.3}},tank2={{2},{4,8},{1}},icon="hydraBuff4.png"},
    },





 --排名奖励
    rankReward={
        [1]={
            {range={1,1},{p={{p1356=1},{p818=8},{p448=3}}}},
            {range={2,2},{p={{p4984=2},{p818=5},{p448=2}}}},
            {range={3,3},{p={{p4984=1},{p819=5},{p447=8}}}},
            {range={4,5},{p={{p1365=8},{p819=3},{p447=5}}}},
            {range={6,20},{p={{p1365=5},{p819=2},{p447=3}}}},
        },
        [2]={
            {range={1,1},{p={{p4984=13},{p818=10},{p448=4}}}},
            {range={2,2},{p={{p4984=5},{p818=7},{p448=3}}}},
            {range={3,3},{p={{p4984=3},{p819=7},{p447=11}}}},
            {range={4,5},{p={{p4984=2},{p819=4},{p447=7}}}},
            {range={6,20},{p={{p1365=13},{p819=3},{p447=4}}}},
        },
        [3]={
            {range={1,1},{p={{p1356=6},{p818=15},{p448=5}}}},
            {range={2,2},{p={{p4984=12},{p818=10},{p448=4}}}},
            {range={3,3},{p={{p4984=6},{p819=10},{p447=14}}}},
            {range={4,5},{p={{p4984=5},{p819=6},{p447=9}}}},
            {range={6,20},{p={{p4984=3},{p819=4},{p447=5}}}},
        },
        [4]={
            {range={1,1},{p={{p1356=10},{p818=20},{p448=6}}}},
            {range={2,2},{p={{p1356=4},{p818=13},{p448=4}}}},
            {range={3,3},{p={{p4984=10},{p819=13},{p447=16}}}},
            {range={4,5},{p={{p4984=8},{p819=8},{p447=10}}}},
            {range={6,20},{p={{p4984=5},{p819=5},{p447=6}}}},
        },
    },

    attackHpreward={
         [1]={
            {p={{p3506=5},{p601=6},{p447=1}}},
            {p={{p3506=10},{p601=20},{p447=3}}},
        },
        [2]={
            {p={{p3506=6},{p601=10},{p447=2}}},
            {p={{p3506=12},{p601=25},{p447=5}}},
        },
        [3]={
            {p={{p3506=8},{p601=15},{p447=3}}},
            {p={{p3506=15},{p601=30},{p447=8}}},
        },
        [4]={
            {p={{p3506=10},{p601=20},{p447=4}}},
            {p={{p3506=20},{p601=40},{p447=10}}},
        },
    },
 --攻击占海德拉总血量百分比
    attacktolHprewardRate=2000,
    attacktolHpreward={
        [1]={
            {p={{p982=1},{p448=2}}},
            {p={{p981=1},{p447=1}}},
            {p={{p415=1},{p446=1}}},
        },
        [2]={
            {p={{p982=2},{p448=3}}},
            {p={{p981=2},{p447=2}}},
            {p={{p415=2},{p446=2}}},
        },
        [3]={
            {p={{p983=2},{p448=4}}},
            {p={{p982=2},{p447=3}}},
            {p={{p981=2},{p446=3}}},
        },
        [4]={
            {p={{p983=5},{p448=5}}},
            {p={{p982=5},{p447=4}}},
            {p={{p981=5},{p446=4}}},
        },
    },

    serverreward={
        rankReward={
            [1]={
                {range={1,1},{props_p1356=1,props_p818=8,props_p448=3}},
                {range={2,2},{props_p4984=2,props_p818=5,props_p448=2}},
                {range={3,3},{props_p4984=1,props_p819=5,props_p447=8}},
                {range={4,5},{props_p1365=8,props_p819=3,props_p447=5}},
                {range={6,20},{props_p1365=5,props_p819=2,props_p447=3}},
            },
            [2]={
                {range={1,1},{props_p4984=13,props_p818=10,props_p448=4}},
                {range={2,2},{props_p4984=5,props_p818=7,props_p448=3}},
                {range={3,3},{props_p4984=3,props_p819=7,props_p447=11}},
                {range={4,5},{props_p4984=2,props_p819=4,props_p447=7}},
                {range={6,20},{props_p1365=13,props_p819=3,props_p447=4}},
            },
            [3]={
                {range={1,1},{props_p1356=6,props_p818=15,props_p448=5}},
                {range={2,2},{props_p4984=12,props_p818=10,props_p448=4}},
                {range={3,3},{props_p4984=6,props_p819=10,props_p447=14}},
                {range={4,5},{props_p4984=5,props_p819=6,props_p447=9}},
                {range={6,20},{props_p4984=3,props_p819=4,props_p447=5}},
            },
            [4]={
                {range={1,1},{props_p1356=10,props_p818=20,props_p448=6}},
                {range={2,2},{props_p1356=4,props_p818=13,props_p448=4}},
                {range={3,3},{props_p4984=10,props_p819=13,props_p447=16}},
                {range={4,5},{props_p4984=8,props_p819=8,props_p447=10}},
                {range={6,20},{props_p4984=5,props_p819=5,props_p447=6}},
            },
        },

        attackHpreward={
            [1]={
                {props_p3506=5,props_p601=6,props_p447=1},
                {props_p3506=10,props_p601=20,props_p447=3},
            },
            [2]={
                {props_p3506=6,props_p601=10,props_p447=2},
                {props_p3506=12,props_p601=25,props_p447=5},
            },
            [3]={
                {props_p3506=8,props_p601=15,props_p447=3},
                {props_p3506=15,props_p601=30,props_p447=8},
            },
            [4]={
                {props_p3506=10,props_p601=20,props_p447=4},
                {props_p3506=20,props_p601=40,props_p447=10},
            },
        },

 --自己攻击占boss总血量的比的奖励
        attacktolHprewardRate=2000,
        attacktolHpreward={
            [1]={
                {props_p982=1,props_p448=2},
                {props_p981=1,props_p447=1},
                {props_p415=1,props_p446=1},
            },
            [2]={
                {props_p982=2,props_p448=3},
                {props_p981=2,props_p447=2},
                {props_p415=2,props_p446=2},
            },
            [3]={
                {props_p983=2,props_p448=4},
                {props_p982=2,props_p447=3},
                {props_p981=2,props_p446=3},
            },
            [4]={
                {props_p983=5,props_p448=5},
                {props_p982=5,props_p447=4},
                {props_p981=5,props_p446=4},
            },
        },
    },
}
function bossCfg.getBossHp(level)
    return math.floor(2200000000*1.038^(level-19)+700000000*(level-19)-2000000000)
end
 --×°¼×
function bossCfg.getBossArmor(level)
    return level/100
end
 --ÉÁ±Ü
function bossCfg.getBossDodge(level)
    return level/100
end
 --·À»¤
function bossCfg.getBossDefence(level)
    return level*2
end

