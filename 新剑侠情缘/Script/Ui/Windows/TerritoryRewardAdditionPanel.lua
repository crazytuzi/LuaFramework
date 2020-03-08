local tbUi = Ui:CreateClass("TerritoryRewardAdditionPanel");

function tbUi:OnOpen()
    if not DomainBattle.nMyOwnerMapId then
        return 0;
    end
    self:RequestDomainAttackInfo()
    self:Update()
end

function tbUi:RequestDomainAttackInfo()
    local nNow = GetTime()
    if self.nLastRequestTime  and self.nLastRequestTime + 3 > nNow then
        return
    end
    self.nLastRequestTime = nNow
    RemoteServer.DomainBattleRequestAttackInfo()
end

function tbUi:Update()
    local tbAttakAwardInfo = DomainBattle:GetAttakAwardInfo()
    if not tbAttakAwardInfo then
        self:ClearUi();
        return
    end
    local tbFlagAddScore = DomainBattle.define.tbFlagAddScore
    local tbGateState = tbAttakAwardInfo.tbGateState
    local tbMapPosSettingAttack = DomainBattle.tbMapPosSetting[tbAttakAwardInfo.nAttackMap]
    local nTotalScore = DomainBattle:GetBaseMapScore(DomainBattle.nMyOwnerMapId)

    local nMapLevelAttack = DomainBattle:GetMapLevel(tbAttakAwardInfo.nAttackMap)
    local nGateFullScore = DomainBattle.define.tbGateScore[nMapLevelAttack]
    local nTotalAddPercent = 0
    for nDoorIndex=1,3 do
        local nGateHpPercent = tbGateState[nDoorIndex]
        if nGateHpPercent then
            self.pPanel:SetActive("Bar" .. nDoorIndex, true)
            local tbDoorInfo = tbMapPosSettingAttack.Doors[nDoorIndex]
            local _,_,_, szObstacle, szDoorNpc, szTrapName, szGateName = unpack(tbDoorInfo)
            self.pPanel:Label_SetText("Name" .. nDoorIndex, szGateName)
            self.pPanel:Sprite_SetFillPercent("Bar" .. nDoorIndex, nGateHpPercent);
            local nAddScore = (1 - nGateHpPercent) * nGateFullScore
            local nAddPecent = math.floor(nAddScore / nTotalScore * 100)
            self.pPanel:Label_SetText("Addition" .. nDoorIndex, string.format("+%d%%", nAddPecent))
            nTotalAddPercent = nTotalAddPercent + nAddPecent
        else
            self.pPanel:SetActive("Bar" .. nDoorIndex, false)
        end
    end

    local tbFlagState = tbAttakAwardInfo.tbFlagState
    for i=1,3 do
        local nOwnerKin = tbFlagState[i] and tbFlagState[i][1]
        if nOwnerKin then
            self.pPanel:SetActive("DragonColumnState" .. i, true)
            local nNpcTemplate, nFlagLevel = unpack(tbMapPosSettingAttack.tbFlogNpcPos[i]) 
            local szNpcName = KNpc.GetNameByTemplateId(nNpcTemplate)
            if nOwnerKin == me.dwKinId then
                self.pPanel:Label_SetText("DragonColumnState" .. i,string.format("[9EFFE9]%s：已占据[-]",szNpcName))
                
                local nAddScore = tbFlagAddScore[nMapLevelAttack][nFlagLevel]
                local nAddPecent = math.floor(nAddScore / nTotalScore * 100)
                self.pPanel:Label_SetText("DragonColumnAddition" .. i, string.format("+%d%%", nAddPecent))
                nTotalAddPercent = nTotalAddPercent + nAddPecent
            else
                self.pPanel:Label_SetText("DragonColumnState" .. i,string.format("%s：未占据",szNpcName))
                self.pPanel:Label_SetText("DragonColumnAddition" .. i, "")
            end
        else
            self.pPanel:SetActive("DragonColumnState" .. i, false)
        end
    end

    local tbWinInfo = DomainBattle:GetWinKin(tbFlagState, tbAttakAwardInfo.nAttackMap) 
    if tbWinInfo and tbWinInfo[1] == me.dwKinId then
        self.pPanel:Label_SetText("RewardAdditionState", "已达上限")
        self.pPanel:Label_SetText("OccupyState", "领先！")
    else
        self.pPanel:Label_SetText("OccupyState", "")
        self.pPanel:Label_SetText("RewardAdditionState", string.format("+%d%%", nTotalAddPercent))
    end
end

function tbUi:ClearUi()
    self.pPanel:Label_SetText("RewardAdditionState", "")
    self.pPanel:Label_SetText("Addition1", "")
    self.pPanel:Label_SetText("Addition2", "")
    self.pPanel:Label_SetText("Addition3", "")
    self.pPanel:Label_SetText("OccupyState", "")
    self.pPanel:Label_SetText("DragonColumnAddition1", "")
    self.pPanel:Label_SetText("DragonColumnAddition2", "")
    self.pPanel:Label_SetText("DragonColumnAddition3", "")
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_ONSYNC_DOMAIN_REPORT,   self.Update, self },
    };

    return tbRegEvent;
end