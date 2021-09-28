FamousGeneralView = FamousGeneralView or BaseClass(BaseView)

FAMOUS_GENERAL_MAX_TAB = 4
function FamousGeneralView:__init()
	self.ui_config = {"uis/views/famous_general_prefab", "FamousGeneralView"}
	self.def_index = TabIndex.famous_general_info
	self.root_index = self.def_index - 1
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
end

function FamousGeneralView:__delete()

end

function FamousGeneralView:LoadCallBack()
	-- 父物体获取
	self.info_content = self:FindObj("info_content")
	self.potential_content = self:FindObj("potential_content")
	self.talent_content = self:FindObj("talent_content")
	self.wakeup_content = self:FindObj("wakeup_content")

	self.toggle_list = {}
	for i = 1, FAMOUS_GENERAL_MAX_TAB do
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
		self.toggle_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, i + self.root_index))
	end

	self.remind_list = {
		[RemindName.General_Info] = self:FindVariable("RedInfo"),
		[RemindName.General_Potential] = self:FindVariable("RedPotential"),
		[RemindName.FamousTalent] = self:FindVariable("RedTalent"),
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.remind_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	-- 元宝
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	-- 首次执行时读取一次
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	self:ListenEvent("Close",BindTool.Bind(self.Close,self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))
	--引导
	self.btn_close = self:FindObj("Close")
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FamousGeneralView, BindTool.Bind(self.GetUiCallBack, self))
end

function FamousGeneralView:ReleaseCallBack()
	self.info_content = nil
	self.potential_content = nil
	self.talent_content = nil
	self.wakeup_content = nil
	self.btn_close = nil
	self.remind_list = nil
	self.toogle_list = nil
	self.gold = nil
	self.bind_gold = nil

	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.potential_view then
		self.potential_view:DeleteMe()
		self.potential_view = nil
	end


	if self.talent_view then
		self.talent_view:DeleteMe()
		self.talent_view = nil
	end

	if self.wakeup_view then
		self.wakeup_view:DeleteMe()
		self.wakeup_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FamousGeneralView)
	end

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
end

function FamousGeneralView:OpenCallBack()
	self:ShowOrHideTab()

	self:DelayOpenJump("info_view")
end

function FamousGeneralView:DelayOpenJump(name)
	if self.info_view and name == "info_view" then
		self.info_view:Jump()
	end
end

function FamousGeneralView:CloseCallBack()
	if self.potential_view then
		self.potential_view:CloseCallBack()
	end
end

function FamousGeneralView:OnFlush(param_t)
	self.delay_flush_param = {}
	for k,v in pairs(param_t) do
		if k == "all" then
			if self.show_index == TabIndex.famous_general_info then
				table.insert(self.delay_flush_param, {key = "info_view", value = v[1]})
			elseif self.show_index == TabIndex.famous_general_potential then
				table.insert(self.delay_flush_param, {key = "potential_view", value = v[1]})
			elseif self.show_index == TabIndex.famous_general_wakeup then
				table.insert(self.delay_flush_param, {key = "wakeup_view", value = v[1]})
			elseif self.show_index == TabIndex.famous_general_talent then
				table.insert(self.delay_flush_param, {key= "talent_view", value = v[1]})
			end
		elseif k == "flush_model" then
			table.insert(self.delay_flush_param, {key = "info_view", value = "flush_model"})
			table.insert(self.delay_flush_param, {key = "potential_view", value = "flush_model"})
		elseif k == "anim" then
			table.insert(self.delay_flush_param, {key = "wakeup_view", value = "anim"})
		elseif k == "potential_view" then
			table.insert(self.delay_flush_param, {key = "potential_view", value = v[1]})
		end
	end
	self:DelayFlushParam()
end

function FamousGeneralView:DelayFlushParam()
	for i,v in ipairs(self.delay_flush_param) do
		local view_name = v.key
		local value = v.value
		if self[view_name] then
			self[view_name]:Flush(value)
		end
	end
end

function FamousGeneralView:ShowOrHideTab()
	if not self:IsOpen() then
		return 
	end

	for i,v in ipairs(self.toggle_list) do
		v:SetActive(FamousGeneralData.Instance:IsShowTab(i + self.root_index))
	end
end

function FamousGeneralView:ConstructData()
	
end

function FamousGeneralView:SetFlag()
	
end

function FamousGeneralView:ShowIndexCallBack(index)
	-- 将tabindex转化为可供遍历的从1开始的整数
	self.jump_two = nil
	if index == TabIndex.famous_general_guangwu then
		index = TabIndex.famous_general_info
		self.show_index = TabIndex.famous_general_info
		self.jump_two = "OnClickGuangWu"
		if self.info_view then
			self.info_view:SetJump(self.jump_two)
			self.jump_two = nil
		end
	end
	if index == TabIndex.famous_general_fazheng then
		index = TabIndex.famous_general_info
		self.show_index = TabIndex.famous_general_info
		self.jump_two = "OnClickFaZhen"
		if self.info_view then
			self.info_view:SetJump(self.jump_two)
			self.jump_two = nil
		end
	end
	index = index % self.root_index

	self:AsyncLoadView(index)

	self:ShowHighLight()

	self:Flush()

end

function FamousGeneralView:ShowHighLight()
	for i,v in ipairs(self.toggle_list) do
		v.toggle.isOn = i == self.show_index % self.root_index
	end
end

function FamousGeneralView:ConstructViewCfg()
	return 
	{
		[1] = 
		{
			bundle = "uis/views/famous_general_prefab", 
			asset = "FamousGeneralInfoContent", 
		 	view_name = "info_view",
		 	parent= self.info_content, 
		 	view_script = FamousGeneralInfoContent
		},
		[2] = 
		{
			bundle = "uis/views/famous_general_prefab", 
			asset = "FamousGeneralPotentialContent", 
		 	view_name = "potential_view", 
		 	parent= self.potential_content, 
		 	view_script = FamousGeneralPotentialContent
		},
		[3] = 
		{
			bundle = "uis/views/famous_general_prefab", 
			asset = "FamousTalentContent", 
		 	view_name = "talent_view", 
		 	parent= self.talent_content, 
		 	view_script = FamousTalentContent
		},
		[4] = 
		{
			bundle = "uis/views/famous_general_prefab", 
			asset = "FamousAwakeContent", 
		 	view_name = "wakeup_view", 
		 	parent= self.wakeup_content, 
		 	view_script = FamousGeneralWakeUpView
		}
	}
end

function FamousGeneralView:AsyncLoadView(index)
	-- 构造界面标签数据
	local view_cfg = self:ConstructViewCfg()
	-- 通用处理
	local current_view_cfg = view_cfg[index]

	if current_view_cfg and not self[current_view_cfg.view_name] then
		UtilU3d.PrefabLoad(current_view_cfg.bundle, current_view_cfg.asset,
			function(obj)
				obj.transform:SetParent(current_view_cfg.parent.transform, false)
				obj = U3DObject(obj)
				self[current_view_cfg.view_name] = current_view_cfg.view_script.New(obj)
				local normal_dispose_flag = self:SpecialLoadCallBack(current_view_cfg.view_name)
				if normal_dispose_flag then
					self[current_view_cfg.view_name]:Flush()
					self:DelayFlushParam()
				end
				self:DelayOpenJump(current_view_cfg.view_name)
			end)
	end
end


-- 如果要在加载子界面时特殊处理写这里
function FamousGeneralView:SpecialLoadCallBack(view_name)
	if view_name == "info_view" then
		self[view_name]:Flush("open")
		if self.jump_two then
			self[view_name]:SetJump(self.jump_two)
			self.jump_two = nil
		end
		return false
	end
	return true
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

---------------------------事件------------
function FamousGeneralView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
	end
end

-- 玩家钻石改变时
function FamousGeneralView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(value))
	end

	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function FamousGeneralView:ShowPotentialEffect()
	if self.potential_view then
		self.potential_view:ShowEffect()
	end
end

function FamousGeneralView:ShowInfoEffect()
	if self.info_view then
		self.info_view:ShowEffect()
	end
end

function FamousGeneralView:SetInfoAnim()
	if self.info_view then
		self.info_view:SetAnim()
	end
end

function FamousGeneralView:GetChouJiangData()
	if self.wakeup_view then
		self.wakeup_view:SetDataFlag(false)
	end
end

function FamousGeneralView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end
