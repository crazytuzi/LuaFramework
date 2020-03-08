local tbLevelUpPopup = Ui:CreateClass("LevelUpPopup");
tbLevelUpPopup.szLevelUp = "shengji"
tbLevelUpPopup.szTask = "task"

function tbLevelUpPopup:OnOpenEnd(szType)
    self.szType = szType
    -- if self.szType == self.szLevelUp and Map:GetMapType(me.nMapTemplateId) == Map.emMap_Fuben then
    --     self.pPanel:SetActive(self.szLevelUp, false)
    --     return
    -- end

    self:Update()
end

function tbLevelUpPopup:Update()
    self:Clear();

    self.pPanel:SetActive(self.szType, true);
    self.nTimer = Timer:Register(Env.GAME_FPS * 2, self.FinishAnimation, self);
end

function tbLevelUpPopup:OnShowSelf(nMapTemplateId)
    if Map:GetMapType(nMapTemplateId) == Map.emMap_Fuben or self.pPanel:IsActive(self.szType) then
        return
    end

    self:Update(self.szType)
end

function tbLevelUpPopup:Clear()
    if self.nTimer then
        Timer:Close(self.nTimer);
        self.nTimer = nil;
    end

    self.pPanel:SetActive(self.szLevelUp, false);
    self.pPanel:SetActive(self.szTask, false);
end

function tbLevelUpPopup:OnClose()
    self:Clear();
end

function tbLevelUpPopup:FinishAnimation()
    if self.nTimer then
        Timer:Close(self.nTimer);
        self.nTimer = nil;
    end
    
    Ui:CloseWindow(self.UI_NAME);
end

function tbLevelUpPopup:OnLeaveMap()
    if self.pPanel:IsActive(self.szType) then
        Ui:CloseWindow(self.UI_NAME);
    end
end

function tbLevelUpPopup:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveMap},
        {UiNotify.emNOTIFY_MAP_LOADED, self.OnShowSelf, self},
    };

    return tbRegEvent;
end