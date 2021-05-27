CommonDisplay = CommonDisplay or BaseClass()

function CommonDisplay:__init(parent, dir, path_func, name_func, status)	
	self.anim_node = cc.Sprite:create()
	self.frame_animate = nil
	if nil ~= parent then
		local size = parent:getContentSize()
		self:SetAnimPosition(size.width / 2, size.height / 2)
		parent:addChild(self.anim_node, 999, 999)
	end	

	self.dir = GameMath.DirDown
	self.dir_default = GameMath.DirDown
	if nil ~= dir then
		self.dir_default = dir
	end

	self.anim_path_func = nil
	self.anim_name_func = nil
	if nil ~= path_func then
		self.anim_path_func = path_func
	end
	if nil ~= name_func then
		self.anim_name_func = name_func
	end

	self.anim_status = SceneObjState.Stand
	if nil ~= status then		
		self.anim_status = status
	end

	self.anim_id = -1
	self.loops = 10
	self.is_pause_lastframe = false
	self.elapsed_time = nil

	self.frame_time = FrameTime.Stand

	self.add_effect_t = {
		effect_id = 0,
		pet_unit = FrameTime.Effect,
		zorder = 10
	}
	self.add_x = 0
	self.add_y = 0
end

function CommonDisplay:SetZOrder(zorder)
	self.anim_node:setLocalZOrder(zorder)
end

function CommonDisplay:SetTag(tag)
	self.anim_node:setTag(tag)
end

function CommonDisplay:SetDirection(dir)
	self.dir_default = dir
end

function CommonDisplay:SetPathFunc(path_func)
	if "function" == type(path_func) then
		self.anim_path_func = path_func
	end
	self:InitAddEfffect()
end

function CommonDisplay:SetNameFunc(name_func)
	if "function" == type(name_func) then
		self.anim_name_func = name_func
	end
	self:InitAddEfffect()
end

function CommonDisplay:SetAnimStatus(status)
	if nil ~= status then
		self.anim_status = status
	end
end

function CommonDisplay:SetAnimPosition(x, y)
	if nil ~= x and nil ~= y then
		self.anim_node:setPosition(x, y)
	end
end

function CommonDisplay:GetAnimNode()
	return self.anim_node
end

-- 获取动画对象坐标
function CommonDisplay:GetAnimPosition()
	return self.anim_node:getPosition()
end

function CommonDisplay:__delete()
	self.anim_node = nil
	if self.add_effect then
		self.add_effect:removeFromParent()
		self.add_effect = nil
	end
end

function CommonDisplay:Show(anim_id, is_turn, x, y, zorder)
	if nil ~= self.anim_name_func and nil ~= self.anim_path_func then
		if true ~= is_turn then
			self.dir = self.dir_default
		end
		zorder = zorder or 0
		x = x or 0
		y = y or 0
		self.anim_node:removeAllChildren()

		local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
		local path = self.anim_path_func(anim_id, self.anim_status, dir_num)
		local name = self.anim_name_func(anim_id, self.anim_status, dir_num)

		self.frame_animate = RenderUnit.CreateAnimSprite(path, name, self.frame_time, self.loops, is_flip_x)
		self.frame_animate:setIsPauseLastFrame(self.is_pause_lastframe)
		if self.elapsed_time ~= nil then
			self.frame_animate:setElapsed(self.elapsed_time)
		end
		self.frame_animate:setPosition(x, y)
		self.anim_id = anim_id
		self.anim_node:addChild(self.frame_animate, zorder, zorder)

		if self.add_effect_t.effect_id > 0 then
			self:CreateAddEffect()
		end
	end		
end

function CommonDisplay:CreateAddEffect()
	if self.add_effect_t.effect_id > 0 then
		self.add_effect = RenderUnit.CreateEffect(self.add_effect_t.effect_id, self.anim_node, self.add_effect_t.zorder, 
			self.add_effect_t.pet_unit, COMMON_CONSTS.MAX_LOOPS, 0, 0)
		if nil ~= self.add_x and nil ~= self.add_y then
			self.add_effect:setPosition(self.add_x, self.add_y)
		end
	else
		if self.add_effect then
			self.add_effect:removeFromParent()
			self.add_effect = nil
		end
	end
end

function CommonDisplay:AddEfffect(effect_id, pet_unit, zorder, x, y)
	self.add_x = x
	self.add_y = y
	self.add_effect_t.effect_id = effect_id or 0
	self.add_effect_t.pet_unit = pet_unit or FrameTime.Effect
	self.add_effect_t.zorder = zorder or 10
	self:Show(self.anim_id, true)
end

function CommonDisplay:InitAddEfffect()
	self.add_effect_t = {
		effect_id = 0,
		pet_unit = FrameTime.Effect,
		zorder = 10
	}
end

function CommonDisplay:TurnRight()
	if -1 ~= self.anim_id and nil ~= self.anim_node then
		self.dir = self.dir + 1
		if self.dir > 3 then
			self.dir = 0
		end
		self:Show(self.anim_id, true)
	end
end

function CommonDisplay:TurnLeft()
	if -1 ~= self.anim_id and nil ~= self.anim_node then	
		self.dir = self.dir - 1	
		if self.dir < 0 then
			self.dir = 3
		end
		self:Show(self.anim_id, true)
	end
end

function CommonDisplay:GetResDirNumAndFlipFlag()
	if self.dir == GameMath.DirLeft then
		return GameMath.DirRight, true
	end

	return self.dir, false
end

-- 设置动画播放帧数
function CommonDisplay:SetFrameTime(time)
	self.frame_time = time
end

-- 设置动画播放模式
function CommonDisplay:SetLoops(times)
	self.loops = times
end

-- 设置动画可见区域
function CommonDisplay:SetViewRect(rect)
	if nil ~= rect and nil ~= self.frame_animate then
		self.frame_animate:setViewRect(rect)
	end
end

-- 取消动画可见区域设置
function CommonDisplay:CancelUseViewRect()
	if nil ~= self.frame_animate then
		self.frame_animate:cancelUseViewRect()
	end
end

function CommonDisplay:SetIsPauseLastFrame(value)
	self.is_pause_lastframe = value
	if nil ~= self.frame_animate then
		self.frame_animate:setIsPauseLastFrame(value)
	end
end

-- 清除动画对象
function CommonDisplay:ClearAnim()
	self.anim_node:removeAllChildren()
	self.frame_animate = nil
end

-- 是否显示动画
function CommonDisplay:ShowAnim(visible)
	self.anim_node:setVisible(visible)
end

function CommonDisplay:SetScale(num)
	self.anim_node:setScale(num)
end

function CommonDisplay:SetScaleX(num)
	self.anim_node:setScaleX(num)
end

function CommonDisplay:SetScaleY(num)
	self.anim_node:setScaleY(num)
end

function CommonDisplay:GetScale()
	return self.anim_node:getScale()
end

function CommonDisplay:SetRotation(rotation)
	self.anim_node:setRotation(rotation)
end

function CommonDisplay:SetElapsed(time)
	if self.frame_animate then
		self.frame_animate:setElapsed(time)
	end
	self.elapsed_time = time
end

function CommonDisplay:RunAction(action)
	if nil ~= action then
		self.anim_node:runAction(action)
	end
end

function CommonDisplay:StopAction(action)
	if nil ~= action then
		self.anim_node:stopAction(action)
	end
end

function CommonDisplay:StopAllActions()
	self.anim_node:stopAllActions()
end

