

Activity.tbWarOfIceAndFire = Activity.tbWarOfIceAndFire or {}
local tbWarOfIceAndFire = Activity.tbWarOfIceAndFire;



tbWarOfIceAndFire.nPerDayAddCount = 2; --每天可以参加多少次
tbWarOfIceAndFire.nMaxJoinCount = 14; --最多可以参加多少次
tbWarOfIceAndFire.szTimeUpdateTime = "4:00"; --每天更新的时间
--tbAct.REVIVE_TIME = 2 -- 复活时间

tbWarOfIceAndFire.nSaveGroup = 197;
tbWarOfIceAndFire.nSaveJoin = 1;
tbWarOfIceAndFire.nSaveJoinTime = 2;
tbWarOfIceAndFire.nSaveVersion = 6;

--tbWarOfIceAndFire.nSaveHonor = 5; --保存的灭火大作战荣誉

-- 火娃积分排名对应奖励
tbWarOfIceAndFire.tbFireRankAward =
{
    [1] = {1,  {{"Item", 11200, 1}}},        -- N名以下（包括N名）的奖励
    [2] = {5,  {{"Item", 11201, 1}}},
    [3] = {10, {{"Item", 11202, 1}}},
    [4] = {20, {{"Item", 11203, 1}}},
    [5] = {50, {{"Item", 11204, 1}}},
    [6] = {100, {{"Item", 11205, 1}}},
};

-- 水娃积分排名对应奖励
tbWarOfIceAndFire.tbIceRankAward =
{
    [1] = {1,  {{"Item", 11206, 1}}},        -- N名以下（包括N名）的奖励
    [2] = {5,  {{"Item", 11207, 1}}},
    [3] = {10, {{"Item", 11208, 1}}},
    [4] = {20, {{"Item", 11209, 1}}},
    [5] = {50, {{"Item", 11210, 1}}},
    [6] = {100, {{"Item", 11211, 1}}},
};

tbWarOfIceAndFire.tbPlayerAwardInGame = --局内玩家的奖励
{
	tbFirePlayerLost = --火娃失败局内积分对应奖励
	{
        [1] = {150000, {{"BasicExp", 80},{"Contrib", 2500}}},
        [2] = {100000, {{"BasicExp", 70},{"Contrib", 2000}}},
        [3] = {50000, {{"BasicExp", 60},{"Contrib", 1000}}},
        [4] = {0, {{"BasicExp", 40},{"Contrib", 500}}},
	};

	tbIcePlayerWin = --水娃获胜局内排名对应奖励
	{
	    [1] = {{"BasicExp", 100},{"Contrib", 3000}};
	    [2] = {{"BasicExp", 80},{"Contrib", 2500}};
	    [3] = {{"BasicExp", 70},{"Contrib", 2000}};
        [4] = {{"BasicExp", 60},{"Contrib", 1500}};
	};
    tbIcePlayerLost = --水娃失败局内排名对应奖励
    {
        [1] = {{"BasicExp", 80},{"Contrib", 2000}};
        [2] = {{"BasicExp", 70},{"Contrib", 1500}};
        [3] = {{"BasicExp", 60},{"Contrib", 1000}};
        [4] = {{"BasicExp", 40},{"Contrib", 500}};
    };
    tbFirePlayerWin = {{"BasicExp", 100},{"Contrib", 3000}}; --火娃获胜奖励
    szFireMailContent = "大侠在本场中使用火娃获得%d积分进入全服火娃排行榜。";
    szIceMailContent = "大侠在本场中使用水娃中排名第%d，获得%d积分进入全服水娃排行榜。";
    szMsg = "灭火大作战奖励";
};

-- 局内积分获得排行榜积分
tbWarOfIceAndFire.tbGameValueToRankBoardValue =
{
    nFirePlayerWin = 100; --火娃获胜获得排行榜积分
    tbFirePlayerLost = --火娃失败局内积分对应排行榜积分
    {
        [1] = {150000, 80};
        [2] = {100000, 60};
        [3] = {50000, 40};
        [4] = {0, 15};
    };

    tbIcePlayerWin = --水娃获胜局内排名对应排行榜积分
    {
        [1] = 100;
        [2] = 80;
        [3] = 60;
        [4] = 50;
    };
    tbIcePlayerLost = --水娃失败局内排名对应排行榜积分
    {
        [1] = 60;
        [2] = 40;
        [3] = 20;
        [4] = 15;
    };
}

tbWarOfIceAndFire.nLimitLevel = 20; --最小等级
tbWarOfIceAndFire.nGameMemberCount = 5 --每场比赛队伍参加人数
tbWarOfIceAndFire.nSelectWaitTime = 10; --选水火娃等待时间

-- 所有使用一次隐藏的技能
tbWarOfIceAndFire.tbUseHideSkill =
{
    [3361] = true;
    [3362] = true;
    [3364] = true;
    [3365] = true;
}

--隐藏分排名段位
tbWarOfIceAndFire.tbHiddenRank =
{
    [1] = 60;
    [2] = 100;
    [3] = 150;
}

tbWarOfIceAndFire.nPrepareMapTID = 272; --准备场地图的ID
tbWarOfIceAndFire.nPlayMapTID = 271; --PK地图的ID

tbWarOfIceAndFire.tbPreMapState =  --准备场的的状态
{
    [1] = { nNextTime = 300, szCall = "Freedom", szRMsg = "等待开始"};
    [2] = { nNextTime = 270, szCall = "StartPlay", szRMsg = "等待开始"};
    [3] = { nNextTime = 270, szCall = "StartPlay", szRMsg = "等待开始"};
    [4] = { nNextTime = 20, szCall = "StartPlay", szRMsg = "活动结束请离开"};
    [5] = { nNextTime = 10, szCall = "GameEnd", szRMsg = "离开场地"};
};
tbWarOfIceAndFire.szMatchEmpyMsg = "本轮轮空，没有匹配到对手"; --轮空描述
tbWarOfIceAndFire.szPanelContent = [[灭火大作战
·单人报名后，自由选择变身为火娃或者水娃，进行1V4的灭火大作战。[FFFE0D]（每天比赛时间为13:30、16:00和20:00）[-]
·比赛分火娃水娃，火娃通过淘汰所有水娃或者存活到最后获胜，水娃则必须在活动时间内淘汰火娃方可获胜。
·水娃采集昆仑玄水可以获得强力控制技能，集齐所有机甲部件可召唤玄武机甲，开启玄武机甲可对火娃造成巨额伤害。
·新增信号按钮，可以快速发送坐标提示队友火娃当前位置。
]];

function tbWarOfIceAndFire:GetJoinCount(pPlayer)
    if MODULE_GAMESERVER then
        local nStartTime = Activity:__GetActTimeInfo("WarOfIceAndFire")
        if nStartTime == 0 then
            return 0
        end
        local nVersion = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveVersion);
        if nVersion ~= nStartTime and self.bHaveJoined then
            pPlayer.SetUserValue(self.nSaveGroup, self.nSaveJoinTime, 0);
            pPlayer.SetUserValue(self.nSaveGroup, self.nSaveJoin, 0);
            pPlayer.SetUserValue(self.nSaveGroup, self.nSaveVersion, nStartTime);
            Log("WarOfIceAndFire GetJoinCount nSaveVersion", pPlayer.dwID, nStartTime);
        end
    end

    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveJoinTime);
    local nParseTodayTime = Lib:ParseTodayTime(self.szTimeUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = 0;
    if nLastTime == 0 then
        nUpdateLastDay = nUpdateDay - 1;
    else
        nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));
    end

    local nJoin   = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveJoin);
    local nAddDay = math.abs(nUpdateDay - nUpdateLastDay);
    if nAddDay == 0 then
        return nJoin;
    end

    if nJoin < self.nMaxJoinCount then
        local nAddResiduTime = nAddDay * self.nPerDayAddCount;
        nJoin = nJoin + nAddResiduTime;
        nJoin = math.min(nJoin, self.nMaxJoinCount);
    end

    if MODULE_GAMESERVER then
        pPlayer.SetUserValue(self.nSaveGroup, self.nSaveJoinTime, nTime);
        pPlayer.SetUserValue(self.nSaveGroup, self.nSaveJoin, nJoin);
    end

    return nJoin;
end