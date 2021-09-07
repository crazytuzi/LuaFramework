LoveWishPossibleReward = LoveWishPossibleReward or BaseClass(BasePanel)

function LoveWishPossibleReward:__init(model, descStr, rewardList)
    self.model = model
    self.descStr = descStr
    self.rewardList = rewardList
    self.name = "LoveWishPossibleReward"
    self.resList = {
        {file = AssetConfig.love_possible_reward, type = AssetType.Main},
	}

    self.itemSlotList = {}
end

function LoveWishPossibleReward:__delete()
    for _, itemSlot in pairs(self.itemSlotList) do
        itemSlot:DeleteMe()
    end
    self.itemSlotList = {}

    self.rewardList = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LoveWishPossibleReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_possible_reward))
	self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
	self.transform = self.gameObject.transform

    local setting = {
        column = 5
        ,cspacing = 20
        ,rspacing = 10
        ,cellSizeX = 66
        ,cellSizeY = 66
    }

    self.goGridLayout = self.transform:Find("Main/ScrollRect/Content")
    self.gridLayout = LuaGridLayout.New(self.goGridLayout, setting)
    self.desc = self.transform:Find("Main/Desc"):GetComponent(Text)


    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button)
    self.panelBtn.onClick:AddListener(function() self:OnClose() end)

    -- local closeButton = self.transform:Find("Main/Close"):GetComponent(Button)
    -- closeButton.gameObject:SetActive(false)
    -- closeButton.onClick:AddListener(function() self:OnClose() end)
end

function LoveWishPossibleReward:OnInitCompleted()
    self:Refresh()
end

function LoveWishPossibleReward:Refresh()
    self.desc.text = self.descStr
    local rewardList = self.rewardList
    for i = 1, #rewardList do
        local itemSlot = ItemSlot.New()
        self.gridLayout:AddCell(itemSlot.gameObject)
        local reward = rewardList[i]
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[reward.id])
        itemData.quantity = reward.num
        itemSlot:SetAll(itemData)
        table.insert(self.itemSlotList, itemSlot)
    end
end

function LoveWishPossibleReward:OnClose()
    self.model:ClosePossibleReward()
end