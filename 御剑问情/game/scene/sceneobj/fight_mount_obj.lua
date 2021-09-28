FightMountObj = FightMountObj or BaseClass(Character)

-- 战斗坐骑
function FightMountObj:__init(fight_mount_vo)
	self.obj_type = SceneObjType.FightMountObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(fight_mount_vo.fight_mount_appeid)
	self.vo = fight_mount_vo
	self.vo.move_speed = self.vo.move_speed
	self.origin_speed = self.vo.move_speed
	self.obj_speed = self.vo.move_speed
	self.peri_next_update_time = 0

	self.is_spirit = true
end

function FightMountObj:__delete()
	self.peri_next_update_time = nil
	self.do_move_time = nil
	self.obj_type = nil
	self.obj_speed = nil
	self.origin_speed = nil
end

function FightMountObj:InitShow()
	Character.InitShow(self)

	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	if self.vo.fight_mount_appeid ~= nil and self.vo.fight_mount_appeid ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetTestFightMountModle())
	end
end

function FightMountObj:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)

	-- if self.peri_next_update_time and now_time >= self.peri_next_update_time then
	-- 	self.peri_next_update_time = now_time + 0.02
		local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
		if nil ~= obj and obj:IsRole() and obj:GetRoleId() == self.vo.owner_role_id then
			self:SetLogicPos(obj:GetLogicPos())
	-- 		if obj:GetVo().move_speed ~= self.obj_speed then
	-- 			self.origin_speed = obj:GetVo().move_speed - 300
	-- 			self.obj_speed = obj:GetVo().move_speed
	-- 		end
	-- 		if obj:IsStand() and self:IsStand() then
	-- 			if self.do_move_time < now_time then
	-- 				local target_x, target_y = math.random(1,5), math.random(1,5)
	-- 				local obj_x, obj_y = obj:GetLogicPos()
	-- 				target_x = obj_x + target_x
	-- 				target_y = obj_y + target_y
	-- 				self:DoMove(target_x, target_y)
	-- 				self.do_move_time = now_time + 5
	-- 			end
	-- 		end
		end

	-- 	-- if not self:IsStand() then
	-- 	-- 	return
	-- 	-- end

	-- 	self:CheckMove()
	-- end
end

-- 检查是否需要移动，返回是否移动
function FightMountObj:CheckMove()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil == obj or not obj:IsRole() or obj:GetRoleId() ~= self.vo.owner_role_id then
		return false
	end

	local target_x, target_y = obj:GetLogicPos()

	local delta_pos = u3d.vec2(target_x - self.logic_pos.x, target_y - self.logic_pos.y)
	self.distance = math.floor(u3d.v2Length(delta_pos))
	target_x, target_y = AStarFindWay:GetTargetXY(self.logic_pos.x, self.logic_pos.y, target_x, target_y, 7)

	if self.distance > 7 then
		if not AStarFindWay:IsWayLine(self.logic_pos.x, self.logic_pos.y, target_x, target_y) then
			self:SetLogicPos(target_x, target_y)
		end
		if self.distance < 25 and self.distance > 9 then
			self.vo.move_speed = self.vo.move_speed + 0.2 * self.distance
		elseif self.distance <= 9 then
			self.vo.move_speed = self.origin_speed
		end
		if self.distance > 25 then
			self:SetLogicPos(target_x, target_y)
			return
		end
		self:DoMove(target_x, target_y)
		return true
	end

	return false
end

-- 镖车不可战斗
function FightMountObj:IsCharacter()
	return false
end

function FightMountObj:GetOwerRoleId()
	return self.vo.owner_role_id
end

function FightMountObj:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 7
end

function FightMountObj:IsFightMount()
	return true
end