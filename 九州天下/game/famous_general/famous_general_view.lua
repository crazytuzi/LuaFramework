FamousGeneralTabIndex = {
	TabIndex.ming_jiang,
	TabIndex.qian_neng,
	TabIndex.dian_jiang,
	TabIndex.jiang_bang,
	TabIndex.chou_jiang,
	TabIndex.general_bone,
}

FamousGeneralView = FamousGeneralView or BaseClass(BaseView)
function FamousGeneralView:__init()
	self.ui_config = {"uis/views/famousgeneralview", "FamousGeneralView"}
	self.toggle_list = {}
	self.def_index = TabIndex.ming_jiang
	self:SetMaskBg()
end

function FamousGeneralView:ReleaseCallBack()
	if self.general_view then 
		self.general_view:DeleteMe()
		self.general_view = nil
	end

	if self.potential_view then
		self.potential_view:DeleteMe()
		self.potential_view = nil
	end

	if self.setfight_view then 
		self.setfight_view:DeleteMe()
		self.setfight_view = nil
	end

	if self.combo_view then
		self.combo_view:DeleteMe()
		self.combo_view = nil 
	end

	if self.chou_view then 
		self.chou_view:DeleteMe()
		self.chou_view = nil
	end

	if self.bone_view then
		self.bone_view:DeleteMe()
		self.bone_view = nil
	end

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.remind_list = {}
	self.show_bg_list = {}

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FamousGeneralView)
	end
	self.btn_close = nil
	self.general_item_btn_active = nil
	self.general_btn_change_first = nil
	self.general_item_btn_select = nil
	self.toggle_list = {}

	FamousGeneralData.Instance:ClearSortList()
end


function FamousGeneralView:OpenCallBack()
	self:ShowOrHideTab()
end


function FamousGeneralView:LoadCallBack()
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_INFO)
	for i = 1, 6 do
		self.toggle_list[FamousGeneralTabIndex[i] % 10] = self:FindObj("toogle_" .. i)
		self.toggle_list[FamousGeneralTabIndex[i] % 10].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, FamousGeneralTabIndex[i]))
	end

	-- 子标签
	self.general_view = GeneralRenderView.New()
	local general_content = self:FindObj("GeneralContent")
	general_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.ming_jiang
		self.general_view:SetInstance(obj)
		self:Flush()
		self.general_view:FlushSkillInfo()
	end)

	self.potential_view = PotentialRenderView.New()
	local potential_content = self:FindObj("PotentialContent")
	potential_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.qian_neng
		self.potential_view:SetInstance(obj)
		self:Flush()
	end)

	self.setfight_view = SetFightRenderView.New()
	local setfight_content = self:FindObj("SetFightContent")
	setfight_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.dian_jiang
		self.setfight_view:SetInstance(obj)
		self:Flush()
	end)

	self.combo_view = ComboRenderView.New()
	local combo_content = self:FindObj("ComboContent")
	combo_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.jiang_bang
		self.combo_view:SetInstance(obj)
		self:Flush()
	end)

	self.chou_view = GeneralChouView.New()
	local chou_content = self:FindObj("ChouContent")
	chou_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.chou_jiang
		self.chou_view:SetInstance(obj)
		self:Flush()
	end)

	self.bone_view = BoneRenderView.New()
	local bone_content = self:FindObj("BoneContent")
	bone_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.general_bone
		self.bone_view:SetInstance(obj)
		self:Flush()
	end)

	self.remind_list = {
		[RemindName.General_Info] = self:FindVariable("RedInfo"),
		[RemindName.General_Wash] = self:FindVariable("RedWash"),
		[RemindName.General_Fight] = self:FindVariable("RedFight"),
		[RemindName.GeneralJiu] = self:FindVariable("RedJiu"),
		[RemindName.GeneralBone] = self:FindVariable("RedBone"),
	}
	for k, _ in pairs(self.remind_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.show_bg_list = {}
	for i = 1, 3 do
		self.show_bg_list[i] = self:FindVariable("IsShowBg" .. i)
	end

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	--引导
	self.btn_close = self:FindObj("Close")
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FamousGeneralView, BindTool.Bind(self.GetUiCallBack, self))
end

function FamousGeneralView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
		if self.potential_view then
			self.potential_view:Flush("Stop")
		end
	end
end

function FamousGeneralView:ShowIndexCallBack(index)
	self.toggle_list[index % 10].toggle.isOn = true
	self:Flush("all", {"change_index"})

	if self.show_index == TabIndex.jiang_bang then
		self.combo_view:ChangeSelect(false)
		self:SetBgShow(3)
	elseif self.show_index == TabIndex.dian_jiang then
		self:SetBgShow(2)
	elseif self.show_index == TabIndex.chou_jiang then
		self:SetBgShow(4)
	else
		self:SetBgShow(1)
	end
end

function FamousGeneralView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if self.show_index == TabIndex.ming_jiang then
				self.general_view:Flush(v[1])
			elseif self.show_index == TabIndex.qian_neng then
				self.potential_view:Flush(v[1])
			elseif self.show_index == TabIndex.dian_jiang then
				self.setfight_view:Flush(v[1])
			elseif self.show_index == TabIndex.jiang_bang then
				self.combo_view:Flush(v[1])
			elseif self.show_index == TabIndex.chou_jiang then
				self.chou_view:Flush(v[1])
			elseif self.show_index == TabIndex.general_bone then
				self.bone_view:Flush(v[1])
			end
		elseif k == "flush_general_view" then
			self.general_view:Flush(v[1])
		elseif k == "flush_potential_view" then
			self.potential_view:Flush(v[1])
		elseif k == "flush_setfight_view" then
			self.setfight_view:Flush(v[1])
		elseif k == "flush_combo_view" then
			self.combo_view:Flush(v[1])
		elseif k == "flush_chou_view" then
			self.chou_view:Flush(v[1])
		elseif k == "flush_bone_view" then
			self.bone_view:Flush(v[1])
		elseif k == "uplevel" then
			self.potential_view:Flush("Continue")
		elseif k == "stopuplevel" then
			self.potential_view:Flush("Stop")
		end
	end
end

function FamousGeneralView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.remind_list[remind_name] then
		self.remind_list[remind_name]:SetValue(num > 0)
	end
end

function FamousGeneralView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		else
			return NextGuideStepFlag
		end
	else
		if ui_name == GuideUIName.Tab then
			local index = TabIndex[ui_param]
			if index == TabIndex.dian_jiang then
				if self.toggle_list[TabIndex.dian_jiang % 10].gameObject.activeInHierarchy then
					return self.toggle_list[TabIndex.dian_jiang % 10]
				end
			end
		elseif ui_name == GuideUIName.GeneralBtnChangeFirst then
			self.general_btn_change_first = self.setfight_view:GetBtnChangeFirst()
			if self.general_btn_change_first and self.general_btn_change_first.gameObject.activeInHierarchy then
				return self.general_btn_change_first,self.setfight_view:GetBtnChangeFirstOnClick()
			else
				return NextGuideStepFlag
			end
		elseif ui_name == GuideUIName.GeneralItemBtnActive then
			return self.general_view:GetItemBtnActive()
		elseif ui_name == GuideUIName.GeneralItemBtnSelect then
			return FamousGeneralCtrl.Instance.select_view:GetSelectItemCell()
		end
	end
end

-- 设置显示背景
function FamousGeneralView:SetBgShow(index)
	for k,v in pairs(self.show_bg_list) do
		if index == k then
			v:SetValue(true)
		else
			v:SetValue(false)
		end
	end
end

function FamousGeneralView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.toggle_list[FamousGeneralTabIndex[1] % 10]:SetActive(open_fun_data:CheckIsHide("famousgeneralview_ming_jiang"))
	self.toggle_list[FamousGeneralTabIndex[2] % 10]:SetActive(open_fun_data:CheckIsHide("famousgeneralview_qian_neng"))
	--self.toggle_list[FamousGeneralTabIndex[3] % 10]:SetActive(open_fun_data:CheckIsHide("famousgeneralview_dian_jiang"))
	self.toggle_list[FamousGeneralTabIndex[4] % 10]:SetActive(open_fun_data:CheckIsHide("famousgeneralview_jiang_bang"))
	self.toggle_list[FamousGeneralTabIndex[5] % 10]:SetActive(open_fun_data:CheckIsHide("famousgeneralview_chou_jiang"))
	self.toggle_list[FamousGeneralTabIndex[6] % 10]:SetActive(open_fun_data:CheckIsHide("famousgeneralview_general_bone"))	
end
