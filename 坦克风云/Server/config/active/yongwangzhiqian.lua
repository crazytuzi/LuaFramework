 --勇往直前活动
local yongwangzhiqian={
multiSelectType=true,
[1]={
type=1,
sortId=317,
 --经验加成
activeExp=0.5,
 --水晶修理折扣
activeRes=0.5,
 --活动期间需要通过的关卡
passChallenge={
s16={num=1,reward={p={{p20=1},{p19=2},},u={{r4=100000},}},serverreward={props_p20=1,props_p19=2,userinfo_r4=100000,}},
s32={num=1,reward={p={{p20=1},{p19=4},},u={{r4=200000},}},serverreward={props_p20=1,props_p19=4,userinfo_r4=200000,}},
s48={num=1,reward={p={{p20=2},{p19=6},},u={{r4=400000},}},serverreward={props_p20=2,props_p19=6,userinfo_r4=400000,}},
s64={num=1,reward={p={{p20=2},{p19=8},},u={{r4=600000},}},serverreward={props_p20=2,props_p19=8,userinfo_r4=600000,}},
s80={num=1,reward={p={{p20=5},{p19=10},},u={{r4=1000000},}},serverreward={props_p20=5,props_p19=10,userinfo_r4=1000000,}},
},
 --每日任务要攻打的关卡 关卡id = 次数
taskChallenge={
t1={num=5,reward={u={{r1=200000},{r2=200000},{r3=200000},{gold=100000},}},serverreward={userinfo_r1=200000,userinfo_r2=200000,userinfo_r3=200000,userinfo_gold=100000,}},
t2={num=10,reward={u={{r1=400000},{r2=400000},{r3=400000},{gold=200000},}},serverreward={userinfo_r1=400000,userinfo_r2=400000,userinfo_r3=400000,userinfo_gold=200000,}},
t3={num=15,reward={u={{r1=800000},{r2=800000},{r3=800000},{gold=400000},}},serverreward={userinfo_r1=800000,userinfo_r2=800000,userinfo_r3=800000,userinfo_gold=400000,}},
t4={num=20,reward={u={{r1=1200000},{r2=1200000},{r3=1200000},{gold=600000},}},serverreward={userinfo_r1=1200000,userinfo_r2=1200000,userinfo_r3=1200000,userinfo_gold=600000,}},
t5={num=30,reward={u={{r1=2000000},{r2=2000000},{r3=2000000},{gold=1000000},}},serverreward={userinfo_r1=2000000,userinfo_r2=2000000,userinfo_r3=2000000,userinfo_gold=1000000,}},
},

},
}
return yongwangzhiqian