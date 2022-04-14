-- 
-- @Author: LaoY
-- @Date:   2018-09-04 20:58:17
-- 

OperationMove = OperationMove or class("OperationMove")
local OperationMove = OperationMove

function OperationMove:ctor()
	self:Clean()
	self:AddEvent()
end

function OperationMove:dctor()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function OperationMove:AddEvent()
	self.global_event_list = self.global_event_list or {}
	local function call_back()
		self:CreateMainRole()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(SceneEvent.CreateMainRole, call_back)
	call_back()
	
	local function call_back()
		--self:RestartAStar()
		-- self:RestartAStar()
		if self.is_check_scene_change and self.is_auto_way then
			
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function OperationMove:CreateMainRole()
	if not self.main_role then
		self.main_role = SceneManager:GetInstance():GetMainRole()
	end
end

function OperationMove:Clean()
	self.last_way 	= nil
	self.cur_pos 	= nil
	self.check_time = 0
	self.last_check_time = 0
	self.last_time = 0
	self.cur_pass_time = 0
	self.cur_total_time = 0
	self.total_pass_time = 0
	
	self.scene_info = nil
	self.start_pos 	= nil
	self.end_pos 	= nil
	self.callback 	= nil
	self.path 		= nil
	self.cur_way 	= nil
	self.is_last_way = false
	self.is_auto_way	= false
	
	self.last_state_is_jump = false
	self.jump_restart_astar = false
	
	self.is_pause = false
	
	self.fly_pos = nil
	
	self.lock_object = nil
	self.lock_check_func = nil
	
	self.is_check_scene_change = false
end

function OperationMove:InitData(scene_info,start_pos,end_pos,jump_path,path,callback,astar_info,fly_pos)
	self:CreateMainRole()
	self.scene_info = scene_info
	self.start_pos = start_pos
	self.end_pos = end_pos
	self.jump_path = jump_path
	self.callback = callback
	self.astar_info = astar_info or {}
	self.fly_pos = fly_pos
	self:SetPath(path)
	
	-- Yzprint('--LaoY OperationMove.lua,line 78--',self.end_pos)
	-- dump(self.end_pos)
	
	self.is_out_sceen = false
	if self.scene_info and self.scene_info.start_scene_id ~= self.scene_info.target_scene_id then
		self.is_out_sceen = true
	elseif MapLayer:GetInstance():IsInScreen(self.end_pos.x,self.end_pos.y) then
		self.is_out_sceen = true
	end
	
	-- test 调试用
	-- if not self.path then
	-- 	return
	-- end
	-- local mask_tab = {}
	-- local function getMask(i)
	-- 	if not mask_tab[i] then
	-- 		local vec = self.path[i]
	-- 		local b_x,b_y = SceneManager:GetInstance():GetBlockPos(vec.x,vec.y)
	-- 		mask_tab[i] = MapManager:GetInstance():GetMask(b_x,b_y)
	-- 	end
	-- 	return mask_tab[i]
	-- end
	
	-- local len = #self.path
	-- local leave_index
	-- for i=1,len do
	-- 	local cur_value = getMask(i)
	-- 	Yzprint('--LaoY ======>',cur_value)
	-- end
	-- Yzprint('--LaoY ======>',len)
end

function OperationMove:InitLock(lock_object,lock_check_func)
	self.lock_object = lock_object
	self.lock_check_func = lock_check_func
end

function OperationMove:FlyToAStarPos()
	if self.is_auto_way then
		local callback = self.callback
		local scene_id = self.scene_info and self.scene_info.target_scene_id or SceneManager:GetInstance():GetSceneId()
		local x,y = self.end_pos.x,self.end_pos.y
		if self.fly_pos then
			x,y = self.fly_pos.x,self.fly_pos.y
		end
		if SceneControler:GetInstance():UseFlyShoeToPos(scene_id, x, y, false, callback) then
			self:StopMove()
		end
	end
end

function OperationMove:SetPath(path)
	self.path = path
	if table.isempty(path) then
		return
	end
	self.all_path = clone(self.path)
	if self.main_role then
		local start_pos = {x = self.main_role.position.x,y = self.main_role.position.y}
		table.insert(self.all_path,1,start_pos)
	end
end

function OperationMove:StartMove()
	self.last_state_is_jump = false
	self.is_auto_way = true
	self:Resume()
	self:ResetMainRolePosition()
	self:MoveNextWay()
	GlobalEvent:Brocast(SceneEvent.FIND_WAY_START,self.all_path)
end

function OperationMove:StopMove(ignore_stop)
	if not ignore_stop then
		self.main_role:SetMovePosition(nil)
	end
	local is_auto_way = self.is_auto_way
	self:Clean()
	if is_auto_way then
		GlobalEvent:Brocast(SceneEvent.FIND_WAY_END)
	end
end

function OperationMove:WaitMove()
	self.last_state_is_jump = false
	self.is_auto_way = true
	self.is_check_scene_change = true
	self:Pause()
end

function OperationMove:IsAutoWay()
	return self.is_auto_way
end

function OperationMove:MoveNextWay()
	if not self:IsCanMove() then
		return
	end
	if not self:GetNextWay() or not self.main_role then
		return false
	end
	self.is_last_way = false
	-- if table.isempty(self.path) and ((self.cur_way.x ~= self.end_pos.x or self.cur_way.y ~= self.end_pos.y)) then
	-- 	local dis = Vector2.DistanceNotSqrt(self.cur_way,self.end_pos)
	-- 	local bo = dis == 0
	-- 	Yzprint('--LaoY OperationMove.lua,line 192--',dis,bo)
	-- end
	if table.isempty(self.jump_path) and table.isempty(self.scene_info.scene_path) and (self.cur_way.x == self.end_pos.x and self.cur_way.y == self.end_pos.y) then
		self.is_last_way = true
	end
	if not self.main_role.is_riding_up and not self.main_role:IsRideDown() then
		self:SetMainRolePos()
	end
	return true
end

function OperationMove:CheckMainRoleRun()
	if not table.isempty(self.cur_way) and not self.main_role:IsRunning() and not self.main_role.is_riding_up and not self.main_role:IsRideDown() and not self.main_role.is_fly then
		self:SetMainRolePos()
	end
end

function OperationMove:SetMainRolePos(pos)
	pos = pos or self.cur_way
	self.main_role:SetMovePosition(pos)
	if self:IsNeedAutoPlayMount() and not self.main_role.is_riding_up and not self.main_role:IsRideDown() and not self.main_role:IsJumping() and not self.main_role.is_fly then
		self.main_role:PlayMount(nil,true,pos)
	end
end

function OperationMove:MainRoleJump(jump_target_pos)
	if self.is_auto_way and jump_target_pos then
		self.cur_way = nil
		self.is_last_way = false
		self.path = nil
	end
end

function OperationMove:ResetMainRolePosition()
	-- if table.isempty(self.path) then
	-- 	return
	-- end
	-- local pos = table.remove(self.path,1)
	-- self.main_role:SetPosition(pos.x + 10,pos.y + 10)
end

function OperationMove:CheckJumpPointAStar(x,y)
	if self.scene_info and not table.isempty(self.scene_info.scene_path) then
		return false
	end
	if self.end_pos and Vector2.DistanceNotSqrt(Vector2(x,y),self.end_pos) <= 60 * 60 then
		return true
	end
	return false
end

function OperationMove:GetNextWay()
	if self.cur_total_time ~= 0 then
		logWarn("当前路段预估时间：",self.cur_total_time,",实际花费：",self.cur_pass_time,",误差：",self.cur_total_time - self.cur_pass_time)
	end
	if self.is_last_way then
		return false
	end
	self.cur_way = nil
	self.cur_pass_time = 0
	local flag = false
	if table.isempty(self.path) then
		if table.isempty(self.scene_info) and table.isempty(self.jump_path) then
			return flag
		end
		--当前阶段的目标点
		local cur_target_pos
		if not table.isempty(self.jump_path) then
			local jump_id = table.remove(self.jump_path,1)
			local jump_data = SceneConfigManager:GetInstance():GetJumpPathData(jump_id)
			cur_target_pos = jump_data.coord
		elseif table.isempty(self.scene_info.scene_path) then
			-- 有可能在传送阵
			if SceneManager:GetInstance():GetSceneId() ~= self.scene_info.target_scene_id then
				return flag
			end
			cur_target_pos = self.end_pos
		else
			local scene_path = self.scene_info.scene_path
			-- 有可能在传送阵
			local cur_scene_id = SceneManager:GetInstance():GetSceneId()
			if scene_path[1] ~= cur_scene_id then
				return flag
			end
			table.remove(scene_path,1)
			local next_scene_id = scene_path[1]
			if not next_scene_id then
				return self:GetNextWay()
			end
			local door_coord = SceneConfigManager:GetInstance():GetSceneDoorCoord(cur_scene_id,next_scene_id)
			cur_target_pos = door_coord
		end
		-- 满足以上条件都找不到的话，传送门等配置可以能搞错了
		if not cur_target_pos then
			logError("LaoY====找不到寻路目标点")
			self:StopMove()
			return flag
		end
		local start_pos = self.main_role:GetPosition()
		if self.astar_info.dis_range and 
			Vector2.DistanceNotSqrt(start_pos,cur_target_pos) <= self.astar_info.dis_range * self.astar_info.dis_range then
			self.main_role:SetMovePosition()
			local callback = self.callback
			self:StopMove()
			if callback then
				callback()
			end
			return
		end
		local path,jump_path = OperationManager:GetInstance():FindWayOrJumpPath(start_pos,cur_target_pos,self.astar_info.error_range,self.astar_info.check_range,self.astar_info.smooth)
		self.jump_path = jump_path
		if table.isempty(path) then
			self:StopMove()
			return
		end
		-- 如果是多场景里面最后一个场景，要把目的地点换成寻路的最后一个
		if table.isempty(self.scene_info.scene_path) then
			local last_path = path[#path]
			self.end_pos.x = last_path.x
			self.end_pos.y = last_path.y
		end
		self.path = path
		self.all_path = clone(self.path)
		self:ResetMainRolePosition()
		self.cur_way = table.remove(self.path,1)
		flag = true
	else
		self.cur_way = table.remove(self.path,1)
		flag = true
	end
	if self.cur_way then
		self:CalculationNextCheckTime()
		local distance = Vector2.Distance(self.main_role:GetPosition(),self.cur_way)
		local speed = self.main_role:GetSpeed() or 400
		self.cur_total_time = distance/speed
	end
	return flag
end

function OperationMove:CalculationNextCheckTime()
	local min_check_time = 0.02 * 5
	if self.last_time <= min_check_time or table.isempty(self.cur_way) then
		self.check_time = 0
		return
	end
	local distance = Vector2.Distance(self.main_role:GetPosition(), self.cur_way)
	if self.is_last_way and self.astar_info.dis_range then
		distance = distance - self.astar_info.dis_range
	end
	local speed = self.main_role:GetSpeed() or 400
	local pre_time = distance/speed
	self.check_time = pre_time/2
	--if self.check_time < min_check_time then
	--	self.check_time = math.max(0,pre_time - min_check_time)
	--end
	self.last_time = pre_time
	self.last_check_time = os.time()
end

function OperationMove:Pause()
	self.is_pause = true
end

function OperationMove:Resume()
	self.is_pause = false
end

--[[
@author LaoY
@des 	没有可走路径
--]]
function OperationMove:IsNotWayPath()
	return table.isempty(self.path) and (table.isempty(self.scene_info) or table.isempty(self.scene_info.scene_path))
	and not self.cur_way
	and table.isempty(self.jump_path)
	and self.is_last_way
end

function OperationMove:RestartAStar()
	if not self.is_auto_way then
		return
	end
	local target_scene_id = self.scene_info and self.scene_info.target_scene_id
	local start_pos = self.main_role:GetPosition()
	local end_pos = self.end_pos
	local callback = self.callback
	local dis_range = self.astar_info.dis_range
	local error_range = self.astar_info.error_range
	local check_range = self.astar_info.check_range
	local smooth = self.astar_info.smooth
	local fly_pos = self.fly_pos
	if self.is_check_scene_change then
		OperationManager:GetInstance():CheckMoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos)
	else
		OperationManager:GetInstance():TryMoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos)
	end
end

function OperationMove:JumpEnd(jump_pos,is_jump_point)
	if not self.is_auto_way then
		return
	end
	if table.isempty(self.path) then
		return
	end
	-- do
	-- 	self:RestartAStar()
	-- 	return
	-- end
	local len = #self.path
	
	local mask_tab = {}
	local function getMask(i)
		if not mask_tab[i] then
			local vec = self.path[i]
			local b_x,b_y = SceneManager:GetInstance():GetBlockPos(vec.x,vec.y)
			mask_tab[i] = MapManager:GetInstance():GetMask(b_x,b_y)
		end
		return mask_tab[i]
	end
	
	local leave_index
	if is_jump_point then
		for i=1,len-1 do
			local cur_value = getMask(i)
			local next_value = getMask(i+1)
			if not BitState.StaticContain(cur_value,SceneConstant.MaskBitList.JumpPath) and i >= 1 then
				-- self:RestartAStar()
				self.jump_restart_astar = true
				return
			end
			if BitState.StaticContain(cur_value,SceneConstant.MaskBitList.JumpPath) and not BitState.StaticContain(next_value,SceneConstant.MaskBitList.JumpPath) then
				leave_index = i
				break
			end
		end
	else
		leave_index = 1
		for i=1,len-1 do
			local pos = self.path[i]
			local has_block = OperationManager:GetInstance():HasBlock(jump_pos,pos)
			if not has_block then
				leave_index = i
				break
			end
		end
	end
	
	if not leave_index then
		return
	end
	
	-- if leave_index > 5 then
	-- 	return
	-- end
	local cur_pos = self.main_role:GetPosition()
	local leave_pos = self.path[leave_index]
	-- local leave_dis = Vector2.DistanceNotSqrt(jump_pos,leave_pos)
	local next_way
	local check_index
	local start_index = leave_index+1
	
	for i=start_index,len do
		local pos = self.path[i]
		local has_block = OperationManager:GetInstance():HasBlock(jump_pos,pos)
		-- if has_block or Vector2.DistanceNotSqrt(pos,leave_pos) > leave_dis then
		if has_block then
			next_way = self.path[i-1]
			check_index = i-1
			break
		elseif BitState.StaticContain(getMask(i),SceneConstant.MaskBitList.JumpPath) then
			next_way = self.path[i]
			check_index = i
			break
		end
	end
	
	if next_way then
		for i=1,check_index do
			table.remove(self.path,1)
		end
		self.cur_way = next_way
	else
		self.cur_way = self.path[len]
		self.path = {}
	end
	-- 落地点不能走到下一个点，直接重新寻路
	local has_block = OperationManager:GetInstance():HasBlock(jump_pos,self.cur_way)
	self.jump_restart_astar = has_block
	
	if not has_block then
		if table.isempty(self.jump_path) and table.isempty(self.scene_info.scene_path) and (self.cur_way.x == self.end_pos.x and self.cur_way.y == self.end_pos.y) then
			self.is_last_way = true
		end
	end
end

--是否自动上马
--跨场景或者寻路距离超过 半屏
function OperationMove:IsNeedAutoPlayMount()
	if self.main_role:IsRiding() then
		return false
	end
	if not self.main_role:IsCanAutoPlayMount() then
		return false
	end
	return not table.isempty(self.scene_info.scene_path) or 
	Vector2.Distance(self.start_pos,self.end_pos) >= ScreenWidth*0.5
end

function OperationMove:IsCanMove()
	local panel = LoadingCtrl:GetInstance().loadingPanel
	return not (SceneManager:GetInstance():GetChangeSceneState() or (panel and not panel.is_dctored) or 
		self.main_role:IsJumping() or self.main_role.is_fly)
end

function OperationMove:IsSameTargetPos(pos,scene_id)
	-- if not self:IsAutoWay() then
	-- 	return false
	-- end
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if not pos or not pos.x or not pos.y then
		if AppConfig.Debug then
			logError("客户端打印：判断是否为寻路目标，查询坐标点是空")
		end
		return false
	end
	if not self.end_pos then
		return false
	end
	return (not self.scene_info or not self.scene_info.target_scene_id or scene_id == self.scene_info.target_scene_id) and 
	(Vector2.DistanceNotSqrt(self.end_pos,pos) <= 1e-05)
end

function OperationMove:CheckLock()
	if self.lock_object and not self.lock_object.is_dctored then
		local distance_square = Vector2.DistanceNotSqrt(self.main_role:GetPosition(), self.lock_object:GetPosition())
		local check_dis_range_square = 0
		if self.astar_info.dis_range then
			check_dis_range_square = self.astar_info.dis_range * self.astar_info.dis_range
		end
		return distance_square <= check_dis_range_square
	end
	
	if self.lock_check_func then
		return self.lock_check_func(self.main_role:GetPosition())
	end
	return false
end

function OperationMove:CheckLockPath()
	local cur_target_pos
	if self.lock_object and not self.lock_object.is_dctored then
		cur_target_pos = self.lock_object:GetPosition()
		cur_target_pos = {x = cur_target_pos.x,y = cur_target_pos.y}
	end
	if not cur_target_pos or Vector2.DistanceNotSqrt(cur_target_pos,self.cur_way) < 1 then
		return false
	end
	
	if self.last_check_lock_time and Time.time - self.last_check_lock_time < 0.4 then
		return false
	end
	self.last_check_lock_time = Time.time
	local start_pos = self.main_role:GetPosition()
	local path
	if not OperationManager:GetInstance():HasBlock(start_pos,cur_target_pos) then
		path = {pos(cur_target_pos.x,cur_target_pos.y)}
	else
		path = OperationManager:GetInstance():FindWayOrJumpPath(start_pos,cur_target_pos,self.astar_info.error_range,self.astar_info.check_range,self.astar_info.smooth)
		if path then
			local last_pos = path[#path]
			if last_pos then
				last_pos.x = cur_target_pos.x
				last_pos.y = cur_target_pos.y
			end
		end
	end
	if table.isempty(path) then
		return false
	end
	self.end_pos = cur_target_pos
	self.is_last_way = false
	self.path = path
	self.all_path = clone(self.path)
	return true
end

function OperationMove:Update(dalta_time)
	if not self.is_auto_way then
		return
	end
	if not self:IsCanMove() then
		if self.main_role:IsJumping() then
			self.last_state_is_jump = true
		end
		return
	end
	if self.last_state_is_jump and self.jump_restart_astar then
		self.last_state_is_jump = false
		self.jump_restart_astar = false
		self:RestartAStar()
		return
	end
	if not self:IsAutoWay() then
		return
	end
	
	if self.is_pause then
		return
	end
	-- if self.finish_last_time and os.clock() - self.finish_last_time <= 100 then
	-- 	return
	-- end
	if not self.cur_way then
		self:MoveNextWay()
		return
	end
	-- self.cur_pass_time = self.cur_pass_time + dalta_time
	-- self.total_pass_time = self.total_pass_time +dalta_time
	-- if os.time() - self.last_check_time < self.check_time then
	-- 	return
	-- end
	
	self:CalculationNextCheckTime()
	local distance_square = Vector2.DistanceNotSqrt(self.main_role:GetPosition(), self.cur_way)
	local check_dis_range_square = 0
	if self.is_last_way and self.astar_info.dis_range then
		check_dis_range_square = self.astar_info.dis_range * self.astar_info.dis_range
	end
	
	if self.is_last_way and ((self.lock_object and not self.lock_object.is_dctored) or self.lock_check_func) then
		if self:CheckLock() then
			local callback = self.callback
			self:StopMove(callback ~= nil)
			if callback then
				callback()
			end
			return
		elseif self:CheckLockPath() then
			self:MoveNextWay()
		end
	elseif distance_square <= check_dis_range_square then
		-- self.finish_last_time = os.clock()
		-- Yzprint('--LaoY OperationMove.lua,line 465--',self.is_last_way,math.sqrt(distance_square),self.astar_info.dis_range)
		if self.is_last_way or not self:MoveNextWay() then
			self.main_role:SetMovePosition()
			if self.is_last_way then
				local callback = self.callback
				self:StopMove()
				if callback then
					callback()
				end
			elseif self.scene_info and SceneManager:GetInstance():GetSceneId() ~= self.scene_info.target_scene_id then
				return
			else
				self:StopMove()
			end
		end
		return
	end
	
	self:CheckMainRoleRun()
end