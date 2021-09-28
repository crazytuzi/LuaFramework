DecompositionModel =BaseClass(LuaModel)

function DecompositionModel:__init()
	self:InitData()
	self:InitEvent()
end

function DecompositionModel:__delete()
	DecompositionModel.inst = nil
end

function DecompositionModel:GetInstance()
	if DecompositionModel.inst == nil then
		DecompositionModel.inst = DecompositionModel.New()
	end
	return DecompositionModel.inst
end

function DecompositionModel:InitData()
	self.items = {} --可分解的物品数据
	self.maxSelectCnt = DecompositionConst.MaxSelectItemsCnt --最大的可选中同时进行分解的上限
end

function DecompositionModel:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function()
		self:HandleBagChange()
	end)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.BAG_INITED, function()
		self:SetItemsData()
	end)
end

function DecompositionModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function DecompositionModel:HandleBagChange()
	self:DestroyItemsData()
	self:SetItemsData()
	self:DispatchEvent(DecompositionConst.UpdateItems)
end

--设置可分解数据
function DecompositionModel:SetItemsData()
	local onGrids = PkgModel:GetInstance():GetOnGrids()
	for i = 1, #onGrids do
		local grid = onGrids[i]
		if self:IsCanDecomposition(grid.bid) then
			table.insert(self.items, grid)
		end
	end
	self:SortItemsData()
end


--判断是否可以分解
function DecompositionModel:IsCanDecomposition(bid)
	if bid then
		local v = GetCfgData("compose"):Get(bid)
		if not TableIsEmpty(v) then
			if v.isDecompose == 1 then return true end
		end
	end
	return false
end

--对可分解的items数据进行排序(按照bid进行升序)
function DecompositionModel:SortItemsData()
	table.sort(self.items, function (a, b) return a.bid < b.bid end)
end


--回收items数据
function DecompositionModel:DestroyItemsData()
	for i = 1, #self.items do
		self.items[i]:Destroy()
		self.items[i] = nil
	end
	self.items = {}
end

--回收某个id的item数据
function DecompositionModel:DestroyItemsDataById(id)
	if id then
		for i = 1, #self.items do
			if self.items[i].id == id then
				local remGoodsVoObj = table.remove(self.items, i)
				remGoodsVoObj:Destroy()
				break
			end
		end
	end
end

function DecompositionModel:GetItemsData()
	return self.items or {}
end

--判断是否存在某个实例id的物品或者装备
function DecompositionModel:IsHasItemById(id)
	if id then
		for i = 1, #self.items do
			local v = self.items[i]
			if not TableIsEmpty(v) then
				if v.id == id then return true end
			end
		end
	end
	return false
end

function DecompositionModel:GetItemDataById(id)
	if id then
		for i = 1 , #self.items do
			local v = self.items[i]
			if not TableIsEmpty(v) then
				if v.id == id then return v end
			end
		end
	end
	return {}
end

function DecompositionModel:GetMaxSelectCnt()
	return self.maxSelectCnt or 0
end

function DecompositionModel:Reset()
	self.items = {} --可分解的物品数据
end
