Activity.DanceMatch = Activity.DanceMatch or {};
local DanceMatch = Activity.DanceMatch;

DanceMatch.tbSetting = 
{
    szActName = "舞动江湖";
    READY_MAP_ID = 6004; --todo 更换
    FIGHT_MAP_ID = 6003;
    SIGNUP_TIME = 5 * 60;
    nMinLevel = 20;
    nMatchPlayerNum = 25;
    nEveryDayPlayerTimes = 2;--一天最多2次
    nTotalPlayTimes = 10; --最多参与次数
    szRankboardKey = "DanceAct"; --排行榜的key
    szCalendarKey = "DanceAct";
    MsgNotifySignUp = "舞动江湖开启报名了，请各位侠士准备入场";
    READY_MAP_POS = {
        {4353, 18323};
        {4865, 18363};
        {4353, 17818};
        {4865, 17818};
    };
    szGeneralHelpKey = "DanceActHelp"; --帮助界面key。没有则注释掉
    szEndGameBlackMsg = "您已失败，可点离开按钮离开";

    nForbitMoveSkillState = 1064; --禁止移动的buff
    nChangeToDogBuffSkill = 4705; --变狗的buffid
    ActionIDDance = 7; --跳舞动作
    nActionEventDance = 10002;
    ActionIDCry = 6; --哭泣动作
    nActionEventCry = 10002;
    nCryTime = 3; --哭泣的秒数
    ActionIDAdvance = 9; --踏歌跳舞动作

    tbDanceSongList = {10, 11, 17}; --歌曲列表 剑侠情 画地为牢 与情缘书

    tbStandPos = {
        {   --不同一套位置
            {4576, 18893, 40}; --进地图后的坐标及朝向
            {4372, 18689, 40};
            {4780, 18689, 40};
            {4168, 18485, 40};
            {4576, 18485, 40};
            {4984, 18485, 40};
            {3964, 18281, 40};
            {4372, 18281, 40};
            {4780, 18281, 40};
            {5188, 18281, 40};
            {3760, 18077, 40};
            {4168, 18077, 40};
            {4576, 18077, 40};
            {4984, 18077, 40};
            {5392, 18077, 40};
            {3964, 17873, 40};
            {4372, 17873, 40};
            {4780, 17873, 40};
            {5188, 17873, 40};
            {4168, 17669, 40};
            {4576, 17669, 40};
            {4984, 17669, 40};
            {4372, 17465, 40};
            {4780, 17465, 40};
            {4576, 17261, 40};

        };
        {
            {5676, 16150, 40};
            {5472, 15946, 40};
            {5880, 15946, 40};
            {5268, 15742, 40};
            {5676, 15742, 40};
            {6084, 15742, 40};
            {5064, 15538, 40};
            {5472, 15538, 40};
            {5880, 15538, 40};
            {6288, 15538, 40};
            {4860, 15334, 40};
            {5268, 15334, 40};
            {5676, 15334, 40};
            {6084, 15334, 40};
            {6492, 15334, 40};
            {5064, 15130, 40};
            {5472, 15130, 40};
            {5880, 15130, 40};
            {6288, 15130, 40};
            {5268, 14926, 40};
            {5676, 14926, 40};
            {6084, 14926, 40};
            {5472, 14722, 40};
            {5880, 14722, 40};
            {5676, 14518, 40};
        };
        {
            {8874, 16804, 40};
            {8670, 16600, 40};
            {9078, 16600, 40};
            {8466, 16396, 40};
            {8874, 16396, 40};
            {9282, 16396, 40};
            {8262, 16192, 40};
            {8670, 16192, 40};
            {9078, 16192, 40};
            {9486, 16192, 40};
            {8058, 15988, 40};
            {8466, 15988, 40};
            {8874, 15988, 40};
            {9282, 15988, 40};
            {9690, 15988, 40};
            {8262, 15784, 40};
            {8670, 15784, 40};
            {9078, 15784, 40};
            {9486, 15784, 40};
            {8466, 15580, 40};
            {8874, 15580, 40};
            {9282, 15580, 40};
            {8670, 15376, 40};
            {9078, 15376, 40};
            {8874, 15172, 40};

        };
    };

    TYPE_NORMAL = 1;
    TYPE_FINAL = 2;

    RIGHT = 1;
    WROING = 0;

    STATE_TRANS = {
        [10] = { --歌曲id对应的流程 剑侠情
            {nSeconds = 4,     szFunc = "ShowReady",                                    szDesc = "准备阶段"}, 
            {nSeconds = 4,     szFunc = "StartDanceBattle",    tbParam = {1},           szDesc = "准备阶段"}, 
            {nSeconds = 100,   szFunc = "ResetTime",                                    szDesc = "普通阶段"}, 
            {nSeconds = 20,    szFunc = "ShowTips",            tbParam = {"死斗阶段"},  szDesc = "休息时间"}, 
            {nSeconds = 3,     szFunc = "StartDanceBattle",    tbParam = {2},           szDesc = "死斗阶段"}, 
            {nSeconds = 115,   szFunc = "StopGame",                                     szDesc = "死斗阶段"}, 
            {nSeconds = 5,     szFunc = "CloseBattle",                                  szDesc = "活动结束"},
        };
        [11] = { --歌曲id对应的流程  画地为牢
            {nSeconds = 4,     szFunc = "ShowReady",                                    szDesc = "准备阶段"}, 
            {nSeconds = 4,     szFunc = "StartDanceBattle",    tbParam = {1},           szDesc = "准备阶段"}, 
            {nSeconds = 130,   szFunc = "ResetTime",                                    szDesc = "普通阶段"}, 
            {nSeconds = 18,    szFunc = "ShowTips",            tbParam = {"死斗阶段"},  szDesc = "休息时间"}, 
            {nSeconds = 3,     szFunc = "StartDanceBattle",    tbParam = {2},           szDesc = "死斗阶段"}, 
            {nSeconds = 116,   szFunc = "StopGame",                                     szDesc = "死斗阶段"}, 
            {nSeconds = 5,     szFunc = "CloseBattle",                                  szDesc = "活动结束"},
        };
        [17] = { --歌曲id对应的流程  与情缘书
            {nSeconds = 4,     szFunc = "ShowReady",                                    szDesc = "准备阶段"}, 
            {nSeconds = 4,     szFunc = "StartDanceBattle",    tbParam = {1},           szDesc = "准备阶段"}, 
            {nSeconds = 120,   szFunc = "ResetTime",                                    szDesc = "普通阶段"}, 
            {nSeconds = 16,    szFunc = "ShowTips",            tbParam = {"死斗阶段"},  szDesc = "休息时间"}, 
            {nSeconds = 3,     szFunc = "StartDanceBattle",    tbParam = {2},           szDesc = "死斗阶段"}, 
            {nSeconds = 87,   szFunc = "StopGame",                                     szDesc = "死斗阶段"}, 
            {nSeconds = 5,     szFunc = "CloseBattle",                                  szDesc = "活动结束"},
        };
        
    };

    tbCmdStr = { "1", "2", "3", "4" }; --输入指令对应字符串
    tbCmdStrToImg = {
        ["1"] = "ArrowDown01";
        ["2"] = "ArrowLeft01";
        ["3"] = "ArrowUpper01";
        ["4"] = "ArrowRight01";
    };   
    tbWinAddScore = { --正确时加的积分
        [1] = 1;
        [2] = 2;
    }; 
    tbCommoboAddScore = {
        [5]     = 2;
        [10]    = 4;
        [15]    = 6;
        [20]    = 8;
        [25]    = 10;
        [30]    = 12;
        [35]    = 14;
    };


    tbCmdSetting = {
        [10] = { --歌曲对应指令 剑侠情
            [1] = {     --普通模式
            --.出现时间，持续时间，指令长度
                [17] = { nDurTime = 7, nCmdLen = 6};
                [24] = { nDurTime = 6, nCmdLen = 6};
                [30] = { nDurTime = 6, nCmdLen = 6};
                [36] = { nDurTime = 6, nCmdLen = 6};
                [42] = { nDurTime = 6, nCmdLen = 6};
                [48] = { nDurTime = 6, nCmdLen = 6};
                [54] = { nDurTime = 7, nCmdLen = 6};
                [61] = { nDurTime = 8, nCmdLen = 7};
                [69] = { nDurTime = 4, nCmdLen = 5};
                [73] = { nDurTime = 5, nCmdLen = 5};
                [78] = { nDurTime = 8, nCmdLen = 7};
                [86] = { nDurTime = 5, nCmdLen = 5};
                [91] = { nDurTime = 7, nCmdLen = 6};

            };
            [2] = {  --死斗模式
                --.出现时间，持续时间，指令长度
                [125] = { nDurTime = 6, nCmdLen = 7};
                [131] = { nDurTime = 7, nCmdLen = 7};
                [138] = { nDurTime = 5, nCmdLen = 6};
                [143] = { nDurTime = 7, nCmdLen = 7};
                [150] = { nDurTime = 6, nCmdLen = 7};
                [156] = { nDurTime = 7, nCmdLen = 7};
                [163] = { nDurTime = 5, nCmdLen = 6};
                [168] = { nDurTime = 8, nCmdLen = 8};
                [176] = { nDurTime = 5, nCmdLen = 7};
                [181] = { nDurTime = 5, nCmdLen = 7};
                [186] = { nDurTime = 7, nCmdLen = 8};
                [193] = { nDurTime = 6, nCmdLen = 8};
                [199] = { nDurTime = 5, nCmdLen = 7};
                [204] = { nDurTime = 4, nCmdLen = 6};
                [208] = { nDurTime = 6, nCmdLen = 8};
                [214] = { nDurTime = 7, nCmdLen = 8};
                [221] = { nDurTime = 5, nCmdLen = 7};
                [226] = { nDurTime = 9, nCmdLen = 10};

            };
        };
        [11] = { --歌曲对应指令 画地为牢
            [1] = {     --普通模式
            --.出现时间，持续时间，指令长度
                [26 ] = { nDurTime = 3, nCmdLen = 4};
                [29 ] = { nDurTime = 5, nCmdLen = 5};
                [34 ] = { nDurTime = 6, nCmdLen = 6};
                [40 ] = { nDurTime = 6, nCmdLen = 6};
                [46 ] = { nDurTime = 3, nCmdLen = 4};
                [49 ] = { nDurTime = 7, nCmdLen = 6};
                [56 ] = { nDurTime = 4, nCmdLen = 5};
                [60 ] = { nDurTime = 5, nCmdLen = 5};
                [65 ] = { nDurTime = 7, nCmdLen = 6};
                [72 ] = { nDurTime = 4, nCmdLen = 5};
                [76 ] = { nDurTime = 4, nCmdLen = 5};
                [80 ] = { nDurTime = 7, nCmdLen = 6};
                [87 ] = { nDurTime = 4, nCmdLen = 5};
                [91 ] = { nDurTime = 5, nCmdLen = 4};
                [96 ] = { nDurTime = 4, nCmdLen = 5};
                [100] = { nDurTime = 3, nCmdLen = 4};
                [103] = { nDurTime = 4, nCmdLen = 5};
                [107] = { nDurTime = 4, nCmdLen = 5};
                [111] = { nDurTime = 4, nCmdLen = 5};
                [115] = { nDurTime = 8, nCmdLen = 7};

            }; 
            [2] = {  --死斗模式 
                --.出现时间，持续时间，指令长度
                [153] = { nDurTime = 7, nCmdLen = 7};
                [160] = { nDurTime = 9, nCmdLen = 9};
                [169] = { nDurTime = 7, nCmdLen = 7};
                [176] = { nDurTime = 8, nCmdLen = 8};
                [184] = { nDurTime = 8, nCmdLen = 8};
                [192] = { nDurTime = 8, nCmdLen = 8};
                [200] = { nDurTime = 7, nCmdLen = 7};
                [207] = { nDurTime = 4, nCmdLen = 6};
                [211] = { nDurTime = 8, nCmdLen = 9};
                [223] = { nDurTime = 8, nCmdLen = 9};
                [231] = { nDurTime = 7, nCmdLen = 8};
                [238] = { nDurTime = 9, nCmdLen = 10};
                [247] = { nDurTime = 8, nCmdLen = 9};
                [255] = { nDurTime = 3, nCmdLen = 5};
                [258] = { nDurTime = 9, nCmdLen = 10};

            };
        };
        [17] = { --歌曲对应指令  与情缘书
            [1] = {     --普通模式
            --.出现时间，持续时间，指令长度
                [28 ] = { nDurTime = 7, nCmdLen = 6};
                [35 ] = { nDurTime = 7, nCmdLen = 6};
                [42 ] = { nDurTime = 7, nCmdLen = 6};
                [49 ] = { nDurTime = 7, nCmdLen = 6};
                [56 ] = { nDurTime = 7, nCmdLen = 6};
                [63 ] = { nDurTime = 8, nCmdLen = 7};
                [71 ] = { nDurTime = 6, nCmdLen = 6};
                [77 ] = { nDurTime = 9, nCmdLen = 7};
                [86 ] = { nDurTime = 5, nCmdLen = 5};
                [91 ] = { nDurTime = 8, nCmdLen = 7};
                [99 ] = { nDurTime = 7, nCmdLen = 6};
                [106] = { nDurTime = 7, nCmdLen = 5};

            };
            [2] = {  --死斗模式
                --.出现时间，持续时间，指令长度
                [142] = { nDurTime = 7, nCmdLen = 7};
                [149] = { nDurTime = 7, nCmdLen = 7};
                [156] = { nDurTime = 6, nCmdLen = 7};
                [162] = { nDurTime = 8, nCmdLen = 8};
                [170] = { nDurTime = 6, nCmdLen = 7};
                [176] = { nDurTime = 8, nCmdLen = 8};
                [184] = { nDurTime = 7, nCmdLen = 7};
                [191] = { nDurTime = 7, nCmdLen = 7};
                [198] = { nDurTime = 6, nCmdLen = 8};
                [204] = { nDurTime = 8, nCmdLen = 9};
                [212] = { nDurTime = 7, nCmdLen = 8};
                [219] = { nDurTime = 7, nCmdLen = 8};

            };
        };
    };

    szMailContent = "本场比赛您获得了第%d名，这是您的奖励！";
    --单场奖励配置
    tbAwardSetting = {
        {nRankEnd = 1,  Award = {{"BasicExp", 100}, {"Coin", 20000}, {"Energy", 1000} } },
        {nRankEnd = 2,  Award = {{"BasicExp", 90}, {"Coin", 18000}, {"Energy", 800} } },
        {nRankEnd = 3,  Award = {{"BasicExp", 90}, {"Coin", 16000}, {"Energy", 600} } },
        {nRankEnd = 4,  Award = {{"BasicExp", 75}, {"Coin", 15000}, {"Energy", 500} } },
        {nRankEnd = 5,  Award = {{"BasicExp", 75}, {"Coin", 12000}, {"Energy", 400} } },
        {nRankEnd = 10,  Award = {{"BasicExp", 60}, {"Coin", 10000}, {"Energy", 300} } },
        {nRankEnd = 15,  Award = {{"BasicExp", 45}, {"Coin", 8000}, {"Energy", 200} } },
        {nRankEnd = 20,  Award = {{"BasicExp", 45}, {"Coin", 6000}, {"Energy", 150} } },
        {nRankEnd = 25,  Award = {{"BasicExp", 30}, {"Coin", 3000}, {"Energy", 100} } },
    };

    szFianalMailContent = "大侠，这次舞动江湖你获得了%s积分，排行%d名。这是您的奖励，请查收。"; --最终排名的奖励邮件
    --活动结束后的最终排名奖励
    tbFinnalAwardSetting = {
        {nRankEnd = 1,  tbAward = {{"Item", 7954, 1}, {"AddTimeTitle" , 6706, -1}, {"ZhenQi", 50000} } },
        {nRankEnd = 5,  tbAward = {{"Item", 7954, 1}, {"AddTimeTitle" , 6707, -1}, {"ZhenQi", 35000} } },
        {nRankEnd = 10,  tbAward = {{"AddTimeTitle" , 6708, -1}, {"ZhenQi", 30000} } },
        {nRankEnd = 50,  tbAward = {{"ZhenQi", 20000} } },
        {nRankEnd = 200,  tbAward = {{"ZhenQi", 10000} } },
        {nRankEnd = 500,  tbAward = {{"ZhenQi", 6000} } },
    };

};