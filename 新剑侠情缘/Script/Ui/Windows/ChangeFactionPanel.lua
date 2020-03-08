local tbUi = Ui:CreateClass("ChangeFactionPanel");
tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end
for i = 1, 5 do
    tbUi.tbOnClick["Btn" .. i] = function (self)
        self:ChangeSeries(i)
    end
end
tbUi.tbOnClick.BtnMale = function (self)
    self:ChangeSex(Player.SEX_MALE)
end
tbUi.tbOnClick.BtnFemale = function (self)
    self:ChangeSex(Player.SEX_FEMALE)
end
tbUi.tbOnClick.BtnSure = function (self)
    self:Sure()
end

function tbUi:ChangeSeries(nSeries)
    self.nSeries = nSeries
    self:UpdateFactionList()
end

function tbUi:ChangeSex(nSex)
    if not self.tbFactionInfo[self.nSelFaction][nSex] then
        return
    end
    self.nSelSex = nSex
    self:UpdateFaction()
end

function tbUi:Sure()
    --星移斗转活动取消二次确认。
    if me.nMapTemplateId ~= ChangeFaction.tbDef.nMapTID then
        RemoteServer.DoChangeFaction(self.nSelFaction, self.nSelSex); 
        Ui:CloseWindow("ChangeFactionPanel") 
        return;
    end
    local szMsg = string.format("您想转[FFFE0D]%s[-]，确认吗？", Faction:GetName(self.nSelFaction));
    me.MsgBox(szMsg, {
        {"确认", function ()
            RemoteServer.DoChangeFaction(self.nSelFaction, self.nSelSex); 
            Ui:CloseWindow("ChangeFactionPanel") 
        end},
        {"取消"}});    
end

function tbUi:OnOpen()
    self.tbSeriesFaction = {};
    self.tbFactionInfo   = {};
    for nFaction, tb in pairs(Faction.tbFactionInfo) do
        local nSeries
        for _, nSex in ipairs({Player.SEX_MALE, Player.SEX_FEMALE}) do
            local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex);
            if tbPlayerInfo then
                nSeries = nSeries or tbPlayerInfo.nSeries
                self.tbFactionInfo[nFaction] = self.tbFactionInfo[nFaction] or {}
                self.tbFactionInfo[nFaction][nSex] = tb["szBackground" .. nSex]
            end
        end
        if nSeries then
            self.tbSeriesFaction[nSeries] = self.tbSeriesFaction[nSeries] or {};
            table.insert(self.tbSeriesFaction[nSeries], nFaction)
        end
    end
    self.nSelFaction   = self.nSelFaction or me.nFaction
    self.nSelSex       = self.nSelSex or me.nSex
    if not self.nSeries then
        local tbPlayerInfo = KPlayer.GetPlayerInitInfo(self.nSelFaction, self.nSelSex)
        self.nSeries       = tbPlayerInfo.nSeries
    end
    self.pPanel:Toggle_SetChecked("Btn1", false);
    self:Update()
end

function tbUi:Update()
    self:UpdateFactionList()
    self:UpdateFaction()
end

function tbUi:UpdateFactionList()
    local tbInfo = self.tbSeriesFaction[self.nSeries]
    local fnSelectFaction = function (BtnObj)
        if BtnObj.nFaction then
            self.nSelFaction = BtnObj.nFaction
            if not self.tbFactionInfo[BtnObj.nFaction][self.nSelSex] then
                self.nSelSex = self.nSelSex == Player.SEX_MALE and Player.SEX_FEMALE or Player.SEX_MALE
            end
            self:UpdateFaction()
        end    
    end
    local fnSetItem = function(tbItemObj, nIndex)
        for i = 1, 3 do
            local nFaction = tbInfo[(nIndex - 1) * 3 + i]
            tbItemObj.pPanel:SetActive("Faction" .. i, nFaction or false)
            if nFaction then
                tbItemObj["Faction" .. i].pPanel:Sprite_SetSprite("Icon" .. i, Faction:GetBGSelectIcon(nFaction))
                tbItemObj["Faction" .. i].pPanel.OnTouchEvent = fnSelectFaction;
                tbItemObj["Faction" .. i].pPanel:Toggle_SetChecked("Main", nFaction == self.nSelFaction)
                tbItemObj["Faction" .. i].nFaction = nFaction
            end
        end
    end
    self.pPanel:Toggle_SetChecked("Btn"..self.nSeries, true);
    local nUpdateCount = #tbInfo
    nUpdateCount = math.ceil(nUpdateCount/3)
    self.ScrollView:Update(nUpdateCount, fnSetItem)
end

function tbUi:UpdateFaction()
    local tbSelFactionInfo = self.tbFactionInfo[self.nSelFaction]
    local szBg = string.format("UI/Textures/FactionSelect/%s", tbSelFactionInfo[self.nSelSex])
    self.pPanel:Texture_SetTexture("Texture", szBg)
    self.pPanel:Sprite_SetSprite("FactionInfo", Faction:GetFactionSchoolIcon(self.nSelFaction))
    local bAllSex = tbSelFactionInfo[Player.SEX_MALE] and tbSelFactionInfo[Player.SEX_FEMALE]
    self.pPanel:SetActive("BtnMale", bAllSex)
    self.pPanel:SetActive("BtnFemale", bAllSex)
    if bAllSex then
        self.pPanel:Button_SetCheck("BtnMale", self.nSelSex == Player.SEX_MALE)
        self.pPanel:Button_SetCheck("BtnFemale", self.nSelSex == Player.SEX_FEMALE)
        self.pPanel:Toggle_SetChecked("BtnMale", self.nSelSex == Player.SEX_MALE);
        self.pPanel:Toggle_SetChecked("BtnFemale", self.nSelSex == Player.SEX_FEMALE);
    end
end

local tbChangeSubItem = Ui:CreateClass("ChangeFactionItem");
function tbChangeSubItem:UpdateInfo(tbFactionInfo)

end    