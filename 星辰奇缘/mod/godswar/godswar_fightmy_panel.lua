-- -------------------------------------------------
-- 诸神之战 我的战斗信息
-- hosr
-- -------------------------------------------------
GodsWarFightMyPanel = GodsWarFightMyPanel or BaseClass(BasePanel)

function GodsWarFightMyPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarfightmy, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.myList = {}
    self.otherList = {}
end

function GodsWarFightMyPanel:__delete()
	for i,v in ipairs(self.myList) do
		v:DeleteMe()
	end
	self.myList = nil

	for i,v in ipairs(self.otherList) do
		v:DeleteMe()
	end
	self.otherList = nil
end

function GodsWarFightMyPanel:OnShow()
	self:Update()
	-- if GodsWarManager.Instance.myFighter == nil then
	-- 	GodsWarManager.Instance:Send17918()
	-- end
end

function GodsWarFightMyPanel:OnHide()
end

function GodsWarFightMyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfightmy))
    self.gameObject.name = "GodsWarFightMyPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -25)

    self.tips = self.transform:Find("Tips/Text"):GetComponent(Text)
    self.tips.text = ""

	self.title1 = self.transform:Find("Item1/Title/Text"):GetComponent(Text)
	self.name1 = self.transform:Find("Item1/Title/Name"):GetComponent(Text)
	local container = self.transform:Find("Item1/Container")
	local len = container.childCount
	for i = 1, len do
		local item = GodsWarFightMyItem.New(container:GetChild(i - 1).gameObject, self)
		table.insert(self.myList, item)
	end

	self.title2 = self.transform:Find("Item2/Title/Text"):GetComponent(Text)
	self.name2 = self.transform:Find("Item2/Title/Name"):GetComponent(Text)
	container = self.transform:Find("Item2/Container")
	len = container.childCount
	for i = 1, len do
		local item = GodsWarFightMyItem.New(container:GetChild(i - 1).gameObject, self)
		table.insert(self.otherList, item)
	end

	self.item1 = self.transform:Find("Item1").gameObject
	self.item2 = self.transform:Find("Item2").gameObject
	self.mid = self.transform:Find("Mid").gameObject
	self.nothing = self.transform:Find("Nothing").gameObject

	self:OnShow()
end

function GodsWarFightMyPanel:Update()
	if GodsWarManager.Instance.myFighter.flag == 2 then
		-- 轮空
		self.nothing:SetActive(true)
		self.item1:SetActive(false)
		self.item2:SetActive(false)
		self.mid:SetActive(false)
	else
		self.nothing:SetActive(false)
		self.item1:SetActive(true)
		self.item2:SetActive(true)
		self.mid:SetActive(true)
	end

	if GodsWarManager.Instance.myData == nil then
		return
	end

	local status = GodsWarManager.Instance.status
	self.tips.text = string.format(TI18N("%s于<color='#ffff00'>%s</color>进行，请提前进入准备场地"), GodsWarEumn.ShowStr(), GodsWarEumn.MatchTime(status))

	self.name1.text = ""
	self.name2.text = ""

	self.myData = GodsWarManager.Instance.myData
	local list = self.myData.members
	table.sort(list, function(a,b)
        if a.position ~= b.position then
            return a.position < b.position
        else
            return a.fight_capacity > b.fight_capacity
        end
	end)
	for i,item in ipairs(self.myList) do
		local data = list[i]
		item:SetData(data)
	end

	local str = ""
	if GodsWarManager.Instance.myCurrentResult == 1 then
		str = TI18N("胜利方")
	elseif GodsWarManager.Instance.myCurrentResult == 0 then
		str = TI18N("失败方")
	end
	self.name1.text = string.format("%s-%s  %s", self.myData.name, BaseUtils.GetServerNameMerge(self.myData.platform, self.myData.zone_id), str)

	if GodsWarManager.Instance.myFighter == nil then
		for i,item in ipairs(self.otherList) do
			item:SetData(nil)
		end
	else
		self.fighter = GodsWarManager.Instance.myFighter
		local str = ""
		if GodsWarManager.Instance.myCurrentResult == 1 then
			str = TI18N("失败方")
		elseif GodsWarManager.Instance.myCurrentResult == 0 then
			str = TI18N("胜利方")
		end
		self.name2.text = string.format("%s-%s  %s", self.fighter.name, BaseUtils.GetServerNameMerge(self.fighter.platform, self.fighter.zone_id), str)

		for i,item in ipairs(self.otherList) do
			local data = self.fighter.members[i]
			item:SetData(data)
		end
	end

end