-----------------------------------------
-- 技能学习itemRender
-----------------------------------------
SkillLearnItemRender = SkillLearnItemRender or BaseClass(BaseRender)
function SkillLearnItemRender:__init()

end

function SkillLearnItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.img_skill_unopen = self.node_tree.img_skill_unopen.node
	self.img_skill_icon_normal = self.node_tree.img_skill_icon_normal.node

	self.skill_icon = XImage:create(ResPath.GetSkillIcon("skill_light"), XUI.IS_PLIST)
	self.skill_icon:setPosition(self.ph_list.ph_skill_icon.x, math.abs(self.ph_list.ph_skill_icon.y))
	self.view:addChild(self.skill_icon, 200)

	self.skill_icon_mask = XImage:create(ResPath.GetSkillIcon("skill_light"), XUI.IS_PLIST)
	self.skill_icon_mask:setPosition(self.ph_list.ph_skill_icon.x, math.abs(self.ph_list.ph_skill_icon.y + 1))
	self.view:addChild(self.skill_icon_mask, 200)

	self.lbl_skill_unopen = self.node_tree.lbl_skill_unopen.node
	self.lbl_skill_name = self.node_tree.lbl_skill_name.node
	
	self.status = 0

	self.img_skill_up = XImage:create(ResPath.GetSkillIcon("skill_up"), XUI.IS_PLIST)
	self.img_skill_up:setPosition(60, 20)
	self.skill_icon:addChild(self.img_skill_up, 100)
	self.view:addClickEventListener(BindTool.Bind1(self.OnClick, self))

	self.learn_effect = AnimateSprite:create()
	self.view:addChild(self.learn_effect, 300)
	local path, name = ResPath.GetEffectAnimPath(3117)
	self.learn_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)
	local param = self.ph_list.ph_skill_icon
	self.learn_effect:setPosition(param.x + 2.5, param.y)
end
function SkillLearnItemRender:OnFlush()
	if self.data == nil then 
		self.view:setTouchEnabled(false)
		return 
	end
	self.view:setTouchEnabled(self.data.skill_id ~= 0)
	local can_learn = false
	if self.data.skill_id == 0 then					--未开放的技能
		self.learn_effect:setVisible(false)
		self.skill_icon:setVisible(false)
		self.lbl_skill_name:setVisible(false)
		if IS_AUDIT_VERSION then
			self.img_skill_unopen:setVisible(false)
			self.lbl_skill_unopen:setVisible(false)
			self.img_skill_icon_normal:setVisible(false)
		else
			self.img_skill_unopen:setVisible(true)
			self.lbl_skill_unopen:setVisible(true)
			self.img_skill_icon_normal:setVisible(true)
			self.lbl_skill_unopen:setString(Language.Role.ToExpect)
			self.lbl_skill_unopen:setColor(COLOR3B.RED)
		end
	else
		self.skill_icon:setVisible(true)
		self.lbl_skill_name:setVisible(true)
		self.img_skill_unopen:setVisible(false)
		self.img_skill_icon_normal:setVisible(true)

		--图标
		local path = ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.skill_id))
		self.skill_icon:loadTexture(path, XUI.IS_PLIST)
		self.lbl_skill_name:setString(self.data.skill_name)

		local skill_info = SkillData.Instance:GetSkillInfoById(self.data.skill_id)
		local now_level = skill_info ~= nil and skill_info.level or 0
		local next_skillvo = SkillData.Instance:GetSkillConfigByIdLevel(self.data.skill_id, now_level + 1)
		self.lbl_skill_unopen:setString("LV." .. now_level)
		self.lbl_skill_unopen:setColor(COLOR3B.YELLOW)
		--可学习状态
		self.status = SkillData.Instance:GetLearnSkillStatus(self.data.skill_id)
		if self.status < 20000 then							
			if math.mod(self.status, 10000) == 0 then 		--满级
				self.img_skill_up:setVisible(false)
			elseif math.mod(self.status, 10000) == 1 then 	-- 人物等级不足
				self.img_skill_up:setVisible(false)
			elseif math.mod(self.status, 10000) == 10 then 	-- 仙魂不足
				self.img_skill_up:setVisible(false)
			elseif math.mod(self.status, 10000) == 100 then  -- 物品不足
				self.img_skill_up:setVisible(false)
			end
		else
			if math.mod(self.status, 20000) == 0 then 		--可学
				self.img_skill_up:setVisible(true)
				can_learn = true
				CommonAction.ShowJumpAction(self.img_skill_up)
			elseif math.mod(self.status, 20000) == 10 then --可升级
				self.img_skill_up:setVisible(true)
				CommonAction.ShowJumpAction(self.img_skill_up)
			end
		end
		self.learn_effect:setVisible(now_level == 0 and can_learn)
	end
	if self.name ~= "skill" then
		self.img_skill_up:setVisible(false)
		self.learn_effect:setVisible(false)
	end
end

---------------羽翼

RoleWingItemRender = RoleWingItemRender or BaseClass(BaseRender)
function RoleWingItemRender:__init()
	local item_config = RoleCtrl.Instance.role_view.ph_list.ph_hh_item	
	self:SetUiConfig(item_config, true)
end

function RoleWingItemRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.EnableOutline(self.node_tree.lbl_wing_name.node)
end

function RoleWingItemRender:OnFlush()
	if nil == self.data then return end 
	local res_id = math.floor(self.data.res_id / 10)
	local head_path = ResPath.GetRole("head_" .. res_id) 
	self.node_tree.img_wing_head.node:loadTexture(head_path)
	self.node_tree.img_wing_head.node:setScale(1.3)
	self.node_tree.lbl_wing_name.node:setColor(1 == self.data.is_special and COLOR3B.YELLOW
	 or JINJIE_COLOR3B[self.data.big_grade])
	if self.data.is_active then
		self.node_tree.img_wing_head.node:setColor(COLOR3B.WHITE)
		if self.data.is_jinghua then
			self.node_tree.img_stamp2.node:loadTexture(ResPath.GetCommon("stamp_5"))
			self.node_tree.img_stamp2.node:setVisible(true)
		else
			self.node_tree.img_stamp2.node:setVisible(false)
		end
	else
		self.node_tree.img_stamp2.node:loadTexture(ResPath.GetCommon("stamp_6"))
		self.node_tree.img_wing_head.node:setColor(COLOR3B.GRAY)
		self.node_tree.img_stamp2.node:setVisible(true)
	end

	self.node_tree.lbl_wing_name.node:setString(self.data.wing_name)
end

function RoleWingItemRender:OnSelectChange(is_select)
	BaseRender.SetSelect(self, is_select)
	if is_select then
		self.node_tree.img_stamp1.node:loadTexture(ResPath.GetCommon("toggle_116_select"))
	else
		self.node_tree.img_stamp1.node:loadTexture(ResPath.GetCommon("toggle_116_normal"))
	end
end


--法阵itemrender
RoleFaZhenItemRender = RoleFaZhenItemRender or BaseClass(BaseRender)
function RoleFaZhenItemRender:__init()
	local item_config = WingCtrl.Instance.fz_view.ph_list.ph_hh_item	
	self:SetUiConfig(item_config, true)
end

function RoleFaZhenItemRender:OnFlush()
	if nil == self.data then return end 
	local head_path = ResPath.GetRole("fazhen_" .. self.data.res_id)
	self.node_tree.img_wing_head.node:loadTexture(head_path)
	self.node_tree.img_wing_head.node:setScale(1.3)
	self.node_tree.lbl_wing_name.node:setColor(JINJIE_COLOR3B[self.data.show_grade])
	if self.data.is_active == 1 then
		self.node_tree.img_wing_head.node:setColor(COLOR3B.WHITE)
		if self.data.is_seleted then
			self.node_tree.img_stamp2.node:loadTexture(ResPath.GetCommon("stamp_5"))
			self.node_tree.img_stamp2.node:setVisible(true)
		else
			self.node_tree.img_stamp2.node:setVisible(false)
		end
	else
		self.node_tree.img_stamp2.node:loadTexture(ResPath.GetCommon("stamp_6"))
		self.node_tree.img_wing_head.node:setColor(COLOR3B.GRAY)
		self.node_tree.img_stamp2.node:setVisible(true)
	end

	self.node_tree.lbl_wing_name.node:setString(self.data.name)
end

function RoleFaZhenItemRender:OnSelectChange(is_select)
	BaseRender.SetSelect(self, is_select)
	if is_select then
		self.node_tree.img_stamp1.node:loadTexture(ResPath.GetCommon("toggle_116_select"))
	else
		self.node_tree.img_stamp1.node:loadTexture(ResPath.GetCommon("toggle_116_normal"))
	end
end

--角色属性itemrender
RoleAttrItem = RoleAttrItem or BaseClass(BaseRender)
function RoleAttrItem:__init()
	self._view_size = cc.size(366, 24)
	self.view:setContentSize(self._view_size)
	self.lbl_attr_name = XUI.CreateTextByType(124, self._view_size.height / 2, 200, 20, "", 2)
	self.lbl_attr_name:setAnchorPoint(1, 0.5)
	self.view:addChild(self.lbl_attr_name, 10)
	self.lbl_attr_value = XUI.CreateTextByType(128, self._view_size.height / 2, 260, 20, "", 2)
	self.lbl_attr_value:setAnchorPoint(0, 0.5)
	self.lbl_attr_value:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.view:addChild(self.lbl_attr_value, 10)
	self.img9_bg = XUI.CreateImageViewScale9(128, self._view_size.height / 2, 258, 24, ResPath.GetCommon("img9_200"), true, cc.rect(10, 5, 10, 5))
	self.img9_bg:setAnchorPoint(0, 0.5)
	self.view:addChild(self.img9_bg, 1)
end

function RoleAttrItem:__delete()
	if self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end

function RoleAttrItem:OnFlush()
	if self.data == nil then return end
	local attr_value = 0
	local attr_v1, attr_v2 = 0, 0
	if type(self.data) == "table" then
		self.lbl_attr_name:setString(Language.Role.AttrNameList[self.data[1]])
		attr_v1, attr_v2 = RoleData.Instance:GetAttr(self.data[1]) or 0, RoleData.Instance:GetAttr(self.data[2]) or 0
		if self.data[1] == OBJ_ATTR.CREATURE_HP or self.data[1] == OBJ_ATTR.CREATURE_MP or self.data[1] == OBJ_ATTR.ACTOR_INNER then
			attr_value = attr_v1 .. "/" .. attr_v2
			if nil == self.pro_bar then
				local size = self.img9_bg:getContentSize()
				local bg = nil
				if self.data[1] == OBJ_ATTR.CREATURE_HP then
					bg = ResPath.GetCommon("prog_110_progress")
				elseif self.data[1] == OBJ_ATTR.CREATURE_MP then
					bg = ResPath.GetCommon("prog_111_progress")
				else
					bg = ResPath.GetCommon("prog_112_progress")
				end
				self.pro_bar = XUI.CreateLoadingBar(size.width / 2 - 2, size.height / 2 + 2, bg, XUI.IS_PLIST, nil, true, size.width - 12, 19, cc.rect(10, 5, 10, 5))
				self.img9_bg:addChild(self.pro_bar)
			end
			self.pro_bar:setPercent(attr_v1 / attr_v2 * 100)
		else
			attr_value = attr_v1 .. "-" .. attr_v2
		end 
	else
		self.lbl_attr_name:setString(Language.Role.AttrNameList[self.data])
		attr_value = RoleData.Instance:GetAttr(self.data) or 0
		if self.data == OBJ_ATTR.ACTOR_DIERRFRESHCD then
			if attr_value == 0 then
				attr_value = TimeUtil.FormatSecond(0, 3)
			elseif attr_value > TimeCtrl.Instance:GetServerTime() then
				local cd_time = attr_value - TimeCtrl.Instance:GetServerTime()
				if self.cd_timer then
					GlobalTimerQuest:CancelQuest(self.cd_timer)
  					self.cd_timer = nil
				end
				self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(self.UpdateBtnCd, self), 1, cd_time)
				attr_value = TimeUtil.FormatSecond(cd_time, 3)
			else
				attr_value = TimeUtil.FormatSecond(0, 3)
			end
		else
			attr_value = RoleData.FormatObjAttrValueStr(self.data, attr_value)
		end
	end
	local show_pro_bar = type(self.data) == "table" and (self.data[1] == OBJ_ATTR.CREATURE_HP or self.data[1] == OBJ_ATTR.CREATURE_MP or self.data[1] == OBJ_ATTR.ACTOR_INNER)
	if self.pro_bar then
		self.pro_bar:setVisible(show_pro_bar)
	end
	self.img9_bg:loadTexture(show_pro_bar and ResPath.GetCommon("prog_118") or ResPath.GetCommon("img9_200"))
	if show_pro_bar then
		self.img9_bg:setContentWH(258, 28)
	else
		self.img9_bg:setContentWH(258, 24)
	end
	self.lbl_attr_value:setString(attr_value)
end

function RoleAttrItem:UpdateBtnCd()
	local attr_value = RoleData.Instance:GetAttr(self.data) or 0
	if attr_value - TimeCtrl.Instance:GetServerTime() > 0 then
		local show_str = TimeUtil.FormatSecond(attr_value - TimeCtrl.Instance:GetServerTime(), 3)
		self.lbl_attr_value:setString(show_str)
	else
		self.lbl_attr_value:setString(TimeUtil.FormatSecond(0, 3))
	end
end

function RoleAttrItem:CreateSelectEffect()
end


--羽翼属性itemrender
WingShowItemRender = WingShowItemRender or BaseClass(BaseRender)
function WingShowItemRender:__init()
	 self:SetContentSize(200, 135)
	 XUI.AddClickEventListener(self.view, BindTool.Bind1(self.OnClick, self))
	 local bottom_line = XUI.CreateImageView(100, 0, ResPath.GetCommon("line_103"))
	 bottom_line:setScaleX(0.5)
	 self.view:addChild(bottom_line, 1, 1)
end

function WingShowItemRender:OnFlush()
	if self.data == nil then
		return 
	end
	local role_prof = RoleData.Instance:GetRoleBaseProf()
	local head_path = ResPath.GetRole("head_" .. math.floor(self.data.res_id / 10))
	if nil == self.wing_img then
		self.wing_img = XUI.CreateImageView(100, 70, head_path)
		self.view:addChild(self.wing_img, 99, 99)
	else
		self.wing_img:loadTexture(head_path)
	end
	local config = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[WingData.Instance:GetJinHua()]
	self.wing_img:setGrey(nil == config or self.data.big_grade > config.big_grade)
end


--法阵属性itemrender
FzShowItemRender = FzShowItemRender or BaseClass(BaseRender)
function FzShowItemRender:__init()
	 self:SetContentSize(200, 135)
	 XUI.AddClickEventListener(self.view, BindTool.Bind1(self.OnClick, self))
	 local bottom_line = XUI.CreateImageView(100, 0, ResPath.GetCommon("line_103"))
	 bottom_line:setScaleX(0.5)
	 self.view:addChild(bottom_line, 1, 1)
end

function FzShowItemRender:OnFlush()
	if self.data == nil then
		return 
	end
	local role_prof = RoleData.Instance:GetRoleBaseProf()
	local head_path = ResPath.GetRole("fazhen_" .. self.data.res_id)
	if nil == self.fz_img then
		self.fz_img = XUI.CreateImageView(100, 70, head_path)
		self.view:addChild(self.fz_img, 99, 99)
	else
		self.fz_img:loadTexture(head_path)
	end
	local fazhen_data = WingData.Instance:GetFaZhenData()
	self.fz_img:setGrey(nil == fazhen_data or self.data.grade > fazhen_data.grade)
end

