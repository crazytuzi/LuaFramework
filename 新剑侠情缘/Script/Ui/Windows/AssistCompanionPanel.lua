local tbUi = Ui:CreateClass("AssistCompanionPanel");
tbUi.tbOnClick = {};

function tbUi:OnClose()
  
end

function tbUi:OnScreenClick()
    Ui:CloseWindow("AssistCompanionPanel");
end

function tbUi:OnOpen()
    self:UpdateAllPartnerList();
end

function tbUi:UpdateAllPartnerList()
    self.tbPosInfo = tbPosInfo or me.GetPartnerPosInfo();
    local fnOnSelectBattle = function (itemObj)
        RemoteServer.CallPartnerFunc("ChangePartnerFightID", itemObj.nPartnerId);
    end

    local fnOnSelect = function(itemObj)
    end

    local nFightPartnerID = me.GetFightPartnerID();
    local fnSetItem = function(itemObj, index)
        local nPartnerId = self.tbPartnerList[index];
        local tbPartner = self.tbAllPartner[nPartnerId];

        itemObj.nPartnerId = nPartnerId;
        itemObj.PartnerHead:SetPartnerInfo(tbPartner);
        itemObj.pPanel:Label_SetText("Name", tbPartner.szName);
        itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbPartner.nFightPower));
        itemObj.pPanel:SetActive("Mark", tbPartner.nIsNormal == 0);
        itemObj.BtnCheck.pPanel:SetActive("GuideTips", false);
        itemObj.BtnCheck:SetCheck(nFightPartnerID == nPartnerId);

        itemObj.BtnCheck.nPartnerId = nPartnerId;
        itemObj.BtnCheck.pPanel.OnTouchEvent = fnOnSelectBattle;
        itemObj.pPanel.OnTouchEvent = fnOnSelect;
    end    
    local bOnlyPos = WuLinDaHui:IsInMap(me.nMapTemplateId)
    local tbPartnerList, tbAllPartner = Partner:GetSortedPartnerList(me, nil, bOnlyPos);

    self.tbPartnerList = tbPartnerList;
    -- local nFindIndex = nil;
    -- for nIndex, nPartnerId in pairs(tbPartnerList) do
    --     if nPartnerId == nFightPartnerID then
    --         nFindIndex = nIndex;
    --     end    
    -- end

    -- if nFindIndex then
    --     table.remove(self.tbPartnerList, nFindIndex);
    --     table.insert(self.tbPartnerList, 1, nFightPartnerID);
    -- end    
    self.tbAllPartner  = tbAllPartner;
    self.CompanionScrollView:Update(self.tbPartnerList, fnSetItem);
end

function tbUi:OnChangeFightID()
    self:UpdateAllPartnerList();
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_CHANGE_FIGHTPARTNER_ID,                  self.OnChangeFightID, self},
    };

    return tbRegEvent;
end