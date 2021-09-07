-- @author 黄耀聪
-- @date 2016年9月6日

BackendHorizontalList = BackendHorizontalList or BaseClass(BasePanel)

function BackendHorizontalList:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendHorizontalList"

    self.resList = {
        {file = AssetConfig.mergeserver_gift_panel, type = AssetConfig.Main},
        {file = AssetConfig.mergeserver_bg, type = AssetType.Main},
    }
    self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.timeFormat = TI18N("%s年%s月%s日")
    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendHorizontalList:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.titleIconImage ~= nil then
        self.titleIconImage.sprite = nil
        self.titleIconImage = nil
    end
    if self.titleImage ~= nil then
        self.titleImage.sprite = nil
        self.titleImage = nil
    end
    if self.assetImage ~= nil then
        self.assetImage.sprite = nil
        self.assetImage = nil
    end
    if self.itemList ~= nil then
        for _,v in ipairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendHorizontalList:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_gift_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    t.anchoredPosition = Vector2.zero

    t:Find("TitleArea").gameObject:SetActive(true)
    self.titleImage = t:Find("TitleArea"):GetComponent(Image)
    self.titleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.mergeserver_bg, "MergeServerBg")

    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.titleIconImage = t:Find("TitleArea/Title/Icon"):GetComponent(Image)
    self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)
    self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)

    local scroll = t:Find("ItemArea/ScrollLayer")
    self.container = scroll:Find("Container")
    self.cloner = scroll:Find("Cloner").gameObject

    local wealthArea = t:Find("WealthArea")
    self.assetValueText = wealthArea:Find("WealthBg/Value"):GetComponent(Text)
    self.assetImage = wealthArea:Find("WealthBg/Currency"):GetComponent(Image)
    self.assetDescText = wealthArea:Find("WealthBg/Desc"):GetComponent(Text)
    self.buyBtn = wealthArea:Find("Buy"):GetComponent(Button)

    self.prePageEnable = t:Find("ItemArea/PrePageBtn/Enable").gameObject
    self.prePageDisable = t:Find("ItemArea/PrePageBtn/Disable").gameObject
    self.nextPageEnable = t:Find("ItemArea/NextPageBtn/Enable").gameObject
    self.nextPageDisable = t:Find("ItemArea/NextPageBtn/Disable").gameObject

    self.buyBtn.onClick:AddListener(function() self:OnBuy() end)
    self.prePageBtn = t:Find("ItemArea/PrePageBtn"):GetComponent(Button)
    -- self.prePageBtn.onClick:AddListener(function() end)
    self.nextPageBtn = t:Find("ItemArea/NextPageBtn"):GetComponent(Button)
    -- self.nextPageBtn.onClick:AddListener(function() end)

    self.prePageBtn.gameObject:SetActive(false)
    self.nextPageBtn.gameObject:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, border = 5})
end

function BackendHorizontalList:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendHorizontalList:OnOpen()
    self:RemoveListeners()

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    self:InitInfo()
    self:OnTime()
    self:ReloadList()

    self.timerId = LuaTimer.Add(20, 20, function() self.timeCount = ((self.timeCount or 0) + 1) % 360 self:DoRotate(self.timeCount) end)
end

function BackendHorizontalList:OnHide()
    self:RemoveListeners()
end

function BackendHorizontalList:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function BackendHorizontalList:ReloadList()
    local model = self.model
    local datalist = {}
    local tab = nil

    local menuData = self.menuData
    for _,v in pairs(menuData.camp_list) do
        table.insert(datalist, v)
        v.campId = self.campId
        v.menuId = self.menuId
    end
    table.sort(datalist, function(a,b) return a.n < b.n end)

    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        local tab = self.itemList[i]
        if self.itemList[i] == nil then
            local obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            tab = BackendHorizontalItem.New(model, obj)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        tab:update_my_self(v)
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.cloner:SetActive(false)
end

function BackendHorizontalList:InitInfo()
    self.titleText.text = self.menuData.title2
    self.descText.text = TI18N("<color='#7EB9F7'>活动内容:</color>")..self.menuData.rule_str
end

function BackendHorizontalList:OnTime()
    local model = self.model
    local start_time = self.menuData.start_time
    local end_time = self.menuData.end_time

    local s_m = os.date("%m", start_time)
    local s_d = os.date("%d", start_time)
    local s_H = os.date("%H", start_time)
    local s_M = os.date("%M", start_time)
    local e_m = os.date("%m", end_time)
    local e_d = os.date("%d", end_time)
    local e_H = os.date("%H", end_time)
    local e_M = os.date("%M", end_time)

    self.timeText.text = string.format(self.timeString, string.format(self.timeFormat, tostring(s_m), tostring(s_d), tostring(s_H), tostring(s_M)), string.format(self.timeFormat, tostring(e_m), tostring(e_d), tostring(e_H), tostring(e_M)))
end

function BackendHorizontalList:DoRotate(theta)
    for _,v in pairs(self.itemList) do
        if v ~= nil then
            v:Rotate(theta)
        end
    end
end

BackendHorizontalItem = BackendHorizontalItem or BaseClass()

function BackendHorizontalItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.priceText = t:Find("PriceBg/Text"):GetComponent(Text)
    self.priceLoader = SingleIconLoader.New(t:Find("PriceBg/Currency").gameObject)
    self.light = t:Find("IconLignt")
    self.slot = ItemSlot.New()
    self.itemdata = ItemData.New()
    NumberpadPanel.AddUIChild(t:Find("IconBg").gameObject, self.slot.gameObject)
    self.nameText = t:Find("NameBg/Name"):GetComponent(Text)
    self.btnImage = t:Find("Buy"):GetComponent(Image)
    self.btn = t:Find("Buy"):GetComponent(Button)
    self.btnText = t:Find("Buy/Text"):GetComponent(Text)

    t:Find("IconBg/Icon").gameObject:SetActive(false)
    self.btn.onClick:AddListener(function() self:OnClick(1) end)
end

function BackendHorizontalItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.itemdata:DeleteMe()
        self.slot = nil
        self.itemdata = nil
    end
    if self.priceLoader ~= nil then
        self.priceLoader:DeleteMe()
        self.priceLoader = nil
    end
    if self.btnImage ~= nil then
        self.btnImage.sprite = nil
        self.btnImage = nil
    end
    self.btn.onClick:RemoveAllListeners()
end

function BackendHorizontalItem:update_my_self(data)
    self.data = data
    local model = self.model
    local menuData = model.backendCampaignTab[data.campId].menu_list[data.menuId]

    self.data = data
    self.gameObject:SetActive(true)

    local baseData = DataItem.data_get[data.items[1].base_id]
    self.nameText.text = baseData.name
    if self.itemdata.base_id ~= baseData.base_id then
        self.itemdata:SetBase(baseData)
        self.slot:SetAll(self.itemdata, {inbag = false, nobutton = true})
        self.slot:SetNum(data.items[1].num)
    end

    baseData = DataItem.data_get[data.loss_items[1].base_id]
    self.priceText.text = tostring(data.loss_items[1].num)

    if GlobalEumn.CostTypeIconName[baseData.base_id] == nil then
        self.priceLoader:SetSprite(SingleIconType.Item, baseData.icon)
    else
        self.priceLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[baseData.base_id]))
    end
end

function BackendHorizontalItem:Rotate(theta)
    self.light.rotation = Quaternion.Euler(0, 0, theta)
end

function BackendHorizontalItem:OnClick(num)
    if self.data.status == 1 then
        BackendManager.Instance:send14053(self.data.campId, self.data.menuid, self.data.n, num)
    else
    end
end