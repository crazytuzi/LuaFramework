BibleWelfarePanel = BibleWelfarePanel or BaseClass(BasePanel)

function BibleWelfarePanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.bible_welfare_panel, type = AssetType.Main}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.shop_textures, type = AssetType.Dep}
    }
    self.panelList = {}

    self.backpackItemChangeListener = function(items)
        local itemDic = BackpackManager.Instance.itemDic
        if self.usebackpackBaseId ~= nil then
            for _,v in pairs(self.model.levelupList) do
                if v ~= nil and v.base_id == self.usebackpackBaseId and self.usebackpackBaseId == self.model.theLastLevelGiftbaseId then
                    self.model:CheckForLevelGift()
                    self:UpdateLevelup()
                    self.usebackpackBaseId = nil
                    break
                end
            end
            self.usebackpackBaseId = nil
        end

        for _,v in pairs(items) do
            if v ~= nil then
                for _,v1 in pairs(self.model.levelupList) do
                    if v1 ~= nil and itemDic[v.id] ~= nil and itemDic[v.id].base_id == v1.base_id then
                        self.model:CheckForLevelGift()
                        self:UpdateLevelup()
                        return
                    end
                end
            end
        end
    end

    self.levelChangeListener = function()
        self.model:CheckForLevelGift()
        self:UpdateLevelup()
    end

    self.timerId = nil
    self.textList = nil

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackItemChangeListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)

    self.onlinerewardchange = function ()
        self:CheckRedPoint()
    end
    EventMgr.Instance:AddListener(event_name.onlinereward_change, self.onlinerewardchange)

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.status = {}
    self.slotList = {}

    self.sortFun = function (a,b)
        return a.index<b.index
    end
end

function BibleWelfarePanel:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemChangeListener)
end

function BibleWelfarePanel:InitPanel()
    --Log.Error("BibleWelfarePanel:InitPanel")
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_welfare_panel))
    self.gameObject.name = "WelfarePanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.tabContainer = self.transform:Find("WelfareListPanel")
    self.tabBtnTemplate = self.tabContainer:Find("TabItem").gameObject
    self.tabBtnTemplate:SetActive(false)

    self.tabObjList = {}
    self.tabImageList = {}
    self.tabTextList = {}
    self.panelObjList = {}
    self.panelList = {}
    self.redPointList = {}

-- <<<<<<< HEAD
--     local mainPanel = self.transform:Find("MainPanel")
--     self.mainPanel = mainPanel
--     for i=1,10 do
--     -- for k,v in pairs(model.bibleList) do
--         local v = model.bibleList[i]
-- =======
    self.mainPanel = self.transform:Find("MainPanel")

    local tableTemp = {}
    for k,v in pairs(model.bibleList) do
        table.insert(tableTemp,v)
    end
    -- BaseUtils.dump(tableTemp,"---------tableTemp")
    table.sort(tableTemp, function (a,b)
        return a.index<b.index
    end )
    -- BaseUtils.dump(tableTemp,"tableTemp")
    -- -- for i=1,10 do
    for i,v in ipairs(tableTemp) do
        i = v.key
-- >>>>>>> investment
        if v ~= nil then
            local obj = GameObject.Instantiate(self.tabBtnTemplate)
            obj:SetActive(true)
            obj.name = tostring(i)
            obj.transform:SetParent(self.tabContainer)
            obj.transform.localScale = Vector3.one
            self.tabObjList[i] = obj
            obj:GetComponent(Button).onClick:AddListener(function()
                self:ChangeTab(i)
            end)
            self.tabImageList[i] = obj:GetComponent(Image)

            local t = obj.transform
            self.tabTextList[i] = t:Find("Text"):GetComponent(Text)
            self.tabTextList[i].text = v.name
            self.redPointList[i] = t:Find("RedPoint").gameObject
            self.redPointList[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
            self.redPointList[i]:SetActive(false)
            if v.package == nil then
                t:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, tostring(v.icon))
            else
                t:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(v.package, tostring(v.icon))
            end
        end
    end

    self.panelObjList[1] = self.mainPanel:Find("DailyCheckin").gameObject
    self.panelObjList[2] = self.mainPanel:Find("SevendayCheck").gameObject
    self.panelObjList[3] = self.mainPanel:Find("LevelupPresents").gameObject
    self.panelObjList[7] = self.mainPanel:Find("CDKey").gameObject
    self.panelObjList[5] = self.mainPanel:Find("PackageExchange").gameObject
    -- self.panelObjList[8] = BibleOnlineRewardPanel.New(model,self.mainPanel.gameObject)

    self.dailyItemTemplate = self.mainPanel:Find("DailyCheckin/DaysPanel/Container/Item").gameObject
    self.dailyItemTemplate:SetActive(false)
    self.sevendayTemplate = self.mainPanel:Find("SevendayCheck/SevenDaysPanel/Container"):GetChild(0).gameObject
    self.sevendayTemplate:SetActive(false)

    self:InitCDKEY()

    for i=1,10 do
        if self.panelObjList[i] ~= nil then
            self.panelObjList[i]:SetActive(false)
        end
    end

    self.gameObject:SetActive(true)
    -- self:ChangeTab(model.currentSub)
    self:CheckRedPoint()
end

function BibleWelfarePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BibleWelfarePanel:OnOpen()
    self.tabObjList[5].gameObject:SetActive(FirstRechargeManager.Instance:isHadDoFirstRecharge2() ~= true)
    self.tabObjList[2].gameObject:SetActive(BibleManager.Instance.isShowSevenDay == true)
    self.tabObjList[3].gameObject:SetActive(#self.model.levelupShowData ~= 0)

    if self.tabObjList[8] ~= nil then
        local isNeedShow = false
        local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OnLine)
        for i,v in ipairs(dataItemList) do
            if v.status == 0 or v.status == 1 then
                isNeedShow = true
                break
            end
        end
        self.tabObjList[8].gameObject:SetActive(isNeedShow)
    end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackItemChangeListener)
    self:ChangeTab(self.model.currentSub)
end

function BibleWelfarePanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemChangeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.backpackItemChangeListener)
    if self.lastSub ~= nil then
        -- print(self.lastSub)
        self:EnableTab(self.lastSub, false)
        if self.panelObjList[self.lastSub] ~= nil then
            self.panelObjList[self.lastSub]:SetActive(false)
-- <<<<<<< HEAD
--         end
--     end
--     for k,v in pairs(self.panelList) do
--         if v ~= nil then
--             v:Hiden()
-- =======
        else
            local panel = self.panelList[self.lastSub]
            if panel ~= nil then
                panel:Hiden()
            end
        end
    end
    self.lastSub = nil
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function BibleWelfarePanel:__delete()
    BibleManager.Instance.on14100_callback = nil
    BibleManager.Instance.on14102_callback = nil

    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    if self.levelupItemGrid ~= nil then
        for k,_ in pairs(self.levelupItemGrid) do
            self.levelupItemGrid[k]:DeleteMe()
            self.levelupItemGrid[k] = nil
        end
        self.levelupItemGrid = nil
    end
    for k,v in pairs(self.panelList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.dailyGridLayout ~= nil then
        self.dailyGridLayout:DeleteMe()
        self.dailyGridLayout = nil
    end
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
    if self.levelupLayout ~= nil then
        self.levelupLayout:DeleteMe()
        self.levelupLayout = nil
    end
    if self.sevendayLayout ~= nil then
        self.sevendayLayout:DeleteMe()
        self.sevendayLayout = nil
    end
    if self.dailyEffect ~= nil then
        self.dailyEffect:DeleteMe()
        self.dailyEffect = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    self.OnOpenEvent:RemoveAll()
    EventMgr.Instance:RemoveListener(event_name.onlinereward_change, self.onlinerewardchange)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemChangeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)
end

function BibleWelfarePanel:ChangeTab(sub)
    for _,v in pairs(self.panelList) do
        if v ~= nil then
            v:Hiden()
        end
    end
    if sub == 5 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
        return
    elseif sub == 6 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1, 2})
        return
    end

    if self.lastSub ~= sub then
        if self.lastSub ~= nil then
            if self.panelObjList[self.lastSub] ~= nil then
                self.panelObjList[self.lastSub]:SetActive(false)
            else
                local panel = self.panelList[self.lastSub]
                print(panel)
                if panel ~= nil then
                    panel:Hiden()
                end
            end
            self:EnableTab(self.lastSub, false)
        end
        self:EnableTab(sub, true)
        self.lastSub = sub
        self.model.currentSub = sub

        if self.panelObjList[sub] ~= nil then
            self.panelObjList[sub]:SetActive(true)
        end
        if sub == 1 then
            if self.dailyGridLayout == nil then
                self:InitEveryday()
                BibleManager.Instance.on14102_callback = function ()
                    -- body
                    self:UpdateEveryday()
                end
            end
            self:UpdateEveryday()
            --self.model:GetDailyCheckData(function() LuaTimer.Add(120, function() self:UpdateEveryday() end) end)
        elseif sub == 2 then
            if self.sevendayLayout == nil then
                self:InitSevenday()
            end
			self:UpdateServenDay()
        elseif sub == 4 then
            if self.panelList[sub] == nil then
                self.panelList[sub] = BibleInvestPanel.New(self.model, self.mainPanel)
            end
            self.panelList[sub]:Show()
        elseif sub == 3 then
            self.model:CheckForLevelGift()
            if self.levelupLayout == nil then
                self:InitLevelup()
            end
            self:UpdateLevelup()
        elseif sub == 7 then
            self:UpdateCDKEY()
        elseif sub == 8 then
            local panel = self.panelList[sub]
            if panel == nil then
                panel = BibleOnlineRewardPanel.New(self.model,self.mainPanel.gameObject)
                self.panelList[sub] = panel
            end
            if panel ~= nil then
                panel:Show()
            end
        end
    end
end

function BibleWelfarePanel:EnableTab(sub, bool)
    if self.tabImageList[sub] == nil then
        return
    end
    if bool == true then
        self.tabImageList[sub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
        self.tabTextList[sub].color = ColorHelper.DefaultButton9
    else
        self.tabImageList[sub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        self.tabTextList[sub].color = ColorHelper.DefaultButton8
    end
end

function BibleWelfarePanel:InitEveryday()
    local panel = self.panelObjList[1].transform
    local dayRewardLength = DataCheckin.data_everyday_data_length
    local everyday_data = DataCheckin.data_everyday_data

    self.dailyGridLayout = nil
    local setting = {
        column = 5
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 100
        ,cellSizeY = 84
    }
    self.dailyContainer = panel:Find("DaysPanel/Container")
    self.dailyGridLayout = LuaGridLayout.New(self.dailyContainer, setting)
    self.dailyItemList = {}
    self.dailyCheckinTitleText = panel:Find("Title/Text"):GetComponent(Text)

    local obj = nil
    local data = nil
    for i=1,dayRewardLength do
        obj= GameObject.Instantiate(self.dailyItemTemplate)
        data = everyday_data[i]
        obj:SetActive(true)
        self.dailyGridLayout:AddCell(obj)
        obj.name = tostring(i)
        self.dailyItemList[i] = obj
        local t = obj.transform
        t:Find("Checked").gameObject:SetActive(false)
        local labelObj = t:Find("Label").gameObject
        -- labelObj:SetActive(false)
        local slot = ItemSlot.New()
        local itemdata = ItemData.New()
        local cell = DataItem.data_get[data.reward[1][1]]
        local labelMod5To2Obj = t:Find("LabelMod5To2").gameObject
        local I18NText = t:Find("LabelMod5To2/I18N_Text"):GetComponent(Text)
        itemdata:SetBase(cell)
        itemdata.quantity = data.reward[1][2]
        slot:SetAll(itemdata, {inbag = false, nobutton = true})
        table.insert(self.slotList, slot)
        NumberpadPanel.AddUIChild(t:Find("Slot").gameObject, slot.gameObject)
        if i % 5 == 2 then
            labelMod5To2Obj:SetActive(true)
            I18NText.text = string.format(TI18N("%s天"), tostring(i))
        else
            labelMod5To2Obj:SetActive(false)
        end

        if data.icon == 1 then
            labelObj:SetActive(true)
        else
            labelObj:SetActive(false)
        end
        local btn = t:GetComponent(Button)
        btn.onClick:AddListener(function()
            if IS_DEBUG == true then
                print("<color=#FF0000>================等待返回================</color>")
            end
            BibleManager.Instance:send14103(nil, function()
                local effect = btn.transform:Find("Effect")
                if effect ~= nil then
                    GameObject.DestroyImmediate(effect.gameObject)
                end
                self:UpdateEveryday()
            end)
        end)
        btn.enabled = false
        t:Find("Panel").gameObject:SetActive(false)
    end
end

function BibleWelfarePanel:InitSevenday()
    BibleManager.Instance.on14100_callback = function ()
        self:UpdateServenDay()
    end

    local panel = self.panelObjList[2].transform
    self.sevendayObjList = {nil, nil, nil, nil, nil, nil, nil}

    local layoutContainer = panel:Find("SevenDaysPanel/Container")
    self.sevendayLayout = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})

    for i=1,7 do
        local obj = GameObject.Instantiate(self.sevendayTemplate)
        obj:SetActive(true)
        obj.name = tostring(i)

        self.sevendayLayout:AddCell(obj)
        obj.transform:Find("DayNoImage/Text"):GetComponent(Text).text = string.format(TI18N("第%s天"),tostring(i))
        obj.transform:Find("Button/Text"):GetComponent(Text).text = TI18N("领 取")
        local itemDic = {
			index = i,
            thisObj = obj,
            btn=obj.transform:Find("Button"):GetComponent(Button),
			btnText = obj.transform:Find("Button/Text"):GetComponent(Text),
            rtObj = obj.transform:Find("ReceivedText").gameObject,
            descText = obj.transform:Find("DescText"):GetComponent(Text),
            riObj1 = obj.transform:Find("RewardItem").gameObject,
            riObj1Image = obj.transform:Find("RewardItem/ribg"),
            riObj2 = obj.transform:Find("RewardItem2").gameObject,
            riObj2Image = obj.transform:Find("RewardItem2/ribg"),
        }
        self.sevendayObjList[i] = itemDic

		self:InitSevendayByIndex(i,itemDic)

		itemDic.btn.onClick:AddListener(function ()
			--点击领取
			--print("七天福利，点击领取"..itemDic.thisObj.name)
            BibleManager.Instance:send14101(itemDic.index, function()
                if self.dailyEffect ~= nil then
                    self.dailyEffect:DeleteMe()
                    self.dailyEffect = nil
                end
            end)
		end)
    end

    -- self:UpdateServenDay()
end

function BibleWelfarePanel:InitSevendayByIndex(index,itemDic)
	local dataDay = DataCheckin.data_get_checkin_data[index]
	itemDic.descText.text = dataDay.desc;
	itemDic.btn.gameObject:SetActive(false)
	itemDic.rtObj:SetActive(false)
	local rewardData = BibleManager.ParaseReward(dataDay.reward)
	--Log.Error(#rewardData.." ----------InitSevendayByIndex")
	for i,v in ipairs(rewardData) do
		local img = nil
		if i == 1 then
			img = itemDic.riObj1Image
		else --if i == 2 then
			img = itemDic.riObj2Image
		end
        local slot = ItemSlot.New()
        local itemdata = ItemData.New()
        local cell = v.dataItem
        itemdata:SetBase(cell)
        slot:SetAll(itemdata, {inbag = false, nobutton = true})
        NumberpadPanel.AddUIChild(img.gameObject, slot.gameObject)
		slot:SetNum(v.count)
	end
end

function BibleWelfarePanel:InitLevelup()
    local panel = self.panelObjList[3].transform
    self.levelupItemGrid = {nil, nil, nil}
    self.levelupItemList = {nil, nil, nil}
    self.levelupItemRect = {}
    self.levelupItemTitle = {}
    self.levelupItemTitle2 = {}
    self.levelupItemTitle2TimeText = {}
    self.levelupItemTitle2OriginText = {}
    self.levelupItemTitle2NowText = {}
    self.levelupItemTitle2OriginImage = {}
    self.levelupItemTitle2NowImage = {}
    self.levelupItemTitle2Text = {}
    self.levelupItemTitleText = {}
    self.levelupItemTitleButtonText = {}
    self.levelupItemTitleButtonImage = {}
    self.levelupItemTitleButton = {}
    self.levelupItemTitle2Button = {}
    self.levelupItemIconList = {nil, nil, nil}
    self.slotList = {}
    self.levelContainer = panel:Find("Panel/Container")
    local levelupTemplate = panel:Find("Item").gameObject
    levelupTemplate:SetActive(false)
    levelupTemplate.transform:Find("Title2/LimitBg/Clock"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "weekly")

    if self.levelupLayout == nil then
        self.levelupLayout = LuaBoxLayout.New(self.levelContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 5})
    end

    self.model:CheckForLevelGift()

    local size = DataAgenda.data_lev_gift_length / 5
    for i=1,size do
        local obj = GameObject.Instantiate(levelupTemplate)
        obj.transform:Find("Title/Button").gameObject:SetActive(false)
        obj.name = tostring(i)
        self.levelupItemList[i] = obj
        self.levelupLayout:AddCell(obj)
        self.levelupItemGrid[i] = LuaGridLayout.New(obj.transform:Find("Grid").gameObject, {cspacing = 15, rspacing = 5, column = 5, cellSizeX = 60, cellSizeY = 60})
        self.levelupItemIconList[i] = {}
        self.slotList[i] = {}
        local t = obj.transform
        local iconTemplate = t:Find("Grid/Icon").gameObject
        self.levelupItemRect[i] = t:GetComponent(RectTransform)
        self.levelupItemTitle[i] = t:Find("Title").gameObject
        self.levelupItemTitle2[i] = t:Find("Title2").gameObject
        self.levelupItemTitleText[i] = t:Find("Title/Text"):GetComponent(Text)
        self.levelupItemTitle2Text[i] = t:Find("Title2/Image/Text"):GetComponent(Text)
        self.levelupItemTitleButton[i] = t:Find("Title/Button"):GetComponent(Button)
        self.levelupItemTitleButtonText[i] = t:Find("Title/Button/Text"):GetComponent(Text)
        self.levelupItemTitleButtonImage[i] = t:Find("Title/Button"):GetComponent(Image)
        self.levelupItemTitle2Button[i] = t:Find("Title2/Button"):GetComponent(Button)
        self.levelupItemTitle2OriginText[i] = t:Find("Title2/Price/Origin/Text"):GetComponent(Text)
        self.levelupItemTitle2OriginImage[i] = t:Find("Title2/Price/Origin/Image"):GetComponent(Image)
        self.levelupItemTitle2NowText[i] = t:Find("Title2/Price/Now/Text"):GetComponent(Text)
        self.levelupItemTitle2NowImage[i] = t:Find("Title2/Price/Now/Image"):GetComponent(Image)
        self.levelupItemTitle2TimeText[i] = t:Find("Title2/LimitBg/Text"):GetComponent(Text)

        for j=1,10 do
            local icon = GameObject.Instantiate(iconTemplate)
            icon.name = tostring(j)
            self.levelupItemIconList[i][j] = icon
            self.slotList[i][j] = nil
            self.levelupItemGrid[i]:AddCell(icon)
        end
        obj:SetActive(false)
    end
end

function BibleWelfarePanel:InitExchange()
    local panel = self.panelObjList[5].transform
end

function BibleWelfarePanel:UpdateEveryday()
    BibleManager.Instance.redPointDic[1][1] = false
    self:CheckRedPoint()

    local daysInMonth = {
        [false] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
        , [true] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    }
    local currentYear = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
    local currentMonth = tonumber(os.date("%m", currentTime))
    local isLeap = false
    local dailyCheckData = self.model.dailyCheckData

    -- BaseUtils.dump(dailyCheckData, "签到情况")
    if currentYear % 100 == 0 then
        isLeap = (currentYear % 400 == 0)
    else
        isLeap = (currentYear % 4 == 0)
    end

    local days = daysInMonth[isLeap][currentMonth]
    local dayRewardLength = DataCheckin.data_everyday_data_length

    self.dailyCheckinTitleText.text = string.format(TI18N("本月累计签到:<color=#FFDC5F>%s天</color>"), tostring(dailyCheckData.signed))

    for i=1,dayRewardLength do
        if i > days then
            self.dailyItemList[i]:SetActive(false)
        else
            self.dailyItemList[i]:SetActive(true)
        end
        self.dailyItemList[i]:GetComponent(Button).enabled = false
        self.dailyItemList[i].transform:Find("Panel").gameObject:SetActive(false)
    end

    for i=1,dailyCheckData.signed do
        self.dailyItemList[i].transform:Find("Checked").gameObject:SetActive(true)
    end

    local lastDay = tonumber(os.date("%d", dailyCheckData.last_time))
    local lastMonth = tonumber(os.date("%m", dailyCheckData.last_time))
    local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))

    if dailyCheckData.signed == 0 or currentMonth ~= lastMonth then
        lastDay = -1
    end
    if currentDay > lastDay then
        self.dailyItemList[dailyCheckData.signed + 1]:GetComponent(Button).enabled = true
        self.dailyItemList[dailyCheckData.signed + 1].transform:Find("Panel").gameObject:SetActive(true)

        if self.dailyEffect == nil then
            self.dailyEffect = self.ShowEffect(20053, self.dailyItemList[dailyCheckData.signed + 1].transform, Vector3(1, 1, 1), Vector3(17,-67,-100))
        else
            self.dailyEffect.gameObject.transform:SetParent(self.dailyItemList[dailyCheckData.signed + 1].transform)
            self.dailyEffect.gameObject.transform.localScale = Vector3(1, 1, 1)
            self.dailyEffect.gameObject.transform.localPosition = Vector3(17,-67,-100)
        end
    end

    self.dailyContainer:GetComponent(RectTransform).sizeDelta = Vector2(538, 89 * math.ceil(days / 5))
end

function BibleWelfarePanel:CheckNeedShowSevenDay()
    local isShow = true
    if #BibleManager.Instance.servenDayData.seven_day >=7 then
        isShow = false
        for i,v in ipairs(BibleManager.Instance.servenDayData.seven_day) do
            if v.rewarded == 0 then
                isShow = true
                break
            end
        end
    end
    return isShow
end

function BibleWelfarePanel:UpdateServenDay()
    BibleManager.Instance.redPointDic[1][2] = false
	if BibleManager.Instance.servenDayData ~= nil then
        -- if self:CheckNeedShowSevenDay() == false then
        --     -- self.tabObjList[2]:SetActive(false)
        --     -- self.panelObjList[2]:SetActive(false)
        --     self:CheckRedPoint()
        --     return
        -- end
		for i,v in ipairs(BibleManager.Instance.servenDayData.seven_day) do
			local itemDic = self.sevendayObjList[i]
			if v.rewarded == 0 then
				itemDic.btn.gameObject:SetActive(true)
				itemDic.rtObj:SetActive(false)
			elseif v.rewarded == 1 then
				itemDic.btn.gameObject:SetActive(false)
				itemDic.rtObj:SetActive(true)
			end
		end
		local loginDays = #BibleManager.Instance.servenDayData.seven_day
		for i,v in ipairs(self.sevendayObjList) do
			if i>loginDays then
				--v.btn.interactable = false;
				v.btn.gameObject:SetActive(false)
				v.rtObj:SetActive(false)
			end
		end
		self:CheckRedPoint()
	end
end

function BibleWelfarePanel:CheckRedPoint()
    -- body
	-- for i = 1,#self.redPointList do
    for i,v in pairs(self.redPointList) do
		self.redPointList[i]:SetActive(false)
	end
	for k1,v1 in pairs(BibleManager.Instance.redPointDic[1]) do
        self.redPointList[k1]:SetActive(v1 == true)
	end
    self.model.bibleWin:CheckRedPoint()
end

function BibleWelfarePanel.ShowEffect(id, transform, scale, position, time)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function BibleWelfarePanel:InitCDKEY()
    local panel = self.panelObjList[7].transform
    self.InputFieldDesc = panel:Find("InputField/Placeholder"):GetComponent(Text)
    self.InputFieldDesc.text = TI18N("输入激活码...")
    self.InputFieldCDKey = panel:Find("InputField"):GetComponent(InputField)
    self.btnCDKey = panel:Find("Button"):GetComponent(Button)
    self.btnCDKey.onClick:AddListener(function()
        self:GetRewardByCDKey()
    end)

end

function BibleWelfarePanel:GetRewardByCDKey()
    if self.InputFieldCDKey.text ~= "" then
        BibleManager.Instance:send9906(self.InputFieldCDKey.text)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请先输入CD Key,再点领取"))
    end
end

function BibleWelfarePanel:UpdateCDKEY()
    -- body
    self.InputFieldCDKey.text = ""
end

function BibleWelfarePanel:CalculateTime()
    if self.textList == nil then
        self.textList = {}
    end

    local model = self.model
    local myLevel = RoleManager.Instance.RoleData.lev
    local size = DataAgenda.data_lev_gift_length / 5

    for i,v in ipairs(model.levelupShowData) do
        if v.limitTime ~= nil then
            if BaseUtils.BASE_TIME < v.limitTime then
                local h = math.floor((v.limitTime - BaseUtils.BASE_TIME) / 3600)
                local msg = os.date(string.format("%s:%%M:%%S", tostring(h)), v.limitTime - BaseUtils.BASE_TIME)
                self.levelupItemTitle2TimeText[i].text = TI18N("限时优惠 ")..msg
            elseif BaseUtils.BASE_TIME == v.limitTime then
                self.model:CheckForLevelGift()
                self:UpdateLevelup()
                return
            end
        end
    end
end

function BibleWelfarePanel:UpdateLevelup()
    local model = self.model
    local bottom = 0
    BibleManager.Instance.redPointDic[1][3] = false
    BibleManager.Instance:CheckMainUIIconRedPoint()
    self:CheckRedPoint()

    if self.levelupItemList == nil then
        self:InitLevelup()
    end

    for i,v in ipairs(self.levelupItemList) do
        self:SetLevelItem(v, model.levelupShowData[i], i)
        if model.levelupShowData[i] ~= nil then
            self.levelupItemRect[i].anchoredPosition = Vector2(0, -bottom)
            bottom = bottom + self.levelupItemRect[i].sizeDelta.y
        end
    end
    self.levelContainer:GetComponent(RectTransform).sizeDelta = Vector2(582, bottom)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:CalculateTime() end)
end

function BibleWelfarePanel:SetLevelItem(obj, data, i)
    if data == nil then
        obj:SetActive(false)
        return
    else
        obj:SetActive(true)
    end

    local lev = RoleManager.Instance.RoleData.lev

    if data.limitTime == nil then
        self.levelupItemTitle[i]:SetActive(true)
        self.levelupItemTitle2[i]:SetActive(false)
        self.levelupItemTitleText[i].text = data.lev..TI18N("级大礼包")
        self.levelupItemTitleButton[i].gameObject:SetActive(true)
        if lev >= data.lev then
            self.levelupItemTitleButtonText[i].text = TI18N("领取奖励")
            self.levelupItemTitleButtonImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.levelupItemTitleButton[i].enabled = true
            self.levelupItemTitleButton[i].onClick:RemoveAllListeners()
            self.levelupItemTitleButton[i].onClick:AddListener(function()
                local itemDic = BackpackManager.Instance.itemDic
                self.usebackpackId = nil
                self.usebackpackBaseId = nil
                for id,item in pairs(itemDic) do
                    if item.base_id == data.base_id then
                        self.usebackpackId = id
                        self.usebackpackBaseId = data.base_id
                        break
                    end
                end
                if self.usebackpackId ~= nil then
                    BackpackManager.Instance:Send10315(self.usebackpackId, 1)
                else
                    if data.lev > 10 then
                        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请先领取%s级礼包"), tostring(data.lev - 10)))
                    else
                        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("背包没有%s级礼包"), tostring(data.lev)))
                    end
                end
            end)
        else
            self.levelupItemTitleButtonText[i].text = data.lev..TI18N("级领取")
            self.levelupItemTitleButtonImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.levelupItemTitleButton[i].enabled = false
        end
    else
        self.levelupItemTitle[i]:SetActive(false)
        self.levelupItemTitle2[i]:SetActive(true)
        self.levelupItemTitle2OriginImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.worth[1][1])
        self.levelupItemTitle2OriginText[i].text = tostring(data.worth[1][2])
        self.levelupItemTitle2NowImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.loss[1][1])
        self.levelupItemTitle2NowText[i].text = tostring(data.loss[1][2])
        self.levelupItemTitle2Text[i].text = data.lev..TI18N("级限时大礼包")

        self.levelupItemTitle2Button[i].gameObject:SetActive(true)
        self.levelupItemTitle2Button[i].onClick:RemoveAllListeners()
        self.levelupItemTitle2Button[i].onClick:AddListener(function ()
            BibleManager.Instance:send12009(data.idx)
        end)
    end

    for j=1,10 do
        if data.itemList[j] ~= nil then
            self.levelupItemIconList[i][j]:SetActive(true)
            if self.slotList[i][j] == nil then
                self.slotList[i][j] = ItemSlot.New()
                NumberpadPanel.AddUIChild(self.levelupItemIconList[i][j], self.slotList[i][j].gameObject)
            end

            local cell = DataItem.data_get[data.itemList[j][1]]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            itemdata.quantity = data.itemList[j][2]
            self.slotList[i][j]:SetAll(itemdata, {inbag = false, nobutton = true})
        else
            self.levelupItemIconList[i][j]:SetActive(false)
        end
    end

    self.levelupItemRect[i].sizeDelta = Vector2(542, 50 + 66 * math.ceil(#data.itemList / 5))
end
