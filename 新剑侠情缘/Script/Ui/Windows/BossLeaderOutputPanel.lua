
local tbUi = Ui:CreateClass("BossLeaderOutputPanel");

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen(szType, szTitle, szTips, tbRankInfo)
    self.szType = szType;
    self.szTitle = szTitle;
    self.szTips = szTips;
    
    if szTitle then
        self.pPanel:Label_SetText("Title", szTitle);
        self.pPanel:Label_SetText("OutputTarget", string.format("对%s的伤害输出排名：", szTitle));
    else
        self.pPanel:Label_SetText("OutputTarget", "");
    end

    if szTips then
        self.pPanel:Label_SetText("Tip", szTips);
    else
        self.pPanel:Label_SetText("Tip", "")
    end

    if tbRankInfo then
        self:Update(tbRankInfo);
    else
        self:RequestData();
    end

    if self.szType == "BossLeader" then
        self:UpdateLeaderInfo();
    end
end

function tbUi:OnScreenClick(szClickUi)
    if szClickUi ~= self.UI_NAME then
        Ui:CloseWindow(self.UI_NAME);
    end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
end

function tbUi:RequestData()
    self.nLastRequestTime = self.nLastRequestTime or 0;
    local nCurTime = GetTime();

    if nCurTime - self.nLastRequestTime > 5 then
        if self.szType == "ImperialTomb" then
            RemoteServer.ImperialTombEmperorDmgReq()
        elseif self.szType == "ImperialTombBoss" then
            RemoteServer.ImperialTombBossDmgReq()
        elseif self.szType == "BossLeader" then
            RemoteServer.RequestBossLeaderBossDmgRank();
        elseif self.szType == "InDifferBattle" then
            RemoteServer.InDifferBattleRequestInst("UpdateNpcDmgInfo");
        elseif self.szType == "DaMoCave" then
            RemoteServer.DaMoCaveC2ZCall("RequestUpdateDmgInfo")
        end

        self.nLastRequestTime = nCurTime;
    end
end

function tbUi:OnSyncData(szType)
    if szType ~= "BossLeader_"..me.nMapTemplateId then
        return;
    end

    self:UpdateLeaderInfo();
end

function tbUi:UpdateLeaderInfo()
    local nMapTemplateId = me.nMapTemplateId;
    local tbNpcGroup = BossLeader:GetTimeFrameNpcGroup("Boss");
    local tbCrossAllGroup = BossLeader:GetCrossTimeFrameNpcGroup("Boss");
    if not tbNpcGroup[nMapTemplateId] and tbCrossAllGroup then
        tbNpcGroup = tbCrossAllGroup;
    end

    if not tbNpcGroup[nMapTemplateId] then
        return;
    end

    local nNpcGroupID = tbNpcGroup[nMapTemplateId][1].tbGroupNpc[1].nNpcGroupID;
    local tbGropNpc = BossLeader:GetGroupNpc(nNpcGroupID);
    local tbNpcInfo = tbGropNpc.tbRateNpc[1];
    local tbSyncData, nNpcTID = Player:GetServerSyncData("BossLeader_"..nMapTemplateId);
    if not nNpcTID or nNpcTID <= 0 then
        nNpcTID = tbNpcInfo.NpcID;
    end
    tbSyncData = tbSyncData or {};
    tbSyncData.szTargetName = KNpc.GetNameByTemplateId(nNpcTID);

    self:Update(tbSyncData)
end    


function tbUi:Update(tbRankInfo)
    self.szTitle = tbRankInfo.szTargetName or self.szTitle
    if not Lib:IsEmptyStr(self.szTitle) then
        self.pPanel:Label_SetText("Title", self.szTitle);
        self.pPanel:Label_SetText("OutputTarget", string.format("对%s的伤害输出排名：", self.szTitle));
    else
        self.pPanel:Label_SetText("Title", "");
        self.pPanel:Label_SetText("OutputTarget", "");
    end

    local nMaxPercent = 100;
    if tbRankInfo[1] then
        nMaxPercent = tbRankInfo[1][2]
    end

    local fnSetItem = function (itemObj, index)
        local tbInfo = tbRankInfo[index]

        itemObj.pPanel:Label_SetText("OutputDamage", string.format("%s%%",tostring(math.floor(tbInfo[2]))));
        itemObj.pPanel:Label_SetText("FamilyName", tbInfo[1]);
        itemObj.pPanel:Sprite_SetFillPercent("OutputBar", tbInfo[2] / nMaxPercent);
    end

    self.ScrollView:Update(tbRankInfo, fnSetItem);

    local szKinName, szPlayerName
    for _, tbInfo in ipairs(tbRankInfo) do
        if tbInfo[3] and tbInfo[3] ~= "" then
            szKinName = tbInfo[1]
            szPlayerName = tbInfo[3]
        end
    end
    if szKinName and szPlayerName then
        self.pPanel:Label_SetText("FirstStrike", string.format("第一击：%s·%s", szKinName, szPlayerName))
    else
        self.pPanel:Label_SetText("FirstStrike", "")
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_SYNC_DATA,           self.OnSyncData},
        {UiNotify.emNOTIFY_DMG_RANK_UPDATE, self.Update},
    };

    return tbRegEvent;
end