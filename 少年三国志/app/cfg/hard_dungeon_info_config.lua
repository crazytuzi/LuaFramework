

---@classdef record_hard_dungeon_info_config
local record_hard_dungeon_info_config = {}
  
record_hard_dungeon_info_config.id = 0 --副本ID  
record_hard_dungeon_info_config.difficulty = 0 --副本难度  
record_hard_dungeon_info_config.cost = 0 --挑战消耗体力  
record_hard_dungeon_info_config.num = 0 --每日挑战次数  
record_hard_dungeon_info_config.monster_group = 0 --引用怪物组id  
record_hard_dungeon_info_config.monster_wave = 0 --怪物波数  
record_hard_dungeon_info_config.success_type = 0 --挑战胜利条件  
record_hard_dungeon_info_config.map = 0 --地图  
record_hard_dungeon_info_config.item1_type = 0 --掉落物品1类型  
record_hard_dungeon_info_config.item1_value = 0 --掉落物品1类型值  
record_hard_dungeon_info_config.item1_size = 0 --掉落物品1数量  
record_hard_dungeon_info_config.item2_type = 0 --掉落物品2类型  
record_hard_dungeon_info_config.item2_value = 0 --掉落物品2类型值  
record_hard_dungeon_info_config.item2_size = 0 --掉落物品2数量  
record_hard_dungeon_info_config.item3_type = 0 --掉落物品3类型  
record_hard_dungeon_info_config.item3_value = 0 --掉落物品3类型值  
record_hard_dungeon_info_config.item3_size = 0 --掉落物品3数量  
record_hard_dungeon_info_config.item4_type = 0 --掉落物品4类型  
record_hard_dungeon_info_config.item4_value = 0 --掉落物品4类型值  
record_hard_dungeon_info_config.item4_size = 0 --掉落物品4数量  
record_hard_dungeon_info_config.item5_type = 0 --掉落物品5类型  
record_hard_dungeon_info_config.item5_value = 0 --掉落物品5类型值  
record_hard_dungeon_info_config.item5_size = 0 --掉落物品5数量  
record_hard_dungeon_info_config.item6_type = 0 --掉落物品6类型  
record_hard_dungeon_info_config.item6_value = 0 --掉落物品6类型值  
record_hard_dungeon_info_config.item6_size = 0 --掉落物品6数量  
record_hard_dungeon_info_config.talk = "" --副本对话


hard_dungeon_info_config = {
   _data = {
    [1] = {1,2,10,5,50001,1,2,31010,3,60,2,22,111,2,0,0,0,0,0,0,0,0,0,0,0,0,"董卓将军快跑，我们掩护你！",},
    [2] = {2,2,10,5,50002,1,2,31010,3,60,2,22,112,2,0,0,0,0,0,0,0,0,0,0,0,0,"我西凉铁骑出马，天下无敌！",},
    [3] = {3,2,10,5,50003,1,2,31010,3,60,2,22,134,2,0,0,0,0,0,0,0,0,0,0,0,0,"我西凉铁骑出马，天下无敌！",},
    [4] = {4,3,10,5,50004,1,2,31013,3,60,2,22,114,2,0,0,0,0,0,0,0,0,0,0,0,0,"我一定要夺取三国志残卷献给董卓将军！",},
    [5] = {5,2,10,5,50005,1,2,31007,3,60,2,22,121,2,0,0,0,0,0,0,0,0,0,0,0,0,"我大哥张角才是真命天子！",},
    [6] = {6,2,10,5,50006,1,2,31007,3,60,2,22,122,2,0,0,0,0,0,0,0,0,0,0,0,0,"张角大王从三国志残卷学到仙术。",},
    [7] = {7,2,10,5,50007,1,2,31007,3,60,2,22,123,2,0,0,0,0,0,0,0,0,0,0,0,0,"三国志残卷这种宝贝，自然归我大哥所有！",},
    [8] = {8,3,10,5,50008,1,2,31007,3,60,2,22,124,2,0,0,0,0,0,0,0,0,0,0,0,0,"我是天庭下凡来拯救百姓的真命天子！",},
    [9] = {9,2,10,5,50009,1,2,31008,3,60,2,22,131,2,0,0,0,0,0,0,0,0,0,0,0,0,"我陈琳的笔锋，可惊天地泣鬼神！",},
    [10] = {10,2,10,5,50010,1,2,31002,3,60,2,22,132,2,0,0,0,0,0,0,0,0,0,0,0,0,"奉旨保卫皇宫，来者杀无赦！",},
    [11] = {11,2,10,5,50011,1,2,31008,3,60,2,22,133,2,0,0,0,0,0,0,0,0,0,0,0,0,"哀家乃是大汉皇后，母仪天下。",},
    [12] = {12,3,10,5,50012,1,2,31002,3,60,2,22,113,2,0,0,0,0,0,0,0,0,0,0,0,0,"本大将军是杀猪的出身，那又如何？",},
    [13] = {13,2,10,5,50013,1,2,31012,3,60,2,22,111,2,0,0,0,0,0,0,0,0,0,0,0,0,"少年时候，吕布不是我的对手！",},
    [14] = {14,2,10,5,50014,1,2,31012,3,60,2,22,112,2,0,0,0,0,0,0,0,0,0,0,0,0,"貂蝉那娇滴滴的样子，看着就动心。",},
    [15] = {15,2,10,5,50015,1,2,31012,3,60,2,22,113,2,0,0,0,0,0,0,0,0,0,0,0,0,"终有一日，我张济将名震天下。",},
    [16] = {16,3,10,5,50016,1,2,31012,3,60,2,22,114,2,0,0,0,0,0,0,0,0,0,0,0,0,"儿郎们，随我前去拿下袁绍的人头。",},
    [17] = {17,2,10,5,50017,1,2,31001,3,60,2,22,121,2,0,0,0,0,0,0,0,0,0,0,0,0,"跟着孙坚大王，逐鹿天下，爽！",},
    [18] = {18,2,10,5,50018,1,2,31001,3,60,2,22,122,2,0,0,0,0,0,0,0,0,0,0,0,0,"钢鞭在此，谁敢说黄盖是乡巴佬？",},
    [19] = {19,2,10,5,50019,1,2,31007,3,60,2,22,123,2,0,0,0,0,0,0,0,0,0,0,0,0,"程普忠心耿耿，效忠孙坚大王！",},
    [20] = {20,3,10,5,50020,1,2,31007,3,60,2,22,124,2,0,0,0,0,0,0,0,0,0,0,0,0,"我儿孙策少年英俊，必将名震天下！",},
    [21] = {21,2,10,5,50021,1,2,31012,3,60,2,22,131,2,0,0,0,0,0,0,0,0,0,0,0,0,"我袁公路才是真命天子。",},
    [22] = {22,2,10,5,50022,1,2,31012,3,60,2,22,132,2,0,0,0,0,0,0,0,0,0,0,0,0,"这乱世，我韩馥也可以争霸天下。",},
    [23] = {23,2,10,5,50023,1,2,31012,3,60,2,22,133,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁绍目光短浅，肯定成不得大业。",},
    [24] = {24,3,10,5,50024,1,2,31012,3,60,2,22,134,2,0,0,0,0,0,0,0,0,0,0,0,0,"我袁家四世三公，何愁大业不成？",},
    [25] = {25,2,10,5,50025,1,2,31003,3,60,2,22,111,2,0,0,0,0,0,0,0,0,0,0,0,0,"在江夏郡，我黄祖就是皇帝。",},
    [26] = {26,2,10,5,50026,1,2,31003,3,60,2,22,112,2,0,0,0,0,0,0,0,0,0,0,0,0,"听说隆中有个诸葛亮，年少智慧，很厉害。",},
    [27] = {27,2,10,5,50027,1,2,31003,3,60,2,22,113,2,0,0,0,0,0,0,0,0,0,0,0,0,"我的箭术，在这荆州就是第一。",},
    [28] = {28,3,10,5,50028,1,2,31003,3,60,2,22,114,2,0,0,0,0,0,0,0,0,0,0,0,0,"荆襄九郡，唯我独尊。",},
    [29] = {29,2,10,5,50029,1,2,31007,3,60,2,22,121,2,0,0,0,0,0,0,0,0,0,0,0,0,"要论用计，王允第一。",},
    [30] = {30,2,10,5,50030,1,2,31007,3,60,2,22,122,2,0,0,0,0,0,0,0,0,0,0,0,0,"貂蝉果然是国色天香，爽。",},
    [31] = {31,2,10,5,50031,1,2,31007,3,60,2,22,123,2,0,0,0,0,0,0,0,0,0,0,0,0,"我心爱的貂蝉啊，你在哪？",},
    [32] = {32,3,10,5,50032,1,2,31007,3,60,2,22,124,2,0,0,0,0,0,0,0,0,0,0,0,0,"奉先将军，快来救我！",},
    [33] = {33,2,10,5,50033,1,2,31002,3,60,2,22,131,2,0,0,0,0,0,0,0,0,0,0,0,0,"我是董太师麾下第一军师。",},
    [34] = {34,2,10,5,50034,1,2,31002,3,60,2,22,132,2,0,0,0,0,0,0,0,0,0,0,0,0,"总有一天我会取代董卓。",},
    [35] = {35,2,10,5,50035,1,2,31002,3,60,2,22,133,2,0,0,0,0,0,0,0,0,0,0,0,0,"终有一日，我张济将名震天下。",},
    [36] = {36,3,10,5,50036,1,2,31002,3,60,2,22,134,2,0,0,0,0,0,0,0,0,0,0,0,0,"要论用计，王允第一。",},
    [37] = {37,2,10,5,50037,1,2,31002,3,60,2,22,111,2,0,0,0,0,0,0,0,0,0,0,0,0,"乱世之中，我辈枭雄当奋起。",},
    [38] = {38,2,10,5,50038,1,2,31002,3,60,2,22,112,2,0,0,0,0,0,0,0,0,0,0,0,0,"算命先生说，我郭汜有当皇帝的命格。",},
    [39] = {39,2,10,5,50039,1,2,31002,3,60,2,22,113,2,0,0,0,0,0,0,0,0,0,0,0,0,"我看王允这老匹夫，肯定没安好心。",},
    [40] = {40,3,10,5,50040,1,2,31002,3,60,2,22,114,2,0,0,0,0,0,0,0,0,0,0,0,0,"貂蝉美人儿，来亲亲！",},
    [41] = {41,2,15,5,50041,1,2,31014,3,60,4,22,121,2,0,0,0,0,0,0,0,0,0,0,0,0,"我家曹阿瞒，少年时候就与众不同。",},
    [42] = {42,2,15,5,50042,1,2,31014,3,60,4,22,122,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹嵩这老匹夫果然有钱。",},
    [43] = {43,2,15,5,50043,1,2,31014,3,60,4,22,123,2,0,0,0,0,0,0,0,0,0,0,0,0,"陶谦此人太弱，将来难成气候。",},
    [44] = {44,3,15,5,50044,1,2,31014,3,60,4,22,124,2,0,0,0,0,0,0,0,0,0,0,0,0,"徐州虽是四战之地，但陶谦不怕！",},
    [45] = {45,2,15,5,50045,1,2,31014,3,60,4,22,131,2,0,0,0,0,0,0,0,0,0,0,0,0,"为今之计，只有将徐州让给刘备方可退敌。",},
    [46] = {46,2,15,5,50046,1,2,31014,3,60,4,22,132,2,0,0,0,0,0,0,0,0,0,0,0,0,"陶公莫急，我派军支援你击退曹贼！",},
    [47] = {47,2,15,5,50047,1,2,31014,3,60,4,22,133,2,0,0,0,0,0,0,0,0,0,0,0,0,"徐州陶谦与我唇亡齿寒，必须支援陶谦。",},
    [48] = {48,3,15,5,50048,1,2,31014,3,60,4,22,134,2,0,0,0,0,0,0,0,0,0,0,0,0,"府君放心，某一定杀出重围请来刘备！",},
    [49] = {49,2,15,5,50049,1,2,31014,3,60,4,22,211,2,0,0,0,0,0,0,0,0,0,0,0,0,"奉曹丞相令，务必今日拿下徐州。",},
    [50] = {50,2,15,5,50050,1,2,31014,3,60,4,22,212,2,0,0,0,0,0,0,0,0,0,0,0,0,"眼睛是父母精血，怎可放弃，战！",},
    [51] = {51,2,15,5,50051,1,2,31014,3,60,4,22,213,2,0,0,0,0,0,0,0,0,0,0,0,0,"典韦出马，徐州旦夕之间可攻下。",},
    [52] = {52,3,15,5,50052,1,2,31014,3,60,4,22,214,2,0,0,0,0,0,0,0,0,0,0,0,0,"拿下徐州，助曹丞相一统中原。",},
    [53] = {53,2,15,5,50053,1,2,31002,3,60,4,22,221,2,0,0,0,0,0,0,0,0,0,0,0,0,"我今天抢了三个宫女做老婆。",},
    [54] = {54,2,15,5,50054,1,2,31002,3,60,4,22,222,2,0,0,0,0,0,0,0,0,0,0,0,0,"哈哈，李傕也可以当皇帝，尔等还不跪下。",},
    [55] = {55,2,15,5,50055,1,2,31002,3,60,4,22,223,2,0,0,0,0,0,0,0,0,0,0,0,0,"哼，我先干掉李傕再称帝。",},
    [56] = {56,3,15,5,50056,1,2,31002,3,60,4,22,224,2,0,0,0,0,0,0,0,0,0,0,0,0,"李榷郭汜目光短浅，不能成事。",},
    [57] = {57,2,15,5,50057,1,2,31002,3,60,4,22,231,2,0,0,0,0,0,0,0,0,0,0,0,0,"冲上去，将曹操赶回青州海边喂鱼！",},
    [58] = {58,2,15,5,50058,1,2,31002,3,60,4,22,232,2,0,0,0,0,0,0,0,0,0,0,0,0,"陛下莫慌，臣张济来救你了！",},
    [59] = {59,2,15,5,50059,1,2,31002,3,60,4,22,233,2,0,0,0,0,0,0,0,0,0,0,0,0,"郭汜小儿，吃我徐晃一斧！",},
    [60] = {60,3,15,5,50060,1,2,31002,3,60,4,22,234,2,0,0,0,0,0,0,0,0,0,0,0,0,"杨奉将军，我们同心协力，共保陛下！",},
    [61] = {61,2,15,5,50061,1,2,31002,3,60,4,22,211,2,0,0,0,0,0,0,0,0,0,0,0,0,"眼睛是父母精血，怎可放弃，战！",},
    [62] = {62,2,15,5,50062,1,2,31002,3,60,4,22,212,2,0,0,0,0,0,0,0,0,0,0,0,0,"挟天子以令诸侯，霸业可成。",},
    [63] = {63,2,15,5,50063,1,2,31002,3,60,4,22,213,2,0,0,0,0,0,0,0,0,0,0,0,0,"挟天子以令诸侯，霸业可成。",},
    [64] = {64,3,15,5,50064,1,2,31002,3,60,4,22,214,2,0,0,0,0,0,0,0,0,0,0,0,0,"叛贼作乱，谁来救救朕啊。",},
    [65] = {65,2,15,5,50065,1,2,31000,3,60,4,22,221,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹操，明年今日，就是你的忌日！",},
    [66] = {66,2,15,5,50066,1,2,31000,3,60,4,22,222,2,0,0,0,0,0,0,0,0,0,0,0,0,"荆襄九郡，唯我独尊。",},
    [67] = {67,2,15,5,50067,1,2,31000,3,60,4,22,223,2,0,0,0,0,0,0,0,0,0,0,0,0,"欲退曹军，要先用计杀了曹操。",},
    [68] = {68,3,15,5,50068,1,2,31000,3,60,4,22,224,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹阿瞒，张绣与你不共戴天。",},
    [69] = {69,2,15,5,50069,1,2,31012,3,60,4,22,231,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹贼兵多又怎样？我出马，照样全灭！",},
    [70] = {70,2,15,5,50070,1,2,31012,3,60,4,22,232,2,0,0,0,0,0,0,0,0,0,0,0,0,"吕布你竟敢如此对我，我必杀你报仇雪恨！",},
    [71] = {71,2,15,5,50071,1,2,31012,3,60,4,22,233,2,0,0,0,0,0,0,0,0,0,0,0,0,"吕布死期就在今日！",},
    [72] = {72,3,15,5,50072,1,2,31012,3,60,4,22,234,2,0,0,0,0,0,0,0,0,0,0,0,0,"我们今日就反了吕布，投奔曹丞相！",},
    [73] = {73,2,15,5,50073,1,2,31012,3,60,4,22,211,2,0,0,0,0,0,0,0,0,0,0,0,0,"看我用调虎离山之计，斩杀吕布！",},
    [74] = {74,2,15,5,50074,1,2,31012,3,60,4,22,212,2,0,0,0,0,0,0,0,0,0,0,0,0,"有我陈宫再此，绝不让曹贼一兵一卒入城！",},
    [75] = {75,2,15,5,50075,1,2,31012,3,60,4,22,213,2,0,0,0,0,0,0,0,0,0,0,0,0,"貂蝉愿与吕布将军共生死。",},
    [76] = {76,3,15,5,50076,1,2,31012,3,60,4,22,214,2,0,0,0,0,0,0,0,0,0,0,0,0,"哈哈，这天下谁能杀得了我吕布？",},
    [77] = {77,2,15,5,50077,1,2,31007,3,60,4,22,221,2,0,0,0,0,0,0,0,0,0,0,0,0,"哪怕是丢了性命，也要保曹丞相安全。",},
    [78] = {78,2,15,5,50078,1,2,31007,3,60,4,22,222,2,0,0,0,0,0,0,0,0,0,0,0,0,"这天下，只有我家曹丞相是大英雄！",},
    [79] = {79,2,15,5,50079,1,2,31007,3,60,4,22,223,2,0,0,0,0,0,0,0,0,0,0,0,0,"天下英雄，唯使君与操也！",},
    [80] = {80,3,15,5,50080,1,2,31007,3,60,4,22,224,2,0,0,0,0,0,0,0,0,0,0,0,0,"切不可让曹操看出我的大志。",},
    [81] = {81,2,20,5,50081,1,2,31003,3,60,6,22,231,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹丞相派我们盯紧刘备，不要让他跑了。",},
    [82] = {82,2,20,5,50082,1,2,31003,3,60,6,22,232,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备逆贼，速速停步，否则杀无赦",},
    [83] = {83,2,20,5,50083,1,2,31003,3,60,6,22,233,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备迟早必反，绝不能让他领兵！",},
    [84] = {84,3,20,5,50084,1,2,31003,3,60,6,22,234,2,0,0,0,0,0,0,0,0,0,0,0,0,"主公给刘备兵权，好比放虎归山。",},
    [85] = {85,2,20,5,50085,1,2,31003,3,60,6,22,211,2,0,0,0,0,0,0,0,0,0,0,0,0,"绝一定要杀了刘备，替丞相消除后患！",},
    [86] = {86,2,20,5,50086,1,2,31003,3,60,6,22,212,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备乃光复汉室的希望，决不能死！",},
    [87] = {87,2,20,5,50087,1,2,31003,3,60,6,22,213,2,0,0,0,0,0,0,0,0,0,0,0,0,"我在城中埋伏人马，等待时机偷袭刘备。",},
    [88] = {88,3,20,5,50088,1,2,31003,3,60,6,22,214,2,0,0,0,0,0,0,0,0,0,0,0,0,"待我写信给车胄，让他出动人马杀了刘备。",},
    [89] = {89,2,20,5,50089,1,2,31003,3,60,6,22,221,2,0,0,0,0,0,0,0,0,0,0,0,0,"我家袁术大人，少年时也曾声名远扬。",},
    [90] = {90,2,20,5,50090,1,2,31003,3,60,6,22,222,2,0,0,0,0,0,0,0,0,0,0,0,0,"夺了袁术的粮草，我自己去打天下！",},
    [91] = {91,2,20,5,50091,1,2,31003,3,60,6,22,223,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁术没戏了，不如抢走粮食另起山头。",},
    [92] = {92,3,20,5,50092,1,2,31003,3,60,6,22,224,2,0,0,0,0,0,0,0,0,0,0,0,0,"蜜水，我要喝蜜水！",},
    [93] = {93,2,20,5,50093,1,2,31014,3,60,6,22,231,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹贼实力虽强，却不是我家袁绍大人对手！",},
    [94] = {94,2,20,5,50094,1,2,31014,3,60,6,22,232,2,0,0,0,0,0,0,0,0,0,0,0,0,"看我起草檄文，历数曹操罪行。",},
    [95] = {95,2,20,5,50095,1,2,31014,3,60,6,22,233,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹贼迟早要对付我们，不如提前灭之。",},
    [96] = {96,3,20,5,50096,1,2,31014,3,60,6,22,234,2,0,0,0,0,0,0,0,0,0,0,0,0,"我一定写好缴文，将曹贼罪行公示天下。",},
    [97] = {97,2,20,5,50097,1,2,31014,3,60,6,22,311,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁绍真是不知死活，居然敢袭击我家丞相。",},
    [98] = {98,2,20,5,50098,1,2,31014,3,60,6,22,312,2,0,0,0,0,0,0,0,0,0,0,0,0,"有我在，袁绍大军休想攻破城池。",},
    [99] = {99,2,20,5,50099,1,2,31014,3,60,6,22,313,2,0,0,0,0,0,0,0,0,0,0,0,0,"我家丞相注定将取代汉室！",},
    [100] = {100,3,20,5,50100,1,2,31014,3,60,6,22,321,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁绍只会狂傲自大，又哪比得上我家丞相！",},
    [101] = {101,2,20,5,50101,1,2,31013,3,60,6,22,322,2,0,0,0,0,0,0,0,0,0,0,0,0,"关羽休逃，有本事同我大战三百回合。",},
    [102] = {102,2,20,5,50102,1,2,31013,3,60,6,22,323,2,0,0,0,0,0,0,0,0,0,0,0,0,"兄弟们赶紧追，休要放跑了关羽！",},
    [103] = {103,2,20,5,50103,1,2,31013,3,60,6,22,331,2,0,0,0,0,0,0,0,0,0,0,0,0,"关羽你个孬种，有本事同我大战一场！",},
    [104] = {104,3,20,5,50104,1,2,31013,3,60,6,22,332,2,0,0,0,0,0,0,0,0,0,0,0,0,"关羽，还不速速归降我家丞相！",},
    [105] = {105,2,20,5,50105,1,2,31000,3,60,6,22,333,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹操进军时必露空隙，我们可趁机进攻！",},
    [106] = {106,2,20,5,50106,1,2,31000,3,60,6,22,311,2,0,0,0,0,0,0,0,0,0,0,0,0,"颜良虽然勇猛，却缺乏脑子，只是个将才。",},
    [107] = {107,2,20,5,50107,1,2,31000,3,60,6,22,312,2,0,0,0,0,0,0,0,0,0,0,0,0,"颜良在此，白马城诸将速速前来受死！",},
    [108] = {108,3,20,5,50108,1,2,31000,3,60,6,22,313,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备一个窝囊废，居然敢与我同行，呸。",},
    [109] = {109,2,20,5,50109,1,2,31000,3,60,6,22,321,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁军虽然来势汹汹，但我绝不会投降！",},
    [110] = {110,2,20,5,50110,1,2,31000,3,60,6,22,322,2,0,0,0,0,0,0,0,0,0,0,0,0,"誓为主公守护白马城！",},
    [111] = {111,2,20,5,50111,1,2,31000,3,60,6,22,323,2,0,0,0,0,0,0,0,0,0,0,0,0,"宋兄你放心，我魏续一定为你报仇雪恨！",},
    [112] = {112,3,20,5,50112,1,2,31000,3,60,6,22,331,2,0,0,0,0,0,0,0,0,0,0,0,0,"颜良厉害，只有关羽能击败他。",},
    [113] = {113,2,20,5,50113,1,2,31014,3,60,6,22,332,2,0,0,0,0,0,0,0,0,0,0,0,0,"没有曹丞相公文，谁也不准通过！",},
    [114] = {114,2,20,5,50114,1,2,31014,3,60,6,22,333,2,0,0,0,0,0,0,0,0,0,0,0,0,"我已埋伏下军队，关羽必死无疑！",},
    [115] = {115,2,20,5,50115,1,2,31014,3,60,6,22,311,2,0,0,0,0,0,0,0,0,0,0,0,0,"待我设下埋伏，看关羽自投罗网！",},
    [116] = {116,3,20,5,50116,1,2,31014,3,60,6,22,312,2,0,0,0,0,0,0,0,0,0,0,0,0,"我仰慕关将军多年，恳请将军收留！",},
    [117] = {117,2,20,5,50117,1,2,31014,3,60,6,22,313,2,0,0,0,0,0,0,0,0,0,0,0,0,"关羽竟敢杀我亲家，看我放火烧死他。",},
    [118] = {118,2,20,5,50118,1,2,31014,3,60,6,22,321,2,0,0,0,0,0,0,0,0,0,0,0,0,"关羽你只敢杀些无名下将，可敢杀我吗？",},
    [119] = {119,2,20,5,50119,1,2,31014,3,60,6,22,322,2,0,0,0,0,0,0,0,0,0,0,0,0,"关羽止步，没曹丞相公文，这里不准通过。",},
    [120] = {120,3,20,5,50120,1,2,31014,3,60,6,22,323,2,0,0,0,0,0,0,0,0,0,0,0,0,"嫂嫂放心，我一定将你们送回大哥身边。",},
    [121] = {121,2,20,5,50121,1,2,31008,3,60,12,22,331,2,0,0,0,0,0,0,0,0,0,0,0,0,"我周仓唯一佩服的就是关羽将军。",},
    [122] = {122,2,20,5,50122,1,2,31008,3,60,12,22,332,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备胸襟宽广，必能成就大业。",},
    [123] = {123,2,20,5,50123,1,2,31008,3,60,12,22,333,2,0,0,0,0,0,0,0,0,0,0,0,0,"我关平一定会比爹爹更强！",},
    [124] = {124,3,20,5,50124,1,2,31008,3,60,12,22,311,2,0,0,0,0,0,0,0,0,0,0,0,0,"不知关将军和两位夫人是否平安……",},
    [125] = {125,2,20,5,50125,1,2,31013,3,60,12,22,312,2,0,0,0,0,0,0,0,0,0,0,0,0,"我一定要找机会杀了孙策。",},
    [126] = {126,2,20,5,50126,1,2,31013,3,60,12,22,313,2,0,0,0,0,0,0,0,0,0,0,0,0,"是哪个小贼，竟敢暗算孙策大人！",},
    [127] = {127,2,20,5,50127,1,2,31013,3,60,12,22,321,2,0,0,0,0,0,0,0,0,0,0,0,0,"我可是领悟了天人之道的仙人。",},
    [128] = {128,3,20,5,50128,1,2,31013,3,60,12,22,322,2,0,0,0,0,0,0,0,0,0,0,0,0,"装神弄鬼之辈，也敢在我面前嚣张！",},
    [129] = {129,2,20,5,50129,1,2,31013,3,60,12,22,323,2,0,0,0,0,0,0,0,0,0,0,0,0,"侄儿孙权必能带领大兴东吴！",},
    [130] = {130,2,20,5,50130,1,2,31013,3,60,12,22,331,2,0,0,0,0,0,0,0,0,0,0,0,0,"可惜不能继续辅佐孙策大人……",},
    [131] = {131,2,20,5,50131,1,2,31013,3,60,12,22,332,2,0,0,0,0,0,0,0,0,0,0,0,0,"老夫必将暗算孙策之人尽数诛杀。",},
    [132] = {132,3,20,5,50132,1,2,31013,3,60,12,22,333,2,0,0,0,0,0,0,0,0,0,0,0,0,"孙策大人放心，我一定要让吴国一统天下。",},
    [133] = {133,2,25,5,50133,1,2,31013,3,60,20,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"孙权将军天生异貌，有勇有谋。",},
    [134] = {134,2,25,5,50134,1,2,31013,3,60,20,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"我不比我老弟差到哪去。",},
    [135] = {135,2,25,5,50135,1,2,31013,3,60,20,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"我鲁肃会尽力为孙权将军出谋划策。",},
    [136] = {136,3,25,5,50136,1,2,31013,3,60,20,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"大哥放心，东吴的未来就交给我吧。",},
    [137] = {137,2,25,5,50137,1,2,31000,3,60,20,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"我哥可是大丞相曹操！谁敢打我？",},
    [138] = {138,2,25,5,50138,1,2,31000,3,60,20,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"烧掉袁绍的粮草，曹军必胜。",},
    [139] = {139,2,25,5,50139,1,2,31000,3,60,20,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁绍当初亏待我不少，我定会让他后悔。",},
    [140] = {140,3,25,5,50140,1,2,31000,3,60,20,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"打败袁绍，一统天下指日可待。",},
    [141] = {141,2,25,5,50141,1,2,31000,3,60,20,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁大人不听我的劝阻，恐怕后方有危险啊。",},
    [142] = {142,2,25,5,50142,1,2,31000,3,60,20,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"有我高览在，曹贼别想进犯一步。",},
    [143] = {143,2,25,5,50143,1,2,31000,3,60,20,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"假使袁大人用我之计，必将一帆风顺。",},
    [144] = {144,3,25,5,50144,1,2,31000,3,60,20,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"我夜观天象，袁大人气数不久矣。",},
    [145] = {145,2,25,5,50145,1,2,31000,3,60,20,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹操小贼，欺人太甚！",},
    [146] = {146,2,25,5,50146,1,2,31000,3,60,20,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹营守卫空虚，大军劫营必能成功！",},
    [147] = {147,2,25,5,50147,1,2,31000,3,60,20,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"我爹爹袁绍，可是名满天下的大英雄！",},
    [148] = {148,3,25,5,50148,1,2,31000,3,60,20,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁大人把我当心腹，我必不负厚望。",},
    [149] = {149,2,25,5,50149,1,2,31012,3,60,20,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"我可是冀州第一的将军。",},
    [150] = {150,2,25,5,50150,1,2,31012,3,60,20,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"袁谭公子少年雄才，主公居然不让他继承大业？",},
    [151] = {151,2,25,5,50151,1,2,31012,3,60,20,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"我会一直站在袁谭公子这边。",},
    [152] = {152,3,25,5,50152,1,2,31012,3,60,20,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"我袁谭，必将重振袁氏雄风。",},
    [153] = {153,2,25,5,50153,1,2,31012,3,60,20,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"公子袁尚虽然年少，却是长得英姿勃发。",},
    [154] = {154,2,25,5,50154,1,2,31012,3,60,20,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"不能让袁谭掌握大权。",},
    [155] = {155,2,25,5,50155,1,2,31012,3,60,20,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"有我审配在，袁氏便不会灭亡！",},
    [156] = {156,3,25,5,50156,1,2,31012,3,60,20,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"哼！他袁谭算个什么东西！",},
    [157] = {157,2,25,5,50157,1,2,31012,3,60,20,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"我必不负“五子良将”之名。",},
    [158] = {158,2,25,5,50158,1,2,31012,3,60,20,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"两袁火并，胜的是我们曹丞相。",},
    [159] = {159,2,25,5,50159,1,2,31012,3,60,20,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"江山美人，我曹丕全要了。",},
    [160] = {160,3,25,5,50160,1,2,31012,3,60,20,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"自古红颜多薄命，妾身亦如此。",},
    [161] = {161,2,25,5,50161,1,2,31011,3,60,20,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘表无能，看不住荆州，还是让我张武接手吧！",},
    [162] = {162,2,25,5,50162,1,2,31011,3,60,20,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"我不造反，荆州也会断送在刘表手里！",},
    [163] = {163,2,25,5,50163,1,2,31011,3,60,20,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"张武！你个不忠不义之徒！不配姓张！",},
    [164] = {164,3,25,5,50164,1,2,31011,3,60,20,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"我刘景升再不济，也不会败在这些叛贼手中！",},
    [165] = {165,2,25,5,50165,1,2,31011,3,60,20,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"曹操势大，我何不投他以自保~",},
    [166] = {166,2,25,5,50166,1,2,31011,3,60,20,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"哼，这荆州迟早会落在我手里！",},
    [167] = {167,2,25,5,50167,1,2,31011,3,60,20,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备！你居然送的卢马克我老公！我饶不了你！",},
    [168] = {168,3,25,5,50168,1,2,31011,3,60,20,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备这个坏人！送的卢马害我爹地！",},
    [169] = {169,2,30,5,50169,1,2,31011,3,60,32,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"不行，蔡夫人要杀刘皇叔，我一定要告诉他！",},
    [170] = {170,2,30,5,50170,1,2,31011,3,60,32,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"周围的荆州兵，都虎视眈眈呢~",},
    [171] = {171,2,30,5,50171,1,2,31011,3,60,32,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"我怎么可能陷害我表哥呢……",},
    [172] = {172,3,30,5,50172,1,2,31011,3,60,32,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘备大人是好人，我不能让蔡瑁杀了他！",},
    [173] = {173,2,30,5,50173,1,2,31007,3,60,32,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"卧龙凤雏，得一可安天下~",},
    [174] = {174,2,30,5,50174,1,2,31007,3,60,32,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"听说水镜先生隐居在此，特来拜访~",},
    [175] = {175,2,30,5,50175,1,2,31007,3,60,32,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘表心胸狭隘，一定会谋害善者~",},
    [176] = {176,3,30,5,50176,1,2,31007,3,60,32,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"今天路过，特地来看看水镜先生~",},
    [177] = {177,2,30,5,50177,1,2,31014,3,60,32,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"嘿嘿，只要攻下新野，拿下刘备，我可是大功一件！",},
    [178] = {178,2,30,5,50178,1,2,31014,3,60,32,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"神马！我兄弟吕旷居然被打败了？！",},
    [179] = {179,2,30,5,50179,1,2,31014,3,60,32,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"看我怎么收拾刘备这个大耳贼！",},
    [180] = {180,3,30,5,50180,1,2,31014,3,60,32,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"徐庶真是可恶，给刘备出了不少主意！",},
    [181] = {181,2,30,5,50181,1,2,31007,3,60,32,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"可惜可惜~卧龙先生，生不逢时啊~",},
    [182] = {182,2,30,5,50182,1,2,31007,3,60,32,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"不知道诸葛先生回来没有……",},
    [183] = {183,2,30,5,50183,1,2,31007,3,60,32,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"大家好，我是诸葛先生，你们找我何事？",},
    [184] = {184,3,30,5,50184,1,2,31007,3,60,32,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"刚一睡醒，怎么屋子里这么多人呀~",},
    [185] = {185,2,30,5,50185,1,2,31012,3,60,32,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"黄祖将军！黄祖将军！吕蒙来犯！",},
    [186] = {186,2,30,5,50186,1,2,31012,3,60,32,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"甘宁将军！不要杀我！",},
    [187] = {187,2,30,5,50187,1,2,31012,3,60,32,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"哼，黄祖看不起我水贼出生，不重用我！",},
    [188] = {188,3,30,5,50188,1,2,31012,3,60,32,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"孙权！你父亲败在我手！今日你也难逃一死！",},
    [189] = {189,2,30,5,50189,1,2,31010,3,60,32,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"黄祖，你的死期到了！",},
    [190] = {190,2,30,5,50190,1,2,31010,3,60,32,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"我一定要拿下荆州！",},
    [191] = {191,2,30,5,50191,1,2,31010,3,60,32,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"父亲！我终于为你报仇了！",},
    [192] = {192,3,30,5,50192,1,2,31010,3,60,32,22,423,2,0,0,0,0,0,0,0,0,0,0,0,0,"一群乌合之众，化成我刀下的血锈吧！",},
    [193] = {193,2,30,5,50193,1,2,31008,3,60,32,22,431,2,0,0,0,0,0,0,0,0,0,0,0,0,"荆州是交给大儿子呢，还是二儿子呢~",},
    [194] = {194,2,30,5,50194,1,2,31008,3,60,32,22,432,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘琦，我绝不会留你性命！",},
    [195] = {195,2,30,5,50195,1,2,31008,3,60,32,22,433,2,0,0,0,0,0,0,0,0,0,0,0,0,"刘表的家事，我不好插手啊~",},
    [196] = {196,3,30,5,50196,1,2,31008,3,60,32,22,411,2,0,0,0,0,0,0,0,0,0,0,0,0,"荆州，决不能落在蔡夫人和蔡瑁手上！",},
    [197] = {197,2,30,5,50197,1,2,31014,3,60,32,22,412,2,0,0,0,0,0,0,0,0,0,0,0,0,"我年少时最恨土匪！所以把他们都干掉了！",},
    [198] = {198,2,30,5,50198,1,2,31014,3,60,32,22,413,2,0,0,0,0,0,0,0,0,0,0,0,0,"诸葛亮狡猾，不知道夏侯将军会不会中计。",},
    [199] = {199,2,30,5,50199,1,2,31014,3,60,32,22,421,2,0,0,0,0,0,0,0,0,0,0,0,0,"诸葛亮阴险狡诈，千万不要中计！",},
    [200] = {200,3,30,5,50200,1,2,31014,3,60,32,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"这次，我一定要帮丞相除掉刘备！",},
    [201] = {201,3,30,5,50200,1,2,31014,3,60,32,22,422,2,0,0,0,0,0,0,0,0,0,0,0,0,"敬请期待",},
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
  difficulty = 2,
  cost = 3,
  num = 4,
  monster_group = 5,
  monster_wave = 6,
  success_type = 7,
  map = 8,
  item1_type = 9,
  item1_value = 10,
  item1_size = 11,
  item2_type = 12,
  item2_value = 13,
  item2_size = 14,
  item3_type = 15,
  item3_value = 16,
  item3_size = 17,
  item4_type = 18,
  item4_value = 19,
  item4_size = 20,
  item5_type = 21,
  item5_value = 22,
  item5_size = 23,
  item6_type = 24,
  item6_value = 25,
  item6_size = 26,
  talk = 27,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_hard_dungeon_info_config")
        
        
        return t._raw[__key_map[k]]
    end
}


function hard_dungeon_info_config.getLength()
    return #hard_dungeon_info_config._data
end



function hard_dungeon_info_config.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_hard_dungeon_info_config
function hard_dungeon_info_config.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = hard_dungeon_info_config._data[index]}, m)
    
end

---
--@return @class record_hard_dungeon_info_config
function hard_dungeon_info_config.get(id)
    
    return hard_dungeon_info_config.indexOf(__index_id[id])
        
end



function hard_dungeon_info_config.set(id, key, value)
    local record = hard_dungeon_info_config.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function hard_dungeon_info_config.get_index_data()
    return __index_id
end