--角色属性itemrender
HeroAttrItem = HeroAttrItem or BaseClass(BaseRender)
function HeroAttrItem:__init()

end

function HeroAttrItem:__delete()
	if self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end

function HeroAttrItem:OnFlush()
	if self.data == nil then return end
	-- local hero_vo = ZhanjiangData.Instance:GetHeroVoData()
	-- if hero_vo == nil then return end
	local attr_value = 0
	local attr_v1, attr_v2 = 0, 0
	if self.data == "damage_reduction" then
		attr_value = ZhanjiangData.Instance:GetAttr(self.data)
		self.node_tree.lbl_attr_name.node:setString(Language.Zhanjiang.SpecialAttrName[self.data])
	elseif type(self.data) == "table" then
		if self.data[1] == OBJ_ATTR.CREATURE_LUCK or self.data[1] == OBJ_ATTR.CREATURE_CURSE then
			-- attr_v1, attr_v2 = RoleData.Instance:GetAttr(self.data[1]) or 0, RoleData.Instance:GetAttr(self.data[2]) or 0
			-- if attr_v1 >= attr_v2 then
			-- 	self.node_tree.lbl_attr_name.node:setString(Language.Role.AttrNameList[self.data[1]])
			-- else	
			-- 	self.node_tree.lbl_attr_name.node:setString(Language.Role.AttrNameList[self.data[2]]) 
			-- end	
			-- attr_value = math.abs(attr_v1 - attr_v2)
		else	
			self.node_tree.lbl_attr_name.node:setString(Language.Role.AttrNameList[self.data[1]])
			attr_v1, attr_v2 = ZhanjiangData.Instance:GetAttr(self.data[1]) or 0, ZhanjiangData.Instance:GetAttr(self.data[2]) or 0
			if self.data[1] == OBJ_ATTR.CREATURE_HP or self.data[1] == OBJ_ATTR.CREATURE_MP or self.data[1] == OBJ_ATTR.ACTOR_INNER then
				attr_value = attr_v1 .. "/" .. attr_v2
				if nil == self.pro_bar then
					local size= self.node_tree.img9_bg2.node:getContentSize()
					local bg = nil
					if self.data[1] == OBJ_ATTR.CREATURE_HP then
						bg = ResPath.GetRole("hp_loading")
					elseif self.data[1] == OBJ_ATTR.CREATURE_MP then
						bg = ResPath.GetRole("mp_loading")
					else
						bg = ResPath.GetRole("ng_loading")
					end
					self.pro_bar = XUI.CreateLoadingBar(size.width / 2, size.height / 2, bg, true, nil, true, 324, 22)
					self.node_tree.img9_bg2.node:addChild(self.pro_bar)			
				end
				self.pro_bar:setPercent(attr_v1 / attr_v2 * 100)
			else
				attr_value = attr_v1 .. "-" .. attr_v2
			end 
		end
	else
		self.node_tree.lbl_attr_name.node:setString(Language.Role.AttrNameList[self.data])
		attr_value = ZhanjiangData.Instance:GetAttr(self.data) or 0
		if self.data == OBJ_ATTR.ACTOR_DIERRFRESHCD then
			if attr_value == 0 then
				attr_value = TimeUtil.FormatSecond(0, 3)
			elseif attr_value > TimeCtrl.Instance:GetServerTime() then
				local cd_time = attr_value - TimeCtrl.Instance:GetServerTime()
				if self.cd_timer then
					GlobalTimerQuest:CancelQuest(self.cd_timer)
  					self.cd_timer = nil
				end
				self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.UpdateBtnCd, self), 1, cd_time)
				attr_value = TimeUtil.FormatSecond(cd_time, 3)
			else
				attr_value = TimeUtil.FormatSecond(0, 3)
			end
		elseif self.data == OBJ_ATTR.ACTOR_CRITRATE 
				or self.data == OBJ_ATTR.ACTOR_RESISTANCECRITRATE 
				or self.data == OBJ_ATTR.ACTOR_BOSSCRITRATE then
				attr_value = string.format("%.2f", attr_value / 100) .. "%"
		elseif self.data == OBJ_ATTR.CREATURE_HP_RENEW or
			self.data == OBJ_ATTR.CREATURE_MP_RENEW then
			attr_value = string.format(Language.Role.RevivalTxt, 20) .. string.format("%.2f", attr_value) .. "%"
		end
	end
	local show_pro_bar = type(self.data) == "table" and (self.data[1] == OBJ_ATTR.CREATURE_HP or self.data[1] == OBJ_ATTR.CREATURE_MP or self.data[1] == OBJ_ATTR.ACTOR_INNER)
	if self.pro_bar then
		self.pro_bar:setVisible(show_pro_bar)
	end

	self.node_tree.img9_bg1.node:setVisible(not show_pro_bar)
	self.node_tree.img9_bg2.node:setVisible(show_pro_bar)

	self.node_tree.lbl_attr_value.node:setString(attr_value)
end

function HeroAttrItem:UpdateBtnCd()
	local attr_value = ZhanjiangData.Instance:GetAttr(self.data) or 0
	if attr_value - TimeCtrl.Instance:GetServerTime() > 0 then
		local show_str = TimeUtil.FormatSecond(attr_value - TimeCtrl.Instance:GetServerTime(), 3)
		self.node_tree.lbl_attr_value.node:setString(show_str)
	else
		self.node_tree.lbl_attr_value.node:setString(TimeUtil.FormatSecond(0, 3))
	end
end

function HeroAttrItem:CreateSelectEffect()
	-- body
end

----------------------------------------------------------------------------------------------------
-- 技能item
----------------------------------------------------------------------------------------------------
HeroSkillListRender = HeroSkillListRender or BaseClass(BaseRender)
function HeroSkillListRender:__init()
	self.switch_bar = nil
end

function HeroSkillListRender:__delete()
	if self.switch_bar then
		self.switch_bar:DeleteMe()
		self.switch_bar = nil
	end	
end

function HeroSkillListRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
    	self.cache_select = false
    	self:CreateSelectEffect()
    end
end

function HeroSkillListRender:OnFlush()
	if nil == self.data then return end
	local skill_info = SkillData.GetSkillCfg(self.data.skill_id)
	self.node_tree.lbl_shuliandu.node:setString("")
	if skill_info then
		self.node_tree.lbl_skill_name.node:setString(skill_info.name)
		self.node_tree.img_cur_skill.node:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.skill_id)))
		local show_auto_use = not skill_info.canNotSettle

		if show_auto_use then
			if not self.switch_bar then
				local ph = self.ph_list.ph_switchBar
				self.switch_bar = SwitchBar.New()
				self.switch_bar:SetPosition(ph.x,ph.y)
				self.switch_bar:SetCallback(BindTool.Bind(self.SwitchCallBack, self))
				self.view:addChild(self.switch_bar:GetView(),99)
			end
			self.node_tree.autoText.node:setVisible(true)
		else
		 	self.node_tree.autoText.node:setVisible(false)	
		end	

		-- local client_index = SkillData.Instance:GetSkillClientIndex(self.data.id)
		local is_auto = self.data.auto_state == 0 			 -- SettingCtrl.Instance:GetAutoSkillSetting(client_index)
		--print(self.data.id,is_auto)
		 if self.switch_bar then
		 	self.switch_bar:SetIsOn(is_auto)
	     end
		
		local add_level = ZhanjiangData.Instance:GetAddSkillLevelBySkillID(self.data.skill_id)
		local cur_level = self.data.skill_lv
		local skill_cur_lv_cfg = SkillData.GetSkillLvCfg(self.data.skill_id, cur_level)
		self.node_tree.img_cur_skill.node:setGrey(skill_cur_lv_cfg == nil)

		local level_string 	= "Lv." .. cur_level
		if add_level > 0 then
			level_string = level_string .. string.format("{wordcolor;00ff00;+%d}",add_level)
		end	
		 
		RichTextUtil.ParseRichText(self.node_tree.lbl_skill_lv.node,level_string)
		local up_cond = Language.Zhanjiang.SkillUpTopTxt
		local skill_n_lv_cfg = SkillData.GetSkillLvCfg(self.data.skill_id, cur_level + 1)
		if cur_level == 0 then
			local fuwen_lv_cond = 0
			for k,v in pairs(skill_n_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.FUWEN_LV then
					fuwen_lv_cond = v.value
				end
			end
			local step, star = ZhanjiangData.GetFuWenStepStar(fuwen_lv_cond)
			up_cond = string.format(Language.Zhanjiang.SkillUpCondTxt, step, star)
			self.node_tree.lbl_shuliandu.node:setString(up_cond)
		end
		-- if skill_n_lv_cfg then
		-- 	local fuwen_lv_cond = 0
		-- 	for k,v in pairs(skill_n_lv_cfg.trainConds) do
		-- 		if v.cond == SkillData.SKILL_CONDITION.FUWEN_LV then
		-- 			fuwen_lv_cond = v.value
		-- 		end
		-- 	end
		-- 	local step, star = ZhanjiangData.GetFuWenStepStar(fuwen_lv_cond)
		-- 	up_cond = string.format(Language.Zhanjiang.SkillUpCondTxt, step, star)
		-- 	self.node_tree.lbl_shuliandu.node:setString(up_cond)
		-- else
		-- 	self.node_tree.lbl_shuliandu.node:setString(Language.Zhanjiang.SkillUpTopTxt)
		-- end
	else
		-- local level_string = "Lv." .. 0
		-- RichTextUtil.ParseRichText(self.node_tree.lbl_skill_lv.node,level_string)
		-- self.node_tree.lbl_shuliandu.node:setString(Language.Zhanjiang.SkillUpTopTxt)
	end
end

function HeroSkillListRender:SwitchCallBack()
	local hero_vo = ZhanjiangData.Instance:GetHeroVoData()
	if self.data == nil or hero_vo == nil or next(hero_vo) == nil then return end
	--print(self.switch_bar:GetIsOn())
	local hero_id = hero_vo.hero_id
	local auto_state = self.switch_bar:GetIsOn() and 0 or 1
	ZhanjiangCtrl.Instance:HeroSkillAutoUseSet(hero_id, self.data.skill_id, auto_state)
	-- local client_index = SkillData.Instance:GetSkillClientIndex(self.data.skill_id)
	-- if client_index > 0 then
		-- SkillData.Instance:SetSkillAuto(self.data.id,self.switch_bar:GetIsOn(),true)
	-- end
end

-- 创建选中特效
function HeroSkillListRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("bg_113"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end


----------------------------------------------------------------------------------------------------
-- 符文等级附加属性item
----------------------------------------------------------------------------------------------------
HeroFuWenAttrRender = HeroFuWenAttrRender or BaseClass(BaseRender)
function HeroFuWenAttrRender:__init()

end

function HeroFuWenAttrRender:__delete()
	
end

function HeroFuWenAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
    	self.cache_select = false
    	self:CreateSelectEffect()
    end
	-- self.node_tree.rich_attr_str.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function HeroFuWenAttrRender:OnFlush()
	if nil == self.data then return end
	-- local content = string.format(Language.Zhanjiang.AddAttrStr, self.data.type_str or "", self.data.value_str or "")
	self.node_tree.txt_attr_name.node:setString(self.data.type_str and self.data.type_str .. "：" or "")
	self.node_tree.txt_attr_value.node:setString(self.data.value_str or "")
	-- RichTextUtil.ParseRichText(self.node_tree.rich_attr_str.node, content, 22)
	-- self.node_tree.txt_attr_name.node:setString(self.data.type_str and self.data.type_str .. "：" or "")
	-- self.node_tree.txt_attr_value.node:setString(self.data.value_str or "")
	
end

-- 创建选中特效
function HeroFuWenAttrRender:CreateSelectEffect()

end