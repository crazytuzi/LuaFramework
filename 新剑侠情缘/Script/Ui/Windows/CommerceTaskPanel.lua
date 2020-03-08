local CommerceTaskPanel = Ui:CreateClass("CommerceTaskPanel");

CommerceTaskPanel.tbOnClick =
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnCompleteTask = function (self)
        if self.nFinishCount == 10 then
            CommerceTask:AutoPathToTaskNpc()
            Ui:CloseWindow(self.UI_NAME)
        elseif self.nFinishCount >= CommerceTask.COMPLETE_COUNT then
            local OnOk = function ()
                CommerceTask:AutoPathToTaskNpc()
                Ui:CloseWindow(self.UI_NAME)
            end

            Ui:OpenWindow("MessageBox", CommerceTask.szNotAllCompleteMsg, {{OnOk},{}});
        end
    end,

    BtnGiveUpTask = function (self)
        local OnOk = function ()
            RemoteServer.OnCommerceTaskRequset("GiveUpTask");
            Ui:CloseWindow(self.UI_NAME);
        end

        Ui:OpenWindow("MessageBox", "你确定要放弃任务吗？", {{OnOk},{}});
    end,
}

local BtnLoad = function (ButtonObj)
    local nIndex = ButtonObj.root.nIndex;
    local self = ButtonObj.root.self;
    local tbSelectBoxData = self.tbBoxInfo[nIndex];

    if tbSelectBoxData.szType == "Gather" then
        RemoteServer.OnCommerceTaskRequset("CommitGather", tbSelectBoxData.nIndex);
        return;
    end

    local nTemplateId, nNeedCount = tbSelectBoxData.nTemplateId, tbSelectBoxData.nCount;
    local nHas = me.GetItemCountInAllPos(nTemplateId);

    if nHas < nNeedCount then
        local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
        local szTip = string.format("%s数量不足，无法交货", tbBaseInfo.szName);
        me.CenterMsg(szTip);
        self:SayGuide(tbSelectBoxData);
        return;
    end

    RemoteServer.OnCommerceTaskRequset("CommitItem", tbSelectBoxData.nIndex);
end

local BtnGather = function (ButtonObj)
    local nIndex = ButtonObj.root.nIndex;
    local self = ButtonObj.root.self;
    local tbSelectBoxData = self.tbBoxInfo[nIndex];

    local function fnOnFindNpc()
        self:OnFindNpc(tbSelectBoxData.nTemplateId);
    end

    --前往采集
    local tbPos = CommerceTask:GetGatherPosition(tbSelectBoxData.nTemplateId);
    if tbPos then
        local nMapId, nX, nY = unpack(tbPos);
        AutoPath:GotoAndCall(nMapId, nX, nY, fnOnFindNpc);
        Ui:CloseWindow(self.UI_NAME);
    else
        me.CenterMsg("没找到该采集物");
    end
end

local BtnHelp = function (ButtonObj)
    local nIndex = ButtonObj.root.nIndex;
    local self = ButtonObj.root.self;
    local tbSelectBoxData = self.tbBoxInfo[nIndex];

    self:SayGuide(tbSelectBoxData);

    if me.dwKinId == 0 then
        me.CenterMsg("您必须加入家族才能求助");
        return;
    end
    RemoteServer.OnCommerceTaskRequset("AskHelp", tbSelectBoxData.nTaskId);
end

function CommerceTaskPanel:SayGuide(tbSelectBoxData)
    --[[
    local szGuide = CommerceTask:GetGuideText(tbSelectBoxData.nTemplateId);
    local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(tbSelectBoxData.nTemplateId);
    local szColor = Ui.tbQualityRGB[nQuality] or Ui.tbQualityRGB[1];
    local szItemName = string.format("[%s]%s[-]", szColor, szName);
    szGuide = string.format(szGuide, szItemName);
    if szGuide then
        self.pPanel:Label_SetText("DialogText", szGuide);
        self.pPanel:ResetTypewriterEffect("DialogText");
    end
    ]]--
end

function CommerceTaskPanel:OnFindNpc(nFindGatherId)
    local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE);
    for _, pNpc in pairs(tbNpcList or {}) do
        if pNpc.nTemplateId == nFindGatherId then
            local bMature, nMatureId, nUnMatureId, nMatureTime = CommerceTask:ResolveGatherParam(pNpc.szScriptParam);
            if bMature then
                Operation:OnGatherClicked(pNpc);
                break;
            end
        end
    end
end

function CommerceTaskPanel:OnOpen(tbCommerceData)
    self.pPanel:Label_SetText("DialogText", "收集越多货物，完成任务后奖励越丰富！");
    tbCommerceData = tbCommerceData or CommerceTask.tbCommerceData;

    self.nLevel = tbCommerceData.nLevel;
    self.tbHelp = tbCommerceData.tbHelp;
    self.tbTask = tbCommerceData.tbTask;

    self.nRemainHelpCount = CommerceTask:GetRemainHelpCount(self.tbHelp);
    self:UpdateBoxData(tbCommerceData.tbTask)
    self:UpdateScrollView();
    self:UpdateOperation();
end

function CommerceTaskPanel:UpdateBoxData(tbTask)
    local tbHelping = self:GetHelpingData();
    local nFinishCount = 0;
    local tbBoxInfo = {};
    for i,v in ipairs(tbTask) do
        local tbSetting = CommerceTask:GetTaskSetting(v.nTaskId);
        local bItemBox = tbSetting.szType == "Item";--

        --是否已完成
        local bHelping = false;
        if tbHelping[v.nTaskId] and tbHelping[v.nTaskId] > 0 then
            bHelping = true;
            tbHelping[v.nTaskId] = tbHelping[v.nTaskId] - 1;
        end
        if v.bFinish then
            nFinishCount = nFinishCount + 1;
        end

        --能否完成
        local bCanFinish = false;
        if not v.bFinish then
            if bItemBox then
                local nHas = me.GetItemCountInAllPos(tbSetting.nTemplateId);
                bCanFinish = nHas >= tbSetting.nCount
            else
                bCanFinish = v.nGain >= tbSetting.nCount;
            end
        end

        local tbTmp = 
        {
            nIndex      = i,
            nTaskId     = v.nTaskId,
            bFinish     = v.bFinish,
            nGain       = v.nGain,
            szType      = tbSetting.szType,
            nTemplateId = tbSetting.nTemplateId,
            nCount      = tbSetting.nCount,
            bHelping    = bHelping,
            tbReward1   = {
                            tbSetting.szRewardType1,
                            tbSetting.nRewardId1,
                            tbSetting.nRewardCount1
                        },
            tbReward2   = {
                            tbSetting.szRewardType2,
                            tbSetting.nRewardId2,
                            tbSetting.nRewardCount2
                        },

            bItemBox    = bItemBox,
            bCanFinish  = bCanFinish,
        }
        if tbTmp.bItemBox then
            tbTmp.nSort = 100 + tbTmp.nIndex
        else
            tbTmp.nSort = tbTmp.nIndex
        end
        if not tbTmp.bFinish then
            if tbTmp.bHelping then
                if tbTmp.bCanFinish then
                    tbTmp.nSort = tbTmp.nSort + 1000
                end
                tbTmp.nSort = tbTmp.nSort + 10000
            else
                tbTmp.nSort = tbTmp.nSort + 100000
                if tbTmp.bCanFinish then
                    tbTmp.nSort = tbTmp.nSort + 1000000
                end
            end
        end
        table.insert(tbBoxInfo, tbTmp)
    end
    table.sort(tbBoxInfo, function (t1, t2)
        return t1.nSort > t2.nSort
    end)

    self.tbBoxInfo = tbBoxInfo;
    self.nFinishCount = nFinishCount;
end

function CommerceTaskPanel:GetHelpingData()
    local tbHelping = {};
    local nHelpCount = math.floor((#self.tbHelp)/2)
    for i = 1, nHelpCount do
        local nTaskId = self.tbHelp[i];
        if tbHelping[nTaskId] then
            tbHelping[nTaskId] = tbHelping[nTaskId] + 1;
        else
            tbHelping[nTaskId] = 1;
        end
    end

    return tbHelping;
end

function CommerceTaskPanel:UpdateScrollView()
    local fnClickItem = function (ButtonObj)
        local tbData = self.tbBoxInfo[ButtonObj.nIndex];
        self.tbSelectBoxData = tbData;
    end

    local fnSetItem = function (itemObj, nIndex)
        local tbData = self.tbBoxInfo[nIndex];
        local bItemBox = tbData.bItemBox;

        local bSelect = false;
        if bSelect then
            itemObj.pPanel:Sprite_SetSprite("Main", "BtnListThirdPress");
        else
            itemObj.pPanel:Sprite_SetSprite("Main", "BtnListThirdNormal");
        end

        --图标
        itemObj.pPanel:SetActive("Item", bItemBox);
        itemObj.pPanel:SetActive("GatherItem", not bItemBox);
        if bItemBox then

            itemObj.Item:SetItemByTemplate(tbData.nTemplateId, nil, me.nFaction);
            itemObj.Item.fnClick = itemObj.Item.DefaultClick;
        else
            itemObj.pPanel:Sprite_SetSprite("GatherIcon", CommerceTask:GetGatherIcon(tbData.nTemplateId) or "");
        end

        --名字
        local szNameText = "";
        if bItemBox then
            local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId);
            szNameText = tbBaseInfo.szName;
        else
            szNameText = CommerceTask:GetGatherName(tbData.nTemplateId);
        end
        itemObj.pPanel:Label_SetText("TxtItemName", szNameText);

        --数量
        local nFinishCount;
        if tbData.bFinish then
            nFinishCount = tbData.nCount;
        else
            if bItemBox then
                nFinishCount = me.GetItemCountInAllPos(tbData.nTemplateId);
            else
                nFinishCount = tbData.nGain;
            end
        end

        local szCountText = string.format("%d/%d", nFinishCount, tbData.nCount);
        local bEnough = nFinishCount >= tbData.nCount;
        itemObj.pPanel:SetActive("NumberRed", not bEnough);
        itemObj.pPanel:SetActive("NumberGreen", bEnough);
        itemObj.pPanel:Label_SetText("NumberRed", szCountText);
        itemObj.pPanel:Label_SetText("NumberGreen", szCountText);

        --求助
        itemObj.pPanel:SetActive("BtnHaveForHelp", tbData.bHelping and not tbData.bFinish);

        local bEnable = CommerceTask:CanAskHelp(self.tbHelp, self.tbTask, tbData.nTaskId);
        itemObj.pPanel:SetActive("BtnHelp", not tbData.bFinish and bEnable and not tbData.bHelping);
        itemObj.BtnHelp.pPanel.OnTouchEvent = BtnHelp;

        --提交按钮
        itemObj.pPanel:SetActive("Completed", tbData.bFinish);


        if bItemBox then
            itemObj.pPanel:SetActive("BtnDelivery", not tbData.bFinish);
            itemObj.pPanel:SetActive("BtnCollection", false);
        else
            itemObj.pPanel:SetActive("BtnCollection", not bEnough and not tbData.bFinish );
            itemObj.pPanel:SetActive("BtnDelivery", bEnough and not tbData.bFinish);
        end

        itemObj.BtnCollection.pPanel.OnTouchEvent = BtnGather;
        itemObj.BtnDelivery.pPanel.OnTouchEvent = BtnLoad;
        itemObj.BtnDelivery.nIndex = nIndex;

        itemObj.nIndex = nIndex;
        itemObj.self = self;
        itemObj.pPanel.OnTouchEvent = fnClickItem;
    end

    self.ScrollView:Update(self.tbBoxInfo, fnSetItem);
end

function CommerceTaskPanel:UpdateOperation()
    local tbAward = {
        {CommerceTask.BASIC_MONEY_TYPE, CommerceTask.BASIC_MONEY_NUM * self.nFinishCount},
        CommerceTask.BASIC_AWARD,
    }
    local tbAllCompleteAward = CommerceTask:GetAllCompleteAward(me)
    table.insert(tbAward, tbAllCompleteAward)
    table.insert(tbAward, {"BasicExp", CommerceTask.BASIC_EXP_AWARD * self.nFinishCount})
    for i = 1, 4 do
        self["itemframe" .. i]:SetGenericItem(tbAward[i])
        self["itemframe" .. i].fnClick = self["itemframe" .. i].DefaultClick;
    end

    --求助
    local nAskHelpCount = CommerceTask:GetAskHelpCount(me.GetVipLevel())
    local szRemainHelpCount = string.format("%d/%d", self.nRemainHelpCount, nAskHelpCount);
    self.pPanel:Label_SetText("RemainHelpCount", szRemainHelpCount);

    --提交 or 放弃
    local bCanCommit = self.nFinishCount >= CommerceTask.COMPLETE_COUNT;
    local bGiveup = CommerceTask:IsGiveupTodyTask(me)
    self.pPanel:SetActive("BtnGiveUpTask", not bCanCommit);
    self.pPanel:Button_SetEnabled("BtnGiveUpTask", not bCanCommit and not bGiveup)
    self.pPanel:Button_SetText("BtnGiveUpTask", bGiveup and "已放弃" or "放弃任务")


    local bFinish = CommerceTask:IsFinishTodayTask(me)
    self.pPanel:SetActive("BtnCompleteTask", bCanCommit);
    self.pPanel:Button_SetEnabled("BtnCompleteTask", bCanCommit and CommerceTask:IsDoingTask(me))
    self.pPanel:Button_SetText("BtnCompleteTask", bFinish and "已完成" or "交任务")

    --已完成次数
    self.pPanel:Label_SetText("FinishCount", string.format("%d/%d", self.nFinishCount, 10));

    local nQQVip, nAddRate = me.GetQQVipInfo();
    self.pPanel:SetActive("MemberAdditionTxt", nAddRate ~= 0 and not Sdk:IsOuterChannel());
    if nAddRate ~= 0 then
        self.pPanel:Label_SetText("MemberAdditionTxt",
            string.format("%s获得银两加成%d%%", nQQVip == Player.QQVIP_SVIP and "#967" or "#968", nAddRate * 100));
    end
end

function CommerceTaskPanel:OnSyncData(tbData)
    self:OnOpen(tbData);
end

function CommerceTaskPanel:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNoTIFY_SYNC_COMMERCE_DATA, self.OnSyncData},
    };

    return tbRegEvent;
end
