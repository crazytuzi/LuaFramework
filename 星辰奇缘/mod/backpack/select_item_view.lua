-- 选择物品
-- ljh 2016.6.4
SelectItemWindow = SelectItemWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function SelectItemWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.selectitem
    self.name = "SelectItemWindow"
    self.friendMgr = self.model.friendMgr
    self.resList = {
        {file = AssetConfig.itemselect, type = AssetType.Main}
    }

    -----------------------------------------
    self.Layout = nil
    self.PlayerItem = nil
    self.noFriend = nil

    self.type = 1 -- 1.成就分享 2.结缘 3.极寒试炼求助
    self.selectItem = nil
    self.selectData = nil
    self.showGreyItem = false
    -----------------------------------------
    self.slotList = {}
end

function SelectItemWindow:__delete()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    self.slotList = {}
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
        self.Layout = nil
    end
    self:ClearDepAsset()
end

function SelectItemWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.itemselect))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.CloseButton = self.transform:Find("Panel")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.PlayerItem = self.transform:Find("MainCon/Item").gameObject
    self.PlayerItem:SetActive(false)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("MainCon/Con")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("MainCon/Con/Layout"), setting)

    self.okButton = self.transform:Find("MainCon/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnClickOkButton() end)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.callBack = self.openArgs[1]
        if #self.openArgs > 1 then
            self.type = self.openArgs[2]
            if #self.openArgs > 2 then
	            self.itemIdList = self.openArgs[3]
                if #self.openArgs > 3 then
                    self.showGreyItem = self.openArgs[4]
                end
	        end
        end
    end

    self.itemDataList = self.model:MakeItemList(self.type, self.itemIdList, self.showGreyItem)

    self:UpdateItemList()
end

function SelectItemWindow:Close()
    self.model:CloseMain()
end

function SelectItemWindow:UpdateItemList()
    local list = self.itemDataList
    local parent = self.transform:Find("MainCon/Con/Layout").gameObject

    for k,v in ipairs(list) do
        local key = string.format("%s_%s", v.id, v.base_id)
        local item = GameObject.Instantiate(self.PlayerItem)
        item.gameObject.name = key

        -- item.transform:Find("Red").gameObject:SetActive(flag)
        -- item.transform:Find("Red/Text"):GetComponent(Text).text = tostring(self.friendMgr.currHasMsg[key])
        self:SetItem(item, v)
        self.Layout:AddCell(item.gameObject)
    end

    self.Layout:ReSize()
end

function SelectItemWindow:SetItem(item, data)
	local itemSlot = ItemSlot.New()
    table.insert(self.slotList, itemSlot)
	UIUtils.AddUIChild(item.transform:FindChild("icon").gameObject, itemSlot.gameObject)
	itemSlot:SetAll(data)

	item.transform:FindChild("name"):GetComponent(Text).text = data.name
	item.transform:FindChild("desc"):GetComponent(Text).text = data.desc

    if data.quantity == 0 then
        itemSlot:SetGrey(true)
        item:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowItem(itemSlot) end)
    else
        item:GetComponent(Button).onClick:AddListener(function() self:OnClickPlayer(item, data) end)
    end
end

function SelectItemWindow:OnClickPlayer(item, data)
	if self.type == 1 then
		if self.selectObject ~= nil then
			self.selectObject.transform:Find("Select").gameObject:SetActive(false)
		end
		self.selectObject = item
        self.selectObject.transform:Find("Select").gameObject:SetActive(true)
    elseif self.type == 2 then
    	local selectObject = item.transform:Find("Select").gameObject
        selectObject:SetActive(not selectObject.activeSelf)
	end
end

function SelectItemWindow:OnClickOkButton()
	if self.callBack == nil then return end
    local selectDataList = {}

    if self.type == 1 then
    	if self.selectObject ~= nil then self.callBack(self.selectObject) end
    	self:Close()
    elseif self.type == 2 then
        self.callBack(selectDataList)
        self:Close()
    end
end