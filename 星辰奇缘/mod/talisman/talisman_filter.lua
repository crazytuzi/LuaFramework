TalismanFilter = TalismanFilter or BaseClass()

function TalismanFilter:__init(gameObject)
    self.gameObject = gameObject.gameObject

    self.buttonList = {}
    self.conditionList = {}
    self.tickTab = {[0] = 1}

    self.datalist = nil
    self.filterCallback = nil

    self:InitPanel()
end

function TalismanFilter:__delete()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
end

function TalismanFilter:InitPanel()
    self.transform = self.gameObject.transform
    self.layout = LuaBoxLayout.New(self.transform:Find("Mask/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    self.cloner = self.transform:Find("Mask/Cloner").gameObject

    self.cloner:SetActive(false)

    self.allTick = self.cloner.transform:Find("Tick").gameObject
    self.cloner.transform:Find("Text"):GetComponent(Text).text = TI18N("选择全部")
    self.cloner:GetComponent(Button).onClick:AddListener(function() self:OnSelectAll() end)
end

function TalismanFilter:SetData(conditionList, setting)
    setting = setting or {}
    for i,v in ipairs(conditionList) do
        table.insert(self.conditionList, v.conditionCallback)
    end
    self.layout:ReSet()

    self.allEnd = (setting.allEnd == true)
    if setting.allEnd ~= true then
        self.layout:AddCell(self.cloner)
    end
    for i,data in ipairs(conditionList) do
        local button = self.buttonList[i]
        if button == nil then
            button = {}
            button.gameObject = GameObject.Instantiate(self.cloner)
            button.transform = button.gameObject.transform
            button.btn = button.gameObject:GetComponent(Button)
            button.btn.onClick:RemoveAllListeners()
            button.tick = button.transform:Find("Tick").gameObject
            button.text = button.transform:Find("Text"):GetComponent(Text)
            self.buttonList[i] = button
            local j = i
            button.btn.onClick:AddListener(function() self:OnClick(j) end)
            self.tickTab[i] = 1
        end
        self.layout:AddCell(button.gameObject)
        button.text.text = data.text
    end
    if setting.allEnd == true then
        self.layout:AddCell(self.cloner)
    end
    for i=#conditionList + 1, #self.buttonList do
        self.buttonList[i].gameObject:SetActive(false)
    end
    self.gameObject:SetActive(true)

    if self.layout.panelRect.sizeDelta.y < 320 then
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, self.layout.panelRect.sizeDelta.y + 18)
    else
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 329)
    end
end

function TalismanFilter:RefreshTicks()
    for i,v in ipairs(self.buttonList) do
        v.tick:SetActive(self.tickTab[i] == 1)
    end
    self.allTick:SetActive(self.tickTab[0] == 1)
end

function TalismanFilter:OnSelectAll(datalist)
    local filterDataList = {}
    if self.tickTab[0] == 1 then
        for i,_ in ipairs(self.buttonList) do
            self.tickTab[i] = 0
        end
        self.tickTab[0] = 0
    else
        for i,_ in ipairs(self.buttonList) do
            self.tickTab[i] = 1
        end
        self.tickTab[0] = 1
    end
    self:RefreshTicks()

    if self.filterCallback ~= nil then
        self.filterCallback(self:Filter())
    end
end

function TalismanFilter:OnClick(index)
    if self.tickTab[index] == 1 then
        self.tickTab[index] = 0
        self.tickTab[0] = 0
    else
        self.tickTab[index] = 1
        local b = true
        for i,v in ipairs(self.buttonList) do
            b = b and (self.tickTab[i] == 1)
        end
        if b then
            self.tickTab[0] = 1
        else
            self.tickTab[0] = 0
        end
    end

    self:RefreshTicks()

    if self.filterCallback ~= nil then
        self.filterCallback(self:Filter())
    end
end

function TalismanFilter:Filter()
    local list = {}

    for _,v in ipairs(self.datalist or {}) do
        for i,filter in ipairs(self.conditionList) do
            if self.tickTab[i] == 1 and filter(v) then
                table.insert(list, v)
                break
            end
        end
    end

    return list
end

function TalismanFilter:Show()
    self.isShow = true
    self:RefreshTicks()
    self.gameObject:SetActive(true)

    -- local h = self.layout.panelRect.parent.rect.height
    -- self.layout.panelRect.anchoredPosition = Vector2(0, self.layout.panelRect.sizeDelta.y - h)
end

function TalismanFilter:Hide()
    self.isShow = false
    self.gameObject:SetActive(false)
end
