--
-- @Author: chk
-- @Date:   2018-12-31 16:42:54
--
FactionEnterSetPanel = FactionEnterSetPanel or class("FactionEnterSetPanel",WindowPanel)
local FactionEnterSetPanel = FactionEnterSetPanel

function FactionEnterSetPanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionEnterSetPanel"
	self.layer = "UI"

	self.minPowerNum = 0
	self.minLevelNum = 0
	self.panel_type = 4
	self.table_index = nil
	self.events = {}
	self.model = FactionModel:GetInstance()
end

function FactionEnterSetPanel:dctor()
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
end

function FactionEnterSetPanel:Open( )
	FactionEnterSetPanel.super.Open(self)
end

function FactionEnterSetPanel:LoadCallBack()
	self.nodes = {
		"btn_ok",
		"btn_cancle",
		"Toggle",
		"minlevel/minLevelValue_min",
		"minlevel/minLevelValue",
		"minlevel/minLevelValue_max",

		"minlevel/minLevelSlider",
		"minlevel/minLevelMinusBtn",
		"minlevel/minLevelPlusBtn",
		"minPower/minPowerValue",
		"minPower/minPowerValue_min",
		"minPower/minPowerValue_max",

		"minPower/minPowerSlider",
		"minPower/minPowerMinusBtn",
		"minPower/minPowerPlusBtn",
		"minlevel/btn",
		"minPower/btn2",
	}
	self:GetChildren(self.nodes)
	self:GetSelfComponent()
	self:AddEvent()
end

function FactionEnterSetPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_cancle.gameObject,call_back)

	local function call_back(target,x,y)
		self.is_auto_accept = self.Toggle:GetComponent('Toggle').isOn and true or false
		FactionController.Instance:RequestFactionSet(self.is_auto_accept,self.minLevelNum,self.minPowerNum)
	end
	AddClickEvent(self.btn_ok.gameObject,call_back)


	local function call_back(target, value)
		self.minPowerNum = value
		if self.minPowerNum > 99999999 then
			self.minPowerNum = 99999999
		end
		self.minPowerValueTxt.text = self.minPowerNum
	end
	AddValueChange(self.minPowerSlider.gameObject, call_back)

	local function call_back(target, value)
		self.minLevelNum= value
		self.minLevelValueTxt.text = value
	end
	AddValueChange(self.minLevelSldr.gameObject, call_back)


	local function call_back()
		if self.minLevelNum > self.minLevelSldr.minValue then
			self.minLevelNum = self.minLevelNum - 1
			self.minLevelSldr.value = self.minLevelNum
			self.minLevelValueTxt.text = self.minLevelNum .. ""
		end
	end
	AddClickEvent(self.minLevelMinusBtn.gameObject,call_back)


	local function call_back()
		if self.minLevelNum < self.minLevelSldr.maxValue then
			self.minLevelNum = self.minLevelNum + 1
			self.minLevelSldr.value = self.minLevelNum
			self.minLevelValueTxt.text = self.minLevelNum .. ""
		end
	end

	AddClickEvent(self.minLevelPlusBtn.gameObject,call_back)


	local function call_back()
		if self.minPowerNum > self.minPowerSldr.minValue then
			self.minPowerNum = self.minPowerNum - 1
			self.minPowerSldr.value = self.minPowerNum
			self.minPowerValueTxt.text = self.minPowerNum .. ""
		end
	end
	AddClickEvent(self.minPowerMinusBtn.gameObject,call_back)


	local function call_back()
		if self.minPowerNum < self.minPowerSldr.maxValue then
			self.minPowerNum = self.minPowerNum + 1
			self.minPowerSldr.value = self.minPowerNum
			self.minPowerValueTxt.text = self.minPowerNum .. ""
		end
	end

	AddClickEvent(self.minPowerPlusBtn.gameObject,call_back)

	--数字键盘点击  等级
	local function call_back()
		self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.minLevelValueTxt, handler(self, self.ClickCheckInput,1), handler(self, self.ClickCheckInput,1), handler(self, self.ClickCheckInput,1), 2)
		self.numKeyPad:Open()
	end
	AddButtonEvent(self.btn.gameObject, call_back)
	-- 战力
	local function call_back()
		self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.minPowerValueTxt, handler(self, self.ClickCheckInput,2), handler(self, self.ClickCheckInput,2), handler(self, self.ClickCheckInput,2), 2)
		self.numKeyPad:Open()
	end
	AddButtonEvent(self.btn2.gameObject, call_back)


	self.is_auto_accept = self.Toggle:GetComponent('Toggle').isOn and true or false

	self.events[#self.events+1] = self.model:AddListener(FactionEvent.FactionSetSucess,handler(self,self.DealFactionSetSucess))
end

function FactionEnterSetPanel:DealFactionSetSucess()
	self:Close()
end

function FactionEnterSetPanel:GetSelfComponent()
	self.ToggleTgl = self.Toggle:GetComponent('Toggle')
	self.minLevelSldr = self.minLevelSlider:GetComponent('Slider')

	self.minLevelValueTxt = self.minLevelValue:GetComponent('Text')
	self.minLevelValue_minTxt = self.minLevelValue_min:GetComponent('Text')
	self.minLevelValue_maxTxt = self.minLevelValue_max:GetComponent('Text')

	self.minPowerSldr = self.minPowerSlider:GetComponent('Slider')
	self.minPowerValueTxt = self.minPowerValue:GetComponent('Text')
	self.minPowerValue_minTxt = self.minPowerValue_min:GetComponent('Text')
	self.minPowerValue_maxTxt = self.minPowerValue_max:GetComponent('Text')
end

function FactionEnterSetPanel:OpenCallBack()
	self:UpdateView()
end

function FactionEnterSetPanel:UpdateView( )
	self:SetTileTextImage("faction_image","faction_f_s")

	if self.model.factionSetInfo ~= nil then
		self.Toggle:GetComponent('Toggle').isOn = self.model.factionSetInfo.auto
		self.minPowerNum = self.model.factionSetInfo.power
		self.minLevelNum = self.model.factionSetInfo.level
		self.minPowerSldr.value = self.minPowerNum
		self.minLevelSldr.value = self.minLevelNum
		self.minPowerValueTxt.text = self.minPowerNum .. ""
		self.minLevelValueTxt.text = self.minLevelNum .. ""
	end
end




function FactionEnterSetPanel:ClickCheckInput(index)
	local temp
	local limit
	if index == 1 then
		temp = tonumber(self.minLevelValueTxt.text)
		limit = 999
	else
		temp = tonumber(self.minPowerValueTxt.text)
		limit = 999999999
	end
	if limit < temp then
		temp = limit
	end
	if index == 1 then
		self.minLevelValueTxt.text = temp
		self.minLevelNum = temp

	else
		self.minPowerValueTxt.text = temp
		self.minPowerNum = temp
	end
end


function FactionEnterSetPanel:CloseCallBack(  )

end
