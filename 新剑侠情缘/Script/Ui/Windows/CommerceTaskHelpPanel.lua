local CommerceHelpPanel = Ui:CreateClass("CommerceHelpPanel");

function CommerceHelpPanel:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_KIN_DATA,      self.OnKinListUpdate,   self },
        { UiNotify.emNoTIFY_SYNC_COMMERCE_HELP, self.OnSyncHelp,        self },
    };

    return tbRegEvent;
end

function CommerceHelpPanel:InitButton()
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
CommerceHelpPanel:InitButton()

function CommerceHelpPanel:OnLoad(nIndex)
    local tbSetting = self.tbInfo[nIndex];
    local nHas = me.GetItemCountInAllPos(tbSetting.nTemplateId);
    if nHas < tbSetting.nCount then
        local szName = Item:GetItemTemplateShowInfo(tbSetting.nTemplateId);
        local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
        local nContribution = CommerceTask:GetAddContributionCount(tbSetting.nTemplateId)
        local nGold = CommerceTask:GetHelpNeedCoin(tbSetting.nTemplateId)
        local szMsg = string.format("您的 [FFFE0D]%s[-] 不足，是否要花费 [FFFE0D]%d[-]%s 购买并协助交货？（交货后可获得[FFFE0D]%d贡献[-]）", szName, nGold, szMoneyEmotion, nContribution)

        me.MsgBox(szMsg, {{"确定", function ()
            local nMyGold = me.GetMoney("Gold")
            if nMyGold >= nGold then
                RemoteServer.OnCommerceTaskRequset("DoHelp", self.nCurMemberId, tbSetting.nTaskId, true)
            else
                me.CenterMsg("元宝不足，无法协助完成任务")
                Ui:CloseWindow(self.UI_NAME)
                Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
            end
        end}, {"取消"}})
        return;
    end
    RemoteServer.OnCommerceTaskRequset("DoHelp", self.nCurMemberId, tbSetting.nTaskId);
end

function CommerceHelpPanel:OnLoadByCoin(nIndex)
    local tbSetting = self.tbInfo[nIndex];
    local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
    local nContribution = CommerceTask:GetAddContributionCount(tbSetting.nTemplateId)
    local nGold = CommerceTask:GetHelpNeedCoin(tbSetting.nTemplateId)
    local szMsg = string.format("是否要花费 [FFFE0D]%d[-]%s 购买并协助交货？（交货后可获得[FFFE0D]%d贡献[-]）", nGold, szMoneyEmotion, nContribution)

    me.MsgBox(szMsg, {{"确定", function ()
        local nMyGold = me.GetMoney("Gold")
        if nMyGold >= nGold then
            RemoteServer.OnCommerceTaskRequset("DoHelp", self.nCurMemberId, tbSetting.nTaskId, true)
        else
            me.CenterMsg("元宝不足，无法协助完成任务")
            Ui:CloseWindow(self.UI_NAME)
            Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
        end
    end}, {"取消"}})
end

function CommerceHelpPanel:OnOpenEnd(nMemberId)
    Kin:UpdateMemberList();
    self.nCurMemberId = nMemberId;
    self:Update();
end

function CommerceHelpPanel:OnKinListUpdate(szType)
    if szType ~= "MemberList" then
        return
    end

    self:Update();
end

function CommerceHelpPanel:Update()
    local szName, tbHelp = self:GetHelpData();
    tbHelp = tbHelp or {};
    szName = szName or "";
    self.pPanel:Label_SetText("UserName", szName);

    self.tbInfo = {};
    local nHelpCount = math.floor((#tbHelp)/2)
    for i = 1, nHelpCount do
        local nTaskId = tbHelp[i] or 0;
        local nState = tbHelp[i + nHelpCount] or -1 ;
        if nTaskId > 0 and nState == 0 then
            local tbSetting = CommerceTask:GetTaskSetting(nTaskId);
            table.insert(self.tbInfo, tbSetting);

            self:UpdateListItem(#self.tbInfo, tbSetting);
        end
    end

    for nLen = #self.tbInfo + 1, 4 do
        self.pPanel:SetActive("TaskList" .. nLen, false);
    end

    self.pPanel:Label_SetText("Time", string.format("[73cbd5]剩余协助次数：[-]%d", CommerceTask:GetLastHelpTimes()))
end

function CommerceHelpPanel:UpdateListItem(nIdx, tbSetting)
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

    local nGold = CommerceTask:GetHelpNeedCoin(nTemplateId)
    self.pPanel:Button_SetText("OnLoadByCoin" .. nIdx, nGold)
end

function CommerceHelpPanel:GetHelpData()
    local tbMemberList = Kin:GetMemberList();
    if not tbMemberList then
        return;
    end
    for _, tbMember in pairs(tbMemberList) do
        if tbMember.nMemberId == self.nCurMemberId then
            return tbMember.szName, tbMember.tbCommerceHelp;
        end
    end
end

function CommerceHelpPanel:OnSyncHelp()
    self:Update();
end