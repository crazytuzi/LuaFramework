local achievement={
    --rank 每项数据记录全服前3名
    --type 类型
    --color 品质
    --level 等级
    --needNum 需求数量
    --needType 1总数量 2总等级
    openLevel=30,
    rank=3,
    stage={20,60,120,224},
    unlock={armor=0,sequip=0,alienweapon=0,userkillrace=0},
    person={
        --装备橙色矩阵个数达到6个
        a1={type="armor",addLevel={1,3,6,},needType=1,color=5,needNum={6,18,36,},reward={{am={exp=20000}},{am={exp=60000}},{am={exp=120000}},},serverReward={{armor_exp=20000},{armor_exp=60000},{armor_exp=120000},},},
        --装备橙色矩阵总等级达到300
        a2={type="armor",addLevel={1,3,6,},needType=2,color=5,needNum={300,900,1800,},reward={{p={p5060=1}},{p={p5060=3}},{p={p5060=6}},},serverReward={{props_p5060=1},{props_p5060=3},{props_p5060=6},},},
        --拥有橙色超级装备个数达到1个
        a3={type="sequip",addLevel={1,3,6,},needType=1,color=5,needNum={1,3,6,},reward={{p={p5060=1}},{p={p5060=3}},{p={p5060=6}},},serverReward={{props_p5060=1},{props_p5060=3},{props_p5060=6},},},
        --拥有橙色超级装备+3数1个
        a4={type="sequip",addLevel={1,3,6,},needType=1,color=5,level=3,needNum={1,2,3,},reward={{p={p4877=2}},{p={p4878=2}},{p={p4879=2}},},serverReward={{props_p4877=2},{props_p4878=2},{props_p4879=2},},},
        --已装备的橙色异星武器总等级达到80级
        a5={type="alienweapon",addLevel={1,3,6,},needType=2,needNum={80,240,480,},reward={{p={p4877=2}},{p={p4878=2}},{p={p4879=2}},},serverReward={{props_p4877=2},{props_p4878=2},{props_p4879=2},},},
        --已装备的异星武器宝石总等级达到80级
        a6={type="alienweapon",subType="c",addLevel={1,3,6,},needType=2,needNum={80,120,180,},reward={{p={p4202=1}},{p={p4202=3}},{p={p4202=10}},},serverReward={{props_p4202=1},{props_p4202=3},{props_p4202=10},},},
        --夺海骑兵黄金场及以上战斗胜利场次达到10次
        a51={type="userkillrace",addLevel={1,3,6,},needType=1,color=3,needNum={10,500,3000,},reward={{p={p4803=1}},{p={p4804=5}},{p={p4806=10}},},serverReward={{props_p4803=1},{props_p4804=5},{props_p4806=10},},},
        --夺海骑兵击杀数达到50000
        a52={type="userkillrace",subType="d",addLevel={1,3,6,},needType=1,needNum={50000,700000,5000000,},reward={{p={p4803=1}},{p={p4804=5}},{p={p4806=10}},},serverReward={{props_p4803=1},{props_p4804=5},{props_p4806=10},},},
    },
    all={
        --装备橙色矩阵个数达到6个完成人数达30个
        a1={type="armor",num={{30,60,90,},{15,30,45,},{1,15,30,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{am={exp=3000}},{am={exp=8000}},{p={p4604=1}},},{{am={exp=10000}},{am={exp=30000}},{p={p4606=1}},},{{p={p4606=1}},{p={p4607=1}},{p={p4608=1}},}},serverReward={{{armor_exp=3000},{armor_exp=8000},{props_p4604=1},},{{armor_exp=10000},{armor_exp=30000},{props_p4606=1},},{{props_p4606=1},{props_p4607=1},{props_p4608=1},}},},
        --装备橙色矩阵总等级达到300完成人数达12个
        a2={type="armor",num={{12,24,36,},{8,16,24,},{1,7,15,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{am={exp=4000}},{am={exp=8000}},{am={exp=12000}},},{{am={exp=8000}},{am={exp=12000}},{am={exp=24000}},},{{am={exp=24000}},{am={exp=48000}},{am={exp=96000}},}},serverReward={{{armor_exp=4000},{armor_exp=8000},{armor_exp=12000},},{{armor_exp=8000},{armor_exp=12000},{armor_exp=24000},},{{armor_exp=24000},{armor_exp=48000},{armor_exp=96000},}},},
        --拥有橙色超级装备个数达到1个完成人数达30个
        a3={type="sequip",num={{30,60,90,},{15,30,45,},{1,15,30,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{p={p4004=5}},{p={p4004=10}},{p={p4005=2}},},{{p={p4005=2}},{p={p4005=3}},{p={p4005=5}},},{{p={p4006=2}},{p={p4006=3}},{p={p4006=5}},}},serverReward={{{props_p4004=5},{props_p4004=10},{props_p4005=2},},{{props_p4005=2},{props_p4005=3},{props_p4005=5},},{{props_p4006=2},{props_p4006=3},{props_p4006=5},}},},
        --拥有橙色超级装备+3数1个完成人数达3个
        a4={type="sequip",num={{3,5,10,},{3,5,10,},{3,5,10,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{p={p4001=600}},{p={p4001=1000}},{p={p4001=2000}},},{{p={p4001=1500}},{p={p4002=2}},{p={p4002=3}},},{{p={p4002=3}},{p={p4002=5}},{p={p4002=10}},}},serverReward={{{props_p4001=600},{props_p4001=1000},{props_p4001=2000},},{{props_p4001=1500},{props_p4002=2},{props_p4002=3},},{{props_p4002=3},{props_p4002=5},{props_p4002=10},}},},
        --已装备的橙色异星武器总等级达到80级完成人数达30个
        a5={type="alienweapon",num={{30,60,90,},{15,30,45,},{5,15,30,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{p={p4873=5}},{p={p4874=5}},{p={p4875=5}},},{{p={p4875=3}},{p={p4876=3}},{p={p4877=3}},},{{p={p4877=2}},{p={p4878=2}},{p={p4879=2}},}},serverReward={{{props_p4873=5},{props_p4874=5},{props_p4875=5},},{{props_p4875=3},{props_p4876=3},{props_p4877=3},},{{props_p4877=2},{props_p4878=2},{props_p4879=2},}},},
        --已装备的异星武器宝石总等级达到80级完成人数达30个
        a6={type="alienweapon",num={{30,60,90,},{20,40,60,},{1,10,20,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{p={p4875=3}},{p={p4876=3}},{p={p4877=3}},},{{p={p4877=2}},{p={p4878=2}},{p={p4879=2}},},{{p={p4854=5}},{p={p4854=30}},{p={p4854=100}},}},serverReward={{{props_p4875=3},{props_p4876=3},{props_p4877=3},},{{props_p4877=2},{props_p4878=2},{props_p4879=2},},{{props_p4854=5},{props_p4854=30},{props_p4854=100},}},},
        --夺海骑兵黄金场及以上战斗胜利场次达到10次完成人数达30个
        a51={type="userkillrace",num={{30,60,90,},{15,30,45,},{1,15,30,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{p={p4803=3}},{p={p4803=6}},{p={p4803=10}},},{{p={p4804=3}},{p={p4804=6}},{p={p4804=10}},},{{p={p4806=3}},{p={p4806=6}},{p={p4806=10}},}},serverReward={{{props_p4803=3},{props_p4803=6},{props_p4803=10},},{{props_p4804=3},{props_p4804=6},{props_p4804=10},},{{props_p4806=3},{props_p4806=6},{props_p4806=10},}},},
        --夺海骑兵击杀数达到50000完成人数达30个
        a52={type="userkillrace",num={{30,60,90,},{15,30,45,},{1,15,30,},},addLevel={{1,1,1,},{2,2,2,},{3,3,3,},},reward={{{p={p4803=3}},{p={p4803=6}},{p={p4803=10}},},{{p={p4804=3}},{p={p4804=6}},{p={p4804=10}},},{{p={p4806=3}},{p={p4806=6}},{p={p4806=10}},}},serverReward={{{props_p4803=3},{props_p4803=6},{props_p4803=10},},{{props_p4804=3},{props_p4804=6},{props_p4804=10},},{{props_p4806=3},{props_p4806=6},{props_p4806=10},}},},
    },
}
return achievement
