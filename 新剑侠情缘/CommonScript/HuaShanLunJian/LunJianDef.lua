
HuaShanLunJian.tbDef = HuaShanLunJian.tbDef or {};

local tbDef = HuaShanLunJian.tbDef;
tbDef.nPlayStateNone = 0; --赛季的状态没有
tbDef.nPlayStatePrepare = 1; --赛季的状态预选赛
tbDef.nPlayStateFinals = 2; --赛季的状态决赛
tbDef.nPlayStateEnd = 3; --赛季的状态结束
tbDef.nPlayStateMail = 4; --赛季的状态开始发邮件

tbDef.nPlayGameStateNone = 1; --比赛没有
tbDef.nPlayGameStateStart = 2; --比赛开始
tbDef.nPlayGameStateEnd   = 3; --比赛结束

tbDef.nSaveGroupID = 103; --保存的Group
tbDef.nSaveMonth   = 1; --保存月
tbDef.nSaveFightTeamID  = 2; --保存战队
tbDef.nSaveFightTeamTime = 3; --创建战队的时间

tbDef.nSaveGuessGroupID = 105; --保存竞猜的Group
tbDef.nSaveGuessVer = 1; --保存竞猜的版本
tbDef.nSaveGuessTeam = 2; --保存竞猜的队伍
tbDef.nSaveGuessOneNote = 3; --保存竞猜的注数

tbDef.nSaveHonorGroupID = 110; --保存荣誉
tbDef.nSaveHonorValue   = 1; --保存荣誉值

tbDef.nTeamTypeName   = 1; --战队的名称
tbDef.nTeamTypePlayer = 2; --战队的成员
tbDef.nTeamTypeValue  = 3; --战队的参加的值 积分 * 100 * 100 + 胜利场数 * 100 + 总共场数
tbDef.nTeamTypeTime   = 4; --战队的参加的时间
tbDef.nTeamTypePlayDay   = 5; --战队的天的时间
tbDef.nTeamTypePerCount   = 6; --战队的每天的次数
tbDef.nTeamTypeServerIdx = 7; --战队的服务器索引，只在武林大会中用到 --前20强, 因为要传回本服时设置新的队伍id，所以还是设值的
tbDef.nTeamTypeServerName = 8; --战队的服务器名，只在武林大会中用到 --前20强
tbDef.nTeamTypeRank = 9; --战队的排名，跨服上排一次存回本服 武林大会用

tbDef.nPrePlayTotalTime = 100000; --设置一个最大的时间

tbDef.nMaxFightTeamVer     = 10000; --最大版本号
tbDef.nMaxFightTeamCount   = 500; --最大战队数
tbDef.nUpateDmgTime        = 2;


tbDef.nGuessTypeTeam    = 1; --竞猜的战队
tbDef.nGuessTypeOneNote = 2; --竞猜的注数
tbDef.nSaveGuessingCount = 1500; --保存玩家竞猜数
tbDef.nMaxGuessingVer    = 1000; --保存最大竞猜数版本

tbDef.nNextPreGamePreMap  = 2; --使用完准备场数加载数
tbDef.nPreGamePreMapTime  = 5; --重新创建地图的时间




-------下面策划填写 ----------------------------------------
tbDef.szRankBoard      = "LunJianRank";
tbDef.szOpenTimeFrame = "HuaShanLunJian"; --开启时间轴
tbDef.fPlayerToNpcDmg = 0.1; --玩家对Npc的伤害占得比例
tbDef.nGameMaxRank    = 1002; --最大排行
tbDef.nMinPlayerLevel = 60; --最小等级开启
tbDef.nFightTeamNameMin = 3; --战队长度最小
tbDef.nFightTeamNameMax = 6; --战队长度最大

if version_vn then
tbDef.bStringLenName = true;
tbDef.nFightTeamNameMin = 4; --越南战队长度最小
tbDef.nFightTeamNameMax = 14; --越南战队长度最大
end

if version_th then
tbDef.nFightTeamNameMin = 6;
tbDef.nFightTeamNameMax = 10;
end

tbDef.nFightTeamJoinMemebr = 2; --组入队员 两人单独组队

tbDef.nDeathSkillState = 1520; --死亡后状态
tbDef.nPartnerFightPos = 1; --伙伴的出战位置
tbDef.nHSLJCrateLimitTime = 4 * 3600;
tbDef.nChampionshipNewTime = 15 * 60 * 60 * 24;
tbDef.nHSLJHonorBox = 2000; --多少荣誉一个宝箱
tbDef.nHSLJHonorBoxItem = 2853; --荣誉宝箱ID

tbDef.nFightTeamShowTitle =
{
    [1] = 7006;
    [2] = 7007;
};

tbDef.tbStatueMapID = --雕像的地图ID
{
    [10] =
    {
        nTitleID = 7004;
        tbAllPos =
        {
            [1] = {11630, 15865, 0};
            [2] = {11079, 15330, 48};
            [3] = {12200, 15323, 16};
            [4] = {11620, 14723, 32};
        };
    };

    [15] =
    {
        nTitleID = 7004;
        tbAllPos =
        {
            [1] = {13495, 12170, 40};
            [2] = {13495, 10299, 56};
            [3] = {11645, 10294, 8};
            [4] = {11642, 12149, 24};
        };
    };
};

tbDef.tbFactionStatueNpc = --门派雕像Npc
{
    [1] = --男
    {
        [1] = 1886; --天王
        [2] = 1887; --峨嵋
        [3] = 1888; --桃花
        [4] = 1889; --逍遥
        [5] = 1890; --武当
        [6] = 1891; --天忍
        [7] = 1892; --少林
        [8] = 1893; --翠烟
        [9] = 2118;--唐门
        [10] = 2971;--昆仑
        [11] = 2221;--丐帮
        [12] = 2220;--五毒
        [13] = 2381;--藏剑
        [14] = 2382;--长歌
        [15] = 2677;--天山
        [16] = 2912;--霸刀
        [17] = 2969;--华山
        [18] = 3283;--明教
        [19] = 3443;--段氏
        [20] = 3727;--万花
        [21] = 3796;--杨门
    };
    [2] = --女
    {
        [1] = 3285; --天王
        [2] = 1887; --峨嵋
        [3] = 1888; --桃花
        [4] = 3445; --逍遥
        [5] = 2914; --武当
        [6] = 3798; --天忍
        [7] = 1892; --少林
        [8] = 1893; --翠烟
        [9] = 2118;--唐门
        [10] = 2119;--昆仑
        [11] = 3729;--丐帮
        [12] = 2220;--五毒
        [13] = 2381;--藏剑
        [14] = 2382;--长歌
        [15] = 2678;--天山
        [16] = 2913;--霸刀
        [17] = 2970;--华山
        [18] = 3284;--明教
        [19] = 3444;--段氏
        [20] = 3728;--万花
        [21] = 3797;--杨门
    };
}

--赛制
tbDef.tbGameFormat =
{
    [1] =
    {
        szName = "双人赛";
        nFightTeamCount = 2; --战队的人数
        bOpenPartner = true; --是否开启同伴
        szOpenHSLJMail =
[[  武林盛会华山论剑开始了！
    本届华山论剑为[FFFE0D]双人赛[-]赛制，每人可携带一名同伴助阵。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！
    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月华山论剑双人赛开始了！[-]
    双人赛限制战队成员为[FFFE0D]2名[-]，每人可携带一位同伴助战。在准备场可以点击[FFFE0D]队伍[-]旁同伴头像更换助战同伴。
    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。
    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。
    [FFFE0D]注意：[-]报名参加比赛无需组队，系统自动为战队成员创建队伍
]];
    };

    [2] =
    {
        szName = "三人赛";
        nFightTeamCount = 3; --战队的人数
        bOpenPartner = true; --是否开启同伴
        szOpenHSLJMail =
[[  武林盛会华山论剑开始了！
    本届华山论剑为[FFFE0D]三人赛[-]赛制，每人可携带一名同伴助阵。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！
    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月华山论剑三人赛开始了！[-]
    三人赛限制战队成员为[FFFE0D]3名[-]，每人可携带一位同伴助战。在准备场可以点击[FFFE0D]队伍[-]旁同伴头像更换助战同伴。
    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。
    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。
    [FFFE0D]注意：[-]报名参加比赛无需组队，系统自动为战队成员创建队伍
]];
    };

    [3] =
    {
        szName = "三人决斗赛";
        nFightTeamCount = 3; --战队的人数
        bOpenPartner = false; --是否开启同伴
        nPartnerPos  = 4; --上阵的同伴位置
        szPKClass = "PlayDuel"; --决斗赛的类别 新增赛季通知程序
        nFinalsMapCount = 3; --创建决赛地图数量
        szOpenHSLJMail =
[[  武林盛会华山论剑开始了！
    本届华山论剑为[FFFE0D]三人决斗[-]赛制，每人可携带所有已上阵同伴助阵。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！
    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月华山论剑三人决斗赛开始了！[-]
    三人决斗赛限制战队成员为[FFFE0D]3名[-]，根据队员编号与其他战队成员分别对战，已上阵同伴均可助战。
    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。
    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。
    [FFFE0D]注意：[-]报名参加比赛无需组队，系统自动为战队成员创建队伍
]];
    };

    [4] =
    {
        szName = "单人赛";
        nFightTeamCount = 1; --战队的人数
        bOpenPartner = false; --是否开启同伴
        nPartnerPos  = 4; --上阵的同伴位置
        szOpenHSLJMail =
[[  武林盛会华山论剑开始了！
    本届华山论剑为[FFFE0D]单人赛[-]赛制，每人可携带所有已上阵同伴助阵。各位大侠请踊跃参加，早日成为武林至尊！
    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月华山论剑单人赛开始了！[-]
    单人赛限制战队成员为[FFFE0D]1名[-]，已上阵同伴均可助战。
    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。
    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。
]];
    };

    [5] =
    {
        szName = "相克双人赛";
        nFightTeamCount = 2; --战队的人数
        bOpenPartner = true; --是否开启同伴
        bSeriesLimit = true; --成员五行相克限制
        szOpenHSLJMail =
[[  武林盛会华山论剑开始了！
    本届华山论剑为[FFFE0D]相克双人赛[-]赛制，每人可携带一名同伴助阵。战队两人五行必须有相克关系，如金木，火金，木土等。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！
    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月华山论剑相克双人赛开始了！[-]
    双人赛限制战队成员为[FFFE0D]2名[-]，战队两人五行必须有相克关系，如金木，火金，木土等。每人可携带一位同伴助战。
    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。
    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。
    [FFFE0D]注意：[-]报名参加比赛无需组队，系统自动为战队成员创建队伍
]];
    };

};

tbDef.tbSkipGameFormat = --更换赛季:暂时关闭单人赛
{
    [4] = 1;
};

-- if version_tx then
--     tbDef.tbSkipGameFormat = --更换赛季
--     {
--         [3] = 4;
--     };
-- end

--冠军竞猜
tbDef.tbChampionGuessing =
{
    nMinLevel = 60; --最小等级
    nOneNoteGold  = 200; --猜中给多少钱
    nMaxOneNote   = 5; -- 最大投注数 废弃
    szAwardMail = "大侠，本次华山论剑冠军为%s战队，您参加了本次华山论剑竞猜并预测正确，获得了%s元宝，请领取附件。";
};


--预选赛
tbDef.tbPrepareGame =
{
    szStartWorldNotify = "今日华山论剑将于3分钟后开启报名，请大家提前准备！";
    szPreOpenWorldMsg = "新一轮华山论剑预选赛开始报名了，时间3分钟，请大家尽快通过活动日历报名参加！";
    bShowMSgWhenEnterMatchTime = true; ---在每次等待下次匹配的时候都世界公告
    nStartMonthDay = 7; --每月开始几号
    nStartOpenTime = 10 * 3600; --每月开始几号的时间

    nPreGamePreMap    = 5; --开始加载准备场数

    nStartEndMonthDay = 15; --未超过本月几号开始活动
    nEndMothDay = 27;  --结束时间

    nMaxPlayerJoinCount = 32; --最大参加场数
    nPerWeekJoinCount = 16; --每周获得场数
    nWinJiFen = 3; --胜利积分
    nFailJiFen = 0; --失败积分
    nDogfallJiFen = 1; --平局积分

    nPrepareTime = 180; --准备时间秒
    nPlayGameTime = 150; --比赛时间秒
    nFreeGameTime = 30; --间隔时间
    nKickOutTime = 3 * 60; --踢出去的时间
    nPlayerGameCount = 8; --每天中共开启次数
    nMatchMaxFindCount = 8; --向下寻找多少战队
    nPerDayJoinCount = 6; --每天参加多少次

    nDefWinPercent = 0.5; --默认胜率
    nPrepareMapTID = 1200; --准备场的地图
    nPlayMapTID = 1201; --比赛地图

    nMatchEmptyTime = 1.5 * 60; --轮空的时间
    tbPlayMapEnterPos = --进入比赛地图的位置
    {
        [1] = {1440, 2961};
        [2] = {3697, 2949};
    };

    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime        = 3; --321延迟多么后开战
    nEndDelayLeaveMap     = 8; --结束延迟多少秒离开地图
    nMaxEnterTeamCount    = 50; --最多进入战队数

    tbAllAward =  --奖励
    {
        tbWin = --赢
        {
            {"BasicExp", 15 * 5};
            {"item", 2424, 2 * 5};
        };

        tbDogfall = --平
        {
            {"BasicExp", 10 * 5};
            {"item", 2424, 1 * 5};
        };

        tbFail = --失败
        {
            {"BasicExp", 10 * 5};
            {"item", 2424, 1 * 5};
        };
    };

    tbAwardMail =
    {
        szWin = "恭喜阁下所在战队参加华山论剑预选赛，获得了一场胜利，附件奖励请查收！";
        szDogfall = "阁下所在战队参加华山论剑预选赛，与对手旗鼓相当，附件奖励请查收！";
        szFail = "阁下所在战队参加华山论剑预选赛，遗憾败北，附件奖励请查收，以资鼓励！";
    };
};


--决赛
tbDef.tbFinalsGame =
{
    szInformFinals = "恭喜少侠所在战队进入八强，成功晋级。决赛将于[FFFE0D]本月28日21：30[-]举行，请准时参加！"; --八强邮件内容
    nMonthDay = 28; --决赛日期
    nFinalsMapTID = 1202; --决赛的地图
    nAudienceMinLevel = 20; --观众最少等级
    nEnterPlayerCount = 300; --进入观众的人数
    nFrontRank = 8; --前几名进入决赛
    nChampionPlan = 2; --冠军赛的对阵表
    nChampionWinCount = 2; --冠军赛最多赢多少场
    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime = 3; --321延迟多少秒后PK
    nEndDelayLeaveMap  = 8; --结束延迟多少秒离开
    --tbPlayGameAward = {{"BasicExp", 8}};

    tbAgainstPlan = --对阵图
    {
        [8] = --8强
        {
            [1] = {tbIndex = {1, 8},  tbPos = { [1] = {1529, 6364}, [2] = {3643, 6346} } };
            [2] = {tbIndex = {4, 5},  tbPos = { [1] = {9104, 6291}, [2] = {11249, 6279} } };
            [3] = {tbIndex = {2, 7},  tbPos = { [1] = {2505, 3141}, [2] = {4671, 3141} } };
            [4] = {tbIndex = {3, 6},  tbPos = { [1] = {8617, 3277}, [2] = {10774, 3254} } };
        };

        [4] = --4强
        {
            [1] = {tbIndex = {1, 2}, tbPos = { [1] = {1529, 6364}, [2] = {3643, 6346} } };
            [2] = {tbIndex = {3, 4}, tbPos = { [1] = {9104, 6291}, [2] = {11249, 6279} } };
        };

        [2] = --2强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {5170, 9474}, [2] = {7765, 9420} } };
        };
    };

    --决赛状态
    tbPlayGameState =
    {
        [1]  =
        {
            nNextTime = 300,
            szCall = "Freedom",
            szRMsg = "比赛即将开始",
            szWorld = "本届华山论剑冠军争夺战将在[FFFE0D]5分钟[-]后开始，玩家可以进场支持心仪的参赛选手！";
        };
        [2]  =
        {
            nNextTime = 150,
            szCall = "StartPK",
            szRMsg = "八强赛进行中",
            szWorld = "本届华山论剑[FFFE0D]八强赛[-]正式开始了！";
            nPlan = 8;
            tbTeamMsg =
            {
                tbWin =
                {
                    szMsg = "恭喜您的战队成功晋级华山论剑半决赛！";
                    szKinMsg = "恭喜家族成员「%s」所在战队成功晋级华山论剑半决赛！";
                    szFriend = "恭喜您的好友「%s」所在战队成功晋级华山论剑半决赛！";
                };
                tbFail =
                {
                    szMsg = "您的战队失利了，没能进入半决赛，再接再厉！";
                };
            };
        };
        [3]  =
        {
            nNextTime = 60,
            szCall = "StopPK",
            szRMsg = "半决赛即将开始";
            --szWorld = "本届华山论剑半决赛将在[FFFE0D]30秒[-]后开始，请大家进场观战并支持心仪的选手！";

        };
        [4]  =
        {
            nNextTime = 150,
            szCall = "StartPK",
            szRMsg = "半决赛进行中",
            nPlan = 4;
            szWorld = "本届华山论剑[FFFE0D]半决赛[-]开始了！";
            szEndWorldNotify = "恭喜%s成功晋级本届华山论剑决赛，将在华山之巅一决雌雄！";
            tbTeamMsg =
            {
                tbWin =
                {
                    szMsg = "恭喜您的战队成功晋级华山论剑决赛！";
                    szKinMsg = "恭喜家族成员「%s」所在战队成功晋级华山论剑决赛，冠军荣耀触手可及！";
                    szFriend = "恭喜您的好友「%s」所在战队成功晋级华山论剑决赛，冠军荣耀触手可及！";
                };
                tbFail =
                {
                    szMsg = "您的战队失利了，没能进入决赛，再接再厉！";
                };
            };

        };
        [5]  =
        {
            nNextTime = 60,
            szCall = "StopPK",
            szRMsg = "决赛即将开始";
            --szWorld = "本届华山论剑决赛将在5分钟后开始，谁才是真正的强者？拭目以待！";
        };
        [6]  =
        {
            nNextTime = 150,
            szCall = "StartPK",
            szRMsg = "第一场决赛进行中",
            szWorld = "本届华山论剑[FFFE0D]决赛第一场[-]开始了，顶尖高手强力碰撞！";
            nPlan = 2;
        };
        [7]  =
        {
            nNextTime = 60,
            szCall = "StopPK",
            szRMsg = "第二场决赛即将开始";
        };
        [8]  =
        {
            nNextTime = 150,
            szCall = "StartPK",
            szRMsg = "第二场决赛进行中",
            szWorld = "本届华山论剑[FFFE0D]决赛第二场[-]开始了，冠军或许就要产生了？！";
            nPlan = 2;
        };
        [9]  =
        {
            nNextTime = 60,
            szCall = "StopPK",
            szRMsg = "第三场决赛即将开始",
            bCanStop = true;
        };
        [10] =
        {
            nNextTime = 150,
            szCall = "StartPK",
            szRMsg = "第三场决赛进行中",
            nPlan = 2;
            bCanStop = true;
            szWorld = "本届华山论剑[FFFE0D]决赛最后一场[-]开始了，这真是宿命的对决！";

        };
        [11] =
        {
            nNextTime = 60,
            szCall = "StopPK",
            szRMsg = "比赛结束";
        };
        [12] =
        {
            nNextTime = 180,
            szCall = "SendAward",
            szRMsg = "离开场地";
        };
        [13] =
        {
            nNextTime = 300,
            szCall = "KickOutAllPlayer",
            szRMsg = "离开场地",
        };
    };
}

tbDef.szEightRankMail =  --八强邮件给全服发
[[  本届华山论剑[FFFE0D]八强[-]已经产生，将于[FFFE0D]本月28日21：30[-]举行最终决赛，届时大家可以进入决赛地图观战。当前已经开启[FFFE0D]冠军竞猜[-]活动，请查看最新消息相应界面！
]]


tbDef.tbLunJianMapId = {
    [tbDef.tbPrepareGame.nPrepareMapTID] = 1;
    [tbDef.tbPrepareGame.nPlayMapTID] = 1;
    [tbDef.tbFinalsGame.nFinalsMapTID] = 1;
}