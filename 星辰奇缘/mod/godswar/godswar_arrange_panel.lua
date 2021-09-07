-- -------------------------------
-- 诸神之战 -- 安排界面
-- hosr
-- -------------------------------
GodsWarArrangePanel = GodsWarArrangePanel or BaseClass(BasePanel)

function GodsWarArrangePanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarprogress, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.isInit = false
    self.progressList = {}
    self.itemList = {}
    self.setDataListener = function() self:SetData() end
    self.sliderList = {70, 300, 600}
end

function GodsWarArrangePanel:__delete()
    GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.setDataListener)
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil

	for i,v in ipairs(self.progressList) do
		v:DeleteMe()
	end
	self.progressList = nil

end

function GodsWarArrangePanel:OnShow()

    GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.setDataListener)
    GodsWarManager.Instance.OnUpdateTime:AddListener(self.setDataListener)
    -- GodsWarManager.Instance:Send17933()
    self:SetData()
	self:UpadteProgress()
end

function GodsWarArrangePanel:OnHide()
end

function GodsWarArrangePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarprogress))
    self.gameObject.name = "GodsWarArrangePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.container)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2.zero

    local progress = self.transform:Find("Progress")
    for i = 1, 3 do
    	local pro = GodsWarProgressItem.New(progress:Find(string.format("Item%s", i)).gameObject, self)
    	table.insert(self.progressList, pro)
    end

    self.sliderRect = progress:Find("Slider"):GetComponent(RectTransform)

    local part1 = self.transform:Find("Part1")
    -- self.btn = part1:Find("Button").gameObject
    -- self.btn:GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance:SignUp() end)
    -- self.btnTxt = part1:Find("Button/Text"):GetComponent(Text)

    table.insert(self.itemList, GodsWarArrangeItem.New(part1:Find("Item1").gameObject, self))
    table.insert(self.itemList, GodsWarArrangeItem.New(part1:Find("Item2").gameObject, self))

    self.part2 = self.transform:Find("Part2/Scroll/Container")
    self.part2Rect = self.part2:GetComponent(RectTransform)

    self.part3 = self.transform:Find("Part3/Scroll/Container")
    self.part3Rect = self.part3:GetComponent(RectTransform)

    self.itemBase = self.transform:Find("Item").gameObject

    -- self:SetData()
    self:OnShow()
end

function GodsWarArrangePanel:SetData()
    if GodsWarManager.Instance.godwarTimeData == nil or self.isInit == true then
        return
    end
    self.isInit = true
	local list = GodsWarManager.Instance.godwarTimeData
	local h = 0

	self.itemList[1]:SetData(list[2])
	self.itemList[2]:SetData(list[3])

	for i = 5, #list, 2 do
		local v = list[i]
		local item = GodsWarArrangeItem.New(GameObject.Instantiate(self.itemBase), self)
		item:SetData(v)
		table.insert(self.itemList, item)

		if i <= 9 then
			item.transform:SetParent(self.part2)
		else
			item.transform:SetParent(self.part3)
		end
		item.transform.localScale = Vector3.one
		item.rect.anchoredPosition = Vector2(0, -h)

		h = h + item.height + 5

		if i == 9 then
			self.part2Rect.sizeDelta = Vector2(210, h)
			h = 0
		end
	end
	self.part3Rect.sizeDelta = Vector2(210, h)
end

function GodsWarArrangePanel:UpadteProgress()
	local status = GodsWarManager.Instance.status
	local index = 1
	if status <= GodsWarEumn.Step.Publicity then
		index = 1
	elseif status >= GodsWarEumn.Step.Audition1Idel and status <= GodsWarEumn.Step.Audition7 then
		index = 2
	elseif status >= GodsWarEumn.Step.Elimination32Idel and status <= GodsWarEumn.Step.Final then
		index = 3
	end

	for i,v in ipairs(self.progressList) do
		if i <= index then
			self.progressList[i]:Doing()
		end
	end
	self.sliderRect.sizeDelta = Vector2(self.sliderList[index], 14)

	for i,v in ipairs(self.itemList) do
		v:Select(false)
	end

	if status <= GodsWarEumn.Step.Sign then
		self.itemList[1]:Select(true)
	elseif status == GodsWarEumn.Step.Publicity then
		self.itemList[2]:Select(true)
	elseif status <= GodsWarEumn.Step.Audition1 then
		self.itemList[3]:Select(true)
	elseif status <= GodsWarEumn.Step.Audition2 then
		self.itemList[4]:Select(true)
	elseif status <= GodsWarEumn.Step.Audition3 then
		self.itemList[5]:Select(true)

	elseif status <= GodsWarEumn.Step.Elimination32 then
		self.itemList[6]:Select(true)
	elseif status <= GodsWarEumn.Step.Elimination16 then
		self.itemList[7]:Select(true)
	elseif status <= GodsWarEumn.Step.Elimination8 then
		self.itemList[8]:Select(true)
	elseif status <= GodsWarEumn.Step.Elimination4 then
		self.part3Rect.anchoredPosition = Vector3(0, 185, 0)
		self.itemList[9]:Select(true)
	elseif status <= GodsWarEumn.Step.Semifinal then
		self.itemList[10]:Select(true)
		self.part3Rect.anchoredPosition = Vector3(0, 185, 0)
	elseif status <= GodsWarEumn.Step.Thirdfinal then
		self.itemList[11]:Select(true)
		self.part3Rect.anchoredPosition = Vector3(0, 185, 0)
	elseif status <= GodsWarEumn.Step.Final then
		self.itemList[12]:Select(true)
		self.part3Rect.anchoredPosition = Vector3(0, 185, 0)
	end
end