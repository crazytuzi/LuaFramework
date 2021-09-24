bossCfg={
startLevel=20, --BOSSÆðÊ¼µÈ¼¶
levelLimite=20, --¹¦ÄÜ¿ª·ÅµÈ¼¶
opentime={{14,0},{14,30}}, --开放时间
reBorn=28, --¸´»î¼Û¸ñ
reBornTime=30, --¸´»îÊ±¼ä
paotou={1,3,2,4,6,5}, --ÅÚÍ·ËÀÍöË³Ðò
vipLimit=3, --VIP¼¸½âËø×Ô¶¯¹¥»÷
inTime=600, --ÌáÇ°xÃë½øÈë½çÃæ
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




 --ÅÅÃû½±Àø
rankReward={
{range={1,1},{p={{p818=5},{p448=3},},},},
{range={2,2},{p={{p818=3},{p448=2},},},},
{range={3,3},{p={{p819=2},{p447=5},},},},
{range={4,5},{p={{p819=2},{p447=3},},},},
{range={6,10},{p={{p819=1},{p447=2},},},},
}, 
attackHpreward={
{p={{p601=6},{p447=1},}},  -- ÆÕÍ¨ÅÚÌ¨»÷»Ù½±Àø * 5
{p={{p601=20},{p447=3},}},  -- ÌØÊâÅÚÌ¨»÷»Ù½±Àø * 1
},
 --×Ô¼º¹¥»÷Õ¼boss×ÜÑªÁ¿µÄ±ÈµÄ½±Àø
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
{props_p601=6,props_p447=1,},  -- ÆÕÍ¨ÅÚÌ¨»÷»Ù½±Àø * 5
{props_p601=20,props_p447=3,},  -- ÌØÊâÅÚÌ¨»÷»Ù½±Àø * 1
},

 --×Ô¼º¹¥»÷Õ¼boss×ÜÑªÁ¿µÄ±ÈµÄ½±Àø
attacktolHprewardRate=2000,
attacktolHpreward={
{props_p448=2},
{props_p447=1},
{props_p446=1},
},

}

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

