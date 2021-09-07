MysticalEggPanel = MysticalEggPanel or BaseClass(BasePanel)

function MysticalEggPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.mystical_eggs_panel, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.arena_textures, type = AssetType.Dep}
    }

    self.targetNum = {point = 0}
    self.timerId = 0
    self.stepTimerId = 0
    self.selectIndex = 0
    self.soulImageTimerId = 0
    self.mainItemList = {}
    self.isRunning = false --在投掷过程中
    self.lastRunGrid = nil --上次走的格子
    self.spendingTime = 0
    self.soulImageCounter = 0
    -- self.num = 0 -- 剩余

    self.itemData = ItemData.New()
    -- EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)

    self.mystical_eggs_info_update = function ()
        if self.isRunning == false then
            self:UpdatePanel()
        end
    end
    EventMgr.Instance:AddListener(event_name.mystical_eggs_info_update, self.mystical_eggs_info_update)

    self.mystical_eggs_roll_update = function ()
        self:updateRoll()
    end
    EventMgr.Instance:AddListener(event_name.mystical_eggs_roll_update, self.mystical_eggs_roll_update)

    self.OnOpenEvent:AddListener(function()
        self:UpdatePanel()
    end)
    self.imgLoader = {}
end

function MysticalEggPanel:RemoveListener()

end

function MysticalEggPanel:InitPanel()
    --Log.Error("MysticalEggPanel:InitPanel")
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mystical_eggs_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.rewardSlotList = {} --奖励列表

    for i=1,3 do
        local rewardItem = self.transform:Find("RewardItem_"..i)
        local rewardDic = {}
        rewardDic.item = rewardItem
        rewardDic.imgCon = rewardItem:Find("RewardBgImage/Img")
        rewardDic.slot = ItemSlot.New()
        local info = ItemData.New()
        local dataTemp = DataCampaignEggs.data_getRolled[i]
        local base = DataItem.data_get[dataTemp.item_id]
        info:SetBase(base)
        local extra = {inbag = false, nobutton = true}
        rewardDic.slot:SetAll(info, extra)
        rewardDic.slot:SetNum(dataTemp.item_num)
        rewardDic.slot:SetQuality(0) -- 不显示品质框
        NumberpadPanel.AddUIChild(rewardDic.imgCon.gameObject, rewardDic.slot.gameObject)
        rewardDic.slot:ShowBg(false)
        rewardDic.slot:SetSelectSelfCallback(function ()
            self:onClickRewardItem(i)
        end)
        rewardDic.descText = rewardItem:Find("DescText"):GetComponent(Text)
        rewardDic.timesText = rewardItem:Find("TimesText"):GetComponent(Text)
        rewardDic.slider = rewardItem:Find("Slider"):GetComponent(Slider)
        rewardDic.gettedImg = rewardItem:Find("GetedImage").gameObject

        table.insert(self.rewardSlotList,rewardDic)
    end

    self.timesCanUseText = self.transform:Find("TimesUseText"):GetComponent(Text) --可用次数

    self.itemList = {}
    for i=1,28 do
        local itemTran = self.transform:Find("Con/Grid_"..i)
        local itemDic = {}
        itemDic.item = itemTran
        itemDic.bgImg = itemTran:GetComponent(Image)
        itemDic.cImg = itemTran:Find("ImgCon").gameObject:GetComponent(Image)
        itemDic.cntTxt = itemTran:Find("CountText").gameObject:GetComponent(Text)
        itemDic.data = DataCampaignEggs.data_getEggs[i]
        local dataItem = DataItem.data_get[itemDic.data.item_id]

        local idObj = itemDic.cImg.gameObject:GetInstanceID()
        if self.imgLoader[idObj] == nil then
            self.imgLoader[idObj] = SingleIconLoader.New(itemDic.cImg.gameObject)
        end
        self.imgLoader[idObj]:SetSprite(SingleIconType.Item, dataItem.icon)

        if i < 28 then
            itemDic.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, itemDic.data.grid_bg_name)
        end
        if itemDic.data.item_num > 1 then
            itemDic.cntTxt.text = tostring(itemDic.data.item_num)
        else
            itemDic.cntTxt.text = ""
        end
        -- itemDic.slot = ItemSlot.New()
        -- local info = ItemData.New()
        -- local base = DataItem.data_get[dataTemp.item_id]
        -- info:SetBase(base)
        -- local extra = {inbag = false, nobutton = true}
        -- itemDic.slot:SetAll(info, extra)
        -- itemDic.slot:SetNum(dataTemp.item_num)
        -- NumberpadPanel.AddUIChild(itemDic.cImg.gameObject, itemDic.slot.gameObject)
        -- itemDic.slot:ShowBg(false)
        itemDic.selectObj = itemTran:Find("SelectedImage").gameObject
        itemDic.getedObj = itemTran:Find("GetedImage").gameObject
        itemDic.selectObj:SetActive(false)
        itemDic.getedObj:SetActive(false)

        itemTran:GetComponent(Button).onClick:AddListener(function ()
            self:OnclickItemTran(i)
        end)

        if i == 28 then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(itemTran)
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 0, -200)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(true)
            end
            self.bev = BaseEffectView.New({effectId = 20141, time = nil, callback = fun})

            self.needMoveImg = itemDic.cImg
            local startPos = self.needMoveImg.gameObject.transform.localPosition
            self.needMoveImg.gameObject.transform.localPosition = self.needMoveImg.gameObject.transform.localPosition + Vector3(0,10,0)
            Tween.Instance:MoveLocalY(self.needMoveImg.gameObject, startPos.y - 4, 0.7, function() end, LeanTweenType.easeInOutQuad):setLoopPingPong()
        end

        table.insert(self.itemList,itemDic)
    end

    self.ruleInfobtn = self.transform:Find("RuleImage"):GetComponent(Button)
    self.ruleInfobtn.onClick:AddListener(function ()
            self:OnclickRuleBtn()
        end)

    self.rollImg = self.transform:Find("Con/RoldFlagImage"):GetComponent(Image)
    self.rollImg.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_5")
    -- self.rollImg.gameObject:GetComponent(Button).onClick:AddListener(function ()
    --     self:OnclickRollButton()
    -- end)
    self.redPointImgObj = self.transform:Find("RedPointImage").gameObject
    self.rollBtn = self.transform:Find("RollButton"):GetComponent(Button)
    self.transform:Find("RollButton"):GetComponent(Image).enabled = false
    -- self.transform:Find("RollButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    -- self.rollBtn.onClick:AddListener(function ()
    --     self:OnclickRollButton()
    -- end)
    self.getButton = BuyButton.New(self.rollBtn.gameObject, TI18N("投 掷"),WindowConfig.WinID.biblemain)
    self.getButton.protoId = 14007
    self.getButton:Show()

    self.rollBtnText = self.rollBtn.transform:Find("Text"):GetComponent(Text)
    self.transform:Find("RollButton/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_5")
    -- self.fildBtn = self.transform:Find("FildButton"):GetComponent(Button)
    -- self.fildBtn.onClick:AddListener(function ()
    --     self:OnclickFildButton()
    -- end)

    -- self.reqHelp = self.transform:Find("reqhelp").gameObject
    -- self.reqHelp.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function ()
    --     self:OnclickCloseReqHelpButton()
    -- end)
    -- self.guildHelpBtn = self.reqHelp.transform:Find("Guildhelp"):GetComponent(Button)
    -- self.guildHelpBtn.onClick:AddListener(function ()
    --     self:OnclickGuildHelpButton()
    -- end)
end
function MysticalEggPanel:onClickRewardItem(index)
    local dataTemp = DataCampaignEggs.data_getRolled[index]
    if self.eggsData.rolled >= dataTemp.need then
        CampaignManager.Instance:Send14008(dataTemp.id)
    end
end
function MysticalEggPanel:OnclickItemTran(index)
    local dataTemp = DataCampaignEggs.data_getEggs[index]
    local dataItem = DataItem.data_get[dataTemp.item_id]
    self.itemData:SetBase(dataItem)
    TipsManager.Instance:ShowItem({gameObject = self.itemList[index].item.gameObject, itemData = self.itemData, extra = {nobutton = true, inbag = false}})
end

function MysticalEggPanel:OnclickRuleBtn()
    self.descRole = {
            TI18N("1.消耗<color='#ffff00'>幸运骰子</color>可以投掷，每天登陆免费投掷<color='#ffff00'>1</color>次"),
            TI18N("2.根据掷出的点数移动到相应位置并<color='#ffff00'>获得奖励</color>"),
            TI18N("3.当移动到终点可获得<color='#ffff00'>神秘彩蛋</color>"),
            TI18N("4.到达终点后重置本轮已获得奖励并且重新开始，每天参与参与上限<color='#ffff00'>15</color>次"),
            TI18N("5.<color='#ffff00'>幸运骰子</color>可在五一活动中获得"),
            TI18N("6.活动时间：4月29日-5月9日"),
        }
    TipsManager.Instance:ShowText({gameObject = self.ruleInfobtn.gameObject, itemData = self.descRole})
end
--投掷
function MysticalEggPanel:OnclickRollButton()
    --请协议，投掷结果
    if self.isRunning == false then
        local roledata = RoleManager.Instance.RoleData
        local gold = roledata:GetMyAssetById(KvData.assets.gold)
        if self.getButton.money > gold then
            -- NoticeManager.Instance:FloatTipsByString("道具不足, 无法操作 !")
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
        else
            self.isRunning = true
            CampaignManager.Instance:Send14007()
        end
    end
end
function MysticalEggPanel:updateRoll()
    self.eggsData = CampaignManager.Instance.campaign_eggs
    self.targetNum = CampaignManager.Instance.rollPoint

    if self.targetNum.point > 0 then
        self:StartRoll()
    else
        Log.Error("目标位置不正确point="..self.targetNum.point)
    end
end
--开始投掷
function MysticalEggPanel:StartRoll()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 60, function() self:GoNextFrame() end)
end
--变化骰子
function MysticalEggPanel:GoNextFrame()
    if self.spendingTime == 30 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
        self.spendingTime = 0
        self.rollImg.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_"..self.targetNum.point)

        self.stepTimerId = LuaTimer.Add(50, 250, function() self:GoNextStep() end)
        return
    end

    self.spendingTime = self.spendingTime + 1
    self.rollImg.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_Action_"..(self.spendingTime % 4))
end
--选中效果移动
function MysticalEggPanel:GoNextStep()
    self.selectIndex = self.selectIndex + 1
    local curGrid = self.itemList[self.selectIndex]
    if self.lastRunGrid ~= nil then
        self.lastRunGrid.selectObj:SetActive(false)
    end
    if curGrid ~= nil then
        self.lastRunGrid = curGrid
        self.lastRunGrid.selectObj:SetActive(true)
    end
    local pos = self.eggsData.location
    if pos == 0 then
        pos = 28
    end
    if self.selectIndex >= pos then
        LuaTimer.Delete(self.stepTimerId)
        if self.soulImageTimerId ~= 0 then
            LuaTimer.Delete(self.soulImageTimerId)
        end
        self.soulImageCounter = 0
        self.soulImageTimerId = LuaTimer.Add(0, 50, function() self:SoulImageTween() end)
    end
end
--缩放
function MysticalEggPanel:SoulImageTween()
    local curGrid = self.itemList[self.selectIndex]
    if self.soulImageCounter > 14 then
        LuaTimer.Delete(self.soulImageTimerId)
        self.soulImageTimerId = 0
        curGrid.item.localScale = Vector3.one

        local dataTemp = DataCampaignEggs.data_getEggs[self.selectIndex]
        local msg = ""
        if self.selectIndex ~= 28 then
            msg = string.format(TI18N("获得{item_2, %d, 0, %d}"),CampaignManager.Instance.rollPoint.base_id,dataTemp.item_num)
            NoticeManager.Instance:FloatTipsByString(msg)
        else
            msg = string.format(TI18N("恭喜你到达终点，获得{item_2, %d, 0, %d}，奖励已经重置可以再次开始"),CampaignManager.Instance.rollPoint.base_id,dataTemp.item_num)
            NoticeManager.Instance:FloatTipsByString(msg)
        end
        self:UpdatePanel()

        local msgData = MessageParser.GetMsgData(msg)
        local chatData = ChatData.New()
        -- chatData:Update(RoleManager.Instance.RoleData)
        chatData.msgData = msgData
        chatData.channel = MsgEumn.ChatChannel.System
        chatData.showType = MsgEumn.ChatShowType.System
        chatData.prefix = MsgEumn.ChatChannel.System
        ChatManager.Instance.model:ShowMsg(chatData)
        return
    end
    local scale = 1.2 + (math.sin(math.pi / 3.5 * self.soulImageCounter) / 6)
    self.soulImageCounter = self.soulImageCounter + 1
    curGrid.item.localScale = Vector3(scale, scale, 1)
end

function MysticalEggPanel:OnInitCompleted()
    -- local args = self.model.mainModel.openArgs
    -- BaseUtils.dump(args,"---------------------")
    -- if args ~= nil and #args == 2 and args[1] == 3 then
    --     self.lastSub = tonumber(args[2])
    -- end
    -- print(self.lastSub .. "MysticalEggPanel:EnableTab(sub)----------"..debug.traceback())
    -- self.lastSub = self.model.mainModel.currentSub
    -- self:ChangeTab(self.model.mainModel.currentSub)
    self:UpdatePanel()
end

function MysticalEggPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.mystical_eggs_info_update, self.mystical_eggs_info_update)
    EventMgr.Instance:RemoveListener(event_name.mystical_eggs_roll_update, self.mystical_eggs_roll_update)
    for k,v in pairs(self.imgLoader) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    if self.stepTimerId ~= 0 then
        LuaTimer.Delete(self.stepTimerId)
    end
    if self.soulImageTimerId ~= 0 then
        LuaTimer.Delete(self.soulImageTimerId)
    end
    if self.bev ~= nil then
        self.bev:DeleteMe()
    end
    for i,v in ipairs(self.rewardSlotList) do
        if v.effect ~= nil then
            v.effect:DeleteMe()
        end
        if v.slot ~= nil then
            v.slot:DeleteMe()
        end
    end
    self.transform = nil
    self.OnOpenEvent:RemoveAll()
    self:AssetClearAll()
end

function MysticalEggPanel:UpdatePanel()
    -- print("MysticalEggPanel:UpdatePanel()"..debug.traceback())
    self.isRunning = false
    self.eggsData = CampaignManager.Instance.campaign_eggs

    for i,v in ipairs(self.rewardSlotList) do
        local dataTemp = DataCampaignEggs.data_getRolled[i]
        if self.eggsData.rolled < dataTemp.need then
            v.slot:SetGrey(true)
            v.gettedImg:SetActive(false)
        else

            if self:isRewarsGetted(dataTemp.id) == false then
                v.slot:SetGrey(false)
                v.gettedImg:SetActive(false)
                if v.effect == nil then
                    local fun = function(effectView)
                        local effectObject = effectView.gameObject

                        effectObject.transform:SetParent(v.item)
                        effectObject.transform.localScale = Vector3(1, 1, 1)
                        effectObject.transform.localPosition = Vector3(-34, -26, -200)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                        effectObject:SetActive(true)
                    end
                    v.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
                else
                    v.effect.gameObject:SetActive(true)
                end
            else
                v.slot:SetGrey(true)
                v.gettedImg:SetActive(true)
                if v.effect ~= nil then
                    v.effect.gameObject:SetActive(false)
                end
            end
        end
        local rate = self.eggsData.rolled / dataTemp.need
        v.slider.value = rate
        v.timesText.text = string.format("<color='%s'>%d</color>/%d",ColorHelper.color[5],self.eggsData.rolled,dataTemp.need)
        v.descText.text = string.format(TI18N("%s次奖励"),dataTemp.need)
    end

    local baseidToNeed = {[29183] = {need = 1}}
    if self.eggsData.can_roll == 15 then
        baseidToNeed = {}
    end
    self.getButton:Layout(baseidToNeed, function ()
        self:OnclickRollButton()
    end)

    self:updateGrids()
end
function MysticalEggPanel:isRewarsGetted(id)
    for i,v in ipairs(self.eggsData.rewarded) do
        if v.id == id then
            return true
        end
    end
    return false
end

function MysticalEggPanel:updateGrids()
    self.eggsData = CampaignManager.Instance.campaign_eggs
    self.selectIndex = self.eggsData.location
    self.lastRunGrid = nil
    for i,v in ipairs(self.itemList) do
        if self:isGetted(i) == true then
            v.getedObj:SetActive(true)
            -- BaseUtils.SetGrey(v.cImg, true)
            v.cImg.color = Color.grey
        else
            v.getedObj:SetActive(false)
            -- BaseUtils.SetGrey(v.cImg, false)
            v.cImg.color = Color.white
        end
        v.selectObj:SetActive(false)
        if i == self.eggsData.location then
            v.getedObj:SetActive(true)
            v.selectObj:SetActive(true)
            self.lastRunGrid = v
            -- BaseUtils.SetGrey(v.cImg, true)
            v.cImg.color = Color.grey
        end
    end
    -- self.num = BackpackManager.Instance:GetItemCount(29183)
    -- if BaseUtils.isTheSameDay(self.eggsData.last_moved,BaseUtils.BASE_TIME) == false then
    --     --上次摇的时间跟当前不是同一天
    --     self.num = self.num + 1
    -- end
    self.timesCanUseText.text = string.format(TI18N("剩余次数：<color='%s'>%d</color>/15"),ColorHelper.color[1],(15 - self.eggsData.can_roll))
    if self.eggsData.can_roll == 15 then
        self.rollBtnText.text = TI18N("免 费")
        self.getButton:Set_btn_txt(TI18N("免 费"))
    else
        self.rollBtnText.text = TI18N("投 掷")
        self.getButton:Set_btn_txt(TI18N("投 掷"))
    end
    self.getButton:Set_btn_img("DefaultButton3")
    self.getButton:SetTextColor(ColorHelper.DefaultButton3)
    if self.eggsData.can_roll == 15 or BackpackManager.Instance:GetItemCount(29183) > 0 then
        self.redPointImgObj:SetActive(true)
    else
        self.redPointImgObj:SetActive(false)
    end
end

function MysticalEggPanel:isGetted(index)
    for i,v in ipairs(self.eggsData.footprints) do
        if v.fp == index then
            return true
        end
    end
    return false
end


