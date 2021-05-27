------------------------------------------------------------
--人物相关主View
------------------------------------------------------------
RoleView = RoleView or BaseClass(XuiBaseView)

function RoleView:__init()
	-- self.view_name = GuideModuleName.RoleView
	-- self:SetHasCommonBag(true)

	self:SetModal(true)
	self.def_index = TabIndex.role_intro
	self.r_tabindex = 1
	self.has_load = false
	self.texture_path_list[1] = 'res/xui/role.png'
	self.texture_path_list[2] = 'res/xui/equipbg.png'
	self.texture_path_list[3] = 'res/xui/skill.png'
	self.texture_path_list[4] = 'res/xui/wing.png'
	-- self.texture_path_list[5] = 'res/xui/exploit.png'
	self.texture_path_list[5] = 'res/xui/equipment.png'
	self.texture_path_list[6] = 'res/xui/gemstone.png'
	self.texture_path_list[7] = 'res/xui/fashion.png'
	self.texture_path_list[8] = 'res/xui/mainui.png'
	self.title_img_path = ResPath.GetRole("btn_juese_txt")

	self.config_tab = {
		{"common_ui_cfg", 5, {0}},
		{"common_ui_cfg", 1, {0}},
		{"role_ui_cfg", 2, {TabIndex.role_skill}},
		{"role_ui_cfg", 3, {TabIndex.role_skill_select}},
		{"role_ui_cfg", 4, {TabIndex.role_skill_select}},
		{"role_ui_cfg", 5, {TabIndex.role_inner}},
		{"role_ui_cfg", 6, {TabIndex.role_title}},
		{"role_ui_cfg", 7, {TabIndex.role_zhuansheng}},
		{"role_ui_cfg", 11, {TabIndex.role_cycle}},
		{"role_ui_cfg", 12, {TabIndex.role_wing}},
		{"role_ui_cfg", 16, {TabIndex.role_meridians}},
		--{"role_ui_cfg", 19,{TabIndex.role_gemstone}},
		-- {"exploit_ui_cfg", 1, {TabIndex.role_exploit}},
		{"role_ui_cfg", 1, {TabIndex.role_intro}},
		{"common_ui_cfg", 2, {0}},
		{"role_ui_cfg", 18, {TabIndex.role_intro}},
		--{"role_ui_cfg", 19, {TabIndex.role_intro}},
	}

	

	self.tabbar = TabbarTwo.New(Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar:Init(Language.Role.TabGrop, {nil, nil, nil, nil, nil,nil,nil}, true)
	self.tabbar:SetSelectCallback(BindTool.Bind1(self.OnTabChangeHandler, self))
	-- self.tabbar:SetToggleVisible(TabIndex.role_zhuansheng, false)
	self.tabbar:SetToggleVisible(TabIndex.role_cycle, false)
	self.tabbar:SetToggleVisible(TabIndex.role_gemstone, false)
	-- self.tabbar:SetInterval(-10)
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.role_intro] = RoleIntroPage.New() --人物简介页面
	self.page_list[TabIndex.role_skill] = RoleSkillPage.New() --人物技能页面
	self.page_list[TabIndex.role_skill_select] = RoleSkillSelectPage.New() --人物技能选择页面
	self.page_list[TabIndex.role_meridians] = RoleMeridiansPage.New() --人物经脉页面
	--self.page_list[TabIndex.role_gemstone] = GemStoneView.New()
	self.page_list[TabIndex.role_wing] = RoleWingPage.New() --人物轮回页面
	self.page_list[TabIndex.role_title] = RoleTitlePage.New() --人物称号页面
 	self.page_list[TabIndex.role_inner] = RoleInnerPage.New() --人物内功页面
	self.page_list[TabIndex.role_zhuansheng] = RoleZhuanshengPage.New() --人物转生页面
	self.page_list[TabIndex.role_cycle] = RoleCyclePage.New() --人物轮回页面
	-- self.page_list[TabIndex.role_exploit] = RoleExploitPage.New() --人物功勋页面
end

function RoleView:__delete()
	self.tabbar:DeleteMe()
	self.tabbar = nil
	self.select_cell = nil
end

function RoleView:ReleaseCallBack()
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end
	if self.role_info_widget then
		self.role_info_widget:DeleteMe()
		self.role_info_widget = nil
	end
	if self.tabbar then
		self.tabbar:Release()
	end
	
	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.Role)
end

function RoleView:LoadCallBack(index, loaded_times)
	if self.page_list[index] then
		self.page_list[index]:InitPage(self)
	end	
	self:CreateRoleInfoWidget()
	if loaded_times <= 1 then
		ViewManager.Instance:RegsiterTabFunUi(ViewName.Role, self.tabbar)
	end
	-- if IS_ON_CROSSSERVER == true then
	
	-- end
	self:UptateTabbarRemind()
end

function RoleView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- EquipmentCtrl.Instance:SendGetRoleDiamondDataReq(0)
	-- EquipmentCtrl.Instance:SmeltDiamondReq(0)
	self.tabbar:ChangeToIndex(self.show_index, self.root_node)
end

function RoleView:ShowIndexCallBack(index)
	self.old_inner_lv = nil
	if index == TabIndex.role_skill_select then
		self.tabbar:ChangeToIndex(TabIndex.role_skill, self.root_node)
	else
		self.tabbar:ChangeToIndex(index, self.root_node)
	end
	self.r_tabindex = index
	if index == TabIndex.role_title then
		self.cur_select_title = 1
	end
	-- if index == TabIndex.role_gemstone then
	-- 	self.page_list[TabIndex.role_gemstone]:FlushTabbarPoint()
	-- end 

	self:Flush(index)
end

function RoleView:OnTabChangeHandler(index)
	self:ChangeToIndex(index)
end


function RoleView:OnFlush(param_t, index)
	if 	self.page_list[index] then
		self.page_list[index]:UpdateData(param_t)
	end
	for k,v in pairs(param_t) do
		if k == "remind" then
			self:UptateTabbarRemind()
			-- if self.page_list[TabIndex.role_gemstone] then
			-- 	self.page_list[TabIndex.role_gemstone]:FlushTabbarPoint()
			-- end
		elseif k == "link_tiao_zhuan" then
			-- if self.page_list[TabIndex.role_gemstone] then
			-- 	self.page_list[TabIndex.role_gemstone]:SetSlectBtn(v.key)
			-- end
		end
	end
end

function RoleView:RemindChange(remind_name, num)
	-- if remind_name == RemindName.InnerUpGrade 
		if remind_name == RemindName.CanZhuansheng 
		or remind_name == RemindName.WingUpGrade
		or remind_name == RemindName.MeridianUp  
		or RemindName.InnerUpGrade then
		-- or remind_name == RemindName.EquipmentHunZhu
		-- or remind_name == RemindName.GemCouond  then
		self:Flush(0, "remind")
	end	
end

function RoleView:UptateTabbarRemind()
	self.tabbar:SetRemindByIndex(TabIndex.role_inner, RemindManager.Instance:GetRemind(RemindName.InnerUpGrade) > 0)
	self.tabbar:SetRemindByIndex(TabIndex.role_zhuansheng, RemindManager.Instance:GetRemind(RemindName.CanZhuansheng) > 0)
	self.tabbar:SetRemindByIndex(TabIndex.role_wing, RemindManager.Instance:GetRemind(RemindName.WingUpGrade) > 0)
	self.tabbar:SetRemindByIndex(TabIndex.role_meridians, RemindManager.Instance:GetRemind(RemindName.MeridianUp) > 0)
	-- local num = RemindManager.Instance:GetRemind(RemindName.EquipmentHunZhu) + RemindManager.Instance:GetRemind(RemindName.GemCouond)
	-- self.tabbar:SetRemindByIndex(TabIndex.role_gemstone, num > 0)
	-- self.tabbar:SetRemindByIndex(TabIndex.role_exploit, RemindManager.Instance:GetRemind(RemindName.Exploit) > 0)
end

function RoleView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RoleView:CreateRoleInfoWidget()
	if self.role_info_widget == nil and self.node_t_list.layout_role_info_widget then
		self.role_info_widget = RoleInfoView.New()
		self.role_info_widget:CreateViewByUIConfig(self.ph_list.ph_role_info_widget, "equip")
		self.node_t_list.layout_role_info_widget.node:addChild(self.role_info_widget:GetView(), 200) 
		self.role_info_widget:SetRoleData(RoleData.Instance.role_vo)
	end
end
