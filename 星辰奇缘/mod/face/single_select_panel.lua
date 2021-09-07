-- @author 黄耀聪
-- @date 2017年8月29日, 星期二

SingleSelectPanel = SingleSelectPanel or BaseClass(BasePanel)

function SingleSelectPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SingleSelectPanel"

    self.resList = {
        {file = AssetConfig.single_select, type = AssetType.Main},
    }

    self.hideCallback = nil
    self.clickCallback = nil
    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

end

function SingleSelectPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function SingleSelectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.single_select))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.layout = LuaBoxLayout.New(t:Find("Main/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})
    self.cloner = t:Find("Main/Scroll/Item").gameObject
end

function SingleSelectPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SingleSelectPanel:OnOpen()
    self:RemoveListeners()

    if self.openArgs ~= nil then
        self.baseIdList = self.openArgs.baseIdList
        self.clickCallback = self.openArgs.clickCallback
    end
    self:Reload()
end

function SingleSelectPanel:OnHide()
    self:RemoveListeners()

    -- 一次性回调
    if self.hideCallback ~= nil then
        self.hideCallback()
        self.hideCallback = nil
    end
end

function SingleSelectPanel:RemoveListeners()
end

function SingleSelectPanel:Reload()
    if self.baseIdList == nil then
        return
    end

    for i,data in ipairs(self.baseIdList) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Slot"), tab.slot.gameObject)
            tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
            tab.descText = tab.transform:Find("Desc"):GetComponent(Text)

            local j = i
            tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickItem(j) end)
            self.itemList[i] = tab
        end

        tab.slot:SetAll(DataItem.data_get[data.base_id], {inbag = false, nobutton = true})
        tab.nameText.text = DataItem.data_get[data.base_id].name

        local num = BackpackManager.Instance:GetItemCount(data.base_id)
        tab.slot:SetGrey(num < data.need)
        tab.descText.text = string.format("%s/%s", BackpackManager.Instance:GetItemCount(data.base_id), data.need)
    end
    for i=#self.baseIdList + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.cloner:SetActive(false)
end

function SingleSelectPanel:ClickItem(index)
    if self.clickCallback ~= nil then
        self.clickCallback(self.baseIdList[index])
    end
end

