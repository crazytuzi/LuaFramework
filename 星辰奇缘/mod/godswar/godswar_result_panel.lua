-- ------------------------
-- 诸神之战 战队结果展示界面
-- hosr
-- ------------------------

GodsWarResultPanel = GodsWarResultPanel or BaseClass(BasePanel)

function GodsWarResultPanel:__init(model)
	self.model = model
    self.effectPath = "prefabs/effect/20162.unity3d"
	self.resList = {
		{file = AssetConfig.godswarresult, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
		{file = self.effectPath, type = AssetType.Main},
		{file = AssetConfig.godswarresultbg, type = AssetType.Main},
	}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.canClose = false
end

function GodsWarResultPanel:__delete()
end

function GodsWarResultPanel:OnShow()
	self.data = self.openArgs

	self:SetData()
end

function GodsWarResultPanel:OnHide()
end

function GodsWarResultPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarresult))
    self.gameObject.name = "GodsWarResultPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.godswarresultbg, "GodsWarResultBg")

    self.winImg = self.transform:Find("ResultImg1").gameObject
    self.winImg.transform.localScale = Vector3.one * 2
    self.winImg:SetActive(false)

    self.failImg = self.transform:Find("ResultImg2").gameObject
    self.failImg.transform.localScale = Vector3.one * 2
    self.failImg:SetActive(false)

    self.desc = self.transform:Find("Desc/Text"):GetComponent(Text)

    self.clickGo = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.clickGo.transform:SetParent(self.transform)
    self.clickGo.transform.localScale = Vector3.one
    self.clickGo.transform.localPosition = Vector3(0, 80, -400)
    Utils.ChangeLayersRecursively(self.clickGo.transform, "UI")
    self.clickGo:SetActive(false)

    self:OnShow()
end

function GodsWarResultPanel:SetData()
	if self.data.result == 0 then
		self:Loss()
	else
		self:Win()
	end
	LuaTimer.Add(2000, function() self.canClose = true end)
end

function GodsWarResultPanel:Win()
	self.winImg:SetActive(true)
	local status = GodsWarManager.Instance.status
	if status >= GodsWarEumn.Step.Audition1Idel and status <= GodsWarEumn.Step.Audition7 then
		self.desc.text = TI18N("小组积分+3")
	elseif status == GodsWarEumn.Step.Elimination32 then
		self.desc.text = TI18N("晋级32强")
	elseif status == GodsWarEumn.Step.Elimination16 then
		self.desc.text = TI18N("晋级16强")
	elseif status == GodsWarEumn.Step.Elimination8 then
		self.desc.text = TI18N("晋级8强")
	elseif status == GodsWarEumn.Step.Elimination4 then
		self.desc.text = TI18N("晋级半决赛")
	elseif status == GodsWarEumn.Step.Semifinal then
		self.desc.text = TI18N("晋级决赛")
	elseif status == GodsWarEumn.Step.Thirdfinal then
		self.desc.text = TI18N("获得季军")
	elseif status == GodsWarEumn.Step.Final then
		self.desc.text = TI18N("获得冠军")
	end
	Tween.Instance:Scale(self.winImg, Vector3.one, 0.5, nil, LeanTweenType.easeOutElastic)
	LuaTimer.Add(100, function() self.clickGo:SetActive(true) end)
end

function GodsWarResultPanel:Loss()
	self.failImg:SetActive(true)
	local status = GodsWarManager.Instance.status
	if status >= GodsWarEumn.Step.Audition1Idel and status <= GodsWarEumn.Step.Audition7 then
		self.desc.text = TI18N("小组积分+1")
	elseif status == GodsWarEumn.Step.Elimination32 then
		self.desc.text = TI18N("未晋级32强")
	elseif status == GodsWarEumn.Step.Elimination16 then
		self.desc.text = TI18N("未晋级16强")
	elseif status == GodsWarEumn.Step.Elimination8 then
		self.desc.text = TI18N("未晋级8强")
	elseif status == GodsWarEumn.Step.Elimination4 then
		self.desc.text = TI18N("未晋级半决赛")
	elseif status == GodsWarEumn.Step.Semifinal then
		self.desc.text = TI18N("晋级季军赛")
	elseif status == GodsWarEumn.Step.Thirdfinal then
		self.desc.text = TI18N("获得第四名")
	elseif status == GodsWarEumn.Step.Final then
		self.desc.text = TI18N("获得亚军")
	end
	Tween.Instance:Scale(self.failImg, Vector3.one, 0.5, nil, LeanTweenType.easeOutElastic)
end

function GodsWarResultPanel:Close()
	if self.canClose then
		self.model:CloseFightResult()
	end
end