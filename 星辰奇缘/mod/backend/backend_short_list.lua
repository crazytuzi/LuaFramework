-- @author 黄耀聪
-- @date 2016年9月5日

BackendShortList = BackendShortList or BaseClass(BasePanel)

function BackendShortList:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendShortList"

    self.itemList = {}

    self.resList = {
        {file = AssetConfig.mergeserver_total_login, type = AssetType.Main},    -- 重用合服活动连续登录的UI
        {file = AssetConfig.mergeserver_bg, type = AssetType.Main},
    }
    self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.timeFormat = TI18N("%s年%s月%s日")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendShortList:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.titleImage ~= nil then
        self.titleImage.sprite = nil
        self.titleImage = nil
    end
    if self.titleIconImage ~= nil then
        self.titleIconImage.sprite = nil
        self.titleIconImage = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendShortList:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_total_login))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    t.anchoredPosition = Vector2(0, 0)

    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.titleImage = t:Find("TitleArea"):GetComponent(Image)
    self.titleIconImage = t:Find("TitleArea/Title/Icon"):GetComponent(Image)
    self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)
    self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)

    local itemContainer = t:Find("MaskScroll/Container")
    self.containerRect = itemContainer:GetComponent(RectTransform)
    self.scrollLayerRect = t:Find("MaskScroll"):GetComponent(RectTransform)
    for i=1,7 do
        self.itemList[i] = BackendShortItem.New(self.model, itemContainer:Find("Day"..i).gameObject)
    end
    self.layout = LuaBoxLayout.New(itemContainer, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 5})
    self.titleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.mergeserver_bg, "MergeServerBg")
end

function BackendShortList:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendShortList:OnOpen()
    self:RemoveListeners()

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    self:ReloadList()
    self:InitInfo()
    self:OnTime()
end

function BackendShortList:InitInfo()
    self.titleText.text = self.menuData.title2
    self.descText.text = TI18N("<color='#7EB9F7'>活动内容:</color>")..self.menuData.rule_str
end

function BackendShortList:OnTime()
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

function BackendShortList:OnHide()
    self:RemoveListeners()
end

function BackendShortList:RemoveListeners()
end

function BackendShortList:ReloadList()
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
            local obj = GameObject.Instantiate(self.itemList[1].gameObject)
            obj.name = "Day"..i
            tab = BackendShortItem.New(model, obj)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        tab:update_my_self(v)
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
end


BackendShortItem = BackendShortItem or BaseClass()

function BackendShortItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    local t = gameObject.transform
    self.transform = t

    self.nameText = t:Find("DayText"):GetComponent(Text)
    self.itemList = {nil, nil, nil}
    for i=1,3 do
        local tab = {}
        tab.transform = t:Find("Item"..i)
        tab.slot = ItemSlot.New()
        tab.data = ItemData.New()
        tab.nameText = tab.transform:Find("NameText"):GetComponent(Text)
        NumberpadPanel.AddUIChild(tab.transform.gameObject, tab.slot.gameObject)
        self.itemList[i] = tab
    end
    self.btn = t:Find("Button"):GetComponent(Button)
    self.finishText = t:Find("FinishText"):GetComponent(Text)

    self.btn.onClick:AddListener(function() self:OnClick(1) end)
end

function BackendShortItem:__delete()
    if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self.btn.onClick:RemoveAllListeners()
end

function BackendShortItem:update_my_self(data)
    local model = self.model
    local menuData = model.backendCampaignTab[data.campId].menu_list[data.menuId]

    self.data = data
    self.gameObject:SetActive(true)
    self.nameText.text = data.str1

    for i,v in ipairs(self.itemList) do
        local rewardData = data.items[i]
        if rewardData ~= nil then
            v.transform.gameObject:SetActive(true)
            local baseData = DataItem.data_get[rewardData.base_id]
            v.nameText.text = BaseUtils.string_cut_utf8(baseData.name, 6, 5)
            if v.data.base_id ~= rewardData.base_id then
                v.data:SetBase(baseData)
                v.slot:SetAll(v.data, {inbag = false, nobutton = true})
                v.slot:SetNum(rewardData.num)
            end
        else
            v.transform.gameObject:SetActive(false)
        end
    end
end

function BackendShortItem:OnClick(num)
    if self.data.status == 1 then
        BackendManager.Instance:send14053(self.data.campId, self.data.menuid, self.data.n, num)
    else
    end
end

