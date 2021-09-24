--
-- 关卡buff配置
-- User: luoning
-- Date: 14-9-15
-- Time: 下午4:18
--
-- tech type 1: 增加资源产量 2：增加部队的攻击力 3：增加部队的血量 4：增加部队的命中率
-- 5：增加部队的闪避率 6：增加部队的暴击 7：增加部队的免爆率
-- attributeType 
-- 102 命中 103 闪避 104 暴击 105 免暴
-- 100 攻击 108 生命

-- baseType 资源增加
-- 201 金属 202 石油 203 铅矿 204 钛矿 205 水晶


local challengeTech=
{
    c1={cid="1",name="challenge_tech_name_1",description="challenge_tech_desc_1",icon="Icon_rapidProduction.png",type=1,baseType={201,202,203,204,205},value={0.025,0.05,0.075,0.1,}},
    c2={cid="2",name="challenge_tech_name_2",description="challenge_tech_desc_2",icon="pro_ship_attack.png",type=2,attributeType=100,value={0.025,0.05,0.075,0.1,}},
    c3={cid="3",name="challenge_tech_name_3",description="challenge_tech_desc_3",icon="pro_ship_life.png",type=3,attributeType=108,value={0.025,0.05,0.075,0.1,}},
    c4={cid="4",name="challenge_tech_name_4",description="challenge_tech_desc_4",icon="skill_01.png",type=4,attributeType=102,value={0.025,0.05,0.075,0.1,}},
    c5={cid="5",name="challenge_tech_name_5",description="challenge_tech_desc_5",icon="skill_02.png",type=5,attributeType=103,value={0.025,0.05,0.075,0.1,}},
    c6={cid="6",name="challenge_tech_name_6",description="challenge_tech_desc_6",icon="skill_03.png",type=6,attributeType=104,value={0.025,0.05,0.075,0.1,}},
    c7={cid="7",name="challenge_tech_name_7",description="challenge_tech_desc_7",icon="skill_04.png",type=7,attributeType=105,value={0.025,0.05,0.075,0.1,}},
}
return challengeTech

