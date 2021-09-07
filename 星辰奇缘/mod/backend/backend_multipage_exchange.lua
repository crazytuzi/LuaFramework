-- @author 黄耀聪
-- @date 2016年9月1日

BackendMultipageExchange = BackendMultipageExchange or BaseClass(BasePanel)

function BackendMultipageExchange:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendMultipageExchange"
    self.mgr = BackendManager.Instance

    self.resList = {
        {file = AssetConfig.backend_multipage_exchange, type = AssetType.Main},
    }

    self.timeString1 = TI18N("活动倒计时:%s")
    self.timeFormat1 = TI18N("%s天%s小时")
    self.timeFormat2 = TI18N("%s小时%s分钟")
    self.timeFormat3 = TI18N("%s分钟%s秒")
    self.timeFormat4 = TI18N("%s秒")
    self.timeString2 = TI18N("活动已结束")
    self.timeListener = function() self:OnTime() end
    self.pageList = {}
    self.toggleList = {}

    self.reloadListener = function() self:ReloadList() end
    self.infoListener = function() self:InitInfo() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendMultipageExchange:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.tabbed ~= nil then
        self.tabbed:DeleteMe()
        self.tabbed = nil
    end
    if self.model.arrowEffect ~= nil then
        self.model.arrowEffect:DeleteMe()
        self.model.arrowEffect = nil
    end
    if self.pageList ~= nil then
        for _,v in pairs(self.pageList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.pageList = nil
    end
    if self.ownLoader ~= nil then
        self.ownLoader:DeleteMe()
        self.ownLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendMultipageExchange:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_multipage_exchange))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("Title/Time/Text"):GetComponent(Text)
    self.noticeBtn = t:Find("Title/Notice"):GetComponent(Button)
    self.container = t:Find("Scroll/Container")
    self.cloner = t:Find("Scroll/Page").gameObject
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0})
    self.tabbed = TabbedPanel.New(t:Find("Scroll").gameObject, 0, 538, 0.6)
    self.tabbed.MoveEndEvent:AddListener(function(page) self:OnDragEnd(page) end)
    self.ownLoader = SingleIconLoader.New(t:Find("Title/Own/Icon").gameObject)
    self.ownImage = t:Find("Title/Own/Icon"):GetComponent(Image)
    self.ownText = t:Find("Title/Own/Icon/Text"):GetComponent(Text)

    self.toggleContainer = t:Find("ToggleGroup")
    self.toggleCloner = t:Find("ToggleGroup/Toggle").gameObject

    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.cloner:SetActive(false)
    self.toggleCloner:SetActive(false)
end

function BackendMultipageExchange:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendMultipageExchange:OnOpen()
    self:RemoveListeners()
    self.mgr.onTick:AddListener(self.timeListener)
    EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.infoListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId
    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")
    self.ruleList = StringHelper.Split(self.menuData.rule_str, "|")

    self:InitInfo()
    self:ReloadList()
end

function BackendMultipageExchange:ReloadList()
    local camp_list = {}
    local campList = {}
    local count = 0
    for i,v in ipairs(self.menuData.camp_list) do
        v.campId = self.campId
        v.menuId = self.menuId
        if count < 6 then
            table.insert(campList, v)
            count = count + 1
        else
            count = 1
            table.insert(camp_list, campList)
            campList = {v}
        end
    end
    if count < 6 then
        table.insert(camp_list, campList)
    end

    self.layout:ReSet()
    self.tabbed:SetPageCount(#camp_list)
    for i,v in ipairs(camp_list) do
        local page = self.pageList[i]
        if page == nil then
            local obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            page = BackendMultiExchangePage.New(self.model, obj)
        end
        self.layout:AddCell(page.gameObject)
        page:update_my_self(v, self.btnSplitList)
        page.gameObject:SetActive(true)
        if self.toggleList[i] == nil then
            local obj = GameObject.Instantiate(self.toggleCloner)
            obj.name = tostring(i)
            obj.transform:SetParent(self.toggleContainer)
            obj.transform.localScale = Vector3.one
            self.toggleList[i] = obj:GetComponent(Toggle)
        end
        self.toggleList[i].gameObject:SetActive(true)
    end
    for i=#camp_list + 1,#self.pageList do
        self.pageList[i].gameObject:SetActive(false)
        self.toggleList[i].gameObject:SetActive(false)
    end

    self:OnDragEnd(self.tabbed.currentPage)
end

function BackendMultipageExchange:OnDragEnd(page)
    for _,v in ipairs(self.toggleList) do
        v.isOn = false
    end
    if self.toggleList[page] ~= nil then
        self.toggleList[page].isOn = true
    end
end

function BackendMultipageExchange:OnHide()
    self:RemoveListeners()
end

function BackendMultipageExchange:RemoveListeners()
    self.mgr.onTick:RemoveListener(self.timeListener)
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.infoListener)
end

function BackendMultipageExchange:InitInfo()
    if self.menuData.camp_list[1] ~= nil and self.menuData.camp_list[1].loss_items[1] ~= nil then
        local base_id = self.menuData.camp_list[1].loss_items[1].base_id
        local baseData = DataItem.data_get[base_id]
        self.ownText.text = string.format("%s", tostring(BackpackManager.Instance:GetItemCount(base_id)))
        self.ownText.transform.sizeDelta = Vector2(math.ceil(self.ownText.preferredWidth + 3), 24)
        self.ownLoader:SetSprite(SingleIconType.Item, baseData.icon)
    else
        self.ownText.text = ""
    end
end

function BackendMultipageExchange:OnTime()
    local model = self.model
    local start_time = self.menuData.start_time
    local end_time = self.menuData.end_time

    local d = nil
    local h = nil
    local m = nil
    local s = nil

    local dis = end_time - BaseUtils.BASE_TIME
    if dis > 0 then
        d,h,m,s = BaseUtils.time_gap_to_timer(dis)
        if d > 0 then
            self.timeText.text = string.format(self.timeString1, string.format(self.timeFormat1, tostring(d), tostring(h)))
        elseif h > 0 then
            self.timeText.text = string.format(self.timeString1, string.format(self.timeFormat2, tostring(h), tostring(m)))
        elseif m > 0 then
            self.timeText.text = string.format(self.timeString1, string.format(self.timeFormat3, tostring(m), tostring(s)))
        else
            self.timeText.text = string.format(self.timeString1, string.format(self.timeFormat4, tostring(s)))
        end
    else
        self.timeText.text = string.format(self.timeString2)
    end
end

function BackendMultipageExchange:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = self.ruleList})
end


BackendMultiExchangePage = BackendMultiExchangePage or BaseClass()

function BackendMultiExchangePage:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.itemlist = {}
    local length = self.transform.childCount
    for i=1,length do
        self.itemlist[i] = BackendMultiExchangeItem.New(model, self.transform:GetChild(i - 1).gameObject)
    end
end

function BackendMultiExchangePage:__delete()
    if self.itemlist ~= nil then
        for _,v in pairs(self.itemlist) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemlist = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
    end
end

function BackendMultiExchangePage:update_my_self(data, stringList)
    for i,v in ipairs(self.itemlist) do
        v:update_my_self(data[i], stringList)
    end
end

BackendMultiExchangeItem = BackendMultiExchangeItem or BaseClass()

function BackendMultiExchangeItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local t = self.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.slot = ItemSlot.New()
    self.itemData = ItemData.New()
    NumberpadPanel.AddUIChild(t:Find("Item").gameObject, self.slot.gameObject)
    self.slot:Default()

    self.priceLoader = SingleIconLoader.New(t:Find("Price/Icon").gameObject)
    self.priceText = t:Find("Price/Icon/Text"):GetComponent(Text)
    self.extText = t:Find("Ext"):GetComponent(Text)
    self.progressText = t:Find("Progress"):GetComponent(Text)

    self.btn = t:Find("Button"):GetComponent(CustomButton)
    self.btnText = t:Find("Button/Text"):GetComponent(Text)
    self.btnImage = t:Find("Button"):GetComponent(Image)
    self.msgExt = MsgItemExt.New(self.btnText, 200, 16, 19)

    -- self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self:OnClick(1) end)
    self.btn.onHold:AddListener(function() self:OnNumberpad() end)
    self.btn.onDown:AddListener(function() self:OnDown() end)
    self.btn.onUp:AddListener(function() self:OnUp() end)

    self.numberpadSetting = {
        gameObject = self.btn.gameObject,
        min_result = 1,
        max_by_asset = 20,
        max_result = 20,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) self:OnClick(num) end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }
end

function BackendMultiExchangeItem:update_my_self(data, stringList)
    self.data = data
    if data == nil then
        self:SetActive(false)
        return
    end
    self:SetActive(true)
    local menuData = self.model.backendCampaignTab[data.campId].menu_list[data.menuId]

    local baseData = DataItem.data_get[data.items[1].base_id]
    if self.itemData.base_id ~= baseData.base_id then
        self.itemData:SetBase(baseData)
        self.slot:SetAll(self.itemData, {inbag = false, nobutton = true})
        self.slot:SetNum(data.items[1].num)
    end
    self.nameText.text = ColorHelper.color_item_name(baseData.quality, baseData.name)

    if #data.loss_items > 0 then
        baseData = DataItem.data_get[data.loss_items[1].base_id]
        self.priceLoader.gameObject:SetActive(true)
        self.priceLoader:SetSprite(SingleIconType.Item, baseData.icon)
        self.priceText.text = tostring(data.loss_items[1].num)
    else
        self.priceLoader.gameObject:SetActive(false)
    end

    if menuData.is_button == BackendEumn.ButtonType.Hiden then          -- 隐藏按钮
        self.btn.gameObject:SetActive(false)
        if data.status ~= 2 then
            self.progressText.gameObject:SetActive(false)
        else
            self.progressText.gameObject:SetActive(true)
            self.progressText.text = TI18N("已完成")
        end
    else
        self.progressText.gameObject:SetActive(false)
        self.btn.gameObject:SetActive(true)
        if data.status ~= 2 then
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("已完成")))
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        end
    end

    if data.reward_num > 5000 then
        self.extText.text = string.format(TI18N("不限兑"))
    else
        self.extText.text = string.format(TI18N("限兑<color='#00ff00'>%s</color>次"), tostring(data.reward_can))
    end

    local size = self.msgExt.contentRect.sizeDelta
    self.msgExt.contentRect.anchorMax = Vector2(0.5,0.5)
    self.msgExt.contentRect.anchorMin = Vector2(0.5,0.5)
    self.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
    self.numberpadSetting.returnText = stringList[1]
    self.numberpadSetting.max_result = data.reward_can or 1
end

function BackendMultiExchangeItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.priceLoader ~= nil then
        self.priceLoader:DeleteMe()
        self.priceLoader = nil
    end
    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end
end

function BackendMultiExchangeItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function BackendMultiExchangeItem:OnClick(num)
    if self.data ~= nil then
        if self.data.status ~= 2 then
            BackendManager.Instance:send14053(self.data.campId, self.data.menuId, self.data.n, num)
        else
            -- NoticeManager.Instance:FloatTipsByString(TI18N("已完成"))
        end
    end
end

function BackendMultiExchangeItem:OnNumberpad()
    local model = self.model
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function BackendMultiExchangeItem:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp then
            return
        end
        if self.model.arrowEffect ~= nil then
            self.model.arrowEffect:DeleteMe()
            self.model.arrowEffect = nil
        end
        self.model.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.btn.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
    end)
end

function BackendMultiExchangeItem:OnUp()
    self.isUp = true
    if self.model.arrowEffect ~= nil then
        self.model.arrowEffect:DeleteMe()
        self.model.arrowEffect = nil
    end
end
