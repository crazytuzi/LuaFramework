-- 
-- @Author: LaoY
-- @Date:   2018-08-25 14:55:16
-- 
AutoFightManager = AutoFightManager or class("AutoFightManager",BaseManager)
local this = AutoFightManager

AutoFightManager.CheckTime = 0.05

AutoFightManager.AutoState = {
	Stop 	= 0, 	-- 手动
	Tem 	= 1, 	-- 临时手动
	Auto 	= 2,	-- 自动
}

function AutoFightManager:ctor()
	AutoFightManager.Instance = self
	self.is_auto_fight = false
	self.auto_state = AutoFightManager.AutoState.Stop
	self.auto_time =0
	self:Reset()
	self:AddEvent()
	
	UpdateBeat:Add(self.Update,self)
end

function AutoFightManager:Reset()
	self:Stop()
	self:StopTemTime()
	self.last_tem_time = Time.time
end

function AutoFightManager.GetInstance()
	if AutoFightManager.Instance == nil then
		AutoFightManager()
	end
	return AutoFightManager.Instance
end

function AutoFightManager:AddEvent()
	local function call_back(flag)
		if flag ~= nil and self.is_auto_fight ~= nil and flag ~= self.is_auto_fight then
			return
		end
		if self.is_auto_fight then
			self:Stop()
		else
			self:Start()
		end
	end
	self.event_id = GlobalEvent:AddListener(FightEvent.AutoFight, call_back)
	
	--切换场景开始
	local function call_back()
		if AutoFightManager:GetInstance():GetAutoFightState() then
			GlobalEvent:Brocast(FightEvent.AutoFight)
		end
	end
	GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)
	
	local function call_back()
		self:SetCurSceneInfo()
	end	
	GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function AutoFightManager:SetCurSceneInfo()
	self.scene_type = SceneConfigManager:GetInstance():GetSceneType()
	self.is_city_or_feild = self.scene_type == SceneConstant.SceneType.Feild or self.scene_type == SceneConstant.SceneType.City
	local scene_id = SceneManager:GetInstance():GetSceneId()
	self.scene_auto_fight = true
	local config = Config.db_scene[scene_id]
	if config then
		self.scene_auto_fight = config.bctype_front == 1
	end
	
	self.def_range = 1000
	if config and config.def_range then
		self.def_range = config.def_range
	end
	self.def_point = not self.is_city_or_feild and not self.scene_auto_fight
	
	self:ResetAutoPosition()
end

-- 内部调用
function AutoFightManager:Start(foce)
	if not foce then
		if self.is_auto_fight then
			return
		end
	else
		if self.is_auto_fight and self.auto_state == AutoFightManager.AutoState.Auto then
			return
		end
	end
	self.auto_time = AutoFightManager.CheckTime
	self.is_auto_fight = true
	self.auto_state = AutoFightManager.AutoState.Auto
	GlobalEvent:Brocast(FightEvent.StartAutoFight)
	self:SetAutoPosition()
end

-- 内部调用
function AutoFightManager:Stop()
	if not self.is_auto_fight then
		return
	end
	self.is_auto_fight = false
	self.auto_state = AutoFightManager.AutoState.Stop
	-- UpdateBeat:Remove(self.Update)
	self.auto_pos = nil
	GlobalEvent:Brocast(FightEvent.StopAutoFight)
end

function AutoFightManager:ResetAutoPosition()
	if self.auto_pos then
		self.auto_pos = nil
		self:SetAutoPosition()
	end
end

function AutoFightManager:SetAutoPosition(pos)
	SceneManager:GetInstance():CleanLockList()
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role then
		main_role:ClearHitList()
		main_role:ClearAttackList()
	end
	
	if pos then
		self.auto_pos = pos
		return
	end
	if not self.auto_pos then
		local pos = main_role and main_role:GetPosition()
		if pos then
			self.auto_pos = {x = pos.x , y = pos.y}
		end
	end
end

-- 外部调用
function AutoFightManager:StartAutoFight()
	-- 不在自动状态才需要开始自动战斗
	if not self.is_auto_fight then
		self:Start()
	end
end

-- 外部调用
function AutoFightManager:StopAutoFight()
	-- 在自动状态才能取消
	if self.is_auto_fight then
		self:Stop()
	end
end

function AutoFightManager:TemAutoFight(state)
	state = state or AutoFightManager.AutoState.Tem
	if state == AutoFightManager.AutoState.Tem then
		self:StartTemTime()
		self.last_tem_time = Time.time
		self.auto_pos = nil
	end
	if state and state == self.auto_state then
		return
	end
	if self.auto_state == AutoFightManager.AutoState.Tem and state == AutoFightManager.AutoState.Auto then
		Notify.ShowText("Return to automode")
	end
	if state == AutoFightManager.AutoState.Auto then
		self:SetAutoPosition()
	end
	self.auto_state = state
	GlobalEvent:Brocast(FightEvent.TemAutoFight)
end

function AutoFightManager:StartTemTime()
	self:StopTemTime()
	local function step()
		if self.auto_state == AutoFightManager.AutoState.Tem then
			self:TemAutoFight(AutoFightManager.AutoState.Auto)
		end
	end
	self.tem_time_id = GlobalSchedule:StartOnce(step,3.0)
end

function AutoFightManager:StopTemTime()
	if self.tem_time_id then
		GlobalSchedule:Stop(self.tem_time_id)
		self.tem_time_id = nil
	end
end

function AutoFightManager:GetAutoFightState()
	return self.is_auto_fight
end

--[[
@author LaoY
@des	获取自动挂机的对象列表
--]]
function AutoFightManager:GetAutoFightTargetList()
	-- local main_role = SceneManager:GetInstance():GetMainRole()
	-- local list = SkillManager:GetInstance():GetRangeTargetList(main_role,1000,0,enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
	-- return list
end

--[[
@author LaoY
@des	获取自动战斗的对象
--]]
function AutoFightManager:GetAutoFightTarget(skill_id,object_type_id)
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role then
		return
	end
	
	if skill_id then
		local skill_vo = SkillManager:GetInstance():GetSkillVo(skill_id)
		if not skill_vo then
			return
		end
		local target
		target = SkillManager:GetInstance():GetClientTarget(main_role,skill_vo,nil,object_type_id)
		if target then
			return target  
		end
		local _,target = SkillManager:GetInstance():GetSkillRushPos(main_role,skill_vo,nil,object_type_id)
		if target then
			return target  
		end
	end
end

--[[
@author LaoY
@des	自动战斗可以释放的技能
--]]
function AutoFightManager:GetAutoFightSkillID()
	local skill_id = SkillManager:GetInstance():GetNextSkill()
	if skill_id then
		return skill_id
	end
	local skill_id = SkillManager:GetInstance():GetNextOrdinarySkill()
	return skill_id
end

function AutoFightManager:Update(deltaTime)
	-- 临时手动不处理
	if self.auto_state == AutoFightManager.AutoState.Tem then
		return
	end
	-- 自动挂机 或者任务自动打怪要处理
	if not self.is_auto_fight and not AutoTaskManager:GetInstance():IsAutoFight() then
		return
	end
	
	-- 寻路过程不攻击
	local main_role = SceneManager:GetInstance():GetMainRole()
	if OperationManager:GetInstance():IsAutoWay() and
		(not self.def_point or not self.auto_pos or 
			(not OperationManager:GetInstance():IsSameTargetPos(self.auto_pos)) or 
			(main_role and Vector2.DistanceNotSqrt(main_role:GetPosition(),self.auto_pos) > self.def_range * self.def_range)) then
		-- self.auto_pos
		-- Yzprint('--LaoY AutoFightManager.lua,line 112-- data=',OperationManager:GetInstance():IsAutoWay())
		return
	end
	
	-- 切场景过程不处理自动战斗等
	-- 还有loading的情况也不处理
	if SceneManager:GetInstance():GetChangeSceneState() or LoadingCtrl:GetInstance().loadingPanel then
		return
	end
	
	SceneManager:GetInstance().last_check_lock_creep_time = os.clock()
	
	self.auto_time = self.auto_time + deltaTime
	if self.auto_time <= AutoFightManager.CheckTime then
		return
	end
	
	-- 不能攻击状态不执行自动挂机
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role or not main_role.object_info then
		return
	end
	
	if main_role then
		local bo,buff_effect_type = main_role.object_info:IsCanAttackByBuff()
		if not bo then
			return
		end
	end


	self.auto_time = self.auto_time%AutoFightManager.CheckTime
	if not main_role or main_role.is_death or 
		main_role:IsRushing() or 
		main_role:IsJumping() or 
		main_role:IsPickuping() or 
		main_role:IsCollecting() or 
		main_role.is_waiting_collect or 
		main_role.is_fly then
		return
	end
	
	-- 自动拾取掉落物
	local drop_object = SceneManager:GetInstance():GetDropInScreen()
	if drop_object then
		drop_object:OnClick(true)
		return
	end
	
	-- if not main_role:IsCanSwitchToAttack() then
	-- 	return
	-- end
	local action_info = main_role:GetCurStateInfo()
	if action_info and main_role:IsAttacking() then
		local action = main_role:GetCurStateInfo()
		local is_fuse =  action and action.skill_vo and action.skill_vo.fuse_time and action.pass_time >= action.skill_vo.fuse_time
		if not is_fuse and not main_role:IsCanPlayNextAttack() then
			return
		end
	end

	local skill_id = self:GetAutoFightSkillID()
	if not skill_id then
		return
	end

	-- 非主城野外 不是全场景广播 自动战斗不能超过警戒点一定范围
	if self.def_point and self.auto_pos then
		local main_role = SceneManager:GetInstance():GetMainRole()
		local cur_pos = main_role:GetPosition()
		if Vector2.DistanceNotSqrt(cur_pos,self.auto_pos) > self.def_range*self.def_range then
			OperationManager:GetInstance():TryMoveToPosition(nil,cur_pos,self.auto_pos,nil,1)
			return
		end
	end
	
	-- 任务打怪
	if AutoTaskManager:GetInstance():IsAutoFight() then
		local value,object_id = AutoTaskManager:GetInstance():GetTaskTargetID()
		if value then
			FightManager:GetInstance():LockFightTarget(object_id)
			GlobalEvent:Brocast(MainEvent.ReleaseSkill,skill_id,true)
			if object_id then
				return
			end
		elseif not self.is_auto_fight then
			return
		end
	end
	
	local lock_object
	local function GetLockObject()
		lock_object = SceneManager:GetInstance():GetObject(FightManager:GetInstance().client_lock_target_id)
		if not lock_object or lock_object:IsDeath() or not lock_object:IsCanBeAttack() or (self.is_city_or_feild and not MapLayer:GetInstance():IsInScreen(lock_object:GetPosition())) then
			lock_object = nil
		end
	end
	GetLockObject()
	
	if not lock_object then
		local object = main_role:GetHateObject()
		if object then
			lock_object = object
		end
	end
	
	if not lock_object then
		SceneManager:GetInstance():CheckLockCreep(true,self.scene_auto_fight)
		GetLockObject()
	end
	
	if self.def_point and lock_object and not lock_object:IsDeath() then
		if Vector2.DistanceNotSqrt(lock_object:GetPosition(),self.auto_pos) > self.def_range*self.def_range then
			SceneManager:GetInstance():CheckLockCreep(true,self.scene_auto_fight)
			GetLockObject()
		end
	end
	
	-- if not lock_object or lock_object:IsDeath() then
	-- 	lock_object = nil
	-- 	local def_range = nil
	-- 	if self.def_point then
	-- 		def_range = self.def_range
	-- 	end
	-- 	local object = SceneManager:GetInstance():GetCreepByTypeId(nil,def_range,enum.CREEP_KIND.CREEP_KIND_MONSTER,self.auto_pos)
	-- 	if object and not object:IsDeath() then
	-- 		FightManager:GetInstance():LockFightTarget(object.object_id)
	-- 		lock_object = object
	-- 	end
	-- end
	
	if main_role:IsInSafe() and lock_object and lock_object.__cname ~= "Monster" then
        return false
    end

	-- 自动打怪
	if lock_object then
		-- local lock_object = SceneManager:GetInstance():GetObject(FightManager:GetInstance().client_lock_target_id)
		-- if lock_object and not lock_object:IsDeath() then
		-- 	return
		-- end
		if (lock_object.__cname ~= "Monster" or lock_object.creep_kind ~= enum.CREEP_KIND.CREEP_KIND_COLLECT) then
			GlobalEvent:Brocast(MainEvent.ReleaseSkill,skill_id,true)
		else
			lock_object:OnClick()
		end
	end
	
	-- 非主城野外 不是全场景广播 自动战斗不能超过警戒点一定范围
	if self.def_point and self.auto_pos and not lock_object then
		local main_role = SceneManager:GetInstance():GetMainRole()
		local cur_pos = main_role:GetPosition()
		if Vector2.DistanceNotSqrt(cur_pos,self.auto_pos) > 20 * 20 then
			OperationManager:GetInstance():TryMoveToPosition(nil,cur_pos,self.auto_pos,nil,1)
			return
		end
	end
	
	-- 自动采集
	-- local collect_object = SceneManager:GetInstance():GetCollectObject()
	-- if collect_object then
	-- 	collect_object:OnClick()
	-- 	return
	-- end
	
	-- local skill_vo = SkillManager:GetInstance():GetSkillVo(skill_id)
	-- if not client_lock_target_id or not FightManager:GetInstance():IsCanAttackLockTarget(client_lock_target_id,skill_vo) then
	-- 	local target = self:GetAutoFightTarget(skill_id)
	-- 	if target then
	-- 		-- local target = self:GetAutoFightTarget(skill_id)
	-- 		FightManager:GetInstance():LockFightTarget(target.object_id)
	-- 	else
	-- 		return
	-- 	end
	-- end
end