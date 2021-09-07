-- @author 黄耀聪
-- @date 2016年8月9日

NationalDayLotary = NationalDayLotary or BaseClass(BasePanel)

function NationalDayLotary:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "NationalDayLotary"
    self.mgr = OpenBetaManager.Instance

    self.turnType = 2

    self.campaignData_cli = DataCampaign.data_list[311]
    self.resList = {
        {file = AssetConfig.open_beta_lotary, type = AssetType.Main},
        {file = AssetConfig.open_beta_textures, type = AssetType.Dep},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
        {file = AssetConfig.bigatlas_open_beta_bg3, type = AssetType.Main},
    }
    self.timeFormatString5 = TI18N("活动已结束")
    self.leftString = TI18N("已抽奖:<color='#00ff00'>%s</color>")
    self.timeFormat1 = TI18N("%s小时%s分%s秒")
    self.timeFormat2 = TI18N("%s分%s秒")
    self.timeFormat3 = TI18N("%s秒")
    self.timeListener = function() self:OnTimeListener() end
    self.onTurnResultListener = function(type, id) self:GetIndex(type, id) end
    self.onTurnTimeListener = function() self:SetLeftTime() end
    self.costListener = function() self:SetCost() end
    self.unfrozenListener = function() self:OnUnFrozen() end

    self.slowDownList = {}

    self.itemList = {}
    self.btnList = {}
    self.iconLoaders = {}
    self.iconList = {}
    self.rewardList = {}
    self.imgLoader = nil
    self.num = 8
    self.radius = 110
    self.count = 0
    self.step = 0
    self.slotList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NationalDayLotary:__delete()
    self.OnHideEvent:Fire()
    if self.iconList ~= nil then
        for i,v in ipairs(self.iconList) do
            v.sprite = nil
        end
        self.iconList = nil
    end
    if self.costImage ~= nil then
        self.costImage.sprite = nil
        self.costImage = nil
    end
    if self.slotList ~= nil then
       for _,v in pairs(self.slotList) do
           v:DeleteMe()
       end
    end
    self.slotList = nil
    if self.timeImage ~= nil then
        self.timeImage.sprite = nil
        self.timeImage = nil
    end
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                if v.grid ~= nil then
                    v.grid:DeleteMe()
                end
                if v.layout ~= nil then
                    v.layout:DeleteMe()
                end
            end
        end
        self.rewardList = nil
    end
     if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if  self.iconLoaders ~= nil then
        for _,imgLoader in pairs(self.iconLoaders) do
            if imgLoader ~= nil then
             imgLoader:DeleteMe()
             imgLoader = nil
            end
        end
        self.iconLoaders = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
        self.effect1 = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    if self.frozen1 ~= nil then
        self.frozen1:DeleteMe()
        self.frozen1 = nil
    end
    if self.multiItemPanel ~= nil then
        self.multiItemPanel:DeleteMe()
        self.multiItemPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NationalDayLotary:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_beta_lotary))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_open_beta_bg3)))

    self.turnplate = t:Find("Turnplate")
    local itemContainer = t:Find("Container")
    self.timeText = t:Find("Time/Clock/Bg/Text"):GetComponent(Text)
    self.timeImage = t:Find("Time/Clock/Image"):GetComponent(Image)
    self.pointer = t:Find("Pointer")
    self.leftText = t:Find("Left"):GetComponent(Text)
    self.costImage = t:Find("Cost/Icon"):GetComponent(Image)
    self.costText = t:Find("Cost/Icon/Text"):GetComponent(Text)
    self.costBtn = t:Find("Cost"):GetComponent(Button)
    self.costRect = t:Find("Cost"):GetComponent(RectTransform)
    self.container = t:Find("Bg/Scroll/Container")
    self.cloner = t:Find("Bg/Scroll/Cloner").gameObject
    self.itemCloner = t:Find("Bg/Scroll/Item").gameObject
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.rewardBtn = t:Find("Reward"):GetComponent(Button)

    -- self.pointerBtn = self.pointer.gameObject:AddComponent(Button)

    for i=1,itemContainer.childCount do
        -- self.slotList[i] = ItemSlot.New()
        self.itemList[i] = itemContainer:GetChild(i - 1)
        self.iconList[i] = self.itemList[i]:Find("Icon"):GetComponent(Image)
        self.btnList[i] = self.itemList[i]:GetComponent(Button)
        -- self.iconList[i].gameObject:SetActive(false)
        -- NumberpadPanel.AddUIChild(self.itemList[i].gameObject, self.slotList[i].gameObject)
    end

    -- self.pointerBtn.onClick:AddListener(function() self:DoSlowDown(BaseUtils.BASE_TIME % 8 + 1) end)
    self:SetItemsPosition(math.pi / 8)
    self.frozen = FrozenButton.New(t:Find("Button").gameObject, {timeout = 10})
    self.frozen1 = FrozenButton.New(t:Find("Button1").gameObject, {timeout = 10})
    self.buttonImage = t:Find("Button"):GetComponent(Image)
    self.buttonImage1 = t:Find("Button1"):GetComponent(Image)
    self.turnBtn = t:Find("Button"):GetComponent(Button)
    self.turnBtn1 = t:Find("Button1"):GetComponent(Button)
    self.turnBtn.onClick:AddListener(function() self:OnTurn() end)
    self.turnBtn1.onClick:AddListener(function() self:OnTurn1() end)
    self.rewardBtn.onClick:AddListener(function() self:OnRewardPreview() end)

    self.costText.fontSize = 16

    self.cloner:SetActive(false)
    self.itemCloner:SetActive(false)
    self:ShowEffect1()
    self:ShowEffect2()
end

function NationalDayLotary:OnTurn()
    if self.mgr.turnState[self.turnType] == TurnState.State.Active then
        local costData = DataCampTurn.data_turnplate[self.turnType].cost[1]
        if costData == nil then
            costData = {90002, 0}
        end
        local inbagNum = BackpackManager.Instance:GetItemCount(costData[1])
        if costData[2] <= inbagNum then
            self:Go()
            self.frozen:OnClick()
            self.frozen1:OnClick()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有<color='#ffff00'>抽奖券</color>，快去获取吧{face_1,56}"))
            TipsManager.Instance:ShowItem({gameObject = self.turnBtn.gameObject, itemData = DataItem.data_get[costData[1]], {inbag = false, nobutton = true}})
        end
    elseif self.mgr.turnState[self.turnType] == TurnState.State.NoBegin then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，请耐心等待"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已经结束，感谢您的参与"))
    end
end

function NationalDayLotary:OnTurn1()
    if self.mgr.turnState[self.turnType] == TurnState.State.Active then
        local costData = DataCampTurn.data_turnplate[self.turnType].cost[1]
        if costData == nil then
            costData = {90002, 0}
        end
        local inbagNum = BackpackManager.Instance:GetItemCount(costData[1])
        if inbagNum < 10 then
            NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>抽奖券</color>不足<color='#ffff00'>10</color>张，快去获取吧{face_1,56}"))
        elseif costData[2] <= inbagNum then
            self:Go1()
            self.frozen:OnClick()
            self.frozen1:OnClick()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有<color='#ffff00'>抽奖券</color>，快去获取吧{face_1,56}"))
            TipsManager.Instance:ShowItem({gameObject = self.turnBtn.gameObject, itemData = DataItem.data_get[costData[1]], {inbag = false, nobutton = true}})
        end
    elseif self.mgr.turnState[self.turnType] == TurnState.State.NoBegin then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，请耐心等待"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已经结束，感谢您的参与"))
    end
end

function NationalDayLotary:Go1()
    self.isRotating = true
    self.doSlowDown = false
    -- self.step = (BaseUtils.BASE_TIME % 10 + 1) * 2
    self.step = 15

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 10, function() self:DoRotation() end)
    end

    self.mgr:send14041(self.turnType, 10)
    self:ShowEffect()
end

function NationalDayLotary:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NationalDayLotary:OnOpen()
    self:RemoveListeners()
    self.mgr.onTurnResult:AddListener(self.onTurnResultListener)
    self.mgr.onTurnTime:AddListener(self.onTurnTimeListener)
    self.mgr.onTickTime:AddListener(self.timeListener)
    self.mgr.onUnFrozen:AddListener(self.unfrozenListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.costListener)

    self:GetItems()
    self:ReloadReward()
    self:SetLeftTime()
    self:SetCost()
    self:SetTime()

    if self.targetTheta ~= nil then
        self.count = self.targetTheta % 360
        self:SetTurnplatePosition(self.count + 22.5)   -- 角度制
        self:SetItemsPosition(self.count * math.pi / 180)   -- 弧度制
        self.targetTheta = nil
    -- else
    --     self.count = 0
    --     self:SetTurnplatePosition(self.count + 22.5)   -- 角度制
    --     self:SetItemsPosition(self.count * math.pi / 180)   -- 弧度制
    end

    if self.effect ~= nil then
        self.effect.gameObject:SetActive(false)
    end
end

function NationalDayLotary:OnHide()
    self:RemoveListeners()
    if self.isRotating then
        self.mgr:send14040()
        self.isRotating = false
        self.frozen:Release()
    end
end

function NationalDayLotary:RemoveListeners()
    self.mgr.onTurnResult:RemoveListener(self.onTurnResultListener)
    self.mgr.onTurnTime:RemoveListener(self.onTurnTimeListener)
    self.mgr.onTickTime:RemoveListener(self.timeListener)
    self.mgr.onUnFrozen:RemoveListener(self.unfrozenListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.costListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function NationalDayLotary:SetItemsPosition(theta)
    local sin = math.sin
    local cos = math.cos
    local pi = math.pi
    theta = - theta
    for i,v in ipairs(self.itemList) do
        v.anchoredPosition = Vector2(self.radius * cos(2 * pi * (i - 1) / self.num + theta), self.radius * sin(2 * pi * (i - 1) / self.num + theta))
    end
end

function NationalDayLotary:SetTurnplatePosition(theta)
    theta = - theta
    self.turnplate.rotation = Quaternion.Euler(0, 0, theta)
end

function NationalDayLotary:DoRotation()
    -- self:SetPointerPos(self.step)
    if self.doSlowDown then
        if self.count < self.targetTheta then
            self.count = self.count + self.step * (self.targetTheta - self.count) * 1.2 / self.distance + 0.2
        end
    else
        self.count = (self.count + self.step) % 360
    end
    self:SetTurnplatePosition(self.count + 22.5)   -- 角度制
    self:SetItemsPosition(self.count * math.pi / 180)   -- 弧度制

    if self.targetTheta ~= nil and self.targetTheta ~= 0 and self.count >= self.targetTheta then
        LuaTimer.Delete(self.timerId)
        self.isRotating = false
        self.timerId = nil
        self.mgr:send14040()
        LuaTimer.Add(500, function()
            if self.effect ~= nil then
                self.effect.gameObject:SetActive(false)
            end
        end)
    end
end

function NationalDayLotary:Go()
    self.isRotating = true
    self.doSlowDown = false
    -- self.step = (BaseUtils.BASE_TIME % 10 + 1) * 2
    self.step = 15

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 10, function() self:DoRotation() end)
    end

    self.mgr:send14039(self.turnType)
    self:ShowEffect()
end

function NationalDayLotary:OnTimeListener()
    self:SetTime()
end

function NationalDayLotary:SetPointerPos(theta)
    self.pointer:Rotate(Vector3(0, 0, theta))
end

function NationalDayLotary:ReloadReward()
    local data = {}
    for i,v in ipairs(self.totalTurnItems) do
        if v.reward_type == 1 then
            table.insert(data, {title = string.format(TI18N("累计抽奖<color=#00ff00>%s次</color>可额外获得："), tostring(v.num)), item_list = v.item_list})
        elseif v.reward_type == 2 then
            table.insert(data, {title = string.format(TI18N("每抽奖<color=#00ff00>%s次</color>可额外获得："), tostring(v.num)), item_list = v.item_list})
        end
    end
    local gridSetting = {
        column = 2,
        cellSizeX = 100,
        cellSizeY = 100,
    }
    local boxSetting = {
        axis = BoxLayoutAxis.Y,
        cspaing = 0.
    }
    local slotSetting = {
        inbag = false,
        -- noshowTag = (showSell ~= true),
        nobutton = true,
        -- white_list= {{id = TipsEumn.ButtonType.InStore,show = true}},
        -- storageType = self.storageType
    }
    self.layout:ReSet()
    for i,v in ipairs(data) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.cloner)
            tab.obj.name = tostring(i)
            tab.trans = tab.obj.transform
            tab.titleText = tab.trans:Find("Title"):GetComponent(Text)
            tab.grid = LuaGridLayout.New(tab.trans:Find("Grid"), gridSetting)
            tab.layout = LuaBoxLayout.New(tab.trans, boxSetting)
            tab.itemlist = {}
            self.rewardList[i] = tab
        end
        tab.layout:ReSet()
        tab.grid:ReSet()
        tab.titleText.text = v.title
        tab.titleText.gameObject.transform.sizeDelta = Vector2(208, math.ceil(tab.titleText.preferredHeight) + 3)
        tab.layout:AddCell(tab.titleText.gameObject)
        for j,item in ipairs(v.item_list) do
            local tab1 = tab.itemlist[j]
            if tab1 == nil then
                tab1 = {}
                tab1.obj = GameObject.Instantiate(self.itemCloner)
                tab1.obj.name = tostring(j)
                tab1.trans = tab1.obj.transform
                tab1.slot = ItemSlot.New()
                table.insert(self.slotList, tab1.slot)
                tab1.slot.gameObject.transform:SetParent(tab1.trans)
                tab1.slot.gameObject.transform.localScale = Vector3.one
                tab1.slot.gameObject.transform.anchoredPosition = Vector2(0,10)
                tab1.slot.gameObject.transform.sizeDelta = Vector2(60, 60)
                tab1.nameText = tab1.trans:Find("Name"):GetComponent(Text)
                tab1.data = ItemData.New()
                tab.itemlist[j] = tab1
            end
            tab1.data:SetBase(DataItem.data_get[item[1]])
            tab1.slot:SetAll(tab1.data, slotSetting)
            tab1.slot:SetNum(item[2])
            tab1.nameText.text = tab1.data.name
            tab.grid:AddCell(tab1.obj)
        end
        for j=#v.item_list + 1, #tab.itemlist do
            tab.itemlist[j].obj:SetActive(false)
        end
        tab.layout:AddCell(tab.grid.panel.gameObject)
        self.layout:AddCell(tab.obj)
    end
    for i=#data + 1, #self.rewardList do
        self.rewardList[i].obj:SetActive(false)
    end

    for i,v in ipairs(self.turnItems) do
        if self.iconLoaders[i] == nil then
           local go = self.itemList[i]:Find("Icon").gameObject
           self.iconLoaders[i] = SingleIconLoader.New(go)
        end
        self.iconLoaders[i]:SetSprite(SingleIconType.Item, DataItem.data_get[v.base_id].icon)
        self.btnList[i].onClick:RemoveAllListeners()
        self.btnList[i].onClick:AddListener(function()
                TipsManager.Instance:ShowItem({gameObject = self.itemList[i].gameObject, itemData = DataItem.data_get[v.base_id], extra = {nobutton = true, inbag = false}})
            end)
    end
end

function NationalDayLotary:DoSlowDown(index)
    index = index - 3
    if self.timerId ~= nil then
        self.doSlowDown = true
        if index > 4 then
            self.targetTheta = 45 * index + 360 * 2 - 15 + Random.Range(0,30)
        else
            self.targetTheta = 45 * index + 360 * 3 - 15 + Random.Range(0,30)
        end
        self.distance = self.targetTheta - self.count
    end
end

function NationalDayLotary:GetItems()
    local lev = RoleManager.Instance.RoleData.lev
    self.turnItems = {}
    self.totalTurnItems = {}
    self.typeToIndex = {}
    self.items = {}
    local count = 1
    for i,v in ipairs(DataCampTurn.data_item) do
        if v.type == self.turnType and lev >= v.lev_min and lev <= v.lev_max then
            table.insert(self.items, {base_id = v.item_id})
            if self.typeToIndex[v.type_item_id] == nil then
                self.typeToIndex[v.type_item_id] = count
                count = count + 1
                table.insert(self.turnItems, {base_id = v.type_item_id})
            end
        end
    end
    for i,v in ipairs(DataCampTurn.data_total_reward) do
        if v.type == self.turnType then
            table.insert(self.totalTurnItems, v)
        end
    end
    -- table.sort(self.totalTurnItems, function(a,b) return a.num < b.num end)
end

function NationalDayLotary:GetIndex(type, id)
    if type == self.turnType then
        if id > 0 then
            -- LuaTimer.Add(1000, function() self:DoSlowDown(self.typeToIndex[DataCampTurn.data_item[id].type_item_id]) end)

            for _,v in ipairs(DataCampTurn.data_item) do
                if v.id == id then
					LuaTimer.Add(1000, function() self:DoSlowDown(self.typeToIndex[v.type_item_id]) end)
                    break
                end
            end
        else
            self:DoSlowDown(BaseUtils.BASE_TIME % 8 + 1)
        end
    end
end

function NationalDayLotary:SetLeftTime()
    local num = 0
    if self.model.turnplateList[self.turnType] ~= nil then
        num = self.model.turnplateList[self.turnType].num
    end
    self.leftText.text = string.format(self.leftString, tostring(num))
end

function NationalDayLotary:SetCost()
    local costData = DataCampTurn.data_turnplate[self.turnType].cost[1]
    if costData == nil then
        costData = {90002, 67}
    end
    local baseData = DataItem.data_get[costData[1]]
    local inbagNum = BackpackManager.Instance:GetItemCount(costData[1])

    if self.imgLoader == nil then
        local go = self.gameObject.transform:Find("Cost/Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, baseData.icon)

    if inbagNum >= costData[2] then
        self.costText.text = string.format("%s<color='#00ff00'>%s</color>/%s", ColorHelper.color_item_name(baseData.quality, baseData.name), tostring(inbagNum), tostring(costData[2]))
    else
        self.costText.text = string.format("%s<color='#ff0000'>%s</color>/%s", ColorHelper.color_item_name(baseData.quality, baseData.name), tostring(inbagNum), tostring(costData[2]))
    end
    self.costText.transform.sizeDelta = Vector2(math.ceil(self.costText.preferredWidth) + 10, 30)
    self.costRect.sizeDelta = Vector2(self.costText.transform.anchoredPosition.x + self.costText.transform.sizeDelta.x, 30)
    self.costBtn.onClick:RemoveAllListeners()
    self.costBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.costBtn.gameObject, itemData = baseData, {inbag = false, nobutton = true}}) end)
end

function NationalDayLotary:SetTime()
    self.times_count = ((self.times_count or 0) + 1) % 3
    if self.times_count == 1 then
        self.mgr:DoCheckOpen()
    end

    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))
    local v = DataCampTurn.data_turnplate[self.turnType]
    local end_time_cli = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2],day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}
    if self.mgr.turnState[self.turnType] == TurnState.State.NoBegin then
        self.timeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_beta_textures, "I18N_ToBegin")
        local beginTime = tonumber(os.time{year = y, month = m, day = d, hour = v.day_time[1][1], min = v.day_time[1][2], sec = v.day_time[1][3]})
        if v.day_time[1][3] == 0 then
            self.timeText.text = string.format(TI18N("%s开启"), tostring(os.date("%H:%M", beginTime)))
        else
            self.timeText.text = string.format(TI18N("%s开启"), tostring(os.date("%H:%M:%S", beginTime)))
        end

        BaseUtils.SetGrey(self.buttonImage, true)
        BaseUtils.SetGrey(self.buttonImage1, true)
        if self.effect1 ~= nil then
            self.effect1:DeleteMe()
            self.effect1 = nil
        end
        if self.effect2 ~= nil then
            self.effect2:DeleteMe()
            self.effect2 = nil
        end
    elseif self.mgr.turnState[self.turnType] == TurnState.State.Active then
        endTime = tonumber(os.time{year = y, month = m, day = d, hour = v.day_time[1][4], min = v.day_time[1][5], sec = v.day_time[1][6]})
        self.timeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_beta_textures, "I18N_TillEnd")
        self.timeText.text = self:ToTime(endTime - baseTime)
        if self.frozen.enabled == false then    -- 按钮被冻结
            if self.effect1 ~= nil then
                self.effect1:DeleteMe()
                self.effect1 = nil
            end
            if self.effect2 ~= nil then
                self.effect2:DeleteMe()
                self.effect2 = nil
            end
        else
            BaseUtils.SetGrey(self.buttonImage, false)
            BaseUtils.SetGrey(self.buttonImage1, false)
            self:ShowEffect1()
            self:ShowEffect2()
        end
    else
        if end_time_cli - baseTime >= 86400 then
            local dd = tonumber(os.date("%d", baseTime + 86400))
            self.timeText.text = string.format(TI18N("%s号%s时开启"), tostring(dd), tostring(v.day_time[1][1]))
        else
            self.timeText.text = self.timeFormatString5
        end
        self.timeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_beta_textures, "I18N_TillEnd")
        BaseUtils.SetGrey(self.buttonImage, true)
        BaseUtils.SetGrey(self.buttonImage1, true)
        if self.effect1 ~= nil then
            self.effect1:DeleteMe()
            self.effect1 = nil
        end
        if self.effect2 ~= nil then
            self.effect2:DeleteMe()
            self.effect2 = nil
        end
    end
end

function NationalDayLotary:ToTime(seconds)
    local h = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local m = math.floor(seconds / 60)
    local s = seconds % 60

    if h > 0 then
        return string.format(self.timeFormat1, tostring(h), tostring(m), tostring(s))
    elseif m > 0 then
        return string.format(self.timeFormat2, tostring(m), tostring(s))
    else
        return string.format(self.timeFormat3, tostring(s))
    end
end

function NationalDayLotary:OnUnFrozen()
    self.frozen:Release()
    self.frozen1:Release()
end

function NationalDayLotary:OnRewardPreview()
    if self.multiItemPanel == nil then
        self.multiItemPanel = MultiItemPanel.New(self.model.otherWin.gameObject)
    end
    if self.rewardInfo == nil then
        self.rewardInfo = {column = 5, list = {{title = TI18N("幸运转盘展示"), items = self.items}}}
    end
    local extra = {}
    extra.horDirection = LuaDirection.Right
    extra.verDirection = LuaDirection.Mid
    extra.fontSize = 17
    local num = 0
    if self.model.turnplateList[self.turnType] ~= nil then
        num = self.model.turnplateList[self.turnType].num
    end
    extra.context = string.format(TI18N("已抽奖:<color='#00ff00'>%s</color>"), tostring(num))
    self.rewardInfo.extra = extra
    self.multiItemPanel:Show(self.rewardInfo)
end

function NationalDayLotary:ShowEffect()
    if self.effect == nil then
        self.effect = BibleRewardPanel.ShowEffect(20175, self.transform:Find("Pointer"), Vector3(0.8, 0.8, 1), Vector3(0, 0, -400))
    else
        self.effect.gameObject:SetActive(true)
    end
end

function NationalDayLotary:ShowEffect1()
    if self.effect1 == nil then
        self.effect1 = BibleRewardPanel.ShowEffect(20185, self.turnBtn.gameObject.transform, Vector3(0.96, 1, 1), Vector3(0, 0, -400))
    end
end

function NationalDayLotary:ShowEffect2()
    if self.effect2 == nil then
        self.effect2 = BibleRewardPanel.ShowEffect(20185, self.turnBtn1.gameObject.transform, Vector3(0.96, 1, 1), Vector3(0, 0, -400))
    end
end




