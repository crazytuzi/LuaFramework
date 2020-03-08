WuLinDaHui.tbDef = {
	nMinPlayerLevel = 60; --参与比赛的最小等级
	nMaxFightTeamCount  = 99; --最大战队数,这样一个块最多就99个战队了， 因为有四人和多的变量，战队数从500减到100 同时方便id的设置
	nMaxFightTeamVer = 1000; --最大版本号--见到1000，就是最多100个scriptdata， 一次武林大会一个服不会超10w的
	nGameTypeInTeamId =  100000 ; -- =nMaxFightTeamVer * nMaxFightTeamCount
	nServerIdxInTeamId = 1000000;--因为是跨服的，要包含serverIdx --目前是不会超过1000的
    nMaxGuessingVer    = 1000; --保存最大竞猜数版本
    nSaveGuessingCount = 500; --保存玩家竞猜数

	--TODO ，代码测试战队id数是不会重的

	nPreGamePreMap = 1;--创建的准备场个数，跨服上就只建一个准备场图了
	nAutoTicketFightPowerRank = 200; --即报名开始时, 时本服战力排名前200的玩家获得参与武林大会的资格。
	--nMaxTicketFightPowerRank = 200; --101-200需要买门派的

	nSellTicketGold = 300; --购买门票资格费用，元宝
	nPreMatchJoinCount = 20; --预选赛的参与次数

    tbNotifyMatchTime = { "15:42", "21:27" };--预告滚动条通知时间
    tbStartMatchTime = {"15:45", "21:30"}; --比赛开启时间
    tbEndMatchTime   = {"16:15", "22:00"}; --比赛结束时间 

    szFinalStartMatchTime = "21:30"; --决赛比赛开启时间
    szFinalEndMatchTime   = "22:00"; --决赛比赛结束时间 

    nOpenPreMatchRound = 4; --初赛每种是开四次，开了四次后才会换下一种

	nMaxJoinTeamNum = 2; --同时最大参与的战队数量
	nDefWinPercent = 0.5; --默认胜率
	nPreRankSaveCount = 20; --初赛保留的战队信息数
    nClientRequestTeamDataInterval = 60; --客户端请求战队数据的时间间隔
    nClientRequestTeamDataIntervalInMap = 5; --在比赛地图内的请求战队数据间隔


    tbUiShowItemIds = { 6007, 6008, 6010, 10153, 6013, 6014, 5238, 6012 }; --界面里展示的道具Id
    nNewsInformationTimeLast = 3600*24*12; --最新消息的持续时间
    szNewsKeyNotify = "WLDHNews"; --武林大会的最新消息key
    szNewsContent1 = [==[
      [eebb01]「武林大会」[-]是剑侠江湖最高级别的竞技赛事，本届武林大会举办前一个周期内获得华山论剑[eebb01]前50[-]玩家才有资格组成战队[eebb01]跨服[-]进行擂台战斗，你可能面对从来也未见过的顶尖高手，最终的强者才能获得无上的荣耀——“武林至尊”。
      大会共[eebb01]3[-]个赛制，分别为[eebb01]双人赛[-]，[eebb01]三人赛[-]及[eebb01]四人赛[-]，每种赛制都将决出“[eebb01]武林至尊[-]”，每位侠士可以选择参与其中的[eebb01]两[-]种。
      [eebb01]注[-]：武林大会比赛期间，跨服名将暂时关闭。
[eebb01]1、参与资格[-]
      在[eebb01]预告阶段[-]结束时：
      等级达到60级，曾在本年度周期期间内获得过华山论剑前50名的大侠自动获得参赛资格；
      已开69等级上限但是之前未开放华山论剑的服务器资格获取方式为到达本服战力排行榜的[eebb01]前200名[-]。

[eebb01]2、赛制及时间[-]
      双人赛、三人赛的比赛规则与华山论剑活动一致。
      四人赛允许最多4名玩家组成战队，战斗时同伴无法助战。
      [eebb01]比赛时间如下：[-]
    ]==]; --最新消息里的内容
    szNewsContentTime1 = "12月3日、12月4日";
    szNewsContentTime2 = "12月9日";
    szNewsContentTime3 = "12月5日、12月6日";
    szNewsContentTime4 = "12月10日";
    szNewsContentTime5 = "12月7日、12月8日";
    szNewsContentTime6 = "12月11日";

    szNewsContent2  = [==[
    初赛日每天的比赛时间为[eebb01]15:45~16:15[-]和[eebb01]21:30~22:00[-]两个时间段；决赛日每天的比赛时间为[eebb01]21:30~22:00[-]。
[eebb01]3、大会流程[-]
    武林大会分为如下几个阶段：
[eebb01]预告阶段[-]
    大会开始报名前，会预告一段时间，该[eebb01]阶段结束[-]时会[eebb01]立即[-]产生具有参赛资格的侠士。
[eebb01]报名阶段[-]
    具有参赛资格的侠士，在这个阶段内自行与[eebb01]本服[-]其他侠士组成战队，在武林大会的专属界面报名各比赛。
    每位侠士最多参与[eebb01]2种[-]比赛，并且每个比赛可以有[eebb01]不同[-]的战队和队友。
    阶段结束后，[eebb01]不再允许创建战队[-]报名比赛，请各位大侠不要错过时间！
[eebb01]初赛阶段[-]
    每种赛制的初赛仅进行[eebb01]二天[-]，15：45及21：30各开一轮，持续半小时，每3分钟开始一场比赛，共开启36场比赛。
    每个战队总共最多允许参加[eebb01]20[-]场比赛，最终初赛排名前[eebb01]16[-]的战队进入决赛阶段。
[eebb01]决赛阶段[-]
    决赛会进行[eebb01]16进8[-]比赛、[eebb01]8进4[-]比赛、[eebb01]半决赛[-]各[eebb01]1[-]场，最终冠军争夺赛采取[eebb01]3局2胜[-]制。
    决赛时，玩家可以对最终冠军进行[eebb01]竞猜[-]，正确后可以获得[eebb01]300元宝[-]奖励。


    ]==];


    szMailTextYuGao = "  大侠，江湖盛事武林大会即将开启，获得参与资格后可与知己好友组成战队与最顶尖的高手正面碰撞，登上擂台向各路豪杰展示你们的英雄气概吧！\n欲知详情，请点击前往[00ff00][url=openwnd:武林大会活动界面, WLDHJoinPanel][-]了解。";
    szMailTextGetTicket = "  大侠神功盖世，获得华山论剑前[eebb01]50[-]名，武林盟一致同意[eebb01]邀请[-]阁下参与下届武林大会，届时请与其他具有参与资格的侠士组队前往报名，争夺武林至尊的称号！";
    szMailTextGetTicketByRank = "  大侠神功盖世，荣登本服战力前[eebb01]200[-]名，武林盟一致同意[eebb01]邀请[-]阁下参与本届武林大会，请与其他具有参与资格的侠士在报名阶段组队前往报名，争夺武林至尊的称号！";
    --szMailTextBuyTicket = "  恭喜侠士的武功获得武林盟的认可，阁下需要[eebb01]「门票」[-]来获得参与武林大会的资格，请前往[00ff00][url=openwnd:武林大会活动界面, WLDHJoinPanel][-]购买。";

    szEnterFinalQualifyMsgKin = "恭喜家族成员[eebb01]%s[-]所在战队成功晋级本届武林大会[eebb01]%s[-]16强"; --晋级16强的家族提示
    szEnterFinalQualifyMsgFriend = "恭喜您的好友[eebb01]%s[-]所在战队成功晋级本届武林大会[eebb01]%s[-]16强"; --晋级16强的好友提示

    nPhoneSysNotifyMsgBeforeSec = 60; --推送提醒的对应提前秒数
    szPhoneSysNotifyMsg = "大侠，武林大会的比赛即将开始了"; --手机上的推送提醒消息

    nHSLJTicketRankPos = 50; --前50名的才有资格进武林大会
	SAVE_GROUP = 136; 
	SAVE_KEY_TicketTime = 1; --获取的门票时间, 大于等于报名时间的就是有资格, 
    --因为现在是按华山论剑前50名有资格的形式，所以在华山获取前50名时直接设上值，然后新开一届时记录上次的报名时间，只要 获取前50名的时间大于上次的开启时间则就有资格
	SAVE_KEY_CanBuyTicketTime = 2; --能买门票的时间, 大于等于报名时间的就是有资格
}

local tbDef = WuLinDaHui.tbDef;

tbDef.tbPrepareGame = {
    szBeforeNotifyMsg = "【武林大会】[eebb01]%s初赛[-]将于[eebb01]3分钟[-]后开始，请参赛选手提前准备！";
    szPreOpenWorldMsg = "【武林大会】[eebb01]%s初赛[-]开始了，首场比赛将于3分钟后开始，请参赛选手尽快入场！";

    szWinNotifyInKin = "【武林大会】恭喜家族成员[eebb01]%s[-]所在战队取得了一场[eebb01]%s初赛[-]胜利。";
    -- szWinNotifyInFriend = "【武林大会】您的好友[eebb01]%s[-]所在战队在刚刚结束的[eebb01]%s初赛[-]中取得了胜利。"

    nPreGamePreMap    = 1; --开始加载准备场数，跨服上就只建一个准备场图不能增加了
    nSynTopZoneTeamDataTimeDelay = 20; --每场比赛完最多20秒一次更新数据

    nWinJiFen = 3; --胜利积分
    nFailJiFen = 0; --失败积分
    nDogfallJiFen = 1; --平局积分

    nPrepareTime = 180; --准备时间秒
    nPlayGameTime = 150; --比赛时间秒
    nFreeGameTime = 30; --间隔时间
    nKickOutTime = 30; --踢出去的时间
    nPlayerGameCount = 9; --每天中共开启次数
    nMatchMaxFindCount = 8; --向下寻找多少战队
    nPerDayJoinCount = 20; --每天参加多少次

    nDefWinPercent = 0.5; --默认胜率
    nPrepareMapTID = 1302; --准备场的地图
    nPlayMapTID = 1303; --比赛地图

    nMatchEmptyTime = 1.5 * 60; --轮空的时间
    tbPlayMapEnterPos = --进入比赛地图的位置
    {
        [1] = {2752, 3213};
        [2] = {4665, 3213};
    };

    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime        = 3; --321延迟多么后开战
    nEndDelayLeaveMap     = 8; --结束延迟多少秒离开地图

    tbAllAward = {};
};

--冠军竞猜
tbDef.tbChampionGuessing =
{
    nMinLevel = 60; --最小等级
    tbWinAward = {{"Gold", 300}};--猜中给的奖励
    szAwardMail = "大侠，本次武林大会%s冠军为%s战队，您参加了本次武林大会竞猜并预测正确，获得了奖励，请领取附件。";
};

--武林大会主界面的预告说明
-- tbDef.szYuGaoUiTexture = "UI/Textures/GrowInvest02.png"
tbDef.szYuGaoUiDesc = [[
    [eebb01]「武林大会」[-]是剑侠江湖最高级别的竞技赛事，曾在本年度周期期间内获得过华山论剑[eebb01]前50名[-]的大侠有资格组成战队[eebb01]跨服[-]进行擂台战斗，最终的强者将获得无上的荣耀——“武林至尊”。
    大会共[eebb01]3[-]个赛制，分别为[eebb01]双人赛[-]，[eebb01]三人赛[-]及[eebb01]四人赛[-]，每种赛制都将决出“[eebb01]武林至尊[-]”，每位侠士可以选择参与其中的[eebb01]两[-]种。
    在[eebb01]预告阶段[-]结束时：
    等级达到60级，曾在本年度周期期间内获得过华山论剑前50名的大侠自动获得参赛资格。
    已开69等级上限但是之前未开放华山论剑的服务器资格获取方式为到达本服战力排行榜的[eebb01]前200名[-]。
    大会详情请查阅[eebb01]最新消息[-]相关页面！
]]
tbDef.tbMatchUiDesc = 
{
	[1] = [[
		双人赛说明
		双人赛限制战队成员为[eebb01]2名[-]，每人可携带一位同伴助战。在准备场可以点击[eebb01]队伍[-]旁同伴头像更换助战同伴。
	]];
	[2] = [[
		三人赛说明
		三人赛限制战队成员为[eebb01]3名[-]，每人可携带一位同伴助战。在准备场可以点击[eebb01]队伍[-]旁同伴头像更换助战同伴。
	]];
	-- [3] = [[
	-- 	三人决斗人赛说明
	-- 	三人决斗赛限制战队成员为[eebb01]3名[-]，根据队员编号与其他战队成员分别对战，已上阵同伴均可助战。
	-- ]];
	[3] = [[
		四人赛说明
		四人赛限制战队成员为[eebb01]4名[-]，不允许携带同伴助战。
	]];
}


WuLinDaHui.tbScheduleDay =  {
	 {
		nGameType = 1;
	};
	{
		nGameType = 1;
	};
	{
		nGameType = 2;
	};
	{
		nGameType = 2;
	};
    {
        nGameType = 3;
    };
    {
        nGameType = 3;
    };
	{
		nGameType = 1;
		bFinal = true;
	};
	{
		nGameType = 2;
		bFinal = true;
	};
    {
        nGameType = 3;
        bFinal = true;
    };
}

WuLinDaHui.tbGameFormat = {
	[1] = {
		szName = "双人赛";
		nFightTeamCount = 2;
		bOpenPartner = true; --是否开启同伴
        szDescTip = "两人组队参赛"; --界面里的简短说明
        szTexture = "UI/Textures/WLDH1.png";
	};
	[2] = {
		szName = "三人赛";
		nFightTeamCount = 3;
		bOpenPartner = true; --是否开启同伴
        szDescTip = "三人组队参赛"; 
        szTexture = "UI/Textures/WLDH2.png";
	};
	-- [3] = {
	-- 	szName = "三人决斗赛";
	-- 	nFightTeamCount = 3;
	-- 	szPKClass = "PlayDuel";
	-- 	bOpenPartner = false; --是否开启同伴
 --        nPartnerPos = 4; --上阵同伴数
	-- 	nFinalsMapCount = 3; --会创建三个地图
 --        szDescTip = "三人组队，按照编号分别对战的比赛"; 
        -- szTexture = "UI/Textures/WLDH3.png";
	-- };
	[3] = {
		szName = "四人赛";
		nFightTeamCount = 4;
		bOpenPartner = false; --是否开启同伴
        szDescTip = "四人组队参赛"; 
        szTexture = "UI/Textures/WLDH4.png";
	};
};


tbDef.tbFinalsGame =
{
    szBeforeNotifyMsg = "【武林大会】[eebb01]%s冠军争夺战[-]将于[eebb01]3分钟[-]后开始，玩家可以进场支持心仪的参赛选手！";

    nFinalsMapTID = 1304; --决赛的地图
    nAudienceMinLevel = 20; --观众最少等级
    nEnterPlayerCount = 600; --进入观众的人数
    nFrontRank = 16; --前几名进入决赛
    nChampionPlan = 2; --冠军赛的对阵表
    nChampionWinCount = 2; --冠军赛最多赢多少场
    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime = 3; --321延迟多少秒后PK
    nEndDelayLeaveMap  = 8; --结束延迟多少秒离开
    --tbPlayGameAward = {{"BasicExp", 8}};

    tbAgainstPlan = --对阵图
    {
        [16] = --16强
        {
            [1] = {tbIndex = {1, 16},  tbPos = { [1] = {9337, 13474},  [2] = {11213, 13480} } };
            [2] = {tbIndex = {8, 9},   tbPos = { [1] = {13667, 13495}, [2] = {15542, 13482} } };
            [3] = {tbIndex = {5, 12},  tbPos = { [1] = {13682, 6310},  [2] = {15531, 6321} } };
            [4] = {tbIndex = {4, 13},  tbPos = { [1] = {9348, 6318},   [2] = {11187, 6307} } };
            [5] = {tbIndex = {2, 15},  tbPos = { [1] = {4944, 8026},   [2] = {6800, 8010} } };
            [6] = {tbIndex = {7, 10},  tbPos = { [1] = {4928, 11860},  [2] = {6799, 11854} } };
            [7] = {tbIndex = {6, 11},  tbPos = { [1] = {18108, 11889}, [2] = {19954, 11881} } };
            [8] = {tbIndex = {3, 14},  tbPos = { [1] = {18076, 8024},  [2] = {19956, 8022} } };
        };

        [8] = --8强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {9337, 13474},  [2] = {11213, 13480} } };
            [2] = {tbIndex = {3, 4},  tbPos = { [1] = {13667, 13495}, [2] = {15542, 13482} } };
            [3] = {tbIndex = {5, 6},  tbPos = { [1] = {13682, 6310},  [2] = {15531, 6321} } };
            [4] = {tbIndex = {7, 8},  tbPos = { [1] = {9348, 6318},   [2] = {11187, 6307} } };
        };

        [4] = --4强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {9337, 13474},  [2] = {11213, 13480} } };
            [2] = {tbIndex = {3, 4},  tbPos = { [1] = {13667, 13495}, [2] = {15542, 13482} } };
        };

        [2] = --2强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {11331, 10095}, [2] = {13594, 10064} } };
        };
    };
    
    --决赛状态
    tbPlayGameState =
    {
        [1]  = 
        {
            nNextTime = 180,
            szCall = "Freedom", 
            szRMsg = "比赛即将开始", 
            szWorld = "【武林大会】[eebb01]%s[-]冠军争夺战将在[eebb01]3分钟[-]后开始，玩家可以进场支持心仪的参赛选手！";
        };
         [2]  = 
        {   
            nNextTime = 150, 
            szCall = "StartPK",  
            szRMsg = "十六强赛进行中",
            szWorld = "【武林大会】[eebb01]%s[-]十六强赛正式开始了！";
            nPlan = 16;
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的战队成功晋级武林大会八强赛！";
                    szKinMsg = "【武林大会】恭喜家族成员[eebb01]%s[-]所在战队成功晋级[eebb01]%s[-]八强赛!";
                    szFriend = "【武林大会】恭喜您的好友[eebb01]%s[-]所在战队成功晋级[eebb01]%s[-]八强赛!";
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
            szRMsg = "八强赛即将开始";
            --szWorld = "本届武林大会半决赛将在[eebb01]30秒[-]后开始，请大家进场观战并支持心仪的选手！";

        };
        [4]  = 
        {   
            nNextTime = 150, 
            szCall = "StartPK",  
            szRMsg = "八强赛进行中",
            szWorld = "【武林大会】[eebb01]%s[-]八强赛正式开始了！";
            nPlan = 8;
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的战队成功晋级武林大会半决赛！";
                    szKinMsg = "【武林大会】恭喜家族成员[eebb01]%s[-]所在战队成功晋级[eebb01]%s[-]半决赛！";
                    szFriend = "【武林大会】恭喜您的好友[eebb01]%s[-]所在战队成功晋级[eebb01]%s[-]半决赛！";
                };
                tbFail =
                {
                    szMsg = "您的战队失利了，没能进入半决赛，再接再厉！";
                };
            };
        };
        [5]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "半决赛即将开始";
            --szWorld = "本届武林大会半决赛将在[eebb01]30秒[-]后开始，请大家进场观战并支持心仪的选手！";

        };
        [6]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK",
            szRMsg = "半决赛进行中",
            nPlan = 4;
            szWorld = "【武林大会】[eebb01]%s[-]半决赛正式开始了！";
            szEndWorldNotify = "恭喜%s成功晋级本届武林大会[eebb01]%s[-]决赛，将在决赛擂台一决雌雄！";
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的战队成功晋级武林大会决赛！";
                    szKinMsg = "【武林大会】恭喜家族成员[eebb01]%s[-]所在战队成功晋级[eebb01]%s[-]决赛，冠军荣耀触手可及！";
                    szFriend = "【武林大会】恭喜您的好友[eebb01]%s[-]所在战队成功晋级[eebb01]%s[-]决赛，冠军荣耀触手可及！";
                };
                tbFail =
                {
                    szMsg = "您的战队失利了，没能进入决赛，再接再厉！";
                };
            };

        };
        [7]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "决赛即将开始";
            --szWorld = "本届武林大会决赛将在5分钟后开始，谁才是真正的强者？拭目以待！";
            
        };
        [8]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第一场决赛进行中", 
            szWorld = "【武林大会】[eebb01]%s[-]决赛第一场开始了，顶尖高手强力碰撞！";
            szNotifyMyWorldTeamMsg = "本服的%s正在为争夺武林至尊而激战，欢迎诸位少侠前往观战，共睹传奇诞生！";
            nPlan = 2; 
        };
        [9]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "第二场决赛即将开始";
        };
        [10]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第二场决赛进行中", 
            szWorld = "【武林大会】[eebb01]%s[-]决赛第二场开始了，冠军或许就要产生了？！";
            szNotifyMyWorldTeamMsg = "本服的%s正在为争夺武林至尊而激战，欢迎诸位少侠前往观战，共睹传奇诞生！";
            nPlan = 2; 
        };
        [11]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "第三场决赛即将开始",
            bCanStop = true;
        };
        [12] = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第三场决赛进行中",
            nPlan = 2;
            bCanStop = true;
            szWorld = "【武林大会】[eebb01]%s[-]决赛最后一场开始了，这真是宿命的对决！";
            szNotifyMyWorldTeamMsg = "本服的%s正在为争夺武林至尊而激战，欢迎诸位少侠前往观战，共睹传奇诞生！";
        };
        [13] = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "比赛结束";
        };
        [14] = 
        {
            nNextTime = 150, 
            szCall = "SendAward", 
            szRMsg = "离开场地";
        };
        [15] = 
        {
            nNextTime = 0, 
            szCall = "KickOutAllPlayer", 
            szRMsg = "离开场地",
        };
    };
};


function WuLinDaHui:GetMatchIndex(nPlan, nRank)
	local tbMathcInfo = tbDef.tbFinalsGame.tbAgainstPlan[ nPlan ]
	for i,v in ipairs(tbMathcInfo) do
		for i2,v2 in ipairs(v.tbIndex) do
			if nRank == v2 then
				return i2, i, #tbMathcInfo;
			end	
		end
	end
end

WuLinDaHui.szActNameYuGao = "WuLinDaHuiActYuGao"
WuLinDaHui.szActNameBaoMing = "WuLinDaHuiActBaoMing"
WuLinDaHui.szActNameMain = "WuLinDaHuiAct"

WuLinDaHui.nActYuGaoTime = 60;-- 活动开始到预告结束的时间

function WuLinDaHui:IsBaoMingAndMainActTime()
	local bIsAct = Activity:__IsActInProcessByType(self.szActNameBaoMing)
	if bIsAct then
		return true, self.szActNameBaoMing
	end
	bIsAct = Activity:__IsActInProcessByType(self.szActNameMain)
	if bIsAct then
		return true, self.szActNameMain
	end
end

function WuLinDaHui:IsInMap(nMapTemplateId)
    if self.tbDef.tbPrepareGame.nPrepareMapTID == nMapTemplateId or
          self.tbDef.tbPrepareGame.nPlayMapTID == nMapTemplateId or
          self.tbDef.tbFinalsGame.nFinalsMapTID == nMapTemplateId then
          return true
    end
    return false
end

function WuLinDaHui:GetToydayGameFormat()
    local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameMain)
    if not nStartTime then
        return
    end

    local nToday = Lib:GetLocalDay()
    local nOpenActDay = Lib:GetLocalDay(nStartTime)
    local nActStartDaySec = Lib:GetLocalDayTime(nStartTime)
    local nMatchDay = nToday - nOpenActDay + 1
    local tbScheInfo = self.tbScheduleDay[nMatchDay]
    if not tbScheInfo then
        return
    end
    return tbScheInfo.nGameType
end

function WuLinDaHui:CanOperateParnter()
    local nGameType = self:GetToydayGameFormat()
    if not nGameType then
        return
    end
    local tbGameFormat = self.tbGameFormat[nGameType]
    if tbGameFormat.bOpenPartner or tbGameFormat.nPartnerPos then
        return true
    end
    return false
end

function WuLinDaHui:GetGameTypeByTeamId(nFightTeamID)
    local nLeft = nFightTeamID % tbDef.nServerIdxInTeamId
    return math.floor(nLeft / tbDef.nGameTypeInTeamId)
end

function WuLinDaHui:GetPreEndBaoMingTime(nGameType)
    local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameMain)
    if nStartTime == 0 then
        return
    end
    if not self.tbCachePreEndBaoMingTime then
        self.tbCachePreEndBaoMingTime = {};
    end
    local nPreEndTime = self.tbCachePreEndBaoMingTime[nGameType]
    if nPreEndTime then
        return nPreEndTime
    end
    local nEndPreMatchDay = 0
    for i,v in ipairs(WuLinDaHui.tbScheduleDay) do
        if v.bFinal then
            break;
        elseif v.nGameType == nGameType then
            nEndPreMatchDay = i;
        end
    end
    local szEndStartTime = WuLinDaHui.tbDef.tbEndMatchTime[#WuLinDaHui.tbDef.tbEndMatchTime]
    local hour1, min1 = string.match(szEndStartTime, "(%d+):(%d+)");
    local tbTime = os.date("*t", nStartTime + 3600 * 24 * (nEndPreMatchDay - 1))
    local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0}); 
    self.tbCachePreEndBaoMingTime[nGameType] = nSecBegin
    return nSecBegin
end


function WuLinDaHui:IsBaoMingTime(nGameType)
    if Activity:__IsActInProcessByType(self.szActNameBaoMing) then
        return true
    else
        local nPreEndTime = self:GetPreEndBaoMingTime(nGameType)
        if nPreEndTime and GetTime() < nPreEndTime - 100 then
            return true
        end
    end
    
    return false, "不在报名时间范围内"
end
