OpenServerTherionPanel = OpenServerTherionPanel or BaseClass(BasePanel)

function OpenServerTherionPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.open_server_therion, type = AssetType.Main}
        , {file = AssetConfig.openserver_therion_i18n, type = AssetType.Main}
    }
    self.setting = {
        notAutoSelect = true,
        openLevel = {0, 0},
        perWidth = 125,
        perHeight = 202,
        isVertical = false,
        spacing = 0
    }

    self.therionList = {}
    self.skillSlotList = {}
    self.skillNameTextList = {}
    self.isMoving = false
    self.therionDataList = model:GetTherions()
    self.currentTherion = 1
    self.isTherion = 1      -- 1 代表神兽，2 代表珍兽

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function OpenServerTherionPanel:__delete()
    self.OnHideEvent:Fire()
    if self.skillSlotList ~= nil then
        for k,v in pairs(self.skillSlotList) do
            if v ~= nil then
                v:DeleteMe()
                self.skillSlotList[k] = nil
                v = nil
            end
        end
        self.skillSlotList = nil
    end
    if self.therionGroup ~= nil then
        self.therionGroup:DeleteMe()
        self.therionGroup = nil
    end
    if self.therionList ~= nil then
        for k,v in pairs(self.therionList) do
            if v ~= nil then
                v:DeleteMe()
                self.therionList[k] = nil
                v = nil
            end
        end
        self.therionList = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerTherionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_therion))
    self.gameObject.name = "OpenServerTherionPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.cloner = t:Find("ShowArea/MaskLayer/ScrollLayer/Cloner").gameObject
    self.scrollRect = t:Find("ShowArea/MaskLayer/ScrollLayer"):GetComponent(ScrollRect)
    self.scrollBar = t:Find("ShowArea/MaskLayer/ScrollLayer/Scrollbar"):GetComponent(ScrollBar)
    self.container = t:Find("ShowArea/MaskLayer/ScrollLayer/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.exchargeBtn = t:Find("CheckArea/Button"):GetComponent(Button)
    self.skillContainer = t:Find("CheckArea/SkillArea/MaskLayer/ScrollLayer/Container")
    self.skillCloner = t:Find("CheckArea/SkillArea/MaskLayer/ScrollLayer/Cloner").gameObject
    self.prePageEnable = t:Find("ShowArea/Prepage/Enable").gameObject
    self.prePageDisable = t:Find("ShowArea/Prepage/Disable").gameObject
    self.nextPageEnable = t:Find("ShowArea/Nextpage/Enable").gameObject
    self.nextPageDisable = t:Find("ShowArea/Nextpage/Disable").gameObject
    self.prePageBtn = t:Find("ShowArea/Prepage"):GetComponent(Button)
    self.nextPageBtn = t:Find("ShowArea/Nextpage"):GetComponent(Button)

    self.cloner:SetActive(false)
    -- self.boxLayout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X})

    local obj = nil
    local rect = nil
    for i,v in ipairs(self.therionDataList) do
        if self.therionList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            obj.transform:SetParent(self.container)
            obj.transform.localScale = Vector3.one
            rect = obj:GetComponent(RectTransform)
            rect.pivot = Vector2(0.5, 1)
            rect.anchoredPosition = Vector2((i - 1) * self.setting.perWidth, 0)
            self.therionList[i] = TherionItem.New(self.model, obj)
        end
        self.therionList[i]:SetData(v,i)
    end

    self.therionGroup = TabGroup.New(self.container, function(index) self:SelectTherion(index) end, self.setting)
    self.therionGroup:Layout()

    self.skillLayout = LuaBoxLayout.New(self.skillContainer, {axis = BoxLayoutAxis.X})
    self.skillCloner:SetActive(false)

    self.pageCount = #self.therionDataList - math.ceil(self.scrollRect:GetComponent(RectTransform).sizeDelta.x / self.setting.perWidth) + 1

    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject, self.pageCount, self.setting.perWidth, 0.5)
    self.tabbedPanel.MoveEndEvent:AddListener(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)

    self.prePageBtn.onClick:AddListener(function()
        if self.tabbedPanel.currentPage > 1 then
            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage - 1)
        end
    end)
    self.nextPageBtn.onClick:AddListener(function()
        if self.tabbedPanel.currentPage < self.pageCount then
            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage + 1)
        end
    end)
    self.scrollRect.onValueChanged:AddListener(function(data) self:OnDrag(data) end)

    self.exchargeBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("9折兑换")
    self.exchargeBtn.onClick:AddListener(function() self:OnGoExchange() end)

    UIUtils.AddBigbg(t:Find("DescArea/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.openserver_therion_i18n)))

    self.OnOpenEvent:Fire()
end

function OpenServerTherionPanel:OnOpen()
    self.therionGroup:ChangeTab(1)
end

function OpenServerTherionPanel:OnHide()
end

function OpenServerTherionPanel:OnDrag(data)
    if self.isMoving == false then
        self.isMoving = true
        local x = math.ceil(data[1] * self.pageCount)
        if x > self.pageCount then
            x = self.pageCount
        elseif x < 1 then
            x = 1
        end
        self:OnDragEnd(x)
        self.tabbedPanel.currentPage = x
    end
end

function OpenServerTherionPanel:SelectTherion(index)
    if self.therionDataList[index].genre == 2 then
        self.isTherion = 1
    else
        self.isTherion = 2
    end

    local skillDatas = self.therionDataList[index].base_skills

    local obj = nil
    for i,v in ipairs(skillDatas) do
        if self.skillSlotList[i] == nil then
            obj = GameObject.Instantiate(self.skillCloner)
            obj.name = tostring(i)
            self.skillLayout:AddCell(obj)
            self.skillSlotList[i] = SkillSlot.New()
            self.skillNameTextList[i] = obj.transform:Find("Name"):GetComponent(Text)
            NumberpadPanel.AddUIChild(obj.transform:Find("SlotBg").gameObject, self.skillSlotList[i].gameObject)
        end
        local data = DataSkill.data_petSkill[v[1].."_1"]
        self.skillSlotList[i]:SetAll(Skilltype.petskill, data)
        self.skillNameTextList[i].text = data.name
        self.skillSlotList[i].gameObject:SetActive(true)
    end

    for i=#skillDatas + 1, #self.skillSlotList do
        self.skillSlotList[i].gameObject.transform.parent.parent.gameObject:SetActive(false)
    end
end

function OpenServerTherionPanel.DoubleEquals(val1, val2)
    return math.abs(val1 - val2) < 0.00000001
end

function OpenServerTherionPanel:OnDragEnd(currentPage, direction)
    if currentPage < self.pageCount then
        self.nextPageEnable:SetActive(true)
        self.nextPageDisable:SetActive(false)
    else
        self.nextPageEnable:SetActive(false)
        self.nextPageDisable:SetActive(true)
    end
    if currentPage > 1 then
        self.prePageEnable:SetActive(true)
        self.prePageDisable:SetActive(false)
    else
        self.prePageEnable:SetActive(false)
        self.prePageDisable:SetActive(true)
    end

    self.isMoving = false
end

function OpenServerTherionPanel:OnGoExchange()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {self.isTherion})
end
