

---@classdef record_buff_info
local record_buff_info = {}
  
record_buff_info.id = 0 --buffID  
record_buff_info.name = "" --buff名称  
record_buff_info.res_id = "" --buff特效  
record_buff_info.res_group = 0 --buff特效组  
record_buff_info.buff_btype = 0 --buff大类型  
record_buff_info.buff_stype = 0 --buff增减益  
record_buff_info.buff_affect_type = 0 --buff作用类型  
record_buff_info.formula = 0 --buff引用公式  
record_buff_info.formula_value1 = 0 --buff公式数值1  
record_buff_info.formula_value2 = 0 --buff公式数值2  
record_buff_info.is_clear = 0 --是否能被清除  
record_buff_info.buff_tween = "" --buff冒字效果  
record_buff_info.buff_tween_pic = "" --buff冒字图片


buff_info = {
   _data = {
    [1] = {1,"测试降双防","",1,1,2,24,4,500,0,1,"tween_buff_down","debuff_fangyu",},
    [2] = {2,"测试中毒","sp_debuff_fire_1",1,2,2,1,3,500,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [3] = {3,"测试加自身伤害加成","",1,1,1,25,4,500,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [4] = {4,"测试加闪避率100%","",1,1,1,15,6,1000,0,1,"tween_buff_up","buff_huibi",},
    [5] = {5,"测试眩晕","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [6] = {6,"测试董卓技能附带buff","sp_buff_def_1",1,1,1,27,6,300,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [7] = {7,"测试吕布技能附带buff","",1,1,1,25,6,500,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [8] = {8,"测试袁绍技能附带buff","",1,1,2,22,4,200,0,1,"tween_buff_down","debuff_gongji",},
    [9] = {9,"测试左慈技能附带buff","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [10] = {10,"测试貂蝉技能附带buff","",1,2,1,2,3,200,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [11] = {11,"测试张飞技能附带buff","",1,1,2,24,4,300,0,1,"tween_buff_down","debuff_fangyu",},
    [12] = {12,"测试关羽技能附带buff","",1,1,1,21,4,300,0,1,"tween_buff_up","buff_gongji",},
    [13] = {13,"测试孟获技能附带buff","sp_buff_def_1",1,1,1,27,6,9999,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [14] = {14,"测试诸葛亮技能附带buff","sp_debuff_fire_1",1,2,2,1,3,200,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [15] = {15,"测试黄忠技能附带buff","",1,1,1,15,6,300,0,1,"tween_buff_up","buff_huibi",},
    [16] = {16,"测试刘备技能附带buff","",1,1,1,21,4,200,0,1,"tween_buff_up","buff_gongji",},
    [17] = {17,"测试吕布貂蝉合击附带buff","",1,1,1,25,6,500,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [18] = {18,"测试关羽刘备合击附带buff","",1,1,1,25,6,500,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [19] = {19,"测试吕布貂蝉合击附带buff2","sp_buff_def_1",1,1,1,27,6,500,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [20] = {20,"测试关羽刘备合击附带buff2","sp_buff_def_1",1,1,1,27,6,500,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [21] = {21,"测试诸葛亮技能附带buff2","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [22] = {22,"测试刘备技能附带buff2","sp_buff_def_1",1,1,1,23,4,200,0,1,"tween_buff_up","buff_fangyu",},
    [23] = {101,"曹操的技能BUFF","",1,1,1,21,4,500,0,1,"tween_buff_up","buff_gongji",},
    [24] = {102,"曹仁的技能BUFF","sp_buff_def_1",1,1,1,27,6,9999,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [25] = {103,"夏侯惇的技能BUFF","",1,1,1,21,4,300,0,1,"tween_buff_up","buff_gongji",},
    [26] = {104,"张辽的技能BUFF","",1,1,2,28,6,180,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [27] = {105,"荀彧的技能BUFF","sp_buff_def_1",1,1,1,27,6,800,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [28] = {106,"荀攸的技能BUFF","",1,1,1,7,4,300,0,1,"tween_buff_up","buff_mogong",},
    [29] = {107,"司马懿的技能BUFF","sp_debuff_toxin_1",1,2,2,1,3,500,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [30] = {108,"典韦的技能BUFF","sp_buff_def_1",1,1,1,27,6,500,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [31] = {109,"关羽的技能BUFF","",1,1,1,21,4,500,0,1,"tween_buff_up","buff_gongji",},
    [32] = {110,"张飞的技能BUFF","",1,1,2,22,4,180,0,1,"tween_buff_down","debuff_gongji",},
    [33] = {111,"赵云的技能BUFF","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [34] = {112,"马超的技能BUFF","",1,1,2,28,6,500,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [35] = {113,"刘备的技能BUFF","sp_buff_def_1",1,1,1,19,6,200,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [36] = {114,"诸葛亮的技能BUFF","",1,1,1,21,4,200,0,1,"tween_buff_up","buff_gongji",},
    [37] = {115,"马良的技能BUFF","",1,1,1,7,4,800,0,1,"tween_buff_up","buff_mogong",},
    [38] = {116,"夏侯涓的技能BUFF","",1,1,1,17,6,300,0,1,"tween_buff_up","buff_baoji",},
    [39] = {117,"孙坚的技能BUFF","",1,1,1,17,6,1000,0,1,"tween_buff_up","buff_baoji",},
    [40] = {118,"孙策的技能BUFF","",1,1,1,21,4,300,0,1,"tween_buff_up","buff_gongji",},
    [41] = {119,"周瑜的技能BUFF","sp_debuff_fire_1",1,2,2,1,3,800,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [42] = {120,"鲁肃的技能BUFF","",1,1,2,22,4,120,0,1,"tween_buff_down","debuff_gongji",},
    [43] = {121,"吕蒙的技能BUFF","",1,1,2,28,6,300,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [44] = {122,"陆逊的技能BUFF","sp_debuff_fire_1",1,2,2,1,3,500,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [45] = {123,"步练师的技能BUFF","sp_buff_def_1",1,1,1,11,4,500,0,1,"tween_buff_up","buff_mofang",},
    [46] = {124,"大乔的技能BUFF","sp_buff_def_1",1,1,1,9,4,500,0,1,"tween_buff_up","buff_wufang",},
    [47] = {125,"小乔的技能BUFF","",1,1,1,7,4,800,0,1,"tween_buff_up","buff_mogong",},
    [48] = {126,"吕布的技能BUFF","",1,1,1,21,4,500,0,1,"tween_buff_up","buff_gongji",},
    [49] = {127,"袁绍的技能BUFF","sp_buff_def_1",1,1,1,9,4,200,0,1,"tween_buff_up","buff_wufang",},
    [50] = {128,"蔡文姬的技能BUFF","sp_buff_def_1",1,1,1,11,4,500,0,1,"tween_buff_up","buff_mofang",},
    [51] = {129,"左慈的技能BUFF","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [52] = {130,"卢植的技能BUFF","",1,1,1,17,6,300,0,1,"tween_buff_up","buff_baoji",},
    [53] = {131,"华佗的技能BUFF","",1,2,2,2,3,500,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [54] = {132,"张角的技能BUFF","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [55] = {133,"夏侯惇的技能BUFF2","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [56] = {134,"关羽的技能BUFF2","sp_buff_def_1",1,1,1,23,4,500,0,1,"tween_buff_up","buff_fangyu",},
    [57] = {135,"刘备的技能BUFF2","",1,2,1,2,3,400,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [58] = {136,"吕布的技能BUFF2","sp_buff_def_1",1,1,1,23,4,500,0,1,"tween_buff_up","buff_fangyu",},
    [59] = {137,"袁绍的技能BUFF2","",1,1,1,5,4,100,0,1,"tween_buff_up","buff_wugong",},
    [60] = {138,"蔡文姬的技能BUFF2","",1,1,1,7,4,500,0,1,"tween_buff_up","buff_mogong",},
    [61] = {139,"左慈的技能BUFF2","sp_debuff_toxin_1",1,2,2,1,3,500,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [62] = {140,"卢植的技能BUFF2","",1,1,1,13,6,300,0,1,"tween_buff_up","buff_mingzhong",},
    [63] = {201,"夏侯惇+夏侯渊合击buff1","",1,1,1,21,4,350,0,1,"tween_buff_up","buff_gongji",},
    [64] = {202,"典韦+许褚合击buff1","sp_buff_def_1",1,1,1,27,6,600,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [65] = {203,"张辽+张郃合击buff1","",1,1,2,28,6,250,0,1,"tween_buff_down","debuff_fangyu",},
    [66] = {204,"关羽+刘备+张飞合击buff1","",1,1,2,21,4,600,0,1,"tween_buff_up","buff_gongji",},
    [67] = {205,"赵云+刘备合击buff1","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [68] = {206,"周瑜+孙策合击buff1","sp_debuff_fire_1",1,2,2,1,3,1000,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [69] = {207,"大乔+小乔合击buff1","sp_buff_def_1",1,1,1,9,4,1000,0,1,"tween_buff_up","buff_wufang",},
    [70] = {208,"吕蒙+陆逊合击buff1","",1,1,2,28,6,450,0,1,"tween_buff_down","debuff_fangyu",},
    [71] = {209,"吕布+貂蝉合击buff1","",1,1,1,21,4,600,0,1,"tween_buff_up","buff_gongji",},
    [72] = {210,"卢植+公孙瓒合击buff1","",1,1,1,17,6,500,0,1,"tween_buff_up","buff_baoji",},
    [73] = {211,"夏侯惇+夏侯渊合击buff2","sp_debuff_swoon_1",1,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [74] = {212,"吕布+貂蝉合击buff2","sp_buff_def_1",1,1,1,23,4,600,0,1,"tween_buff_up","buff_fangyu",},
    [75] = {213,"卢植+公孙瓒合击buff2","",1,1,1,13,6,500,0,1,"tween_buff_up","buff_mingzhong",},
    [76] = {214,"关羽+刘备+张飞合击buff2","sp_buff_def_1",1,1,1,23,4,600,0,1,"tween_buff_up","buff_fangyu",},
    [77] = {141,"佩刀步兵","sp_buff_def_1",1,1,1,27,6,300,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [78] = {142,"骑虎骑士","",1,1,1,21,4,300,0,1,"tween_buff_up","buff_gongji",},
    [79] = {143,"投石车","",1,1,1,21,4,300,0,1,"tween_buff_up","buff_gongji",},
    [80] = {144,"弓骑兵","",1,1,2,28,6,100,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [81] = {145,"舞娘","",1,1,1,25,4,100,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [82] = {146,"文官","",1,1,2,22,4,50,0,1,"tween_buff_down","debuff_gongji",},
    [83] = {147,"舞娘","sp_buff_def_1",1,1,1,27,6,100,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [84] = {1001,"持续伤害 灼烧 35%","sp_debuff_fire_1",1,2,2,1,3,350,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [85] = {1002,"持续伤害 灼烧 50%","sp_debuff_fire_1",1,2,2,1,3,500,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [86] = {1003,"持续伤害 灼烧 60%","sp_debuff_fire_1",1,2,2,1,3,600,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [87] = {1004,"持续伤害 灼烧 70%","sp_debuff_fire_1",1,2,2,1,3,700,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [88] = {1005,"持续伤害 中毒 35%","sp_debuff_toxin_1",2,2,2,1,3,350,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [89] = {1006,"持续伤害 中毒 50%","sp_debuff_toxin_1",2,2,2,1,3,500,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [90] = {1007,"持续伤害 中毒 60%","sp_debuff_toxin_1",2,2,2,1,3,600,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [91] = {1008,"持续伤害 中毒 70%","sp_debuff_toxin_1",2,2,2,1,3,700,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [92] = {1009,"持续伤害 中毒 20%","sp_debuff_toxin_1",2,2,2,1,3,200,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [93] = {1010,"持续伤害 中毒 15%","sp_debuff_toxin_1",2,2,2,1,3,150,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [94] = {1011,"持续伤害 灼烧 20%","sp_debuff_fire_1",1,2,2,1,3,200,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [95] = {1012,"持续伤害 灼烧 30%","sp_debuff_fire_1",1,2,2,1,3,300,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [96] = {1013,"持续伤害 中毒 30%","sp_debuff_toxin_1",2,2,2,1,3,300,0,1,"tween_buff_down","zhuangtaitishi_zhongdu",},
    [97] = {1014,"持续伤害 灼烧 40%","sp_debuff_fire_1",1,2,2,1,3,400,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [98] = {1015,"持续伤害 灼烧 80%","sp_debuff_fire_1",1,2,2,1,3,800,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [99] = {1016,"持续伤害 灼烧 90%","sp_debuff_fire_1",1,2,2,1,3,900,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [100] = {1017,"持续伤害 灼烧 20%-不能清除","sp_debuff_fire_1",1,2,2,1,3,200,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [101] = {1018,"持续伤害 灼烧 30%-不能清除","sp_debuff_fire_1",1,2,2,1,3,300,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [102] = {1019,"持续伤害 灼烧 40%-不能清除","sp_debuff_fire_1",1,2,2,1,3,400,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [103] = {1020,"持续伤害 灼烧 50%-不能清除","sp_debuff_fire_1",1,2,2,1,3,500,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [104] = {1021,"持续伤害 灼烧 60%-不能清除","sp_debuff_fire_1",1,2,2,1,3,600,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [105] = {1022,"持续伤害 灼烧 55%-不能清除","sp_debuff_fire_1",1,2,2,1,3,550,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [106] = {1023,"持续伤害 灼烧 70%-不能清除","sp_debuff_fire_1",1,2,2,1,3,700,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [107] = {1024,"持续伤害 灼烧 80%-不能清除","sp_debuff_fire_1",1,2,2,1,3,800,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [108] = {1025,"持续伤害 灼烧 45%-不能清除","sp_debuff_fire_1",1,2,2,1,3,450,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [109] = {1026,"持续伤害 灼烧 120%-不能清除","sp_debuff_fire_1",1,2,2,1,3,1200,0,0,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [110] = {1027,"持续伤害 灼烧 100%","sp_debuff_fire_1",1,2,2,1,3,1000,0,1,"tween_buff_down","zhuangtaitishi_zhuoshao",},
    [111] = {2001,"持续治疗  20%","",1,2,1,2,3,200,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [112] = {2002,"持续治疗  25%","",1,2,1,2,3,250,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [113] = {2003,"持续治疗  30%","",1,2,1,2,3,300,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [114] = {2004,"持续治疗  35%","",1,2,1,2,3,350,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [115] = {2005,"持续治疗  40%","",1,2,1,2,3,400,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [116] = {2006,"持续治疗  110%","",1,2,1,2,3,1100,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [117] = {2007,"持续治疗  140%","",1,2,1,2,3,1400,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [118] = {2008,"持续治疗  80%","",1,2,1,2,3,800,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [119] = {2009,"持续治疗  50%","",1,2,1,2,3,500,0,1,"tween_buff_up","zhuangtaitishi_huifu",},
    [120] = {13001,"命中率+  10%","",1,1,1,13,6,100,0,1,"tween_buff_up","buff_mingzhong",},
    [121] = {13002,"命中率+  15%","",1,1,1,13,6,150,0,1,"tween_buff_up","buff_mingzhong",},
    [122] = {13003,"命中率+  20%","",1,1,1,13,6,200,0,1,"tween_buff_up","buff_mingzhong",},
    [123] = {13004,"命中率+  30%","",1,1,1,13,6,300,0,1,"tween_buff_up","buff_mingzhong",},
    [124] = {13005,"命中率+  40%","",1,1,1,13,6,400,0,1,"tween_buff_up","buff_mingzhong",},
    [125] = {13006,"命中率+  50%","",1,1,1,13,6,500,0,1,"tween_buff_up","buff_mingzhong",},
    [126] = {14003,"命中率-  20%","",1,1,1,14,6,200,0,1,"tween_buff_down","debuff_mingzhong",},
    [127] = {15001,"闪避率+  10%","",1,1,1,15,6,100,0,1,"tween_buff_up","buff_huibi",},
    [128] = {15002,"闪避率+  15%","",1,1,1,15,6,150,0,1,"tween_buff_up","buff_huibi",},
    [129] = {15003,"闪避率+  20%","",1,1,1,15,6,200,0,1,"tween_buff_up","buff_huibi",},
    [130] = {15004,"闪避率+  30%","",1,1,1,15,6,300,0,1,"tween_buff_up","buff_huibi",},
    [131] = {15005,"闪避率+  40%","",1,1,1,15,6,400,0,1,"tween_buff_up","buff_huibi",},
    [132] = {15006,"闪避率+  50%","",1,1,1,15,6,500,0,1,"tween_buff_up","buff_huibi",},
    [133] = {17001,"暴击率+  10%","",1,1,1,17,6,100,0,1,"tween_buff_up","buff_baoji",},
    [134] = {17002,"暴击率+  15%","",1,1,1,17,6,150,0,1,"tween_buff_up","buff_baoji",},
    [135] = {17003,"暴击率+  20%","",1,1,1,17,6,200,0,1,"tween_buff_up","buff_baoji",},
    [136] = {17004,"暴击率+  30%","",1,1,1,17,6,300,0,1,"tween_buff_up","buff_baoji",},
    [137] = {17005,"暴击率+  40%","",1,1,1,17,6,400,0,1,"tween_buff_up","buff_baoji",},
    [138] = {17006,"暴击率+  50%","",1,1,1,17,6,500,0,1,"tween_buff_up","buff_baoji",},
    [139] = {19001,"抗暴率+  10%","sp_buff_def_1",3,1,1,19,6,100,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [140] = {19002,"抗暴率+  15%","sp_buff_def_1",3,1,1,19,6,150,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [141] = {19003,"抗暴率+  20%","sp_buff_def_1",3,1,1,19,6,200,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [142] = {19004,"抗暴率+  30%","sp_buff_def_1",3,1,1,19,6,300,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [143] = {19005,"抗暴率+  40%","sp_buff_def_1",3,1,1,19,6,400,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [144] = {21001,"攻击+  10%","",1,1,1,21,4,100,0,1,"tween_buff_up","buff_gongji",},
    [145] = {21002,"攻击+  15%","",1,1,1,21,4,150,0,1,"tween_buff_up","buff_gongji",},
    [146] = {21003,"攻击+  20%","",1,1,1,21,4,200,0,1,"tween_buff_up","buff_gongji",},
    [147] = {21004,"攻击+  30%","",1,1,1,21,4,300,0,1,"tween_buff_up","buff_gongji",},
    [148] = {21005,"攻击+  40%","",1,1,1,21,4,400,0,1,"tween_buff_up","buff_gongji",},
    [149] = {22001,"攻击-  10%","",1,1,2,22,4,100,0,1,"tween_buff_down","debuff_gongji",},
    [150] = {22002,"攻击-  15%","",1,1,2,22,4,150,0,1,"tween_buff_down","debuff_gongji",},
    [151] = {22003,"攻击-  20%","",1,1,2,22,4,200,0,1,"tween_buff_down","debuff_gongji",},
    [152] = {22004,"攻击-  30%","",1,1,2,22,4,300,0,1,"tween_buff_down","debuff_gongji",},
    [153] = {22005,"攻击-  40%","",1,1,2,22,4,400,0,1,"tween_buff_down","debuff_gongji",},
    [154] = {22006,"攻击-  25%","",1,1,2,22,4,250,0,1,"tween_buff_down","debuff_gongji",},
    [155] = {23001,"物防&amp;魔防+  15%","sp_buff_def_1",3,1,1,23,4,150,0,1,"tween_buff_up","buff_fangyu",},
    [156] = {23002,"物防&amp;魔防+  30%","sp_buff_def_1",3,1,1,23,4,300,0,1,"tween_buff_up","buff_fangyu",},
    [157] = {23003,"物防&amp;魔防+  50%","sp_buff_def_1",3,1,1,23,4,500,0,1,"tween_buff_up","buff_fangyu",},
    [158] = {23004,"物防&amp;魔防+  60%","sp_buff_def_1",3,1,1,23,4,600,0,1,"tween_buff_up","buff_fangyu",},
    [159] = {23005,"物防&amp;魔防+  80%","sp_buff_def_1",3,1,1,23,4,800,0,1,"tween_buff_up","buff_fangyu",},
    [160] = {24001,"物防&amp;魔防-  15%","",1,1,2,24,4,150,0,1,"tween_buff_down","debuff_fangyu",},
    [161] = {24002,"物防&amp;魔防-  30%","",1,1,2,24,4,300,0,1,"tween_buff_down","debuff_fangyu",},
    [162] = {24003,"物防&amp;魔防-  50%","",1,1,2,24,4,500,0,1,"tween_buff_down","debuff_fangyu",},
    [163] = {24004,"物防&amp;魔防-  60%","",1,1,2,24,4,600,0,1,"tween_buff_down","debuff_fangyu",},
    [164] = {24005,"物防&amp;魔防-  80%","",1,1,2,24,4,800,0,1,"tween_buff_down","debuff_fangyu",},
    [165] = {24006,"物防&amp;魔防-  20%","",1,1,2,24,4,200,0,1,"tween_buff_down","debuff_fangyu",},
    [166] = {24007,"物防&amp;魔防-  5%","",1,1,2,24,4,50,0,1,"tween_buff_down","debuff_fangyu",},
    [167] = {24008,"物防&amp;魔防-  10%","",1,1,2,24,4,100,0,1,"tween_buff_down","debuff_fangyu",},
    [168] = {25001,"伤害+  20%","",1,1,1,25,6,200,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [169] = {25002,"伤害+  30%","",1,1,1,25,6,300,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [170] = {25003,"伤害+  40%","",1,1,1,25,6,400,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [171] = {25004,"伤害+  50%","",1,1,1,25,6,500,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [172] = {25005,"伤害+  70%","",1,1,1,25,6,700,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [173] = {25006,"伤害+  15%","",1,1,1,25,6,150,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [174] = {25007,"伤害+  10%","",1,1,1,25,6,100,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [175] = {25008,"伤害+  25%","",1,1,1,25,6,250,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [176] = {25009,"伤害+  35%","",1,1,1,25,6,350,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [177] = {25010,"伤害+  5%","",1,1,1,25,6,50,0,1,"tween_buff_up","zhuangtaitishi_guwu",},
    [178] = {26001,"伤害-  10%","",1,1,2,26,6,100,0,1,"tween_buff_down","debuff_gongji",},
    [179] = {26002,"伤害-  15%","",1,1,2,26,6,150,0,1,"tween_buff_down","debuff_gongji",},
    [180] = {26003,"伤害-  20%","",1,1,2,26,6,200,0,1,"tween_buff_down","debuff_gongji",},
    [181] = {26004,"伤害-  30%","",1,1,2,26,6,300,0,1,"tween_buff_down","debuff_gongji",},
    [182] = {26005,"伤害-  40%","",1,1,2,26,6,400,0,1,"tween_buff_down","debuff_gongji",},
    [183] = {26006,"伤害-  25%","",1,1,2,26,6,250,0,1,"tween_buff_down","debuff_gongji",},
    [184] = {27001,"伤害减免+  10%","sp_buff_def_1",3,1,1,27,6,100,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [185] = {27002,"伤害减免+  15%","sp_buff_def_1",3,1,1,27,6,150,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [186] = {27003,"伤害减免+  20%","sp_buff_def_1",3,1,1,27,6,200,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [187] = {27004,"伤害减免+  25%","sp_buff_def_1",3,1,1,27,6,250,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [188] = {27005,"伤害减免+  30%","sp_buff_def_1",3,1,1,27,6,300,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [189] = {27006,"伤害减免+  35%","sp_buff_def_1",3,1,1,27,6,350,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [190] = {27007,"伤害减免+  40%","sp_buff_def_1",3,1,1,27,6,400,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [191] = {27008,"伤害减免+  55%","sp_buff_def_1",3,1,1,27,6,550,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [192] = {27009,"伤害减免+  70%","sp_buff_def_1",3,1,1,27,6,700,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [193] = {27010,"伤害减免+  999.9%","sp_buff_def_1",3,1,1,27,6,9999,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [194] = {27011,"伤害减免+  5%","sp_buff_def_1",3,1,1,27,6,50,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [195] = {27012,"伤害减免+  18%","sp_buff_def_1",3,1,1,27,6,180,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [196] = {27013,"伤害减免+  21%","sp_buff_def_1",3,1,1,27,6,210,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [197] = {27014,"伤害减免+  24%","sp_buff_def_1",3,1,1,27,6,240,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [198] = {27015,"伤害减免+  27%","sp_buff_def_1",3,1,1,27,6,270,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [199] = {27016,"伤害减免+  65%","sp_buff_def_1",3,1,1,27,6,650,0,1,"tween_buff_up","zhuangtaitishi_tiebi",},
    [200] = {28001,"伤害减免-  12%","",1,1,2,28,6,120,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [201] = {28002,"伤害减免-  18%","",1,1,2,28,6,180,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [202] = {28003,"伤害减免-  25%","",1,1,2,28,6,250,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [203] = {28004,"伤害减免-  30%","",1,1,2,28,6,300,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [204] = {28005,"伤害减免-  35%","",1,1,2,28,6,350,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [205] = {28006,"伤害减免-  50%","",1,1,2,28,6,500,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [206] = {28007,"伤害减免-  10%","",1,1,2,28,6,100,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [207] = {28008,"伤害减免-  15%","",1,1,2,28,6,150,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [208] = {28009,"伤害减免-  20%","",1,1,2,28,6,200,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [209] = {28010,"伤害减免-  5%","",1,1,2,28,6,50,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [210] = {28011,"伤害减免-  40%","",1,1,2,28,6,400,0,1,"tween_buff_down","zhuangtaitishi_cuiruo",},
    [211] = {29001,"眩晕（无法行动）  0%","sp_debuff_swoon_1",4,1,2,29,0,0,0,1,"tween_buff_down","zhuangtaitishi_xuanyun",},
    [212] = {30001,"免疫所有减益状态","sp_debuff_lmmortal",5,1,1,31,0,0,0,1,"tween_buff_up","buff_mianyijianyi",},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [1001] = 84,
    [1002] = 85,
    [1003] = 86,
    [1004] = 87,
    [1005] = 88,
    [1006] = 89,
    [1007] = 90,
    [1008] = 91,
    [1009] = 92,
    [101] = 23,
    [1010] = 93,
    [1011] = 94,
    [1012] = 95,
    [1013] = 96,
    [1014] = 97,
    [1015] = 98,
    [1016] = 99,
    [1017] = 100,
    [1018] = 101,
    [1019] = 102,
    [102] = 24,
    [1020] = 103,
    [1021] = 104,
    [1022] = 105,
    [1023] = 106,
    [1024] = 107,
    [1025] = 108,
    [1026] = 109,
    [1027] = 110,
    [103] = 25,
    [104] = 26,
    [105] = 27,
    [106] = 28,
    [107] = 29,
    [108] = 30,
    [109] = 31,
    [11] = 11,
    [110] = 32,
    [111] = 33,
    [112] = 34,
    [113] = 35,
    [114] = 36,
    [115] = 37,
    [116] = 38,
    [117] = 39,
    [118] = 40,
    [119] = 41,
    [12] = 12,
    [120] = 42,
    [121] = 43,
    [122] = 44,
    [123] = 45,
    [124] = 46,
    [125] = 47,
    [126] = 48,
    [127] = 49,
    [128] = 50,
    [129] = 51,
    [13] = 13,
    [130] = 52,
    [13001] = 120,
    [13002] = 121,
    [13003] = 122,
    [13004] = 123,
    [13005] = 124,
    [13006] = 125,
    [131] = 53,
    [132] = 54,
    [133] = 55,
    [134] = 56,
    [135] = 57,
    [136] = 58,
    [137] = 59,
    [138] = 60,
    [139] = 61,
    [14] = 14,
    [140] = 62,
    [14003] = 126,
    [141] = 77,
    [142] = 78,
    [143] = 79,
    [144] = 80,
    [145] = 81,
    [146] = 82,
    [147] = 83,
    [15] = 15,
    [15001] = 127,
    [15002] = 128,
    [15003] = 129,
    [15004] = 130,
    [15005] = 131,
    [15006] = 132,
    [16] = 16,
    [17] = 17,
    [17001] = 133,
    [17002] = 134,
    [17003] = 135,
    [17004] = 136,
    [17005] = 137,
    [17006] = 138,
    [18] = 18,
    [19] = 19,
    [19001] = 139,
    [19002] = 140,
    [19003] = 141,
    [19004] = 142,
    [19005] = 143,
    [2] = 2,
    [20] = 20,
    [2001] = 111,
    [2002] = 112,
    [2003] = 113,
    [2004] = 114,
    [2005] = 115,
    [2006] = 116,
    [2007] = 117,
    [2008] = 118,
    [2009] = 119,
    [201] = 63,
    [202] = 64,
    [203] = 65,
    [204] = 66,
    [205] = 67,
    [206] = 68,
    [207] = 69,
    [208] = 70,
    [209] = 71,
    [21] = 21,
    [210] = 72,
    [21001] = 144,
    [21002] = 145,
    [21003] = 146,
    [21004] = 147,
    [21005] = 148,
    [211] = 73,
    [212] = 74,
    [213] = 75,
    [214] = 76,
    [22] = 22,
    [22001] = 149,
    [22002] = 150,
    [22003] = 151,
    [22004] = 152,
    [22005] = 153,
    [22006] = 154,
    [23001] = 155,
    [23002] = 156,
    [23003] = 157,
    [23004] = 158,
    [23005] = 159,
    [24001] = 160,
    [24002] = 161,
    [24003] = 162,
    [24004] = 163,
    [24005] = 164,
    [24006] = 165,
    [24007] = 166,
    [24008] = 167,
    [25001] = 168,
    [25002] = 169,
    [25003] = 170,
    [25004] = 171,
    [25005] = 172,
    [25006] = 173,
    [25007] = 174,
    [25008] = 175,
    [25009] = 176,
    [25010] = 177,
    [26001] = 178,
    [26002] = 179,
    [26003] = 180,
    [26004] = 181,
    [26005] = 182,
    [26006] = 183,
    [27001] = 184,
    [27002] = 185,
    [27003] = 186,
    [27004] = 187,
    [27005] = 188,
    [27006] = 189,
    [27007] = 190,
    [27008] = 191,
    [27009] = 192,
    [27010] = 193,
    [27011] = 194,
    [27012] = 195,
    [27013] = 196,
    [27014] = 197,
    [27015] = 198,
    [27016] = 199,
    [28001] = 200,
    [28002] = 201,
    [28003] = 202,
    [28004] = 203,
    [28005] = 204,
    [28006] = 205,
    [28007] = 206,
    [28008] = 207,
    [28009] = 208,
    [28010] = 209,
    [28011] = 210,
    [29001] = 211,
    [3] = 3,
    [30001] = 212,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  name = 2,
  res_id = 3,
  res_group = 4,
  buff_btype = 5,
  buff_stype = 6,
  buff_affect_type = 7,
  formula = 8,
  formula_value1 = 9,
  formula_value2 = 10,
  is_clear = 11,
  buff_tween = 12,
  buff_tween_pic = 13,

}



local m = { 
    __index = function(t, k) 
        if k == "toObject" then
            return function()  
                local o = {}
                for key, v in pairs (__key_map) do 
                    o[key] = t._raw[v]
                end
                return o
            end 
        end
        
        assert(__key_map[k], "cannot find " .. k .. " in record_buff_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function buff_info.getLength()
    return #buff_info._data
end



function buff_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_buff_info
function buff_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = buff_info._data[index]}, m)
    
end

---
--@return @class record_buff_info
function buff_info.get(id)
    
    return buff_info.indexOf(__index_id[id])
        
end



function buff_info.set(id, key, value)
    local record = buff_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function buff_info.get_index_data()
    return __index_id
end