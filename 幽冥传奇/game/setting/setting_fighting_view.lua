SettingView = SettingView or BaseClass(BaseView)

function SettingView:FightingInit()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	self.layout_skill_top = self.node_tree.layout_skill_set.layout_skill_top
	self.layout_skill_center = self.node_tree.layout_skill_set["layout_skill_center" .. prof]
	self.layout_skill_down = self.node_tree.layout_skill_set.layout_skill_down
	self.layout_skill_down.node:retain()
	self.layout_skill_down.node:removeFromParent()
	self.node_t_list.scroll_index3.node:addChild(self.layout_skill_down.node)
	self.layout_skill_down.node:release()
	self.layout_skill_center.node:retain()
	self.layout_skill_center.node:removeFromParent()
	self.node_t_list.scroll_index3.node:addChild(self.layout_skill_center.node)
	self.layout_skill_center.node:release()
	local down_height = self.layout_skill_down.node:getContentSize().height
	local center_height = self.layout_skill_center.node:getContentSize().height
	local top_height = self.layout_skill_top.node:getContentSize().height
	local scroll_size = self.node_t_list.scroll_index3.node:getContentSize()
	local all_height = down_height + center_height + top_height + 15
	local off_height = math.max(scroll_size.height - all_height, 0)
	local down_y = self.layout_skill_down.node:getPositionY()
	self.layout_skill_down.node:setPositionY(down_y + off_height)
	self.layout_skill_center.node:setPositionY(self.layout_skill_down.node:getPositionY() + (down_height + center_height) / 2+5)
	self.layout_skill_top.node:retain()
	self.layout_skill_top.node:removeFromParent()
	self.node_t_list.scroll_index3.node:addChild(self.layout_skill_top.node)
	self.layout_skill_top.node:release()
	self.layout_skill_top.node:setPositionY(self.layout_skill_center.node:getPositionY() + (center_height + top_height) / 2)
	self.node_t_list.scroll_index3.node:setInnerContainerSize(cc.size(scroll_size.width, all_height + off_height))

	local x = self.layout_skill_down.node:getPositionX() - self.layout_skill_down.node:getContentSize().width/2
	local box_bg = XUI.CreateImageViewScale9(0, 100, 165, 70, nil, true)
	self.node_t_list.scroll_index3.node:addChild(box_bg)
	box_bg:setAnchorPoint(0, 1)
	box_bg:setPositionY(self.layout_skill_top.node:getPositionY() + top_height/2)
	local center_y = self.layout_skill_center.node:getPositionY()
	local height = self.layout_skill_top.node:getPositionY() + top_height/2 - center_y + center_height/ 2
	box_bg:setContentWH(700, height)

	self.node_t_list.scroll_index3.node:jumpToTop()
	for i = 1, 3 do
		self.node_tree.layout_skill_set["layout_skill_center" .. i].node:setVisible(i == prof)
	end
	for i = self.GJ_OPTION_COUNT + 1, self.GJ_OPTION_COUNT2 do
		XUI.AddClickEventListener(self.node_t_list["layout_gj_option"..i].node, BindTool.Bind(self.OnClickGuijiSetting, self, i))
		self.node_t_list["layout_gj_option"..i].lbl_set_name.node:setString(Language.Setting.GjOptionNames[i])
	end
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	self.node_t_list.lbl_guaji_single.node:setString(string.format(Language.Setting.SingleSkill, Language.Common.ProfName[prof]))
	self.node_t_list.lbl_guaji_group.node:setString(string.format(Language.Setting.GroupSkill, Language.Common.ProfName[prof]))
	for i,v in ipairs(SettingData.SkillOption[prof]) do
		XUI.AddClickEventListener(self.node_t_list["layout_gj_option_" .. prof .. "_" .. i].node, BindTool.Bind(self.OnClickGuijiSkillSetting, self, i, v))
		self.node_t_list["layout_gj_option_" .. prof .. "_" .. i].lbl_set_name.node:setString(Language.Setting.ProfSkillOptionNames[prof][i])
	end

	--屏蔽召唤法神
	-- self.node_t_list["layout_gj_option12"].node:setVisible(false)

	-- 自动施展必杀技
	-- XUI.AddClickEventListener(self.node_t_list["layout_gj_option_bisha"].node, BindTool.Bind(self.OnClickDisplayNirvana, self))
	-- self.node_t_list["layout_gj_option_bisha"].lbl_set_name.node:setString(Language.Setting.PinbiNuSkill)

	self:InitSingleSkillData()
	self:InitGroupSkillData()
	self:RefreshCheckBoxGuaJi2()
	self.node_t_list.btn_select_single.node:addClickEventListener(BindTool.Bind(self.OnClickSingleAttactHp, self))
	self.node_t_list.btn_select_group.node:addClickEventListener(BindTool.Bind(self.OnClickGroupAttactHp, self))

	-- if 3 == prof then
	-- 	self.node_t_list.lbl_guaji_group.node:setVisible(false)
	-- 	self.node_t_list.btn_select_group.node:setVisible(false)
	-- end
end

function SettingView:FightingDelete()
	-- body
end

function SettingView:RefreshCheckBoxGuaJi2()
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SETTING)
	if data ~= nil then
		self.guaji_set_flag = bit:d2b(data)
		for i = self.GJ_OPTION_COUNT + 1, self.GJ_OPTION_COUNT2 do
			self.node_t_list["layout_gj_option"..i].img_setting_hook1.node:setVisible(1 == self.guaji_set_flag[33 - i])
		end
	end
	self.node_t_list.btn_select_single.node:setTitleText(self.single_skill_data[self.single_select + 1])
	self.node_t_list.btn_select_group.node:setTitleText(self.group_skill_data[self.group_select + 1])

	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for i,v in ipairs(SettingData.SkillOption[prof]) do
		local client_index = SkillData.Instance:GetSkillClientIndex(v)
		if client_index then
			self.node_t_list["layout_gj_option_" .. prof .. "_" .. i].img_setting_hook1.node:setVisible(SettingCtrl.Instance:GetAutoSkillSetting(client_index))
		end
	end

	-- local nu_skill = SPECIAL_SKILL_LIST[prof] or 31
	-- local client_index = SkillData.Instance:GetSkillClientIndex(nu_skill)
	-- if client_index then
	-- 	self.node_t_list["layout_gj_option_bisha"].img_setting_hook1.node:setVisible(SettingCtrl.Instance:GetAutoSkillSetting(client_index))
	-- end
	-- self.node_t_list["layout_gj_option_bisha"].node:setVisible(false)
end

function SettingView:FightingOnFlush(param_t, index)
	self:RefreshCheckBoxGuaJi2()
end

function SettingView:OnClickSingleAttactHp()
	self.select_setting_view:SetDataAndOpen(self.single_skill_data, function (index)
		if self:CheckSkillIsLimitUseByIdAndPlayTip(1, index) then return end
		self.single_select = index
		self.node_t_list.btn_select_single.node:setTitleText(self.single_skill_data[self.single_select + 1])
	end)
end

function SettingView:OnClickGroupAttactHp()
	self.select_setting_view:SetDataAndOpen(self.group_skill_data, function (index)
		if self:CheckSkillIsLimitUseByIdAndPlayTip(2, index) then return end
		self.group_select = index
		self.node_t_list.btn_select_group.node:setTitleText(self.group_skill_data[self.group_select + 1])
	end)
end

function SettingView:CheckSkillIsLimitUseByIdAndPlayTip(tag, index)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local data = SkillData.Instance:GetSkill(SettingData.SKILL[prof][tag][index + 1])
	if nil == data then
		SysMsgCtrl.Instance:ErrorRemind(Language.LimitTip.Tip3)
		return true
	end
	return false
end

function SettingView:OnClickGuijiSkillSetting(index, skill_id)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local img_hook =  self.node_t_list["layout_gj_option_" .. prof .. "_" .. index].img_setting_hook1.node

	local vis = img_hook:isVisible()
	img_hook:setVisible(not vis)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local client_index = SkillData.Instance:GetSkillClientIndex(skill_id)
	if client_index > 0 then
		SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = not vis})
	end
end

-- function SettingView:OnClickDisplayNirvana()
-- 	local img_hook =  self.node_t_list["layout_gj_option_bisha"].img_setting_hook1.node

-- 	local vis = img_hook:isVisible()
-- 	img_hook:setVisible(not vis)
-- 	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
-- 	local nu_skill = SPECIAL_SKILL_LIST[prof] or 31
-- 	local client_index = SkillData.Instance:GetSkillClientIndex(nu_skill)
-- 	if client_index > 0 then
-- 		SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = not vis})
-- 	end
-- end
