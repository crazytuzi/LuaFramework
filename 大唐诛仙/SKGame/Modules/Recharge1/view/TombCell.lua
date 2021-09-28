TombCell = BaseClass(LuaUI)
function TombCell:__init(...)
	self.URL = "ui://g35bobp2e5r2k";
	self:__property(...)
	self:Config()
	self:InitEvent()
end
function TombCell:SetProperty(...)
	
end
function TombCell:Config()
	self.idx = 0
end
function TombCell:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","TombCell");

	self.btn = self.ui:GetChild("btn")
	self.rewardConn = self.ui:GetChild("rewardConn")
end
function TombCell.Create(ui, ...)
	return TombCell.New(ui, "#", {...})
end
function TombCell:__delete()
	self:RemoveReward()
end

function TombCell:RemoveReward()
	if self.reward then
		self.reward:Destroy()
		self.reward = nil
	end
end

function TombCell:AddReward(data)
	local icon = PkgCell.New(self.rewardConn)
	icon:SetScale(0.83, 1)
	icon:SetXY(-36, -47)
	--icon:OpenTips(true)
	icon:SetupPressShowTips(true)
	icon:SetDataByCfg(3, data.itemId, data.count, false)
	self.reward = icon
end

function TombCell:SetData(idx, isInit, isNew)
	if isInit then self.ui.visible = false return end
	self.ui.visible = true
	self.idx = idx
	self:RefreshUI()
	if isNew then
		self:AddEffect()
	end
end

function TombCell:RefreshUI()
	local model = RechargeModel:GetInstance()
	local state = model:GetCellState(self.idx)
	if state == RechargeConst.TombCellState.Finish then
		local data = model:GetCellData(self.idx)
		url = UIPackage.GetItemURL("Welfare", "btn_mushi2")
		self.btn.grayed = true
		self.btn.touchable = false
		self.ui:SetScale(1.2, 1)
		self:RemoveReward()
		self:AddReward(data)
	else
		url = UIPackage.GetItemURL("Welfare", "btn_mushi1")
		self.btn.grayed = false
		self.btn.touchable = true
		self.ui:SetScale(1, 1)
	end
	self.btn.icon = url
end

function TombCell:InitEvent()
	self.btn.onClick:Add(function()
		RechargeController:GetInstance():OpenTombSure(self.idx)
	end)
end

function TombCell:AddEffect()
	AddEffectToUI( self.ui, "tombtips", 60, 63, Vector3.New( 1, 1, 1 ) )
end