Require("CommonScript/Player/PlayerEventRegister.lua");
Require("CommonScript/RandomBoss/RandomBossDef.lua");

function RandomBoss:LoadSetting()
    self.tbMainSetting = {};
    self.tbAllNpcGroup = {};
    self.tbAllFirstDmgAward = {};
    self.tbAllPlayerDmgRank = {};
    self.tbAllTMapSetting = {};

    local tbFileData = Lib:LoadTabFile("Setting/RandomBoss/Main.tab", {MapID = 1, ShowAwardID = 1, ShowNpcID = 1, NpcRateCount = 1, NpcGroupRateCount = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        self.tbMainSetting[tbInfo.NpcType] = self.tbMainSetting[tbInfo.NpcType] or {};
        self.tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame] = self.tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame] or {};
        local tbMapInfo = {};
        tbMapInfo.nMapTID             = tbInfo.MapID;
        tbMapInfo.nNpcRateCount      = tbInfo.NpcRateCount;
        tbMapInfo.nNpcGroupRateCount = tbInfo.NpcGroupRateCount;
        tbMapInfo.szActivityName     = tbInfo.ActivityName or "";
        tbMapInfo.nTotalGroupRate    = 0;
        tbMapInfo.tbGroupNpc         = {};
        tbMapInfo.nShowAwardID       = tbInfo.ShowAwardID;
        tbMapInfo.nShowNpcID         = tbInfo.ShowNpcID;

        for nI = 1, 10 do
            if not Lib:IsEmptyStr(tbInfo["NpcGroupID_"..nI]) and not Lib:IsEmptyStr(tbInfo["NpcGroupRate_"..nI]) then
                local nNpcGroupID = tonumber(tbInfo["NpcGroupID_"..nI]);
                local nRate    = tonumber(tbInfo["NpcGroupRate_"..nI]);
                tbMapInfo.nTotalGroupRate = tbMapInfo.nTotalGroupRate + nRate;
                local tbRateNpc = {};
                tbRateNpc.nNpcGroupID = nNpcGroupID;
                tbRateNpc.nRate       = nRate;
                table.insert(tbMapInfo.tbGroupNpc, tbRateNpc);
            end

        end

        self.tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame][tbMapInfo.nMapTID] = self.tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame][tbMapInfo.nMapTID] or {}; 
        table.insert(self.tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame][tbMapInfo.nMapTID], tbMapInfo);
        self.tbAllTMapSetting[tbMapInfo.nMapTID] = tbInfo.NpcType;    
    end

    tbFileData = Lib:LoadTabFile("Setting/RandomBoss/NpcGroup.tab", {GroupID = 1, NpcID = 1, NpcLevel = 1, PosX = 1, 
        PosY = 1, Rate = 1, SoulStoneID = 1, PlayerAwardID = 1, ValueParam = 1, KinItemAwardID = 1, MJSoulStoneID = 1, IsFalse = 1, Mask = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbAllNpcGroup[tbInfo.GroupID] = self.tbAllNpcGroup[tbInfo.GroupID] or {};
        self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate = self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate or 0;
        self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc = self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc or {};
        self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate = self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate + tbInfo.Rate;
        table.insert(self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc, tbInfo);
    end

    tbFileData = Lib:LoadTabFile("Setting/RandomBoss/FirstDmgAward.tab", {});
    for _, tbInfo in pairs(tbFileData) do
        local tbAllAward = {};

        tbAllAward.tbCangBaoTuBoss = Lib:GetAwardFromString(tbInfo.CanBaoTuBossAward);
        self.tbAllFirstDmgAward[tbInfo.TimeFrame] = tbAllAward;
    end

    tbFileData = Lib:LoadTabFile("Setting/RandomBoss/PlayerDmgRankAward.tab", {AwardID = 1, Rank = 1, Rate = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbAllPlayerDmgRank[tbInfo.AwardID] = self.tbAllPlayerDmgRank[tbInfo.AwardID] or {};

        local tbAllAward = {};
        tbAllAward.tbAward = Lib:GetAwardFromString(tbInfo.Award);
        tbAllAward.nRateAward = tbInfo.Rate;
        tbAllAward.tbRateAward = Lib:GetAwardFromString(tbInfo.AwardRate);
        self.tbAllPlayerDmgRank[tbInfo.AwardID][tbInfo.Rank] = tbAllAward;
    end

end
-- 目前只有服务端用到
if MODULE_GAMESERVER then
    RandomBoss:LoadSetting();
end

function RandomBoss:GetTimeFrameNpcGroup(szType)
    local tbAllTimeNpc = self.tbMainSetting[szType];
    assert(tbAllTimeNpc, "GetTimeFrameNpcGroup Not Type" ..szType);

    local szCurTimeFrame = Lib:GetMaxTimeFrame(tbAllTimeNpc);
    return tbAllTimeNpc[szCurTimeFrame], szCurTimeFrame;
end

function RandomBoss:GetGroupNpc(nGroupID)
    return self.tbAllNpcGroup[nGroupID] or {};
end

function RandomBoss:GetFirstDmgAward(szType)
    local szCurTimeFrame = Lib:GetMaxTimeFrame(self.tbAllFirstDmgAward);
    local tbAward =  self.tbAllFirstDmgAward[szCurTimeFrame];
    if not tbAward then
        return;
    end
        
    return tbAward["tb"..szType];
end
