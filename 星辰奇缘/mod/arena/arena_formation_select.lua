ArenaFormationSelect = ArenaFormationSelect or BaseClass()

function ArenaFormationSelect:__init(model, gameObject, assetWrapper, callback)
    self.assetWrapper = assetWrapper
    self.model = model
    self.gameObject = gameObject
    self.callback = callback

    local t = gameObject.transform:Find("Main")
    self.rect = t:GetComponent(RectTransform)
    self.guardItemList = {}
    self.isOpen = false
    self.container = t:Find("Scroll/Container")
    self.scrollRect = t:Find("Scroll"):GetComponent(RectTransform)
    self.containerRect = self.container:GetComponent(RectTransform)
    self.cloner = t:Find("Scroll/Cloner").gameObject
    local rect = self.cloner:GetComponent(RectTransform)
    self.clonerX = rect.sizeDelta.x
    self.clonerY = rect.sizeDelta.y
    self.cloner:SetActive(false)
    self.maxHeight = self.clonerY * 6

    gameObject.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    end
end

-- 传入{formation_id = formation_id, formation_lev = formation_lev}列表
function ArenaFormationSelect:Show(args, id)
    local obj = nil
    if args == nil then
        args = {}
    end
    self.selectTab = {}
    for i,v in ipairs(args) do
        if v.id == id then
            self.selectTab[i] = true
            self.lastSelect = i
        else
            self.selectTab[i] = false
        end
        if self.guardItemList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.guardItemList[i] = ArenaFormationSelectItem.New(self.model, obj, self.assetWrapper, function() self.callback(i) end)
        end
        self.guardItemList[i]:SetData(v, i)
        self.guardItemList[i]:SetActive(true)
    end
    for i=#args + 1, #self.guardItemList do
        self.guardItemList[i]:SetActive(false)
    end
    local height = #args * self.clonerY
    self.containerRect.sizeDelta = Vector2(self.clonerX, height)
    if height > self.maxHeight then
        height = self.maxHeight
    end
    self.scrollRect.sizeDelta = Vector2(self.clonerX, height)
    self.rect.sizeDelta = Vector2(self.clonerX + 16, height + 35)
    -- self.scrollRect.anchoredPosition = Vector2(0, #args * self.clonerY - 42)
    self.gameObject:SetActive(true)
    self.isOpen = true

    self:Select(self.lastSelect)
end

function ArenaFormationSelect:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self.isOpen = false
end

function ArenaFormationSelect:__delete()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
end

function ArenaFormationSelect:UnSelect(index)
    if index ~= nil then
        self.guardItemList[index]:UnSelect()
    end
end

function ArenaFormationSelect:Select(index)
    if index ~= nil then
        self.guardItemList[index]:Select()
    end
end

function ArenaFormationSelect:GetSelection()
    for i,v in ipairs(self.selectTab) do
        if v == true then
            return i
        end
    end
    return nil
end

ArenaFormationSelectItem = ArenaFormationSelectItem or BaseClass()

function ArenaFormationSelectItem:__init(model, gameObject, assetWrapper, callback)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.callback = callback
    local t = gameObject.transform

    self.selected = false

    self.nameText = t:Find("Text"):GetComponent(Text)
    -- self.selectObj = t:Find("Select").gameObject
    self.button = t:GetComponent(Button)
end

function ArenaFormationSelectItem:SetData(data, index)
    self.nameText.text = BaseUtils.Key(DataFormation.data_list[BaseUtils.Key(data.id, data.lev)].name, "Lv.", data.lev)
    -- self.selectObj:SetActive(false)
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(self.callback)
    self:SetActive(true)
end

function ArenaFormationSelectItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ArenaFormationSelectItem:Select()
    -- self.selectObj:SetActive(true)
end

function ArenaFormationSelectItem:UnSelect()
    -- self.selectObj:SetActive(false)
end
