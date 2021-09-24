emblemListCfg={
    
    --etype:装置类型  1:武器  2:装置
    --color:装置品质  1-5:白绿蓝紫橙
    --lv:装备等级  4级（紫色）以上装可上级
    --lvTo:升级至某个装置  例:e62升级至e62_1
    --qiangdu:装置强度  用于强度统计
    --howToGet:获取方式  1:由装备抽取获得 2:装备进阶/装备抽取获得 3:装备进阶获得 4:活动投放获得
    --skill:装置具备的技能
    --upCost:升级消耗  装置升级的消耗
    --deCompose:装备分解获得
    --attUp:属性增加  troopsAdd:带兵量增加 hp:血量 dmg:伤害 accuracy:精准 evade:闪避 crit:暴击 anticrit:免爆 arp:击破 armor:防护
    
    equipListCfg={
        e1={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=10,howToGet=1,deCompose={p4001=1},attUp={dmg=0.01}},
        e2={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=10,howToGet=1,deCompose={p4001=1},attUp={hp=0.01}},
        e3={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=10,howToGet=1,deCompose={p4001=1},attUp={accuracy=0.005}},
        e4={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=10,howToGet=1,deCompose={p4001=1},attUp={evade=0.005}},
        e5={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=10,howToGet=1,deCompose={p4001=1},attUp={crit=0.005}},
        e6={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=10,howToGet=1,deCompose={p4001=1},attUp={anticrit=0.005}},
        e11={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=14,howToGet=1,deCompose={p4001=1},attUp={dmg=0.014}},
        e12={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=14,howToGet=1,deCompose={p4001=1},attUp={hp=0.014}},
        e13={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=14,howToGet=1,deCompose={p4001=1},attUp={evade=0.007}},
        e14={isShow=1,etype=1,color=1,lv=0,lvTo=nil,qiangdu=14,howToGet=1,deCompose={p4001=1},attUp={crit=0.007}},
        e21={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=20,howToGet=2,deCompose={p4001=50},attUp={dmg=0.02}},
        e22={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=20,howToGet=2,deCompose={p4001=50},attUp={hp=0.02}},
        e23={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=20,howToGet=2,deCompose={p4001=50},attUp={accuracy=0.01}},
        e24={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=20,howToGet=2,deCompose={p4001=50},attUp={evade=0.01}},
        e25={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=20,howToGet=2,deCompose={p4001=50},attUp={crit=0.01}},
        e26={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=20,howToGet=2,deCompose={p4001=50},attUp={anticrit=0.01}},
        e31={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=25,howToGet=2,deCompose={p4001=50},attUp={dmg=0.025}},
        e32={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=25,howToGet=2,deCompose={p4001=50},attUp={hp=0.025}},
        e33={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=30,howToGet=2,deCompose={p4001=50},attUp={evade=0.015}},
        e34={isShow=1,etype=1,color=2,lv=0,lvTo=nil,qiangdu=30,howToGet=2,deCompose={p4001=50},attUp={crit=0.015}},
        e41={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=80,howToGet=2,deCompose={p4001=560},attUp={dmg=0.04,accuracy=0.02}},
        e42={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=80,howToGet=2,deCompose={p4001=560},attUp={hp=0.04,evade=0.02}},
        e43={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=80,howToGet=2,deCompose={p4001=560},attUp={dmg=0.04,crit=0.02}},
        e44={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=80,howToGet=2,deCompose={p4001=560},attUp={hp=0.04,anticrit=0.02}},
        e45={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=90,howToGet=2,deCompose={p4001=560},attUp={dmg=0.03,evade=0.03}},
        e51={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=80,howToGet=2,skill={"s1",1},deCompose={p4001=560},attUp={dmg=0.04,crit=0.02}},
        e52={isShow=1,etype=1,color=4,lv=0,lvTo="e52_1",qiangdu=460,howToGet=2,skill={"s2",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,dmg=0.08,crit=0.04}},
        e52_1={isShow=1,etype=1,color=4,lv=1,lvTo="e52_2",qiangdu=750,howToGet=3,skill={"s2",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,dmg=0.13,crit=0.06}},
        e52_2={isShow=1,etype=1,color=4,lv=2,lvTo="e52_3",qiangdu=1180,howToGet=3,skill={"s2",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,dmg=0.2,crit=0.09}},
        e52_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1810,howToGet=3,skill={"s2",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,dmg=0.25,accuracy=0.06,crit=0.12}},
        e53={isShow=1,etype=1,color=5,lv=0,lvTo="e53_1",qiangdu=690,howToGet=3,skill={"s3",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,dmg=0.13,accuracy=0.02,crit=0.06}},
        e53_1={isShow=1,etype=1,color=5,lv=1,lvTo="e53_2",qiangdu=1110,howToGet=3,skill={"s3",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,dmg=0.2,accuracy=0.04,crit=0.09}},
        e53_2={isShow=1,etype=1,color=5,lv=2,lvTo="e53_3",qiangdu=1610,howToGet=3,skill={"s3",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,dmg=0.25,accuracy=0.06,crit=0.12}},
        e53_3={isShow=1,etype=1,color=5,lv=3,lvTo="e53_4",qiangdu=2360,howToGet=3,skill={"s3",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,dmg=0.3,accuracy=0.08,evade=0.05,crit=0.15}},
        e53_4={isShow=1,etype=1,color=5,lv=4,lvTo="e53_5",qiangdu=3180,howToGet=3,skill={"s3",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.4,accuracy=0.1,evade=0.06,crit=0.18,anticrit=0.05}},
        e53_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4500,howToGet=3,skill={"s3",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.5,accuracy=0.12,evade=0.07,crit=0.21,anticrit=0.1}},
        e61={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=90,howToGet=2,skill={"s101",1},deCompose={p4001=560},attUp={hp=0.03,anticrit=0.03}},
        e62={isShow=1,etype=1,color=4,lv=0,lvTo="e62_1",qiangdu=460,howToGet=2,skill={"s102",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,hp=0.06,anticrit=0.05}},
        e62_1={isShow=1,etype=1,color=4,lv=1,lvTo="e62_2",qiangdu=740,howToGet=3,skill={"s102",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,hp=0.1,anticrit=0.07}},
        e62_2={isShow=1,etype=1,color=4,lv=2,lvTo="e62_3",qiangdu=1150,howToGet=3,skill={"s102",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,hp=0.15,anticrit=0.1}},
        e62_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1820,howToGet=3,skill={"s102",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,hp=0.2,evade=0.07,anticrit=0.14}},
        e63={isShow=1,etype=1,color=5,lv=0,lvTo="e63_1",qiangdu=700,howToGet=3,skill={"s103",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,hp=0.1,evade=0.03,anticrit=0.07}},
        e63_1={isShow=1,etype=1,color=5,lv=1,lvTo="e63_2",qiangdu=1100,howToGet=3,skill={"s103",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,hp=0.15,evade=0.05,anticrit=0.1}},
        e63_2={isShow=1,etype=1,color=5,lv=2,lvTo="e63_3",qiangdu=1620,howToGet=3,skill={"s103",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,hp=0.2,evade=0.07,anticrit=0.14}},
        e63_3={isShow=1,etype=1,color=5,lv=3,lvTo="e63_4",qiangdu=2450,howToGet=3,skill={"s103",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,dmg=0.1,hp=0.25,evade=0.1,anticrit=0.2}},
        e63_4={isShow=1,etype=1,color=5,lv=4,lvTo="e63_5",qiangdu=3360,howToGet=3,skill={"s103",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.12,hp=0.28,accuracy=0.05,evade=0.13,anticrit=0.3}},
        e63_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4790,howToGet=3,skill={"s103",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.15,hp=0.32,accuracy=0.1,evade=0.16,anticrit=0.4}},
        e71={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=90,howToGet=2,skill={"s104",1},deCompose={p4001=560},attUp={dmg=0.03,accuracy=0.03}},
        e72={isShow=1,etype=1,color=4,lv=0,lvTo="e72_1",qiangdu=460,howToGet=2,skill={"s105",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,dmg=0.06,accuracy=0.05}},
        e72_1={isShow=1,etype=1,color=4,lv=1,lvTo="e72_2",qiangdu=740,howToGet=3,skill={"s105",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,dmg=0.1,accuracy=0.07}},
        e72_2={isShow=1,etype=1,color=4,lv=2,lvTo="e72_3",qiangdu=1150,howToGet=3,skill={"s105",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,dmg=0.15,accuracy=0.1}},
        e72_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1820,howToGet=3,skill={"s105",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,dmg=0.2,accuracy=0.14,crit=0.07}},
        e73={isShow=1,etype=1,color=5,lv=0,lvTo="e73_1",qiangdu=700,howToGet=3,skill={"s106",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,dmg=0.1,accuracy=0.07,crit=0.03}},
        e73_1={isShow=1,etype=1,color=5,lv=1,lvTo="e73_2",qiangdu=1100,howToGet=3,skill={"s106",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,dmg=0.15,accuracy=0.1,crit=0.05}},
        e73_2={isShow=1,etype=1,color=5,lv=2,lvTo="e73_3",qiangdu=1620,howToGet=3,skill={"s106",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,dmg=0.2,accuracy=0.14,crit=0.07}},
        e73_3={isShow=1,etype=1,color=5,lv=3,lvTo="e73_4",qiangdu=2450,howToGet=3,skill={"s106",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,dmg=0.25,hp=0.1,accuracy=0.2,crit=0.1}},
        e73_4={isShow=1,etype=1,color=5,lv=4,lvTo="e73_5",qiangdu=3350,howToGet=3,skill={"s106",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.3,hp=0.13,accuracy=0.26,crit=0.15,anticrit=0.05}},
        e73_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4750,howToGet=3,skill={"s106",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.35,hp=0.16,accuracy=0.32,crit=0.2,anticrit=0.1}},
        e81={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=90,howToGet=2,skill={"s107",1},deCompose={p4001=560},attUp={hp=0.03,evade=0.03}},
        e82={isShow=1,etype=1,color=4,lv=0,lvTo="e82_1",qiangdu=460,howToGet=2,skill={"s108",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,hp=0.06,evade=0.05}},
        e82_1={isShow=1,etype=1,color=4,lv=1,lvTo="e82_2",qiangdu=740,howToGet=3,skill={"s108",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,hp=0.1,evade=0.07}},
        e82_2={isShow=1,etype=1,color=4,lv=2,lvTo="e82_3",qiangdu=1150,howToGet=3,skill={"s108",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,hp=0.15,evade=0.1}},
        e82_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1820,howToGet=3,skill={"s108",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,hp=0.2,evade=0.14,anticrit=0.07}},
        e83={isShow=1,etype=1,color=5,lv=0,lvTo="e83_1",qiangdu=700,howToGet=3,skill={"s109",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,hp=0.1,evade=0.07,anticrit=0.03}},
        e83_1={isShow=1,etype=1,color=5,lv=1,lvTo="e83_2",qiangdu=1100,howToGet=3,skill={"s109",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,hp=0.15,evade=0.1,anticrit=0.05}},
        e83_2={isShow=1,etype=1,color=5,lv=2,lvTo="e83_3",qiangdu=1620,howToGet=3,skill={"s109",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,hp=0.2,evade=0.14,anticrit=0.07}},
        e83_3={isShow=1,etype=1,color=5,lv=3,lvTo="e83_4",qiangdu=2550,howToGet=3,skill={"s109",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,hp=0.25,accuracy=0.1,evade=0.2,anticrit=0.1}},
        e83_4={isShow=1,etype=1,color=5,lv=4,lvTo="e83_5",qiangdu=3410,howToGet=3,skill={"s109",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.05,hp=0.28,accuracy=0.12,evade=0.27,anticrit=0.15}},
        e83_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4860,howToGet=3,skill={"s109",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.1,hp=0.32,accuracy=0.18,evade=0.34,anticrit=0.2}},
        e91={isShow=1,etype=1,color=3,lv=0,lvTo=nil,qiangdu=90,howToGet=2,skill={"s110",1},deCompose={p4001=560},attUp={dmg=0.03,crit=0.03}},
        e92={isShow=1,etype=1,color=4,lv=0,lvTo="e92_1",qiangdu=460,howToGet=2,skill={"s111",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,dmg=0.06,crit=0.05}},
        e92_1={isShow=1,etype=1,color=4,lv=1,lvTo="e92_2",qiangdu=740,howToGet=3,skill={"s111",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,dmg=0.1,crit=0.07}},
        e92_2={isShow=1,etype=1,color=4,lv=2,lvTo="e92_3",qiangdu=1150,howToGet=3,skill={"s111",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,dmg=0.15,crit=0.1}},
        e92_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1820,howToGet=3,skill={"s111",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,dmg=0.2,accuracy=0.07,crit=0.14}},
        e93={isShow=1,etype=1,color=5,lv=0,lvTo="e93_1",qiangdu=700,howToGet=3,skill={"s112",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,dmg=0.1,accuracy=0.03,crit=0.07}},
        e93_1={isShow=1,etype=1,color=5,lv=1,lvTo="e93_2",qiangdu=1100,howToGet=3,skill={"s112",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,dmg=0.15,accuracy=0.05,crit=0.1}},
        e93_2={isShow=1,etype=1,color=5,lv=2,lvTo="e93_3",qiangdu=1620,howToGet=3,skill={"s112",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,dmg=0.2,accuracy=0.07,crit=0.14}},
        e93_3={isShow=1,etype=1,color=5,lv=3,lvTo="e93_4",qiangdu=2450,howToGet=3,skill={"s112",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,dmg=0.25,accuracy=0.1,evade=0.05,crit=0.2}},
        e93_4={isShow=1,etype=1,color=5,lv=4,lvTo="e93_5",qiangdu=3340,howToGet=3,skill={"s112",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.3,accuracy=0.13,evade=0.08,crit=0.26,anticrit=0.05}},
        e93_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4750,howToGet=3,skill={"s112",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.35,accuracy=0.16,evade=0.12,crit=0.32,anticrit=0.1}},
        e101={isShow=1,etype=1,color=4,lv=0,lvTo="e101_1",qiangdu=460,howToGet=3,skill={"s5",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,dmg=0.08,accuracy=0.04}},
        e101_1={isShow=1,etype=1,color=4,lv=1,lvTo="e101_2",qiangdu=750,howToGet=3,skill={"s5",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,dmg=0.13,accuracy=0.06}},
        e101_2={isShow=1,etype=1,color=4,lv=2,lvTo="e101_3",qiangdu=1180,howToGet=3,skill={"s5",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,dmg=0.2,accuracy=0.09}},
        e101_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1810,howToGet=3,skill={"s5",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,dmg=0.25,accuracy=0.12,crit=0.06}},
        e102={isShow=1,etype=1,color=5,lv=0,lvTo="e102_1",qiangdu=690,howToGet=4,skill={"s6",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,dmg=0.13,accuracy=0.06,crit=0.02}},
        e102_1={isShow=1,etype=1,color=5,lv=1,lvTo="e102_2",qiangdu=1110,howToGet=4,skill={"s6",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,dmg=0.2,accuracy=0.09,crit=0.04}},
        e102_2={isShow=1,etype=1,color=5,lv=2,lvTo="e102_3",qiangdu=1610,howToGet=4,skill={"s6",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,dmg=0.25,accuracy=0.12,crit=0.06}},
        e102_3={isShow=1,etype=1,color=5,lv=3,lvTo="e102_4",qiangdu=2360,howToGet=4,skill={"s6",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,dmg=0.3,accuracy=0.15,evade=0.05,crit=0.08}},
        e102_4={isShow=1,etype=1,color=5,lv=4,lvTo="e102_5",qiangdu=3170,howToGet=4,skill={"s6",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.35,accuracy=0.18,evade=0.08,crit=0.1,anticrit=0.05}},
        e102_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4500,howToGet=4,skill={"s6",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.4,accuracy=0.21,evade=0.12,crit=0.12,anticrit=0.1}},
        e103={isShow=1,etype=1,color=5,lv=0,lvTo="e103_1",qiangdu=690,howToGet=4,skill={"s9",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,hp=0.13,evade=0.06,anticrit=0.02}},
        e103_1={isShow=1,etype=1,color=5,lv=1,lvTo="e103_2",qiangdu=1110,howToGet=4,skill={"s9",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,hp=0.2,evade=0.09,anticrit=0.04}},
        e103_2={isShow=1,etype=1,color=5,lv=2,lvTo="e103_3",qiangdu=1610,howToGet=4,skill={"s9",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,hp=0.25,evade=0.12,anticrit=0.06}},
        e103_3={isShow=1,etype=1,color=5,lv=3,lvTo="e103_4",qiangdu=2360,howToGet=4,skill={"s9",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,hp=0.3,evade=0.15,crit=0.05,anticrit=0.08}},
        e103_4={isShow=1,etype=1,color=5,lv=4,lvTo="e103_5",qiangdu=3170,howToGet=4,skill={"s9",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.05,hp=0.34,evade=0.18,crit=0.06,anticrit=0.15}},
        e103_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4500,howToGet=4,skill={"s9",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.1,hp=0.38,evade=0.21,crit=0.08,anticrit=0.22}},
        e104={isShow=1,etype=1,color=5,lv=0,lvTo="e104_1",qiangdu=690,howToGet=4,skill={"s12",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,dmg=0.13,accuracy=0.06,crit=0.02}},
        e104_1={isShow=1,etype=1,color=5,lv=1,lvTo="e104_2",qiangdu=1110,howToGet=4,skill={"s12",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,dmg=0.2,accuracy=0.09,crit=0.04}},
        e104_2={isShow=1,etype=1,color=5,lv=2,lvTo="e104_3",qiangdu=1610,howToGet=4,skill={"s12",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,dmg=0.25,accuracy=0.12,crit=0.06}},
        e104_3={isShow=1,etype=1,color=5,lv=3,lvTo="e104_4",qiangdu=2360,howToGet=4,skill={"s12",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,dmg=0.3,accuracy=0.15,evade=0.05,crit=0.08}},
        e104_4={isShow=1,etype=1,color=5,lv=4,lvTo="e104_5",qiangdu=3170,howToGet=4,skill={"s12",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.35,accuracy=0.18,evade=0.08,crit=0.1,anticrit=0.05}},
        e104_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4500,howToGet=4,skill={"s12",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.4,accuracy=0.21,evade=0.12,crit=0.12,anticrit=0.1}},
        e111={isShow=1,etype=1,color=4,lv=0,lvTo="e111_1",qiangdu=460,howToGet=3,skill={"s202",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,hp=0.08,evade=0.04}},
        e111_1={isShow=1,etype=1,color=4,lv=1,lvTo="e111_2",qiangdu=750,howToGet=3,skill={"s202",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,hp=0.13,evade=0.06}},
        e111_2={isShow=1,etype=1,color=4,lv=2,lvTo="e111_3",qiangdu=1180,howToGet=3,skill={"s202",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,hp=0.2,evade=0.09}},
        e111_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1810,howToGet=3,skill={"s202",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,hp=0.25,evade=0.12,anticrit=0.06}},
        e112={isShow=1,etype=1,color=5,lv=0,lvTo="e112_1",qiangdu=690,howToGet=3,skill={"s203",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,hp=0.13,evade=0.06,anticrit=0.02}},
        e112_1={isShow=1,etype=1,color=5,lv=1,lvTo="e112_2",qiangdu=1110,howToGet=3,skill={"s203",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,hp=0.2,evade=0.09,anticrit=0.04}},
        e112_2={isShow=1,etype=1,color=5,lv=2,lvTo="e112_3",qiangdu=1610,howToGet=3,skill={"s203",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,hp=0.25,evade=0.12,anticrit=0.06}},
        e112_3={isShow=1,etype=1,color=5,lv=3,lvTo="e112_4",qiangdu=2360,howToGet=3,skill={"s203",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,hp=0.3,accuracy=0.05,evade=0.15,anticrit=0.08}},
        e112_4={isShow=1,etype=1,color=5,lv=4,lvTo="e112_5",qiangdu=3120,howToGet=3,skill={"s203",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.05,hp=0.35,accuracy=0.06,evade=0.18,anticrit=0.12}},
        e112_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4500,howToGet=3,skill={"s203",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.1,hp=0.4,accuracy=0.09,evade=0.21,anticrit=0.2}},
        e801={isShow=1,etype=2,color=4,lv=0,lvTo=nil,qiangdu=500,howToGet=3,skill={"s308",1},deCompose={p4001=4600}},
        e802={isShow=1,etype=2,color=5,lv=0,lvTo=nil,qiangdu=1000,howToGet=3,skill={"s309",1},deCompose={p4002=10}},
        e812={isShow=1,etype=2,color=4,lv=0,lvTo=nil,qiangdu=500,howToGet=3,skill={"s302",1},deCompose={p4001=4600}},
        e813={isShow=1,etype=2,color=5,lv=0,lvTo=nil,qiangdu=1000,howToGet=3,skill={"s303",1},deCompose={p4002=10}},
        e822={isShow=1,etype=2,color=4,lv=0,lvTo=nil,qiangdu=500,howToGet=3,skill={"s305",1},deCompose={p4001=4600}},
        e823={isShow=1,etype=2,color=5,lv=0,lvTo=nil,qiangdu=1000,howToGet=3,skill={"s306",1},deCompose={p4002=10}},
        e833={isShow=1,etype=2,color=5,lv=0,lvTo=nil,qiangdu=1200,howToGet=3,skill={"s315",1},deCompose={p4002=10}},
        e842={isShow=0,etype=2,color=4,lv=0,lvTo=nil,qiangdu=500,howToGet=4,skill={"s311",1},deCompose={p4001=4600}},
        e843={isShow=0,etype=2,color=5,lv=0,lvTo=nil,qiangdu=1000,howToGet=4,skill={"s312",1},deCompose={p4002=10}},
        e852={isShow=1,etype=2,color=4,lv=0,lvTo=nil,qiangdu=500,howToGet=3,skill={"s317",1},deCompose={p4001=4600}},
        e853={isShow=1,etype=2,color=5,lv=0,lvTo=nil,qiangdu=1000,howToGet=3,skill={"s318",1},deCompose={p4002=10}},
        e105={isShow=1,etype=1,color=4,lv=0,lvTo="e105_1",qiangdu=460,howToGet=4,skill={"s7",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,hp=0.08,evade=0.04}},
        e105_1={isShow=1,etype=1,color=4,lv=1,lvTo="e105_2",qiangdu=750,howToGet=4,skill={"s7",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,hp=0.13,evade=0.06}},
        e105_2={isShow=1,etype=1,color=4,lv=2,lvTo="e105_3",qiangdu=1180,howToGet=4,skill={"s7",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,hp=0.2,evade=0.09}},
        e105_3={isShow=1,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1810,howToGet=4,skill={"s7",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,hp=0.25,evade=0.12,anticrit=0.06}},
        e106={isShow=0,etype=1,color=4,lv=0,lvTo="e106_1",qiangdu=460,howToGet=4,skill={"s10",1},upCost={p4001=7000,p19=50},deCompose={p4001=4600},attUp={troopsAdd=30,dmg=0.08,accuracy=0.04}},
        e106_1={isShow=0,etype=1,color=4,lv=1,lvTo="e106_2",qiangdu=750,howToGet=4,skill={"s10",2},upCost={p4001=12000,p4002=2,p19=150,p20=5},deCompose={p4001=8800,p19=80},attUp={troopsAdd=50,dmg=0.13,accuracy=0.06}},
        e106_2={isShow=0,etype=1,color=4,lv=2,lvTo="e106_3",qiangdu=1180,howToGet=4,skill={"s10",3},upCost={p4001=25000,p4002=7,p19=450,p20=15},deCompose={p4001=16000,p4002=1,p19=200,p20=4},attUp={troopsAdd=80,dmg=0.2,accuracy=0.09}},
        e106_3={isShow=0,etype=1,color=4,lv=3,lvTo=nil,qiangdu=1810,howToGet=4,skill={"s10",4},deCompose={p4001=31000,p4002=5,p19=200,p20=12},attUp={troopsAdd=120,dmg=0.25,accuracy=0.12,crit=0.06}},
        e901={isShow=0,etype=1,color=5,lv=0,lvTo=nil,qiangdu=102,howToGet=4,attUp={dmg=0.01,hp=0.01,accuracy=0.01,evade=0.01,crit=0.01,anticrit=0.01}},
        e122={isShow=1,etype=1,color=5,lv=0,lvTo="e122_1",qiangdu=690,howToGet=4,skill={"s13",1},upCost={p4001=15000,p4002=10,p19=200,p20=5},deCompose={p4002=10},attUp={troopsAdd=40,hp=0.13,evade=0.06,anticrit=0.02}},
        e122_1={isShow=1,etype=1,color=5,lv=1,lvTo="e122_2",qiangdu=1110,howToGet=4,skill={"s13",2},upCost={p4001=40000,p4002=25,p19=500,p20=20},deCompose={p4001=9000,p4002=16,p19=240},attUp={troopsAdd=65,hp=0.2,evade=0.09,anticrit=0.04}},
        e122_2={isShow=1,etype=1,color=5,lv=2,lvTo="e122_3",qiangdu=1610,howToGet=4,skill={"s13",3},upCost={p4001=100000,p4002=65,p19=1500,p20=60},deCompose={p4001=33000,p4002=31,p19=560,p20=48},attUp={troopsAdd=100,hp=0.25,evade=0.12,anticrit=0.06}},
        e122_3={isShow=1,etype=1,color=5,lv=3,lvTo="e122_4",qiangdu=2360,howToGet=4,skill={"s13",4},upCost={p4001=200000,p4002=90,p19=2500,p20=100},deCompose={p4001=93000,p4002=70,p19=960,p20=72},attUp={troopsAdd=150,hp=0.3,accuracy=0.05,evade=0.15,anticrit=0.08}},
        e122_4={isShow=1,etype=1,color=5,lv=4,lvTo="e122_5",qiangdu=3120,howToGet=4,skill={"s13",5},upCost={p4001=300000,p4002=120,p19=4000,p20=200},deCompose={p4001=213000,p4002=124,p19=1710,p20=102},attUp={troopsAdd=200,dmg=0.05,hp=0.35,accuracy=0.06,evade=0.18,anticrit=0.12}},
        e122_5={isShow=1,etype=1,color=5,lv=5,lvTo=nil,qiangdu=4500,howToGet=4,skill={"s13",6},deCompose={p4001=393000,p4002=196,p19=2910,p20=162},attUp={troopsAdd=300,dmg=0.1,hp=0.4,accuracy=0.09,evade=0.21,anticrit=0.2}},
    },
    
    --stype:技能类型  1:繁荣掠夺 2:克敌机先 101:关卡护盾 102:关卡强击 103:关卡教条 104:矿点作战 201:急速采集 301:急速科技 302:急速生产 303:急速改造 304:急速建造 305:钻石合成
    --value:技能加成值  value1-4对应4个等级
    --新增：3：燃烧炮弹  4：爆破炸弹  306：急速储备
    
    skillCfg={
        s1={stype=1,value1={0.05},value2={0.08},value3={0.11},value4={0.15}},
        s2={stype=1,value1={0.1},value2={0.15},value3={0.2},value4={0.25}},
        s3={stype=1,value1={0.2},value2={0.3},value3={0.4},value4={0.5},value5={0.6},value6={0.7}},
        s4={stype=2,value1={35},value2={50},value3={65},value4={80}},
        s5={stype=2,value1={75},value2={100},value3={125},value4={150}},
        s6={stype=2,value1={150},value2={200},value3={250},value4={300},value5={350},value6={400}},
        s7={stype=3,value1={"ay",1},value2={"ay",2},value3={"ay",3},value4={"ay",4}},
        s8={stype=3,value1={"ay",2},value2={"ay",3},value3={"ay",4},value4={"ay",5}},
        s9={stype=3,value1={"ay",4},value2={"ay",5},value3={"ay",6},value4={"ay",7},value5={"ay",8},value6={"ay",9}},
        s10={stype=4,value1={"az",1},value2={"az",2},value3={"az",3},value4={"az",4}},
        s11={stype=4,value1={"az",1},value2={"az",2},value3={"az",3},value4={"az",4}},
        s12={stype=4,value1={"az",1},value2={"az",2},value3={"az",3},value4={"az",4},value5={"az",6},value6={"az",8}},
        s101={stype=101,value1={0.05},value2={0.07},value3={0.1},value4={0.15}},
        s102={stype=101,value1={0.1},value2={0.15},value3={0.2},value4={0.25}},
        s103={stype=101,value1={0.2},value2={0.25},value3={0.32},value4={0.4},value5={0.48},value6={0.56}},
        s104={stype=102,value1={0.02},value2={0.03},value3={0.05},value4={0.1}},
        s105={stype=102,value1={0.03},value2={0.05},value3={0.1},value4={0.2}},
        s106={stype=102,value1={0.05},value2={0.1},value3={0.2},value4={0.3},value5={0.4},value6={0.5}},
        s107={stype=103,value1={0.06},value2={0.08},value3={0.1},value4={0.15}},
        s108={stype=103,value1={0.08},value2={0.1},value3={0.15},value4={0.2}},
        s109={stype=103,value1={0.1},value2={0.15},value3={0.2},value4={0.3},value5={0.4},value6={0.5}},
        s110={stype=104,value1={0.03},value2={0.05},value3={0.07},value4={0.1}},
        s111={stype=104,value1={0.05},value2={0.07},value3={0.1},value4={0.14}},
        s112={stype=104,value1={0.06},value2={0.1},value3={0.14},value4={0.2},value5={0.26},value6={0.32}},
        s201={stype=201,value1={0.05},value2={0.07},value3={0.1},value4={0.15}},
        s202={stype=201,value1={0.07},value2={0.1},value3={0.15},value4={0.2}},
        s203={stype=201,value1={0.1},value2={0.15},value3={0.2},value4={0.3},value5={0.4},value6={0.5}},
        s301={stype=301,value1={0.5}},
        s302={stype=301,value1={1}},
        s303={stype=301,value1={2}},
        s304={stype=302,value1={0.5}},
        s305={stype=302,value1={1}},
        s306={stype=302,value1={2}},
        s307={stype=303,value1={0.5}},
        s308={stype=303,value1={1}},
        s309={stype=303,value1={2}},
        s310={stype=304,value1={0.5}},
        s311={stype=304,value1={1}},
        s312={stype=304,value1={2}},
        s313={stype=305,value1={18}},
        s314={stype=305,value1={36}},
        s315={stype=305,value1={60}},
        s316={stype=306,value1={0.5}},
        s317={stype=306,value1={1}},
        s318={stype=306,value1={2}},
        s13={stype=5,value1={"cg",1},value2={"cg",2},value3={"cg",3},value4={"cg",4},value5={"cg",5},value6={"cg",6}},
    },
}
