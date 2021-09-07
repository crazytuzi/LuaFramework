-- -------------------------------
-- 幻化所有卡片陈列界面
-- hosr
-- -------------------------------
HandbookItemPanel = HandbookItemPanel or BaseClass(BasePanel)

function HandbookItemPanel:__init(parent)
	self.parent = parent
	self.mdoel = HandbookManager.Instance.model
	self.resList = {
		{file = AssetConfig.handbook_item, type = AssetType.Main},
		{file = AssetConfig.handbook_res, type = AssetType.Dep},
		{file = AssetConfig.guard_head, type = AssetType.Dep},
		{file = AssetConfig.handbookhead, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemList = {}

    self.listener = function() self:ProtoUpdate() end
    self.backpackListener = function() self:BackpackUpdate() end

    self.grade = 0
    self.isInit = false

    self.currItem = nil
end

function HandbookItemPanel:__delete()
	EventMgr.Instance:RemoveListener(event_name.handbook_infoupdate, self.listener)
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackListener)
end

function HandbookItemPanel:OnShow()
	local index = 1
	self.grade = 0
	if self.parent.selectId ~= nil and self.parent.selectId ~= 0 then
		local base = DataHandbook.data_base[self.parent.selectId]
		if base ~= nil then
			index = base.lev
		end
	end
	self.tabGroup:ChangeTab(index)
	EventMgr.Instance:AddListener(event_name.handbook_infoupdate, self.listener)
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackListener)
end

function HandbookItemPanel:OnHide()
	EventMgr.Instance:RemoveListener(event_name.handbook_infoupdate, self.listener)
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackListener)
end

function HandbookItemPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_item))
    self.gameObject.name = "HandbookItemPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(15, 15)

    self.containerRect = self.transform:Find("Scroll/Container"):GetComponent(RectTransform)
    self.baseItem = self.transform:Find("Scroll/HeadItem").gameObject
    self.baseItem:SetActive(false)

    local gridSetting = {
        column = 3,
        bordertop = 0,
        borderleft = 0,
        cspacing = 16,
        rspacing = 5,
        cellSizeX = 72,
        cellSizeY = 72,
    }

    if self.gridLayout == nil then
        self.gridLayout = LuaGridLayout.New(self.containerRect.gameObject, gridSetting)
    end

	local tabGroupSetting = {
        notAutoSelect = true,
        isVertical = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.isInit = true
    self:OnShow()
end

-- 创建格子
function HandbookItemPanel:CreateGrid()
	local grid = GameObject.Instantiate(self.baseItem)
	self.gridLayout:AddCell(grid)
	local item = HandbookItem.New(grid, self)
	table.insert(self.itemList, item)
	return item
end

function HandbookItemPanel:GetItem(index)
	local item = self.itemList[index]
	if item == nil then
		item = self:CreateGrid()
	end
	return item
end

-- 选择一个
function HandbookItemPanel:DefaultSelect()
	local item = self.itemList[1]
	if self.parent.selectId ~= nil and self.parent.selectId ~= 0 then
		item = self:SelectById(self.parent.selectId)
		if item == nil then
			item = self.itemList[1]
		end
	end
	if item ~= nil then
		self.parent:SelectOne(item.data)
	end
end

function HandbookItemPanel:SelectById(id)
	for i,item in ipairs(self.itemList) do
		if item.data ~= nil and item.data.id == id then
			return item
		end
	end
	return nil
end

function HandbookItemPanel:SelectOne(item)
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)
	if item ~= nil and item.data ~= nil then
		self.parent:SelectOne(item.data)
	end
end

function HandbookItemPanel:Update(grade)
	if self.grade == grade then
		return
	end

	self.grade = grade
	local dataList = self.mdoel:GetGradeData(grade)
	table.sort(dataList, function(a,b) return a.id < b.id end)
    local index = nil
    local index2 = nil
    for i,v in pairs(dataList) do
        if v.id == 318 then
            index = i
        elseif v.id == 112 then
            index2 = i
        end
    end

    if grade == 1 and index ~= nil then
        local specialItem = table.remove(dataList, index)
        table.insert(dataList, index2, specialItem)
    end
	local count = 0
	for i,data in ipairs(dataList) do
		count = i
		local item = self:GetItem(i)
		item:SetData(data)
	end
	self.containerRect.sizeDelta = Vector2(250, 77 * math.ceil(count / 3))
	self.containerRect.anchoredPosition = Vector2.zero

	count = count + 1
	for i = count, #self.itemList do
		self.itemList[i].gameObject:SetActive(false)
	end

	local item = self.itemList[1]
	if self.parent.selectId ~= nil and self.parent.selectId ~= 0 then
		item = self:SelectById(self.parent.selectId)
		if item == nil then
			item = self.itemList[1]
		end
	end
	item:ClickItem()
end

function HandbookItemPanel:ChangeTab(index)
	self:Update(index)
end

-- 协议数据更新
function HandbookItemPanel:ProtoUpdate()
	if self.currItem ~= nil then
		self.currItem:Update()
	end
end

function HandbookItemPanel:BackpackUpdate()
	for i,item in ipairs(self.itemList) do
		item:Update()
	end
end