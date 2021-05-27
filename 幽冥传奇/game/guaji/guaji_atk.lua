GuajiCtrl = GuajiCtrl or BaseClass(BaseController)

-- 记录攻击操作信息
-- 先缓存起来，不是直接就攻击的 如果目标在攻击范围内且攻击信息有效会立刻发动攻击 缓存过程中可以替换更高优先级的攻击信息
function GuajiCtrl:DoAtkOperate(atk_source, skill_id, x, y, dir, target_obj)
	if self.AtkInfo.is_valid and self.AtkInfo.atk_source < atk_source then -- 攻击源优先级比已缓存有效信息低，不记录
		return false
	end
	self.AtkInfo.is_valid = true	-- 有效的缓存信息
	self.AtkInfo.atk_source = atk_source	-- 攻击源
	self.AtkInfo.record_time = Status.NowTime	-- 记录此次攻击信息的时间

	self.AtkInfo.skill_id = skill_id	-- 攻击的技能id
	self.AtkInfo.x = x	-- 攻击坐标x 为nil时:主角施放时的坐标/攻击目标的坐标
	self.AtkInfo.y = y	-- 攻击坐标y 为nil时:主角施放时的坐标/攻击目标的坐标
	self.AtkInfo.dir = dir	-- 攻击方向 为nil时:会自动根据当前位置和目标位置计算攻击方向
	self.AtkInfo.target_obj_id = target_obj and target_obj:GetObjId() or COMMON_CONSTS.INVALID_OBJID	-- 目标对象id
	self.AtkInfo.target_obj = target_obj
	self.AtkInfo.skill_range_info = SkillData.Instance:GetSkillDisConds(skill_id) -- 施放技能的范围信息

	self:StrictCheckAtkOpt()

	return true
end

-- 清除攻击操作信息
function GuajiCtrl:ClearAtkOperate(atk_source)
	if nil ~= atk_source and self.AtkInfo.atk_source ~= atk_source then -- 指定攻击源
		return
	end

	self.AtkInfo.is_valid = false
	self.AtkInfo.target_obj_id = COMMON_CONSTS.INVALID_OBJID
	self.AtkInfo.target_obj = nil
end

function GuajiCtrl:CheckRoleIsFree()
	local main_role = self.scene:GetMainRole()

	--玩家角色执行动作中
	if main_role:IsMove() or main_role:IsAtk() or MoveCache.is_valid or self.AtkInfo.is_valid then
		return false
	end

	-- 玩家正操作移动
	if MoveCache.is_player_opting then
		return false
	end

	return true
end

-- 职业自动施放技能
function GuajiCtrl:UpdateProfAutoSkill(now_time, elapse_time)
	if not self:CheckRoleIsFree() then return end
	local main_role = self.scene:GetMainRole()
	local prof = main_role:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if prof == GameEnum.ROLE_PROF_2 then
		-- if not main_role:HasBuffByGroup(BUFF_GROUP.MAGIC_SHIELD) and GuajiCtrl.CanAutoUseSkill(16) then
		-- 	self:DoAtkOperate(ATK_SOURCE.PROF_AUTO, 16)
		-- 	return
		-- end
	elseif prof == GameEnum.ROLE_PROF_3 then
		if not main_role:HasBuffByGroup(BUFF_GROUP.HUTISHU) and GuajiCtrl.CanAutoUseSkill(26) then
			self:DoAtkOperate(ATK_SOURCE.PROF_AUTO, 26)
			return
		end
		if not RoleData.Instance:IsEntityState(EntityState.StateOwnPet) and GuajiCtrl.CanAutoUseSkill(25) then
			self:DoAtkOperate(ATK_SOURCE.PROF_AUTO, 25)
			return
		end
	else
		-- SettingCtrl.Instance:GetAutoSkillSetting(SkillData.Instance:GetSkillClientIndex(16))
		if GuajiCtrl.CanAutoUseSkill(16) then	
			if not main_role:HasBuffByGroup(BUFF_GROUP.HUTI_SHIELD) then
				self:DoAtkOperate(ATK_SOURCE.PROF_AUTO, 16)
				return
			end
		end	
	end
end

-- 攻击缓存信息 攻击是否在范围内
function GuajiCtrl:GetAtkInfoMoveInfo()
	local main_role = self.scene:GetMainRole()
	local self_x, self_y = main_role:GetServerPos()
	local atk_x, atk_y = self.AtkInfo.x, self.AtkInfo.y

	if nil == atk_x and nil == atk_y then
		if nil ~= self.AtkInfo.target_obj then
			atk_x, atk_y = self.AtkInfo.target_obj:GetLogicPos()
		end
	end

	local in_range, range = GuajiCtrl.CheckAtkRange(self_x, self_y, atk_x, atk_y, self.AtkInfo.skill_range_info)
	return in_range, atk_x, atk_y, range
end



-------------------------------------
-- 执行攻击行为

-- 严格的攻击检查 在移动中或攻击中不攻击
function GuajiCtrl:StrictCheckAtkOpt()
	if not self.AtkInfo.is_valid then
		return false
	end

	local main_role = self.scene:GetMainRole()
	if main_role:IsMove() or not main_role:IsAtkEnd() or MoveCache.is_valid then
		return false
	end

	if nil ~= self.AtkInfo.target_obj then
		if self.AtkInfo.target_obj ~= self.scene:GetObjectByObjId(self.AtkInfo.target_obj_id) then
			self:ClearAtkOperate()
			return false
		end
	end

	return self:MoveToAtk()
end

-- 移动到可攻击的范围进行攻击 成功发功攻击时返回 true
function GuajiCtrl:MoveToAtk()
	if not self.AtkInfo.is_valid then
		return false
	end

	local in_range, atk_x, atk_y, range = self:GetAtkInfoMoveInfo()
	
	-- 目标在范围内攻击
	if in_range then
		return self:DoAtk()
	end

	-- 无指定的攻击目标且无攻击坐标
	if nil == self.AtkInfo.target_obj and (nil == atk_x or nil == atk_y) then
		return false
	end

	-- 玩家正操作移动
	if MoveCache.is_player_opting then
		return false
	end

	-- 检查移动缓存重复
	if MoveCache.is_valid and MoveCache.move_type == MoveType.AtkMove then
		if MoveCache.x == atk_x and MoveCache.y == atk_y and MoveCache.range == range then
			return false
		end
	end
	
	-- 移动到可发动攻击的坐标
	MoveCache.end_type = MoveEndType.Fight
	MoveCache.x = atk_x
	MoveCache.y = atk_y
	MoveCache.range = range
	MoveCache.is_valid = true
	MoveCache.move_type = MoveType.AtkMove
	MoveCache.target_obj = self.AtkInfo.target_obj
	MoveCache.target_obj_id = self.AtkInfo.target_obj_id
	MoveCache.offset_range = 0

	self:MoveHelper(atk_x, atk_y, range)
	return false
end

-- 发动攻击
-- 返回是否发动成功
function GuajiCtrl:DoAtk()
	local do_atk_succ = false
	if not self.AtkInfo.is_valid then
		return do_atk_succ
	end

	local main_role = self.scene:GetMainRole()
	local self_x, self_y = main_role:GetServerPos()
	local atk_x, atk_y, dir = self.AtkInfo.x, self.AtkInfo.y, self.AtkInfo.dir
	
	if nil == self.AtkInfo.target_obj then
		-- 不需要攻击对象的技能攻击
		atk_x, atk_y = atk_x or self_x, atk_y or self_y -- 没有提供坐标的用主角当前坐标
		if not GuajiCtrl.CheckAtkRange(self_x, self_y, atk_x, atk_y, self.AtkInfo.skill_range_info) then
			return do_atk_succ
		end

		dir = dir or self:GetMainRoleTargetDir(atk_x, atk_y)
		do_atk_succ = main_role:PerformSkill(self.AtkInfo.skill_id, 0, atk_x, atk_y, dir)
	else
		-- 需要攻击对象的技能攻击
		local tar_x, tar_y = self.AtkInfo.target_obj:GetLogicPos()
		atk_x, atk_y = atk_x or tar_x, atk_y or tar_y -- 没有提供坐标的用攻击目标当前坐标
		if not GuajiCtrl.CheckAtkRange(self_x, self_y, atk_x, atk_y, self.AtkInfo.skill_range_info) then
			return do_atk_succ
		end

		dir = dir or self:GetMainRoleTargetDir(atk_x, atk_y)
		do_atk_succ = main_role:PerformSkill(self.AtkInfo.skill_id, self.AtkInfo.target_obj_id, atk_x, atk_y, dir)

		-- 对一个目标攻击后 如果不是自动战斗，进入半自动，打死目标或者丢失目标才停止杀戮
		if GuajiCache.guaji_type ~= GuajiType.Auto then
			self:SetGuajiType(GuajiType.HalfAuto)
		end
	end

	if do_atk_succ then
		self:ClearAtkOperate()
	end
	return do_atk_succ
end

-- 自动使用技能攻击目标
function GuajiCtrl:DoAttackTarget(target_obj)
	if nil == target_obj then
		return
	end

	if self.AtkInfo.is_valid or not self.scene:GetMainRole():IsAtkEnd() or MoveCache.is_player_opting then
		return
	end

	local x, y = target_obj:GetLogicPos()
	local aim_obj_x, aim_obj_y = target_obj:GetLogicPos()
	local dir = self:GetMainRoleTargetDir(x, y)

	local skill_id, range = 0, 1
	local back_skill_id, back_range = 0, 1
	local can_use, temp_range = false, 1

	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if prof == GameEnum.ROLE_PROF_1 then
		for i, v in ipairs({123, 122, 16, 8, 7, 6}) do
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(v)
			if can_use then
				skill_id, range = v, temp_range
				break
			end
		end

		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(3)
			if can_use then
				skill_id, range = 3, temp_range
			end

			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(4)
			if can_use and target_obj:GetType() == SceneObjType.Monster and target_obj:IsRealMonster()
				and GuajiCtrl.IsMultiTarget(x, y, 1) then
				skill_id, range = 4, temp_range
			end
		end
	elseif prof == GameEnum.ROLE_PROF_2 then
		----环境状态 外部对权重计算的影响
		--是否需要释放群体技能
		local is_need_multi = GuajiCtrl.IsMultiTarget(aim_obj_x, aim_obj_y, 1)
		--获取设置中的设定好的技能id 判断当前技能是否可使用
		local single_skill_idx, multi_skill_idx = SettingData.Instance:GetGuajiSkillData()		
		local function is_setting_set_guaji_skill(id)		
			return id == SettingData.SKILL[prof][2][multi_skill_idx + 1] or id == SettingData.SKILL[prof][1][single_skill_idx + 1]
		end
		--该技能不在设置中设定 需做特殊处理
		local function is_bisha(id)
			return id == 32
		end

		--初始化 技能优先级结构体
		local function init_skill_data(t)
			--根据不同环境状态(是否需要群体攻击is_multi 是否可以使用can_use) 计算技能释放优先级
			t.calc_priority_num = function (is_multi, can_use)
				return t.damage + (is_multi and t.multi or 0) + (not can_use and t.not_can_use or 0)
			end
			return t
		end

		--以技能的 伤害, 范围伤害, 是否可使用 计算优先级
		local priority_attr_list = {
			[1] = init_skill_data{id = 32, damage = 5, multi = 10, not_can_use = -1000},		--必杀技
			[2] = init_skill_data{id = 12, damage = 3, multi = 0, not_can_use = -1000},			--大雷电术
			[3] = init_skill_data{id = 83, damage = 4, multi = 0, not_can_use = -1000},			--火龙气焰
			[4] = init_skill_data{id = 17, damage = 1, multi = 10, not_can_use = -1000},		--流星火雨
			[5] = init_skill_data{id = 18, damage = 2, multi = 10, not_can_use = -1000}			--冰雪咆哮
		}

		--进行排序 筛选最佳技能
		table.sort(priority_attr_list, function (a, b)
			local a_can_use = GuajiCtrl.CanAutoUseSkill(a.id) and (is_setting_set_guaji_skill(a.id) or is_bisha(a.id))
			local b_can_use = GuajiCtrl.CanAutoUseSkill(b.id) and (is_setting_set_guaji_skill(b.id) or is_bisha(b.id))
			return a.calc_priority_num(is_need_multi, a_can_use) > b.calc_priority_num(is_need_multi, b_can_use)
		end)
		--得到技能id
		--最后检测得到的技能id 是否能使用
		if priority_attr_list[1].calc_priority_num(is_need_multi, GuajiCtrl.CanAutoUseSkill(priority_attr_list[1].id)) > 0 then
			skill_id = priority_attr_list[1].id
		end
	else
		local single_skill_idx, multi_skill_idx = SettingData.Instance:GetGuajiSkillData()
		local function is_setting_set_guaji_skill(id)
			return id == SettingData.SKILL[prof][2][multi_skill_idx + 1] or id == SettingData.SKILL[prof][1][single_skill_idx + 1]
		end

		local target_color = target_obj:GetAttr(OBJ_ATTR.CREATURE_COLOR)
		can_use, temp_range = GuajiCtrl.CanAutoUseSkill(33)
		if can_use then
			skill_id, range = 33, temp_range
		end

		if 0 == skill_id and GuajiCtrl.IsMultiTarget(x, y, 1) then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(27)
			if can_use and is_setting_set_guaji_skill(27) then
				-- 红色表示已中毒
				if target_color ~= 0x00ff0000 and target_color ~= 0x00b1b1b1 then
					skill_id, range = 27, temp_range
				end
			end
			if 0 == skill_id and target_obj:GetType() == SceneObjType.Monster and target_obj:IsRealMonster() then
				can_use, temp_range = GuajiCtrl.CanAutoUseSkill(28)
				if can_use and is_setting_set_guaji_skill(28) then
					skill_id, range = 28, temp_range
				end
			end
		end

		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(22)
			if can_use and is_setting_set_guaji_skill(22)  then
				skill_id, range = 22, temp_range
			end
		end

		if 0 == skill_id then
			can_use, temp_range = GuajiCtrl.CanAutoUseSkill(23)
			if can_use  then
				if target_color ~= 0x00ff0000 and target_color ~= 0x00b1b1b1 then
					skill_id, range = 23, temp_range
				end
			end
		end
	end

	if prof == GameEnum.ROLE_PROF_1 or skill_id ~= 0 then
		self:DoAtkOperate(ATK_SOURCE.AUTO, skill_id, nil, nil, nil, target_obj)
	end
end


-- 自动选择一个攻击目标
function GuajiCtrl:SelectAtkTarget(can_select_role)
	local target_obj = nil

	if nil ~= GuajiCache.target_obj 
		and GuajiCache.target_obj == self.scene:GetObjectByObjId(GuajiCache.target_obj_id)
		and self.scene:IsEnemy(GuajiCache.target_obj) then
		target_obj = GuajiCache.target_obj
	end

	if nil == target_obj then
		local scene = self.scene

		local target_distance = COMMON_CONSTS.SELECT_OBJ_DISTANCE
		local x, y = scene:GetMainRole():GetLogicPos()

		local temp_target = nil
		temp_target, target_distance = scene:SelectObjHelper(scene:GetMonsterList(), x, y, target_distance, SelectType.Enemy)
		target_obj = temp_target or target_obj

		if can_select_role then
			temp_target = nil
			temp_target, target_distance = scene:SelectObjHelper(scene:GetRoleList(), x, y, target_distance, SelectType.Enemy)
			target_obj = temp_target or target_obj
		end

		if nil ~= target_obj then
			GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "select")
		end
	end

	return target_obj
end

-- 取消选中
function GuajiCtrl:CancelSelect(auto_pick)
	if nil ~= GuajiCache.target_obj then
		if self.scene:CheckObjRefIsValid(GuajiCache.target_obj, GuajiCache.target_obj_id) then
			GuajiCache.target_obj:CancelSelect()
		end
		GuajiCache.target_obj = nil
		GuajiCache.target_obj_id = COMMON_CONSTS.INVALID_OBJID
	end
end

function GuajiCtrl.CanAutoUseSkill(skill_id)
	if not SkillData.Instance:GetSkillAuto(skill_id) then
		return false, 0
	end
	return SkillData.Instance:CanUseSkill(skill_id)
end