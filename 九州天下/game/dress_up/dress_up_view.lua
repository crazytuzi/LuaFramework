DressUpView = DressUpView or BaseClass(BaseView)

function DressUpView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/dressup", "DressUpView"}
	-- self.ui_scene = {"scenes/map/uizqdt01", "UIzqdt01"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenAdvanced)
	end
	self.def_index = TabIndex.headwear
	self.play_audio = true
	self.view_state = DressUpViewState.HEADWEAR
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function DressUpView:__delete()
	if self.open_trigger_handle ~= nil then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end
end

function DressUpView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("OpenHeadwear",BindTool.Bind(self.OpenHeadwear, self))
	self:ListenEvent("OpenMask",BindTool.Bind(self.OpenMask, self))
	self:ListenEvent("OpenWaist",BindTool.Bind(self.OpenWaist, self))
	self:ListenEvent("OpenBead",BindTool.Bind(self.OpenBead, self))
	self:ListenEvent("OpenFaBao",BindTool.Bind(self.OpenFaBao, self))
	self:ListenEvent("OpenKirinArm",BindTool.Bind(self.OpenKirinArm, self))

	self.tab_headwear = self:FindObj("TabHeadwear")
	self.tab_mask = self:FindObj("TabMask")
	self.tab_waist = self:FindObj("TabWaist")
	self.tab_bead = self:FindObj("TabBead")
	self.tab_fabao = self:FindObj("TabFaBao")
	self.tab_kirin_arm = self:FindObj("TabKirinArm")

	self.show_red_point_list = {}
	for i = 1, DressUpViewState.MAX do
		self.show_red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end

	self.headwear_content = self:FindObj("HeadwearContent")
	self.headwear_view = DressUpHeadwearView.New()
	self.headwear_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		--引导用按钮
		self.headwear_view:SetInstance(obj)
		self.headwear_start_up = self.headwear_view.start_button
		self.headwear_view:SetNotifyDataChangeCallBack()
	end)

	self.mask_content = self:FindObj("MaskContent")
	self.mask_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.mask_view = DressUpMaskView.New(obj)
		-- 引导用按钮
		-- self.mask_content = self.mask_content.start_button
		self.mask_view:SetNotifyDataChangeCallBack()
	end)

	self.waist_content = self:FindObj("WaistContent")
	self.waist_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.waist_view = DressUpWaistView.New(obj)
		--引导用按钮
		self.waist_start_up = self.waist_view.start_button
		self.waist_view:SetNotifyDataChangeCallBack()
	end)

	self.bead_content = self:FindObj("BeadContent")
	self.bead_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.bead_view = DressUpBeadView.New(obj)
		self.bead_view:SetNotifyDataChangeCallBack()
	end)

	self.fabao_content = self:FindObj("FaBaoContent")
	self.fabao_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fabao_view = DressUpFaBaoView.New(obj)
		self.fabao_view:SetNotifyDataChangeCallBack()
	end)

	self.kirin_arm_content = self:FindObj("KirinArmContent")
	self.kirin_arm_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.kirin_arm_view = DressUpKirinArmView.New(obj)
		self.kirin_arm_view:SetNotifyDataChangeCallBack()
	end)

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self:InitTab()
	self.btn_close = self:FindObj("BtnClose")

	-- FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Advance, BindTool.Bind(self.GetUiCallBack, self))
end

function DressUpView:ReleaseCallBack()
	-- if FunctionGuide.Instance then
	-- 	FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Advance)
	-- end
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.headwear_view ~= nil then
		self.headwear_view:DeleteMe()
		self.headwear_view = nil
	end

	if self.mask_view ~= nil then
		self.mask_view:DeleteMe()
		self.mask_view = nil
	end

	if self.waist_view ~= nil then
		self.waist_view:DeleteMe()
		self.waist_view = nil
	end

	if self.bead_view ~= nil then
		self.bead_view:DeleteMe()
		self.bead_view = nil
	end
	
	if self.fabao_view ~= nil then
		self.fabao_view:DeleteMe()
		self.fabao_view = nil
	end

	if self.kirin_arm_view ~= nil then
		self.kirin_arm_view:DeleteMe()
		self.kirin_arm_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.tab_headwear = nil
	self.tab_mask = nil
	self.tab_waist = nil
	self.tab_bead = nil
	self.tab_fabao = nil
	self.tab_kirin_arm = nil
	self.show_red_point_list = {}
	self.btn_close = nil

	self.headwear_content = nil
	self.mask_content = nil
	self.waist_content = nil
	self.bead_content = nil
	self.fabao_content = nil
	self.kirin_arm_content = nil
	self.headwear_start_up = nil
	self.waist_start_up = nil
	
end

function DressUpView:OnRoleDrag(data)
	if UIScene.role_model then
		-- UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function DressUpView:OnHuashenUpgradeResult(result)
	-- self.huashen_view:OnHuashenUpgradeResult(result)
end

function DressUpView:OnSpiritUpgradeResult(result)
	-- self.huashen_protect_view:OnSpiritUpgradeResult(result)
end

function DressUpView:HeadwearUpgradeResult(result)
	if self.headwear_view then
		self.headwear_view:HeadwearUpgradeResult(result)
	end
end

function DressUpView:MaskUpgradeResult(result)
	if self.mask_view then
		self.mask_view:MaskUpgradeResult(result)
	end
end

function DressUpView:WaistUpgradeResult(result)
	if self.waist_view then
		self.waist_view:WaistUpgradeResult(result)
	end
end

function DressUpView:BeadUpgradeResult(result)
	if self.bead_view then
		self.bead_view:BeadUpgradeResult(result)
	end
end

function DressUpView:FaBaoUpgradeResult(result)
	if self.fabao_view then
		self.fabao_view:FaBaoUpgradeResult(result)
	end
end

function DressUpView:KirinArmUpgradeResult(result)
	if self.kirin_arm_view then
		self.kirin_arm_view:KirinArmUpgradeResult(result)
	end
end

function DressUpView:OpenHeadwear()
	if self.view_state == DressUpViewState.HEADWEAR then
		return
	end
	self:ShowIndex(TabIndex.headwear)
	self:StopAutoAdvance(DressUpViewState.HEADWEAR)
	self:ShowContent(DressUpViewState.HEADWEAR)
	self:SetToggleHighLight(self.view_state)
	if self.headwear_view then
		self.headwear_view:ResetModleRotation()
	end
end

function DressUpView:OpenMask()
	if self.view_state == DressUpViewState.MASK then
		return
	end
	self:ShowIndex(TabIndex.mask)
	self:StopAutoAdvance(DressUpViewState.MASK)
	self:ShowContent(DressUpViewState.MASK)
	self:SetToggleHighLight(self.view_state)
	if self.mask_view then
		self.mask_view:ResetModleRotation()
	end
end

function DressUpView:OpenWaist()
	if self.view_state == DressUpViewState.WAIST then
		return
	end
	self:ShowIndex(TabIndex.waist)
	self:StopAutoAdvance(DressUpViewState.WAIST)
	self:ShowContent(DressUpViewState.WAIST)
	self:SetToggleHighLight(self.view_state)
	if self.waist_view then
		self.waist_view:ResetModleRotation()
	end
end

function DressUpView:OpenBead()
	if self.view_state == DressUpViewState.BEAD then
		return
	end
	self:ShowIndex(TabIndex.bead)
	self:StopAutoAdvance(DressUpViewState.BEAD)
	self:ShowContent(DressUpViewState.BEAD)
	self:SetToggleHighLight(self.view_state)
	if self.bead_view then
		self.bead_view:ResetModleRotation()
	end
end

function DressUpView:OpenFaBao()
	if self.view_state == DressUpViewState.FABAO then
		return
	end
	self:ShowIndex(TabIndex.fabao)
	self:StopAutoAdvance(DressUpViewState.FABAO)
	self:ShowContent(DressUpViewState.FABAO)
	self:SetToggleHighLight(self.view_state)
end

function DressUpView:OpenKirinArm()
	if self.view_state == DressUpViewState.KIRINARM then
		return
	end
	self:ShowIndex(TabIndex.kirin_arm)
	self:StopAutoAdvance(DressUpViewState.KIRINARM)
	self:ShowContent(DressUpViewState.KIRINARM)
	self:SetToggleHighLight(self.view_state)
end

function DressUpView:ShowIndexCallBack(index)
	if self.headwear_view then
		self.headwear_view:ClearTempData()
	end

	if self.mask_view then
		self.mask_view:ClearTempData()
	end

	if self.waist_view then
		self.waist_view:ClearTempData()
	end

	if self.bead_view then
		self.bead_view:ClearTempData()
	end
	
	if self.fabao_view then
		self.fabao_view:ClearTempData()
	end

	if self.kirin_arm_view then
		self.kirin_arm_view:ClearTempData()
	end

	self:Flush()
	if index == TabIndex.headwear then
		local callback = function()
			if self.headwear_view then
				self.headwear_view:Flush("headwear")
			end
		end
		if self.headwear_view then
			self.headwear_view:OpenCallBack()
		end

	elseif index == TabIndex.mask then
		local callback = function()
			if self.mask_view then
				self.mask_view:Flush("mask")
			end
		end
		if self.mask_view then
			self.mask_view:OpenCallBack()
		end

	elseif index == TabIndex.waist then
		local callback = function()
			if self.waist_view then
				self.waist_view:Flush("waist")
			end
		end
		if self.waist_view then
			self.waist_view:OpenCallBack()
		end

	elseif index == TabIndex.bead then
		local callback = function()
			if self.bead_view then
				self.bead_view:Flush("bead")
			end
		end
		if self.bead_view then
			self.bead_view:OpenCallBack()
		end

	elseif index == TabIndex.fabao then
		local callback = function()
			if self.fabao_view then
				self.fabao_view:Flush("fabao")
			end
		end
		if self.fabao_view then
			self.fabao_view:OpenCallBack()
		end

	elseif index == TabIndex.kirin_arm then
		local callback = function()
			if self.kirin_arm_view then
				self.kirin_arm_view:Flush()
			end
		end
		if self.kirin_arm_view then
			self.kirin_arm_view:OpenCallBack()
		end
	end
end

function DressUpView:FlushSonView()
	if self.view_state == DressUpViewState.HEADWEAR then
		if self.headwear_view then
			self.headwear_view:Flush("headwear")
		end
	elseif self.view_state == DressUpViewState.MASK then
		if self.mask_view then
			self.mask_view:Flush("mask")
		end
	elseif self.view_state == DressUpViewState.WAIST then
		if self.waist_view then
			self.waist_view:Flush("waist")
		end
	elseif self.view_state == DressUpViewState.BEAD then
		if self.bead_view then
			self.bead_view:Flush("bead")
		end
	elseif self.view_state == DressUpViewState.FABAO then
		if self.fabao_view then
			self.fabao_view:Flush("fabao")
		end
	elseif self.view_state == DressUpViewState.KIRINARM then
		if self.kirin_arm_view then
			self.kirin_arm_view:Flush()
		end
	end
end

function DressUpView:ShowContent(id)
	self.view_state = id
	self.headwear_content:SetActive(id == DressUpViewState.HEADWEAR)
	self.mask_content:SetActive(id == DressUpViewState.MASK)
	self.waist_content:SetActive(id == DressUpViewState.WAIST)
	self.bead_content:SetActive(id == DressUpViewState.BEAD)
	self.fabao_content:SetActive(id == DressUpViewState.FABAO)
	self.kirin_arm_content:SetActive(id == DressUpViewState.KIRINARM)
	
	-- if id > DressUpViewState.HALIDOM and id ~= DressUpViewState.MASK then
	-- 	self.right_bar:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition = Vector2(0, 0)
	-- end

	if id == DressUpViewState.HEADWEAR then
		if self.headwear_view then
			self.headwear_view:Flush("headwear")
		end
	elseif id == DressUpViewState.MASK then
		if self.mask_view then
			self.mask_view:Flush("mask")
		end
	elseif id == DressUpViewState.WAIST then
		if self.waist_view then
			self.waist_view:Flush("waist")
		end
	elseif id == DressUpViewState.BEAD then
		if self.bead_view then
			self.bead_view:Flush("bead")
		end
	elseif id == DressUpViewState.FABAO then
		if self.fabao_view then
			self.fabao_view:Flush("fabao")
		end
	elseif id == DressUpViewState.KIRINARM then
		if self.kirin_arm_view then
			self.kirin_arm_view:Flush()
		end
	end
end

function DressUpView:SetToggleHighLight(id)
	self.tab_headwear.toggle.isOn = DressUpViewState.HEADWEAR == id
	self.tab_mask.toggle.isOn = DressUpViewState.MASK == id
	self.tab_waist.toggle.isOn = DressUpViewState.WAIST == id
	self.tab_bead.toggle.isOn = DressUpViewState.BEAD == id
	self.tab_fabao.toggle.isOn = DressUpViewState.FABAO == id
	self.tab_kirin_arm.toggle.isOn = DressUpViewState.KIRINARM == id

	if self.headwear_view then
		self.headwear_view:SetModle(DressUpViewState.HEADWEAR == id)
	end
	if self.mask_view then
		self.mask_view:SetModle(DressUpViewState.MASK == id)
	end
	if self.waist_view then
		self.waist_view:SetModle(DressUpViewState.WAIST == id)
	end
	if self.bead_view then
		self.bead_view:SetModle(DressUpViewState.BEAD == id)
	end
	if self.fabao_view then
		self.fabao_view:SetModle(DressUpViewState.FABAO == id)
	end
	if self.kirin_arm_view then
		self.kirin_arm_view:SetModle(DressUpViewState.KIRINARM == id)
	end
end

function DressUpView:StopAutoAdvance(id)
	if (self.headwear_view and self.headwear_view.is_auto) or (self.mask_view and self.mask_view.is_auto) or
		(self.waist_view and self.waist_view.is_auto) or (self.bead_view and self.bead_view.is_auto) or 
		(self.fabao_view and self.fabao_view.is_auto)  or (self.kirin_arm_view and self.kirin_arm_view.is_auto)  then
		if self.view_state ~= id then
			if self.view_state == DressUpViewState.HEADWEAR then
				self.headwear_view:OnAutomaticAdvance()
			elseif self.view_state == DressUpViewState.MASK then
				self.mask_view:OnAutomaticAdvance()
			elseif self.view_state == DressUpViewState.WAIST then
				self.waist_view:OnAutomaticAdvance()
			elseif self.view_state == DressUpViewState.BEAD then
				self.bead_view:OnAutomaticAdvance()
			elseif self.view_state == DressUpViewState.FABAO then
				self.fabao_view:OnAutomaticAdvance()
			elseif self.view_state == DressUpViewState.KIRINARM then
				self.kirin_arm_view:OnAutomaticAdvance()
			end
		end
	end
end

function DressUpView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self:StopAutoAdvance()
end

function DressUpView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:InitTab()
end

function DressUpView:ItemDataChangeCallback()
	self.show_red_point_list[1]:SetValue(DressUpData.Instance:IsShowHeadwearRedPoint())
	self.show_red_point_list[2]:SetValue(DressUpData.Instance:IsShowMaskRedPoint())
	self.show_red_point_list[3]:SetValue(DressUpData.Instance:IsShowWaistRedPoint())
	self.show_red_point_list[4]:SetValue(DressUpData.Instance:IsShowBeadRedPoint())
	self.show_red_point_list[5]:SetValue(DressUpData.Instance:IsShowFaBaoRedPoint())
	self.show_red_point_list[6]:SetValue(DressUpData.Instance:IsShowKirinArmRedPoint())
	-- for k,v in pairs(self.show_red_point_list) do
	-- 	v:SetValue(DressUpData.Instance:GetIsShowRed(k))
	-- end
	self:Flush()
end

function DressUpView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_list) do
		if k == "headwear" then
			if self.headwear_view and self.tab_headwear.toggle.isOn then
				self.headwear_view:Flush(k)
			end
			self.show_red_point_list[1]:SetValue(DressUpData.Instance:IsShowHeadwearRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.DressUp, DressUpData.Instance:GetCanUplevel()
			-- 	or DressUpData.Instance:IsShowRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUp)
			RemindManager.Instance:Fire(RemindName.DressUpHeadwear)
		elseif k == "mask" then
			if self.mask_view and self.tab_mask.toggle.isOn then
				self.mask_view:Flush(k)
			end
			self.show_red_point_list[2]:SetValue(DressUpData.Instance:IsShowMaskRedPoint())
			--self.show_red_point_list[1]:SetValue(DressUpData.Instance:IsShowHeadwearRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.DressUp, DressUpData.Instance:GetCanUplevel()
			-- 	or DressUpData.Instance:IsShowRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUp)
			RemindManager.Instance:Fire(RemindName.DressUpMask)
		elseif k == "waist" then
			if self.waist_view and self.tab_waist.toggle.isOn then
				self.waist_view:Flush()
			end
			self.show_red_point_list[3]:SetValue(DressUpData.Instance:IsShowWaistRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUp)
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.DressUp, DressUpData.Instance:GetCanUplevel()
			-- 	or DressUpData.Instance:IsShowRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUpWaist)
		elseif k == "bead" then
			if self.bead_view and self.tab_bead.toggle.isOn then
				self.bead_view:OnFlush(param_list)
			end
			self.show_red_point_list[4]:SetValue(DressUpData.Instance:IsShowBeadRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUp)

			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.DressUp, DressUpData.Instance:GetCanUplevel()
			-- 	or DressUpData.Instance:IsShowRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUpBead)
		elseif k == "fabao" then
			if self.fabao_view and self.tab_fabao.toggle.isOn then
				self.fabao_view:Flush(k)
			end
			self.show_red_point_list[5]:SetValue(DressUpData.Instance:IsShowFaBaoRedPoint())
			RemindManager.Instance:Fire(RemindName.DressUp)
			-- self.show_red_point_list[5]:SetValue(DressUpData.Instance:IsShowHuaShenRedPoint())
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.DressUp, DressUpData.Instance:GetCanUplevel()
			-- 	or DressUpData.Instance:IsShowRedPoint())
		elseif k == "kirin_arm" then
			if self.kirin_arm_view and self.tab_kirin_arm.toggle.isOn then
				self.kirin_arm_view:Flush()
			end
			RemindManager.Instance:Fire(RemindName.DressUp)
			self.show_red_point_list[6]:SetValue(DressUpData.Instance:IsShowKirinArmRedPoint())
			-- self.show_top_haushen_red_point:SetValue(DressUpData.Instance:IsShowTopHuashenRedPoint())
		
		elseif k == "all"then
			self.show_red_point_list[1]:SetValue(DressUpData.Instance:IsShowHeadwearRedPoint())
			self.show_red_point_list[2]:SetValue(DressUpData.Instance:IsShowMaskRedPoint())
			self.show_red_point_list[3]:SetValue(DressUpData.Instance:IsShowWaistRedPoint())
			self.show_red_point_list[4]:SetValue(DressUpData.Instance:IsShowBeadRedPoint())
			self.show_red_point_list[5]:SetValue(DressUpData.Instance:IsShowFaBaoRedPoint())
			self.show_red_point_list[6]:SetValue(DressUpData.Instance:IsShowKirinArmRedPoint())
			
			if cur_index == TabIndex.headwear then
				self:StopAutoAdvance(DressUpViewState.HEADWEAR)
				self:ShowContent(DressUpViewState.HEADWEAR)
				self:SetToggleHighLight(self.view_state)
				if self.headwear_view then
					self.headwear_view:ResetModleRotation()
				end
			elseif cur_index == TabIndex.mask then
				self:StopAutoAdvance(DressUpViewState.MASK)
				self:ShowContent(DressUpViewState.MASK)
				self:SetToggleHighLight(self.view_state)
				-- if self.mask_view then
				-- 	self.mask_view:ResetModleRotation()
				-- end
			elseif cur_index == TabIndex.waist then
				self:OpenWaist()
				self:ShowContent(DressUpViewState.WAIST)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.bead then
				self:OpenBead()
				self:ShowContent(DressUpViewState.BEAD)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.fabao then
				self:OpenFaBao()
				self:ShowContent(DressUpViewState.FABAO)
				self:SetToggleHighLight(self.view_state)
			elseif cur_index == TabIndex.kirin_arm then
				self:OpenKirinArm()
				self:ShowContent(DressUpViewState.KIRINARM)
				self:SetToggleHighLight(self.view_state)
			end
		end
	end
end

function DressUpView:InitTab()
	if not self:IsOpen() then return end

	if self.tab_headwear then
		self.tab_headwear:SetActive(OpenFunData.Instance:CheckIsHide("headwear"))
	end

	if self.tab_mask then
		self.tab_mask:SetActive(OpenFunData.Instance:CheckIsHide("mask"))
	end

	if self.tab_waist then
		self.tab_waist:SetActive(OpenFunData.Instance:CheckIsHide("waist"))
	end
	if self.tab_bead then
		self.tab_bead:SetActive(OpenFunData.Instance:CheckIsHide("bead"))
	end
	
	if self.tab_fabao then
		self.tab_fabao:SetActive(OpenFunData.Instance:CheckIsHide("fabao"))
	end
	
	if self.tab_kirin_arm then
		self.tab_kirin_arm:SetActive(OpenFunData.Instance:CheckIsHide("kirin_arm"))
	end
end

--引导用函数
function DressUpView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.headwear then
		self:OpenHeadwear()
		self.tab_headwear.toggle.isOn = true
	elseif index == TabIndex.waist then
		self:OpenWaist()
		self.tab_waist.toggle.isOn = true
	elseif index == TabIndex.bead then
		self:OpenBead()
		self.tab_bead.toggle.isOn = true
	elseif index == TabIndex.fabao then
		self:OpenFaBao()
		self.tab_fabao.toggle.isOn = true
	end
end

function DressUpView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.headwear then
			if self.tab_headwear.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.headwear)
				return self.tab_headwear, callback
			end
		elseif index == TabIndex.waist then
			if self.tab_waist.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.waist)
				return self.tab_waist, callback
			end
		elseif index == TabIndex.bead then
			if self.tab_bead.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.bead)
				return self.tab_bead, callback
			end
		elseif index == TabIndex.fabao then
			if self.tab_fabao.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fabao)
				return self.tab_fabao, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end