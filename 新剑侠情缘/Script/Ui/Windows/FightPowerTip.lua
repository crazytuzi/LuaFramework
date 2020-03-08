local FightPowerTip = Ui:CreateClass("FightPowerTip");

--FightPowerTip.STATE1_SEC = 0.01;--显示旧值得时长
FightPowerTip.STATE2_SEC = 1.5;--动画时长
FightPowerTip.STATE3_SEC = 0.5;--结束动画后，停留显示新值得时长

function FightPowerTip:RegisterEvent()
    return
    {
        {UiNotify.emNOTIFY_MAP_LOADED, self.ShowMe, self},
    };
end

function FightPowerTip:OnOpenEnd(nTar, nOrg)
    if self.nTimer then
        Timer:Close(self.nTimer);
    end

    self.nOrg = nOrg;
    self.nTar = nTar;
    if Map:GetMapType(me.nMapTemplateId) == Map.emMap_Fuben and not House:GetHouseSetting(me.nMapTemplateId) then
        self.pPanel:SetActive("Main", false)
        return
    end

    self:PlayAnimation()
    --self.nTimer = Timer:Register(Env.GAME_FPS * self.STATE1_SEC, self.Animation1, self);
end

function FightPowerTip:PlayAnimation()
    self.pPanel:SetActive("Main", true)

    self.nTarLen = string.len(tostring(nTar));
    self:SetNumber();
    self:Animation1();
end

function FightPowerTip:Animation1()
    local nLeap = self.nTar - self.nOrg;
    local nAdd = math.ceil(nLeap / (Env.GAME_FPS * self.STATE2_SEC));
    --Timer:Close(self.nTimer);
    self.nTimer = Timer:Register(1, self.Animation2, self, nAdd);
    return false;
end

function FightPowerTip:Animation2(nAdd)
    self.nOrg = self.nOrg + nAdd;
    self.nOrg = self.nOrg > self.nTar and self.nTar or self.nOrg;
    self:SetNumber();
    
    if self.nOrg >= self.nTar then
        Timer:Close(self.nTimer);
        self.nTimer = Timer:Register(Env.GAME_FPS * self.STATE3_SEC, self.Animation3, self);
        return false;
    else
        return true;
    end
end

function FightPowerTip:Animation3()
    Timer:Close(self.nTimer);
    self.nTimer = nil;
    Ui:CloseWindow(self.UI_NAME);
end

function FightPowerTip:SetNumber()
    local szNum = tostring(self.nOrg);
    local nLen = string.len(szNum);
    local nKeep = self.nTarLen - nLen;

    local nLabelIdx = 1;
    for i = 1, nKeep do
        self.pPanel:SetActive("Num" .. nLabelIdx, false);
        nLabelIdx = nLabelIdx + 1;
    end

    for i = 1, nLen do 
        local szChar = string.sub(szNum, i, i);
        local szLabel = string.format("Num%d", nLabelIdx);
        self.pPanel:SetActive(szLabel, true);
        self.pPanel:Label_SetText(szLabel, szChar);
        nLabelIdx = nLabelIdx + 1;
    end

    for i = nLabelIdx, 8 do
        self.pPanel:SetActive("Num"..i, false);
    end
end

function FightPowerTip:ShowMe(nMapTemplateId)
    if Map:GetMapType(nMapTemplateId) == Map.emMap_Fuben or self.pPanel:IsActive("Main") then
        return
    end

    self:PlayAnimation()
end