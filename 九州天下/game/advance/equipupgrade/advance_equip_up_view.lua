
AdvanceEquipUpView = AdvanceEquipUpView or BaseClass(BaseView)

function AdvanceEquipUpView:__init()
	self.ui_config = {"uis/views/advanceview", "EquipUpGradeView"}
	self.view_layer = UiLayer.Pop
end

function AdvanceEquipUpView:__delete()
end

function AdvanceEquipUpView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OpenMountView",
		BindTool.Bind(self.OpenMountView, self))
	self:ListenEvent("OpenWingView",
		BindTool.Bind(self.OpenWingView, self))
	self:ListenEvent("OpenHaloView",
		BindTool.Bind(self.OpenHaloView, self))
	self:ListenEvent("OpenShengongView",
		BindTool.Bind(self.OpenShengongView, self))
	self:ListenEvent("OpenShenyiView",
		BindTool.Bind(self.OpenShenyiView, self))

	self.tab_mount = self:FindObj("TabMount")
	self.tab_wing = self:FindObj("TabWing")
	self.tab_halo = self:FindObj("TabHalo")
	self.tab_shengong = self:FindObj("TabShengong")
	self.tab_shenyi = self:FindObj("TabShenyi")

	self.mount_view = AdvanceEquipMountView.New(self:FindObj("EquipUpGradeMountContent"))
	self.wing_view = AdvanceEquipWingView.New(self:FindObj("EquipUpGradeWingContent"))
	self.halo_view = AdvanceEquipHaloView.New(self:FindObj("EquipUpGradeHaloContent"))
	self.shengong_view = AdvanceEquipShengongView.New(self:FindObj("EquipUpGradeShengongContent"))
	self.shenyi_view = AdvanceEquipShenyiView.New(self:FindObj("EquipUpGradeShenyiContent"))
	self:Flush()
	self:InitTab()
	-- self:OnOpenEquipUp()
end

function AdvanceEquipUpView:CloseCallBack()
	AdvanceCtrl.Instance:GetAdvanceView().notips = false
end

function AdvanceEquipUpView:ReleaseCallBack()
	if self.mount_view ~= nil then
	   self.mount_view:DeleteMe()
	   self.mount_view = nil
	end

	if self.wing_view ~= nil then
	   self.wing_view:DeleteMe()
	   self.wing_view = nil
	end

	if self.halo_view ~= nil then
	   self.halo_view:DeleteMe()
	   self.halo_view = nil
	end

	if self.shengong_view ~= nil then
	   self.shengong_view:DeleteMe()
	   self.shengong_view = nil
	end

	if self.shenyi_view ~= nil then
	   self.shenyi_view:DeleteMe()
	   self.shenyi_view = nil
	end
	self.index = nil
end

function AdvanceEquipUpView:OnClickClose()
	self:Close()
end

function AdvanceEquipUpView:OpenMountView()
	self.mount = AdvanceData.Instance:GetMountCanUplevel() or {}
	self.mount_view:OnFlush({index = 0, list = self.mount})
end

function AdvanceEquipUpView:OpenWingView()
	self.wing = AdvanceData.Instance:GetWingCanUplevel() or {}
	self.wing_view:OnFlush({index = 0, list = self.wing})
end

function AdvanceEquipUpView:OpenHaloView()
	self.halo = AdvanceData.Instance:GetHaloCanUplevel() or {}
	self.halo_view:OnFlush({index = 0, list = self.halo})
end

function AdvanceEquipUpView:OpenShengongView()
	self.shengong = AdvanceData.Instance:GetShengongCanUplevel() or {}
	self.shengong_view:OnFlush({index = 0, list = self.shengong})
end

function AdvanceEquipUpView:OpenShenyiView()
	self.shenyi = AdvanceData.Instance:GetShenyiCanUplevel() or {}
	self.shenyi_view:OnFlush({index = 0, list = self.shenyi})
end

function AdvanceEquipUpView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "mount_equipup" or cur_index == TabIndex.advance_equipup_mount then
			self.index = v.index or 0
			self.mount = AdvanceData.Instance:GetMountCanUplevel() or v
			self.tab_mount.toggle.isOn = true
			self.mount_view:OnFlush({index = self.index, list = self.mount})
		elseif k == "wing_equipup" or cur_index == TabIndex.advance_equipup_wing then
			self.index = v.index or 0
			self.wing = AdvanceData.Instance:GetWingCanUplevel() or v
			self.tab_wing.toggle.isOn = true
			self.wing_view:OnFlush({index = self.index, list = self.wing})
		elseif k == "halo_equipup" or cur_index == TabIndex.advance_equipup_halo then
			self.index = v.index or 0
			self.halo = AdvanceData.Instance:GetHaloCanUplevel() or v
			self.tab_halo.toggle.isOn = true
			self.halo_view:OnFlush({index = self.index, list = self.halo})
		elseif k == "shengong_equipup" or cur_index == TabIndex.advance_equipup_shengong then
			self.index = v.index or 0
			self.shengong = AdvanceData.Instance:GetShengongCanUplevel() or v
			self.tab_shengong.toggle.isOn = true
			self.shengong_view:OnFlush({index = self.index, list = self.shengong})
		elseif k == "shenyi_equipup" or cur_index == TabIndex.advance_equipup_shenyi then
			self.index = v.index or 0
			self.shenyi = AdvanceData.Instance:GetShenyiCanUplevel() or v
			self.tab_shenyi.toggle.isOn = true
			self.shenyi_view:OnFlush({index = self.index, list = self.shenyi})
		end
	end
end

function AdvanceEquipUpView:InitTab()
	local list = TaskData.Instance:GetTaskCompletedList()
	if list[OPEN_FUNCTION_TYPE_ID.MOUNT] == 1 then
		self.tab_mount:SetActive(true)
	else
		self.tab_mount:SetActive(false)
	end

	if list[OPEN_FUNCTION_TYPE_ID.WING] == 1 then
		self.tab_wing:SetActive(true)
	else
		self.tab_wing:SetActive(false)
	end

	if list[OPEN_FUNCTION_TYPE_ID.HALO] == 1 then
		self.tab_halo:SetActive(true)
	else
		self.tab_halo:SetActive(false)
	end

	if list[OPEN_FUNCTION_TYPE_ID.SHEN_GONG] == 1 then
		self.tab_shengong:SetActive(true)
	else
		self.tab_shengong:SetActive(false)
	end

	if list[OPEN_FUNCTION_TYPE_ID.SHEN_YI] == 1 then
		self.tab_shenyi:SetActive(true)
	else
		self.tab_shenyi:SetActive(false)
	end
end

-- function AdvanceEquipUpView:OnOpenEquipUp()
-- 	local default_open = AdvanceData.Instance:GetDefaultOpenView()
-- 	if default_open == "mount" then
-- 		self:OpenMountView()
-- 	elseif default_open == "wing" then
-- 		self:OpenWingView()
-- 	elseif default_open == "halo" then
-- 		self:OpenHaloView()
-- 	elseif default_open == "shengong" then
-- 		self:OpenShengongView()
-- 	elseif default_open == "shenyi" then
-- 		self:OpenShenyiView()
-- 	end
-- end