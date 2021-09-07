DefendWelfareBagPanel = DefendWelfareBagPanel or BaseClass(BasePanel)

function DefendWelfareBagPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.defend_welfare_bag_panel, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        -- {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.selectIndex = 1
    self.mainItemList = {}
    self.isCanFill = true --用于防止连续的点填充
    self.curDataTpl = nil --当前选择的福袋

    self.itemDataNeed = ItemData.New()
    -- self.itemDataReward = ItemData.New()
    self.itemDataRewardTotal = ItemData.New()
    -- EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
    self.welfare_bags_info_update = function ()
        --福袋数据刷新
        self.isCanFill = true
        self:UpdatePanel()
    end
    EventMgr.Instance:AddListener(event_name.welfare_bags_info_update, self.welfare_bags_info_update)

    self.OnOpenEvent:AddListener(function()
        -- local args = self.model.mainModel.openArgs
        -- if args ~= nil and #args == 2 and args[1] == 3 then
        --     self.lastSub = tonumber(args[2])
        -- end
        -- self.lastSub = self.model.mainModel.currentSub
        -- self:ChangeTab(self.model.mainModel.currentSub)
        self.curDataTpl = nil
        self:UpdatePanel()
    end)
end

function DefendWelfareBagPanel:RemoveListener()

end

function DefendWelfareBagPanel:InitPanel()
    --Log.Error("DefendWelfareBagPanel:InitPanel")
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.defend_welfare_bag_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.timeDescTxt = self.transform:Find("TimeDescText"):GetComponent(Text)
    local start = DataCampaign.data_list[460].cli_start_time[1]
    local over = DataCampaign.data_list[460].cli_end_time[1]
    local str = string.format(TI18N("活动时间：%s年%s月%s日-%s年%s月%s日"), start[1], start[2], start[3], over[1], over[2], over[3])
    self.timeDescTxt.text = str

    self.rewardTotalImg = self.transform:Find("RewardBgImage/img")
    self.rewardTotalSlot = ItemSlot.New()
    NumberpadPanel.AddUIChild(self.rewardTotalImg.gameObject, self.rewardTotalSlot.gameObject)

    self.timeText = self.transform:Find("RemindTimeBgImage/TimeText"):GetComponent(Text)
    self.transform:Find("RewardDescText"):GetComponent(Text).text = TI18N("装满奖励:")
    self.transform:Find("RemindTimeBgImage/DescText"):GetComponent(Text).text = TI18N("今天任务剩余:")
   -- self.TxtfulDesc = self.transform:Find("Full/NeedDescText"):GetComponent(Text)
   -- self.TxtfulDesc.text = I18N("")
    self.itemList = {}
    for i=1,4 do
        local itemTran = self.transform:Find("Item_"..i)
        local itemDic = {}
        itemDic.item = itemTran
        itemDic.cImgLoader = SingleIconLoader.New(itemTran:Find("CImage").gameObject)
        itemDic.numText = itemTran:Find("ConDescText"):GetComponent(Text)
        itemDic.selectObj = itemTran:Find("SelectImage").gameObject
        itemDic.flagObj = itemTran:Find("FlagImage").gameObject
        itemDic.okObj = itemTran:Find("OkImage").gameObject
        itemDic.commitObj = itemTran:Find("CommitImage").gameObject
        itemDic.selectObj:SetActive(false)
        itemDic.flagObj:SetActive(false)
        itemDic.okObj:SetActive(false)
        itemDic.commitObj:SetActive(false)

        itemTran:GetComponent(Button).onClick:AddListener(function ()
            self:OnclickItem(i)
        end)

        table.insert(self.itemList,itemDic)
    end

    self.notFullObj = self.transform:Find("NotFull").gameObject

    self.needImg = self.transform:Find("NotFull/NeedBgImage/img")
    self.needSlot = ItemSlot.New()
    NumberpadPanel.AddUIChild(self.needImg.gameObject, self.needSlot.gameObject)
    self.rewardExpText = self.notFullObj.transform:Find("textbg/exptext"):GetComponent(Text)
    -- self.rewardImg = self.transform:Find("NotFull/RewardBgImage/img")
    -- self.rewardSlot = ItemSlot.New()
    -- NumberpadPanel.AddUIChild(self.rewardImg.gameObject, self.rewardSlot.gameObject)

    self.helpBtn = self.transform:Find("NotFull/AskHelpButton"):GetComponent(Button)
    self.helpBtn.onClick:AddListener(function ()
        self:OnclickHelpButton()
    end)
    self.fildBtn = self.transform:Find("NotFull/FildButton"):GetComponent(Button)
    self.fildBtn.onClick:AddListener(function ()
        self:OnclickFildButton()
    end)
    self.fildBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("填充")

    self.reqHelp = self.transform:Find("NotFull/reqhelp").gameObject
    self.reqHelp.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function ()
        self:OnclickCloseReqHelpButton()
    end)
    self.guildHelpBtn = self.reqHelp.transform:Find("Guildhelp"):GetComponent(Button)
    self.guildHelpBtn.onClick:AddListener(function ()
        self:OnclickGuildHelpButton()
    end)
    self.friendHelpBtn = self.reqHelp.transform:Find("Friendhelp"):GetComponent(Button)
    self.friendHelpBtn.onClick:AddListener(function ()
        self:OnclickFriendHelpButton()
    end)
    self.reqHelp:SetActive(false)

    self.fullObj = self.transform:Find("Full").gameObject
    self.getTotalRewardBtn = self.fullObj.transform:Find("GetButton"):GetComponent(Button)
    self.getTotalRewardBtn.onClick:AddListener(function ()
        self:OnclickGetTotalRewardBtn()
    end)
end
--领取最终奖励
function DefendWelfareBagPanel:OnclickGetTotalRewardBtn()
    CampaignManager.Instance:Send14014()
end
--关闭求助按钮
function DefendWelfareBagPanel:OnclickCloseReqHelpButton()
    self.reqHelp:SetActive(false)
end
--公会求助
function DefendWelfareBagPanel:OnclickGuildHelpButton()
    if self.curDataTpl ~= nil then
        -- self.isCanFill = false
        CampaignManager.Instance:Send14013(self.curDataTpl.id)
    end
    self:OnclickCloseReqHelpButton()
end
--好友求助
function DefendWelfareBagPanel:OnclickFriendHelpButton()
    self.model:FriendHelp()
    self:OnclickCloseReqHelpButton()
end
--点击某个福袋
function DefendWelfareBagPanel:OnclickItem(index)
    local v = self.dataItem.collected[index]
    local dataTpl = DataCampaignBags.data_getBags[v.id]
    if v.num < dataTpl.need then
        --未填满
        local itemDic = self.itemList[self.selectIndex]
        itemDic.selectObj:SetActive(false)
        itemDic.flagObj:SetActive(false)

        self.selectIndex = index
        self.curDataTpl = dataTpl
        self:UpdateData()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("此福袋已装满了"))
    end
end
--求助
function DefendWelfareBagPanel:OnclickHelpButton()
    self.reqHelp:SetActive(true)
end
--填充
function DefendWelfareBagPanel:OnclickFildButton()
    if self.curDataTpl ~= nil and self.isCanFill == true then
        -- self.isCanFill = false
        CampaignManager.Instance:Send14010(self.curDataTpl.id)
    end
end

function DefendWelfareBagPanel:OnInitCompleted()
    -- local args = self.model.mainModel.openArgs
    -- BaseUtils.dump(args,"---------------------")
    -- if args ~= nil and #args == 2 and args[1] == 3 then
    --     self.lastSub = tonumber(args[2])
    -- end
    -- print(self.lastSub .. "DefendWelfareBagPanel:EnableTab(sub)----------"..debug.traceback())
    -- self.lastSub = self.model.mainModel.currentSub
    -- self:ChangeTab(self.model.mainModel.currentSub)
    self.curDataTpl = nil
    self:UpdatePanel()
end

function DefendWelfareBagPanel:__delete()
    if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
        LuaTimer.Delete(self.timerIdBefore)
    end
    if self.rewardTotalSlot ~= nil then
        self.rewardTotalSlot:DeleteMe()
    end
    if self.needSlot ~= nil then
        self.needSlot:DeleteMe()
    end
    EventMgr.Instance:RemoveListener(event_name.welfare_bags_info_update, self.welfare_bags_info_update)
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.cImgLoader:DeleteMe()
            end
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    self.OnOpenEvent:RemoveAll()
    self:AssetClearAll()
end

function DefendWelfareBagPanel:UpdatePanel()
    if self.curDataTpl ~= nil then
        local v = CampaignManager.Instance.campaign_bags.collected[self.selectIndex]
        if v.num < self.curDataTpl.need then
            self:UpdateData()
        else
            self.curDataTpl = nil
            self:UpdatePanel()
        end
    else
        self.selectIndex = 0
        self.dataItem = CampaignManager.Instance.campaign_bags
        self.curDataTpl = nil --当前选择的福袋

        local indexSelected = 0
        local dataTplSelected = nil
        for i,v in ipairs(self.dataItem.collected) do
            local dataTpl = DataCampaignBags.data_getBags[v.id]
            local itemDic = self.itemList[i]
            itemDic.selectObj:SetActive(false)
            itemDic.flagObj:SetActive(false)

            itemDic.numText.text = tostring(dataTpl.need)
            itemDic.cImgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[dataTpl.id].icon)

            if v.num < dataTpl.need then
                itemDic.okObj:SetActive(false)
                local num = BackpackManager.Instance:GetItemCount(dataTpl.id)
                if num < dataTpl.need then
                    --不足
                    itemDic.commitObj:SetActive(false)
                else
                    itemDic.commitObj:SetActive(true)
                    if indexSelected == 0 then
                        indexSelected = i
                        dataTplSelected = dataTpl
                    end
                end
                if self.selectIndex == 0 then
                    self.curDataTpl = dataTpl
                    self.selectIndex = i
                end
            else
                itemDic.commitObj:SetActive(false)
                itemDic.okObj:SetActive(true)
            end
        end
        if indexSelected ~= 0 then
            self.curDataTpl = dataTplSelected
            self.selectIndex = indexSelected
        end
        if self.selectIndex > 0 then
            --有没填满的福袋
            self.notFullObj:SetActive(true)
            self.fullObj:SetActive(false)
            if self.effectRewardTotal ~= nil and self.effectRewardTotal.gameObject ~= nil then
                self.effectRewardTotal.gameObject:SetActive(false)
            end
            if self.effectGetRewardTotal ~= nil and self.effectGetRewardTotal.gameObject ~= nil then
                self.effectGetRewardTotal.gameObject:SetActive(false)
            end
            self:UpdateData()
        else
            --全部已填满
            self.notFullObj:SetActive(false)
            self.fullObj:SetActive(true)
            if CampaignManager.Instance.campaign_bags.rewarded == 1 then
                if self.effectRewardTotal ~= nil and self.effectRewardTotal.gameObject ~= nil then
                    self.effectRewardTotal.gameObject:SetActive(false)
                end
                if self.effectGetRewardTotal ~= nil and self.effectGetRewardTotal.gameObject ~= nil then
                    self.effectGetRewardTotal.gameObject:SetActive(false)
                end
                self.getTotalRewardBtn.gameObject:SetActive(false)
            elseif CampaignManager.Instance.campaign_bags.rewarded == 0 then
                self.getTotalRewardBtn.gameObject:SetActive(true)
                if self.effectRewardTotal ~= nil and self.effectRewardTotal.gameObject ~= nil then
                    self.effectRewardTotal.gameObject:SetActive(true)
                else
                    local fun = function(effectView)
                        local effectObject = effectView.gameObject

                        effectObject.transform:SetParent(self.rewardTotalImg)
                        effectObject.transform.localScale = Vector3(1, 1, 1)
                        effectObject.transform.localPosition = Vector3(-34, -26, -200)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                        effectObject:SetActive(true)
                    end
                    self.effectRewardTotal = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
                end
                if self.effectGetRewardTotal ~= nil and self.effectGetRewardTotal.gameObject ~= nil then
                    self.effectGetRewardTotal.gameObject:SetActive(true)
                else
                    local fun = function(effectView)
                        local effectObject = effectView.gameObject

                        effectObject.transform:SetParent(self.getTotalRewardBtn.transform)
                        effectObject.transform.localScale = Vector3(1.7, 0.7, 1)
                        effectObject.transform.localPosition = Vector3(-55, -16, -200)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                        effectObject:SetActive(true)
                    end
                    self.effectGetRewardTotal = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
                end
            end

            local dataTplTT = nil
            for i,v in ipairs(self.dataItem.collected) do
                dataTplTT = DataCampaignBags.data_getBags[v.id]
                break
            end
            local dataItemRewardTotal = DataItem.data_get[dataTplTT.reward_full[1][1]]
            self.itemDataRewardTotal:SetBase(dataItemRewardTotal)
            self.rewardTotalSlot:SetAll(self.itemDataRewardTotal, {inbag = false, nobutton = true})
            self.rewardTotalSlot:SetQuality(0)
            self.rewardTotalSlot:ShowBg(false)
        end
    end
    if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
        LuaTimer.Delete(self.timerIdBefore)
    end
    local ph = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local pm = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    local ps = tonumber(os.date("%S", BaseUtils.BASE_TIME))
    self.timeCount = 86400 - ph * 3600 - pm * 60 - ps + BaseUtils.BASE_TIME
    self.timerIdBefore = LuaTimer.Add(0, 1000, function()

        if self.timeCount > BaseUtils.BASE_TIME then

            local day,hour,min,second = BaseUtils.time_gap_to_timer(self.timeCount - BaseUtils.BASE_TIME)
            local timeStr = tostring(hour)
            if hour < 10 then
                timeStr = "0"..tostring(hour)
            end
            if min < 10 then
                timeStr = timeStr.. TI18N("小时0") .. tostring(min)
            else
                timeStr = timeStr.. TI18N("小时") .. tostring(min)
            end
            if second < 10 then
                timeStr = string.format(TI18N("%s分钟0%s秒"), timeStr, second)
            else
                timeStr = string.format(TI18N("%s分钟%s秒"), timeStr, second)
            end

            self.timeText.text = timeStr --BaseUtils.formate_time_gap(self.countDataBefore,":",0,BaseUtils.time_formate.MIN)
        else
            -- self.countDataBefore = 0
            LuaTimer.Delete(self.timerIdBefore)
        end
    end)
end

function DefendWelfareBagPanel:UpdateData()
    local itemDic = self.itemList[self.selectIndex]
    local collectedData = CampaignManager.Instance.campaign_bags.collected[self.selectIndex]
    local  neddNum = self.curDataTpl.need - collectedData.num;
    if  neddNum < 0 then
        neddNum = 0
    end
    itemDic.selectObj:SetActive(true)
    itemDic.flagObj:SetActive(true)

    local dataItemNeed = DataItem.data_get[self.curDataTpl.id]
    self.itemDataNeed:SetBase(dataItemNeed)
    self.needSlot:SetAll(self.itemDataNeed, {inbag = false, nobutton = true})
    self.needSlot:SetNum(BackpackManager.Instance:GetItemCount(self.curDataTpl.id),neddNum)
    self.needSlot:SetQuality(0)
    self.needSlot:ShowBg(false)

    local dataItemRewardTotal = DataItem.data_get[self.curDataTpl.reward_full[1][1]]
    self.itemDataRewardTotal:SetBase(dataItemRewardTotal)
    self.rewardTotalSlot:SetAll(self.itemDataRewardTotal, {inbag = false, nobutton = true})
    self.rewardTotalSlot:SetQuality(0)
    self.rewardTotalSlot:ShowBg(false)

    self.rewardExpText.text = tostring(CampaignManager.Instance.campaign_bags.bagRewardsKeyValue[self.curDataTpl.id].rewards[1].base_num)
    -- local dataItemReward = DataItem.data_get[self.curDataTpl.reward_fill[1][1]]
    -- self.itemDataReward:SetBase(dataItemReward)
    -- self.rewardSlot:SetAll(self.itemDataReward, {inbag = false, nobutton = true})
    -- self.rewardSlot:SetQuality(0)
    -- self.rewardSlot:ShowBg(false)
end

