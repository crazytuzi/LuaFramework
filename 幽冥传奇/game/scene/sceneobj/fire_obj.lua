
-- 烈焰神力
FireObj = FireObj or BaseClass(Character)

function FireObj:__init(vo)
	self.obj_type = SceneObjType.FireObj
	self:SetObjId(vo.obj_id)
	self.vo = vo

	self.move_speed = 2
	self.peri_next_update_time = 0
	self.res_id = 1
	self.res_is_change = false

	RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
end

function FireObj:__delete()
	if nil ~= self.free_walk_timer then
		GlobalTimerQuest:CancelQuest(self.free_walk_timer)
		self.free_walk_timer = nil
	end
	if self.fire_animation then
		self.fire_animation = nil
	end
	self.res_is_change = nil
end

function FireObj:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)

	self:InitResId()
	self.name = self.vo.name or ""
end

function FireObj:CreateBoard()
end

function FireObj:InitResId()
	local owner_obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil == owner_obj then
		return
	end
	local old_res_id = self.res_id
	self.res_id = owner_obj:GetAttr(OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID) or 0
	if old_res_id ~= self.res_id then
		self.res_is_change = true
	end
end

function FireObj:InitAnimation()
	self:DoStand()
	self:RefreshAnimation()
end

function FireObj:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID then
		self:InitResId()
		self:RefreshAnimation()
	end
end

function FireObj:RefreshAnimation()
	if self.res_is_change then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.res_id)
		self.fire_animation = self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, false, FrameTime.Stand, nil, nil, nil, 0, 80)
		self.fire_animation:setOpacity(0)
		self.fire_animation:setVisible(false)
		self.res_is_change = false
	end
end

function FireObj:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)

	if now_time >= self.peri_next_update_time then
		self.peri_next_update_time = now_time + 0.5

		self:CheckMove()
	end
end

function FireObj:SetHeight(height)
	self.height = height
end

-- 检查是否需要移动，返回是否移动
local vaild_move_pos = {
	{-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2},
	{-2, 1}, {-1, 1}, {0, 1}, {1, 1}, {2, 1},
	{-2, 0}, {-1, 0}, {1, 0}, {2, 0},
	{-2, -1}, {-1, -1}, {0, -1}, {1, -1}, {2, -1},
	{-2, -2}, {-1, -2}, {0, -2}, {1, -2}, {2, -2},
}
function FireObj:CheckMove()
	local owner_obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil == owner_obj then
		return false
	end

	local owner_pos = cc.p(owner_obj:GetLogicPos())
	local delta_pos = cc.pSub(owner_pos, self.logic_pos)
	local max_dis = math.max(math.abs(delta_pos.x), math.abs(delta_pos.y))
	local is_over = max_dis > 3

	if is_over then
		local target_pos = cc.p(owner_pos.x - 1, owner_pos.y + 1)
		if max_dis > 12 then
			self:ClearAction(true)
			self:SetLogicPos(target_pos.x, target_pos.y)
		else
			self:ClearAction()
			self.move_speed = max_dis > 6 and 5 or 3
			self:DoMove(target_pos.x, target_pos.y)
			return true
		end
	else
		if self:IsStand() and nil == self.free_walk_timer then
			local timer_callback = function()
				self.free_walk_timer = nil
				if not self:IsStand() then
					return
				end

				-- math.randomseed(os.time())
				local owner_pos = cc.p(owner_obj:GetLogicPos())
				local rand = math.floor(math.random() * #vaild_move_pos) + 1
				local target_pos = vaild_move_pos[rand]
				if target_pos then
					self.move_speed = 2
					self:DoMove(owner_pos.x + target_pos[1], owner_pos.y + target_pos[2])
				else
				end
			end
			self.free_walk_timer = GlobalTimerQuest:AddDelayTimer(timer_callback, math.random() * 1 + 0.8)
		end
	end

	return false
end

function FireObj:ReadyDoFireAttack(target_obj)
	self.fire_animation:stopAllActions()
	self.fire_animation:setOpacity(0)
	self.fire_animation:setVisible(true)
	------------------------------------------------------
	local fade_in = cc.FadeIn:create(1.5) -- 逐渐显示时间(秒)
	------------------------------------------------------
	local fire_sequence = cc.Sequence:create(fade_in, cc.CallFunc:create(BindTool.Bind(self.DoFireAttack, self, target_obj)))
	self.fire_animation:runAction(fire_sequence)
end

function FireObj:DoFireAttack(target_obj)
	if nil == self.skill_animate_sprite then
		self.skill_animate_sprite = AnimateSprite:create()
		self.skill_animate_sprite:setPosition(0, 65)
		self.model:AttachNode(self.skill_animate_sprite, nil, GRQ_SCENE_OBJ, InnerLayerType.AttackEffect)
		-- 设置动画回调
		self.skill_animate_sprite:addEventListener(function(sender, event_type, frame)
			if event_type == AnimateEventType.Stop then -- 动画停止
				------------------------------------------------------
				local delay = cc.DelayTime:create(2) -- 逐渐消失前延时时间
				------------------------------------------------------
				------------------------------------------------------
				local fade_out = cc.FadeOut:create(4) -- 逐渐消失时间(秒)
				------------------------------------------------------
 				local fire_sequence = cc.Sequence:create(delay, fade_out, cc.CallFunc:create(function()
 					self.fire_animation:stopAllActions()
					self.fire_animation:setVisible(false)
 				end
 					))
 				self.fire_animation:runAction(fire_sequence)
			end
		end)
	end
	local anim_path, anim_name = ResPath.GetEffectAnimPath(100)
	self.skill_animate_sprite:setAnimate(anim_path, anim_name, 1, FrameTime.Atk, false)

	if nil ~= target_obj then
		local vo = GameVoManager.Instance:CreateVo(EffectObjVo)
		vo.deliverer_obj_id = self:GetObjId()
		vo.effect_type = EffectType.Fly
		vo.effect_id = 104
		vo.pos_x, vo.pos_y = target_obj:GetLogicPos()
		vo.target_pos_x, vo.target_pos_y = target_obj:GetLogicPos()
		vo.remain_time = 200
		self.parent_scene:CreateEffectObj(vo)

		GlobalTimerQuest:AddDelayTimer(function()
			local vo = GameVoManager.Instance:CreateVo(EffectObjVo)
			vo.deliverer_obj_id = 0
			vo.effect_type = 4
			vo.effect_id = 105
			vo.pos_x, vo.pos_y = target_obj:GetLogicPos()
			vo.target_pos_x, vo.target_pos_y = target_obj:GetLogicPos()
			vo.remain_time = 200
			self.parent_scene:CreateEffectObj(vo)
		end, 200 / 1000)
	end
end

function FireObj:MoveEnd()
	local need_move = self:CheckMove()
	return not need_move
end

function FireObj:CanClick()
	return false
end

function FireObj:IsCharacter()
	return false
end

function FireObj:UpdateHpBoardVisible()
end

function FireObj:GetOwerRoleId()
	return self.vo.owner_obj_id
end
