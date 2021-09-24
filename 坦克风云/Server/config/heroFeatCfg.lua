local heroFeatCfg={
    --将领授勋
    --将领最大功勋技能等级（heroListCfg）
    --技能是否可随（heroSkillCfg,0不可随机，1随机类型1,2随机类型2）
    
    --功能开启等级,可授勋等级
    levelLimit=60,
    
    --可授勋星级
    fusionLimit=4,
    
    --领悟金币消耗
    gemCost={8,18,28,38,48,58,68,78,88,98},
    
    --领悟道具消耗（后台）
    ServerPropCost={{p866=1},{p866=2},{p866=3},{p866=4},{p866=5},{p866=6},{p866=7},{p866=8},{p866=9},{p866=10}},
    
    --领悟道具消耗（前台）
    propCost={{p={p866=1}},{p={p866=2}},{p={p866=3}},{p={p866=4}},{p={p866=5}},{p={p866=6}},{p={p866=7}},{p={p866=8}},{p={p866=9}},{p={p866=10}}},
    
    --每次领悟可获得几个可选技能
    skillChoice=2,
    
    --资质等级
    aptitude={0,1,4,7,11,16,21,28,35,42,50},
    
    --资质等级对应的字母和颜色
    qualificationLevel={{"E",1},{"E+",1},{"D",2},{"D+",2},{"C",3},{"C+",3},{"B",4},{"B+",4},{"A",5},{"A+",5},{"S",6}},
    
    --（二次授勋）每次领悟可获得几个可选技能
    skillChoice2={3},
    --（二次授勋）将领一次授勋后达到70级可二次授勋
    levelLimit2={70},
    --（二次授勋）可授勋星级
    fusionLimit2={5},
    --（二次授勋）领悟金币消耗
    gemCost2={98},
    --（二次授勋）领悟道具消耗（后台）
    ServerPropCost2={{p866=10}},
    --（二次授勋）领悟道具消耗（前台）
    propCost2={{p={p866=10}}},
    
    --天命技能刷新：出现几率是ratio(20%)，每次刷新3个格子只会出现1次天命，玩家技能都达到上限，不会刷新出天命
    --天命技能使用1：根据玩家技能等级和技能上限，从weight中取值，例：25/25，为0  15/20，取weight中第15个数
    --天命技能使用2：根据玩家技能数量，会得到至少4个数，假设为100,150,0,110，对应第1技能--第4技能
    --天命技能使用3：将100,150,0,110中第一个数以外的其他数乘以multiple，得到100,450,0,330，以这4个数为权重，来随机天命技能对哪一个技能生效
    --注：使用天命技能只会使技能提升1级，且不会使技能超过技能上限
    --（二次授勋）天命几率
    ratio=0.2,
    --（二次授勋）辅助系数1
    weight={200,195,190,185,180,175,170,165,160,155,150,145,140,135,130,125,120,115,110,105,100,95,90,85,80},
    --（二次授勋）辅助系数2
    multiple=3,
    
    --（二次授勋）天命技能
    tianming={id="s2000",icon="skill_s381.png",name="skill_name_s2000",des="skill_des_s2000"},
    
    --授勋任务( t1:收集魂魄 t2:携带该将领在15章及以后的关卡中获胜 t3:携带此将领竞技场胜利n次 t4:携带此将领击杀军团副本BOSS t5:携带此将领获得n军功 t6:攻打n次补给线(包含扫荡) t7:通过远征军关卡n次 t8:需要十字勋章X个 t9:技能资质达到S t10:携带此将领攻打叛军X次 t11:参与X次异元战场  t12:参与X次军团战  t13:携带此将领占领富矿X次  t14:携带此将领攻打7层及以上的神秘海域叛军X次)
    heroQuest={
        h1={{{"t1",690,"s1"},{"t6",15},{"t2",15,225},{"t5",300000}},{{"t9",11},{"t13",20},{"t11",2},{"t10",25}}},
        h2={{{"t1",690,"s2"},{"t3",15},{"t2",15,225},{"t5",100000}},{{"t9",11},{"t10",25},{"t12",2},{"t14",25,7}}},
        h3={{{"t1",690,"s3"},{"t6",20},{"t2",20,225},{"t4",3}},{{"t9",11},{"t10",25},{"t12",2},{"t13",20}}},
        h4={{{"t1",690,"s4"},{"t3",15},{"t7",15},{"t5",50000}},{{"t9",11},{"t13",20},{"t11",2},{"t14",25,7}}},
        h5={{{"t1",690,"s5"},{"t6",25},{"t7",15},{"t5",500000}},{{"t9",11},{"t13",18},{"t11",2},{"t10",20}}},
        h6={{{"t1",690,"s6"},{"t3",15},{"t2",15,225},{"t5",100000}},{{"t9",11},{"t13",18},{"t12",2},{"t10",20}}},
        h7={{{"t1",690,"s7"},{"t3",15},{"t7",15},{"t5",80000}},{{"t9",11},{"t13",18},{"t12",2},{"t14",20,7}}},
        h8={{{"t1",690,"s8"},{"t6",30},{"t2",15,225},{"t5",80000}},{{"t9",11},{"t10",20},{"t11",2},{"t14",20,7}}},
        h9={{{"t1",690,"s9"},{"t3",15},{"t7",15},{"t4",1}},{{"t9",11},{"t13",18},{"t11",2},{"t10",20}}},
        h10={{{"t1",690,"s10"},{"t3",15},{"t7",15},{"t5",50000}},{{"t9",11},{"t13",15},{"t11",1},{"t14",18,7}}},
        h11={{{"t1",690,"s11"},{"t3",20},{"t2",15,225},{"t4",1}},{{"t9",11},{"t13",15},{"t11",1},{"t10",18}}},
        h12={{{"t1",690,"s12"},{"t3",15},{"t6",20},{"t2",30,225}},{{"t9",11},{"t14",18,7},{"t12",1},{"t13",15}}},
        h13={{{"t1",690,"s13"},{"t3",15},{"t2",15,225},{"t5",100000}},{{"t9",11},{"t13",20},{"t12",2},{"t10",25}}},
        h14={{{"t1",690,"s14"},{"t6",30},{"t7",15},{"t5",100000}},{{"t9",11},{"t10",25},{"t12",2},{"t14",25,7}}},
        h15={{{"t1",690,"s15"},{"t3",15},{"t7",15},{"t4",2}},{{"t9",11},{"t14",25,7},{"t11",2},{"t10",25}}},
        h16={{{"t1",690,"s16"},{"t6",20},{"t7",15},{"t5",100000}},{{"t9",11},{"t13",18},{"t11",2},{"t10",20}}},
        h17={{{"t1",690,"s17"},{"t3",15},{"t2",15,225},{"t5",80000}},{{"t9",11},{"t13",18},{"t12",2},{"t14",20,7}}},
        h18={{{"t1",690,"s18"},{"t7",15},{"t2",15,225},{"t4",1}},{{"t9",11},{"t10",20},{"t12",2},{"t14",20,7}}},
        h19={{{"t1",690,"s19"},{"t3",15},{"t7",15},{"t5",100000}},{{"t9",11},{"t14",20,7},{"t12",2},{"t13",18}}},
        h20={{{"t1",690,"s20"},{"t3",15},{"t6",20},{"t4",1}},{{"t9",11},{"t14",20,7},{"t12",2},{"t10",20}}},
        h21={{{"t1",690,"s21"},{"t7",15},{"t3",12},{"t5",100000}},{{"t9",11},{"t14",20,7},{"t11",2},{"t13",18}}},
        h22={{{"t1",690,"s22"},{"t3",15},{"t7",15},{"t5",100000}},{{"t9",11},{"t13",15},{"t11",1},{"t14",18,7}}},
        h23={{{"t1",690,"s23"},{"t3",15},{"t6",20},{"t5",50000}},{{"t9",11},{"t10",18},{"t11",1},{"t14",18,7}}},
        h24={{{"t1",690,"s24"},{"t7",6},{"t2",15,225},{"t5",200000}},{{"t9",11},{"t13",20},{"t12",2},{"t10",25}}},
        h25={{{"t1",690,"s25"},{"t7",6},{"t3",12},{"t5",500000}},{{"t9",11},{"t10",25},{"t12",2},{"t14",25,7}}},
        h26={{{"t1",690,"s26"},{"t7",6},{"t3",12},{"t4",3}},{{"t9",11},{"t13",20},{"t11",2},{"t14",25,7}}},
        h27={{{"t1",690,"s27"},{"t5",50000},{"t3",10},{"t2",10,225}},{{"t9",11},{"t13",15},{"t11",1},{"t14",18,7}}},
        h28={{{"t1",690,"s28"},{"t7",6},{"t3",12},{"t5",100000}},{{"t9",11},{"t13",15},{"t12",1},{"t14",18,7}}},
        h29={{{"t1",690,"s29"},{"t6",10},{"t7",15},{"t5",100000}},{{"t9",11},{"t14",18,7},{"t11",1},{"t10",18}}},
        h30={{{"t1",690,"s30"},{"t3",10},{"t6",12},{"t5",100000}},{{"t9",11},{"t14",25,7},{"t11",2},{"t10",25}}},
        h31={{{"t1",690,"s31"},{"t6",20},{"t3",10},{"t7",20}},{{"t9",11},{"t14",15,7},{"t11",1},{"t10",15}}},
        h32={{{"t1",690,"s32"},{"t6",20},{"t3",12},{"t5",100000}},{{"t9",11},{"t10",25},{"t12",2},{"t14",25,7}}},
        h33={{{"t1",690,"s33"},{"t7",6},{"t3",12},{"t4",1}},{{"t9",11},{"t13",12},{"t12",1},{"t14",15,7}}},
        h34={{{"t1",690,"s34"},{"t6",20},{"t3",10},{"t7",15}},{{"t9",11},{"t13",12},{"t11",1},{"t10",15}}},
        h35={{{"t1",690,"s35"},{"t6",20},{"t3",8},{"t7",10}},{{"t9",11},{"t13",12},{"t12",1},{"t10",15}}},
        h36={{{"t1",690,"s36"},{"t7",6},{"t6",20},{"t5",50000}},{{"t9",11},{"t10",15},{"t11",1},{"t14",15,7}}},
        h37={{{"t1",690,"s37"},{"t7",6},{"t3",12},{"t4",1}},{{"t9",11},{"t13",12},{"t12",1},{"t10",15}}},
        h38={{{"t1",690,"s38"},{"t6",20},{"t3",6},{"t7",10}},{{"t9",11},{"t14",15,7},{"t12",1},{"t10",15}}},
        h39={{{"t1",690,"s39"},{"t3",10},{"t2",18,225},{"t5",50000}},{{"t9",11},{"t13",18},{"t12",2},{"t10",20}}},
        h40={{{"t1",690,"s40"},{"t6",20},{"t3",5},{"t7",10}},{{"t9",11},{"t10",18},{"t11",1},{"t14",18,7}}},
        h101={{{"t1",690,"s101"},{"t6",15},{"t2",15,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t14",30,7}}},
        h102={{{"t1",690,"s102"},{"t6",20},{"t2",20,225},{"t4",3}},{{"t9",11},{"t10",30},{"t12",2},{"t14",30,7}}},
        h103={{{"t1",690,"s103"},{"t2",15,225},{"t3",15},{"t5",300000}},{{"t9",11},{"t10",30},{"t11",2},{"t13",25}}},
        h104={{{"t1",690,"s104"},{"t6",20},{"t2",20,225},{"t4",3}},{{"t9",11},{"t10",30},{"t11",2},{"t13",25}}},
        h105={{{"t1",690,"s105"},{"t7",15},{"t2",20,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t13",25}}},
        h106={{{"t1",690,"s106"},{"t6",30},{"t4",3},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t14",30,7}}},
        h107={{{"t1",690,"s107"},{"t6",30},{"t2",20,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t14",30,7}}},
        h108={{{"t1",690,"s108"},{"t6",30},{"t4",3},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t14",30,7}}},
        h109={{{"t1",690,"s109"},{"t6",30},{"t2",20,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t13",25}}},
        h110={{{"t1",690,"s110"},{"t6",30},{"t4",3},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t13",25}}},
        h111={{{"t1",690,"s111"},{"t6",15},{"t2",15,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t13",25}}},
        h112={{{"t1",690,"s112"},{"t6",20},{"t2",20,225},{"t4",3}},{{"t9",11},{"t10",30},{"t11",2},{"t14",30,7}}},
        h113={{{"t1",690,"s113"},{"t2",15,225},{"t3",15},{"t5",300000}},{{"t9",11},{"t10",30},{"t12",2},{"t14",30,7}}},
        h114={{{"t1",690,"s114"},{"t6",20},{"t2",20,225},{"t4",3}},{{"t9",11},{"t10",30},{"t12",2},{"t14",30,7}}},
        h115={{{"t1",690,"s115"},{"t7",15},{"t2",20,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t13",25}}},
        h116={{{"t1",690,"s116"},{"t6",30},{"t4",3},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t13",25}}},
        h117={{{"t1",690,"s117"},{"t6",30},{"t2",20,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t13",25}}},
        h118={{{"t1",690,"s118"},{"t6",30},{"t4",3},{"t5",500000}},{{"t9",11},{"t10",30},{"t12",2},{"t14",30,7}}},
        h119={{{"t1",690,"s119"},{"t6",30},{"t2",20,225},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t14",30,7}}},
        h120={{{"t1",690,"s120"},{"t6",30},{"t4",3},{"t5",500000}},{{"t9",11},{"t10",30},{"t11",2},{"t14",30,7}}},
    },
}

return heroFeatCfg
