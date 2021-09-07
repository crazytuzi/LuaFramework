-- 藏宝图抽奖界面

TreasuremapView = TreasuremapView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

function TreasuremapView:__init(model)
    self.model = model
    self.name = "TreasuremapView"
    self.windowId = WindowConfig.WinID.treasuremapwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.treasuremapwindow, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    ------------------------------------------------
    self.Button = nil
    self.select = nil
    self.item_list = {}
    self.itemSlot_list = {}
    self.roll_count = 0
	self.select_id = 1
    self.reward2 = nil
    self.reward3 = nil
    self.reward4 = nil
    self.show = false

    self.roll_speed = 1

    ------------------------------------------------
    self._Update = function()
        self:Update()
    end

    self._Roll = function()
    	self:Roll()
	end
    ------------------------------------------------

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function TreasuremapView:__delete()
    for k,v in pairs(self.itemSlot_list) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function TreasuremapView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasuremapwindow))
    self.gameObject.name = "TreasuremapView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    local transform = self.transform

    local closeBtn = transform:FindChild("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.Button = transform:FindChild("Main/Button"):GetComponent(Button)
    self.Button.onClick:AddListener( function() self:GetReward() end )

    self.select = transform:FindChild("Main/Panel/Select").gameObject
    self.reward2 = transform:FindChild("Main/Reward2").gameObject
    self.reward3 = transform:FindChild("Main/Reward3").gameObject
    self.reward4 = transform:FindChild("Main/Reward4").gameObject

    local item = nil
    for i = 1, 12 do
    	item = transform:FindChild("Main/Panel/Item"..i).gameObject
    	item.name = tostring(i)
    	table.insert(self.item_list, item)
    end

    -------------------------------------------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function TreasuremapView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TreasuremapView:OnShow()
    EventMgr.Instance:AddListener(event_name.treasuremap_update, self._Update)
    self.show = true
    self:Update()
end

function TreasuremapView:OnHide()
	EventMgr.Instance:RemoveListener(event_name.treasuremap_update, self._Update)
	self.show = false

    self:SendGetReward()
end

function TreasuremapView:Update()
	if self.gameObject == nil or not self.show then return end

    if self.model.status == 1 then
    	for i = 1, 12 do
            local item = self.item_list[i]
            local data = self.model.item_list[i]
            if data.type == 1 then
                local item_basedata = BackpackManager.Instance:GetItemBase(data.val)
                if item_basedata ~= nil then
                    local itemSlot = ItemSlot.New()
    				UIUtils.AddUIChild(item.transform:FindChild("Image").gameObject, itemSlot.gameObject)
                    local itemData = ItemData.New()
                    itemData:SetBase(item_basedata)
                    if item_basedata.id < 90000 then itemData.quantity = data.num end
                    itemSlot:SetAll(itemData)
                    item.transform:FindChild("Text"):GetComponent(Text).text = ColorHelper.color_item_name(itemData.quality, itemData.name)
                end
                -- if item_basedata.quality < 3 then
                --     item.transform:FindChild("Special").gameObject:SetActive(false)
                -- else
                --     item.transform:FindChild("Special").gameObject:SetActive(true)
                -- end
            elseif data.type == 2 then
                -- item.transform:FindChild("Special").gameObject:SetActive(true)
                UIUtils.AddUIChild(item.transform:FindChild("Image").gameObject, GameObject.Instantiate(self.reward2))
                item.transform:FindChild("Text"):GetComponent(Text).text = TI18N("特殊宝藏")
            elseif data.type == 3 then
                -- item.transform:FindChild("Special").gameObject:SetActive(false)
                UIUtils.AddUIChild(item.transform:FindChild("Image").gameObject, GameObject.Instantiate(self.reward3))
                item.transform:FindChild("Text"):GetComponent(Text).text = TI18N("遇袭")
            elseif data.type == 4 then
                -- item.transform:FindChild("Special").gameObject:SetActive(false)
                UIUtils.AddUIChild(item.transform:FindChild("Image").gameObject, GameObject.Instantiate(self.reward4))
                item.transform:FindChild("Text"):GetComponent(Text).text = TI18N("魔盒")
            end
    	end
    	self.select_id = 1
    	self.roll_count = 72 + self.model.gain_id
        self.roll_speed = 1
		LuaTimer.Add(500, self._Roll)
    else
    	self:OnClickClose()
    end
end

function TreasuremapView:GetReward()
    if self.gameObject == nil or not self.show then return end

    -- self:OnClickClose()
    self.roll_speed = 2

    BaseUtils.SetGrey(self.Button.gameObject:GetComponent(Image), true)
end

function TreasuremapView:Roll()
    if self.gameObject == nil or not self.show then return end

	if self.roll_count == 0 then
        self:OnClickClose()
    else
        local p = self.item_list[self.select_id].transform.position
        self.select.transform.position = p

		self.roll_count = self.roll_count - 1
		if self.roll_count > 24 then
    		LuaTimer.Add(50, self._Roll)
    	elseif self.roll_count > 12 then
            BaseUtils.SetGrey(self.Button.gameObject:GetComponent(Image), true)
    		LuaTimer.Add(80, self._Roll)
    	elseif self.roll_count > 8 then
    		LuaTimer.Add(100, self._Roll)
    	elseif self.roll_count > 5 then
    		LuaTimer.Add(150, self._Roll)
    	elseif self.roll_count > 4 then
    		LuaTimer.Add(200, self._Roll)
    	elseif self.roll_count > 3 then
    		LuaTimer.Add(300, self._Roll)
    	elseif self.roll_count > 2 then
    		LuaTimer.Add(400, self._Roll)
    	elseif self.roll_count > 1 then
    		LuaTimer.Add(500, self._Roll)
    	else
    		LuaTimer.Add(1000, self._Roll)
    	end

        if self.roll_speed == 2 and self.roll_count > 12 and self.roll_count % 12 == 1 then self.roll_count = 13 end

        self.select_id = self.select_id + 1
        if self.select_id > 12 then self.select_id = 1 end
    end
end

function TreasuremapView:SendGetReward()
    TreasuremapManager.Instance:Send13601() -- 关闭界面领取奖励

    -- 如果奖励类型是 1:道具 4:封妖，则使用背包剩余的藏宝图
    if BackpackManager.Instance:GetCurrentGirdNum() > 0 then
        for i = 1, #self.model.item_list do
            local data = self.model.item_list[i]
            if self.model.gain_id == data.id then
                -- print(string.format("挖到的奖励是 %s", data.type))
                if data.type == 1 or data.type == 4 then
                    local item_list = BackpackManager.Instance:GetItemByBaseid(20052)
                    if #item_list > 0 then
                        LuaTimer.Add(1000, function() self.model:use_treasuremap(item_list[1]) end)
                        return
                    end

                    item_list = BackpackManager.Instance:GetItemByBaseid(20053)
                    if #item_list > 0 then
                        LuaTimer.Add(1000, function() self.model:use_treasuremap(item_list[1]) end)
                        return
                    end
                end
                return
            end
        end
    end
end
