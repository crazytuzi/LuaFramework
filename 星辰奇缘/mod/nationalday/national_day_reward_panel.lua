-- ------------------------------------
-- 国庆活动十连抽
-- hosr
-- ------------------------------------
NationalDayRewardPanel = NationalDayRewardPanel or BaseClass(BasePanel)

function NationalDayRewardPanel:__init(model)
	self.model = model

	self.effectPath = string.format(AssetConfig.effect, "20053")
	self.effect = nil
	self.resList = {
		{file = AssetConfig.nationaldayrewardshowpanel, type = AssetType.Main},
		{file = AssetConfig.bigatlas_titlebg, type = AssetType.Main},
		{file = self.effectPath, type = AssetType.Main},
		{file = AssetConfig.national_day_res, type = AssetType.Dep},
	}
	self.OnOpenEvent:Add(function() self:OnShow() end)
	self.OnHideEvent:Add(function() self:OnHide() end)

	self.itemList = {}
	self.dataList = {}
	self.count = 0
	self.showOver = false
end

function NationalDayRewardPanel:__delete()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function NationalDayRewardPanel:OnShow()
	self.dataList = self.openArgs
	self:BeginShow()
end

function NationalDayRewardPanel:OnHide()
	self.count = 0
end

function NationalDayRewardPanel:Close()
	if self.showOver then
		self.model:CloseRewardPanel()
	end
end

function NationalDayRewardPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationaldayrewardshowpanel))
	self.gameObject.name = "NationalDayRewardPanel"
	UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

	self.transform = self.gameObject.transform
	UIUtils.AddBigbg(self.transform:Find("MainCon/Title/Image"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_titlebg)))

	self.closeBtn = self.transform:Find("MainCon/CloseButton").gameObject
	self.closeBtn:SetActive(false)
	self.closeBtn:GetComponent(Button).onClick:AddListener(function() self:Close() end)
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

	self.btn = self.transform:Find("MainCon/Button").gameObject
	self.btn:GetComponent(Button).onClick:AddListener(function()
		EventMgr.Instance:Fire(event_name.nationalday_roll10)
		self:Close()
	end)
	self.btn:SetActive(false)

	local container = self.transform:Find("MainCon/Container")
	local len = container.childCount
	for i = 1, len do
		local item = NationalDayRewardItem.New(container:GetChild(i - 1).gameObject, self)
		table.insert(self.itemList, item)
	end

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    local effectTransform = self.effect.transform
    effectTransform:SetParent(self.transform)
    effectTransform.localScale = Vector3.one
    effectTransform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(effectTransform, "UI")
    self.effect:SetActive(false)

	self:OnShow()
end

function NationalDayRewardPanel:BeginShow()
	self:EndLoop()
	self.timeId = LuaTimer.Add(0, 80, function() self:Loop() end)
end

function NationalDayRewardPanel:Loop()
	self.count = self.count + 1
	if self.count > #self.itemList then
		self:EndLoop()
		self.btn:SetActive(true)
		self.closeBtn:SetActive(true)
		return
	end
	local item = self.itemList[self.count]
	local data = self.dataList[self.count]
	item:SetData(data)
	item:ShowTime()
end

function NationalDayRewardPanel:EndLoop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
	self.showOver = true
end
