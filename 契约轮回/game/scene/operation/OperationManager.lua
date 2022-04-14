-- 
-- @Author: LaoY
-- @Date:   2018-09-03 17:04:16
-- 寻路操作相关

OperationManager = OperationManager or class("OperationManager",BaseManager)
local OperationManager = OperationManager

function OperationManager:ctor()
	OperationManager.Instance = self
	LateUpdateBeat:Add(self.Update,self,1)
	self:Reset()
end

function OperationManager:Reset()
	if self.move_operation then
		self.move_operation:destroy()
		self.move_operation = nil
	end
end

function OperationManager.GetInstance()
	if OperationManager.Instance == nil then
		OperationManager()
	end
	return OperationManager.Instance
end

function OperationManager:IsCurScene(scene_id)
	return SceneManager:GetInstance():GetSceneId() == scene_id
end

function OperationManager:CreateMoveOperation()
	if not self.move_operation then
		self.move_operation = OperationMove()
	end
end

function OperationManager:IsSameTargetPos(pos,scene_id)
	if self.move_operation then
		return self.move_operation:IsSameTargetPos(pos,scene_id)
	end
end

--会检查是否同场景，不是同场景有特殊处理
function OperationManager:CheckMoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos,change_func)
	local cur_scene_id = SceneManager:GetInstance():GetSceneId()
	target_scene_id = target_scene_id or cur_scene_id

	if target_scene_id ~= cur_scene_id then
		if not SceneConfigManager:GetInstance():CheckEnterScene(cur_scene_id,true) then
			return
		end

		local main_role = SceneManager:GetInstance():GetMainRole()
		if not main_role then
			return
		end
		if main_role:IsJumping() and main_role.jump_info then
			local jump_pos = main_role:GetJumpEndPos()
			start_pos = {x = jump_pos.x,y = jump_pos.y}
		elseif not start_pos then
			local pos = main_role:GetPosition()
			start_pos = {x = pos.x,y = pos.y}
		end

		self:CreateMoveOperation()
		local scene_info = {
			start_scene_id = cur_scene_id,
			target_scene_id = target_scene_id,
			scene_path = {},
		}
		local astar_info = {dis_range = dis_range,error_range = error_range,check_range = check_range,smooth = smooth,jump_path = nil,fly_pos = fly_pos}
		self.move_operation:Clean()
		self.move_operation:InitData(scene_info,start_pos,end_pos,nil,{},callback,astar_info,fly_pos)
		self.move_operation:WaitMove()

		if change_func then
			change_func()
		else
			local function callback()
				SceneControler:GetInstance():RequestSceneLeave()
			end
			if DungeonModel:GetInstance():ExitScene() then
				SceneControler:GetInstance():RequestSceneChange(target_scene_id, 2)
			end
		end
		return true
	else
		return self:TryMoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos)
	end
end

--[[
	@author LaoY
	@des	
	@param1 target_scene_id
	@param2 start_pos
	@param3 end_pos
	@param4 callback
	@param5 dis_range 		--执行回调时距离目标地点的半径，会停止走路，调用回调 lua层用
	@param6 error_range     --AStar模糊寻路，离准确目标点误差距离，停止继续寻路算法 单位掩码大小 C#层用
	@param7 check_range     --如果目标点是阻挡物，检索周围可行走的半径。单位为掩码大小 C#层用
	@param8 smooth 			--是否平滑移动 C#层用
--]]
function OperationManager:TryMoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos)
	if not end_pos then
		return
	end
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role then
		return
	end
	if main_role:IsJumping() and main_role.jump_info then
		local jump_pos = main_role:GetJumpEndPos()
		start_pos = {x = jump_pos.x,y = jump_pos.y}
	elseif not start_pos then
		local pos = main_role:GetPosition()
		start_pos = {x = pos.x,y = pos.y}
	end
	if self:MoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos) then
		return true
	end
	return false
end

function OperationManager:LockObject(target_scene_id,start_pos,end_pos,callback,dis_range,lock_object,lock_check_func)
	if self:TryMoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range) then
		self.move_operation:InitLock(lock_object,lock_check_func)
	end
end

function OperationManager:MoveToPosition(target_scene_id,start_pos,end_pos,callback,dis_range,error_range,check_range,smooth,fly_pos)
	if not dis_range or dis_range < 1 then
		dis_range = 1
	end
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role then
		local bo,buff_effect_type = main_role.object_info:IsCanMoveByBuff()
		if not bo then
			main_role:MoveDebuffTip(buff_effect_type)
			return
		end
	end
	self:CreateMoveOperation()
	target_scene_id = target_scene_id or SceneManager:GetInstance():GetSceneId()
	-- start_pos.x = 3120
	-- start_pos.y = 3660
	-- end_pos.x = 2490
	-- end_pos.y = 6954
	-- local bo,x,y = self:GetFarest(start_pos,end_pos)
	-- Yzprint('--LaoY OperationManager.lua,line 52-- data=',bo)
	local path
	local scene_info = {}
	if self:IsCurScene(target_scene_id) then
		if dis_range and Vector2.DistanceNotSqrt(start_pos,end_pos) <= dis_range * dis_range and not self:HasBlock(start_pos,end_pos) then
			if callback then
				self.move_operation:Clean()
				callback()
			end
			return
		end
		path,jump_path = self:FindWayOrJumpPath(start_pos,end_pos,error_range,check_range,smooth)
		if table.isempty(path) then
			return
		end
		local last_path = path[#path]
		if not jump_path then
			last_path.x = end_pos.x
			last_path.y = end_pos.y
		end
		scene_info = {start_scene_id = target_scene_id,target_scene_id = target_scene_id}
	else
		local start_scene_id = SceneManager:GetInstance():GetSceneId()
		local door_coord,scene_path = self:GetOtherSceneInfo(start_scene_id,target_scene_id)
		if not door_coord then
			return
		end
		path,jump_path = self:FindWayOrJumpPath(start_pos,door_coord,error_range,check_range,smooth)
		if not path then
			return
		end
		scene_info = {
			start_scene_id = start_scene_id,
			target_scene_id = target_scene_id,
			scene_path = scene_path,
		}
	end

	self.move_operation:StopMove(true)

	-- Yzprint('--LaoY OperationManager.lua,line 70--',self:IsCurScene(target_scene_id),tostring(end_pos))
	-- Yzdump(path,"path")
	local astar_info = {dis_range = dis_range,error_range = error_range,check_range = check_range,smooth = smooth,jump_path = jump_path,fly_pos}
	self.move_operation:Clean()
	self.move_operation:InitData(scene_info,start_pos,end_pos,jump_path,path,callback,astar_info,fly_pos)
	self.move_operation:StartMove()
	return true
end

function OperationManager:StopAStarMove()
	if self.move_operation then
		self.move_operation:StopMove()
	end
end

function OperationManager:IsCheckWaitStar()
	if self.move_operation then
		return self.move_operation.is_check_scene_change and self.move_operation.is_auto_way
	end
	return false
end

--是否寻路到跳跃点 到达跳跃点后要取消寻路
function OperationManager:CheckJumpPointAStar(x,y)
	if self.move_operation then
		return self.move_operation:CheckJumpPointAStar(x,y)
	end
	return false
end

function OperationManager:JumpEnd(jump_pos,is_jump_point)
	if self.move_operation then
		self.move_operation:JumpEnd(jump_pos,is_jump_point)
	end
end

function OperationManager:RestartAStar()
	if self.move_operation then
		self.move_operation:RestartAStar()
	end
end

function OperationManager:IsAutoWay()
	if self.move_operation then
		return self.move_operation:IsAutoWay()
	end
	return false
end

-- 超出屏幕的寻路
function OperationManager:IsOutScreenAutoWay()
	return self:IsAutoWay() and not self.move_operation.is_out_sceen
end

function OperationManager:GetOtherSceneInfo(start_scene_id,target_scene_id)
	if self:IsCurScene(target_scene_id) then
		return
	end
	local scene_path = self:GetScenePath(start_scene_id,target_scene_id)
	local door_coord = SceneConfigManager:GetInstance():GetSceneDoorCoord(start_scene_id,scene_path[1])
	--if door_coord then
	--	table.remove(scene_path,1)
	--end
	return door_coord,scene_path
end

function OperationManager:GetScenePath(start_scene_id,target_scene_id)
	local scene_path = SceneConfigManager:GetInstance():GetScenePath(start_scene_id,target_scene_id)
	return scene_path
end

function OperationManager:GetDoorPos(target_scene_id)
	if self:IsCurScene(target_scene_id) then
		return nil
	end
	return nil
end

function OperationManager:FindWayOrJumpPath(pos1,pos2,error_range,check_range,smooth)
	local list = self:FindWay(pos1,pos2,error_range,check_range,smooth)
	if not table.isempty(list) then
		return list
	end
	-- local path = SceneConfigManager:GetInstance():GetJumpPath(pos1,pos2)
	-- if table.isempty(path) then
	-- 	return
	-- end
	-- local jump_data = SceneConfigManager:GetInstance():GetJumpPathData(path[1])
	-- local list = self:FindWay(pos1,jump_data.coord,error_range,check_range,smooth)
	-- if table.isempty(list) then
	-- 	return
	-- end
	-- table.remove(path,1)
	-- return list,path
end

function OperationManager:FindWay(pos1,pos2,error_range,check_range,smooth)
	error_range = error_range or 0
	check_range = check_range or 1
	smooth = smooth == nil and true or smooth
	local b_s_x,b_s_y = SceneManager:GetInstance():GetBlockPos(pos1.x,pos1.y)
	local b_e_x,b_e_y = SceneManager:GetInstance():GetBlockPos(pos2.x,pos2.y)
	if  b_s_x == b_e_x and b_s_y == b_e_y then
		return {pos2}
	end
	local is_check_not_point = true
	local s_block_value = MapManager:GetInstance():GetMask(b_s_x,b_s_y)
	local e_block_value = MapManager:GetInstance():GetMask(b_e_x,b_e_y)
	if BitState.StaticContain(s_block_value,SceneConstant.MaskBitList.PathNot) or 
		BitState.StaticContain(e_block_value,SceneConstant.MaskBitList.PathNot) then
		is_check_not_point = false
	end
	local list = mapMgr:FindWay(pos1.x,pos1.y,pos2.x,pos2.y,error_range,check_range,smooth,is_check_not_point)
	if is_check_not_point and not list then
		list = mapMgr:FindWay(pos1.x,pos1.y,pos2.x,pos2.y,error_range,check_range,smooth,false)
	end
	if list then
		local tab = {}
		local start_index = 1
		if list.Length > 1 then
			local vec1 = list[1]
			if self:HasBlock(pos1,vec1) then
				start_index = 0
			end
		end
		-- C#是从0开始，第一个点是起始点
		-- 第一个点过滤
		for i=start_index,list.Length - 1 do
			local vec = list[i]
			tab[#tab + 1] = vec
		end
		return tab
	end
	return nil
end

function OperationManager:FlyToAStarPos()
	if self.move_operation then
		self.move_operation:FlyToAStarPos()
	end
end

-- /////////////////////////////////////

--[[
	@author LaoY
	@des	两点中间是否有阻挡
--]]
function OperationManager:HasBlock(pos1,pos2)
	return mapMgr:HasBlock(pos1.x,pos1.y,pos2.x,pos2.y) == 1
end

function OperationManager:IsBlock(x,y)
	local map_pixels_width = MapManager:GetInstance().map_pixels_width
	local map_pixels_height = MapManager:GetInstance().map_pixels_height
	if x <= 0 or y <= 0 or x >= map_pixels_width or y >= map_pixels_height then
		return true
	end
	local block_x,block_y = SceneManager:GetInstance():GetBlockPos(x,y)
	local mask = MapManager:GetInstance():GetMask(block_x,block_y)
	return mask == SceneConstant.MaskBitList.Block
	-- 跳跃路径可以行走
	-- or mask == SceneConstant.MaskBitList.JumpPath
end

function OperationManager:GetMask(x,y)
	local map_pixels_width = MapManager:GetInstance().map_pixels_width
	local map_pixels_height = MapManager:GetInstance().map_pixels_height
	if x <= 0 or y <= 0 or x >= map_pixels_width or y >= map_pixels_height then
		return true
	end
	local block_x,block_y = SceneManager:GetInstance():GetBlockPos(x,y)
	local mask = MapManager:GetInstance():GetMask(block_x,block_y)
	return mask
end

 -- 距离起始点最远的可行走的，遇到障碍物为止;  abc|d|ef |是障碍物 a->f 返回c
function OperationManager:GetFarest(pos1,pos2)
	local bo,x,y
	bo,x,y = mapMgr:GetFarest(pos1.x,pos1.y,pos2.x,pos2.y,x,y)
	-- Yzprint('--LaoY ======>',bo,x,y)
	return bo,x,y
end

-- 距离结束点最近的可行走点，不管起点终点间隔多少个障碍物;  a|c|d|ef |是障碍物 a->f 返回c
-- jump_path_is_can_way 跳跃路径是否可以寻路
function OperationManager:GetNearest(pos1,pos2,jump_path_is_can_way)
	local bo,x,y
	if jump_path_is_can_way == nil then
		bo,x,y = mapMgr:GetNearest(pos1.x,pos1.y,pos2.x,pos2.y,x,y)
	else
		bo,x,y = mapMgr:GetNearest(pos1.x,pos1.y,pos2.x,pos2.y,x,y,jump_path_is_can_way)
	end
	-- Yzprint('--LaoY ======>',bo,x,y)
	return bo,x,y
end

function OperationManager:Update(deltaTime)
	if self.move_operation then
		self.move_operation:Update(deltaTime)
	end
end