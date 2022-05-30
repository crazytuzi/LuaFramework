----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--dun_trial_data.xml
--------------------------------------

Config = Config or {} 
Config.DunTrialData = Config.DunTrialData or {}

-- -------------------trialtower_start-------------------
Config.DunTrialData.data_trialtower_length = 70
Config.DunTrialData.data_trialtower = {
	[1] = {name="第1层", floor=1, lev=1, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28002, headicon=30004, unit_list=28002, rem_power="16000", floor_tips="需要抗住敌方第一波进攻！", tips=""},
	[2] = {name="第2层", floor=2, lev=2, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28007, headicon=30015, unit_list=28007, rem_power="16000", floor_tips="需先手击败游侠射手", tips=""},
	[3] = {name="第3层", floor=3, lev=3, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28012, headicon=30022, unit_list=28012, rem_power="16000", floor_tips="吸血伯爵能稳定控制流血状态单位，需优先集火", tips=""},
	[4] = {name="第4层", floor=4, lev=4, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28017, headicon=20001, unit_list=28017, rem_power="16000", floor_tips="埃恩德隆魔法输出极高，需优先集火", tips=""},
	[5] = {name="第5层", floor=5, lev=5, loss={}, gain={}, first_award={{10210,1,1}}, award={{1,1,500},{10,1,250}}, unitid=28022, headicon=30017, unit_list=28022, rem_power="16000", floor_tips="有BUFF加成的剑圣攻击极高，需小心", tips=""},
	[6] = {name="第6层", floor=6, lev=6, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28027, headicon=20005, unit_list=28027, rem_power="16000", floor_tips="光明牧师能复活阵亡的队友", tips=""},
	[7] = {name="第7层", floor=7, lev=7, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28032, headicon=20002, unit_list=28032, rem_power="17000", floor_tips="灼烧流第一波伤害极高，需要辅助英雄恢复状态", tips=""},
	[8] = {name="第8层", floor=8, lev=8, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28037, headicon=20024, unit_list=28037, rem_power="18000", floor_tips="奥杜尔·铜须魔法输出极高，需优先集火", tips=""},
	[9] = {name="第9层", floor=9, lev=9, loss={}, gain={}, first_award={{2,1,50}}, award={{1,1,500},{10,1,250}}, unitid=28042, headicon=30014, unit_list=28042, rem_power="19000", floor_tips="美杜莎能石化流血单位", tips=""},
	[10] = {name="第10层", floor=10, lev=10, loss={}, gain={}, first_award={{10201,1,1}}, award={{1,1,500},{10,1,250},{10200,1,2}}, unitid=28047, headicon=30013, unit_list=28047, rem_power="20000", floor_tips="诅咒伤害无视防御，尽快结束战斗", tips=""},
	[11] = {name="第11层", floor=11, lev=11, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,750},{10,1,375}}, unitid=28052, headicon=30012, unit_list=28052, rem_power="22000", floor_tips="炽天使暴击后会追加攻击一个单位", tips=""},
	[12] = {name="第12层", floor=12, lev=12, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,750},{10,1,375}}, unitid=28057, headicon=30009, unit_list=28057, rem_power="24000", floor_tips="凯兰崔尔能让第一个阵亡的队友复活", tips=""},
	[13] = {name="第13层", floor=13, lev=13, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,750},{10,1,375}}, unitid=28062, headicon=30016, unit_list=28062, rem_power="26000", floor_tips="游侠射手是主力输出，集火击杀", tips=""},
	[14] = {name="第14层", floor=14, lev=14, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,750},{10,1,375}}, unitid=28067, headicon=30021, unit_list=28067, rem_power="28000", floor_tips="竖琴海妖概率睡眠敌方所有单位", tips=""},
	[15] = {name="第15层", floor=15, lev=15, loss={}, gain={}, first_award={{10201,1,1}}, award={{1,1,800},{10,1,400}}, unitid=28072, headicon=30020, unit_list=28072, rem_power="30000", floor_tips="甘道夫的魔法输出极高，需抗住其2波输出", tips=""},
	[16] = {name="第16层", floor=16, lev=16, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,800},{10,1,400}}, unitid=28077, headicon=30002, unit_list=28077, rem_power="35000", floor_tips="水元素对减速单位必定冰冻", tips=""},
	[17] = {name="第17层", floor=17, lev=17, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,800},{10,1,400}}, unitid=28082, headicon=30006, unit_list=28082, rem_power="38000", floor_tips="盖亚擅长持久战，尽早结束战斗", tips=""},
	[18] = {name="第18层", floor=18, lev=18, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,800},{10,1,400}}, unitid=28085, headicon=30010, unit_list=28087, rem_power="40000", floor_tips="炎魔之王气血低于40%时异常狂暴，需小心", tips=""},
	[19] = {name="第19层", floor=19, lev=19, loss={}, gain={}, first_award={{2,1,75}}, award={{1,1,800},{10,1,400}}, unitid=28092, headicon=30003, unit_list=28092, rem_power="42000", floor_tips="哈迪斯和吸血伯爵大概率能控制住所有目标", tips=""},
	[20] = {name="第20层", floor=20, lev=20, loss={}, gain={}, first_award={{10201,1,1}}, award={{1,1,800},{10,1,400},{10200,1,2}}, unitid=28097, headicon=30007, unit_list=28097, rem_power="45000", floor_tips="优先击杀或者控制阿努比斯", tips=""},
	[21] = {name="第21层", floor=21, lev=21, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28102, headicon=30005, unit_list=28102, rem_power="48000", floor_tips="奥丁的破甲配合群体输出能造成高伤害", tips=""},
	[22] = {name="第22层", floor=22, lev=22, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28107, headicon=30019, unit_list=28107, rem_power="50000", floor_tips="菲尼克斯拥有2条命，先击杀其他敌人", tips=""},
	[23] = {name="第23层", floor=23, lev=23, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28112, headicon=30018, unit_list=28112, rem_power="52000", floor_tips="冰霜巨龙防御极高，且输出不低，先破甲击杀", tips=""},
	[24] = {name="第24层", floor=24, lev=24, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28117, headicon=30017, unit_list=28117, rem_power="55000", floor_tips="剑圣的无敌斩每次能击杀一个英雄", tips=""},
	[25] = {name="第25层", floor=25, lev=25, loss={}, gain={}, first_award={{10201,1,1}}, award={{1,1,1000},{10,1,500}}, unitid=28122, headicon=30023, unit_list=28122, rem_power="60000", floor_tips="优先击杀输出英雄", tips=""},
	[26] = {name="第26层", floor=26, lev=26, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28127, headicon=20019, unit_list=28127, rem_power="70000", floor_tips="憎恶被攻击后会反伤，需要加血辅助持续治疗", tips=""},
	[27] = {name="第27层", floor=27, lev=27, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28132, headicon=30024, unit_list=28132, rem_power="72000", floor_tips="影刹有反击BUFF时需击杀其他敌人", tips=""},
	[28] = {name="第28层", floor=28, lev=28, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28135, headicon=30018, unit_list=28137, rem_power="76000", floor_tips="冰霜巨龙的吐息随着回合数增加伤害越来越高", tips=""},
	[29] = {name="第29层", floor=29, lev=29, loss={}, gain={}, first_award={{2,1,100}}, award={{1,1,1000},{10,1,500}}, unitid=28142, headicon=30016, unit_list=28142, rem_power="80000", floor_tips="抗住月之祭司重置后的一波输出", tips=""},
	[30] = {name="第30层", floor=30, lev=30, loss={}, gain={}, first_award={{81052,1,1}}, award={{1,1,1200},{10,1,600},{10200,1,2}}, unitid=28147, headicon=30001, unit_list=28147, rem_power="90000", floor_tips="优先击杀或者控制住宙斯", tips=""},
	[31] = {name="第31层", floor=31, lev=31, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28152, headicon=30004, unit_list=28152, rem_power="100000", floor_tips="击败主力输出雅典娜", tips=""},
	[32] = {name="第32层", floor=32, lev=32, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28155, headicon=20022, unit_list=28157, rem_power="105000", floor_tips="需同时击败2个BOSS，否则会无限复活！", tips=""},
	[33] = {name="第33层", floor=33, lev=33, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28162, headicon=30021, unit_list=28162, rem_power="110000", floor_tips="优先击杀魅魔女王", tips=""},
	[34] = {name="第34层", floor=34, lev=34, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28167, headicon=20001, unit_list=28167, rem_power="120000", floor_tips="优先击杀2个输出，注意德鲁伊复活", tips=""},
	[35] = {name="第35层", floor=35, lev=35, loss={}, gain={}, first_award={{10211,1,1}}, award={{1,1,1200},{10,1,600},{10200,1,2}}, unitid=28170, headicon=30020, unit_list=28172, rem_power="125000", floor_tips="击败甘道夫需要他两名学生的帮助", tips=""},
	[36] = {name="第36层", floor=36, lev=36, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28177, headicon=20005, unit_list=28177, rem_power="135000", floor_tips="暴走的阿瑞斯，注意其沉默技能", tips=""},
	[37] = {name="第37层", floor=37, lev=37, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28182, headicon=20002, unit_list=28182, rem_power="140000", floor_tips="灼烧暴击流，抗住第一波群体输出", tips=""},
	[38] = {name="第38层", floor=38, lev=38, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28185, headicon=30004, unit_list=28187, rem_power="150000", floor_tips="雅典娜会召唤仆从加入战斗", tips=""},
	[39] = {name="第39层", floor=39, lev=39, loss={}, gain={}, first_award={{2,1,125}}, award={{1,1,1200},{10,1,600}}, unitid=28192, headicon=30014, unit_list=28192, rem_power="155000", floor_tips="加强版的流血套路，优先击杀核心美杜莎吧", tips=""},
	[40] = {name="第40层", floor=40, lev=40, loss={}, gain={}, first_award={{10212,1,1}}, award={{1,1,1500},{10,1,750},{10200,1,2}}, unitid=28195, headicon=20023, unit_list=28197, rem_power="160000", floor_tips="岩石傀儡受到伤害会反击，优先击杀其队友吧", tips=""},
	[41] = {name="第41层", floor=41, lev=41, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28200, headicon=30012, unit_list=28202, rem_power="165000", floor_tips="注意炽天使残局收割", tips=""},
	[42] = {name="第42层", floor=42, lev=42, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28205, headicon=30015, unit_list=28207, rem_power="180000", floor_tips="击杀一个后，另外一个会进入狂暴状态", tips=""},
	[43] = {name="第43层", floor=43, lev=43, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28210, headicon=30007, unit_list=28212, rem_power="190000", floor_tips="控制或者优先击杀核心阿努比斯", tips=""},
	[44] = {name="第44层", floor=44, lev=44, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28215, headicon=20014, unit_list=28217, rem_power="200000", floor_tips="优先集火2个射手", tips=""},
	[45] = {name="第45层", floor=45, lev=45, loss={}, gain={}, first_award={{81062,1,1}}, award={{1,1,1500},{10,1,750},{10200,1,2}}, unitid=28220, headicon=30010, unit_list=28222, rem_power="210000", floor_tips="每个敌人死后都会给其他敌人增加超强BUFF", tips=""},
	[46] = {name="第46层", floor=46, lev=46, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28225, headicon=30002, unit_list=28227, rem_power="220000", floor_tips="防止己方被冰冻", tips=""},
	[47] = {name="第47层", floor=47, lev=47, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28230, headicon=30024, unit_list=28232, rem_power="230000", floor_tips="己方释放2技能或者3技能会遭到影刹攻击", tips=""},
	[48] = {name="第48层", floor=48, lev=48, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28235, headicon=30003, unit_list=28237, rem_power="235000", floor_tips="需要清除流血状态或者强力加血辅助", tips=""},
	[49] = {name="第49层", floor=49, lev=49, loss={}, gain={}, first_award={{2,1,175}}, award={{1,1,1500},{10,1,750}}, unitid=28240, headicon=30007, unit_list=28242, rem_power="250000", floor_tips="需优先集火路西法和阿努比斯", tips=""},
	[50] = {name="第50层", floor=50, lev=50, loss={}, gain={}, first_award={{10212,1,1}}, award={{1,1,1500},{10,1,750},{10200,1,2}}, unitid=28245, headicon=20003, unit_list=28247, rem_power="276000", floor_tips="雷诺矮人不会被其他两个矮人复活", tips=""},
	[51] = {name="第51层", floor=51, lev=51, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2000},{10,1,1000}}, unitid=28250, headicon=30005, unit_list=28252, rem_power="296000", floor_tips="需在对面输出攻击前集火击杀", tips=""},
	[52] = {name="第52层", floor=52, lev=52, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2000},{10,1,1000}}, unitid=28255, headicon=20001, unit_list=28257, rem_power="316000", floor_tips="优先击杀BOSS召唤出来的狼人", tips=""},
	[53] = {name="第53层", floor=53, lev=53, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2000},{10,1,1000}}, unitid=28260, headicon=30018, unit_list=28262, rem_power="336000", floor_tips="需要破甲英雄针对攻击冰霜巨龙", tips=""},
	[54] = {name="第54层", floor=54, lev=54, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2000},{10,1,1000}}, unitid=28265, headicon=30019, unit_list=28267, rem_power="356000", floor_tips="带有免疫或者恢复能力的英雄抵抗灼烧流", tips=""},
	[55] = {name="第55层", floor=55, lev=55, loss={}, gain={}, first_award={{81082,1,1}}, award={{1,1,2000},{10,1,1000},{10200,1,2}}, unitid=28270, headicon=30001, unit_list=28272, rem_power="376000", floor_tips="哈迪斯带有禁疗效果，提高自身英雄的生存能力", tips=""},
	[56] = {name="第56层", floor=56, lev=56, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2500},{10,1,1250}}, unitid=28275, headicon=30006, unit_list=28277, rem_power="396000", floor_tips="优先击杀凯兰崔尔，需要带破甲型英雄", tips=""},
	[57] = {name="第57层", floor=57, lev=57, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2500},{10,1,1250}}, unitid=28280, headicon=30020, unit_list=28282, rem_power="416000", floor_tips="抗住大法师4回合群攻且全部英雄不阵亡即可获胜", tips=""},
	[58] = {name="第58层", floor=58, lev=58, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2500},{10,1,1250}}, unitid=28285, headicon=30014, unit_list=28287, rem_power="436000", floor_tips="需带有全体免疫的英雄", tips=""},
	[59] = {name="第59层", floor=59, lev=59, loss={}, gain={}, first_award={{2,1,200}}, award={{1,1,2500},{10,1,1250}}, unitid=28290, headicon=30016, unit_list=28292, rem_power="456000", floor_tips="先手控制雅典娜", tips=""},
	[60] = {name="第60层", floor=60, lev=60, loss={}, gain={}, first_award={{10212,1,1}}, award={{1,1,2500},{10,1,1250},{10200,1,2}}, unitid=28295, headicon=30011, unit_list=28297, rem_power="476000", floor_tips="控制并先击杀黑暗之主的分身", tips=""},
	[61] = {name="第61层", floor=61, lev=61, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28300, headicon=30025, unit_list=28302, rem_power="500000", floor_tips="防止被敌方控制住", tips=""},
	[62] = {name="第62层", floor=62, lev=62, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28305, headicon=30002, unit_list=28307, rem_power="535000", floor_tips="优先击杀2个水元素", tips=""},
	[63] = {name="第63层", floor=63, lev=63, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28310, headicon=30018, unit_list=28312, rem_power="596000", floor_tips="冰龙每3回合切换一次免疫效果", tips=""},
	[64] = {name="第64层", floor=64, lev=64, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28315, headicon=30009, unit_list=28317, rem_power="622000", floor_tips="需快速击杀3个输出", tips=""},
	[65] = {name="第65层", floor=65, lev=65, loss={}, gain={}, first_award={{10212,1,1}}, award={{1,1,3000},{10,1,1500},{10200,1,2}}, unitid=28320, headicon=30019, unit_list=28322, rem_power="684000", floor_tips="凤凰复活冷却只有3回合，需要在3回合内击杀", tips=""},
	[66] = {name="第66层", floor=66, lev=66, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28325, headicon=30011, unit_list=28327, rem_power="713000", floor_tips="小心黑暗之主收割", tips=""},
	[67] = {name="第67层", floor=67, lev=67, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28330, headicon=30020, unit_list=28332, rem_power="765000", floor_tips="甘道夫每出手一次额外释放一次狂风", tips=""},
	[68] = {name="第68层", floor=68, lev=68, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28335, headicon=30007, unit_list=28337, rem_power="810000", floor_tips="每4回合阿努比斯引爆一次诅咒", tips=""},
	[69] = {name="第69层", floor=69, lev=69, loss={}, gain={}, first_award={{2,1,250}}, award={{1,1,3000},{10,1,1500}}, unitid=28340, headicon=30026, unit_list=28342, rem_power="861000", floor_tips="控制敌方输出", tips=""},
	[70] = {name="第70层", floor=70, lev=70, loss={}, gain={}, first_award={{10212,1,1}}, award={{1,1,3000},{10,1,1500},{10200,1,2}}, unitid=28345, headicon=30028, unit_list=28347, rem_power="900000", floor_tips="丘比特免疫法术伤害，雷神免疫物理伤害", tips=""}
}
-- -------------------trialtower_end---------------------


-- -------------------constant_start-------------------
Config.DunTrialData.data_constant_length = 7
Config.DunTrialData.data_constant = {
	["id_normal"] = 1,
	["id_hard"] = 2,
	["reset_time"] = {{1,0,0,0},{16,0,0,0}},
	["hard_open"] = 50,
	["free_open"] = {21,10,0,0},
	["free_close"] = {21,21,0,0},
	["open_lev"] = 15
}
-- -------------------constant_end---------------------


-- -------------------showgain_start-------------------
Config.DunTrialData.data_showgain_length = 4
Config.DunTrialData.data_showgain = {
	[31] = {id=31, gain={{14705,1,1}}, desc="概率奖励"},
	[33] = {id=33, gain={{10201,1,1}}, desc="第5层奖励"},
	[34] = {id=34, gain={{14705,1,10}}, desc="第10层奖励"},
	[35] = {id=35, gain={{10213,1,5}}, desc="第15层奖励"}
}
-- -------------------showgain_end---------------------


-- -------------------hardtower_start-------------------
Config.DunTrialData.data_hardtower_length = 15
Config.DunTrialData.data_hardtower = {
	[1] = {name="第1层", floor=1, lev=50, loss={}, award={{1,1,10000},{13,1,100}}, drop_id=50040, unitid=28500, headicon=30002, unit_list=28501, rem_power="225000", floor_tips="优先控制或者击杀月之骑士"},
	[2] = {name="第2层", floor=2, lev=50, loss={}, award={{1,1,10000},{13,1,100}}, drop_id=50041, unitid=28505, headicon=20001, unit_list=28506, rem_power="240000", floor_tips="敌方强力AOE，注意己方气血"},
	[3] = {name="第3层", floor=3, lev=50, loss={}, award={{1,1,10000},{13,1,100}}, drop_id=50042, unitid=28510, headicon=20017, unit_list=28511, rem_power="250000", floor_tips="防止敌方睡眠单点秒杀，优先击杀狼人"},
	[4] = {name="第4层", floor=4, lev=50, loss={}, award={{1,1,10000},{13,1,100}}, drop_id=50043, unitid=28515, headicon=30016, unit_list=28516, rem_power="260000", floor_tips="控制阿努比斯，己方最好有免疫BUFF"},
	[5] = {name="第5层", floor=5, lev=50, loss={}, award={{10201,1,1},{1,1,10000},{13,1,100}}, drop_id=0, unitid=28520, headicon=30025, unit_list=28521, rem_power="275000", floor_tips="控制甘道夫或者赫拉，带强力加血"},
	[6] = {name="第6层", floor=6, lev=50, loss={}, award={{1,1,15000},{13,1,150}}, drop_id=50044, unitid=28525, headicon=30005, unit_list=28526, rem_power="285000", floor_tips="带具有净化或者免疫的辅助"},
	[7] = {name="第7层", floor=7, lev=50, loss={}, award={{1,1,15000},{13,1,150}}, drop_id=50045, unitid=28530, headicon=30004, unit_list=28531, rem_power="300000", floor_tips="净化身上减益效果"},
	[8] = {name="第8层", floor=8, lev=50, loss={}, award={{1,1,15000},{13,1,150}}, drop_id=50046, unitid=28535, headicon=30010, unit_list=28536, rem_power="320000", floor_tips="带净化辅助和强力奶妈，先手控制输出"},
	[9] = {name="第9层", floor=9, lev=50, loss={}, award={{1,1,15000},{13,1,150}}, drop_id=50047, unitid=28540, headicon=20013, unit_list=28541, rem_power="330000", floor_tips="点杀其中一个水元素"},
	[10] = {name="第10层", floor=10, lev=50, loss={}, award={{14705,1,10},{1,1,15000},{13,1,150}}, drop_id=0, unitid=28545, headicon=40000, unit_list=28546, rem_power="340000", floor_tips="BOSS每隔3回合会直接秒杀一个英雄"},
	[11] = {name="第11层", floor=11, lev=50, loss={}, award={{1,1,20000},{13,1,200}}, drop_id=50048, unitid=28550, headicon=30018, unit_list=28551, rem_power="360000", floor_tips="需要稳定破甲BOSS"},
	[12] = {name="第12层", floor=12, lev=50, loss={}, award={{1,1,20000},{13,1,200}}, drop_id=50049, unitid=28555, headicon=30011, unit_list=28556, rem_power="380000", floor_tips="需减速打条，延缓BOSS攻击频率"},
	[13] = {name="第13层", floor=13, lev=50, loss={}, award={{1,1,20000},{13,1,200}}, drop_id=50050, unitid=28560, headicon=30006, unit_list=28561, rem_power="395000", floor_tips="BOSS免疫直接伤害，用持续伤害耗死"},
	[14] = {name="第14层", floor=14, lev=50, loss={}, award={{1,1,20000},{13,1,200}}, drop_id=50051, unitid=28565, headicon=30012, unit_list=28566, rem_power="410000", floor_tips="炽天使攻击必定暴击"},
	[15] = {name="第15层", floor=15, lev=50, loss={}, award={{10213,1,5},{1,1,20000},{13,1,200}}, drop_id=0, unitid=28570, headicon=30010, unit_list=28571, rem_power="430000", floor_tips="在炎魔之王吃掉小怪前把小怪清掉"}
}
-- -------------------hardtower_end---------------------
