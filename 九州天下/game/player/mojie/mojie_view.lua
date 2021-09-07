require("game/player/mojie/mojie_content")
require("game/player/mojie/gouyu_content")
require("game/player/mojie/jewelry_content")
MojieView = MojieView or BaseClass(BaseView)

local PASSIVE_TYPE = 73

function MojieView:__init()
	self.ui_config = {"uis/views/player","MojieView"}
	self:SetMaskBg()
	self.play_audio = true
	self.def_index = 0
	self.view_name = ViewName.Mojie

	self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function MojieView:__delete()
	
end

function MojieView:ReleaseCallBack()
	if self.mojie_view then
		self.mojie_view:DeleteMe()
		self.mojie_view = nil
	end
	if self.gouyu_view then
		self.gouyu_view:DeleteMe()
		self.gouyu_view = nil
	end
	if self.jewelry_view then
		self.jewelry_view:DeleteMe()
		self.jewelry_view = nil
	end

	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.red_point_list = {}
	self.mojie_btn = nil
	self.gouyu_btn = nil
	self.jewelry_btn = nil
end

function MojieView:LoadCallBack()
	self.mojie_btn = self:FindObj("MojieButton")
	self.gouyu_btn = self:FindObj("GouyuButton")
	self.jewelry_btn = self:FindObj("JewelryButton")

	self.mojie_view = MojieContentView.New()
	local mojie_content = self:FindObj("MojieContent")
	mojie_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.mojie_view:SetInstance(obj)
	end)

	self.gouyu_view = GouyuContentView.New()
	local gouyu_content = self:FindObj("GouyuContent")
	gouyu_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.gouyu_view:SetInstance(obj)
	end)

	self.jewelry_view = JewelryContentView.New()
	local jewelry_content = self:FindObj("JewelryContent")
	jewelry_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.jewelry_view:SetInstance(obj)
	end)
	
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickTab1",BindTool.Bind(self.OnToggleChange, self, TabIndex.role_mojie))
	self:ListenEvent("ClickTab2",BindTool.Bind(self.OnToggleChange, self, TabIndex.role_jinjie))
	self:ListenEvent("ClickTab3",BindTool.Bind(self.OnToggleChange, self, TabIndex.role_jewelry))

	self:InitTab()

	-- self.jinjie_red = self:FindVariable("JinjieRed")

	self.red_point_list = {
		[RemindName.Mojie] = self:FindVariable("MoJieRed"),
		[RemindName.GouYu] = self:FindVariable("GouyuRed"),
		[RemindName.SpecialView] = self:FindVariable("JinjieRed"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
end

function MojieView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function MojieView:InitTab()
	if not self:IsOpen() then return end
	self.gouyu_btn:SetActive(OpenFunData.Instance:CheckIsHide("jinjie"))
end

function MojieView:OpenCallBack()
end

function MojieView:OnToggleChange(index)
	if self.show_index == index then return end
	self:ChangeToIndex(index)
end

function MojieView:ShowIndexCallBack(index)
	if self.show_index == TabIndex.role_mojie then
		self.mojie_btn.toggle.isOn = true
		if self.mojie_view ~= nil then
			self.mojie_view:ResetIndex(1)
		end
	elseif self.show_index == TabIndex.role_jinjie then
		self.gouyu_btn.toggle.isOn = true
	elseif self.show_index == TabIndex.role_jewelry then
		self.jewelry_btn.toggle.isOn = true
	end
	self:Flush()
end

function MojieView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.show_index == TabIndex.role_mojie then
				local types = MojieData.Instance:GetMojieStuffTypes(v.item_id)
				if self.mojie_view then
					self.mojie_view:Flush("types", {types = types})
				end
			elseif self.show_index == TabIndex.role_jinjie then
				if self.gouyu_view then
					self.gouyu_view:Flush()
				end
			elseif self.show_index == TabIndex.role_jewelry then
				local types = nil
				if v.item_id ~= nil then
					types = MojieData.Instance:GetGuazhuiIndex(v.item_id)
				end
				if self.jewelry_view then
					self.jewelry_view:Flush("types",{types = types})
				end
			end
		elseif k == "data" then
			if self.show_index == TabIndex.role_mojie then
				if v.types and self.mojie_view then
					self.mojie_view:Flush("types", {types = v.types})
				end
			elseif self.show_index == TabIndex.role_jewelry then
				if self.jewelry_view then
					self.jewelry_view:Flush("types",{types = v.types})
				end
			end
		end
	end
	self:red()
end

function MojieView:ItemDataChangeCallback()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.Mojie)
	RemindManager.Instance:Fire(RemindName.GouYu)
	RemindManager.Instance:Fire(RemindName.JieZhi)
	RemindManager.Instance:Fire(RemindName.GuaZhui)
end

function MojieView:red()
	
end
