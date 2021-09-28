DecompositionUILeft = BaseClass(LuaUI)
function DecompositionUILeft:__init(...)
	self.URL = "ui://q13jjk9jxy1x3"
	self:__property(...)
	self:Config()
end

function DecompositionUILeft:SetProperty(type)
	self.type = type
end

function DecompositionUILeft:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function DecompositionUILeft:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Decomposition","DecompositionUILeft")
	self.decompositionTitle = self.ui:GetChild("decompositionTitle")
	self.scrollViewContent = self.ui:GetChild("scrollViewContent")
	self.label_cnt = self.ui:GetChild("label_cnt")
end

function DecompositionUILeft.Create(ui, ...)
	return DecompositionUILeft.New(ui, "#", {...})
end

function DecompositionUILeft:__delete()
	self:DestroyCellList()
	self:CleanEvent()
end

function DecompositionUILeft:InitData()
	self.cellList = {} 
	self.selectCellDataList = {} 
	if self.type == DecompositionConst.Decomposition then
		self.model = DecompositionModel:GetInstance()
	else
		self.model = RefinedModel:GetInstance()
		self.decompositionTitle:GetChild("labelTitle").text = "可提炼物品"
	end

	self.gridsCnt = PkgModel:GetInstance().bagGrid or 0
	self.cellWidthStart = 10
	self.cellHeightStart = 10
	self.selectedCell = nil	
end

function DecompositionUILeft:InitEvent()
	local function HandleCancelDecomposition(cellObj)
		self:HandleCancelDecomposition(cellObj)
	end
	self.handler0 = self.model:AddEventListener(DecompositionConst.CancelItem , HandleCancelDecomposition)
end

function DecompositionUILeft:CleanEvent()
	self.model:RemoveEventListener(self.handler0)
end

function DecompositionUILeft:InitUI()
	self:InitGridsUI()
	self:SetUI()
end

function DecompositionUILeft:InitGridsUI()
	local function onCellItemClick(data)
		self:OnClickItem(data)
	end
	for i = 1, self.gridsCnt do
		local cell = PkgCell.New(self.scrollViewContent, nil , onCellItemClick)
		cell:SetRare(0)
		cell:OpenTips(false, false)
		cell:SetupPressShowTips(true , 1)
		table.insert(self.cellList, cell)
	end
end

function DecompositionUILeft:SetUI()
	local itemsData = self.model:GetItemsData()
	local function onCellItemClick(data)
		self:OnClickItem(data)
	end
	for i = 1 , #self.cellList do
		local cell = self.cellList[i]
		local curItemData = itemsData[i]
		if (not TableIsEmpty(cell)) and (not TableIsEmpty(curItemData)) then
			cell:SetData(curItemData)
			cell:SetGrayed(false)
			local isHas, idx = self:IsHasSelectCellData(curItemData.id)
			if isHas == true and idx ~= -1 then
				cell:SetGrayed(true)
			end
		else
			cell:SetData(nil)
			cell:SetGrayed(false)
		end
	end
	self.label_cnt.text = StringFormat("{0}/{1}", #itemsData , self.gridsCnt)
end

function DecompositionUILeft:UpdateUI()
	self:SetUI()
	self:DestroySelectCellDataList()
end

--策划需求，切换到分解页签时，取消选中的PkgCell,清除对应的选中数据
function DecompositionUILeft:CleanSelectCellUIAndData()
	self:CleanSelectCellStateUI()
	self:DestroySelectCellDataList()
end

function DecompositionUILeft:CleanSelectCellStateUI()
	for i = 1, #self.cellList do
		local cell = self.cellList[i]
		if not TableIsEmpty(cell) then
			cell:SetGrayed(false)
		end
	end
end

function DecompositionUILeft:GetPkgCellUIByIndex(idx)
	return self.cellList[idx] or {}
end

function DecompositionUILeft:GetPkgCellUIById(id)
	if id then
		for i = 1, #self.cellList do
			local cell = self.cellList[i]
			if not TableIsEmpty(cell) then
				local curCellData = cell:GetData()
				if not TableIsEmpty(curCellData) then
					if curCellData.id == id then
						return cell
					end
				end
			end
		end
	end
	return {}
end

function DecompositionUILeft:OnClickItem(cell)
	if cell then	
		local cellData = cell:GetData()
		if not TableIsEmpty(cellData) then
			local isHas = self:IsHasSelectCellData(cellData.id)
			if isHas then
				self.model:DispatchEvent(DecompositionConst.UnselectItem, cell)
				self:SetSelectStateUI(cell)
			else
				if #self.selectCellDataList < self.model:GetMaxSelectCnt() then
					self.model:DispatchEvent(DecompositionConst.SelectItem, cell)
					self:SetSelectStateUI(cell)
				else
				end
			end
		end
	end
end

--设置选中状态和限制
--如果已经选中，再次点击则取消选中，否则则为选中
function DecompositionUILeft:SetSelectStateUI(cellObj)
	if not TableIsEmpty(cellObj) then
		local cellDataObj = cellObj:GetData()
		if not TableIsEmpty(cellDataObj) then
			local isHas , i = self:IsHasSelectCellData(cellDataObj.id)
			if isHas and i ~= -1 then
				cellObj:SetGrayed(false)
				self:RemSelectCellData(cellDataObj)
			else
				cellObj:SetGrayed(true)
				self:AddSelectCellData(cellDataObj)
			end
		end
	end
end

--增加选中单元数据
function DecompositionUILeft:AddSelectCellData(cellDataObj)
	if not TableIsEmpty(cellDataObj) then
		local isHas , i = self:IsHasSelectCellData(cellDataObj.id)
		if isHas and i ~= -1 then
			self:RemSelectCellData(cellDataObj)
			self.selectCellDataList[i] = cellDataObj
		else
			table.insert(self.selectCellDataList , cellDataObj)
		end
	end
end

--减少选中单元数据
function DecompositionUILeft:RemSelectCellData(cellDataObj)
	if not TableIsEmpty(cellDataObj) then
		local isHas , i = self:IsHasSelectCellData(cellDataObj.id)
		if isHas == true and i ~= -1 then
			local rmCellDataObj = table.remove(self.selectCellDataList, i)
			rmCellDataObj:Destroy()
		end
	end
end

--设置选中数据
function DecompositionUILeft:IsHasSelectCellData(id)
	if id then
		for i = 1, #self.selectCellDataList do
			local curSelectCellData = self.selectCellDataList[i]
			if not TableIsEmpty(curSelectCellData) then
				if curSelectCellData.id == id then
					return true , i
				end
			end
		end
	end
	return false , -1
end

function DecompositionUILeft:DestroyCellList()
	for i, v in ipairs(self.cellList) do
		if not TableIsEmpty(v) then
			v:Destroy()
		end
	end
	self.cellList = {}
end

function DecompositionUILeft:DestroySelectCellDataList()
	for i = 1, #self.selectCellDataList do
		if not TableIsEmpty(self.selectCellDataList[i]) then
			self.selectCellDataList[i]:Destroy()
		end
	end
	self.selectCellDataList = {}
end

function DecompositionUILeft:HandleCancelDecomposition(cellObj)
	if not TableIsEmpty(cellObj) then
		local cellData = cellObj:GetData()
		if not TableIsEmpty(cellData) then
			local id = cellData.id
			local obj = self:GetPkgCellUIById(id)
			if not TableIsEmpty(obj) then
				obj:SetGrayed(false)
				self:RemSelectCellData(obj:GetData())
			end
		end
	end
end

