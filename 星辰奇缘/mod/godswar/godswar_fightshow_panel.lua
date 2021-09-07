-- --------------------------------
-- 诸神之战  开战展示
-- hosr
-- --------------------------------
GodsWarFightShowPanel = GodsWarFightShowPanel or BaseClass(BasePanel)

function GodsWarFightShowPanel:__init(model)
	self.model = model
	self.effectPath = "prefabs/effect/20162.unity3d"
	self.resList = {
		{file = AssetConfig.godswarfightshow, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = self.effectPath, type = AssetType.Main},
		{file = AssetConfig.maxnumber_13, type = AssetType.Dep},
	}

	self.myList = {}
	self.otherList = {}
	self.showing = false
	self.index = 1
	self.timeVal = 5
end

function GodsWarFightShowPanel:__delete()
	self:EndTime()
	self.timeImg.sprite = nil
	self.time1Img.sprite = nil
	for i,v in ipairs(self.myList) do
		v:DeleteMe()
	end
	self.myList = nil

	for i,v in ipairs(self.otherList) do
		v:DeleteMe()
	end
	self.otherList = nil

	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end

	if self.tweenId1 ~= nil then
		Tween.Instance:Cancel(self.tweenId1)
		self.tweenId1 = nil
	end
end

function GodsWarFightShowPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfightshow))
    self.gameObject.name = "GodsWarFightShowPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    -- self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Title"):GetComponent(Image).enabled = false
    self.transform:Find("Title/Image").gameObject:SetActive(false)
    self.status = self.transform:Find("Title/Status"):GetComponent(Text)
    self.iconV = self.transform:Find("Image/IconV").gameObject
    self.iconS = self.transform:Find("Image/IconS").gameObject
    self.iconVRect = self.iconV:GetComponent(RectTransform)
    self.iconVRect.anchoredPosition = Vector3(-120, 0, 0)
    self.iconSRect = self.iconS:GetComponent(RectTransform)
    self.iconSRect.anchoredPosition = Vector3(130, -20, 0)
    self.iconV:SetActive(false)
    self.iconS:SetActive(false)

    self.bule = self.transform:Find("Blue")
    self.buleObj = self.bule.gameObject
    self.buleRect = self.bule:GetComponent(RectTransform)
    for i = 1, 5 do
    	local item = GodsWarFightShowItem.New(self.bule:GetChild(i - 1).gameObject, self)
    	table.insert(self.myList, item)
    end

    self.red = self.transform:Find("Red")
    self.redObj = self.red.gameObject
    self.redRect = self.red:GetComponent(RectTransform)
    for i = 1, 5 do
    	local item = GodsWarFightShowItem.New(self.red:GetChild(i - 1).gameObject, self)
    	table.insert(self.otherList, item)
    end

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 38, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self.time = self.transform:Find("Time").gameObject
    self.timeImg = self.time:GetComponent(Image)
    self.time:SetActive(false)

    self.time1 = self.transform:Find("Time1").gameObject
    self.time1Img = self.time1:GetComponent(Image)
    self.time1:SetActive(false)

    self:OnShow()
end

function GodsWarFightShowPanel:Close()
	if self.showing then
		return
	end
	GodsWarManager.Instance.model:CloseFightShow()
end

function GodsWarFightShowPanel:OnShow()
	self.data = self.openArgs
	self:SetData()
end

function GodsWarFightShowPanel:SetData()
	self.status.text = GodsWarEumn.ShowStr()

	for i,team in ipairs(self.data) do
		if team.tid == GodsWarManager.Instance.myData.tid then
			for j,v in ipairs(self.myList) do
				v:SetData(team.members[j])
			end
		else
			for j,v in ipairs(self.otherList) do
				v:SetData(team.members[j])
			end
		end
	end

	self.showing = true
	self:FlyIn()
end

-- 双方左右飞入
function GodsWarFightShowPanel:FlyIn()
	local myItem = self.myList[self.index]
	local otherItem = self.otherList[self.index]

	self.tweenId = Tween.Instance:MoveLocalX(myItem.gameObject, 150 - 30 * (self.index - 1), 0.1, nil, LeanTweenType.easeOutSine).id
	self.tweenId1 = Tween.Instance:MoveLocalX(otherItem.gameObject, -30 * self.index, 0.1, nil, LeanTweenType.easeOutSine).id
	self.index = self.index + 1
	if self.index <= 5 then
		LuaTimer.Add(100, function() self:FlyIn() end)
	else
		self:ShowV()
		self:ShowS()
		LuaTimer.Add(100, function() self:ShowEnd() end)
	end
end

-- VS表现效果
function GodsWarFightShowPanel:ShowV()
    self.iconV:SetActive(true)
	Tween.Instance:MoveLocalX(self.iconV, -20, 0.1, nil, LeanTweenType.easeInQuart)
end

function GodsWarFightShowPanel:ShowS()
    self.iconS:SetActive(true)
	Tween.Instance:MoveLocalX(self.iconS, 32, 0.1, nil, LeanTweenType.easeInQuart)
end

function GodsWarFightShowPanel:ShowEnd()
	self.showing = false
	self.effect:SetActive(true)
	LuaTimer.Add(500, function() self:ShowTime() end)
end

function GodsWarFightShowPanel:ShowTime()
	self:EndTime()
	self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function GodsWarFightShowPanel:Loop()
	local list = StringHelper.ConvertStringTable(tostring(self.timeVal))
	-- if #list == 1 then
	-- 	table.insert(list, 1, "0")
	-- end

	self.timeImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_13, string.format("Num13_%s", list[1]))
	self.timeImg:SetNativeSize()
	self.time:SetActive(true)

	-- self.time1Img.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_13, string.format("Num13_%s", list[2]))
	-- self.time1Img:SetNativeSize()
	-- self.time1:SetActive(true)

	self.timeVal = self.timeVal - 1
	if self.timeVal < 0 then
		self:EndTime()
		self:Close()
	end
end

function GodsWarFightShowPanel:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end
