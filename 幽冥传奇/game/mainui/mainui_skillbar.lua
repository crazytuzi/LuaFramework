----------------------------------------------------------
-- 主ui上的技能操作区
----------------------------------------------------------
MainuiSkillBar = MainuiSkillBar or BaseClass()
MainuiSkillBar.ANGLE_INTERVAL = 36
MainuiSkillBar.CELL_COUNT = 8

function MainuiSkillBar:__init()
	self.mt_layout_skill = nil
	
	self.common_cell = nil
	self.cell_list = {}
		
	self.normal_angle = 0
	self.angle = 0
	self.min_angle = -(MainuiSkillBar.CELL_COUNT - 2) * MainuiSkillBar.ANGLE_INTERVAL
	self.max_angle = 0
	self.radius = 150
	self.begin_angle = 90
	
	self.select_obj_group_list = {}

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	GlobalEventSystem:Bind(OtherEventType.INIT_SKILL_LIST, BindTool.Bind(self.OnInitSkillList, self))
	GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind(self.OnMainRoleUseSkill, self))
	GlobalEventSystem:Bind(SettingEventType.SKILL_BAR_CHANGE, BindTool.Bind(self.OnSkillBarChange, self))
	GlobalEventSystem:Bind(OtherEventType.AREA_SKILL_ID_CHANGE, BindTool.Bind(self.OnAreaSkillIdChange, self))
	GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_ITEM_USE, BindTool.Bind(self.OnUseItemSuc, self))
	-- GlobalEventSystem:Bind(ObjectEventType.MAX_ANGER_VAL_CHANGE, BindTool.Bind(self.OnMaxAngerValChange, self))
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnItemChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_ANGER, BindTool.Bind(self.OnActorAngerChange, self))

	EventProxy.New(SkillData.Instance, self):AddEventListener(SkillData.SKILL_DATA_CHANGE, function ()
		self.cell_list[MainuiSkillBar.CELL_COUNT + 1]:SetCellGrey(nil == SkillData.Instance:GetSkill(122))
		self.cell_list[MainuiSkillBar.CELL_COUNT + 1]:SetData{type = SKILL_BAR_TYPE.SKILL, id = 122}

		-- 优先显示124
		local second_skill_data = SkillData.Instance:GetSkill(124) or SkillData.Instance:GetSkill(123)
		local id = nil ~= SkillData.Instance:GetSkill(124) and 124 or 123
		self.cell_list[MainuiSkillBar.CELL_COUNT + 2]:SetCellGrey(nil == second_skill_data)
		self.cell_list[MainuiSkillBar.CELL_COUNT + 2]:SetData{type = SKILL_BAR_TYPE.SKILL, id = id}
		self:FlushSkillCd()
	end)
	GlobalEventSystem:Bind(TIYAN_SHEN_BIn_EVENT.TIYAN_SKILL_TiME, BindTool.Bind(self.SetBtnShowTime, self))

	-- 场景切换
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, function ()
		self.cell_list[MainuiSkillBar.CELL_COUNT + 1]:FlushUseSkillTip()
		self.cell_list[MainuiSkillBar.CELL_COUNT + 2]:FlushUseSkillTip()
	end)
end

function MainuiSkillBar:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	
	if nil ~= self.common_cell then
		self.common_cell:DeleteMe()
		self.common_cell = nil
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest) -- 取消计时器任务
		self.timer_quest = nil
	end

	GlobalEventSystem:UnBind(self.scene_change)
	self.scene_change = nil
end

function MainuiSkillBar:OnActorAngerChange()
	if self.spec_skill then
		self.spec_skill:FlushState()
	end
end

function MainuiSkillBar:Update(now_time, elapse_time)
	if self.normal_angle and self.normal_angle ~= self.angle then
		local minus_or_plus = math.abs(self.normal_angle - self.angle) / (self.normal_angle - self.angle)
		local is_over = self.angle > self.max_angle or self.angle < self.min_angle
		local change_angle = is_over and 4 or 1.8
		self.angle = self.angle + minus_or_plus * change_angle
		if (minus_or_plus == 1 and self.angle >= self.normal_angle) or (minus_or_plus == -1 and self.angle <= self.normal_angle) then
			self.angle = self.normal_angle
			self.normal_angle = nil
			Runner.Instance:RemoveRunObj(self)
		end
		self:UpdatePos()
	end
end

function MainuiSkillBar:OnRecvMainRoleInfo()
	if nil ~= self.common_cell then
		self.common_cell:FlushIcon()
	end
end

--      90°
--       |
-- 180°-----0°
--       |
--      270°
local c_x = - 82
local c_y = 95
function MainuiSkillBar:CalcPosByAngle(angle)
	local x = c_x + self.radius * math.cos(math.rad(angle))
	local y = c_y + self.radius * math.sin(math.rad(angle))
	return math.floor(x * 100) / 100, math.floor(y * 100) / 100
end

function MainuiSkillBar:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root
	local size = self.mt_layout_root:getContentSize()
	self.mt_layout_skill = MainuiMultiLayout.CreateMultiLayout(size.width, 0, cc.p(1, 0), cc.size(0, 0), mt_layout_root, 10)

	self.common_cell = MainuiSkillCommonItem.New(self.mt_layout_skill)
	self.common_cell:GetMtView():setPosition(- 90, 100)
	self.common_cell:GetMtView():TextureLayout():setTouchEnabled(true)
	self.common_cell:GetMtView():TextureLayout():addTouchEventListener(BindTool.Bind(self.OnTouchCommonCell, self))

	self.mt_layout_skill:TextureLayout():addChild(XUI.CreateImageView(-110, 180, ResPath.GetSkillIcon("skill_arrow_up")))
	self.mt_layout_skill:TextureLayout():addChild(XUI.CreateImageView(-155, 70, ResPath.GetSkillIcon("skill_arrow_down")))



	local cell
	for i = 1, MainuiSkillBar.CELL_COUNT do
		cell = MainuiSkillItem.New(self.mt_layout_skill, i)
		cell:SetAngle(self.begin_angle + MainuiSkillBar.ANGLE_INTERVAL *(i - 1))
		cell:GetMtView():TextureLayout():setTouchEnabled(true)
		cell:GetMtView():TextureLayout():addTouchEventListener(BindTool.Bind(self.OnTouchSkillCell, self, cell))
		self.cell_list[i] = cell
	end
	self:UpdatePos()

	local skill_122_item = MainuiSkillItem.New(self.mt_layout_skill, MainuiSkillBar.CELL_COUNT + 1)
	skill_122_item:GetMtView():TextureLayout():setTouchEnabled(true)
	skill_122_item:GetMtView():TextureLayout():addTouchEventListener(BindTool.Bind(self.OnTouchRexueSpecialSkill, self, skill_122_item))
	skill_122_item:GetMtView():setPosition(- 260, 230)
	skill_122_item:SetData{type = SKILL_BAR_TYPE.SKILL, id = 122}
	self.cell_list[MainuiSkillBar.CELL_COUNT + 1] = skill_122_item
	
	local skill_123_item = MainuiSkillItem.New(self.mt_layout_skill, MainuiSkillBar.CELL_COUNT + 2)
	skill_123_item:GetMtView():TextureLayout():setTouchEnabled(true)
	skill_123_item:GetMtView():TextureLayout():addTouchEventListener(BindTool.Bind(self.OnTouchRexueSpecialSkill, self, skill_123_item))
	skill_123_item:GetMtView():setPosition(- 180, 300)

	local s_id = nil ~= SkillData.Instance:GetSkill(124) and 124 or 123
	skill_123_item:SetData{type = SKILL_BAR_TYPE.SKILL, id = s_id}
	self.cell_list[MainuiSkillBar.CELL_COUNT + 2] = skill_123_item

	self.cell_list[MainuiSkillBar.CELL_COUNT + 1]:SetCellGrey( nil == SkillData.Instance:GetSkill(122))
	self.cell_list[MainuiSkillBar.CELL_COUNT + 2]:SetCellGrey(nil == SkillData.Instance:GetSkill(123))

	-- self.spec_skill = MainuiSpecialSkill.New(self.mt_layout_skill)
	-- self.spec_skill:GetMtView():setPosition(- 261, 230)
	-- self.spec_skill:GetMtView():TextureLayout():setTouchEnabled(true)
	-- self.spec_skill:GetMtView():TextureLayout():addTouchEventListener(BindTool.Bind(self.OnTouchSpecialSkill, self))

end


function MainuiSkillBar:SetBtnShowTime(data)
	if data == nil then
		return
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest) -- 取消计时器任务
		self.timer_quest = nil
	end

	self.timer_quest = GlobalTimerQuest:AddRunQuest(function ( ... )
			local time = data.use_time  - TimeCtrl.Instance:GetServerTime()
			if time <= 0 then
				if self.timer_quest then
					GlobalTimerQuest:CancelQuest(self.timer_quest) -- 取消计时器任务
					self.timer_quest = nil
				end
				if self.cell_list[MainuiSkillBar.CELL_COUNT + 2] then
					local cell = self.cell_list[MainuiSkillBar.CELL_COUNT + 2]
					cell:SetTextShow("")
				end
				return
			end
			local text = string.format("体验时间: {wordcolor;00ff00;%s}", TimeUtil.FormatSecond(time, 2))
			if self.cell_list[MainuiSkillBar.CELL_COUNT + 2] then
				local cell = self.cell_list[MainuiSkillBar.CELL_COUNT + 2]
				cell:SetTextShow(text)
			end
	end, 1)
end

function MainuiSkillBar:UpdatePos()
	local angle = 0
	for i = 1, MainuiSkillBar.CELL_COUNT do
		angle = GameMath.NormalizeAngle(self.angle + self.cell_list[i]:GetAngle())
		self.cell_list[i]:GetMtView():setPosition(self:CalcPosByAngle(angle))
		self.cell_list[i]:GetMtView():setVisible(angle > 0 and angle <= 240)
	end
end

local math_360_angle = function(y, x)
	local an = math.deg(math.atan2(y, x))
	return y >= 0 and an or (360 + an)
end


function MainuiSkillBar:OnTouchRexueSpecialSkill(cell, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		 local data = cell:GetData()
		 if nil == SkillData.Instance:GetSkill(data.id) then
	 		local skill_id = 0
			local skiill_level = 0
			local suit_type = 0
			local suitlevel = 0
			if data.id == 123  then
				skill_id = SuitPlusConfig[10].list[1].skillid
				skill_level =  0
				suit_type = 10
				suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
				if suitlevel > 0 then
					skill_id = SuitPlusConfig[10].list[suitlevel].skillid
					skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
					
				end
			elseif data.id == 122 then
				skill_id = SuitPlusConfig[11].list[1].skillid
				skill_level =  0
				suit_type = 11
				suitlevel = EquipData.Instance:GetBazheLevel()
				if suitlevel > 0 then
					skill_id = SuitPlusConfig[11].list[suitlevel].skillid
					skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
				end
			end
			TipCtrl.Instance:OpenTipSkill(skill_id, skill_level, suit_type, suitlevel)

		 	return
		 end

		 GlobalEventSystem:Fire(OtherEventType.USER_TOUCH_SKILL_ICON, 2, data.id) --单点触摸
		GuajiCtrl.Instance:ClearAtkOperate()
		self:OnUseSkill(data.id)
	end
end

function MainuiSkillBar:OnTouchSkillCell(cell, sender, event_type, touch)
	local data = cell:GetData()
	if event_type == XuiTouchEventType.Began then
		if nil == self.touch_id then
			self.touch_id = touch:getId()
			self.touch_began_point = touch:getLocation()
			self.began_x, self.began_y = cell:GetMtView():getPosition()
			self.began_angle = self.angle
			self.is_touch_moved = false
			
			cell:GetMtView():setScale(1.1)

			if data and data.type == SKILL_BAR_TYPE.SKILL then
				GlobalEventSystem:Fire(OtherEventType.USER_TOUCH_SKILL_ICON, 1, data.id)
			end
		end
		return
	end
	
	if self.touch_id ~= touch:getId() then
		if data and data.type == SKILL_BAR_TYPE.SKILL then
			GlobalEventSystem:Fire(OtherEventType.USER_TOUCH_SKILL_ICON, 2, data.id)
		end
		return
	end
	
	if event_type == XuiTouchEventType.Moved then
		local location = touch:getLocation()
		local old_angle = math_360_angle(self.began_y, self.began_x)
		local new_angle = math_360_angle(self.began_y + (location.y - self.touch_began_point.y),
		self.began_x + (location.x - self.touch_began_point.x))
		
		local change_angle = new_angle - old_angle
		local angle = change_angle + self.began_angle

		local over_max = angle - self.max_angle
		local over_min = angle - self.min_angle
		local angle_delta = angle - self.angle

		if over_max > 0 and angle_delta > 0 then
			angle = math.min(self.angle + angle_delta / (over_max * 1.2), self.max_angle + 20)
		elseif over_min < 0 and angle_delta < 0 then
			angle = math.max(self.angle + angle_delta / ((-over_min) * 1.2), self.min_angle - 20)
		end

		self.angle = angle

		-- 移动3度就不触发点击事件
		if not self.is_touch_moved and math.abs(self.angle - self.began_angle) >= 3 then
			cell:GetMtView():setScale(1)
			self.is_touch_moved = true
			if data and data.type == SKILL_BAR_TYPE.SKILL then
				GlobalEventSystem:Fire(OtherEventType.USER_TOUCH_SKILL_ICON, 2, data.id)
			end
		end
		self:UpdatePos()
		
	elseif event_type == XuiTouchEventType.Ended then
		if data and data.type == SKILL_BAR_TYPE.SKILL then
			GlobalEventSystem:Fire(OtherEventType.USER_TOUCH_SKILL_ICON, 2, data.id)
		end
		self.touch_id = nil
		if not self.is_touch_moved then
			self:OnClickSkillCell(cell)
		end
	else
		self.touch_id = nil
		if data and data.type == SKILL_BAR_TYPE.SKILL then
			GlobalEventSystem:Fire(OtherEventType.USER_TOUCH_SKILL_ICON, 2, data.id)
		end
	end
	
	if nil == self.touch_id then
		cell:GetMtView():setScale(1)
		self:AutoNormalSkillAngle()
	end
end

-- 自动标准化技能角度
function MainuiSkillBar:AutoNormalSkillAngle()
	local normal_angle = self.angle
	local angle_mod = self.angle % MainuiSkillBar.ANGLE_INTERVAL
	if angle_mod > MainuiSkillBar.ANGLE_INTERVAL / 2 then
		normal_angle = normal_angle + MainuiSkillBar.ANGLE_INTERVAL - angle_mod
	else
		normal_angle = normal_angle - angle_mod
	end

	if normal_angle > self.max_angle then
		normal_angle = self.max_angle
	elseif normal_angle < self.min_angle then
		normal_angle = self.min_angle
	end

	self.normal_angle = normal_angle

	if self.normal_angle ~= self.angle then
		Runner.Instance:AddRunObj(self)
	end
end

function MainuiSkillBar:OnTouchSpecialSkill(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		if self:OnUseSkill(SkillData.Instance:GetMainRoleSpecSkillId()) then
			ActivityCtrl.StopAutoEscort()
		end
	end
end

function MainuiSkillBar:OnTouchCommonCell(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		if nil == self.touch_id then
			self.touch_id = touch:getId()
			self.touch_began_point = touch:getLocation()
			self.is_touch_moved = false
			self.common_cell:PlayInsideEffect()
		end
		return
	end
	
	if self.touch_id ~= touch:getId() then
		return
	end
	
	local location = touch:getLocation()
	
	if event_type == XuiTouchEventType.Moved then
		if not self.is_touch_moved and math.abs(location.y - self.touch_began_point.y) >= 40 then
			self.is_touch_moved = true
		end
	elseif event_type == XuiTouchEventType.Ended then
		self.touch_id = nil
		if not self.is_touch_moved then
			self:OnClickCommonCell()
		end
		self.common_cell:StopInsideEffect()
	else
		self.touch_id = nil
		self.common_cell:StopInsideEffect()
	end
	
	if nil == self.touch_id then
		self.common_cell:GetMtView():setScale(1)
		
		if location.y - self.touch_began_point.y > 40 then
			self:OnClickCommonUp()
		elseif location.y - self.touch_began_point.y < - 40 then
			self:OnClickCommonDown()
		end
	end
end

function MainuiSkillBar:OnClickSkillCell(cell)
	cell:OnClick()
	local data = cell:GetData()
	if nil == data then
		return
	end
	
	if data.type == SKILL_BAR_TYPE.SKILL then
		if self:OnUseSkill(data.id) then
			ActivityCtrl.StopAutoEscort()
		else
			-- MainuiData.Instance:SetAreaSkillId(0)
		end
	elseif data.type == SKILL_BAR_TYPE.ITEM then
		local item = BagData.Instance:GetItem(data.id)
		if nil ~= item then
			BagCtrl.Instance:SendUseItem(item.series)
		end
	end
end

function MainuiSkillBar:OnUseSkill(skill_id)
	local skill = SkillData.Instance:GetSkill(skill_id)
	if nil == skill then return false end
	
	local skill_cfg = SkillData.GetSkillCfg(skill_id)
	if nil == skill_cfg then return false end
	
	if skill_cfg.skillSpellType == SKILL_SPELL_TYPE.AREA then
		if MainuiData.Instance:GetAreaSkillId() == skill_id then
			MainuiData.Instance:SetAreaSkillId(0)
			return false
		end
	end
	
	local can_use, range, str = SkillData.Instance:CanUseSkill(skill_id, true)
	if str then
		SysMsgCtrl.Instance:FloatingTopRightText(str)
	end
	if not can_use then return false end
	
	local x, y, dir = 0, 0, 0
	local target_obj = nil
	if skill_cfg.skillSpellType == SKILL_SPELL_TYPE.AREA then
		if MainuiData.Instance:GetAreaSkillId() ~= skill_id then
			MainuiData.Instance:SetAreaSkillId(skill_id)
			MainuiData.Instance:SetAreaSkillRange(range)
		else
			return false
		end
		return true
	elseif skill_cfg.skillSpellType == SKILL_SPELL_TYPE.SELF or skill_cfg.skillSpellType == SKILL_SPELL_TYPE.NONE then
		x, y = Scene.Instance:GetMainRole():GetLogicPos()
		dir = Scene.Instance:GetMainRole():GetDirNumber()
	else
		target_obj = GuajiCtrl.Instance:SelectAtkTarget(true)
		if nil == target_obj then
			if GuajiCache.target_obj then
				if GuajiCache.target_obj:IsRole() then
					target_obj = GuajiCache.target_obj
				else
					SystemHint.Instance:FloatingTopRightText(Language.Mainui.IsNotAttackTarget)
					return false
				end
			else
				SystemHint.Instance:FloatingTopRightText(Language.Mainui.NotAttackTarget)
				return false
			end
		end
	end
	
	GuajiCtrl.Instance:DoAtkOperate(ATK_SOURCE.PLAYER, skill_id, nil, nil, nil, target_obj)
	return true
end

function MainuiSkillBar:OnClickCommonCell()
	self.common_cell:PlayExteriorEffect()
	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(true)
	if nil ~= target_obj then
		if not self.common_cell:IsInCD() then
			self.common_cell:OnClick()
			self:DoCommonAttack(target_obj)
		end
	else
		if GuajiCache.target_obj then
			if GuajiCache.target_obj:IsRole() then
				self:DoCommonAttack(GuajiCache.target_obj)
			else
				SystemHint.Instance:FloatingTopRightText(Language.Mainui.IsNotAttackTarget)
			end
		else
			SystemHint.Instance:FloatingTopRightText(Language.Mainui.NotAttackTarget)
		end
	end
end

function MainuiSkillBar:DoCommonAttack(target_obj)
	if nil == target_obj then
		return
	end
	local x, y = target_obj:GetLogicPos()
	local dir = GuajiCtrl.Instance:GetMainRoleTargetDir(x, y)
	
	local skill_id, range = 0, 1
	local back_skill_id, back_range = 0, 1
	local can_use, temp_range = false, 1
	
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if prof == GameEnum.ROLE_PROF_1 then
		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(3)		--刺影剑法
			if can_use then
				skill_id, range = 3, temp_range
			end
		end
	elseif prof == GameEnum.ROLE_PROF_2 then
		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(14)		--火墙
			if can_use and 14 == MainuiData.Instance:GetAreaSkillId() then
				skill_id, range = 14, temp_range
			end
		end
		
		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(12)		--大雷电术
			if can_use then
				skill_id, range = 12, temp_range
			end
		end
		
		if 0 == skill_id then
			skill_id, range = back_skill_id, back_range
		end
	else
		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(22)		--天灵火符
			if can_use then
				skill_id, range = 22, temp_range
			end
		end
		
		if 0 == skill_id then
			skill_id, range = back_skill_id, back_range
		end
	end
	if prof == GameEnum.ROLE_PROF_1 or skill_id ~= 0 then
		GuajiCtrl.Instance:DoAtkOperate(ATK_SOURCE.PLAYER, skill_id, nil, nil, nil, target_obj)
	end
end

function MainuiSkillBar:OnMaxAngerValChange()
	if self.spec_skill then
		self.spec_skill:FlushState()
	end
end

function MainuiSkillBar:OnAreaSkillIdChange(skill_id)
	for k, v in pairs(self.cell_list) do
		if v:GetData() then
			local id = v:GetData().id
			if SkillData.IsFirewall(id) then
				v:SetData(v:GetData())
			else
				v:PlayIconEffect(0)
			end
		end
	end
end

function MainuiSkillBar:OnClickCommonUp()
	self.common_cell:PlayUpEffect()
	if nil == self:SelectObj(SceneObjType.Role, SelectType.Alive) then
		Scene.Instance:GetMainRole():PlaySelectAreaEffect(ResPath.GetBigPainting("select_area_yellow", false))
	end
end

function MainuiSkillBar:OnClickCommonDown()
	self.common_cell:PlayDownEffect()
	if nil == self:SelectObj(SceneObjType.Monster, SelectType.Enemy) then
		Scene.Instance:GetMainRole():PlaySelectAreaEffect(ResPath.GetBigPainting("select_area_red", false))
	end
end

function MainuiSkillBar:SelectObj(obj_type, select_type)
	-- 获取所有可选对象
	local obj_list = Scene.Instance:GetObjListByType(obj_type)
	if not next(obj_list) then
		return
	end
	
	local temp_obj_list = {}
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0
	
	local can_select = true
	for k, v in pairs(obj_list) do
		can_select = true
		if SelectType.Friend == select_type then
			can_select = Scene.Instance:IsFriend(v, self.main_role)
		elseif SelectType.Enemy == select_type then
			can_select = Scene.Instance:IsEnemy(v, self.main_role)
		elseif SelectType.Alive == select_type then
			can_select = not v:IsRealDead()
		end
		
		if can_select then
			target_x, target_y = v:GetLogicPos()
			table.insert(temp_obj_list, {obj = v, dis = GameMath.GetDistance(x, y, target_x, target_y, false)})
		end
	end
	if not next(temp_obj_list) then
		return
	end
	table.sort(temp_obj_list, function(a, b) return a.dis < b.dis end)
	
	-- 排除已选过的
	local select_obj_list = self.select_obj_group_list[obj_type]
	if nil == select_obj_list then
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end
	
	local select_obj = nil
	for i, v in ipairs(temp_obj_list) do
		if nil == select_obj_list[v.obj:GetObjId()] then
			select_obj = v.obj
			break
		end
	end
	
	-- 如果没有选中，选第一个，并清空已选列表
	if nil == select_obj then
		select_obj = temp_obj_list[1].obj
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end
	if nil == select_obj then
		return
	end
	select_obj_list[select_obj:GetObjId()] = select_obj
	
	GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, select_obj, "select")
	
	return select_obj
end

function MainuiSkillBar:OnInitSkillList()
	self:FlushSkillCd()
	-- self.spec_skill:FlushState()
end

function MainuiSkillBar:OnMainRoleUseSkill(skill_id)
	SkillData.Instance:OnUseSkill(skill_id)
	self:FlushSkillCd()
end

function MainuiSkillBar:OnUseItemSuc(param)
	for k, v in pairs(self.cell_list) do
		local use_item_config = ItemData.Instance:GetItemConfig(param.item_id)
		if use_item_config then
			if nil ~= v:GetData() and v:GetData().type == SKILL_BAR_TYPE.ITEM then
				local item_config = ItemData.Instance:GetItemConfig(v:GetData().id)
				if item_config and item_config.colGroup == use_item_config.colGroup then
					v:SetCDTime(Status.NowTime + item_config.cdTime / 1000)
				end
			end
		end
	end
end

function MainuiSkillBar:OnSkillBarChange()
	for i = 1, MainuiSkillBar.CELL_COUNT do
		self.cell_list[i]:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. i]))
		self.cell_list[i]:ClearCDTime()
	end

	-- for k, v in pairs(self.cell_list) do
	-- 	v:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. k]))
	-- 	v:ClearCDTime()
	-- end

	self.common_cell:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. 0]))
	self:FlushSkillCd()
	MainuiData.Instance:SetAreaSkillId(0)
end

function MainuiSkillBar:FlushSkillCd()
	self.common_cell:SetCDTime(SkillData.Instance:GetGlobalCD())
	
	for k, v in pairs(self.cell_list) do
		if nil ~= v:GetData() and v:GetData().type == SKILL_BAR_TYPE.SKILL then
			v:SetCDTime(SkillData.Instance:GetSkillCD(v:GetData().id))
		end
	end
end

--背包物品变化监听 改写后 涉及到物品监听的都需检查
function MainuiSkillBar:OnItemChange(event)	
	-- if event.GetChangeDataList()[1].change_type == ITEM_CHANGE_TYPE.LIST then
	-- end
	event.CheckAllItemDataByFunc(function (vo)
		for k, v in pairs(self.cell_list) do
			v:FlushByItemId(vo.data.item_id)
		end
	end)
end

function MainuiSkillBar:OnGetUiNode(node_name)
	local key = string.match(node_name, "^skill_cell(%d)")
	local ret = nil
	if 0 == tonumber(key) then
		ret = self.common_cell
	end
	if ret == nil then
		ret = self.cell_list[tonumber(key)]
	end

	if ret == nil then
		ret = self[node_name]
	end
	return ret
end

function MainuiSkillBar:SetVisible(visible)
	self.mt_layout_skill:setVisible(visible)
end

------------------------------------------------------------------------
MainuiSkillItem = MainuiSkillItem or BaseClass()
MainuiSkillItem.Size = cc.size(80, 80)
function MainuiSkillItem:__init(parent, index)
	self.mt_view = MainuiMultiLayout.New()
	self.mt_view:CreateByMultiLayout(parent)
	self.mt_view:setContentSize(MainuiSkillItem.Size)
	
	self.index = index
	self.angle = 0
	
	self.data = nil
	self.cd_end_time = 0
	self.last_click_time = 0
	
	self:CreateUi()
end

function MainuiSkillItem:__delete()
	self.img_tip = nil
end

function MainuiSkillItem:CreateUi()
	local x, y = MainuiSkillItem.Size.width / 2, MainuiSkillItem.Size.height / 2
	
	-- self.img_skill_bg = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("skill_bg_02"), true)
	-- self.img_skill_bg:setScale(1.0)
	-- self.mt_view:TextureLayout():addChild(self.img_skill_bg, 1)
	
	self.img_skill = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("double_setting"), true)
	self.img_skill:setScale(80 / 120)
	self.mt_view:TextureLayout():addChild(self.img_skill, 100)
	
	self.text_num = XUI.CreateText(x, 12, 60, 20, nil, "", nil, 20)
	self.mt_view:TextLayout():addChild(self.text_num)
	self.text_num:setVisible(false)
	
	local sprite = XUI.CreateSprite(ResPath.GetSkillIcon("skill_mask"))
	self.cd_bar = cc.ProgressTimer:create(sprite)
	self.cd_bar:setType(0)
	self.cd_bar:setPercentage(0)
	self.cd_bar:setReverseDirection(true)
	self.cd_bar:setPosition(x, y)
	self.cd_bar:setVisible(false)
	self.mt_view:TextLayout():addChild(self.cd_bar, 300)
	
	self.img_skill_light = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("skill_light"), true)
	self.mt_view:TextureLayout():addChild(self.img_skill_light, 200)

	self.cd_txt = XUI.CreateText(x, y, 200, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.WHITE)
	self.cd_txt:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	self.mt_view:TextLayout():addChild(self.cd_txt, 300)
end

function MainuiSkillItem:GetMtView()
	return self.mt_view
end

function MainuiSkillItem:GetAngle()
	return self.angle
end

function MainuiSkillItem:SetAngle(angle)
	self.angle = angle
end

function MainuiSkillItem:SetData(data)
	self.data = data
	self.text_num:setVisible(false)
	self:PlayIconEffect(0)
	self:CheckShowEff()
	if nil == data then
		self:SetCDTime(0)
		self.img_skill:loadTexture(ResPath.GetSkillIcon("double_setting"))
		return
	end
	
	if self.data.type == SKILL_BAR_TYPE.SKILL then
		self.img_skill:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.id)))
		if SkillData.IsFirewall(self.data.id) then
			local is_fire = MainuiData.Instance:GetAreaSkillId() == self.data.id
			local icon = is_fire and "firewall_1" or "firewall_0"
			self:PlayIconEffect(is_fire and 7 or 0, nil, nil, 0.58)
			self.img_skill:loadTexture(ResPath.GetSkillIcon(icon))
		end
	elseif self.data.type == SKILL_BAR_TYPE.ITEM then
		self:FlushByItemId(self.data.id)
	end
end

function MainuiSkillItem:GetData()
	return self.data
end

function MainuiSkillItem:FlushByItemId(item_id)
	if nil ~= self.data and self.data.type == SKILL_BAR_TYPE.ITEM and self.data.id == item_id then
		local item_config = ItemData.Instance:GetItemConfig(item_id)
		if nil ~= item_config then
			local item_num = BagData.Instance:GetItemNumInBagById(item_id)
			if ItemData.GetIsTransferStone(item_id) then
				item_num = BagData.Instance:GetItemDurabilityInBagById(item_id) / 1000
			end
			self.text_num:setVisible(true)
			self.text_num:setString(tonumber(item_num))
			self.img_skill:loadTexture(ResPath.GetItem(item_config.icon))
			self.img_skill:setGrey(item_num <= 0)
		end
	end
end

function MainuiSkillItem:OnClick()
	if nil == self.data then
		if Status.NowTime - self.last_click_time <= 0.5 then
			self.last_click_time = 0
			ViewManager.Instance:OpenViewByDef(ViewDef.Skill.SelectSkill)
		else
			self.last_click_time = Status.NowTime
		end
	else
		self.last_click_time = 0
	end
end

function MainuiSkillItem:SetGrey(value)
	self.img_skill:setGrey(value)
end
function MainuiSkillItem:IsInCD()
	return self.cd_bar:isVisible() or Status.NowTime < FightCtrl.NextAttackTime()
end

function MainuiSkillItem:ClearCDTime()
	self.cd_end_time = 0
	if self.cd_bar then
		self.cd_bar:setVisible(false)
		CountDown.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = nil
	end
end

--是否需要播放特效
function MainuiSkillItem:FlushUseSkillTip()	
	if nil == self.data then return end
	local is_show = self.data and (self.data.id == 122 or self.data.id == 123 or self.data.id == 124) and not self.cd_bar:isVisible() and SkillData.Instance:GetSkill(self.data.id)
	--必杀技提醒
	local cfg = Scene.Instance:GetSceneServerConfig()
	if is_show and cfg.tipUseSkill then
		if nil == self.img_tip  then
			self.img_tip = XUI.CreateImageView(- 110, 40, ResPath.GetSkillIcon("img_tip"), true)
			self.mt_view:TextureLayout():addChild(self.img_tip, 100)
			self.img_tip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.4, cc.p(- 120, 40)), cc.MoveTo:create(0.4, cc.p(- 110, 40)))))
		end
	end
	if self.img_tip then
		self.img_tip:setVisible(is_show and cfg.tipUseSkill)
	end
end

--是否需要播放特效
function MainuiSkillItem:CheckShowEff()	
	local is_show = self.data and (self.data.id == 122 or self.data.id == 123 or self.data.id == 124) and not self.cd_bar:isVisible() and SkillData.Instance:GetSkill(self.data.id)
	self:PlayIconEffect(is_show and 622 or 0)
	self:FlushUseSkillTip()
end

function MainuiSkillItem:SetCDTime(cd_time)	
	if cd_time <= self.cd_end_time then
		return
	end

	self.cd_end_time = cd_time
	
	if cd_time > Status.NowTime then
		self.cd_bar:setVisible(true)
		cd_time = cd_time - Status.NowTime
		CountDown.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = CountDown.Instance:AddCountDown(cd_time, 0.05, BindTool.Bind(self.OnCDTime, self))
	else
		self.cd_bar:setVisible(false)
		CountDown.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = nil
	end

	self:CheckShowEff()
end

function MainuiSkillItem:OnCDTime(elapse_time, total_time)
	if elapse_time >= total_time then
		self.cd_bar:setVisible(false)
		self.cd_bar:setPercentage(0)
		self.cd_txt:setVisible(false)
		self:CheckShowEff()	
	else
		self.cd_bar:setPercentage((1 - elapse_time / total_time) * 100)
		self.cd_txt:setVisible(true)
		self.cd_txt:setString(string.format("%ds", math.ceil(total_time - elapse_time)))
	end
end

function MainuiSkillItem:CompleteCd()
end

function MainuiSkillItem:PlayIconEffect(effect_id, anim_pos, loop, scale)
	effect_id = effect_id or 0
	if effect_id > 0 then
		if nil == self.icon_effect then
			self.icon_effect = AnimateSprite:create()
			self.mt_view:EffectLayout():addChild(self.icon_effect)
		end
		
		anim_pos = anim_pos or {x = MainuiSkillItem.Size.width / 2, y = MainuiSkillItem.Size.height / 2}
		self.icon_effect:setPosition(anim_pos)
		
		local path, name = ResPath.GetEffectUiAnimPath(effect_id)
		self.icon_effect:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		if scale then
			self.icon_effect:setScale(scale)
		end
	end
	if nil ~= self.icon_effect then
		self.icon_effect:setVisible(effect_id > 0)
	end
end

function MainuiSkillItem:RemoveIconEffect()
	if nil ~= self.icon_effect then
		self.icon_effect:removeFromParent()
		self.icon_effect = nil
	end
end

function MainuiSkillItem:SetCellGrey( boolean )
	if self.icon_effect then
		XUI.MakeGrey(self.icon_effect, boolean)
	end
	if self.img_skill then
		-- XUI.MakeGrey(self.img_skill, boolean)
		self.img_skill:setGrey(boolean)
	end
end


function MainuiSkillItem:SetTextShow(text)
	if self.cd_show_text == nil then
		self.cd_show_text = XUI.CreateRichText(MainuiSkillItem.Size.width / 2, MainuiSkillItem.Size.height + 5,  200, 20, false)
		XUI.RichTextSetCenter(self.cd_show_text)
		self.mt_view:TextLayout():addChild(self.cd_show_text)
	end
	RichTextUtil.ParseRichText(self.cd_show_text, text, nil, nil, nil, nil, nil, nil, nil, {outline_size = 1})
end


------------------------------------------------------------------------
MainuiSpecialSkill = MainuiSpecialSkill or BaseClass()
MainuiSpecialSkill.Size = cc.size(100, 100)
function MainuiSpecialSkill:__init(parent)
	self.mt_view = MainuiMultiLayout.New()
	self.mt_view:CreateByMultiLayout(parent)
	self.mt_view:setContentSize(MainuiSpecialSkill.Size)
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.FlushState, self))
	self:CreateUi()
end

function MainuiSpecialSkill:__delete()
end

function MainuiSpecialSkill:CreateUi()
	local x, y = MainuiSpecialSkill.Size.width / 2, MainuiSpecialSkill.Size.height / 2
	self.img_skill_bg = XUI.CreateImageView(x, y, "", true)
	self.mt_view:TextureLayout():addChild(self.img_skill_bg)

	local sprite = XUI.CreateSprite(ResPath.GetSkillIcon("spec_skill_prog"))
	self.prog_bar = cc.ProgressTimer:create(sprite)
	self.prog_bar:setScale(1)
	self.prog_bar:setType(0)
	self.prog_bar:setPercentage(100)
	self.prog_bar:setPosition(x, y)
	self.prog_bar:setVisible(false)
	self.mt_view:TextureLayout():addChild(self.prog_bar, 300)

	self.cd_txt = XUI.CreateText(x, y, 200, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.WHITE)
	self.cd_txt:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	self.mt_view:TextLayout():addChild(self.cd_txt, 300)

	self:FlushState()
end

function MainuiSpecialSkill:GetMtView()
	return self.mt_view
end

function MainuiSpecialSkill:SetData(data)
	self.data = data
end

function MainuiSpecialSkill:GetData()
	return self.data
end

function MainuiSpecialSkill:FlushState()
	local skill = SkillData.Instance:GetSkill(SkillData.Instance:GetMainRoleSpecSkillId())
	if nil == skill or skill.is_guideing_bisha then
		self.img_skill_bg:loadTexture(ResPath.GetSkillIcon("img_spec_skill_locked"))
		self.prog_bar:setVisible(false)
	else
		local x, y = MainuiSpecialSkill.Size.width / 2, MainuiSpecialSkill.Size.height / 2
		local anger = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ANGER)
		self.img_skill_bg:loadTexture(ResPath.GetSkillIcon("spec_skill_bg"))

		-- 进度条
		local max_anger = FuwenData.Instance:GetMaxAnger()
		local percent = anger / max_anger
		self.prog_bar:setPercentage(percent * 100);

		-- 怒气满特效
		local is_full = percent >= 1
		if is_full and nil == self.full_eff then
			self.full_eff = RenderUnit.CreateEffect(273, self.mt_view:EffectLayout(), 100, nil, nil, x - 2, y + 4)
		elseif nil ~= self.full_eff then
			self.full_eff:setVisible(is_full)
		end
		self.prog_bar:setVisible(not is_full)

		-- cd文字
		local add_point = FuwenData.Instance:GetAngerAddPoint()
		local left_time = math.ceil((max_anger - anger) / add_point)
		if left_time > 0 then
			self.cd_txt:setVisible(true)
			self.cd_txt:setString(string.format("%ds", left_time))
		else
			self.cd_txt:setVisible(false)
		end

		-- 怒气满引导施放必杀
		local show_guide = is_full and Scene.Instance:GetSceneLogic():IsNeedGuideBiSha()
		UiInstanceMgr.Instance:ShowGuideArrow(self.mt_view:EffectLayout(),
			{is_remove = not show_guide, root_x = x, root_y = MainuiSpecialSkill.Size.height, root_zorder = 999, dir = "down", word = "施放必杀"})
		UiInstanceMgr.Instance:ShowGuideLightCircle(self.mt_view:EffectLayout(),
			{is_remove = not show_guide, root_x = x, root_y = y, root_zorder = 999})
	end
end

function MainuiSpecialSkill:SetCDTime(cd_time)
end

function MainuiSpecialSkill:UpdateCD(elapse_time, total_time)
end

------------------------------------------------------------------------
MainuiSkillCommonItem = MainuiSkillCommonItem or BaseClass()
MainuiSkillCommonItem.Size = cc.size(300, 300)
function MainuiSkillCommonItem:__init(parent)
	self.last_click_time = 0
	
	self.mt_view = MainuiMultiLayout.New()
	self.mt_view:CreateByMultiLayout(parent)
	self.mt_view:setContentSize(MainuiSkillCommonItem.Size)
	
	self:CreateUi()
end

function MainuiSkillCommonItem:__delete()
end

function MainuiSkillCommonItem:CreateUi()
	local x, y = MainuiSkillCommonItem.Size.width / 2, MainuiSkillCommonItem.Size.height / 2
	
	-- self.img_skill_bg = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("skill_bg_01"), true)
	-- self.mt_view:TextureLayout():addChild(self.img_skill_bg)
	
	self.img_skill = XUI.CreateImageView(x, y, "", true)
	self.img_skill:setScale(114 / 120)
	self.mt_view:TextureLayout():addChild(self.img_skill, 10)
	-- self:FlushIcon()
	local sprite = XUI.CreateSprite(ResPath.GetSkillIcon("skill_mask"))
	self.cd_bar = cc.ProgressTimer:create(sprite)
	self.cd_bar:setScale(1.3)
	self.cd_bar:setType(0)
	self.cd_bar:setPercentage(0)
	self.cd_bar:setReverseDirection(true)
	self.cd_bar:setPosition(x, y)
	self.cd_bar:setVisible(false)
	self.mt_view:TextureLayout():addChild(self.cd_bar, 300)
	
	self.img_skill_light = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("common_light"), true)
	self.img_skill_light:setScale(1.0)
	self.mt_view:TextureLayout():addChild(self.img_skill_light, 200)
	
	self.img_up = XUI.CreateImageView(x, MainuiSkillCommonItem.Size.height - 96, ResPath.GetSkillIcon("common_up"), true)
	self.mt_view:TextureLayout():addChild(self.img_up, 100)
	local word = XUI.CreateImageView(x, MainuiSkillCommonItem.Size.height - 74, ResPath.GetSkillIcon("common_up_word"), true)
	self.mt_view:TextureLayout():addChild(word, 100)
	
	self.img_down = XUI.CreateImageView(x, 96, ResPath.GetSkillIcon("common_down"), true)
	self.mt_view:TextureLayout():addChild(self.img_down, 100)
	local word = XUI.CreateImageView(x, 74, ResPath.GetSkillIcon("common_down_word"), true)
	self.mt_view:TextureLayout():addChild(word, 100)
	
	self.up_effect = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("common_up_effect"), true)
	self.mt_view:TextureLayout():addChild(self.up_effect, 400)
	self.up_effect:setVisible(false)
	
	self.inside_effect = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("common_inside_effect"), true)
	self.inside_effect:setScale(0.9)
	self.mt_view:TextureLayout():addChild(self.inside_effect, 400)
	self.inside_effect:setVisible(false)

	self.cd_txt = XUI.CreateText(x, y, 200, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.WHITE)
	self.cd_txt:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	self.mt_view:TextLayout():addChild(self.cd_txt, 300)
end

function MainuiSkillCommonItem:SetData(data)
	self.data = data
	
	if nil == data then
		self:SetCDTime(0)
		self.img_skill:loadTexture(ResPath.GetSkillIcon("double_setting"))
		return
	end
	
	if self.data.type == SKILL_BAR_TYPE.SKILL then
		self.img_skill:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.id)))
	end
end

function MainuiSkillCommonItem:GetMtView()
	return self.mt_view
end

function MainuiSkillCommonItem:FlushIcon()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or GameEnum.ROLE_PROF_1
	if prof > 0 then
		self.img_skill:loadTexture(ResPath.GetSkillIcon("100" .. prof), true)
	end
end

function MainuiSkillCommonItem:OnClick()
	self.last_click_time = Status.NowTime
end

function MainuiSkillCommonItem:IsInCD()
	return self.cd_bar:isVisible()
end

function MainuiSkillCommonItem:SetCDTime(cd_time)
	if cd_time > Status.NowTime then
		self.cd_bar:setVisible(true)
		cd_time = cd_time - Status.NowTime
		CountDown.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = CountDown.Instance:AddCountDown(cd_time, 0.05, BindTool.Bind(self.UpdateCD, self))
	else
		self.cd_bar:setVisible(false)
		CountDown.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = nil
	end
end

function MainuiSkillCommonItem:UpdateCD(elapse_time, total_time)
	if elapse_time >= total_time then
		self.cd_bar:setVisible(false)
		self.cd_bar:setPercentage(0)
		self.cd_txt:setVisible(false)
	else
		self.cd_bar:setPercentage((1 - elapse_time / total_time) * 100)
		self.cd_txt:setVisible(true)
		self.cd_txt:setString(string.format("%ds", math.ceil(total_time - elapse_time)))
	end
end

function MainuiSkillCommonItem:PlayUpEffect()
	self.up_effect:setVisible(true)
	self.up_effect:setScaleY(1)
	self.up_effect:setOpacity(255)
	
	self.up_effect:stopAllActions()
	local action_complete_callback = function()
		self.up_effect:setVisible(false)
	end
	local action = cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(action_complete_callback))
	self.up_effect:runAction(action)
end

function MainuiSkillCommonItem:PlayDownEffect()
	self.up_effect:setVisible(true)
	self.up_effect:setScaleY(- 1)
	self.up_effect:setOpacity(255)
	
	self.up_effect:stopAllActions()
	local action_complete_callback = function()
		self.up_effect:setVisible(false)
	end
	local action = cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(action_complete_callback))
	self.up_effect:runAction(action)
end

function MainuiSkillCommonItem:PlayInsideEffect()
	self.inside_effect:setVisible(true)
end

function MainuiSkillCommonItem:StopInsideEffect()
	self.inside_effect:setVisible(false)
end

function MainuiSkillCommonItem:PlayExteriorEffect()
	local x, y = MainuiSkillCommonItem.Size.width / 2, MainuiSkillCommonItem.Size.height / 2
	local effect = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("common_exterior_effect"), true)
	effect:setScale(0.83)
	self.mt_view:TextureLayout():addChild(effect, 400)
	
	local scale_to = cc.ScaleTo:create(0.3, 1)
	local action_complete_callback = function()
		effect:removeFromParent()
	end
	local action = cc.Sequence:create(scale_to, cc.CallFunc:create(action_complete_callback))
	effect:runAction(action)
end
