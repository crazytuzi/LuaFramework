MedicineUI = BaseClass(LuaUI)
function MedicineUI:__init(root, x, y, type)
	self:RegistUI()
	root:AddChild(self.ui)
	self:SetXY(x, y)
	self.type = type
	self.model = PkgModel:GetInstance()

	self:Config()
	self:Update()
end
function MedicineUI:RegistUI()
	self.ui = UIPackage.CreateObject("Pkg","MedicineUI")
	self.title = self.ui:GetChild("title")
	self.txtDesc = self.ui:GetChild("txtDesc")
	self.cell1 = self.ui:GetChild("cell1")
	self.cell2 = self.ui:GetChild("cell2")
	self.cell3 = self.ui:GetChild("cell3")
	self.layer = self.ui:GetChild("layer")
end
function MedicineUI:Config()
	self.title.text = PkgConst.titleList[self.type]
	self.txtDesc.text = PkgConst.medicineDescList[self.type]
	self.fillBg = UIPackage.GetItemURL("Pkg" , "medicineCell00")
	self.emptyBg = UIPackage.GetItemURL("Pkg" , "medicineCell01")
	self.items = {}
	self.bids = PkgConst.medicineTypeBidList[self.type]

	local item = nil
	local offH = 115
	local function handler(bid, state )
		if state == 0 then -- 未装备中
			PkgCtrl:GetInstance():C_PutonDrug(self.type, bid)
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		else
			PkgCtrl:GetInstance():C_PutdownDrug(self.type, bid)
		end
	end
	for i=1, #self.bids do
		item = MedicineItem.New(self.layer, 0, offH*(i-1), GoodsVo.GetItemCfg(self.bids[i]))
		self.items[i] = item
		item:SetClickCallback(handler)
	end
end

function MedicineUI:Update()
	local wearList = {}
	if self.type == 1 then
		for k,v in pairs(self.model.wearHpTable) do
			if v and v ~= 0 then
				table.insert(wearList, v)
			end
		end
	else
		for k,v in pairs(self.model.wearMpTable) do
			if v and v ~= 0 then
				table.insert(wearList, v)
			end
		end
	end
	
	for i=1,3 do -- 不跟后端下标走
		local cell = self["cell"..i]
		local v = wearList[i]
		if v ~= nil and v ~= 0 then -- and self.model:IsOnBagByBid(v.itemId)
			cell:GetChild("image").url = "Icon/Goods/"..GoodsVo.GetItemCfg(v).icon
			cell.data = {v, self.type}
			cell:GetChild("bg").url = self.fillBg
		else
			cell:GetChild("image").url = nil
			cell.data = nil
			cell:GetChild("bg").url = self.emptyBg
		end
	end

	for _,item in ipairs(self.items) do
		local state = 0
		for _,v in ipairs(wearList) do
			if item.data and item.data.id == v then
				state = 1
				break
			end
		end
		item:SetState(state)
	end
	
end

function MedicineUI:LevelCheck()
	for _,item in ipairs(self.items) do
		item:LevelCheck()
	end
end

function MedicineUI:__delete()
	if self.items then
		for _,v in pairs(self.items) do
			v:Destroy()
		end
		self.items = nil
	end
end