

---@classdef record_corps_market_info
local record_corps_market_info = {}
  
record_corps_market_info.id = 0 --id  
record_corps_market_info.min_level = 0 --军团等级下限  
record_corps_market_info.max_level = 0 --军团等级上限  
record_corps_market_info.probability = 0 --概率  
record_corps_market_info.item_type = 0 --物品类型  
record_corps_market_info.item_id = 0 --物品ID  
record_corps_market_info.item_num = 0 --物品数量  
record_corps_market_info.buy_num = 0 --限购数量  
record_corps_market_info.price_type = 0 --购买货币类型  
record_corps_market_info.price = 0 --购买现价  
record_corps_market_info.original_price = 0 --原价  
record_corps_market_info.extra_type = 0 --其他消耗类型  
record_corps_market_info.extra_value = 0 --其他消耗类型值  
record_corps_market_info.extra_size = 0 --其他消耗数量  
record_corps_market_info.discount = 0 --折扣


corps_market_info = {
   _data = {
    [1] = {1,1,3,600,6,10005,10,3,2,210,300,0,0,0,70,},
    [2] = {2,1,3,600,6,10011,10,3,2,210,300,0,0,0,70,},
    [3] = {3,1,3,600,6,10027,10,3,2,210,300,0,0,0,70,},
    [4] = {4,1,3,600,6,10033,10,3,2,210,300,0,0,0,70,},
    [5] = {5,1,3,600,6,10051,10,3,2,210,300,0,0,0,70,},
    [6] = {6,1,3,600,6,10054,10,3,2,210,300,0,0,0,70,},
    [7] = {7,1,3,600,6,10083,10,3,2,210,300,0,0,0,70,},
    [8] = {8,1,3,600,6,10088,10,3,2,210,300,0,0,0,70,},
    [9] = {9,1,3,300,3,156,1,1,2,1400,2000,0,0,0,70,},
    [10] = {10,1,3,300,3,157,1,1,2,1400,2000,0,0,0,70,},
    [11] = {11,1,3,300,3,158,1,1,2,1400,2000,0,0,0,70,},
    [12] = {12,1,3,300,3,159,1,1,2,1400,2000,0,0,0,70,},
    [13] = {13,1,3,200,3,160,1,1,2,1680,2400,0,0,0,70,},
    [14] = {14,1,3,200,3,67,1,1,2,1680,2400,0,0,0,70,},
    [15] = {15,1,3,600,3,6,50,3,2,40,50,0,0,0,80,},
    [16] = {16,1,3,600,3,6,100,3,2,80,100,0,0,0,80,},
    [17] = {17,1,3,600,3,6,150,3,2,120,150,0,0,0,80,},
    [18] = {18,1,3,600,3,9,30,3,2,72,90,0,0,0,80,},
    [19] = {19,1,3,600,3,9,50,3,2,120,150,0,0,0,80,},
    [20] = {20,1,3,600,3,9,100,3,2,240,300,0,0,0,80,},
    [21] = {21,4,4,350,6,10005,10,3,2,210,300,0,0,0,70,},
    [22] = {22,4,4,350,6,10011,10,3,2,210,300,0,0,0,70,},
    [23] = {23,4,4,350,6,10027,10,3,2,210,300,0,0,0,70,},
    [24] = {24,4,4,350,6,10033,10,3,2,210,300,0,0,0,70,},
    [25] = {25,4,4,350,6,10051,10,3,2,210,300,0,0,0,70,},
    [26] = {26,4,4,350,6,10054,10,3,2,210,300,0,0,0,70,},
    [27] = {27,4,4,350,6,10083,10,3,2,210,300,0,0,0,70,},
    [28] = {28,4,4,350,6,10088,10,3,2,210,300,0,0,0,70,},
    [29] = {29,4,4,250,3,156,1,1,2,1400,2000,0,0,0,70,},
    [30] = {30,4,4,250,3,157,1,1,2,1400,2000,0,0,0,70,},
    [31] = {31,4,4,250,3,158,1,1,2,1400,2000,0,0,0,70,},
    [32] = {32,4,4,250,3,159,1,1,2,1400,2000,0,0,0,70,},
    [33] = {33,4,4,100,3,160,1,1,2,1680,2400,0,0,0,70,},
    [34] = {34,4,4,100,3,67,1,1,2,1680,2400,0,0,0,70,},
    [35] = {35,4,4,400,3,6,100,3,2,80,100,0,0,0,80,},
    [36] = {36,4,4,400,3,6,150,3,2,120,150,0,0,0,80,},
    [37] = {37,4,4,400,3,6,200,3,2,160,200,0,0,0,80,},
    [38] = {38,4,4,400,3,9,50,3,2,120,150,0,0,0,80,},
    [39] = {39,4,4,400,3,9,80,3,2,192,240,0,0,0,80,},
    [40] = {40,4,4,400,3,9,120,3,2,288,360,0,0,0,80,},
    [41] = {41,4,4,400,3,60,100,3,2,150,300,0,0,0,50,},
    [42] = {42,4,4,400,3,60,200,3,2,300,600,0,0,0,50,},
    [43] = {43,4,4,400,3,60,300,3,2,450,900,0,0,0,50,},
    [44] = {44,4,4,400,23,0,200,3,2,100,200,0,0,0,50,},
    [45] = {45,4,4,400,23,0,300,3,2,150,300,0,0,0,50,},
    [46] = {46,4,4,400,23,0,500,3,2,250,500,0,0,0,50,},
    [47] = {47,4,4,200,3,71,5,10,2,25,50,0,0,0,50,},
    [48] = {48,4,4,200,3,71,10,10,2,50,100,0,0,0,50,},
    [49] = {49,4,4,200,3,71,20,10,2,100,200,0,0,0,50,},
    [50] = {50,4,4,200,3,72,3,5,2,45,90,0,0,0,50,},
    [51] = {51,4,4,200,3,72,5,5,2,75,150,0,0,0,50,},
    [52] = {52,4,4,200,3,72,10,5,2,150,300,0,0,0,50,},
    [53] = {53,5,5,300,6,10001,10,2,2,280,350,0,0,0,80,},
    [54] = {54,5,5,300,6,10006,10,2,2,280,350,0,0,0,80,},
    [55] = {55,5,5,300,6,10025,10,2,2,280,350,0,0,0,80,},
    [56] = {56,5,5,300,6,10032,10,2,2,280,350,0,0,0,80,},
    [57] = {57,5,5,300,6,10048,10,2,2,280,350,0,0,0,80,},
    [58] = {58,5,5,300,6,10052,10,2,2,280,350,0,0,0,80,},
    [59] = {59,5,5,300,6,10071,10,2,2,280,350,0,0,0,80,},
    [60] = {60,5,5,300,6,10075,10,2,2,280,350,0,0,0,80,},
    [61] = {61,5,5,100,3,55,1,1,2,4000,5000,0,0,0,80,},
    [62] = {62,5,5,500,3,6,150,3,2,120,150,0,0,0,80,},
    [63] = {63,5,5,500,3,6,200,3,2,160,200,0,0,0,80,},
    [64] = {64,5,5,500,3,6,300,3,2,240,300,0,0,0,80,},
    [65] = {65,5,5,500,3,9,80,3,2,192,240,0,0,0,80,},
    [66] = {66,5,5,500,3,9,120,3,2,288,360,0,0,0,80,},
    [67] = {67,5,5,500,3,9,180,3,2,432,540,0,0,0,80,},
    [68] = {68,5,5,500,3,60,200,3,2,300,600,0,0,0,50,},
    [69] = {69,5,5,500,3,60,300,3,2,450,900,0,0,0,50,},
    [70] = {70,5,5,500,3,60,500,3,2,750,1500,0,0,0,50,},
    [71] = {71,5,5,400,23,0,400,3,2,200,400,0,0,0,50,},
    [72] = {72,5,5,400,23,0,600,3,2,300,600,0,0,0,50,},
    [73] = {73,5,5,400,23,0,800,3,2,400,800,0,0,0,50,},
    [74] = {74,5,5,300,3,71,10,10,2,50,100,0,0,0,50,},
    [75] = {75,5,5,300,3,71,20,10,2,100,200,0,0,0,50,},
    [76] = {76,5,5,300,3,71,30,10,2,150,300,0,0,0,50,},
    [77] = {77,5,5,300,3,72,5,10,2,75,150,0,0,0,50,},
    [78] = {78,5,5,300,3,72,10,10,2,150,300,0,0,0,50,},
    [79] = {79,5,5,300,3,72,15,10,2,225,450,0,0,0,50,},
    [80] = {80,6,6,300,6,10001,10,5,2,280,350,0,0,0,80,},
    [81] = {81,6,6,300,6,10006,10,5,2,280,350,0,0,0,80,},
    [82] = {82,6,6,300,6,10025,10,5,2,280,350,0,0,0,80,},
    [83] = {83,6,6,300,6,10032,10,5,2,280,350,0,0,0,80,},
    [84] = {84,6,6,300,6,10048,10,5,2,280,350,0,0,0,80,},
    [85] = {85,6,6,300,6,10052,10,5,2,280,350,0,0,0,80,},
    [86] = {86,6,6,300,6,10071,10,5,2,280,350,0,0,0,80,},
    [87] = {87,6,6,300,6,10075,10,5,2,280,350,0,0,0,80,},
    [88] = {88,6,6,100,3,55,1,2,2,4000,5000,0,0,0,80,},
    [89] = {89,6,6,500,3,6,300,3,2,240,300,0,0,0,80,},
    [90] = {90,6,6,500,3,6,500,3,2,400,500,0,0,0,80,},
    [91] = {91,6,6,500,3,6,800,3,2,640,800,0,0,0,80,},
    [92] = {92,6,6,500,3,9,100,3,2,240,300,0,0,0,80,},
    [93] = {93,6,6,500,3,9,150,3,2,360,450,0,0,0,80,},
    [94] = {94,6,6,500,3,9,200,3,2,480,600,0,0,0,80,},
    [95] = {95,6,6,500,3,60,300,3,2,450,900,0,0,0,50,},
    [96] = {96,6,6,500,3,60,500,3,2,750,1500,0,0,0,50,},
    [97] = {97,6,6,500,3,60,800,3,2,1200,2400,0,0,0,50,},
    [98] = {98,6,6,500,23,0,500,3,2,250,500,0,0,0,50,},
    [99] = {99,6,6,500,23,0,800,3,2,400,800,0,0,0,50,},
    [100] = {100,6,6,500,23,0,1000,3,2,500,1000,0,0,0,50,},
    [101] = {101,6,6,600,3,73,3,3,2,225,450,0,0,0,50,},
    [102] = {102,6,6,500,3,73,5,3,2,375,750,0,0,0,50,},
    [103] = {103,6,6,400,3,73,10,3,2,750,1500,0,0,0,50,},
    [104] = {104,7,7,300,6,10001,10,5,2,280,350,0,0,0,80,},
    [105] = {105,7,7,300,6,10006,10,5,2,280,350,0,0,0,80,},
    [106] = {106,7,7,300,6,10025,10,5,2,280,350,0,0,0,80,},
    [107] = {107,7,7,300,6,10032,10,5,2,280,350,0,0,0,80,},
    [108] = {108,7,7,300,6,10048,10,5,2,280,350,0,0,0,80,},
    [109] = {109,7,7,300,6,10052,10,5,2,280,350,0,0,0,80,},
    [110] = {110,7,7,300,6,10071,10,5,2,280,350,0,0,0,80,},
    [111] = {111,7,7,300,6,10075,10,5,2,280,350,0,0,0,80,},
    [112] = {112,7,7,100,3,55,1,2,2,4000,5000,0,0,0,80,},
    [113] = {113,7,7,500,3,6,500,3,2,400,500,0,0,0,80,},
    [114] = {114,7,7,500,3,6,800,3,2,640,800,0,0,0,80,},
    [115] = {115,7,7,500,3,6,1000,3,2,800,1000,0,0,0,80,},
    [116] = {116,7,7,500,3,9,150,3,2,360,450,0,0,0,80,},
    [117] = {117,7,7,500,3,9,200,3,2,480,600,0,0,0,80,},
    [118] = {118,7,7,500,3,9,250,3,2,600,750,0,0,0,80,},
    [119] = {119,7,7,500,3,60,400,3,2,600,1200,0,0,0,50,},
    [120] = {120,7,7,500,3,60,600,3,2,900,1800,0,0,0,50,},
    [121] = {121,7,7,500,3,60,1000,3,2,1500,3000,0,0,0,50,},
    [122] = {122,7,7,400,23,0,1000,3,2,500,1000,0,0,0,50,},
    [123] = {123,7,7,400,23,0,1500,3,2,750,1500,0,0,0,50,},
    [124] = {124,7,7,400,23,0,2000,3,2,1000,2000,0,0,0,50,},
    [125] = {125,7,7,300,3,73,3,5,2,225,450,0,0,0,50,},
    [126] = {126,7,7,300,3,73,5,5,2,375,750,0,0,0,50,},
    [127] = {127,7,7,300,3,73,10,5,2,750,1500,0,0,0,50,},
    [128] = {128,7,7,300,3,74,1,3,2,345,690,0,0,0,50,},
    [129] = {129,7,7,300,3,74,2,3,2,690,1380,0,0,0,50,},
    [130] = {130,7,7,300,3,74,3,3,2,1035,2070,0,0,0,50,},
    [131] = {131,8,8,300,6,10001,10,5,2,280,350,0,0,0,80,},
    [132] = {132,8,8,300,6,10006,10,5,2,280,350,0,0,0,80,},
    [133] = {133,8,8,300,6,10025,10,5,2,280,350,0,0,0,80,},
    [134] = {134,8,8,300,6,10032,10,5,2,280,350,0,0,0,80,},
    [135] = {135,8,8,300,6,10048,10,5,2,280,350,0,0,0,80,},
    [136] = {136,8,8,300,6,10052,10,5,2,280,350,0,0,0,80,},
    [137] = {137,8,8,300,6,10071,10,5,2,280,350,0,0,0,80,},
    [138] = {138,8,8,300,6,10075,10,5,2,280,350,0,0,0,80,},
    [139] = {139,8,8,100,3,55,1,3,2,4000,5000,0,0,0,80,},
    [140] = {140,8,8,500,3,6,800,3,2,640,800,0,0,0,80,},
    [141] = {141,8,8,500,3,6,1000,3,2,800,1000,0,0,0,80,},
    [142] = {142,8,8,500,3,6,1200,3,2,960,1200,0,0,0,80,},
    [143] = {143,8,8,500,3,9,200,3,2,480,600,0,0,0,80,},
    [144] = {144,8,8,500,3,9,250,3,2,600,750,0,0,0,80,},
    [145] = {145,8,8,500,3,9,300,3,2,720,900,0,0,0,80,},
    [146] = {146,8,8,500,3,60,500,3,2,750,1500,0,0,0,50,},
    [147] = {147,8,8,500,3,60,800,3,2,1200,2400,0,0,0,50,},
    [148] = {148,8,8,500,3,60,1200,3,2,1800,3600,0,0,0,50,},
    [149] = {149,8,8,400,23,0,1500,3,2,750,1500,0,0,0,50,},
    [150] = {150,8,8,400,23,0,2000,3,2,1000,2000,0,0,0,50,},
    [151] = {151,8,8,400,23,0,2500,3,2,1250,2500,0,0,0,50,},
    [152] = {152,8,8,300,3,73,5,10,2,375,750,0,0,0,50,},
    [153] = {153,8,8,300,3,73,8,10,2,600,1200,0,0,0,50,},
    [154] = {154,8,8,300,3,73,15,10,2,1125,2250,0,0,0,50,},
    [155] = {155,8,8,200,3,74,2,5,2,690,1380,0,0,0,50,},
    [156] = {156,8,8,200,3,74,4,5,2,1380,2760,0,0,0,50,},
    [157] = {157,8,8,200,3,74,6,5,2,2070,4140,0,0,0,50,},
    [158] = {158,8,8,100,3,75,1,1,2,1944,2430,0,0,0,80,},
    [159] = {159,8,8,100,3,75,2,1,2,3888,4860,0,0,0,80,},
    [160] = {160,8,8,100,3,75,3,1,2,5832,7290,0,0,0,80,},
    [161] = {161,9,9,300,6,10001,10,5,2,280,350,0,0,0,80,},
    [162] = {162,9,9,300,6,10006,10,5,2,280,350,0,0,0,80,},
    [163] = {163,9,9,300,6,10025,10,5,2,280,350,0,0,0,80,},
    [164] = {164,9,9,300,6,10032,10,5,2,280,350,0,0,0,80,},
    [165] = {165,9,9,300,6,10048,10,5,2,280,350,0,0,0,80,},
    [166] = {166,9,9,300,6,10052,10,5,2,280,350,0,0,0,80,},
    [167] = {167,9,9,300,6,10071,10,5,2,280,350,0,0,0,80,},
    [168] = {168,9,9,300,6,10075,10,5,2,280,350,0,0,0,80,},
    [169] = {169,9,9,200,3,55,1,3,2,4000,5000,0,0,0,80,},
    [170] = {170,9,9,500,3,6,1000,3,2,800,1000,0,0,0,80,},
    [171] = {171,9,9,500,3,6,1500,3,2,1200,1500,0,0,0,80,},
    [172] = {172,9,9,500,3,6,2000,3,2,1600,2000,0,0,0,80,},
    [173] = {173,9,9,500,3,9,250,3,2,600,750,0,0,0,80,},
    [174] = {174,9,9,500,3,9,300,3,2,720,900,0,0,0,80,},
    [175] = {175,9,9,500,3,9,350,3,2,840,1050,0,0,0,80,},
    [176] = {176,9,9,500,3,60,800,3,2,1200,2400,0,0,0,50,},
    [177] = {177,9,9,500,3,60,1200,3,2,1800,3600,0,0,0,50,},
    [178] = {178,9,9,500,3,60,1800,3,2,2700,5400,0,0,0,50,},
    [179] = {179,9,9,400,23,0,2000,3,2,1000,2000,0,0,0,50,},
    [180] = {180,9,9,400,23,0,3000,3,2,1500,3000,0,0,0,50,},
    [181] = {181,9,9,400,23,0,5000,3,2,2500,5000,0,0,0,50,},
    [182] = {182,9,9,300,3,74,3,5,2,1035,2070,0,0,0,50,},
    [183] = {183,9,9,300,3,74,5,5,2,1725,3450,0,0,0,50,},
    [184] = {184,9,9,300,3,74,8,5,2,2760,5520,0,0,0,50,},
    [185] = {185,9,9,200,3,75,2,3,2,3888,4860,0,0,0,80,},
    [186] = {186,9,9,200,3,75,3,3,2,5832,7290,0,0,0,80,},
    [187] = {187,9,9,200,3,75,4,3,2,7776,9720,0,0,0,80,},
    [188] = {188,9,9,100,3,76,1,1,2,7864,9830,0,0,0,80,},
    [189] = {189,9,9,100,3,76,2,1,2,15728,19660,0,0,0,80,},
    [190] = {190,10,10,300,6,10001,10,10,2,280,350,0,0,0,80,},
    [191] = {191,10,10,300,6,10006,10,10,2,280,350,0,0,0,80,},
    [192] = {192,10,10,300,6,10025,10,10,2,280,350,0,0,0,80,},
    [193] = {193,10,10,300,6,10032,10,10,2,280,350,0,0,0,80,},
    [194] = {194,10,10,300,6,10048,10,10,2,280,350,0,0,0,80,},
    [195] = {195,10,10,300,6,10052,10,10,2,280,350,0,0,0,80,},
    [196] = {196,10,10,300,6,10071,10,10,2,280,350,0,0,0,80,},
    [197] = {197,10,10,300,6,10075,10,10,2,280,350,0,0,0,80,},
    [198] = {198,10,10,200,3,55,1,3,2,4000,5000,0,0,0,80,},
    [199] = {199,10,10,500,3,6,1500,3,2,1200,1500,0,0,0,80,},
    [200] = {200,10,10,500,3,6,2000,3,2,1600,2000,0,0,0,80,},
    [201] = {201,10,10,500,3,6,3000,3,2,2400,3000,0,0,0,80,},
    [202] = {202,10,10,500,3,9,300,3,2,720,900,0,0,0,80,},
    [203] = {203,10,10,500,3,9,350,3,2,840,1050,0,0,0,80,},
    [204] = {204,10,10,500,3,9,500,3,2,1200,1500,0,0,0,80,},
    [205] = {205,10,10,500,3,60,1000,3,2,1500,3000,0,0,0,50,},
    [206] = {206,10,10,500,3,60,1500,3,2,2250,4500,0,0,0,50,},
    [207] = {207,10,10,500,3,60,2000,3,2,3000,6000,0,0,0,50,},
    [208] = {208,10,10,400,23,0,3000,3,2,1500,3000,0,0,0,50,},
    [209] = {209,10,10,400,23,0,4000,3,2,2000,4000,0,0,0,50,},
    [210] = {210,10,10,400,23,0,5000,3,2,2500,5000,0,0,0,50,},
    [211] = {211,10,10,300,3,74,3,10,2,1035,2070,0,0,0,50,},
    [212] = {212,10,10,300,3,74,5,10,2,1725,3450,0,0,0,50,},
    [213] = {213,10,10,300,3,74,8,10,2,2760,5520,0,0,0,50,},
    [214] = {214,10,10,200,3,75,2,5,2,3888,4860,0,0,0,80,},
    [215] = {215,10,10,200,3,75,3,5,2,5832,7290,0,0,0,80,},
    [216] = {216,10,10,200,3,75,4,5,2,7776,9720,0,0,0,80,},
    [217] = {217,10,10,100,3,76,1,3,2,7864,9830,0,0,0,80,},
    [218] = {218,10,10,100,3,76,2,3,2,15728,19660,0,0,0,80,},
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
    [151] = 151,
    [152] = 152,
    [153] = 153,
    [154] = 154,
    [155] = 155,
    [156] = 156,
    [157] = 157,
    [158] = 158,
    [159] = 159,
    [16] = 16,
    [160] = 160,
    [161] = 161,
    [162] = 162,
    [163] = 163,
    [164] = 164,
    [165] = 165,
    [166] = 166,
    [167] = 167,
    [168] = 168,
    [169] = 169,
    [17] = 17,
    [170] = 170,
    [171] = 171,
    [172] = 172,
    [173] = 173,
    [174] = 174,
    [175] = 175,
    [176] = 176,
    [177] = 177,
    [178] = 178,
    [179] = 179,
    [18] = 18,
    [180] = 180,
    [181] = 181,
    [182] = 182,
    [183] = 183,
    [184] = 184,
    [185] = 185,
    [186] = 186,
    [187] = 187,
    [188] = 188,
    [189] = 189,
    [19] = 19,
    [190] = 190,
    [191] = 191,
    [192] = 192,
    [193] = 193,
    [194] = 194,
    [195] = 195,
    [196] = 196,
    [197] = 197,
    [198] = 198,
    [199] = 199,
    [2] = 2,
    [20] = 20,
    [200] = 200,
    [201] = 201,
    [202] = 202,
    [203] = 203,
    [204] = 204,
    [205] = 205,
    [206] = 206,
    [207] = 207,
    [208] = 208,
    [209] = 209,
    [21] = 21,
    [210] = 210,
    [211] = 211,
    [212] = 212,
    [213] = 213,
    [214] = 214,
    [215] = 215,
    [216] = 216,
    [217] = 217,
    [218] = 218,
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
  min_level = 2,
  max_level = 3,
  probability = 4,
  item_type = 5,
  item_id = 6,
  item_num = 7,
  buy_num = 8,
  price_type = 9,
  price = 10,
  original_price = 11,
  extra_type = 12,
  extra_value = 13,
  extra_size = 14,
  discount = 15,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_market_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_market_info.getLength()
    return #corps_market_info._data
end



function corps_market_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_market_info
function corps_market_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_market_info._data[index]}, m)
    
end

---
--@return @class record_corps_market_info
function corps_market_info.get(id)
    
    return corps_market_info.indexOf(__index_id[id])
        
end



function corps_market_info.set(id, key, value)
    local record = corps_market_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_market_info.get_index_data()
    return __index_id
end