-- 
-- @Author: LaoY
-- @Date:   2018-07-25 14:50:09
-- 

MainRole = MainRole or class("MainRole",Role)
local this = MainRole
function MainRole:ctor()
	self.load_level = Constant.LoadResLevel.Best
	
	local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObj)
	if scene_obj_layer then
		self.parent_transform:SetParent(scene_obj_layer)
	else
		logWarn("SceneObj is nil........................")
	end
	
	-- 最后一次攻击怪物、人物的时间
	self.last_attack_monster_time = 0
	self.last_attack_role_time = 0
	
	-- 最后一次收到怪物、人物攻击时间
	self.last_be_monster_hit_time = 0
	self.last_be_role_hit_time = 0
	
	-- 同步
	self.last_target_pos = {x=0,y=0}
	
	self.hate_list = {}
	self.attack_list = {}

	self.is_waiting_collect = false
end

function MainRole:dctor()
	self.hate_list = nil
	self.attack_list = nil
	if self.event_id_1 then
		GlobalEvent:RemoveListener(self.event_id_1)
		self.event_id_1 = nil
	end
	
	self:DelFlyUpEffect()
	self:DelFlyDownEffect()
end

function MainRole:InitData(uid)
	MainRole.super.InitData(self,uid)
	if self.object_info then
		self:AddUpdateEvent()
		self.name_container:SetName(self.object_info.name)
		self.move_speed = self.object_info.attr.speed
	end
end

function MainRole:RemoveListener()
	if self.role_update_list then
		self.object_info:RemoveTabListener(self.role_update_list)
	end
	self.role_update_list = {}
end

function MainRole:InitMachine()
	MainRole.super.InitMachine(self)
	local idle_func_list = {
		OnEnter = handler(self,self.IdleOnEnter),
		OnExit 	= handler(self,self.IdleOnExit),
		Update = handler(self,self.UpdateIdleState),
	}
	self:RegisterMachineState(SceneConstant.ActionName.idle,true,idle_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.ride,true,idle_func_list)
	
	local fly_func_list = {
		OnEnter = handler(self,self.FlyUpOnEnter),
		OnExit 	= handler(self,self.FlyUpOnExit),
		Update = handler(self,self.FlyUpdate),
		CheckOutFunc = function()
			return not self.is_fly
		end
	}
	self:RegisterMachineState(SceneConstant.ActionName.Fly1,false,fly_func_list)
	
	local fly_func_list = {
		OnEnter = handler(self,self.FlyDownOnEnter),
		OnExit 	= handler(self,self.FlyDownOnExit),
		Update = handler(self,self.FlyUpdate),
		CheckOutFunc = function()
			return not self.is_fly
		end
	}
	self:RegisterMachineState(SceneConstant.ActionName.Fly2,false,fly_func_list)
	
	-- 重新注册跑步状态 有某些debuf不能移动
	local run_func_list = {
		OnEnter = handler(self, self.RunOnEnter),
		OnExit = handler(self, self.RunOnExit),
		Update = handler(self, self.UpdateRunState),
		CheckInFunc = handler(self,self.IsCanSwitchToMove),
	}
	self:RegisterMachineState(SceneConstant.ActionName.run, true, run_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.riderun, true, run_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.run2, true, run_func_list)
end

-- function MainRole:SetNameColor()
-- 	self.name_container:SetColor(Color.blue,Color.black)
-- end

function MainRole:AddEvent()
	MainRole.super.AddEvent(self)
	
	self.event_id_list = self.event_id_list or {}
	-- local function call_back()
	-- 	-- 切换完场景，主角强制设置到服务端的目标点
	-- 	local sceneMgr = SceneManager:GetInstance()
	-- 	self:SetPosition(sceneMgr.scene_info_data.coord.x,sceneMgr.scene_info_data.coord.y)
	-- end
	-- self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
	
	local function call_back()
		self:ChangeToMachineDefalutState()
		self.last_block_pos.x = -1
		self.last_block_pos.y = -1
		self.block_pos.x = -1
		self.block_pos.y = -1
	end
	self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)

	local function call_back()
		self:SetTargetEffect("effect_Levelup",false)
		SoundManager:GetInstance():PlayById(52)
	end
	self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.ChangeLevel, call_back)
	
	-- local function call_back()
	-- 	self:SetTargetEffect("effect_ui_wanchengrenwu",false)
	-- end
	-- self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(TaskEvent.FinishTask, call_back)
	
	local function call_back()
		if not self.object_id then
			local uid = RoleInfoModel:GetInstance():GetMainRoleId()
			self:InitData(uid)
		end
	end
	if not self.roleinfo_model_event_1 then
		self.roleinfo_model_event_1 = RoleInfoModel:GetInstance():AddListener(RoleInfoEvent.ReceiveRoleInfo,call_back)
	end
end

function MainRole:AddUpdateEvent()
	if not table.isempty(self.role_update_list) then
		return
	end
	self.role_update_list = {}
	local function call_back()
		self:SetPosition(self.object_info.coord.x,self.object_info.coord.y)
	end
	-- self.role_update_list[#self.role_update_list+1] = self.object_info:BindData("coord",call_back)
	
	local function call_back()
		self:SetTargetEffect("effect_Levelup",false)
		SoundManager:GetInstance():PlayById(52)
	end
	-- self.role_update_list[#self.role_update_list+1] = self.object_info:BindData("level",call_back)
end

function MainRole:LoadBodyCallBack()
	MainRole.super.LoadBodyCallBack(self)
	-- 如果在移动要重置
	if self.move_pos then
		local move_pos = self.move_pos
		self.move_pos = nil
		self:SetMovePosition(move_pos)
	end
end

-- function MainRole:Attack()
-- 	self:ChangeMachineState(SceneConstant.ActionName.attack)
-- end

function MainRole:Update(delta_time)
	MainRole.super.Update(self,delta_time)
	self:TrySynchronousPosition()
	self:TrySynchronousTargetPosition()
	
	if not self.last_check_hate_time or Time.time - self.last_check_hate_time > 1.0 then
		self:GetHateObject(nil,true)
	end

	self:CheckMainRoleRunStop()
end

-- 主角原地跑步
function MainRole:CheckMainRoleRunStop()
	-- 没有在跑步或者摇杆不处理
	if not self.is_runing or Rocker.IsRocking then
	-- if not self.is_runing then
		self.last_main_role_pos_time = Time.time
		return
	end

	if not self.last_main_role_pos then
		self.last_main_role_pos = pos(-1,-1)
	end

	local main_position = self.position
	if self.last_main_role_pos_time and self.last_main_role_pos and Vector2.DistanceNotSqrt(self.last_main_role_pos,main_position) <= 1e-5 then
		if Time.time - self.last_main_role_pos_time > 1.0 then
			if AppConfig.Debug then
				if OperationManager:GetInstance():IsAutoWay() then
					local end_pos = OperationManager:GetInstance().move_operation.end_pos or pos(0,0)
					logError(string.format("打印输出，非摇杆状态下，寻路状态原地跑动1秒，坐标：%s,%s,寻路坐标:%s,%s",self.position.x,self.position.y,end_pos.x,end_pos.y))
				else
					logError(string.format("打印输出，非摇杆状态下，原地跑动1秒，坐标：%s,%s",self.position.x,self.position.y))
				end
			end
			self.last_main_role_pos_time = Time.time
			self:SetMovePosition(nil)
			if OperationManager:GetInstance():IsAutoWay() then
				OperationManager:GetInstance():RestartAStar()
			end
			return
		end
	else
		self.last_main_role_pos_time = Time.time
	end

	self.last_main_role_pos.x = main_position.x
	self.last_main_role_pos.y = main_position.y
end

function MainRole:SetLastSynchronousePos(pos)
	self.last_syn_pos_time = Time.time
	if not self.last_syn_pos then
		self.last_syn_pos = {x = pos.x,y = pos.y}
	else
		self.last_syn_pos.x = pos.x
		self.last_syn_pos.y = pos.y
	end
end

--[[
@author LaoY
@des	同步坐标点
@param  force 战斗同步
--]]
function MainRole:TrySynchronousPosition(force)
	if SceneManager:GetInstance():GetChangeSceneState() then
		return
	end
	if not self.position then
		return
	end
	local x,y = self.position.x,self.position.y
	local cur_time = Time.time
	-- 不发同步包 冲刺、跳跃
	if self:IsRushing() or self:IsJumping() or self:IsCollecting() then
		self.last_syn_pos_time = cur_time
		self:SetLastSynchronousePos(self.position)
		return
	end
	if x == 0 or y == 0 then
		return
	end
	local diff_pos_dis = self.last_syn_pos and Vector2.DistanceNotSqrt(self.position,self.last_syn_pos) or 0
	if self.last_syn_pos and diff_pos_dis <= 1*1 then
		return
	end
	-- 每隔1.0秒
	-- 每移动240像素 同步一次
	local off_time = 0.5
	local off_distance = 200
	if force then
		off_distance = 10
	end
	off_distance = off_distance * off_distance
	if (self.last_syn_pos_time and cur_time - self.last_syn_pos_time < off_time) and
		(self.last_syn_pos and diff_pos_dis < off_distance) and (self.last_syb_target_state == self.move_state) then
		return
	end
	GlobalEvent:Brocast(SceneEvent.RequestMove,x,y)
	self.last_syb_target_state = self.move_state
	self.last_syn_pos_time = cur_time
	self.last_syn_pos = {x = x,y = y}
end

function MainRole:SetDirection(vec,is_move)
	-- if not vec and self.move_state then
	-- 	self:TrySynchronousTargetPosition(SceneConstant.SynchronousType.Stop,self.position)
	-- end
	MainRole.super.SetDirection(self,vec,is_move)
end

--[[
@author LaoY
@des	同步目标点
--]]
function MainRole:TrySynchronousTargetPosition(syn_state,syn_pos)
	local cur_time = Time.time
	-- 冲刺阶段不同步
	if self:IsRushing() or self:IsJumping() or self:IsCollecting() then
		self.last_target_pos.x = self.position.x
		self.last_target_pos.y = self.position.y
		self.last_syn_target_pos_time = cur_time
		return
	end

	-- 方向没变
	-- 离上次发的时间太近
	-- 自身坐标没变
	self.last_syn_target_pos_time = self.last_syn_target_pos_time or cur_time - 0.1
	local last_time = cur_time - self.last_syn_target_pos_time
	self.last_target_vec = self.last_target_vec or {x = self.direction.x,y = self.direction.y}
	local is_same_dir = (self.last_target_vec and self.last_target_vec.x == self.direction.x and  self.last_target_vec.y == self.direction.y)
	
	local syn_time = 0.3
	
	local target_x,target_y
	local state
	local debug_x = 0
	local debug_x_time = 0
	if syn_state then
		target_x = syn_pos.x
		target_y = syn_pos.y
		state = syn_state
	elseif self.move_pos then
		target_x = self.move_pos.x
		target_y = self.move_pos.y
		state = SceneConstant.SynchronousType.Move
	elseif not self.move_state then
		target_x = self.position.x
		target_y = self.position.y
		state = SceneConstant.SynchronousType.Stop
	else
		if self.direction.x * self.direction.x + self.direction.y*self.direction.y <=1e-5 then
			return
		end
		local rocker_syn_time = syn_time * 1.2
		target_x = self.position.x + self.direction.x * self.move_speed * rocker_syn_time
		target_y = self.position.y + self.direction.y * self.move_speed * rocker_syn_time
		state = SceneConstant.SynchronousType.Rocker
	end

	-- if Vector2.DistanceNotSqrt(Vector2(target_x,target_y),self.position) < 1e-5 and self.all_rotate_off then
	-- 	return
	-- end

	-- local dis_not_sqrt = Vector2.DistanceNotSqrt(Vector2(target_x,target_y),self.last_target_pos)
	local dis_not_sqrt = (self.last_target_pos.x - target_x) ^ 2 + (self.last_target_pos.y - target_y) ^ 2
	if dis_not_sqrt < 1e-5 and is_same_dir then
		return
	end
	if (last_time < syn_time) then
		-- if not is_same_dir and (dis_not_sqrt  > 30*30 or last_time > 0.1 or (self.move_pos and self.move_state)) then
		-- 方向变换要发包
		-- 摇杆改变方向0.1秒才发包
		-- if not is_same_dir and (last_time > 0.1 or (self.move_pos and self.move_state)) then
		if self.last_target_state ~= state then
		-- elseif not is_same_dir and (last_time > 0.1 or (self.move_pos and self.move_state)) then
		elseif not is_same_dir then
			-- 停下来一定发包
		elseif self.last_syb_target_state ~= nil and self.last_syb_target_state ~= self.move_state then
		else
			return
		end
	end
	
	
	self.last_target_vec = self.last_target_vec or {x=0,y=0}
	self.last_target_vec.x = self.direction.x
	self.last_target_vec.y = self.direction.y
	
	self.last_syb_target_state = self.move_state
	
	self.last_syn_target_pos_time = cur_time
	self.last_target_pos.x = target_x
	self.last_target_pos.y = target_y

	self.last_target_state = state
	GlobalEvent:Brocast(SceneEvent.RequestDest,target_x,target_y,self.angele,state)
end

--[[
@author LaoY
@des	是否可以切换到攻击状态
@条件	
如果在施法状态，是否可以打断施法
其他状态是否可以打断
--]]
function MainRole:IsCanSwitchToAttack(skill_vo)
	return MainRole.super.IsCanSwitchToAttack(self,skill_vo)
end

--[[
@author LaoY
@des	是否可以切换到移动状态
@条件	
如果在施法状态，是否可以打断施法
其他状态是否可以打断
--]]
function MainRole:IsCanSwitchToMove()
	-- 220210001
	local bo = self.object_info:IsCanMoveByBuff()
	if not bo then
		return false
	end
	return MainRole.super.IsCanSwitchToMove(self)
end

function MainRole:PlayRush(rush_pos, callback,is_fly)
	if MainRole.super.PlayRush(self,rush_pos, callback,is_fly) and self.rush_pos then
		local  scene_data = SceneManager:GetInstance():GetSceneInfo()
		if  ArenaModel:GetInstance():IsArenaFight(scene_data.scene) then
			return
		end
		if not is_fly then
			GlobalEvent:Brocast(SceneEvent.RequestRush,self.rush_pos.x,self.rush_pos.y)
		end
	end
end

function MainRole:PlayJump(pos,jump_type,is_continuous_jump,is_fly,callback)
	if self.is_fly then
		return
	end
	
	jump_type = jump_type or SceneConstant.JumpType.Ordinary
	if MainRole.super.PlayJump(self,pos,jump_type,is_continuous_jump,is_fly,callback) then
		-- local move_operation = OperationManager:GetInstance().move_operation
		-- if move_operation then
		-- 	move_operation:MainRoleJump(self.jump_pos)
		-- end
		if (not is_continuous_jump or jump_type == SceneConstant.JumpType.Ordinary) and not is_fly then
			GlobalEvent:Brocast(SceneEvent.RequestJump,self.position,pos or self.jump_pos,jump_type)
		end
		-- if jump_type == SceneConstant.JumpType.Ordinary then
		-- 	GlobalEvent:Brocast(SceneEvent.RequestJump,self.position,self.jump_pos,jump_type)
		-- else
		-- 	GlobalEvent:Brocast(SceneEvent.RequestJump,self.position,self.jump_pos,jump_type)
		-- end
		if self.jump_count == 1 then
			local target_pos = pos
			if not pos and jump_type == 0 then
				target_pos = self.jump_pos
			elseif jump_type > 0 then
				local scene_id = SceneManager:GetInstance():GetSceneId()
				local config = JumpConfig[scene_id]
				config = config and config[jump_type]
				if config and config[#config] then
					target_pos = config[#config].end_pos
				end
			end
			OperationManager:GetInstance():JumpEnd(target_pos,jump_type > 0)
		end
	end
end

function MainRole:JumpOnExit(action_name,last_state_name)
	MainRole.super.JumpOnExit(self,action_name,last_state_name)
	-- 跳跃点寻路后要合并跳跃路径
	-- OperationManager:GetInstance():JumpEnd()
end

function MainRole:PlayCollect(info)
	if table.isempty(info) then
		return
	end
	if MainRole.super.PlayCollect(self,info) then
		self:TrySynchronousPosition(true)
		-- Yzprint('--%%%^56&^*&*(&(*&*(&(*&*(&*(&*(&(*--\n\n\n\n',data)
		GlobalEvent:Brocast(FightEvent.StartPickUp,info.target_id,info.action_time)

		local object = SceneManager:GetInstance():GetObject(info.target_id)
		if object then
			object.is_collecting = true
			object:BeLock(true)
		end
	end
end

function MainRole:CollectOnExit(action_name)
	MainRole.super.CollectOnExit(self,action_name)
	GlobalEvent:Brocast(FightEvent.EndPickUp)
	local action = self.action_list[action_name]
	local object = SceneManager:GetInstance():GetObject(action.target_id)
	if object then
		object.is_collecting = false
		if FactionSerWarModel:GetInstance():IsFactionSerMap() then
			return
		end
		object:BeLock(false)
	end
end

function MainRole:CollectUpdate(action_name,delta_time)
	MainRole.super.CollectUpdate(self,action_name)
	local action = self.action_list[action_name]
	local object = SceneManager:GetInstance():GetObject(action.target_id)
	if not object or object.is_dctored then
		self:ChangeToMachineDefalutState()
		return
	end
	GlobalEvent:Brocast(FightEvent.UpdatePickUp,action.total_time)
	-- Yzprint('--&&&&&***((((()))__+++&&%$$####--\n\n\n\n',data)
	if action.collect_time and action.total_time >= action.collect_time then
		self:ChangeToMachineDefalutState()
	end
end

function MainRole:DeathOnExit()
	MainRole.super.DeathOnExit(self)
	-- 死亡原地复活
	--SceneManager:GetInstance():ReviveTip()
end

function MainRole:SetPosition(x,y)
	local last_is_in_safe = self.is_in_safe
	local bo = MainRole.super.SetPosition(self, x, y)
	if last_is_in_safe ~= nil and self.is_in_safe ~= last_is_in_safe then
		local str = self.is_in_safe and "Enter Safe Zone" or "Leave Safe Zone"
		Notify.ShowText(str)
	end
	return bo
end

function MainRole:CheckNextBlock(x,y)
	local bo,block_value = MainRole.super.CheckNextBlock(self,x,y)
	-- 走进跳跃路径了
	if block_value and not self:IsJumping() and self:IsCurBlockContain(SceneConstant.MaskBitList.JumpPath,block_value) then
		--print(self:IsCurBlockContain(SceneConstant.MaskBitList.JumpPath))
		--print(self.block_pos.x,self.block_pos.y)
		local jump_point = SceneManager:GetInstance():GetJumpPointInfo(self.position,200*200)
		if jump_point then
			self:PlayJump(jump_point.target_coord,jump_point.id)
		else
			local end_pos = self.direction * SceneConstant.JumpDis[1]
			end_pos.x = end_pos.x + self.position.x
			end_pos.y = end_pos.y + self.position.y
			local bo,x,y = OperationManager:GetInstance():GetFarest(self.position,end_pos)
			if bo then
				local mask = OperationManager:GetInstance():GetMask(x,y)
				if mask ~= true and self:IsCurBlockContain(SceneConstant.MaskBitList.JumpPath,mask) then
					return
				end
				end_pos = {x=x,y=y}
				self:PlayJump(end_pos)
			end
		end
		return false,block_value
	end

	-- 摇杆移动
	if not bo and self.move_state and not self.move_pos then
		self:TrySynchronousTargetPosition(SceneConstant.SynchronousType.Rocker,self.position)
	end

	return bo,block_value
end

-- function MainRole:IsCorssBlock()
-- 	return MainRole.super.IsCorssBlock(self) 
-- 	or OperationManager:GetInstance():IsAutoWay()
-- end

-- function MainRole:RunOnExit()
-- 	SceneManager:GetInstance():CheckMainRoleStop(self.position.x,self.position.y)
-- end

function MainRole:IdleOnEnter(state_name)
	MainRole.super.IdleOnEnter(self,state_name)
	local action = self.action_list[state_name]
	action.check_time = 0
end

function MainRole:IdleOnExit()
	-- self.is_had_check_pos_is_door = false
	self:SetPickupingState(false)
end

function MainRole:UpdateIdleState(state_name,delta_time)
	if self.is_pickuping then
		return
	end
	local action = self.action_list[state_name]
	if action.total_time - action.check_time > SceneConstant.StopCheckTime then
		action.check_time = action.total_time
		SceneManager:GetInstance():CheckMainRoleStop()
		-- self.is_had_check_pos_is_door = true
	end
end

function MainRole:SetMovePosition(pos)
	if self.is_riding_up then
		local action = self.action_list[self.cur_state_name]
		action.move_pos = pos
		self.move_pos = pos
	else
		MainRole.super.SetMovePosition(self,pos)
	end
end

function MainRole:UpdateRunState(action_name,delta_time)
	MainRole.super.UpdateRunState(self,action_name,delta_time)
	if action_name == SceneConstant.ActionName.run then
		-- SoundManager:GetInstance():RunEff(self:IsRiding())
		-- 改为只有正常跑步才有声音
		SoundManager:GetInstance():RunEff()
	end
	local action = self.action_list[action_name]
	if self:IsCanAutoPlayMount() and action.total_time > 3.0 and not self:IsRiding() and FightManager:GetInstance():IsInFightNULLState() then
		local call_back
		local move_pos = self.move_pos
		local move_dir = self.move_dir
		if move_pos ~= nil then
			call_back = function()
				self:SetMovePosition(move_pos,move_dir)
			end
		end
		self:PlayMount(call_back,true,move_pos)
	end
	if self:IsRiding() and (not self.last_play_mount_effect_time or os.clock() - self.last_play_mount_effect_time >= 400) then
		self.last_play_mount_effect_time = os.clock()
		EffectManager:GetInstance():PlayPositionEffect("effect_zuoqixingzouyanwu",self.position)
	end
end

function MainRole:IsCanAutoPlayMount()
	local open_cf = OpenConfig["130@1"]
	if open_cf and self.object_info.level < open_cf.level + 1 then
		return false
	end
	return true
end

function MainRole:IsPickuping()
	return self.is_pickuping
end

function MainRole:SetPickupingState(flag)
	self.is_pickuping = flag
end

-- 点击上坐骑
function MainRole:OnClickPlayMount()
	local is_can_mount = SceneConfigManager:GetInstance():GetSceneCanPlayMount()
	if not is_can_mount then
		Notify.ShowText("You can't mount in this scene");
		return
	end
	if not self:IsRiding() then
		local move_pos = self.move_pos
		local move_dir = self.move_dir
		if not self.move_state then
			move_pos = nil
		end
		local call_back
		if move_pos ~= nil then
			call_back = function()
				self:SetMovePosition(move_pos,move_dir)
			end
		end
		self:PlayMount(call_back,self.is_runing,move_pos)
	end
end

function MainRole:PlayMount(...)
	if not FightManager:GetInstance():IsInFightNULLState() and not OperationManager:GetInstance():IsAutoWay() then
		Notify.ShowText("Can't mount while battling")
		return
	end
	local bo = MainRole.super.PlayMount(self,...)
	-- if bo then--不上坐骑直接注释这里
	-- 	GlobalEvent:Brocast(SceneEvent.ChangeMount,true)
	-- 	if not self:GetEscortMountID() and self.object_info.figure.mount and self.object_info.figure.mount.model ~= 0 and not self.object_info.figure.mount.show then
	-- 		MountCtrl:GetInstance():RequestMountRide(1)
	-- 	end
	-- end
end

function MainRole:LoadMount()
	MainRole.super.LoadMount(self)
	GlobalEvent:Brocast(SceneEvent.ChangeMount,true)
	if not self:GetEscortMountID() and self.object_info.figure.mount and self.object_info.figure.mount.model ~= 0 and not self.object_info.figure.mount.show then
		MountCtrl:GetInstance():RequestMountRide(1)
	end
end

function MainRole:RemoveMount(delay_time,is_ignore_syn)
	local is_riding = self:IsRiding()
	local boneName = SceneConstant.BoneNode.Ride_Root
	local horse_info = self.boneObject_list[boneName]
	local bo = MainRole.super.RemoveMount(self,delay_time,is_ignore_syn)
	if is_riding then
		Yzprint('--LaoY MainRole.lua,line 549--',bo,Time.time,is_riding,self:IsRiding(),self:GetEscortMountID(),horse_info)
		Yzdump(self.object_info.figure,"self.object_info.figure")
		traceback()
	end
	if bo then
		GlobalEvent:Brocast(SceneEvent.ChangeMount,false)
		if not self:GetEscortMountID() and self.object_info.figure.mount and self.object_info.figure.mount.model ~= 0 and self.object_info.figure.mount.show and not is_ignore_syn then
			MountCtrl:GetInstance():RequestMountRide(2)
			-- 后端如果不返回，下次上坐骑也不会请求
			-- 重置一下状态
			self.object_info.figure.mount.show = false
		end
	end
end

-- 攻击
function MainRole:SignAttack(object)
	if object.__cname == "Role" then
		self.last_attack_role_time = os.clock()
	elseif object.__cname == "Monster" then
		self.last_attack_monster_time = os.clock()
	end
	self.attack_list[object.object_id] = true
	Yzprint('--LaoY MainRole.lua,line 563--',data)
	
	self:CheckSignAttackList()
end

function MainRole:ClearAttackList()
	self.attack_list = {}
end

function MainRole:CheckSignAttackList()
	if self.last_sign_attck_tiem and Time.time - self.last_sign_attck_tiem < 3.0 then
		return
	end
	self.last_sign_attck_tiem = Time.time
	local del = {}
	for object_id,value in pairs(self.attack_list) do
		local object = SceneManager:GetInstance():GetObject(object_id)
		if not object or object.is_dctored or object:IsDeath() then
			del[#del+1] = object_id
		end
	end
	
	for k,object_id in pairs(del) do
		self.attack_list[object_id] = nil
	end
end


-- 受击
function MainRole:SignBeHit(attack,value)
	if attack.__cname == "Role" then
		self.last_be_role_hit_time = os.clock()
	elseif attack.__cname == "Monster" then
		self.last_be_monster_hit_time = os.clock()
	end
	
	self.hate_list[attack.object_id] = self.hate_list[attack.object_id] or 0
	self.hate_list[attack.object_id] = self.hate_list[attack.object_id] + value
end

function MainRole:ClearHitList()
	self.hate_list = {}
end

-- 怪物的仇恨列表
function MainRole:GetHateObject(object_type,is_del)
	self.last_check_hate_time = Time.time
	if table.isempty(self.hate_list) then
		return
	end
	local monster_list = {}
	local role_list = {}
	local del = {}
	local attact_range_square = SceneConstant.AttactDis * SceneConstant.AttactDis
	local role_rush_range = self.body_size.width * 0.5 + SceneConstant.AttactDis + SceneConstant.RushDis
	local role_rush_range_square = role_rush_range * role_rush_range
	for object_id,value in pairs(self.hate_list) do
		local object = SceneManager:GetInstance():GetObject(object_id)
		if not object or object.is_dctored or object:IsDeath() then
			del[#del+1] = object_id
		elseif object.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
			if Vector2.DistanceNotSqrt(object.position,self.position) > attact_range_square + (object.body_size.width * 0.5) * (object.body_size.width * 0.5) then
				del[#del+1] = object_id
			else
				if not is_del and object:IsCanBeAttack() then
					monster_list[#monster_list+1] = {id = object_id,value = value}
				end
			end
		else
			if Vector2.DistanceNotSqrt(object.position,self.position) > role_rush_range_square then
				del[#del+1] = object_id
			else
				if not is_del and object:IsCanBeAttack() then
					role_list[#role_list+1] = {id = object_id,value = value}
				end
			end
		end
	end
	
	for k,object_id in pairs(del) do
		self.hate_list[object_id] = nil
	end
	
	if is_del then
		return
	end
	
	local function sortFunc(a,b)
		if a.value == b.value then
			return a.id < b.id
		else
			return a.value > b.value
		end
	end
	
	table.sort(role_list,sortFunc)
	if role_list[1] then
		return SceneManager:GetInstance():GetObject(role_list[1].id)
	end
	
	table.sort(monster_list,sortFunc)
	if monster_list[1] then
		return SceneManager:GetInstance():GetObject(monster_list[1].id)
	end
end

-- 小飞鞋 上升
function MainRole:PlayFlyUp(callback)
	if self:IsDeath() then
		if callback then
			callback()
		end
		return
	end
	self:ChangeToMachineDefalutState()
	local action_name = SceneConstant.ActionName.Fly1
	local bo = self:ChangeMachineState(action_name,true)
	Yzprint('--LaoY MainRole.lua,line 688--',Time.time)
	traceback()
	if not bo then
		return
	end
	-- self:RemoveMount(nil,true)
	self:RemoveMount()
	local action = self.action_list[action_name]
	action.on_exit_call_back = callback
	-- action.action_call_back = function()
	-- 	self:ShowBody(false)
	-- 	action.on_exit_call_back = nil
	-- 	Yzprint('--LaoY MainRole.lua,line 701--',Time.time)
	-- 	local function step()
	-- 		self:ChangeToMachineDefalutState()
	-- 		if callback then
	-- 			callback()
	-- 		end
	-- 	end
	-- 	GlobalSchedule:StartOnce(step,SceneConstant.FlyDelayTime.Up)
	-- end
end

function MainRole:IsFlying()
	return self.is_fly
end

-- 小飞鞋 下落
function MainRole:PlayFlyDown(callback)
	if self:IsDeath() then
		self:ShowBody(true)
		if callback then
			callback()
		end
		return
	end
	Yzprint('--LaoY MainRole.lua,line 715--',Time.time)
	traceback()
	self:ChangeToMachineDefalutState()
	local function step()
		self.is_fly = false
		self:PlayFlyDownT(callback)
	end
	self.is_fly = true
	if not self.isShowBody then
		GlobalSchedule:StartOnce(step,SceneConstant.FlyDelayTime.Down)
	else
		step()
	end
end

function MainRole:PlayFlyDownT(callback)
	self:ShowBody(true)
	if self:IsDeath() then
		if callback then
			callback()
		end
		return
	end
	
	local action_name = SceneConstant.ActionName.Fly2
	if not self:ChangeMachineState(action_name,true) then
		return
	end
	-- self:RemoveMount(nil,true)
	self:RemoveMount()
	local action = self.action_list[action_name]
	action.on_exit_call_back = callback
	action.action_call_back = function()
		self.is_fly = false
		-- self:ChangeSceneCheckMount()
		self:ShowBody(true)
		if self.cur_state_name == SceneConstant.ActionName.Fly2 then
			self:ChangeToMachineDefalutState()
		end
	end
end

function MainRole:AddFlyUpEffect()
	if not self.fly_up_effect then
		local root_name = SceneConstant.BoneNode.Root
		self.fly_up_effect = self:SetTargetEffect("effect_chuansong",false,nil)
	end
end

function MainRole:DelFlyUpEffect()
	if self.fly_up_effect then
		self.fly_up_effect:destroy()
		self.fly_up_effect = nil
	end
end

function MainRole:FlyUpOnEnter()
	self.is_fly = true
	self:AddFlyUpEffect()
end

function MainRole:FlyUpOnExit(action_name)
	self.is_fly = false
	self:DelFlyUpEffect()
	self:ShowBody(false)
	
	local action = self.action_list[action_name]
	local function step()
		self:ChangeToMachineDefalutState()
		if action.on_exit_call_back then
			action.on_exit_call_back()
			action.on_exit_call_back = nil
		end
	end
	if action.action_time and action.pass_time >= action.action_time then
		GlobalSchedule:StartOnce(step,SceneConstant.FlyDelayTime.Up)
	else
		step()
	end
	Yzprint('--LaoY MainRole.lua,line 783--',Time.time)
end

function MainRole:FlyUpdate(state_name, delta_time)
end

function MainRole:AddFlyDownEffect()
	if not self.fly_down_effect then
		local root_name = SceneConstant.BoneNode.Root
		-- local root_node = self:GetBoneNode(root_name)
		self.fly_down_effect = self:SetTargetEffect("effect_chuansong_wangxia",false,nil)
	end
end

function MainRole:DelFlyDownEffect()
	if self.fly_down_effect then
		self.fly_down_effect:destroy()
		self.fly_down_effect = nil
	end
end

function MainRole:FlyDownOnEnter()
	self.is_fly = true
	self:AddFlyDownEffect()
end

function MainRole:FlyDownOnExit(action_name)
	self.is_fly = false
	self:DelFlyDownEffect()
	
	local action = self.action_list[action_name]
	if action.on_exit_call_back then
		action.on_exit_call_back()
		action.on_exit_call_back = nil
	end
	
	self:ShowBody(true)

	self:StartSetNameContainerPos()

	if self.fly_down_on_exit_call_back then
		self.fly_down_on_exit_call_back(action_name)
	end
end

function MainRole:PlayDeath(...)
	if MainRole.super.PlayDeath(self,...) then
		OperationManager:GetInstance():StopAStarMove()
		FightManager:GetInstance():UnLockFightTarget()
	end
end

function MainRole:Revive(...)
	MainRole.super.Revive(self,...)
	if AutoFightManager:GetInstance().auto_state ~= AutoFightManager.AutoState.Tem and AutoFightManager:GetInstance():GetAutoFightState() then
		AutoFightManager:GetInstance():ResetAutoPosition()
	end
end

function MainRole:PlayAttack(skill_vo)
	local release_control = false
	if skill_vo then
		release_control = SkillManager:GetInstance():IsReleaseDebuffSkill(skill_vo.skill_id)
	end
	local bo,buff_effect_type = self.object_info:IsCanAttackByBuff()
	if not bo and not release_control then
		return false
	end
	local bo = MainRole.super.PlayAttack(self,skill_vo)
	Yzprint('--LaoY MainRole.lua,line 745--',bo)
	return bo
end

-- 不能移动buff 提示
function MainRole:MoveDebuffTip(buff_effect_type,move_type)
	move_type = move_type or ""
	if self.last_move_debuff_tip_time and Time.time - self.last_move_debuff_tip_time <= 1.0 then
		return
	end
	local name = enumName.BUFF_EFFECT[buff_effect_type]
	if name then
		local str = string.format("Current处于%sStatus，None法%s",name,move_type)
		if PeakArenaModel:GetInstance():Is1v1Fight() then
			str = "战斗未开始，None法移动"
		end
		Notify.ShowText(str)
		self.last_move_debuff_tip_time = Time.time
	end
end

-- 不能攻击buff 提示
function MainRole:AttackDebuffTip(buff_effect_type)
	if self.last_attack_debuff_tip_time and Time.time - self.last_attack_debuff_tip_time <= 1.0 then
		return
	end
	local name = enumName.BUFF_EFFECT[buff_effect_type]
	if name then
		self.last_attack_debuff_tip_time = Time.time
		local str = string.format("Current处于%sStatus，None法UseATK",name)
		Notify.ShowText(str)
	end
end

function MainRole:IsCanBeAttack()
	return false
end

function MainRole:OnEnterMachineState(state_name)
	MainRole.super.OnEnterMachineState(self,state_name)
	-- self:ShowBody(true)
end

local function isFightRole(tab)
	if not tab then
		return false
	end
	local object
	for object_id,v in pairs(tab) do
		object = SceneManager:GetInstance():GetObject(object_id)
		if object and object.__cname ~= "Monster" then
			return true
		end
	end
	return false
end

function MainRole:IsFightRole()
	if not self:IsAttacking() then
		return false
	end

	local is_attack_role = isFightRole(self.attack_list)
	if is_attack_role then
		return true
	end

	local is_be_attack_by_role = isFightRole(self.hate_list)
	return is_be_attack_by_role
end

function MainRole:ShowBody(flag)
	-- Yzprint('--LaoY MainRole.lua,line 882--',flag,Time.time)
	-- traceback()
	MainRole.super.ShowBody(self,flag)
end

function MainRole:IsCanOClick()
	return false
end


-- 主角自己不需要处理
function MainRole:UpdateDance()
end

local buff_id = 130150018
function MainRole:DanceOnEnter(state_name)
    MainRole.super.DanceOnEnter(self,state_name)
    SceneControler:GetInstance():RequestAddBuff(buff_id)
    GlobalEvent:Brocast(SceneEvent.MainRoleMachineStateUpdate,state_name,true)
end
function MainRole:DanceOnExit(state_name)
    MainRole.super.DanceOnExit(self,state_name)
    SceneControler:GetInstance():RequestDelBuff(buff_id)
    GlobalEvent:Brocast(SceneEvent.MainRoleMachineStateUpdate,state_name,false)
end

function MainRole:SetRateScale(rate)
	local scale = (self.scale or 1) * rate
	if self.transform then
		SetLocalScale(self.transform, scale, scale, scale)
	end
end