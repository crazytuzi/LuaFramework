-- @author 黄耀聪
-- @date 2016年8月24日

ExquisiteShelfRewardPreview = ExquisiteShelfRewardPreview or BaseClass(BasePanel)

function ExquisiteShelfRewardPreview:__init(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.itemList = {}
    self:InitPanel()

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExquisiteShelfRewardPreview:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            v.slot:DeleteMe()
            v.slot = nil
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    self:AssetClearAll()
end

function ExquisiteShelfRewardPreview:InitPanel()
    local t = self.transform

    -- self.descText = t:Find("Panel/Title"):GetComponent(Text)

    self.container = t:Find("Main/Scroll/Container")
    self.scrollRect = self.container.parent

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0, border = 15})

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    t:Find("Main/Text"):GetComponent(Text).text = TI18N("通关此层极品奖励")
end

function ExquisiteShelfRewardPreview:OnOpen()
    self:RemoveListeners()

    self:ReloadItems(self.openArgs.list)
end

function ExquisiteShelfRewardPreview:OnHide()
    self:RemoveListeners()
end

function ExquisiteShelfRewardPreview:RemoveListeners()
end

function ExquisiteShelfRewardPreview:ReloadItems(list)
    self.layout:ReSet()
    for i,v in ipairs(list) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            self.itemList[i] = tab
        end
        tab.data:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        tab.slot:SetNum(v[2])
        self.layout:AddCell(tab.slot.gameObject)
    end
    for i=#list + 1, #self.itemList do
        self.itemList[i].slot.gameObject:SetActive(false)
    end

    local num = #list
    self.scrollRect.sizeDelta = Vector2(64 * num + 15 * (num - 1), 64)
end


