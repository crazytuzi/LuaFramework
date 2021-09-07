-- --------------------------------------------
-- 新手头饰展示
-- hosr
-- --------------------------------------------
GuideHatShow = GuideHatShow or BaseClass(BasePanel)

function GuideHatShow:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.guidehatshow, type = AssetType.Main},
		{file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
		{file = AssetConfig.fashion_big_icon2, type = AssetType.Dep},
	}
	self.timeId = nil
end

function GuideHatShow:__delete()
	self:EndRotate()
	self:EndTime()
	self.iconImg.sprite = nil
end

function GuideHatShow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guidehatshow))
    self.gameObject.name = "GuideHatShow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.panelImg = self.transform:Find("Panel"):GetComponent(Image)

    self.icon = self.transform:Find("Icon").gameObject
    self.iconImg = self.icon:GetComponent(Image)
    self.iconRect = self.icon:GetComponent(RectTransform)
    self.iconTrans = self.icon.transform
    self.iconTrans.localScale = Vector3.one * 0.5

    self.bg = self.transform:Find("Bg1")

    self.target = self.transform:Find("Target")

    self:SetData()
end

function GuideHatShow:SetData()
	self:HideBtn()
	self.iconImg.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_big_icon2, "53045")
	self.iconImg:SetNativeSize()
	self.iconRect.anchoredPosition = Vector3.zero

	self:Rotate()
	self:ScaleShow()
end

function GuideHatShow:Rotate()
	self.rotateId = LuaTimer.Add(0, 50, function() self:LoopRotate() end)
end

function GuideHatShow:LoopRotate()
	self.bg:Rotate(Vector3(0, 0, -2))
end

function GuideHatShow:EndRotate()
	if self.rotateId ~= nil then
		LuaTimer.Delete(self.rotateId)
		self.rotateId = nil
	end
end

function GuideHatShow:ScaleShow()
	Tween.Instance:Scale(self.icon, Vector3.one, 0.3, function() self:ShowEnd() end, LeanTweenType.easeOutElastic)
end

function GuideHatShow:ShowEnd()
	self:EndTime()
	self:HideBtn()
	self.timeId = LuaTimer.Add(1000, function() self:Fly() end)
end

function GuideHatShow:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function GuideHatShow:Fly()
	self:EndTime()
	self:HideBtn()
	self:EndRotate()
	self.bg.gameObject:SetActive(false)
    Tween.Instance:Scale(self.icon, Vector3.one * 0.5, 1)
    Tween.Instance:Move(self.icon, self.target.position, 0.8, function() self:FlyEnd() end)
    self.panelImg.color = Color(1, 1, 1, 0)
end

function GuideHatShow:FlyEnd()
	if self.btn ~= nil and not BaseUtils.isnull(self.btn.gameObject) then
		self.btn.gameObject:SetActive(true)
	end
	self:Close()
end

function GuideHatShow:Close()
	self.model:CloseGuideHatShow()
end

function GuideHatShow:HideBtn()
	self.btn = MainUIManager.Instance.MainUIIconView:getbuttonbyid(205)
	if self.btn ~= nil and not BaseUtils.isnull(self.btn.gameObject) then
		self.btn.gameObject:SetActive(false)
	end
end