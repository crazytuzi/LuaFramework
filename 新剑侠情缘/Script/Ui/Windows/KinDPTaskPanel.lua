local KinDPTaskPanel = Ui:CreateClass("KinDPTaskPanel");

KinDPTaskPanel.tbOnClick =
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnCompleteTask = function (self)
        Ui.HyperTextHandle:Handle("[url=npc:KinManager, 266, 1004]")
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnGiveUpTask = function (self)
        local OnOk = function ()
            RemoteServer.KinDinnerPartyReq("GiveUpTask");
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
        RemoteServer.KinDinnerPartyReq("CommitGather", tbSelectBoxData.nIndex);
        return;
    end

    local nTemplateId, nNeedCount = tbSelectBoxData.nTemplateId, tbSelectBoxData.nCount;
    local nHas = me.GetItemCountInAllPos(nTemplateId);

    if nHas < nNeedCount then
        local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
        local szTip = string.format("%s数量不足，无法交货", tbBaseInfo.szName);
        me.CenterMsg(szTip);
        return;
    end

    RemoteServer.KinDinnerPartyReq("CommitItem", tbSelectBoxData.nIndex);
end

local BtnGather = function (ButtonObj)
    local nIndex = ButtonObj.root.nIndex;
    local self = ButtonObj.root.self;
    local tbSelectBoxData = self.tbBoxInfo[nIndex];

    local function fnOnFindNpc()
        self:OnFindNpc(tbSelectBoxData.nTemplateId);
    end

    --前往采集
    local tbPos = KinDinnerParty:GetGatherPosition(tbSelectBoxData.nTemplateId);
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

    if me.dwKinId == 0 then
        me.CenterMsg("您必须加入家族才能求助");
        return;
    end
    RemoteServer.KinDinnerPartyReq("AskHelp", tbSelectBoxData.nTaskId);
end

function KinDPTaskPanel:OnFindNpc(nFindGatherId)
    local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE);
    for _, pNpc in pairs(tbNpcList or {}) do
        if pNpc.nTemplateId == nFindGatherId then
            local bMature, nMatureId, nUnMatureId, nMatureTime = KinDinnerParty:ResolveGatherParam(pNpc.szScriptParam);
            if bMature then
                Operation:OnKinDPGatherClicked(pNpc);
                break;
            end
        end
    end
end

function KinDPTaskPanel:OnOpen(tbTask)
    self.pPanel:SetActive("GiveTimes", false)
    self.pPanel:SetActive("BtnGiveUpTask", false)
    self.pPanel:Label_SetText("DialogText", "收集的部分物品比较稀缺，记得向家族发出求助！");
    tbTask = tbTask or KinDinnerParty.tbTask;

    self.nLevel = tbTask.nLevel;
    self.tbHelp = KinDinnerParty.tbHelp or {}
    self.tbTask = tbTask.tbTask;

    self:UpdateBoxData(tbTask.tbTask)
    self:UpdateScrollView();
    self:UpdateOperation();
end

function KinDPTaskPanel:UpdateBoxData(tbTask)
    local tbHelping = self:GetHelpingData();
    self.bAllFinished = true
    self.nFinishCount = 0
    local tbBoxInfo = {};
    for i,v in ipairs(tbTask) do
        local tbSetting = KinDinnerParty:GetTaskSetting(v.nTaskId);
        local bItemBox = tbSetting.szType == "Item";--

        local bHelping = false;
        if tbHelping[v.nTaskId] == false then
            bHelping = true;
        end

        local bCanFinish = false;
        if not v.bFinish then
            self.bAllFinished = false
            if bItemBox then
                local nHas = me.GetItemCountInAllPos(tbSetting.nTemplateId);
                bCanFinish = nHas >= tbSetting.nCount
            else
                bCanFinish = v.nGain >= tbSetting.nCount;
            end
        else
            self.nFinishCount = self.nFinishCount + 1
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
end

function KinDPTaskPanel:GetHelpingData()
    return self.tbHelp
end

function KinDPTaskPanel:UpdateScrollView()
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
            itemObj.pPanel:Sprite_SetSprite("GatherIcon", KinDinnerParty:GetGatherIcon(tbData.nTemplateId) or "", KinDinnerParty.Def.szIconAtlas);
        end

        --名字
        local szNameText = "";
        if bItemBox then
            local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId);
            szNameText = tbBaseInfo.szName;
        else
            szNameText = KinDinnerParty:GetGatherName(tbData.nTemplateId);
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

        local bEnable = KinDinnerParty:CanAskHelp(self.tbHelp, self.tbTask, tbData.nTaskId);
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

function KinDPTaskPanel:UpdateOperation()
    local bCanCommit = self.bAllFinished
    local bFinish = KinDinnerParty.tbTask.bFinished
    self.pPanel:SetActive("BtnCompleteTask", bCanCommit);
    self.pPanel:Button_SetEnabled("BtnCompleteTask", bCanCommit and KinDinnerParty:IsDoingTask(me))
    self.pPanel:Button_SetText("BtnCompleteTask", bFinish and "已完成" or "交任务")

    local bGiveup = KinDinnerParty.tbTask.bGiveup
    self.pPanel:SetActive("BtnGiveUpTask", not bCanCommit);
    self.pPanel:Button_SetEnabled("BtnGiveUpTask", not bCanCommit and not bGiveup)
    self.pPanel:Button_SetText("BtnGiveUpTask", bGiveup and "已放弃" or "放弃任务")

    self.itemframe:SetGenericItem({"Item", KinDinnerParty.Def.nPartyTokenId, 1})
    self.itemframe.fnClick = self.itemframe.DefaultClick

    self.pPanel:Label_SetText("FinishCount", string.format("%d/%d", self.nFinishCount, #self.tbTask));
end

function KinDPTaskPanel:OnSyncData(tbData)
    self:OnOpen(tbData);
end

function KinDPTaskPanel:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_SYNC_KDP_DATA, self.OnSyncData},
    };

    return tbRegEvent;
end
