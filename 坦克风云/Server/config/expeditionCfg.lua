local expeditionCfg= --远征军关卡配置
{
 --不同vip对应最大重置次数包含vip 0
resetNum={1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2},
 --玩家开放等级
openLevel=25,
 --每个档次存储玩家数量 
maxCount=10,
 --远征关卡配置玩家档次
expeditionid={-10,-10,-9,-9,-8,-8,-7,-7,-6,-6,-5,-4,-3,-2,-1,},
 --关卡解锁需要玩家等级
unlockExpUserLvl={  25,25,25,25,25,25,30,30,30,35,35,35,40,40,40,},
--达到这个数时可以扫荡
acount=3,
 --每次重置衰减   向上取整   1.三颗星可以扫荡所有，不衰减 2.每次远征等级提高，会进行衰减  例：上一次打了15关，重置后可以扫荡8关
resetRatio=0.5,
challenge={
s1={userinfo={"elite_challenge_name_1","ArtilleryLv2.png",21,40000,0,120,},tank={{"a10003",120},{"a10013",120},{"a10023",120},{"a10033",120},{"a10022",120},{"a10032",120},},skill={s101=20,s102=20,s103=20,s104=20,},attributeUp={attack=1,life=1,accurate=1,avoid=1,critical=1,decritical=1,},},
s2={userinfo={"elite_challenge_name_2","RocketLv2.png",22,44000,0,138,},tank={{"a10003",138},{"a10013",138},{"a10023",138},{"a10033",138},{"a10022",138},{"a10032",138},},skill={s101=20,s102=20,s103=20,s104=20,},attributeUp={attack=1.1,life=1.1,accurate=1,avoid=1,critical=1,decritical=1,},},
s3={userinfo={"elite_challenge_name_3","TankLv3.png",23,49000,0,159,},tank={{"a10003",159},{"a10013",159},{"a10023",159},{"a10033",159},{"a10022",159},{"a10032",159},},skill={s101=21,s102=21,s103=21,s104=21,},attributeUp={attack=1.2,life=1.2,accurate=1,avoid=1,critical=1,decritical=1,},},
s4={userinfo={"elite_challenge_name_4","WeaponLv3.png",24,54000,0,183,},tank={{"a10003",183},{"a10013",183},{"a10023",183},{"a10033",183},{"a10022",183},{"a10032",183},},skill={s101=21,s102=21,s103=21,s104=21,},attributeUp={attack=1.3,life=1.3,accurate=1,avoid=1,critical=1,decritical=1,},},
s5={userinfo={"elite_challenge_name_5","ArtilleryLv3.png",25,60000,0,210,},tank={{"a10003",210},{"a10013",210},{"a10023",210},{"a10033",210},{"a10022",210},{"a10032",210},},skill={s101=21,s102=21,s103=21,s104=21,},attributeUp={attack=1.4,life=1.4,accurate=1,avoid=1,critical=1,decritical=1,},},
s6={userinfo={"elite_challenge_name_6","RocketLv3.png",26,66000,0,241,},tank={{"a10003",241},{"a10013",241},{"a10023",241},{"a10033",241},{"a10022",241},{"a10032",241},},skill={s101=22,s102=22,s103=22,s104=22,},attributeUp={attack=1.5,life=1.5,accurate=1,avoid=1,critical=1,decritical=1,},},
s7={userinfo={"elite_challenge_name_7","TankLv3.png",27,73000,0,277,},tank={{"a10003",277},{"a10013",277},{"a10023",277},{"a10033",277},{"a10022",277},{"a10032",277},},skill={s101=22,s102=22,s103=22,s104=22,},attributeUp={attack=1.6,life=1.6,accurate=1,avoid=1,critical=1,decritical=1,},},
s8={userinfo={"elite_challenge_name_8","WeaponLv3.png",28,81000,0,318,},tank={{"a10003",318},{"a10013",318},{"a10023",318},{"a10033",318},{"a10022",318},{"a10032",318},},skill={s101=22,s102=22,s103=22,s104=22,},attributeUp={attack=1.7,life=1.7,accurate=1,avoid=1,critical=1,decritical=1,},},
s9={userinfo={"elite_challenge_name_9","ArtilleryLv3.png",29,90000,0,365,},tank={{"a10003",365},{"a10013",365},{"a10023",365},{"a10033",365},{"a10022",365},{"a10032",365},},skill={s101=23,s102=23,s103=23,s104=23,},attributeUp={attack=1.8,life=1.8,accurate=1,avoid=1,critical=1,decritical=1,},},
s10={userinfo={"elite_challenge_name_10","RocketLv3.png",30,99000,0,419,},tank={{"a10003",419},{"a10013",419},{"a10023",419},{"a10033",419},{"a10022",419},{"a10032",419},},skill={s101=23,s102=23,s103=23,s104=23,},attributeUp={attack=1.9,life=1.9,accurate=1,avoid=1,critical=1,decritical=1,},},
s11={userinfo={"elite_challenge_name_11","TankLv3.png",31,109000,0,481,},tank={{"a10003",481},{"a10013",481},{"a10023",481},{"a10033",481},{"a10022",481},{"a10032",481},},skill={s101=23,s102=23,s103=23,s104=23,},attributeUp={attack=2,life=2,accurate=1,avoid=1,critical=1,decritical=1,},},
s12={userinfo={"elite_challenge_name_12","WeaponLv3.png",32,120000,0,552,},tank={{"a10003",552},{"a10013",552},{"a10023",552},{"a10033",552},{"a10022",552},{"a10032",552},},skill={s101=24,s102=24,s103=24,s104=24,},attributeUp={attack=2.1,life=2.1,accurate=1,avoid=1,critical=1,decritical=1,},},
s13={userinfo={"elite_challenge_name_13","ArtilleryLv3.png",33,132000,0,633,},tank={{"a10003",633},{"a10013",633},{"a10023",633},{"a10033",633},{"a10022",633},{"a10032",633},},skill={s101=24,s102=24,s103=24,s104=24,},attributeUp={attack=2.2,life=2.2,accurate=1,avoid=1,critical=1,decritical=1,},},
s14={userinfo={"elite_challenge_name_14","RocketLv3.png",34,146000,0,726,},tank={{"a10003",726},{"a10013",726},{"a10023",726},{"a10033",726},{"a10022",726},{"a10032",726},},skill={s101=24,s102=24,s103=24,s104=24,},attributeUp={attack=2.3,life=2.3,accurate=1,avoid=1,critical=1,decritical=1,},},
s15={userinfo={"elite_challenge_name_15","TankLv3.png",35,161000,0,832,},tank={{"a10003",832},{"a10013",832},{"a10023",832},{"a10033",832},{"a10022",832},{"a10032",832},},skill={s101=25,s102=25,s103=25,s104=25,},attributeUp={attack=2.4,life=2.4,accurate=1,avoid=1,critical=1,decritical=1,},},
},

reward={
s1={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s2={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s4={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s5={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s7={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s8={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s10={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s11={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s13={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s14={point=100,resource={userinfo_gold=0},rate={p=1,r=50000}},
s3={point=200,rate={p=2},pool={{100},{1900,550,200,0,0,250,250,250,250,250,250,250,250,550,550,550,550,550,550,550,0,0,0,0,0,0,0,150,150,150,150,150,150,150,150,150,150,},{{"props_p446",3},{"props_p447",1},{"props_p447",2},{"props_p447",3},{"props_p448",1},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p624",1},{"props_p625",1},{"props_p626",1},{"props_p627",1},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p634",1},{"props_p635",1},{"props_p636",1},{"props_p637",1},{"hero_s23",1},{"hero_s29",1},{"hero_s31",1},{"hero_s33",1},{"hero_s34",1},{"hero_s35",1},{"hero_s36",1},{"hero_s37",1},{"hero_s38",1},{"hero_s40",1},},{20,14,12,7,0,5,5,5,5,5,5,5,5,10,10,10,10,10,10,10,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,}}},
s6={point=300,rate={p=3},pool={{100},{1100,900,650,0,0,250,250,250,250,250,250,250,250,500,500,500,500,500,500,500,50,50,50,50,50,50,50,150,150,150,150,150,150,150,150,150,150,},{{"props_p446",3},{"props_p447",1},{"props_p447",2},{"props_p447",3},{"props_p448",1},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p624",1},{"props_p625",1},{"props_p626",1},{"props_p627",1},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p634",1},{"props_p635",1},{"props_p636",1},{"props_p637",1},{"hero_s23",1},{"hero_s29",1},{"hero_s31",1},{"hero_s33",1},{"hero_s34",1},{"hero_s35",1},{"hero_s36",1},{"hero_s37",1},{"hero_s38",1},{"hero_s40",1},},{0,22,18,13,0,5,5,5,5,5,5,5,5,9,9,9,9,9,9,9,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,}}},
s9={point=400,rate={p=4},pool={{100},{0,850,750,550,0,250,250,250,250,250,250,250,250,450,450,450,450,450,450,450,100,100,100,100,100,100,100,200,200,200,200,200,200,200,200,200,200,},{{"props_p446",3},{"props_p447",1},{"props_p447",2},{"props_p447",3},{"props_p448",1},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p624",1},{"props_p625",1},{"props_p626",1},{"props_p627",1},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p634",1},{"props_p635",1},{"props_p636",1},{"props_p637",1},{"hero_s23",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},},{0,0,23,10,10,5,5,5,5,5,5,5,5,8,8,8,8,8,8,8,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,}}},
s12={point=500,rate={p=5},pool={{100},{0,600,550,550,450,250,250,250,250,250,250,250,250,350,350,350,350,350,350,350,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,},{{"props_p446",3},{"props_p447",1},{"props_p447",2},{"props_p447",3},{"props_p448",1},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p624",1},{"props_p625",1},{"props_p626",1},{"props_p627",1},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p634",1},{"props_p635",1},{"props_p636",1},{"props_p637",1},{"hero_s4",1},{"hero_s11",1},{"hero_s12",1},{"hero_s21",1},{"hero_s22",1},{"hero_s27",1},{"hero_s28",1},{"hero_s30",1},{"hero_s32",1},{"hero_s39",1},},{0,0,7,16,20,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,4,4,}}},
s15={point=600,rate={p=6},pool={{100},{0,0,550,800,800,250,250,250,250,250,250,250,250,300,300,300,300,300,300,300,250,250,250,250,250,250,250,200,200,200,200,200,200,200,200,200,200,},{{"props_p446",6},{"props_p447",2},{"props_p447",4},{"props_p447",6},{"props_p448",2},{"props_p611",2},{"props_p612",2},{"props_p613",2},{"props_p614",2},{"props_p615",2},{"props_p616",2},{"props_p617",2},{"props_p618",2},{"props_p621",2},{"props_p622",2},{"props_p623",2},{"props_p624",2},{"props_p625",2},{"props_p626",2},{"props_p627",2},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2},{"hero_s4",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s27",2},{"hero_s28",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},},{0,0,0,5,38,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,}}},
},

}
return expeditionCfg
