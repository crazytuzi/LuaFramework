-- 结缘纪念日界面
-- ljh 20160829
WeddingDayWindow = WeddingDayWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function WeddingDayWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.weddingday_window
    self.name = "WeddingDayWindow"
    self.resList = {
        {file = AssetConfig.weddingday_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.witch_girl, type = AssetType.Dep}
    }

    -----------------------------------------
    self.itemSolt = nil

    self.package_id = 0
    self.canReceive = false

    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end
end

function WeddingDayWindow:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end

    self:OnHide()

    self:ClearDepAsset()
end

function WeddingDayWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.weddingday_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:Find("Main")

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.mainTransform:Find("WitchImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl, "Witch")

    self.okButton = self.mainTransform:FindChild("Panel/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.mainTransform:FindChild("Panel/Item").gameObject, self.itemSolt.gameObject)

    self:OnShow()

    LuaTimer.Add(50, function()
            if not BaseUtils.isnull(self.transform) then
                self.transform:Find("Panel").gameObject:AddComponent(Button).onClick:AddListener(function() self:Close() end)
            end
        end)
end

function WeddingDayWindow:Close()
    self:OnHide()

    -- WindowManager.Instance:CloseWindow(self)
    -- self.model:CloseWeddingDayWindow()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marriage_certificate_window)
end

function WeddingDayWindow:OnShow()
	EventMgr.Instance:AddListener(event_name.lover_data, self._Update)
	if MarryManager.Instance.loverData == nil then
		MarryManager.Instance:Send15014()
	end
    MarryManager.Instance:Send15025()
end

function WeddingDayWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.lover_data, self._Update)
end

function WeddingDayWindow:Update()
    self.package_id = 0
	local package_data = nil
    local package_times = 0
	local weddingday_data = nil
	local loverData = MarryManager.Instance.loverData
	local day = math.floor((BaseUtils.BASE_TIME-loverData.time)/3600/24)

	for _,value in pairs(self.model.wedding_package_list) do
		if package_data == nil and (value.times == 0 or DataWedding.data_wedding_package[value.id].day == 365) then
			package_data = DataWedding.data_wedding_package[value.id]
            self.package_id = value.id
            package_times = value.times
		end
	end

	for i,value in ipairs(DataWedding.data_weddingday) do
		if weddingday_data == nil or day >= value.day then
			weddingday_data = value
		end
	end

    if package_data == nil or weddingday_data == nil then
        Log.Error(TI18N("礼包数据出错"))
        return
    end

	self.mainTransform:FindChild("DescText"):GetComponent(Text).text = TI18N("结缘时间达到纪念日可领取<color='#008800'>丰厚奖励</color>~1周年以后每年可领取<color='#008800'>周年奖励</color>哦~")

	self.mainTransform:FindChild("TimeText"):GetComponent(Text).text = string.format(TI18N("你们已经结缘：<color='#20cbd9'>%s天(%s)</color>"), tostring(day), weddingday_data.name)
	self.mainTransform:FindChild("Panel/MarryText"):GetComponent(Text).text = package_data.name
	self.mainTransform:FindChild("Panel/TimeText"):GetComponent(Text).text = string.format(TI18N("结缘<color='#00ff00'>%s天</color>"), package_data.day)

	local itembase = BackpackManager.Instance:GetItemBase(package_data.item_id)
	local itemData = ItemData.New()
	itemData:SetBase(itembase)
	self.itemSolt:SetAll(itemData)

    local receive_day = package_data.day * (package_times+1)
    if receive_day > day then
        self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("确定")
        self.okButton.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
        self.canReceive = false
        local hours = (receive_day - day) * 24
        local next_day = math.floor(hours/24)
        local next_hour = hours % 24
        if next_hour == 0 then
            self.mainTransform:FindChild("NextTimeText"):GetComponent(Text).text = string.format(TI18N("距下次纪念日：%s天"), next_day)
        else
            self.mainTransform:FindChild("NextTimeText"):GetComponent(Text).text = string.format(TI18N("距下次纪念日：%s天%小时"), next_day, next_hour)
        end
    else
        self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("领取")
        self.okButton.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2

        self.canReceive = true
        self.mainTransform:FindChild("NextTimeText"):GetComponent(Text).text = ""
    end
end

function WeddingDayWindow:okButtonClick()
    if self.package_id ~= 0 then
        if self.canReceive then
            MarryManager.Instance:Send15026(self.package_id)
        else
            self:Close()
        end
    end
end
