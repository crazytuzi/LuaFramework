-- 
-- @Author: LaoY
-- @Date:   2018-07-26 16:01:02
--

SkillManager = SkillManager or class("SkillManager",BaseManager)
local SkillManager = SkillManager

function SkillManager:ctor()
	SkillManager.Instance = self
	self:Reset()
	self:AddEvent()
end

function SkillManager:Reset()
	-- 上一个释放普攻时间
	self.last_ordinary_skill_time = 0
	-- 上一个普攻index
	self.ordinary_skill_index = 0

	-- 上一个技能释放时间
	self.last_skill_time = 0
	-- 上一个技能ID
	self.last_skill_id = 0

	self.skill_index_list = {}
end

function SkillManager.GetInstance()
	if SkillManager.Instance == nil then
		SkillManager()
	end
	return SkillManager.Instance
end

function SkillManager:AddEvent()
	local function attack_call_back()
		self:TryReleaseOrdinarySkill()
	end
	GlobalEvent:AddListener(MainEvent.Attack, attack_call_back)

	local function call_back(skill_id,is_auto_fight)
		self:TryReleaseSkill(skill_id,is_auto_fight)
	end
	GlobalEvent:AddListener(MainEvent.ReleaseSkill, call_back)
end

--[[
	@author LaoY
	@des	尝试释放普通攻击 普攻也是技能
--]]
function SkillManager:TryReleaseOrdinarySkill()
	local cur_time = Time.time
	if cur_time - self.last_skill_time < FightConfig.PublicCD or cur_time - self.last_ordinary_skill_time < FightConfig.PublicOrdinaryCD then
		return
	end
	local skill_id = self:GetNextOrdinarySkill()
	self:ReleaseSkill(skill_id)
	-- if self:ReleaseSkill(skill_id) then
	-- 	self.ordinary_skill_index = index
	-- 	self.last_ordinary_skill_time = cur_time
	-- end
end

function SkillManager:GetNextOrdinarySkill()
	local index
	local cur_time = Time.time
	if cur_time - self.last_skill_time < FightConfig.PublicCD or cur_time - self.last_ordinary_skill_time < FightConfig.PublicOrdinaryCD then
		return
	end

	-- 机甲变身状态
	local mecha_morph_buff = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
	if mecha_morph_buff then
		local skill_vo = SkillUIModel:GetInstance():GetSkillByIndex(enum.SKILL_POS.SKILL_POS_MACHINEARMOR_NOR)
		local cur_time_ms = os.clock()
		if skill_vo and cur_time_ms >= tonumber(skill_vo.cd) then
			return skill_vo.id
		end
		return
	end

	if cur_time - self.last_ordinary_skill_time < FightConfig.OrdinaryCombTime then
		index = self.ordinary_skill_index + 1
	else
		index = 1
	end
	local ordinary_skill_list = self:GetOrdinarySkillList()
	index = index > #ordinary_skill_list and 1 or index
	index = index < 1 and 1 or index
	-- index = 1
	local skill_id = ordinary_skill_list[index]
	return skill_id
end

function SkillManager:GetOrdinarySkillList()
	local skill_list = SkillUIModel:GetInstance():GetOrdinarySkillList()

	local ordinary_skill_list = {}
	local count = 0
	for i=1,#skill_list do
		local vo = skill_list[i]
		if vo.pos == 0 then
			ordinary_skill_list[#ordinary_skill_list+1] = vo.id
		end
	end
	if not table.isempty(ordinary_skill_list) then
		return ordinary_skill_list
	end
	local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	return FightConfig.OrdinarySkill[role_data.gender]
end

function SkillManager:GetSkillSeq(skill_id)
	self.skill_index_list[skill_id] = self.skill_index_list[skill_id] or 1
	return self.skill_index_list[skill_id]
end

function SkillManager:GetNextSkill()
	local cur_time = Time.time
	if cur_time - self.last_skill_time < FightConfig.PublicCD or cur_time - self.last_ordinary_skill_time < FightConfig.PublicOrdinaryCD then
		return
	end
	local skill_list = SkillUIModel:GetInstance().skill_List or {}
	local can_release_list = {}
	local cur_time_ms = os.clock()
	local length = #skill_list
	-- length = length >=8 and 8 or length
	local mecha_morph_buff = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
	
	--获取到怒气相关buff
	local add_anger_buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_ADD_ANGER)
    local del_anger_buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_DEL_ANGER)
    local anger_p_buff = nil
    if add_anger_buff_id then
        anger_p_buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(add_anger_buff_id)
    elseif del_anger_buff_id then
        anger_p_buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(del_anger_buff_id)
    end

	for i=1,length do

		--获取技能是否可以自动释放
		local vo = skill_list[i]
		local auto_use = SkillUIModel:GetInstance().autoUseChangeList[vo.id]

		if tonumber(vo.cd) <= cur_time_ms and auto_use == 0 then
			if mecha_morph_buff and vo.pos > enum.SKILL_POS.SKILL_POS_MACHINEARMOR_NOR and vo.pos <= enum.SKILL_POS.SKILL_POS_MACHINEARMOR_6 then
				can_release_list[#can_release_list+1] = {id = vo.id,level = 1, pos = vo.pos}
			elseif not mecha_morph_buff and vo.pos > 0 and vo.pos <= enum.SKILL_POS.SKILL_POS_TRANSFORM then
				can_release_list[#can_release_list+1] = {id = vo.id,level = 1, pos = vo.pos}
			elseif vo.pos == enum.SKILL_POS.SKILL_POS_ANGER and anger_p_buff and anger_p_buff.value == 100 then
				can_release_list[#can_release_list+1] = {id = vo.id,level = 1, pos = vo.pos}
			end
		end
	end
	
	-- local skill
	-- local long_cd
	-- for k,v in pairs(can_release_list) do
	-- 	local config = self:GetSkillLevelConfig(v.id,v.level)
	-- 	if config then
	-- 		if not long_cd or config.cd > long_cd then
	-- 			long_cd = config.cd
	-- 			skill = v.id
	-- 		end
	-- 	end
	-- end

	local function sortFunc(a,b)
		if a.pos == b.pos then
			return a.id < b.id
		else
			return a.pos < b.pos
		end
	end

	table.sort(can_release_list,sortFunc)
	if table.isempty(can_release_list) then
		return nil
	end
	return can_release_list[1].id
end

function SkillManager:SetSkillPublickCD(skill)
	local is_pet_skill = self:IsPetSkill(skill)
	local skill_list = SkillUIModel:GetInstance().skill_List or {}
	local cur_time_ms = os.clock()
	for i=1,#skill_list do
		local vo = skill_list[i]
		if skill == vo.id then
			local config = self:GetSkillLevelConfig(skill)
			if config then
				local end_time = cur_time_ms + config.cd + 150
				vo.cd = end_time
				SkillModel:GetInstance():Brocast(SkillEvent.UPDATE_SKILL_CD,vo.id,end_time)
			end
		elseif not is_pet_skill and vo.pos ~= 0 and tonumber(vo.cd) <= cur_time_ms + FightConfig.PublicCD * 1000 then
			SkillModel:GetInstance():Brocast(SkillEvent.UPDATE_SKILL_CD,vo.id,cur_time_ms + FightConfig.PublicCD * 1000,true)
		end
	end
end

--[[
	@author LaoY
	@des	尝试释放技能
	@param1 skill_id 技能ID
--]]
function SkillManager:TryReleaseSkill(skill_id,is_auto_fight)
	if not skill_id then
		return
	end

	local skill_cfg = Config.db_skill[skill_id]

	--是否忽略技能公共CD
	local is_ignore_public_cd = skill_cfg.group ~=1 and skill_cfg.group ~=3
	if not is_ignore_public_cd then
		local cur_time = Time.time
		if cur_time - self.last_skill_time < FightConfig.PublicCD or cur_time - self.last_ordinary_skill_time < FightConfig.PublicOrdinaryCD then
			return
		end
	end

	
	self:ReleaseSkill(skill_id,is_auto_fight)
	-- if self:ReleaseSkill(skill_id) then
	-- 	self.last_skill_time = cur_time
	-- 	self.last_skill_id = skill_id
	-- end
end

function SkillManager:ReleaseSkillSuccess(skill_id)
	local ordinary_index = self:IsOrdinarySkill(skill_id)
	local cur_time = Time.time
	if ordinary_index then
		self.ordinary_skill_index = ordinary_index
		self.last_ordinary_skill_time = cur_time
	else
		self.last_skill_time = cur_time
		self.last_skill_id = skill_id
	end

	self.skill_index_list[skill_id] = self.skill_index_list[skill_id] or 0
	self.skill_index_list[skill_id] = self.skill_index_list[skill_id] + 1

	-- 派发播放技能成功事件
	-- GlobalEvent:Brocast(event_name)
end

function SkillManager:ReciveSkillSuccess(skill_id)
	local ordinary_index = self:IsOrdinarySkill(skill_id)
	local cur_time = Time.time
	if ordinary_index then
		self.ordinary_skill_index = ordinary_index
		self.last_ordinary_skill_time = cur_time
	else
		self.last_skill_time = cur_time
		self.last_skill_id = skill_id
	end
end

function SkillManager:IsOrdinarySkill(skill_id)
	local ordinary_skill_list = self:GetOrdinarySkillList()
	for k,v in pairs(ordinary_skill_list) do
		if skill_id == v then
			return k
 		end
	end
	return false
end

--[[
	@author LaoY
	@des	释放技能
	@param1 skill_id 技能ID
--]]
function SkillManager:ReleaseSkill(skill_id,is_auto_fight)
	if not skill_id then
		return false
	end
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role and main_role.is_swing_block then
		Notify.ShowText("You can't battle in the deep water zone")
		return
	end

	--根据id获取到技能信息
	local skill_vo = self:GetSkillVo(skill_id)

	return FightManager:GetInstance():MainRoleReleaseSkill(skill_vo,is_auto_fight)
end

function SkillManager:GetSkillVo(skill_id)
	 return FightConfig.SkillConfig[skill_id]
end

function SkillManager:IsCanAttackLockTarget(id,skill_vo)
	local object = SceneManager:GetInstance():GetObject(id)
	if not object or object:IsDeath() or not object.is_loaded then
		return false
	end
	local skill_id = skill_vo.skill_id
	local config = self:GetSkillLevelConfig(skill_id,level)
	if not config or not config.area then
		return false
	end
	local main_role = SceneManager:GetInstance():GetMainRole()
	local rush_dis = SceneConstant.RushDis
	local range = config.dist
	local distance = Vector2.Distance(main_role:GetPosition(), object:GetPosition())
	return distance <= (rush_dis + range)
end

--[[
	@author LaoY
	@des	获取客户端攻击目标
	@param1 object 默认是主角
	@param2 skill_vo 技能信息
	@param3 rush_dis 冲刺距离
	@return 目标ID
--]]
function SkillManager:GetClientTarget(object,skill_vo,rush_dis,object_type_id)
	object = object or SceneManager:GetInstance():GetMainRole()
	local skill_id = skill_vo.skill_id
	local config = self:GetSkillLevelConfig(skill_id,level)
	if not config or not config.area then
		return
	end
	-- local area = String2Table(config.area)
	local range_type = config.area
	local range = config.dist
	if not range_type or not range then
		return
	end

	local tartget_type = enum.ACTOR_TYPE.ACTOR_TYPE_CREEP
	local target = self:GetAttackTarget(object,range_type,range,rush_dis,config.radius,tartget_type,object_type_id)

	-- 可以攻击人的模式
	if not target then
		tartget_type = enum.ACTOR_TYPE.ACTOR_TYPE_ROLE
		target = self:GetAttackTarget(object,range_type,range,rush_dis,config.radius,tartget_type,object_type_id)
	end
	return target
end

function SkillManager:GetAttackTarget(object,range_type,range,rush_dis,radius,tartget_type,object_type_id)
	local target
	-- 冲刺
	if rush_dis then
		-- target = self:GetRangeTarget(object,range,range + rush_dis,tartget_type,360,object_type_id)
		target = self:GetRangeTarget(object,SceneConstant.AttactDis,SceneConstant.AttactDis + rush_dis,tartget_type,360,object_type_id)
	-- 单体
	elseif range_type == enum.SKILL_AREA.SKILL_AREA_SINGLE then
		target = self:GetRangeTarget(object,0,range,tartget_type,360,nil,object_type_id)
	-- 矩形
	elseif range_type == enum.SKILL_AREA.SKILL_AREA_RECT then
		target = self:GetRangeTarget(object,0,range,tartget_type,360,nil,object_type_id)
	-- 扇形
	elseif range_type == enum.SKILL_AREA.SKILL_AREA_SECTOR then
		target = self:GetRangeTarget(object,0,range,tartget_type,radius or 90,nil,object_type_id)
	-- 圆形
	elseif range_type == enum.SKILL_AREA.SKILL_AREA_CIRCLE then
		target = self:GetRangeTarget(object,0,range,tartget_type,360,nil,object_type_id)
	end
	return target
end

--[[
	@author LaoY
	@des	获取攻击范围内的对象列表
	@param1 scene_object 	施法者
	@param2 start_range 	半径起点 有可能获取圆环或者扇环内的怪物，默认是获取圆形或者扇形内的怪物
	@param3 range  			攻击半径
	@param4 type   			攻击类型 默认是怪物
	@param5 creep_kind   	攻击类型 怪物类型
	@param5 object_type_id  攻击类型 怪物ID(怪物类型ID，不是实例ID)
	@return table 			k = sceneobject ,v = distance
--]]
function SkillManager:GetRangeTargetList(scene_object,start_range,range,actor_type,creep_kind,object_type_id)
	start_range = start_range or 0
	actor_type = actor_type or enum.ACTOR_TYPE.ACTOR_TYPE_CREEP
	creep_kind = creep_kind or enum.CREEP_KIND.CREEP_KIND_MONSTER
	scene_object = scene_object or SceneManager:GetInstance():GetMainRole()
	if not scene_object then
		return
	end
	local object_list = SceneManager:GetInstance():GetObjectListByType(actor_type)
	if not object_list then
		return nil
	end
	if actor_type ~= enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
		creep_kind = nil
	end
	-- 候选名单
	local candidate_list = {}
	-- 施法者的坐标
	local caster_pos = scene_object:GetPosition()
	-- 攻击距离的平方
	local start_range_square = start_range * start_range
	local range_square = range * range
	-- 不开方的话，效率好一点
	for k,object in pairs(object_list) do
		local dis_square = Vector2.DistanceNotSqrt(caster_pos, object:GetPosition())
		local config = Config.db_creep[object.object_info.id]
		local volume = object:GetVolume()
		range_square = (range+volume) * (range+volume)
		if (not creep_kind or (config and creep_kind == config.kind)) and 
		(not object_type_id or object_type_id == object.object_info.id) and not object:IsDeath() and object.is_loaded
		and dis_square <= range_square and dis_square >= start_range_square then

			--攻击人的时候，对方是否可以攻击 详细规则后面补充
			if actor_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then 
				if (
					(FightManager:GetInstance().pkmode == enum.PKMODE.PKMODE_ALLY and 
					not TeamController:GetInstance():IsSameTeam(object.object_info.team) and
					not FactionModel:GetInstance():IsSameGuild(object.object_info.gname)
					)
					or FightManager:GetInstance().pkmode == enum.PKMODE.PKMODE_WHOLE) then
					candidate_list[object] = dis_square
				end
			else
				candidate_list[object] = dis_square
			end
		end
	end
	return candidate_list
end

--[[
	@author LaoY
	@des	获取攻击范围内的对象
	@param5 radian 			攻击朝向 360就是圆 默认是朝向的60弧度
	@return sceneobject 	优先选择面向的最近的目标
--]]
function SkillManager:GetRangeTarget(scene_object,start_range,range,actor_type,radian,creep_kind,creep_id)
	scene_object = scene_object or SceneManager:GetInstance():GetMainRole()
	local candidate_list = self:GetRangeTargetList(scene_object,start_range,range,actor_type,creep_kind,creep_id) or {}
	radian = radian or 60
	-- local range_square = range * range
	-- 施法者面向最近的对象距离 
	local min_dir_dis_square
	local min_dis_square
	-- 最佳候选对象 面向的为最佳
	local best_candidate = nil
	-- 候选对象 没有面向的 选择最近的
	local candidate = nil
	local caster_pos = scene_object:GetPosition()
	local caster_dir = scene_object:GetRotate().y
	for object,distance in pairs(candidate_list) do
		local pos = object:GetPosition()
		local vec = GetVector(caster_pos,pos)
		-- local v_radian = Vector2.GetAngle(vec)
		if IsInRadian(caster_dir,radian,vec) then
			if not min_dir_dis_square or distance < min_dir_dis_square then
				min_dir_dis_square = distance
				best_candidate = object
			end
		else
			-- 找不到角度最好的，就找最近的
			if not min_dis_square or distance < min_dis_square then
				min_dis_square = distance
				candidate = object
			end
		end
	end
	if best_candidate then
		return best_candidate
	end
	return candidate
end

--[[
	@author LaoY
	@des	获取冲刺目的坐标，冲刺分两种
			1.太近，直接走过去
			2.冲刺
--]]
function SkillManager:GetSkillRushPos(scene_object,skill_vo,rush_target,object_type_id)
	object = object or SceneManager:GetInstance():GetMainRole()
	-- local target = self:GetClientTarget(scene_object,skill_vo)
	-- if target then
	-- 	return nil
	-- end
	local rush_dis = SceneConstant.RushDis
	rush_target = rush_target or self:GetClientTarget(scene_object,skill_vo,rush_dis,object_type_id)
	if not rush_target then
		return nil
	end
	local skill_id = skill_vo.skill_id
	local config = self:GetSkillLevelConfig(skill_id,level)
	if not config or not config.dist then
		return nil
	end
	local range = config.dist
	-- if range < SceneConstant.RushMinDis then
	-- 	return
	-- end
	local start_pos = scene_object:GetPosition()
	local end_pos = rush_target:GetPosition()
	local vec = GetVector(start_pos,end_pos)
	vec = Vector2.Normalize(vec)
	local distance = Vector2.Distance(start_pos, end_pos)
	local radius = rush_target:GetVolume()
	-- local rush = distance - range - radius + 20
	-- rush = math.min(rush,SceneConstant.RushDis)
	-- if rush < 0 then
	-- 	rush = 0
	-- end
	-- local rush_pos = {x = start_pos.x + vec.x * rush,y = start_pos.y + vec.y * rush}

	rush_pos = GetDirDistancePostion(start_pos,end_pos,SceneConstant.AttactDis * 0.5 + radius)
	if OperationManager:GetInstance():IsBlock(rush_pos.x,rush_pos.y) then
		rush_pos = end_pos
	end
	return rush_pos,rush_target
end

function SkillManager:CheckSkillInRange(object,target_object,skill_vo)
	if not object or not target_object or not skill_vo then
		return false
	end
	local skill_id = skill_vo.skill_id
	local config = self:GetSkillLevelConfig(skill_id,level)
	if not config or not config.dist then
		return false
	end
	local range = config.dist
	local range_square = range * range
	return Vector2.DistanceNotSqrt(object:GetPosition(), target_object:GetPosition()) <= range_square
end

function SkillManager:GetSkillLevel()
	return 1
end

function SkillManager:GetSkillConfig(skill_id)
	return Config.db_skill[skill_id]
end

function SkillManager:GetSkillLevelConfig(skill_id,level)
	level = level or self:GetSkillLevel(skill_id)
	local key = string.format("%s@%s",skill_id,level)
	return Config.db_skill_level[key]
end

function SkillManager:GetSkillAttackDistance(skill_id)
	local config = self:GetSkillLevelConfig(skill_id)
	if not config or not config.dist then
		return 0
	end
	return config.dist
end

function SkillManager:IsPetSkill(skill)
	local cf = self:GetSkillConfig(skill)
	if not cf then
		return false
	end
	return cf.attack == 2
end

function SkillManager:GetPetReleaseSkillByList(skill_list)
	local skill
	local long_cd
	for k,id in pairs(skill_list) do
		-- local config = self:GetSkillLevelConfig(id,1)
		-- if config then
		-- 	if not long_cd or config.cd > long_cd then
		-- 		long_cd = config.cd
		-- 		skill = id
		-- 	end
		-- end
		skill = id
		return skill
	end
	return skill
end

function SkillManager:IsCanRelease(skill)

end

function SkillManager:IsReleaseDebuffSkill(skill_id)
	-- 镇炎说写死
	local tab = {
		-- 男角色
		[101010] = true,
		-- 女角色
		[201010] = true,
	}
	return tab[skill_id]
end