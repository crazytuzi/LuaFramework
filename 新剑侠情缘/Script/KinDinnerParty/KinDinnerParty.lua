function KinDinnerParty:LoadCommerceSetting()
    self.tbPosInfo         = {};
    self.tbCommerceSetting = LoadTabFile("Setting/Npc/NpcKinDinnerParty.tab", "dsss", "TemplateID", {"TemplateID", "Name", "Icon", "ClassName"});

    for _, nMapTemplateId in pairs(self.Def.tbWildMap) do
        self:LoadMapCommerceNpc(nMapTemplateId);
    end
end

function KinDinnerParty:LoadMapCommerceNpc(nMapTemplateId)
    local szPath = Map:GetMapInfoPath(nMapTemplateId);
    local tbNpc  = LoadTabFile(szPath, "ddd", nil, {"NpcTemplateId", "XPos", "YPos"});
    for _, tbNpcInfo in pairs(tbNpc) do
        local nTemplateId = tbNpcInfo.NpcTemplateId;
        if self.tbCommerceSetting[nTemplateId] then
            self.tbPosInfo[nTemplateId] = self.tbPosInfo[nTemplateId] or {};
            table.insert(self.tbPosInfo[nTemplateId], {nMapId = nMapTemplateId, nPosX = tbNpcInfo.XPos, nPosY = tbNpcInfo.YPos});
        end
    end
end
KinDinnerParty:LoadCommerceSetting();

function KinDinnerParty:IsTaskGather(nGatherId)
    local tbSetting = self.tbCommerceSetting[nGatherId]
    return tbSetting and tbSetting.ClassName == "KinDPTaskGather"
end

function KinDinnerParty:OnSyncTask(tbData, tbHelp)
    self.tbTask = tbData
    self.tbHelp = tbHelp
    Task:UpdateNpcTaskState()
    Task:OnTaskUpdate(Task.tbDailyTaskSettings[Task.emDAILY_KIN_DP].nTaskId)
    Task:OnKinDinnerPartyTaskUpdate()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KDP_DATA)
end

function KinDinnerParty:GetGatherName(nGatherId)
    local tbGather = self.tbCommerceSetting[nGatherId];
    if tbGather then
        return tbGather.Name;
    end
end

function KinDinnerParty:GetGatherIcon(nGatherId)
    local tbGather = self.tbCommerceSetting[nGatherId];
    if tbGather then
        return tbGather.Icon;
    end
end

function KinDinnerParty:GetGatherPosition(nGatherId)
    if not self.tbPosInfo or not self.tbPosInfo[nGatherId] then
        return;
    end

    local tbPos = self.tbPosInfo[nGatherId];
    if not tbPos or not next(tbPos) then
        return;
    end

    local tbCurMapPos = {};
    for _, tbInfo in pairs(tbPos) do
        if tbInfo.nMapId == me.nMapId then
            table.insert(tbCurMapPos, tbInfo);
        end
    end

    local bCurMap = #tbCurMapPos > 0;
    local nRan = bCurMap and MathRandom(1, #tbCurMapPos) or MathRandom(1, #tbPos);
    local tbPosInfo = bCurMap and tbCurMapPos[nRan] or tbPos[nRan];
    return {tbPosInfo.nMapId, tbPosInfo.nPosX, tbPosInfo.nPosY};
end

function KinDinnerParty:OnRespondHelp(szInfo)
    Kin:UpdateMemberList();
    me.CenterMsg(szInfo);
    
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KDP_HELP);
end

function KinDinnerParty:IsKinMemberHelping(tbMemberData)
    for _, bHelped in pairs(tbMemberData.tbKinDPTaskHelp or {}) do
        if not bHelped then
            return true
        end
    end
    return false
end