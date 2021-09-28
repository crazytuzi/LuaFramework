

---@classdef record_hard_dungeon_roit_info
local record_hard_dungeon_roit_info = {}
  
record_hard_dungeon_roit_info.id = 0 --ID  
record_hard_dungeon_roit_info.name = "" --怪物名字  
record_hard_dungeon_roit_info.quality = 0 --怪物品质  
record_hard_dungeon_roit_info.image = "" --怪物资源  
record_hard_dungeon_roit_info.roit_reward_type_1 = 0 --精英暴动掉落1类型  
record_hard_dungeon_roit_info.roit_reward_value_1 = 0 --精英暴动掉落1类型值  
record_hard_dungeon_roit_info.roit_reward_min_size_1 = 0 --精英暴动掉落1最小数量  
record_hard_dungeon_roit_info.roit_reward_max_size_1 = 0 --精英暴动掉落1最大数量  
record_hard_dungeon_roit_info.roit_reward_type_2 = 0 --精英暴动掉落2类型  
record_hard_dungeon_roit_info.roit_reward_value_2 = 0 --精英暴动掉落2类型值  
record_hard_dungeon_roit_info.roit_reward_min_size_2 = 0 --精英暴动掉落2最小数量  
record_hard_dungeon_roit_info.roit_reward_max_size_2 = 0 --精英暴动掉落2最大数量  
record_hard_dungeon_roit_info.roit_reward_type_3 = 0 --精英暴动掉落3类型  
record_hard_dungeon_roit_info.roit_reward_value_3 = 0 --精英暴动掉落3类型值  
record_hard_dungeon_roit_info.roit_reward_min_size_3 = 0 --精英暴动掉落3最小数量  
record_hard_dungeon_roit_info.roit_reward_max_size_3 = 0 --精英暴动掉落3最大数量  
record_hard_dungeon_roit_info.roit_cost = 0 --精英暴动消耗体力


hard_dungeon_roit_info = {
   _data = {
    [1] = {1,"董卓",3,14016,3,60,29,44,0,0,0,0,0,0,0,0,5,},
    [2] = {2,"董卓",4,14016,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [3] = {3,"董卓",5,14016,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [4] = {4,"于吉",3,14009,3,60,29,44,0,0,0,0,0,0,0,0,5,},
    [5] = {5,"于吉",4,14009,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [6] = {6,"于吉",5,14009,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [7] = {7,"袁绍",3,14006,3,60,29,44,0,0,0,0,0,0,0,0,5,},
    [8] = {8,"袁绍",4,14006,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [9] = {9,"袁绍",5,14006,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [10] = {10,"董卓",3,14016,3,60,29,44,0,0,0,0,0,0,0,0,5,},
    [11] = {11,"董卓",4,14016,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [12] = {12,"董卓",5,14016,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [13] = {13,"袁术",3,14027,3,60,29,44,0,0,0,0,0,0,0,0,5,},
    [14] = {14,"袁术",4,14027,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [15] = {15,"袁术",5,14027,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [16] = {16,"曹操",3,11002,3,60,29,44,0,0,0,0,0,0,0,0,5,},
    [17] = {17,"曹操",4,11002,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [18] = {18,"曹操",5,11002,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [19] = {19,"蔡夫人",3,13033,3,60,44,67,0,0,0,0,0,0,0,0,10,},
    [20] = {20,"蔡夫人",4,13033,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [21] = {21,"蔡夫人",5,13033,3,60,135,202,0,0,0,0,0,0,0,0,25,},
    [22] = {22,"王允",3,14029,3,60,44,67,0,0,0,0,0,0,0,0,10,},
    [23] = {23,"王允",4,14029,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [24] = {24,"王允",5,14029,3,60,135,202,0,0,0,0,0,0,0,0,25,},
    [25] = {25,"吕布",3,14005,3,60,44,67,0,0,0,0,0,0,0,0,10,},
    [26] = {26,"吕布",4,14005,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [27] = {27,"吕布",5,14005,3,60,135,202,0,0,0,0,0,0,0,0,25,},
    [28] = {28,"牛辅",3,14034,3,60,44,67,0,0,0,0,0,0,0,0,10,},
    [29] = {29,"牛辅",4,14034,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [30] = {30,"牛辅",5,14034,3,60,135,202,0,0,0,0,0,0,0,0,25,},
    [31] = {31,"刘备",3,12008,3,60,44,67,0,0,0,0,0,0,0,0,10,},
    [32] = {32,"刘备",4,12008,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [33] = {33,"刘备",5,12008,3,60,135,202,0,0,0,0,0,0,0,0,25,},
    [34] = {34,"孔融",3,14036,3,60,44,67,0,0,0,0,0,0,0,0,10,},
    [35] = {35,"孔融",4,14036,3,60,90,135,0,0,0,0,0,0,0,0,25,},
    [36] = {36,"孔融",5,14036,3,60,135,202,0,0,0,0,0,0,0,0,35,},
    [37] = {37,"曹操",3,11002,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [38] = {38,"曹操",4,11002,3,60,120,180,0,0,0,0,0,0,0,0,25,},
    [39] = {39,"曹操",5,11002,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [40] = {40,"汉献帝",3,14039,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [41] = {41,"汉献帝",4,14039,3,60,120,180,0,0,0,0,0,0,0,0,25,},
    [42] = {42,"汉献帝",5,14039,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [43] = {43,"吉平",3,13034,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [44] = {44,"吉平",4,13034,3,60,120,180,0,0,0,0,0,0,0,0,25,},
    [45] = {45,"吉平",5,13034,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [46] = {46,"刘备",3,12008,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [47] = {47,"刘备",4,12008,3,60,120,180,0,0,0,0,0,0,0,0,25,},
    [48] = {48,"刘备",5,12008,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [49] = {49,"贾诩",3,11009,3,60,60,90,0,0,0,0,0,0,0,0,10,},
    [50] = {50,"贾诩",4,11009,3,60,120,180,0,0,0,0,0,0,0,0,25,},
    [51] = {51,"贾诩",5,11009,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [52] = {52,"荀彧",3,11007,3,60,60,90,0,0,0,0,0,0,0,0,15,},
    [53] = {53,"荀彧",4,11007,3,60,120,180,0,0,0,0,0,0,0,0,30,},
    [54] = {54,"荀彧",5,11007,3,60,180,271,0,0,0,0,0,0,0,0,40,},
    [55] = {55,"曹操",3,11002,3,60,75,112,0,0,0,0,0,0,0,0,15,},
    [56] = {56,"曹操",4,11002,3,60,150,225,0,0,0,0,0,0,0,0,30,},
    [57] = {57,"曹操",5,11002,3,60,225,338,0,0,0,0,0,0,0,0,40,},
    [58] = {58,"关羽",3,12003,3,60,75,112,0,0,0,0,0,0,0,0,15,},
    [59] = {59,"关羽",4,12003,3,60,150,225,0,0,0,0,0,0,0,0,30,},
    [60] = {60,"关羽",5,12003,3,60,225,338,0,0,0,0,0,0,0,0,40,},
    [61] = {61,"夏侯惇",3,11004,3,60,75,112,0,0,0,0,0,0,0,0,15,},
    [62] = {62,"夏侯惇",4,11004,3,60,150,225,0,0,0,0,0,0,0,0,30,},
    [63] = {63,"夏侯惇",5,11004,3,60,225,338,0,0,0,0,0,0,0,0,40,},
    [64] = {64,"郭嘉",3,11001,3,60,75,112,0,0,0,0,0,0,0,0,15,},
    [65] = {65,"郭嘉",4,11001,3,60,150,225,0,0,0,0,0,0,0,0,30,},
    [66] = {66,"郭嘉",5,11001,3,60,225,338,0,0,0,0,0,0,0,0,40,},
    [67] = {67,"袁胤",3,12045,3,60,75,112,0,0,0,0,0,0,0,0,15,},
    [68] = {68,"袁胤",4,12045,3,60,150,225,0,0,0,0,0,0,0,0,30,},
    [69] = {69,"袁胤",5,12045,3,60,225,338,0,0,0,0,0,0,0,0,40,},
    [70] = {70,"袁绍",3,14006,3,60,75,112,0,0,0,0,0,0,0,0,15,},
    [71] = {71,"袁绍",4,14006,3,60,150,225,0,0,0,0,0,0,0,0,30,},
    [72] = {72,"袁绍",5,14006,3,60,225,338,0,0,0,0,0,0,0,0,40,},
    [73] = {73,"曹操",3,11002,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [74] = {74,"曹操",4,11002,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [75] = {75,"曹操",5,11002,3,60,271,406,0,0,0,0,0,0,0,0,50,},
    [76] = {76,"吕布",3,14005,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [77] = {77,"吕布",4,14005,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [78] = {78,"吕布",5,14005,3,60,271,406,0,0,0,0,0,0,0,0,50,},
    [79] = {79,"颜良",3,14013,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [80] = {80,"颜良",4,14013,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [81] = {81,"颜良",5,14013,3,60,271,406,0,0,0,0,0,0,0,0,50,},
    [82] = {82,"关羽",3,12003,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [83] = {83,"关羽",4,12003,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [84] = {84,"关羽",5,12003,3,60,271,406,0,0,0,0,0,0,0,0,50,},
    [85] = {85,"周仓",3,12041,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [86] = {86,"周仓",4,12041,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [87] = {87,"周仓",5,12041,3,60,271,406,0,0,0,0,0,0,0,0,50,},
    [88] = {88,"刘备",3,12008,3,60,90,135,0,0,0,0,0,0,0,0,15,},
    [89] = {89,"刘备",4,12008,3,60,180,271,0,0,0,0,0,0,0,0,35,},
    [90] = {90,"刘备",5,12008,3,60,271,406,0,0,0,0,0,0,0,0,50,},
    [91] = {91,"关羽",3,12003,3,60,105,150,0,0,0,0,0,0,0,0,15,},
    [92] = {92,"关羽",4,12003,3,60,195,286,0,0,0,0,0,0,0,0,35,},
    [93] = {93,"关羽",5,12003,3,60,286,421,0,0,0,0,0,0,0,0,50,},
    [94] = {94,"孙权",3,13005,3,60,105,150,0,0,0,0,0,0,0,0,15,},
    [95] = {95,"孙权",4,13005,3,60,195,286,0,0,0,0,0,0,0,0,35,},
    [96] = {96,"孙权",5,13005,3,60,286,421,0,0,0,0,0,0,0,0,50,},
    [97] = {97,"鲁肃",3,13002,3,60,105,150,0,0,0,0,0,0,0,0,15,},
    [98] = {98,"鲁肃",4,13002,3,60,195,286,0,0,0,0,0,0,0,0,35,},
    [99] = {99,"鲁肃",5,13002,3,60,286,421,0,0,0,0,0,0,0,0,50,},
    [100] = {100,"孙策",3,13004,3,60,105,150,0,0,0,0,0,0,0,0,15,},
    [101] = {101,"孙策",4,13004,3,60,195,286,0,0,0,0,0,0,0,0,35,},
    [102] = {102,"孙策",5,13004,3,60,286,421,0,0,0,0,0,0,0,0,50,},
    [103] = {103,"许褚",3,11016,3,60,105,150,0,0,0,0,0,0,0,0,15,},
    [104] = {104,"许褚",4,11016,3,60,195,286,0,0,0,0,0,0,0,0,35,},
    [105] = {105,"许褚",5,11016,3,60,286,421,0,0,0,0,0,0,0,0,50,},
    [106] = {106,"袁绍",3,14006,3,60,105,150,0,0,0,0,0,0,0,0,15,},
    [107] = {107,"袁绍",4,14006,3,60,195,286,0,0,0,0,0,0,0,0,35,},
    [108] = {108,"袁绍",5,14006,3,60,286,421,0,0,0,0,0,0,0,0,50,},
    [109] = {109,"逢纪",3,12044,3,60,120,165,0,0,0,0,0,0,0,0,20,},
    [110] = {110,"逢纪",4,12044,3,60,210,301,0,0,0,0,0,0,0,0,40,},
    [111] = {111,"逢纪",5,12044,3,60,301,436,0,0,0,0,0,0,0,0,60,},
    [112] = {112,"郭图",3,13018,3,60,120,165,0,0,0,0,0,0,0,0,20,},
    [113] = {113,"郭图",4,13018,3,60,210,301,0,0,0,0,0,0,0,0,40,},
    [114] = {114,"郭图",5,13018,3,60,301,436,0,0,0,0,0,0,0,0,60,},
    [115] = {115,"审配",3,14043,3,60,120,165,0,0,0,0,0,0,0,0,20,},
    [116] = {116,"审配",4,14043,3,60,210,301,0,0,0,0,0,0,0,0,40,},
    [117] = {117,"审配",5,14043,3,60,301,436,0,0,0,0,0,0,0,0,60,},
    [118] = {118,"曹丕",3,11020,3,60,120,165,0,0,0,0,0,0,0,0,20,},
    [119] = {119,"曹丕",4,11020,3,60,210,301,0,0,0,0,0,0,0,0,40,},
    [120] = {120,"曹丕",5,11020,3,60,301,436,0,0,0,0,0,0,0,0,60,},
    [121] = {121,"蔡夫人",3,13033,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [122] = {122,"蔡夫人",4,13033,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [123] = {123,"蔡夫人",5,13033,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [124] = {124,"刘琦",3,12025,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [125] = {125,"刘琦",4,12025,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [126] = {126,"刘琦",5,12025,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [127] = {127,"刘备",3,12008,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [128] = {128,"刘备",4,12008,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [129] = {129,"刘备",5,12008,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [130] = {130,"诸葛亮",3,12009,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [131] = {131,"诸葛亮",4,12009,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [132] = {132,"诸葛亮",5,12009,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [133] = {133,"曹仁",3,11003,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [134] = {134,"曹仁",4,11003,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [135] = {135,"曹仁",5,11003,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [136] = {136,"赵云",3,12001,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [137] = {137,"赵云",4,12001,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [138] = {138,"赵云",5,12001,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [139] = {139,"孙策",3,13004,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [140] = {140,"孙策",4,13004,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [141] = {141,"孙策",5,13004,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [142] = {142,"孙权",3,13005,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [143] = {143,"孙权",4,13005,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [144] = {144,"孙权",5,13005,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [145] = {145,"刘琮",3,12045,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [146] = {146,"刘琮",4,12045,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [147] = {147,"刘琮",5,12045,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    [148] = {148,"曹操",3,11002,3,60,104,157,0,0,0,0,0,0,0,0,20,},
    [149] = {149,"曹操",4,11002,3,60,210,315,0,0,0,0,0,0,0,0,40,},
    [150] = {150,"曹操",5,11002,3,60,316,474,0,0,0,0,0,0,0,0,60,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [100] = 100,
    [101] = 101,
    [102] = 102,
    [103] = 103,
    [104] = 104,
    [105] = 105,
    [106] = 106,
    [107] = 107,
    [108] = 108,
    [109] = 109,
    [11] = 11,
    [110] = 110,
    [111] = 111,
    [112] = 112,
    [113] = 113,
    [114] = 114,
    [115] = 115,
    [116] = 116,
    [117] = 117,
    [118] = 118,
    [119] = 119,
    [12] = 12,
    [120] = 120,
    [121] = 121,
    [122] = 122,
    [123] = 123,
    [124] = 124,
    [125] = 125,
    [126] = 126,
    [127] = 127,
    [128] = 128,
    [129] = 129,
    [13] = 13,
    [130] = 130,
    [131] = 131,
    [132] = 132,
    [133] = 133,
    [134] = 134,
    [135] = 135,
    [136] = 136,
    [137] = 137,
    [138] = 138,
    [139] = 139,
    [14] = 14,
    [140] = 140,
    [141] = 141,
    [142] = 142,
    [143] = 143,
    [144] = 144,
    [145] = 145,
    [146] = 146,
    [147] = 147,
    [148] = 148,
    [149] = 149,
    [15] = 15,
    [150] = 150,
    [16] = 16,
    [17] = 17,
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
    [26] = 26,
    [27] = 27,
    [28] = 28,
    [29] = 29,
    [3] = 3,
    [30] = 30,
    [31] = 31,
    [32] = 32,
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [36] = 36,
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [40] = 40,
    [41] = 41,
    [42] = 42,
    [43] = 43,
    [44] = 44,
    [45] = 45,
    [46] = 46,
    [47] = 47,
    [48] = 48,
    [49] = 49,
    [5] = 5,
    [50] = 50,
    [51] = 51,
    [52] = 52,
    [53] = 53,
    [54] = 54,
    [55] = 55,
    [56] = 56,
    [57] = 57,
    [58] = 58,
    [59] = 59,
    [6] = 6,
    [60] = 60,
    [61] = 61,
    [62] = 62,
    [63] = 63,
    [64] = 64,
    [65] = 65,
    [66] = 66,
    [67] = 67,
    [68] = 68,
    [69] = 69,
    [7] = 7,
    [70] = 70,
    [71] = 71,
    [72] = 72,
    [73] = 73,
    [74] = 74,
    [75] = 75,
    [76] = 76,
    [77] = 77,
    [78] = 78,
    [79] = 79,
    [8] = 8,
    [80] = 80,
    [81] = 81,
    [82] = 82,
    [83] = 83,
    [84] = 84,
    [85] = 85,
    [86] = 86,
    [87] = 87,
    [88] = 88,
    [89] = 89,
    [9] = 9,
    [90] = 90,
    [91] = 91,
    [92] = 92,
    [93] = 93,
    [94] = 94,
    [95] = 95,
    [96] = 96,
    [97] = 97,
    [98] = 98,
    [99] = 99,

}

local __key_map = {
  id = 1,
  name = 2,
  quality = 3,
  image = 4,
  roit_reward_type_1 = 5,
  roit_reward_value_1 = 6,
  roit_reward_min_size_1 = 7,
  roit_reward_max_size_1 = 8,
  roit_reward_type_2 = 9,
  roit_reward_value_2 = 10,
  roit_reward_min_size_2 = 11,
  roit_reward_max_size_2 = 12,
  roit_reward_type_3 = 13,
  roit_reward_value_3 = 14,
  roit_reward_min_size_3 = 15,
  roit_reward_max_size_3 = 16,
  roit_cost = 17,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_hard_dungeon_roit_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function hard_dungeon_roit_info.getLength()
    return #hard_dungeon_roit_info._data
end



function hard_dungeon_roit_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_hard_dungeon_roit_info
function hard_dungeon_roit_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = hard_dungeon_roit_info._data[index]}, m)
    
end

---
--@return @class record_hard_dungeon_roit_info
function hard_dungeon_roit_info.get(id)
    
    return hard_dungeon_roit_info.indexOf(__index_id[id])
        
end



function hard_dungeon_roit_info.set(id, key, value)
    local record = hard_dungeon_roit_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function hard_dungeon_roit_info.get_index_data()
    return __index_id
end