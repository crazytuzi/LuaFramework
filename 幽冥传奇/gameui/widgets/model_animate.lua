ModelAnimate = ModelAnimate or BaseClass()

function ModelAnimate:__init(path_func, parent, dir, status)
	self.anim_node = AnimateSprite:create()

	if nil ~= parent then
		local size = parent:getContentSize()
		self.anim_node:setPosition(size.width / 2, size.height / 2)
		parent:addChild(self.anim_node, 999, 999)
	end

	self.anim_path_func = path_func

	self.anim_id = -1
	self.dir = GameMath.DirDown
	self.dir_default = dir or GameMath.DirDown
	self.anim_status = status or SceneObjState.Stand

	self.loops = COMMON_CONSTS.MAX_LOOPS
	self.frame_interval = FrameTime.Stand
end

function ModelAnimate:__delete()
	self.anim_node = nil
end

function ModelAnimate:GetAnimNode()
	return self.anim_node
end

function ModelAnimate:Show(anim_id)
	self.dir = self.dir_default
	if anim_id and self.anim_id ~= anim_id then
		self.anim_id = anim_id
		self:UpdateAnim()
	end
end

function ModelAnimate:RemoveFromParent()
	self.anim_node:removeFromParent()
	self.anim_node = nil
end

function ModelAnimate:SetZOrder(zorder)
	self.anim_node:setLocalZOrder(zorder)
end

function ModelAnimate:SetTag(tag)
	self.anim_node:setTag(tag)
end

function ModelAnimate:SetDirection(dir)
	self.dir_default = dir
end

function ModelAnimate:SetPathFunc(path_func)
	self.anim_path_func = path_func
end

function ModelAnimate:SetAnimStatus(status)
	self.anim_status = status
end

function ModelAnimate:SetAnimPosition(x, y)
	self.anim_node:setPosition(x, y)
end

function ModelAnimate:GetAnimPosition()
	return self.anim_node:getPosition()
end

-- 设置帧间隔
function ModelAnimate:SetFrameInterval(interval)
	self.frame_interval = interval
	self.anim_node:setFrameInterval(interval)
end

function ModelAnimate:SetLoops(loops)
	self.loops = loops
end

-- 设置动画可见区域
function ModelAnimate:SetViewRect(rect)
	self.anim_node:setViewRect(rect)
end

-- 取消动画可见区域设置
function ModelAnimate:CancelUseViewRect()
	self.anim_node:cancelUseViewRect()
end

function ModelAnimate:SetIsPauseLastFrame(value)
	self.anim_node:setIsPauseLastFrame(value)
end

function ModelAnimate:SetStop()
	self.anim_node:setStop()
end

function ModelAnimate:SetElapsed(time)
	self.anim_node:setElapsed(time)
end

-- 是否显示动画
function ModelAnimate:SetVisible(visible)
	self.anim_node:setVisible(visible)
end

function ModelAnimate:SetScale(scale)
	self.anim_node:setScale(scale)
end


function ModelAnimate:MakeGray(value)
	AdapterToLua:makeGray(self.anim_node, value)
end

function ModelAnimate:GetScale()
	return self.anim_node:getScale()
end

function ModelAnimate:SetRotation(rotation)
	self.anim_node:setRotation(rotation)
end

-- 刷新动画
function ModelAnimate:UpdateAnim()
	if self.anim_id <= 0 then
		self.anim_node:setStop()
		return
	end

	if nil ~= self.anim_path_func then
		local dir_num, is_flip_x = GameMath.GetResDirNumAndFlipFlag(self.dir)
		local path, name = self.anim_path_func(self.anim_id, self.anim_status, dir_num)
		self.anim_node:setAnimate(path, name, self.loops, self.frame_interval, is_flip_x)
	end
end

-- 顺时针旋转
function ModelAnimate:TurnRight()
	if -1 ~= self.anim_id and nil ~= self.anim_node then
		self.dir = self.dir + 1
		if self.dir > 3 then
			self.dir = 0
		end
		self:UpdateAnim()
	end
end

-- 逆时针旋转
function ModelAnimate:TurnLeft()
	if -1 ~= self.anim_id and nil ~= self.anim_node then	
		self.dir = self.dir - 1	
		if self.dir < 0 then
			self.dir = 3
		end
		self:UpdateAnim()
	end
end

function ModelAnimate:RunAction(action)
	if nil ~= action then
		self.anim_node:runAction(action)
	end
end

function ModelAnimate:StopAction(action)
	if nil ~= action then
		self.anim_node:stopAction(action)
	end
end

function ModelAnimate:StopAllActions()
	self.anim_node:stopAllActions()
end
