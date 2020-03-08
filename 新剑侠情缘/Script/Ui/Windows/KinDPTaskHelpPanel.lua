local tbUi = Ui:CreateClass("KinDPTaskHelpPanel");

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_KIN_DATA,      self.OnKinListUpdate,   self },
        { UiNotify.emNOTIFY_SYNC_KDP_HELP, self.OnSyncHelp,        self },
    };

    return tbRegEvent;
end

function tbUi:InitButton()
    self.tbOnClick =
    {
        BtnClose = function (self)
            Ui:CloseWindow(self.UI_NAME)
        end
    }
    for i = 1, 4 do
        self.tbOnClick["OnLoad" .. i] = function (self)
            self:OnLoad(i)
        end
        self.tbOnClick["OnLoadByCoin" .. i] = function (self)
            self:OnLoadByCoin(i)
        end
    end
end
tbUi:InitButton()

function tbUi:OnLoad(nIndex)
    local tbSetting = self.tbInfo[nIndex];
    local nHas = me.GetItemCountInAllPos(tbSetting.nTemplateId);
    if nHas < tbSetting.nCount then
        local szName = Item:GetItemTemplateShowInfo(tbSetting.nTemplateId);
        local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
        local nContribution = KinDinnerParty:GetAddContributionCount(tbSetting.nTemplateId)
        local nGold = KinDinnerParty:GetHelpNeedCoin(tbSetting.nTemplateId)
        local szMsg = string.format("您的 [FFFE0D]%s[-] 不足，是否要花费 [FFFE0D]%d[-]%s 购买并协助交货？（交货后可获得[FFFE0D]%d贡献[-]）", szName, nGold, szMoneyEmotion, nContribution)

        me.MsgBox(szMsg, {{"确定", function ()
            local nMyGold = me.GetMoney("Gold")
            if nMyGold >= nGold then
                RemoteServer.KinDinnerPartyReq("DoHelp", self.nCurMemberId, tbSetting.nTaskId, true)
            else
                me.CenterMsg("元宝不足，无法协助完成任务")
                Ui:CloseWindow(self.UI_NAME)
                Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
            end
        end}, {"取消"}})
        return;
    end
    RemoteServer.KinDinnerPartyReq("DoHelp", self.nCurMemberId, tbSetting.nTaskId);
end

function tbUi:OnLoadByCoin(nIndex)
    local tbSetting = self.tbInfo[nIndex];
    local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
    local nContribution = KinDinnerParty:GetAddContributionCount(tbSetting.nTemplateId)
    local nGold = KinDinnerParty:GetHelpNeedCoin(tbSetting.nTemplateId)
    local szMsg = string.format("是否要花费 [FFFE0D]%d[-]%s 购买并协助交货？（交货后可获得[FFFE0D]%d贡献[-]）", nGold, szMoneyEmotion, nContribution)

    me.MsgBox(szMsg, {{"确定", function ()
        local nMyGold = me.GetMoney("Gold")
        if nMyGold >= nGold then
            RemoteServer.KinDinnerPartyReq("DoHelp", self.nCurMemberId, tbSetting.nTaskId, true)
        else
            me.CenterMsg("元宝不足，无法协助完成任务")
            Ui:CloseWindow(self.UI_NAME)
            Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
        end
    end}, {"取消"}})
end

function tbUi:OnOpenEnd(nMemberId)
    Kin:UpdateMemberList();
    self.nCurMemberId = nMemberId;
    self:Update();
end

function tbUi:OnKinListUpdate(szType)
    if szType ~= "MemberList" then
        return
    end

    self:Update();
end

function tbUi:Update()
    local szName, tbHelp = self:GetHelpData();
    tbHelp = tbHelp or {};
    szName = szName or "";
    self.pPanel:Label_SetText("UserName", szName);

    self.tbInfo = {};
    local nHelpCount = math.min(4, #tbHelp)
    for i = 1, nHelpCount do
        local nTaskId = tbHelp[i]
        local tbSetting = KinDinnerParty:GetTaskSetting(nTaskId);
        table.insert(self.tbInfo, tbSetting);

        self:UpdateListItem(#self.tbInfo, tbSetting);
    end

    for nLen = #self.tbInfo + 1, 4 do
        self.pPanel:SetActive("TaskList" .. nLen, false);
    end
end

function tbUi:UpdateListItem(nIdx, tbSetting)
    local nTemplateId = tbSetting.nTemplateId
    self.pPanel:SetActive("TaskList" .. nIdx, true);
    --名字
    local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
    local szNameText = tbBaseInfo.szName or "??";
    self.pPanel:Label_SetText("ItemNeedText" .. nIdx, szNameText);

    --数量
    local nHas = me.GetItemCountInAllPos(nTemplateId);
    local szNumText = string.format("%d/%d", nHas, tbSetting.nCount);
    local bGreen = nHas >= tbSetting.nCount;
    self.pPanel:Label_SetText("NumberRed" .. nIdx, szNumText);
    self.pPanel:Label_SetText("NumberGreen" .. nIdx, szNumText);
    self.pPanel:SetActive("NumberRed" .. nIdx, not bGreen);
    self.pPanel:SetActive("NumberGreen" .. nIdx, bGreen);

    --图标
    self["itemframe" .. nIdx]:SetItemByTemplate(nTemplateId, nil, me.nFaction);

    local nGold = KinDinnerParty:GetHelpNeedCoin(nTemplateId)
    self.pPanel:Button_SetText("OnLoadByCoin" .. nIdx, nGold)
end

function tbUi:GetHelpData()
    local tbMemberList = Kin:GetMemberList();
    if not tbMemberList then
        return;
    end
    for _, tbMember in pairs(tbMemberList) do
        if tbMember.nMemberId == self.nCurMemberId then
            local tbHelp = {}
            for nTaskId, bHelped in pairs(tbMember.tbKinDPTaskHelp or {}) do
                if not bHelped then
                    table.insert(tbHelp, nTaskId)
                end
            end
            return tbMember.szName, tbHelp
        end
    end
end

function tbUi:OnSyncHelp()
    self:Update();
end