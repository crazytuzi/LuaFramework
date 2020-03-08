

Activity.tbDaXueZhang = Activity.tbDaXueZhang or {}
local tbDaXueZhang = Activity.tbDaXueZhang;
tbDaXueZhang.tbDef = tbDaXueZhang.tbDef or {};

local tbDef = tbDaXueZhang.tbDef;
tbDef.nSaveGroup = 122;
tbDef.nSaveJoin = 1;
tbDef.nSaveJoinTime = 2;
tbDef.nSaveVersion = 6;

tbDef.nSaveHonor = 5; --保存的雪站荣誉

tbDef.nMaxTeamVS = 2; --队伍数
tbDef.nUpdateDmgTime = 2; --更新伤害的时间
tbDef.tbMatchingCount = --匹配规则
{
    [3] = {1};
    [2] = {2, 1};
    [1] = {1};
}

tbDef.nWinType = 1; --胜利的奖励类型
tbDef.nFailType = 2; --失败的奖励类型
tbDef.nSinleRankType = 3; -- 单人模式排名奖励

--------------策划填写 --------------------------------------------
--tbDef.nActivityVersion = 1; --活动的版本号 注意重新开启要加版本号(改用活动开始时间作为key)
tbDef.nLimitLevel = 20; --最小等级
tbDef.nTeamCount  = 4; --一个队伍的人数

tbDef.nPrepareMapTID = 1700; --准备场地图的ID

tbDef.tbHonorInfo = --兑换荣誉 优先级从上到下
{
    {nNeed = 2000, nItemID = 3538};
    {nNeed = 1000, nItemID = 3537};
};

tbDef.tbPreMapState =  --准备场的的状态
{
    [1] = { nNextTime = 300, szCall = "Freedom", szRMsg = "等待打雪仗开始"};
    [2] = { nNextTime = 270, szCall = "StartPlay", szRMsg = "等待打雪仗开始"};
    [3] = { nNextTime = 270, szCall = "StartPlay", szRMsg = "等待打雪仗开始"};
    [4] = { nNextTime = 10, szCall = "StartPlay", szRMsg = "活动结束请离开"};
    [5] = { nNextTime = 1, szCall = "CloseEnter", szRMsg = "活动结束请离开"};
    [6] = { nNextTime = 10, szCall = "GameEnd", szRMsg = "离开场地"};
};

tbDef.nPlayMapTID = 1701; --PK地图的ID

tbDef.tbPlayerAward = --玩家的奖励
{
    tbWin = --胜利的奖励
    {
        tbRankAward =
        {
            [1] =
            {
                {"BasicExp", 90};
                {"DXZHonor", 3000};
            };
            [2] =
            {
                {"BasicExp", 75};
                {"DXZHonor", 2500};
            };
            [3] =
            {
                {"BasicExp", 60};
                {"DXZHonor", 2000};
            };
            [4] =
            {
                {"BasicExp", 45};
                {"DXZHonor", 1500};
            };
        };

        szMailContent = "恭喜阁下在刚刚结束的打雪仗比赛中，获得了一场胜利，附件为奖励请查收！";
        szMsg = "您的队伍赢得了本次比赛！";
    };

    tbFail = --失败的奖励
    {
        tbRankAward =
        {
            [1] =
            {
                {"BasicExp", 75};
                {"DXZHonor", 2500};
            };
            [2] =
            {
                {"BasicExp", 60};
                {"DXZHonor", 2000};
            };
            [3] =
            {
                {"BasicExp", 45};
                {"DXZHonor", 1500};
            };
            [4] =
            {
                {"BasicExp", 30};
                {"DXZHonor", 1000};
            };
        };
        szMailContent = "阁下在刚刚结束的打雪仗比赛中，遗憾败北，附件为奖励请查收，以资鼓励！";
        szMsg = "您失利了，再接再厉！";
    };
    tbSinlePlayerAward =                    -- 单人模式排名奖励
    {
        tbRankAward =
        {
            [1] =
            {
                {"BasicExp", 90};
                {"DXZHonor", 3000};
            };
            [2] =
            {
                {"BasicExp", 75};
                {"DXZHonor", 2500};
            };
            [3] =
            {
                {"BasicExp", 60};
                {"DXZHonor", 2000};
            };
            [4] =
            {
                {"BasicExp", 50};
                {"DXZHonor", 1500};
            };
            [5] =
            {
                {"BasicExp", 45};
                {"DXZHonor", 1200};
            };
            [6] =
            {
                {"BasicExp", 30};
                {"DXZHonor", 1000};
            };
        };
        szMailContent = "恭喜大侠获得本场第%d名，特奖励%d点雪地荣誉以兑换奖励宝箱。大侠还可获得%d积分进入全服排行榜，祝武运昌隆，雪地称王。";
        szMsg = "获得排名奖励";
    };
};

-- 排名获得积分
tbDef.tbRankJiFen = 
{
    [1] = 100;
    [2] = 80;
    [3] = 60;
    [4] = 40;
    [5] = 30;
    [6] = 15;        
}

-- 积分排名对应奖励
tbDef.tbRankJiFenAward = 
{
    [1] = {1,  {{"Item", 10174, 1}}},        -- N名以下（包括N名）的奖励
    [2] = {5,  {{"Item", 10175, 1}}},
    [3] = {10, {{"Item", 10176, 1}}},
    [4] = {20, {{"Item", 10177, 1}}},
    [5] = {50, {{"Item", 10178, 1}}},
    [6] = {100, {{"Item", 10180, 1}}},
    [7] = {200, {{"Item", 10179, 1}}},
    [8] = {201, {{"Item", 10181, 1}}},
}
tbDef.nDogfallJiFen = 10; --平局的额外的积分
tbDef.szMatchEmpyMsg = "本轮轮空，没有匹配到对手"; --轮空描述
tbDef.szPanelContent = [[打雪仗比赛
·单人报名后，变身为打雪仗的小孩，进入特殊地图，进行六人间的雪球大乱斗。（每天比赛时间为13:30、16:00和20:00）
·比赛分三轮，击倒对手获得积分，结束时积分多的人获胜。
·战场上会出现随机的雪堆和雪人，采集后能获得强力技能。
·棕色雪人—无敌技能，蓝色雪人—群攻技能，红色雪人—连击技能。
·另外，还要注意躲避年兽放出的带有控制效果的强力技能。
]];


tbDef.nPerDayAddCount = 1; --每天可以参加多少次
tbDef.nMaxJoinCount = 3; --最多可以参加多少次
tbDef.szTimeUpdateTime = "4:00"; --每天更新的时间
tbDef.bSingleJoin = true        -- 是否单人参加模式
tbDef.nSingleJoin = 6           -- 单人参加模式人数
tbDef.REVIVE_TIME = 2           -- 复活时间

-- 所有使用一次隐藏的技能
tbDef.tbUseHideSkill = 
{
    [3591] = true;
    [3367] = true;
    [3593] = true;
    [3371] = true;
}

tbDef.nSnowBallBuffId = 3594           -- 扔雪球buffid
tbDef.nSnowBallBuffTime = 200           -- 复活重给扔雪球buffid时间
tbDef.nBuffSkillId = 3398               -- 三技能buff技能

function tbDaXueZhang:GetDXZJoinCount(pPlayer)
    if MODULE_GAMESERVER then
        local nStartTime = Activity:__GetActTimeInfo("DaXueZhang")
        if nStartTime == 0 then
            return 0
        end
        local nVersion = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveVersion);
        --if nVersion ~= tbDef.nActivityVersion and tbDaXueZhang.bHaveDXZ then
        if nVersion ~= nStartTime and tbDaXueZhang.bHaveDXZ then
            pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime, 0);
            pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin, 0);
            pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveVersion, nStartTime);
            Log("DaXueZhang GetDXZJoinCount nSaveVersion", pPlayer.dwID, nStartTime);
        end
    end

    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime);
    local nParseTodayTime = Lib:ParseTodayTime(tbDef.szTimeUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = 0;
    if nLastTime == 0 then
        nUpdateLastDay = nUpdateDay - 1;
    else
        nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));
    end

    local nJoin   = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin);
    local nAddDay = math.abs(nUpdateDay - nUpdateLastDay);
    if nAddDay == 0 then
        return nJoin;
    end

    if nJoin < tbDef.nMaxJoinCount then
        local nAddResiduTime = nAddDay * tbDef.nPerDayAddCount;
        nJoin = nJoin + nAddResiduTime;
        nJoin = math.min(nJoin, tbDef.nMaxJoinCount);
    end

    if MODULE_GAMESERVER then
        pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime, nTime);
        pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin, nJoin);
    end

    return nJoin;
end

function tbDaXueZhang:GetSingRankHonorByRank(nRank)
    local tbRankAward = tbDef.tbPlayerAward.tbSinlePlayerAward.tbRankAward[nRank] or {}
    for _, tbAward in pairs(tbRankAward) do
        if tbAward[1] == "DXZHonor" then
            return tbAward[2]
        end
    end
    return 0
end

function tbDaXueZhang:OnNpcTimeChange(nAddGatherNpcTime, nNSNpcTime)
    Ui:OpenWindow("QYHLeftInfo", "DaXueZhangFight", {nAddGatherNpcTime, nNSNpcTime})
end

function tbDaXueZhang:OnSynSingleShowRankData(tbData)
    UiNotify.OnNotify(UiNotify.emNOTIFY_DAXUEZHANG_SINGLE_RANK_DATA, tbData)
end