-- --------------------------------------
-- 首充宠物展示
-- hosr
-- --------------------------------------
FirstRechargePetShowPanel = FirstRechargePetShowPanel or BaseClass(BasePanel)

function FirstRechargePetShowPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.rechargeshowpet, type = AssetType.Main},
		{file = AssetConfig.bigatlas_rechargepet, type = AssetType.Main},
		{file = AssetConfig.rechargeshowpet_res, type = AssetType.Dep},
	}
    self.setting = {
        name = "RechargePetPreview"
        ,orthographicSize = 0.35
        ,width = 200
        ,height = 150
        ,offsetY = -0.2
    }
	self.previewCallback = function(composite) self:SetRawImage(composite) end

	self.canClick = false
end

function FirstRechargePetShowPanel:__delete()
	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end
end

function FirstRechargePetShowPanel:Close()
	self.model:ClosePetShow()
end

function FirstRechargePetShowPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rechargeshowpet))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
	UIUtils.AddBigbg(self.transform:Find("Main/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_rechargepet)))

	self.main = self.transform:Find("Main").gameObject
	self.mainTrans = self.main.transform
	self.transform:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:ClickPanel() end)
	self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:TweenClose() end)
	self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:ClickButton() end)
	self.rawImage = self.transform:Find("Main/Preview").gameObject

	self.empty = self.transform:Find("Empty")

	self:Preview()
	self:TweenShow()
	self:BeginTime()
end

function FirstRechargePetShowPanel:TweenShow()
	self.canClick = false
	local target = MainUIManager.Instance.MainUIIconView:getbuttonbyid(107)
	if target ~= nil then
		local pos = target.transform.position
		local t = Vector3(pos.x + 0.2, 1.7, 0)
		self.mainTrans.position = t
		self.mainTrans.localScale = Vector3.one * 0.2

		Tween.Instance:Move(self.main, self.empty.transform.position, 0.4, function() self:ShowEnd() end, LeanTweenType.linear)
		Tween.Instance:Scale(self.main, Vector3.one, 0.4, nil, LeanTweenType.linear)
	else
		self:ShowEnd()
	end
end

function FirstRechargePetShowPanel:ShowEnd()
	self.canClick = true
end

function FirstRechargePetShowPanel:TweenClose()
	self.canClick = false
	self:EndTime()
	local target = MainUIManager.Instance.MainUIIconView:getbuttonbyid(107)
	if target ~= nil then
		local pos = target.transform.position
		local t = Vector3(pos.x + 0.2, 1.7, 0)
		Tween.Instance:Move(self.main, t, 0.5, function() self:TweenEnd() end, LeanTweenType.linear)
	end
	Tween.Instance:Scale(self.main, Vector3.one * 0.2, 0.5, nil, LeanTweenType.linear)
end

function FirstRechargePetShowPanel:TweenEnd()
	self.canClick = true
	self:Close()
end

function FirstRechargePetShowPanel:ClickButton()
	if not self.canClick then
		return
	end

	self:TweenClose()
	LuaTimer.Add(200, function()
		-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3})
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
	end)
end

function FirstRechargePetShowPanel:ClickPanel()
	if not self.canClick then
		return
	end

	self:TweenClose()
	LuaTimer.Add(200, function()
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
	end)
end

function FirstRechargePetShowPanel:BeginTime()
	self:EndTime()
	self.time = LuaTimer.Add(10000, function() self:TimeOver() end)
end

function FirstRechargePetShowPanel:EndTime()
	if self.time ~= nil then
		LuaTimer.Delete(self.time)
		self.time = nil
	end
end

function FirstRechargePetShowPanel:TimeOver()
	self:TweenClose()
end

function FirstRechargePetShowPanel:Preview()
    local base = DataPet.data_pet[10000]
    local data = {type = PreViewType.Pet, skinId = base.skin_id_0, modelId = base.model_id, animationId = base.animation_id, scale = base.scale / 100, effects = base.effects}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, data)
    else
        self.previewComp:Reload(data, self.previewCallback)
    end
end

function FirstRechargePetShowPanel:SetRawImage(composite)
    if self.gameObject == nil then
        return
    end

    local image = composite.rawImage
    if image == nil then
        return
    end
    image.transform:SetParent(self.rawImage.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3(0, 0, 0)
    composite.tpose.transform:Rotate(Vector3(0, 25, 0))
    self.rawImage:SetActive(true)
end