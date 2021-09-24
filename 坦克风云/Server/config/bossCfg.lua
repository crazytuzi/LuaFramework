local bossCfg={
startLevel=20, --BOSS起始等级
levelLimite=20, --功能开放等级
opentime={{21,0},{21,30}}, --开放时间
reBorn=28, --复活价格
reBornTime=30, --复活时间
autoRBTime=45, --挂机自动复活时间
paotou={1,3,2,4,6,5}, --炮头死亡顺序
-- n天没有击杀 boss就减去1级
killday=2,
vipLimit=3,  --VIP几解锁自动攻击
altLevel=50,	--等级解锁自动攻击（与vip解锁为或关系）


buffSkill={
b1={maxLv=10,cost={u={r4=500000}},serverCost={r4=500000},per=0.05,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffSmeltExpert.png",name="BossBattle_buffName1",des="BossBattle_buffDesc1"},
b2={maxLv=10,cost={u={r4=500000}},serverCost={r4=500000},per=0.05,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffCommander.png",name="BossBattle_buffName2",des="BossBattle_buffDesc2"},
b3={maxLv=10,cost={u={gems=18}},serverCost={gems=18},per=0.05,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffNetget.png",name="BossBattle_buffName3",des="BossBattle_buffDesc3"},
b4={maxLv=10,cost={u={gems=8}},serverCost={gems=8},per=2,probability={100,95,90,85,80,75,70,65,60,55},icon="WarBuffStatistician.png",name="BossBattle_buffName4",des="BossBattle_buffDesc4"},
},

 --排名奖励
rankReward={
{range={1,1},{p={{p818=5},{p448=3},},},},
{range={2,2},{p={{p818=3},{p448=2},},},},
{range={3,3},{p={{p819=2},{p447=5},},},},
{range={4,5},{p={{p819=2},{p447=3},},},},
{range={6,10},{p={{p819=1},{p447=2},},},},
}, 
attackHpreward={
{p={{p601=6},{p447=1},}},  -- 普通炮台击毁奖励 * 5
{p={{p601=20},{p447=3},}},  -- 特殊炮台击毁奖励 * 1
},
 --自己攻击占boss总血量的比的奖励
attacktolHprewardRate=2000,
attacktolHpreward={
{p={{p448=2}}},
{p={{p447=1}}},
{p={{p446=1}}},
},

serverreward={
rankReward={
{range={1,1},{props_p818=5,props_p448=3,},},
{range={2,2},{props_p818=3,props_p448=2,},},
{range={3,3},{props_p819=2,props_p447=5,},},
{range={4,5},{props_p819=2,props_p447=3,},},
{range={6,10},{props_p819=1,props_p447=2,},},
},
attackHpreward={
{props_p601=6,props_p447=1,},  -- 普通炮台击毁奖励 * 5
{props_p601=20,props_p447=3,},  -- 特殊炮台击毁奖励 * 1
},

 --自己攻击占boss总血量的比的奖励
attacktolHprewardRate=2000,
attacktolHpreward={
{props_p448=2},
{props_p447=1},
{props_p446=1},
},

}

}
function bossCfg.getBossHp(level)
    return math.floor(2200000000*1.038^(level-19)+300000000*(level-19)-2000000000)
end
 --装甲
function bossCfg.getBossArmor(level)
    return level/100
end
 --闪避
function bossCfg.getBossDodge(level)
    return level/100
end
 --防护
function bossCfg.getBossDefence(level)
    return level*2
end
return bossCfg