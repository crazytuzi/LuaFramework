TombRewardShow = BaseClass(LuaUI)
function TombRewardShow:__init(...)
	self.URL = "ui://g35bobp2e5r2q";
	self:__property(...)
	self:Config()
	self:AddCells()
end
function TombRewardShow:SetProperty(...)
	
end
function TombRewardShow:Config()
	self.cells = {}
	self.cellDescs = {}
end
function TombRewardShow:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","TombRewardShow");

	self.txt_desc = self.ui:GetChild("txt_desc")
	self.txt_name = self.ui:GetChild("txt_name")
end
function TombRewardShow.Create(ui, ...)
	return TombRewardShow.New(ui, "#", {...})
end
function TombRewardShow:__delete()
	self:DestroyCells()
	self.cellDescs = nil
end

function TombRewardShow:DestroyCells()
	if not self.cells then return end
	for _, v in pairs(self.cells) do
		if v then
			v:Destroy()
		end
	end
	self.cells = nil
end

function TombRewardShow:AddCells()
	local model = RechargeModel:GetInstance()
	self:DestroyCells()
	self.cells = {}
	local startX = -90
	local startY = 3
	local curI = 1
	local idList = model:GetSortedIdList()
	local tombData = GetCfgData("tomb")
	for i = 1, RechargeConst.kMaxCellNum do
		local id = idList[i]
		local data = tombData:Get(id)
		local icon = PkgCell.New(self.ui)
		local function selectCallback()
			self:SetSelect(i, data)
		end
		icon:SetClickEngine(true)
		--icon:SetScale(1.1, 1.1)
		icon:SetSelectCallback(selectCallback)
		--local state = model:GetCellStateById(id)
		local state = model:IsTombIdGot(id)
		self:AddCellDesc(icon, state)
		local j = math.ceil(i / 3)
		icon:SetXY(startX + 100 * curI, startY + 100 * j)
		icon:SetDataByCfg(3, data.itemId, data.count, false)
		self.cells[i] = icon
		if i % 3 == 0 then
			curI = 1
		else
			curI = curI + 1
		end
		if i == 1 then
			self:SetSelect(i, data)
		end
	end
end

function TombRewardShow:AddCellDesc(cell, state)
	--if state == RechargeConst.TombCellState.Finish then
	if state then
		local txt = createText1("已获得", cell.ui, 12, 30, 60, 26)
		cell.ui.grayed = true
		table.insert(self.cellDescs, txt)
	end
end

function TombRewardShow:SetSelect(idx, data)
	for k, v in pairs(self.cells) do
		if k == idx then
			v:SetSelected(true)
			self.selectedIdx = idx
			self:RefreshDesc(data)
		else
			v:SetSelected(false)
		end
	end
end

function TombRewardShow:RefreshDesc(data)
	if not data then return end
	data = GetCfgData("item"):Get(data.itemId)
	local tinyType = data.tinyType
	local content = data.des or ""
	local effectValue = data.effectValue
	content = getGiftDesc(content, tinyType, effectValue)
	self.txt_name.text = StringFormat("[color={0}]{1}[/color]", RechargeConst.TombDescNameColor[data.rare], data.name)
	self.txt_desc.text = content
end