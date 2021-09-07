require("game/dimai/dimai_content_view")
require("game/dimai/dimai_base_view")

DiMaiView = DiMaiView or BaseClass(BaseView)

function DiMaiView:__init()
	self.ui_config = {"uis/views/dimaiview", "DiMaiView"}
	self.full_screen = false
	self.play_audio = true								-- 播放音效
	self:SetMaskBg()
end

function DiMaiView:__delete()
	self.full_screen = nil
	self.play_audio = nil
end

function DiMaiView:ReleaseCallBack()
	if self.dimai_content_view then
		self.dimai_content_view:DeleteMe()
		self.dimai_content_view = nil
	end

	for i = 1, 6 do
		if self.view_list[i] then
			self.view_list[i]:DeleteMe()
			self.view_list[i] = nil
		end
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.toggle_list = {}
	self.view_list = {}
	self.tab_index = {}
	self.layer_bg = nil
	self.is_occupy = {}
end

function DiMaiView:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.layer_bg = self:FindVariable("LayerBg")

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))

	self.toggle_list = {
		self:FindObj("ToggleRenMai"),
		self:FindObj("ToggleLingMai"),
		self:FindObj("ToggleDiMai"),
		self:FindObj("ToggleTianMai"),
		self:FindObj("ToggleShengMai"),
		self:FindObj("ToggleShenMai"),
	}

	self.tab_index = {
		TabIndex.dimai_renmai,
		TabIndex.dimai_lingmai,
		TabIndex.dimai_dimai,
		TabIndex.dimai_tianmai,
		TabIndex.dimai_shengmai,
		TabIndex.dimai_shenmai,
	}

	self.view_list = {
		dimai_renmai_view,
		dimai_lingmai_view,
		dimai_dimai_view,
		dimai_tianmai_view,
		dimai_shengmai_view,
		dimai_shenmai_view,
	}

	local obj_list = {
		self:FindObj("RenMaiContent"),
		self:FindObj("LingMaiContent"),
		self:FindObj("DiMaiContent"),
		self:FindObj("TianMaiContent"),
		self:FindObj("ShengMaiContent"),
		self:FindObj("ShenMaiContent"),
	}

	local type_list = {
		"RenMai",
		"LingMai",
		"DiMai",
		"TianMai",
		"ShengMai",
		"ShenMai",
	}

	for i = 1, 6 do
		self.toggle_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, self.tab_index[i]))

		self.view_list[i] = DiMaiBaseView.New()
		local dimai_content = obj_list[i]
		dimai_content.uiprefab_loader:Wait(function(obj)
			obj = U3DObject(obj)
			self.view_list[i]:SetInstance(obj)
			self.view_list[i]:SetData(DiMaiData.SceneCount[type_list[i]])
		end)
	end

	-- 地脉通用content
	self.dimai_content_view = DiMaiContentView.New()
	local qiang_dimai_content = self:FindObj("QiangDiMaiContent")
	qiang_dimai_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.dimai_content_view:SetInstance(obj)
	end)

	self.is_occupy = {}
	for i = 0,5 do
		self.is_occupy[i] = self:FindVariable("IsOccupy"..(i + 1))
	end
end

function DiMaiView:ShowIndexCallBack(index)
	local bg_id = 0

	for i = 1, 6 do
		if index == self.tab_index[i] then
			self.toggle_list[i].toggle.isOn = true
			bg_id = i - 1
			break
		end
	end

	DiMaiData.Instance:SetDiMaiLayer(bg_id)

	if self.layer_bg then
		self.layer_bg:SetAsset(ResPath.GetDiMaiLayerBg(bg_id))
	end
	
	if self.dimai_content_view then
		self.dimai_content_view:OpenCallBack()
	end
end

function DiMaiView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
	end
end

function DiMaiView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			for i = 1, 6 do
				if self.show_index == self.tab_index[i] then
					self.view_list[i]:Flush()
					break
				end
			end
		elseif k == "flush_dimai_content" then
			if self.dimai_content_view then
				self.dimai_content_view:Flush()
			end
		end
	end

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local index = DiMaiData.Instance:GetRoleLayerByRoleID(main_role_id)
	if nil ~= index then
		for i = 0, 5 do
			if index == i then
				if self.is_occupy~=nil and self.is_occupy[i]~=nil then
					self.is_occupy[i]:SetValue(true)
				end
			end
		end
	end
end
