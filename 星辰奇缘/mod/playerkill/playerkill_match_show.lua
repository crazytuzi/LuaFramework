-- -------------------------------
-- 英雄擂台匹配展示
-- hosr
-- -------------------------------
PlayerkillMatchShow = PlayerkillMatchShow or BaseClass()

function PlayerkillMatchShow:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent
	self.transform = gameObject.transform
	self.gameObject:SetActive(false)

	self.itemList = {}

	self.index = 1
	self:InitPanel()
end

function PlayerkillMatchShow:__delete()
	self:EndLoopChange()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function PlayerkillMatchShow:InitPanel()
	self.transform:Find("Panel").gameObject:SetActive(false)
	for i = 1, 2 do
		local item = PlayerkillMatchItem.New(self.transform:Find("Item" .. i), self)
		table.insert(self.itemList, item)
	end
end

function PlayerkillMatchShow:Hide()
	self.gameObject:SetActive(false)
	self:EndLoopChange()
end

-- 开始匹配展示
function PlayerkillMatchShow:Show()
	self.gameObject:SetActive(true)
	self.dataList = PlayerkillManager.Instance.matchList

	table.insert(self.dataList, PlayerkillEumn.GetDefaultMatchRole())
	table.insert(self.dataList, PlayerkillEumn.GetDefaultMatchRole())
	table.insert(self.dataList, PlayerkillEumn.GetDefaultMatchRole())
	table.insert(self.dataList, PlayerkillEumn.GetDefaultMatchRole())
	table.insert(self.dataList, PlayerkillEumn.GetDefaultMatchRole())
	table.insert(self.dataList, PlayerkillEumn.GetDefaultMatchRole())

	self.itemList[1]:SetMyData()
	self.itemList[2]:SetOtherData()
	-- self:ChangeEnemy()
end

-- 匹配取消
function PlayerkillMatchShow:Cancel()
	self:EndLoopChange()
end

-- 匹配成功
function PlayerkillMatchShow:Success()
	self:EndLoopChange()
	self.itemList[2]:SetData(PlayerkillManager.Instance.enemyData)
end

-- 匹配中每隔两秒更换一次对手数据
function PlayerkillMatchShow:ChangeEnemy()
	self:EndLoopChange()
	self.changeId = LuaTimer.Add(0, 500, function() self:LoopChange() end)
end

function PlayerkillMatchShow:LoopChange()
	if self.index > #self.dataList then
		self.index = 1
	end
	local data = self.dataList[self.index]
	self.index = self.index + 1
	self.itemList[2]:SetData(data)
end

function PlayerkillMatchShow:EndLoopChange()
	if self.changeId ~= nil then
		LuaTimer.Delete(self.changeId)
		self.changeId = nil
	end
end