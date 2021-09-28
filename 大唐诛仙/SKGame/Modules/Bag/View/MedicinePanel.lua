MedicinePanel = BaseClass(LuaUI)
function MedicinePanel:__init(root)
	self.ui = UIPackage.CreateObject("Common","CustomLayerN")
	self.hpPanel = MedicineUI.New(self.ui, 126, 137, 1) -- 红药
	self.mpPanel = MedicineUI.New(self.ui, 637, 137, 2) -- 蓝药
	local line = UIPackage.CreateObject("Common","line_fenge")
	self.ui:AddChild(line)
	line:SetXY(self.hpPanel:GetX()+self.hpPanel:GetW()+15, 140)
	root:AddChild(self.ui)
	self:Config()
	self.isInited = true
end

function MedicinePanel:Config()
	self.model = PkgModel:GetInstance()
	self:InitEvent()
end
function MedicinePanel:InitEvent()
	self.hpPanel.cell1.onClick:Add(function(e)
		self:onClickHandle(e.sender.data)
	end)
	self.hpPanel.cell2.onClick:Add(function(e)
		self:onClickHandle(e.sender.data)
	end)
	self.hpPanel.cell3.onClick:Add(function(e)
		self:onClickHandle(e.sender.data)
	end)
	self.mpPanel.cell1.onClick:Add(function(e)
		self:onClickHandle(e.sender.data)
	end)
	self.mpPanel.cell2.onClick:Add(function(e)
		self:onClickHandle(e.sender.data)
	end)
	self.mpPanel.cell3.onClick:Add(function(e)
		self:onClickHandle(e.sender.data)
	end)

	self.medicineChangeHandle = GlobalDispatcher:AddEventListener(EventName.MEDICINE_CHANGE, function()
		if not self.isInited then return end
		self:Update()
	end)
	self:Update()
end
-- 更新面板数据
function MedicinePanel:Update()
	self.hpPanel:Update()
	self.mpPanel:Update()
	self:LevelCheck()
end
function MedicinePanel:LevelCheck()
	self.hpPanel:LevelCheck()
	self.mpPanel:LevelCheck()
end
-- 点击顶部药品
function MedicinePanel:onClickHandle(data)
	if data then
		PkgCtrl:GetInstance():C_PutdownDrug(data[2], data[1])
	end
end
function MedicinePanel:__delete()
	GlobalDispatcher:RemoveEventListener(self.medicineChangeHandle)
	if self.hpPanel then self.hpPanel:Destroy() end
	self.hpPanel =nil
	if self.mpPanel then self.mpPanel:Destroy() end
	self.mpPanel =nil
	self.medicineChangeHandle = nil
	self.isInited = nil
end