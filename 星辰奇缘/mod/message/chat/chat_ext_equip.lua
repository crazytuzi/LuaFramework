-- --------------------------------
-- 聊天扩展界面--装备
-- --------------------------------
ChatExtEquip = ChatExtEquip or BaseClass()

function ChatExtEquip:__init(gameObject, type)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtEquip"

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.type = type
    self.pageMax = 1

    self:InitPanel()
    self.gameObject:SetActive(false)
end

function ChatExtEquip:__delete()
    for i,v in ipairs(self.itemTab) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemTab = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
end

function ChatExtEquip:InitPanel()
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Container").gameObject
    self.rect = self.container:GetComponent(RectTransform)
    self.pageBase = self.container.transform:Find("ItemPage").gameObject
    self.pageBase:SetActive(false)
    self.pageTab = {self.pageBase}
    local pageTransform = self.pageBase.transform
    self:GetItem(pageTransform)
end

function ChatExtEquip:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    local list = {}
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        table.insert(list, v)
    end
    for k,v in pairs(TalismanManager.Instance.model.itemDic) do
        local data = v
        data.istalisman = true
        table.insert(list, data)
    end
    if WingsManager.Instance.WingInfo.grade ~= nil and WingsManager.Instance.WingInfo.grade > 0 then
        local base = BaseUtils.copytab(DataItem.data_get[WingsManager.Instance:GetItemByGrade(WingsManager.Instance.WingInfo.grade)])
        base.grade = WingsManager.Instance.WingInfo.grade
        base.growth = WingsManager.Instance.WingInfo.growth
        base.wing_id = WingsManager.Instance.WingInfo.wing_id
        table.insert(list, base)
    end
    self:InitPage(list, 560, 18)
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtEquip:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function ChatExtEquip:GetItem(pageTransform)
    for i = 1, 18 do
        local item = pageTransform:GetChild(i - 1)
        local tab = ItemSlot.New(item.gameObject)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab.click_self_call_back = function() self:ClickBtn(index) end
    end
end

function ChatExtEquip:Refresh(list)
    local count = 0
    for i,itemData in ipairs(list) do
        if itemData.istalisman then
            count = i
            local tab = self.itemTab[i]
            local cfg = DataTalisman.data_get[itemData.base_id]
            local itemcfg = DataItem.data_get[itemData.base_id]
            -- tab:SetAll(itemData)
            -- tab:SetAll(cfg)
            for k,v in pairs(itemcfg) do
                if k ~= "id" then
                    itemData[k] = v
                end
            end
            local roleData = RoleManager.Instance.RoleData
            tab:SetAll(itemcfg)
            tab["itemData"] = itemData
            tab["talisman_id"] = itemData.id
            if cfg.quality >= 3 then
                tab["match"] = string.format("%%[%%[%s%%]%s%%]", TalismanEumn.QualifyName[cfg.quality], cfg.name)
                tab["append"] = string.format("[[%s]%s]", TalismanEumn.QualifyName[cfg.quality], cfg.name)
                tab["send"] = string.format("{item_4,%s,%s,%s,%s}", roleData.platform, roleData.zone_id, itemData.base_id, itemData.id)
            else
                tab["match"] = string.format("%%[%s%%]", cfg.name)
                tab["append"] = string.format("[%s]", cfg.name)
                tab["send"] = string.format("{item_4,%s,%s,%s,%s}", roleData.platform, roleData.zone_id, itemData.base_id, itemData.id)
            end
            tab["gameObject"]:SetActive(true)
        elseif itemData.wing_id == nil then
            count = i
            local tab = self.itemTab[i]
            tab:SetAll(itemData)
            tab["itemData"] = itemData

            local name_str = itemData.name
            local is_shenqi = false
            local shenqi_id = 0
            local shenqi_flag = 0
            shenqi_id, shenqi_flag = EquipStrengthManager.Instance.model:check_equip_is_shenqi(itemData)

            local match_name_str = name_str
            local append_name_str = name_str

            if shenqi_id ~= 0 then
                match_name_str = DataItem.data_get[shenqi_id].name
                append_name_str = DataItem.data_get[shenqi_id].name
                if shenqi_flag ~= 0 then
                    local name_pre = EquipStrengthManager.Instance.model.dianhua_name[shenqi_flag]
                    match_name_str = string.format("%s[%s%s]%s", "%", name_pre, "%",match_name_str)
                    append_name_str = string.format("[%s]%s", name_pre, append_name_str)
                end
            end

            tab["match"] = string.format("%%[%s%%]", match_name_str)
            tab["append"] = string.format("[%s]", append_name_str)
            tab["send"] = string.format("{item_2,%s,%s,%s}", itemData.base_id, itemData.bind, itemData.quantity)
            tab["gameObject"]:SetActive(true)
        else
            count = i
            local tab = self.itemTab[i]
            tab:ShowAddBtn(false)
            local wingID = itemData.wing_id
            local grade = itemData.grade
            local base = DataItem.data_get[WingsManager.Instance:GetItemByGrade(grade)]
            local TitemData = ItemData.New()
            local roleData = RoleManager.Instance.RoleData
            TitemData:SetBase(base)
            tab:SetAll(TitemData, {nobutton = true})
            tab["itemData"] = itemData
            tab["wing_id"] = itemData.wing_id
            tab["match"] = string.format("%%[%s%%]", base.name)
            tab["append"] = string.format("[%s]", base.name)
            tab["send"] = string.format("{wing_1,%s,%s,%s,%s,%s}", roleData.platform, roleData.zone_id, roleData.classes, itemData.grade, itemData.growth)
            tab["gameObject"]:SetActive(true)
        end
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtEquip:InitPage(list, width, num)
    local len = #list
    local page = math.ceil(len / num)
    local len = #self.pageTab
    for i = 1, len do
        if i <= page then
            self.pageTab[i]:SetActive(true)
        else
            self.pageTab[i]:SetActive(false)
        end
    end
    local newLen = page - len
    for i = 1, newLen do
        local newPage = GameObject.Instantiate(self.pageBase)
        local transform = newPage.transform
        transform:SetParent(self.container.transform)
        transform.localScale = Vector3.one
        transform.localPosition = Vector3(i * width, 0, 0)
        newPage:SetActive(true)
        self:GetItem(newPage.transform)
        table.insert(self.pageTab, newPage)
    end

    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.gameObject, page, width)
        self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
    else
        self.tabbedPanel:SetPageCount(page)
    end
    self.rect.sizeDelta = Vector2(page * width, 270)

    self:Refresh(list)
    self.pageMax = page
end

function ChatExtEquip:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["append"]
    if str ~= nil and str ~= "" then
        if tab["talisman_id"] ~= nil then
            ChatManager.Instance:Send10406(MsgEumn.CacheType.Talisman, tab.itemData.id)
            local element = {}
            element.type = MsgEumn.AppendElementType.Talisman
            element.id = tab.itemData.id
            element.base_id = tab.itemData.base_id
            element.num = 1
            element.cacheType = MsgEumn.CacheType.Talisman
            element.showString = str
            element.sendString = tab["send"]
            element.matchString = tab["match"]

            ChatManager.Instance:AppendInputElement(element, self.type)
        elseif tab["wing_id"] == nil then
            ChatManager.Instance:Send10406(MsgEumn.CacheType.Equip, tab.itemData.id)
            local element = {}
            element.type = MsgEumn.AppendElementType.Equip
            element.id = tab.itemData.id
            element.base_id = tab.itemData.base_id
            element.num = tab.itemData.quantity
            element.cacheType = MsgEumn.CacheType.Equip
            element.showString = str
            element.sendString = tab["send"]
            element.matchString = tab["match"]

            ChatManager.Instance:AppendInputElement(element, self.type)
        else
            ChatManager.Instance:Send10406(MsgEumn.CacheType.Wing, tab["wing_id"])
            local element = {}
            element.type = MsgEumn.AppendElementType.Wing
            element.id = tab.itemData.id
            element.base_id = tab["wing_id"]
            element.grade = tab.itemData.grade
            element.growth = tab.itemData.growth
            element.num = tab.itemData.quantity
            element.cacheType = MsgEumn.CacheType.Wing
            element.showString = str
            element.sendString = tab["send"]
            element.matchString = tab["match"]

            ChatManager.Instance:AppendInputElement(element, self.type)
        end
    end
end

function ChatExtEquip:OnMoveEnd(currentPage, direction)
    self.currentPageCount = currentPage
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleIndex(currentPage)
    end
end