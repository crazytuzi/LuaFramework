

---@classdef record_newplay_guide_info
local record_newplay_guide_info = {}
  
record_newplay_guide_info.step_id = 0 --步骤  
record_newplay_guide_info.step_desc = "" --步骤描述  
record_newplay_guide_info.scene_name = "" --所处场景  
record_newplay_guide_info.layer_name = "" --所处界面  
record_newplay_guide_info.next_step = 0 --跳转至步骤  
record_newplay_guide_info.x = 0 --基点x坐标  
record_newplay_guide_info.y = 0 --基点y坐标  
record_newplay_guide_info.width = 0 --宽度  
record_newplay_guide_info.height = 0 --高度  
record_newplay_guide_info.hooker_delay = 0 --监控延迟时间  
record_newplay_guide_info.text_id = 0 --说话内容  
record_newplay_guide_info.click_enable = 0 --是否接受触摸  
record_newplay_guide_info.click_widget = "" --需点击控件名  
record_newplay_guide_info.click_param1 = 0 --点击参数1  
record_newplay_guide_info.prepare_data = 0 --预准备数据  
record_newplay_guide_info.zoom_percent = 0 --缩放比例  
record_newplay_guide_info.need_mask = 0 --是否做遮罩  
record_newplay_guide_info.protocal_id = "" --监听消息  
record_newplay_guide_info.reset_Id = 0 --返回引导  
record_newplay_guide_info.is_assistant = 0 --是否为辅助步骤  
record_newplay_guide_info.wait_effect = 0 --是否等待特效完成  
record_newplay_guide_info.check_data = 0 --确认辅助数据  
record_newplay_guide_info.jump_step = 0 --跳过步数  
record_newplay_guide_info.position = 0 --气泡出现位置  
record_newplay_guide_info.comment = "" --气泡对话


newplay_guide_info = {
   _data = {
    [1] = {1,"跳过副本介绍","DungeonGateScene","DungeonSubtitleLayer",0,0,0,0,0,600,0,1,"",0,0,0,0,"",506,0,1,0,0,0,"",},
    [2] = {2,"点第一个关卡","DungeonGateScene","DungeonMapLayer",0,0,0,0,0,600,1003,1,"stage_1",0,0,25,1,"",506,0,0,0,0,0,"将军，请点这里，消灭这个可恶的西凉兵吧！",},
    [3] = {3,"点击挑战按钮","DungeonGateScene","DungeonEnterGateLayer",0,0,0,0,0,600,0,1,"Button_Challenge",0,0,100,1,"dungeon_enterbattle",500,0,0,1,508,0,"",},
    [4] = {4,"战斗","DungeonBattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",500,0,0,0,0,0,"",},
    [5] = {5,"点击宝箱","DungeonGateScene","DungeonMapLayer",0,0,0,0,0,600,1004,1,"box_2",0,0,100,1,"",500,0,0,0,0,0,"将军，请点击并领取地上的宝箱吧。",},
    [6] = {6,"点击领取","DungeonGateScene","DungeonTopLayer",0,0,0,0,0,800,0,1,"getbounsbtn",0,0,100,1,"dungeon_executestage",501,0,1,2,509,0,"",},
    [7] = {7,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,30,1005,1,"back",0,0,100,1,"",8,0,0,0,0,0,"",},
    [8] = {8,"点击阵容","DungeonMainScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_LineUp",0,0,100,1,"",8,0,0,0,0,0,"将军，点“阵容”这里可以换武将哦。",},
    [9] = {9,"点击上阵位","HeroScene","heroArray",0,0,0,0,0,800,0,1,"Button_back_0",1,0,100,1,"",8,0,0,2,11,1,"将军，请点这里，让菜菜上阵吧！",},
    [10] = {10,"选择上阵武将","HeroScene","HeroSelectLayer",0,458,-179,135,50,800,0,1,"Panel_list",1,0,100,1,"add_team_knight",11,0,1,0,0,0,"",},
    [11] = {11,"点击主线","HeroScene","SpeedBar",0,0,0,0,0,0,1006,1,"Button_Dungeon",0,0,100,1,"",11,0,0,0,0,0,"将军，点击“副本”继续征战三国吧。",},
    [12] = {12,"点第一个副本","DungeonMainScene","DungeonMainLayer",0,70,160,500,165,600,0,1,"Panel_List",0,0,100,1,"",12,0,0,0,0,0,"将军，让我们继续消灭可恶的西凉兵吧。",},
    [13] = {13,"点第二个关卡","DungeonGateScene","DungeonMapLayer",0,0,0,0,0,600,0,1,"stage_3",0,0,30,1,"",12,0,0,0,0,0,"",},
    [14] = {14,"点击挑战按钮","DungeonGateScene","DungeonEnterGateLayer",0,0,0,0,0,600,0,1,"Button_Challenge",0,0,100,1,"dungeon_enterbattle",502,0,0,3,510,0,"",},
    [15] = {15,"战斗","DungeonBattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",502,0,0,0,0,0,"",},
    [16] = {16,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,30,1007,1,"back",0,0,100,1,"",17,0,0,0,0,0,"",},
    [17] = {17,"点击商城","DungeonMainScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_Shop",0,0,100,1,"",17,0,0,0,0,0,"",},
    [18] = {18,"点击神将","ShopScene","ShopDropMainLayer",0,0,0,0,0,600,0,1,"Button_jipin",0,0,100,1,"",18,0,0,2,22,0,"将军，在这里可以招募到强力的武将哦！",},
    [19] = {19,"点击招一次","ShopScene","ShopDropGodlyKnightLayer",0,0,0,0,0,0,0,1,"Button_onetime",0,0,100,1,"shop_drop_godly_knight",22,0,0,2,515,0,"希望会是一个漂亮的大姐姐加入我们~",},
    [20] = {20,"关闭动画","ShopScene","OneKnightDrop",0,0,0,0,0,500,0,1,"",0,0,100,0,"",22,0,1,0,0,0,"",},
    [21] = {21,"点击关闭","ShopScene","ShopDropInfoNextInputLayer",0,376,84,176,64,300,0,1,"Button_close",0,0,140,1,"",22,0,0,0,0,0,"",},
    [22] = {22,"点击阵容","ShopScene","SpeedBar",0,0,0,0,0,0,1008,1,"Button_LineUp",0,0,100,1,"",22,0,0,0,0,0,"",},
    [23] = {23,"点击上阵位","HeroScene","heroArray",0,0,0,0,0,800,0,1,"Button_back_1",0,0,100,1,"",22,0,0,3,25,1,"将军，现在让英英姐姐也上阵吧！",},
    [24] = {24,"选择上阵武将","HeroScene","HeroSelectLayer",0,469,-173,134,49,800,0,1,"Panel_list",1,0,100,1,"add_team_knight",25,0,1,0,0,0,"",},
    [25] = {25,"点击回主线","HeroScene","SpeedBar",0,0,0,0,0,0,1010,1,"Button_Dungeon",0,0,100,1,"",25,0,0,0,0,0,"",},
    [26] = {26,"点第一个副本","DungeonMainScene","DungeonMainLayer",0,70,160,500,165,600,0,1,"Panel_List",0,0,100,1,"",26,0,0,0,0,0,"让英英菜菜陪将军一起消灭敌人吧！",},
    [27] = {27,"点第三个关卡","DungeonGateScene","DungeonMapLayer",0,0,0,0,0,600,0,1,"stage_4",0,0,30,1,"",26,0,0,0,0,0,"",},
    [28] = {28,"点击挑战按钮","DungeonGateScene","DungeonEnterGateLayer",0,0,0,0,0,600,0,1,"Button_Challenge",0,0,100,1,"dungeon_enterbattle",503,0,0,4,511,0,"",},
    [29] = {29,"战斗","DungeonBattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",503,0,0,0,0,0,"",},
    [30] = {30,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,30,1011,1,"back",0,0,100,1,"",503,0,0,0,0,0,"",},
    [31] = {31,"点击首页","DungeonMainScene","SpeedBar",0,0,0,0,0,600,0,1,"Button_MainPage",0,0,100,1,"",31,0,0,0,0,0,"",},
    [32] = {32,"点击武将","MainScene","MainLayer",0,0,0,0,0,800,0,1,"Button_Knight",0,0,100,1,"",32,0,0,0,0,0,"将军，点“武将”可以查看并培养武将哦。",},
    [33] = {33,"点击展开","HeroFosterScene","HeroFosterLayer",0,494,-430,56,56,800,0,1,"Panel_strength_list",0,0,100,1,"",32,0,0,0,0,0,"",},
    [34] = {34,"点击强化","HeroFosterScene","HeroFosterLayer",0,0,0,0,0,800,0,1,"Button_strength",0,0,100,1,"",32,0,0,1,512,1,"现在，请点击这里给菜菜升级吧。",},
    [35] = {35,"点击添加材料","HeroDevelopScene","heroDevelopLayer",0,0,0,0,0,500,0,1,"Button_add_5",0,0,100,1,"",32,0,0,0,0,0,"点这里选择升级需要的材料卡牌吧。",},
    [36] = {36,"选择材料","HeroDevelopScene","HeroStrengthChoose",0,509,-202,85,80,600,0,1,"Panel_list",0,0,200,1,"",32,0,0,0,0,0,"",},
    [37] = {37,"选择材料","HeroDevelopScene","HeroStrengthChoose",0,509,-342,85,80,0,0,1,"Panel_list",0,0,200,1,"",32,0,0,0,0,0,"",},
    [38] = {38,"选择材料","HeroDevelopScene","HeroStrengthChoose",0,509,-482,85,80,0,0,1,"Panel_list",0,0,200,1,"",32,0,0,0,0,0,"",},
    [39] = {39,"选择材料","HeroDevelopScene","HeroStrengthChoose",0,509,-622,85,80,0,0,1,"Panel_list",0,0,200,1,"",32,0,0,1,41,0,"",},
    [40] = {40,"选择材料","HeroDevelopScene","HeroStrengthChoose",0,509,-758,85,80,0,0,1,"Panel_list",0,0,100,1,"",32,0,0,1,41,0,"",},
    [41] = {41,"确认选择","HeroDevelopScene","HeroStrengthChoose",0,0,0,0,0,0,0,1,"Button_ok",0,0,100,1,"",32,0,0,0,0,0,"",},
    [42] = {42,"点击强化","HeroDevelopScene","heroDevelopLayer",0,0,0,0,0,1000,0,1,"Button_strength",0,0,100,1,"uprade_knight_result",44,0,1,0,0,0,"请点击升级，让菜菜变得更强吧！",},
    [43] = {43,"回主线","HeroDevelopScene","SpeedBar",0,0,0,0,0,0,1014,1,"Button_Dungeon",0,0,100,1,"",44,0,0,0,0,0,"",},
    [44] = {44,"点第一个副本","DungeonMainScene","DungeonMainLayer",0,70,160,500,165,600,0,1,"Panel_List",0,0,100,1,"",44,0,0,0,0,0,"一鼓作气去打倒其他敌人吧！冲啊！",},
    [45] = {45,"点第四个关卡","DungeonGateScene","DungeonMapLayer",0,0,0,0,0,600,0,1,"stage_5",0,0,30,1,"",44,0,0,0,0,0,"",},
    [46] = {46,"点击挑战按钮","DungeonGateScene","DungeonEnterGateLayer",0,0,0,0,0,600,0,1,"Button_Challenge",0,0,100,1,"dungeon_enterbattle",504,0,0,5,513,0,"",},
    [47] = {47,"战斗","DungeonBattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",504,0,0,0,0,0,"",},
    [48] = {48,"点击宝箱","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,800,1015,1,"copperbox",0,0,100,1,"",504,0,0,0,0,0,"将军，请点击并领取第一个星星宝箱吧。",},
    [49] = {49,"点击领取","DungeonGateScene","DungeonTopLayer",0,0,0,0,0,800,0,1,"getbounsbtn",0,0,100,1,"dungeon_getbounssucc",505,0,1,1001,514,0,"",},
    [50] = {50,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,30,1016,1,"back",0,0,100,1,"",51,0,0,0,0,0,"",},
    [51] = {51,"点击首页","DungeonMainScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_MainPage",0,0,100,1,"",51,0,0,0,0,0,"",},
    [52] = {52,"点击武将","MainScene","MainLayer",0,0,0,0,0,600,0,1,"Button_Knight",0,0,100,1,"",52,0,0,0,0,0,"",},
    [53] = {53,"点击展开","HeroFosterScene","HeroFosterLayer",0,494,-261,56,56,800,0,1,"Panel_strength_list",0,0,100,1,"",52,0,0,0,0,0,"",},
    [54] = {54,"点击突破","HeroFosterScene","HeroFosterLayer",0,0,0,0,0,600,0,1,"Button_jingjie",0,0,100,1,"",52,0,0,0,0,1,"将军，请点击这里进行突破吧。",},
    [55] = {55,"确认突破","HeroDevelopScene","HeroJingJieLayer",0,0,0,0,0,800,0,1,"Button_shengjie",0,0,100,1,"advanced_knight_result",507,0,0,1,57,0,"",},
    [56] = {56,"动画中确认","HeroDevelopScene","HeroJingJieResult",0,0,0,0,0,400,0,1,"",0,0,100,0,"",507,0,1,0,0,0,"",},
    [57] = {57,"回主线","HeroDevelopScene","SpeedBar",0,0,0,0,0,0,1017,1,"Button_Dungeon",0,0,100,1,"",507,0,0,0,0,0,"",},
    [58] = {58,"点第一个副本","DungeonMainScene","DungeonMainLayer",0,70,160,500,165,600,0,1,"Panel_List",0,0,100,1,"",58,0,0,0,0,0,"将军，就剩最后一个敌人了，加油！",},
    [59] = {59,"点第五个关卡","DungeonGateScene","DungeonMapLayer",0,0,0,0,0,600,0,1,"stage_6",0,0,30,1,"",58,0,0,0,0,0,"",},
    [60] = {60,"点击挑战按钮","DungeonGateScene","DungeonEnterGateLayer",0,0,0,0,0,600,0,1,"Button_Challenge",0,0,100,1,"dungeon_enterbattle",520,0,0,6,516,0,"",},
    [61] = {61,"战斗","DungeonBattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",520,0,0,0,0,0,"",},
    [62] = {62,"副本完成动画","DungeonGateScene","DungeonSubtitleLayer",0,0,0,0,0,600,0,1,"",0,0,100,0,"",520,0,1,0,0,0,"",},
    [63] = {63,"点击包裹","DungeonMainScene","SpeedBar",0,0,0,0,0,3500,1071,1,"Button_Packbag",0,0,100,1,"",519,0,0,0,0,0,"请到“包裹”里使用道具吧！",},
    [64] = {64,"点击使用","BagScene","BagLayer",0,454,-233,136,50,600,0,1,"Panel_listview",0,0,100,1,"bag_use_item",521,0,0,2,65,1,"将军，请打开礼包获取珍稀合击紫将组吧！",},
    [65] = {65,"点击主线","BagScene","SpeedBar",0,0,0,0,0,800,1072,1,"Button_Dungeon",0,0,100,1,"",66,0,0,0,0,0,"",},
    [66] = {66,"点第二个副本","DungeonMainScene","DungeonMainLayer",0,85,415,490,175,600,0,1,"Panel_List",0,0,100,1,"",0,0,0,0,0,0,"将军，让我们去消灭作乱的黄巾军吧！",},
    [67] = {500,"点第一个副本","DungeonMainScene","DungeonMainLayer",5,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",500,1,0,0,0,0,"",},
    [68] = {501,"点第一个副本","DungeonMainScene","DungeonMainLayer",7,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",501,1,0,0,0,0,"",},
    [69] = {502,"点第一个副本","DungeonMainScene","DungeonMainLayer",16,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",502,1,0,0,0,0,"",},
    [70] = {503,"点第一个副本","DungeonMainScene","DungeonMainLayer",30,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",503,1,0,0,0,0,"",},
    [71] = {504,"点第一个副本","DungeonMainScene","DungeonMainLayer",48,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",504,1,0,0,0,0,"",},
    [72] = {505,"点第一个副本","DungeonMainScene","DungeonMainLayer",50,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",505,1,0,0,0,0,"",},
    [73] = {506,"点第一个副本","DungeonMainScene","DungeonMainLayer",2,70,160,500,165,0,0,1,"Panel_List",0,0,100,1,"",506,1,0,0,0,0,"将军，请点击此处进入战场吧。",},
    [74] = {507,"点第一个副本","DungeonMainScene","DungeonMainLayer",59,70,160,500,165,0,1017,1,"Panel_List",0,0,100,1,"",507,1,0,0,0,0,"将军，就剩最后一个敌人了，加油！",},
    [75] = {508,"第一关-点击关闭","DungeonGateScene","DungeonEnterGateLayer",5,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",500,1,0,0,0,0,"",},
    [76] = {509,"地图宝箱-点击关闭","DungeonGateScene","DungeonTopLayer",7,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",8,1,0,0,0,0,"",},
    [77] = {510,"第二关-点击关闭","DungeonGateScene","DungeonEnterGateLayer",16,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",17,1,0,0,0,0,"",},
    [78] = {511,"第三关-点击关闭","DungeonGateScene","DungeonEnterGateLayer",30,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",503,1,0,0,0,0,"",},
    [79] = {512,"武将列表-点击主线","HeroFosterScene","SpeedBar",44,0,0,0,0,600,0,1,"Button_Dungeon",0,0,100,1,"",44,1,0,0,0,0,"",},
    [80] = {513,"第四关-点击关闭","DungeonGateScene","DungeonEnterGateLayer",48,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",504,1,0,0,0,0,"",},
    [81] = {514,"星数宝箱-点击关闭","DungeonGateScene","DungeonTopLayer",50,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",505,1,0,0,0,0,"",},
    [82] = {515,"神将招募-点击关闭","ShopScene","ShopDropGodlyKnightLayer",22,0,0,0,0,600,0,1,"Button_close",0,0,100,1,"",22,1,0,0,0,0,"",},
    [83] = {516,"第五关-点击关闭","DungeonGateScene","DungeonEnterGateLayer",517,0,0,0,0,600,0,1,"closebtn",0,0,100,1,"",519,1,0,0,0,0,"",},
    [84] = {517,"第一章-点击返回","DungeonGateScene","DungeonMainGateLayer",520,0,0,0,0,600,0,1,"back",0,0,100,1,"",519,1,0,0,0,0,"",},
    [85] = {518,"点第二个副本","DungeonMainScene","DungeonMainLayer",0,85,415,490,175,600,0,1,"",0,0,100,1,"",0,1,0,0,0,0,"将军，让我们去消灭作乱的黄巾军吧！",},
    [86] = {519,"点击包裹","DungeonMainScene","SpeedBar",64,0,0,0,0,600,0,1,"Button_Packbag",0,0,100,1,"",519,1,0,0,0,0,"请到“包裹”里使用道具吧！",},
    [87] = {520,"点击包裹","DungeonMainScene","SpeedBar",64,0,0,0,0,600,1071,1,"Button_Packbag",0,0,100,1,"",519,1,0,0,0,0,"请到“包裹”里使用道具吧！",},
    [88] = {521,"点第二个副本","DungeonMainScene","DungeonMainLayer",0,85,415,490,175,600,1072,1,"",0,0,100,1,"",0,1,0,0,0,0,"将军，让我们去消灭作乱的黄巾军吧！",},
    [89] = {601,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,0,1037,1,"back",0,0,100,1,"",603,0,0,0,0,0,"",},
    [90] = {602,"点击阵容","DungeonMainScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_LineUp",0,0,100,1,"",603,0,0,0,0,0,"",},
    [91] = {603,"点击武器","HeroScene","heroArray",0,0,0,0,0,800,0,1,"Button_1",0,0,100,1,"",603,0,0,1,605,1,"将军，请点击这里穿戴武器吧。",},
    [92] = {604,"选择装备","HeroScene","EquipSelectLayer",0,450,-203,136,51,600,0,1,"Panel_list",0,0,100,1,"add_fight_equipment",605,0,1,0,0,0,"",},
    [93] = {605,"点击武器","HeroScene","heroArray",0,0,0,0,0,800,1025,1,"Button_1",0,0,100,1,"",605,0,0,0,0,1,"将军，点击这里可以查看武器详情。",},
    [94] = {606,"点击强化按钮","HeroScene","EquipmentInfo",0,0,0,0,0,600,0,1,"Button_strength",0,0,100,1,"",605,0,0,0,0,0,"将军，请点击这里强化武器吧。",},
    [95] = {607,"点强化一次","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,0,1,"Button_strength",0,0,100,1,"equipment_strengthen",702,0,1,2,608,0,"将军，请将这把武器强化三次吧。",},
    [96] = {608,"点强化一次","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,0,1,"Button_strength",0,0,100,1,"equipment_strengthen",704,0,1,4,609,0,"",},
    [97] = {609,"点强化一次","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,0,1,"Button_strength",0,0,100,1,"equipment_strengthen",611,0,1,6,610,0,"",},
    [98] = {610,"点返回","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,1026,1,"Button_return",0,0,100,1,"",611,0,0,0,0,0,"",},
    [99] = {611,"点主线","HeroScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_Dungeon",0,0,100,1,"",0,0,0,0,0,0,"将军，让我们回到副本继续征战吧！",},
    [100] = {702,"点武器","HeroScene","heroArray",703,0,0,0,0,800,0,1,"Button_1",0,0,100,1,"",702,1,0,0,0,0,"",},
    [101] = {703,"点强化按钮","HeroScene","EquipmentInfo",608,0,0,0,0,600,0,1,"Button_strength",0,0,100,1,"",702,1,0,0,0,0,"",},
    [102] = {704,"点武器","HeroScene","heroArray",705,0,0,0,0,800,0,1,"Button_1",0,0,100,1,"",704,1,0,0,0,0,"",},
    [103] = {705,"点强化按钮","HeroScene","EquipmentInfo",609,0,0,0,0,600,0,1,"Button_strength",0,0,100,1,"",704,1,0,0,0,0,"",},
    [104] = {801,"点击日常副本","DungeonMainScene","DungeonMainLayer",0,0,0,0,0,600,1028,1,"Button_NormalDungeon",0,0,100,1,"",801,0,0,0,0,1,"将军，请进日常副本看看吧。",},
    [105] = {802,"点击挑战按钮","VipMapScene","VipMapLayer",0,0,0,0,0,600,1029,1,"Button_Fight",0,0,100,1,"",801,0,0,0,0,0,"请尝试挑战第一个关卡吧~",},
    [106] = {803,"引导对话","VipMapScene","VipMapLayer",0,0,0,0,0,600,1032,1,"",0,0,100,0,"",0,0,0,0,0,0,"",},
    [107] = {901,"在章节列表点击征战","DungeonMainScene","SpeedBar",0,0,0,0,0,600,1023,1,"Button_PlayRule",0,0,100,1,"",901,0,0,0,0,0,"在“征战”里，有很多玩法等着将军哦。",},
    [108] = {902,"点击竞技场","PlayingScene","PlayingLayer",0,0,0,0,0,600,0,1,"Button_arena",1,1,100,1,"arena_list_users",902,0,0,0,0,1,"将军，让我们去竞技场看看吧。",},
    [109] = {903,"点击npc","ArenaScene","ArenaLayer",0,0,0,0,0,600,1024,1,"",0,1,100,1,"",1001,0,0,0,905,0,"点击挑战第一个对手吧，将军加油！",},
    [110] = {904,"战斗","ArenaBattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",1001,0,0,0,0,0,"",},
    [111] = {905,"点击声望商店","ArenaScene","ArenaLayer",0,0,0,0,0,800,1045,1,"Button_shop",0,0,100,1,"",1001,0,0,0,0,0,"点击这里的话，能进入声望商店。",},
    [112] = {906,"点击奖励","ShopScoreScene","ShopScoreLayer",0,0,0,0,0,1200,1046,1,"CheckBox_jjc_jiangli",0,0,100,1,"",1001,0,0,1,909,1,"请点这里看看奖励列表吧。",},
    [113] = {907,"点击购买第一个","ShopScoreScene","ShopScoreLayer",0,444,-365,137,48,600,0,1,"Panel_listview02",0,0,100,1,"",1001,0,0,1,909,1,"请点击购买第一个奖励吧。",},
    [114] = {908,"点击确定","ShopScoreScene","PurchaseScoreDialog",0,0,0,0,0,600,0,1,"Button_buy",0,0,100,1,"shop_item_buy_result",1002,0,0,0,0,0,"",},
    [115] = {909,"点击主线","ShopScoreScene","SpeedBar",0,0,0,0,0,600,1055,1,"Button_Dungeon",0,0,100,1,"",0,0,0,0,0,0,"将军，让我们回到副本继续征战三国吧！",},
    [116] = {1001,"点击竞技场","PlayingScene","PlayingLayer",905,0,0,0,0,600,0,1,"Button_arena",1,1,100,1,"",1001,1,0,0,0,0,"",},
    [117] = {1002,"点击竞技场","PlayingScene","PlayingLayer",1003,0,0,0,0,600,0,1,"Button_arena",1,1,100,1,"",1002,1,0,0,0,0,"",},
    [118] = {1003,"点击主线","ArenaScene","SpeedBar",0,0,0,0,0,600,1055,1,"Button_Dungeon",1,1,100,1,"",1002,1,0,0,0,0,"将军，让我们回到副本继续征战三国吧！",},
    [119] = {1101,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,0,1047,1,"back",0,0,100,1,"",1201,0,0,0,0,0,"",},
    [120] = {1102,"点击首页","DungeonMainScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_MainPage",0,0,100,1,"",1201,0,0,0,0,0,"从首页可以进入“回收”系统。",},
    [121] = {1103,"点击回收","MainScene","MainLayer",0,0,0,0,0,600,0,1,"Button_Recycle",0,0,100,1,"",1201,0,0,0,0,0,"“回收”这边，可以分解闲置的武将和装备哦。",},
    [122] = {1104,"点击最前面的加号","RecycleScene","RecycleKnightMainLayer",0,0,100,0,0,600,0,1,"Button_selected1",0,0,100,1,"",1201,0,0,1,1109,0,"将军，请把要回收的武将放在这里，回收武将可以获得将魂哦！",},
    [123] = {1105,"选择武将","RecycleScene","RecycleSelectKnightLayer",0,509,-201,85,80,600,0,1,"Panel_list",0,0,100,1,"",1201,0,0,0,0,0,"",},
    [124] = {1106,"点击确定","RecycleScene","RecycleSelectKnightLayer",0,0,0,0,0,0,0,1,"Button_certain",0,0,100,1,"",1201,0,0,0,0,0,"",},
    [125] = {1107,"点击分解","RecycleScene","RecycleKnightMainLayer",0,0,0,0,0,0,0,1,"Button_recycle",0,0,100,1,"",1201,0,0,2,0,0,"请点击分解吧，可以回收武魂和其他强化资源。",},
    [126] = {1108,"点击确定","RecycleScene","RecyclePreviewLayer",0,0,0,0,0,600,0,1,"Button_ok",0,0,100,1,"event_recycle_result",1202,0,1,0,1109,0,"",},
    [127] = {1109,"点神将商店","RecycleScene","rootMainLayer",0,0,0,0,0,600,1049,1,"Button_secret_shop",0,0,100,1,"",1202,0,0,0,0,1,"点击这里，就可以进入神将商店。",},
    [128] = {1110,"点击副本","SecretShopScene","SpeedBar",0,0,0,0,0,1200,1050,1,"Button_Dungeon",0,0,100,1,"",0,0,0,0,0,0,"将军，让我们回到三国继续征战三国吧!",},
    [129] = {1201,"点击回收","MainScene","MainLayer",1104,0,0,0,0,600,0,1,"Button_Recycle",0,0,100,1,"",1201,1,0,0,0,0,"",},
    [130] = {1202,"点击回收","MainScene","MainLayer",1109,0,0,0,0,600,0,1,"Button_Recycle",0,0,100,1,"",1202,1,0,0,0,0,"",},
    [131] = {1300,"点击首页","DungeonMainScene","SpeedBar",0,0,0,0,0,600,1051,1,"Button_MainPage",0,0,100,1,"",1301,0,0,0,0,0,"",},
    [132] = {1301,"点击更多","MainScene","MainLayer",0,0,0,0,0,600,0,1,"Button_More",0,0,100,1,"",1301,0,0,0,0,0,"从更多可以进入“三国志”系统。",},
    [133] = {1302,"点击三国志","MainScene","MoreButtonLayer",0,0,0,0,0,600,0,1,"Button_mingxing",0,0,100,1,"",1301,0,0,0,0,0,"在“三国志”里可以用收集到的三国志残片点亮命星。",},
    [134] = {1303,"点击点亮","SanguozhiMainScene","Sanguozhi",0,0,0,0,0,600,0,1,"Button_dianliang",0,0,100,1,"event_use_main_grouth_info",1304,0,1,1,1304,0,"将军，请点亮第一颗三国志命星吧，所有上阵武将的物防会增加10点哦！",},
    [135] = {1304,"点击主线","SanguozhiMainScene","SpeedBar",0,0,0,0,0,0,1053,1,"Button_Dungeon",0,0,100,1,"",0,0,0,0,0,0,"将军，请继续回到副本，收集更多三国志残卷吧。",},
    [136] = {1401,"点击征战","MainScene","SpeedBar",0,0,0,0,0,0,1022,1,"Button_PlayRule",0,0,100,1,"",1401,0,0,0,0,0,"",},
    [137] = {1402,"点击三国无双","PlayingScene","PlayingLayer",0,0,0,0,0,600,0,1,"Button_mingjiang",3,1,100,1,"",1402,0,0,0,0,0,"将军，让我们到三国无双看看吧。",},
    [138] = {1403,"点击第一关","WushScene","WushMainLayer",0,0,0,0,0,600,1027,1,"Panel_Monster1",0,0,100,1,"",1402,0,0,1,1406,0,"将军，请尝试完成这个关卡吧。",},
    [139] = {1404,"点击“困难”的挑战","WushScene","WushFightPreview",0,0,0,0,0,600,0,1,"Button_fight3",0,0,100,1,"",1501,0,0,0,0,0,"",},
    [140] = {1405,"战斗","BattleScene","",0,0,0,0,0,400,0,1,"",0,0,100,0,"",1501,0,0,0,0,0,"",},
    [141] = {1406,"点击神装商店","WushScene","WushMainLayer",0,0,0,0,0,600,1043,1,"Button_Shop",0,0,100,1,"",1501,0,0,0,0,0,"点击这里，就可以进入神装商店。",},
    [142] = {1407,"引导对话","ShopScoreScene","ShopScoreLayer",0,0,0,0,0,0,1044,1,"0",0,0,100,0,"",0,0,0,0,0,0,"",},
    [143] = {1501,"点击三国无双","PlayingScene","PlayingLayer",1406,0,0,0,0,600,0,1,"Button_mingjiang",3,1,100,1,"",1501,1,0,0,0,0,"",},
    [144] = {1601,"点击征战","MainScene","SpeedBar",0,0,0,0,0,0,1020,1,"Button_PlayRule",0,0,100,1,"",1601,0,0,0,0,0,"",},
    [145] = {1602,"点击夺宝","PlayingScene","PlayingLayer",0,0,0,0,0,600,0,1,"Button_duobao",2,1,100,1,"",1602,0,0,0,0,1,"将军，让我们到夺宝看看吧。",},
    [146] = {1603,"引导对话","TreasureComposeScene","TreasureComposeLayer",0,0,0,0,0,0,1021,1,"",0,0,100,0,"",0,0,0,0,0,0,"",},
    [147] = {1701,"点击返回","DungeonGateScene","DungeonMainGateLayer",0,0,0,0,0,0,1038,1,"back",0,0,100,1,"",1703,0,0,0,0,0,"",},
    [148] = {1702,"点击阵容","DungeonMainScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_LineUp",0,0,100,1,"",1703,0,0,0,0,0,"",},
    [149] = {1703,"点击武器","HeroScene","heroArray",0,0,0,0,0,800,0,1,"Button_1",0,0,100,1,"",1703,0,0,0,0,1,"将军，点击此处可以查看武器详情。",},
    [150] = {1704,"点击强化按钮","HeroScene","EquipmentInfo",0,0,0,0,0,600,0,1,"Button_strength",0,0,100,1,"",1703,0,0,0,0,0,"将军，请点击这里强化武器吧。",},
    [151] = {1705,"点强化一次","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,0,1,"Button_strength",0,0,100,1,"equipment_strengthen",1802,0,1,2,1706,0,"将军，请将这把武器强化三次吧。",},
    [152] = {1706,"点强化一次","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,0,1,"Button_strength",0,0,100,1,"equipment_strengthen",1804,0,1,4,1707,0,"",},
    [153] = {1707,"点强化一次","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,0,1,"Button_strength",0,0,100,1,"equipment_strengthen",1709,0,1,6,1708,0,"",},
    [154] = {1708,"点返回","EquipmentDevelopeScene","DevelopeLayer",0,0,0,0,0,0,1026,1,"Button_return",0,0,100,1,"",1709,0,0,0,0,0,"",},
    [155] = {1709,"点主线","HeroScene","SpeedBar",0,0,0,0,0,0,0,1,"Button_Dungeon",0,0,100,1,"",0,0,0,0,0,0,"将军，让我们回到副本继续征战三国吧！",},
    [156] = {1802,"点武器","HeroScene","heroArray",1803,0,0,0,0,800,0,1,"Button_1",0,0,100,1,"",1802,1,0,0,0,0,"",},
    [157] = {1803,"点强化按钮","HeroScene","EquipmentInfo",1706,0,0,0,0,600,0,1,"Button_strength",0,0,100,1,"",1802,1,0,0,0,0,"",},
    [158] = {1804,"点武器","HeroScene","heroArray",1805,0,0,0,0,800,0,1,"Button_1",0,0,100,1,"",1804,1,0,0,0,0,"",},
    [159] = {1805,"点强化按钮","HeroScene","EquipmentInfo",1707,0,0,0,0,600,0,1,"Button_strength",0,0,100,1,"",1804,1,0,0,0,0,"",},
    [160] = {1901,"点击征战","MainScene","SpeedBar",0,0,0,0,0,0,1020,1,"Button_PlayRule",0,0,100,1,"",1901,0,0,0,0,0,"",},
    [161] = {1902,"点击夺宝","PlayingScene","PlayingLayer",0,0,0,0,0,600,0,1,"Button_duobao",2,1,100,1,"",1902,0,0,0,0,1,"将军，让我们到夺宝看看吧。",},
    [162] = {1903,"点击顶端圆圈","TreasureComposeScene","TreasureListLayer",0,0,0,0,0,600,1021,1,"Panel_pageView",0,1,100,1,"",1902,0,0,1,1906,1,"点击此处可以抢夺该碎片。",},
    [163] = {1904,"抢夺第一个玩家","TreasureRobScene","TreasureRobLayer",0,461,-264,135,46,600,0,1,"Panel_list",0,0,100,1,"",2001,0,0,0,0,1,"试着从这名玩家身上抢碎片吧！",},
    [164] = {1905,"战斗","TreasureRobBattleScene","",0,0,0,0,0,600,0,1,"",0,0,100,0,"",2001,0,0,0,0,0,"",},
    [165] = {1906,"点击合成","TreasureComposeScene","TreasureListLayer",0,0,0,0,0,600,1060,1,"Button_compose",0,0,100,1,"treasure_compose",2002,0,1,1,1908,0,"请点击此处进行合成吧。",},
    [166] = {1907,"点击关闭","TreasureComposeScene","BaseInfoTreasure",0,0,0,0,0,600,0,1,"Button_close",0,0,100,1,"",2002,0,0,0,0,0,"",},
    [167] = {1908,"点击阵容","TreasureComposeScene","SpeedBar",0,0,0,0,0,600,1061,1,"Button_LineUp",0,0,100,1,"",2002,0,0,0,0,0,"",},
    [168] = {1909,"点击左边宝物框","HeroScene","heroArray",0,0,0,0,0,600,0,1,"Button_5",0,0,100,1,"",2002,0,0,1,1911,0,"请将刚刚合成的宝物装备上吧。",},
    [169] = {1910,"点击穿戴","HeroScene","EquipSelectLayer",0,455,-199,135,47,600,0,1,"Panel_list",0,0,100,1,"add_fight_treasure",2003,0,1,0,0,0,"",},
    [170] = {1911,"引导对话","HeroScene","heroArray",0,0,0,0,0,600,1062,1,"",0,0,100,0,"",0,0,0,0,0,0,"",},
    [171] = {2001,"点击夺宝","PlayingScene","PlayingLayer",1906,0,0,0,0,600,0,1,"Button_duobao",0,0,100,1,"",2001,1,0,0,0,0,"",},
    [172] = {2002,"主界面点击阵容","MainScene","SpeedBar",1909,0,0,0,0,600,1061,1,"Button_LineUp",0,0,100,1,"",2002,1,0,0,0,0,"",},
    [173] = {2003,"主界面点击阵容","MainScene","SpeedBar",1911,0,0,0,0,600,0,1,"Button_LineUp",0,0,100,1,"",2003,1,0,0,0,0,"",},
    [174] = {2101,"点装备","MainScene","MainLayer",0,0,0,0,0,600,1056,1,"Button_Equipment",0,0,100,1,"",2101,0,0,0,0,0,"",},
    [175] = {2102,"点击展开","EquipmentMainScene","EquipmentListLayer",0,500,-268,80,75,800,0,1,"Panel_listViewContainer",0,0,100,1,"",2101,0,0,1,2201,0,"",},
    [176] = {2103,"点击精炼","EquipmentMainScene","EquipmentListLayer",0,0,0,0,0,600,0,1,"Button_xilian",0,0,100,1,"",2101,0,0,0,0,1,"将军，点击这里可以进行装备精炼。",},
    [177] = {2104,"引导对话","EquipmentDevelopeScene","EquipmentDevelopeLayer",0,0,0,0,0,1000,1057,1,"",0,0,100,0,"",0,0,0,0,0,0,"",},
    [178] = {2201,"分支用引导对话","EquipmentMainScene","EquipmentMainLayer",0,0,0,0,0,600,1058,1,"",0,0,100,0,"",0,1,0,0,0,0,"",},
    [179] = {2301,"点宝物","MainScene","MainLayer",0,0,0,0,0,600,1059,1,"Button_Treasure",0,0,100,1,"",2301,0,0,0,0,0,"",},
    [180] = {2302,"点击展开","TreasureMainScene","TreasureListLayer",0,500,-268,80,75,800,0,1,"Panel_listViewContainer",0,0,100,1,"",2301,0,0,1,2401,0,"",},
    [181] = {2303,"点击精炼","TreasureMainScene","TreasureListLayer",0,0,0,0,0,600,0,1,"Button_xilian",0,0,100,1,"",2301,0,0,0,0,1,"将军，点击这里可以进行宝物精炼。",},
    [182] = {2304,"引导对话","TreasureDevelopeScene","TreasureDevelopeLayer",0,0,0,0,0,1000,1063,1,"",0,0,100,0,"",0,0,0,0,0,0,"",},
    [183] = {2401,"分支用引导对话","TreasureMainScene","TreasureMainLayer",0,0,0,0,0,600,1064,1,"",0,0,100,0,"",0,1,0,0,0,0,"",},
    [184] = {2501,"点击征战","","",0,0,0,0,0,600,1065,1,"",0,0,100,1,"",2501,0,0,0,0,0,"",},
    [185] = {2502,"点击领地攻讨","","",0,0,0,0,0,600,0,1,"",0,0,100,1,"",2501,0,0,0,0,0,"将军，让我们到领地攻讨看看吧。",},
    [186] = {2503,"点击桃源村","","",0,0,0,0,0,600,1066,1,"",0,0,100,1,"",2501,0,0,0,2602,0,"请将军占领这座城池吧。",},
    [187] = {2504,"点击挑战","","",0,0,0,0,0,600,0,1,"",0,0,100,1,"判断是否被攻占",2501,0,0,0,2507,0,"",},
    [188] = {2505,"战斗","","",0,0,0,0,0,600,0,1,"",0,0,100,0,"",2601,0,0,0,0,0,"",},
    [189] = {2506,"点击桃源村","","",0,0,0,0,0,600,1067,1,"",0,0,100,1,"",2601,0,0,0,0,0,"请将军派武将在城中巡逻吧。",},
    [190] = {2507,"点击中间加号","","",0,0,0,0,0,600,0,1,"",0,0,100,1,"判断是否处于巡逻状态",2601,0,0,0,2510,1,"点击此处可选择巡逻的武将。",},
    [191] = {2508,"点击选择","","",0,457,-195,136,50,600,0,1,"",0,0,100,1,"",2601,0,0,0,2603,0,"",},
    [192] = {2509,"点击开始巡逻","","",0,0,0,0,0,600,0,1,"",0,0,100,1,"",0,0,0,0,0,0,"点击此处就可以开始巡逻了！",},
    [193] = {2510,"点击返回","","",0,0,0,0,0,600,1068,1,"",0,0,100,1,"",0,0,0,0,0,0,"",},
    [194] = {2601,"点击领地攻讨","","",2506,0,0,0,0,600,0,1,"",0,0,100,1,"",2601,1,0,0,0,0,"",},
    [195] = {2602,"战力不足引导对话","","",0,0,0,0,0,600,1069,1,"",0,0,100,0,"",0,1,0,0,0,0,"",},
    [196] = {2603,"武将不足引导对话","","",0,0,0,0,0,600,1070,1,"",0,0,100,0,"",0,1,0,0,0,0,"",},
    }
}



local __index_step_id = {
    [1] = 1,
    [10] = 10,
    [1001] = 116,
    [1002] = 117,
    [1003] = 118,
    [11] = 11,
    [1101] = 119,
    [1102] = 120,
    [1103] = 121,
    [1104] = 122,
    [1105] = 123,
    [1106] = 124,
    [1107] = 125,
    [1108] = 126,
    [1109] = 127,
    [1110] = 128,
    [12] = 12,
    [1201] = 129,
    [1202] = 130,
    [13] = 13,
    [1300] = 131,
    [1301] = 132,
    [1302] = 133,
    [1303] = 134,
    [1304] = 135,
    [14] = 14,
    [1401] = 136,
    [1402] = 137,
    [1403] = 138,
    [1404] = 139,
    [1405] = 140,
    [1406] = 141,
    [1407] = 142,
    [15] = 15,
    [1501] = 143,
    [16] = 16,
    [1601] = 144,
    [1602] = 145,
    [1603] = 146,
    [17] = 17,
    [1701] = 147,
    [1702] = 148,
    [1703] = 149,
    [1704] = 150,
    [1705] = 151,
    [1706] = 152,
    [1707] = 153,
    [1708] = 154,
    [1709] = 155,
    [18] = 18,
    [1802] = 156,
    [1803] = 157,
    [1804] = 158,
    [1805] = 159,
    [19] = 19,
    [1901] = 160,
    [1902] = 161,
    [1903] = 162,
    [1904] = 163,
    [1905] = 164,
    [1906] = 165,
    [1907] = 166,
    [1908] = 167,
    [1909] = 168,
    [1910] = 169,
    [1911] = 170,
    [2] = 2,
    [20] = 20,
    [2001] = 171,
    [2002] = 172,
    [2003] = 173,
    [21] = 21,
    [2101] = 174,
    [2102] = 175,
    [2103] = 176,
    [2104] = 177,
    [22] = 22,
    [2201] = 178,
    [23] = 23,
    [2301] = 179,
    [2302] = 180,
    [2303] = 181,
    [2304] = 182,
    [24] = 24,
    [2401] = 183,
    [25] = 25,
    [2501] = 184,
    [2502] = 185,
    [2503] = 186,
    [2504] = 187,
    [2505] = 188,
    [2506] = 189,
    [2507] = 190,
    [2508] = 191,
    [2509] = 192,
    [2510] = 193,
    [26] = 26,
    [2601] = 194,
    [2602] = 195,
    [2603] = 196,
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
    [500] = 67,
    [501] = 68,
    [502] = 69,
    [503] = 70,
    [504] = 71,
    [505] = 72,
    [506] = 73,
    [507] = 74,
    [508] = 75,
    [509] = 76,
    [51] = 51,
    [510] = 77,
    [511] = 78,
    [512] = 79,
    [513] = 80,
    [514] = 81,
    [515] = 82,
    [516] = 83,
    [517] = 84,
    [518] = 85,
    [519] = 86,
    [52] = 52,
    [520] = 87,
    [521] = 88,
    [53] = 53,
    [54] = 54,
    [55] = 55,
    [56] = 56,
    [57] = 57,
    [58] = 58,
    [59] = 59,
    [6] = 6,
    [60] = 60,
    [601] = 89,
    [602] = 90,
    [603] = 91,
    [604] = 92,
    [605] = 93,
    [606] = 94,
    [607] = 95,
    [608] = 96,
    [609] = 97,
    [61] = 61,
    [610] = 98,
    [611] = 99,
    [62] = 62,
    [63] = 63,
    [64] = 64,
    [65] = 65,
    [66] = 66,
    [7] = 7,
    [702] = 100,
    [703] = 101,
    [704] = 102,
    [705] = 103,
    [8] = 8,
    [801] = 104,
    [802] = 105,
    [803] = 106,
    [9] = 9,
    [901] = 107,
    [902] = 108,
    [903] = 109,
    [904] = 110,
    [905] = 111,
    [906] = 112,
    [907] = 113,
    [908] = 114,
    [909] = 115,

}

local __key_map = {
  step_id = 1,
  step_desc = 2,
  scene_name = 3,
  layer_name = 4,
  next_step = 5,
  x = 6,
  y = 7,
  width = 8,
  height = 9,
  hooker_delay = 10,
  text_id = 11,
  click_enable = 12,
  click_widget = 13,
  click_param1 = 14,
  prepare_data = 15,
  zoom_percent = 16,
  need_mask = 17,
  protocal_id = 18,
  reset_Id = 19,
  is_assistant = 20,
  wait_effect = 21,
  check_data = 22,
  jump_step = 23,
  position = 24,
  comment = 25,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_newplay_guide_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function newplay_guide_info.getLength()
    return #newplay_guide_info._data
end



function newplay_guide_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_newplay_guide_info
function newplay_guide_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = newplay_guide_info._data[index]}, m)
    
end

---
--@return @class record_newplay_guide_info
function newplay_guide_info.get(step_id)
    
    return newplay_guide_info.indexOf(__index_step_id[step_id])
        
end



function newplay_guide_info.set(step_id, key, value)
    local record = newplay_guide_info.get(step_id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function newplay_guide_info.get_index_data()
    return __index_step_id
end