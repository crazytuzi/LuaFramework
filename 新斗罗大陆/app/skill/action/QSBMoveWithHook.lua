local QSBAction = import(".QSBAction")
local QSBMoveWithHook = class("QSBMoveWithHook", QSBAction)
local QActor = import("...models.QActor")
local QBaseEffectView
if not IsServerSide then
	QBaseEffectView = import("...views.QBaseEffectView")
end

function QSBMoveWithHook:ctor(director, attacker, target, skill, options )
    QSBMoveWithHook.super.ctor(self, director, attacker, target, skill, options)
    self._head_effect_id = options.head_effect_id
    self._body_src = options.body_src
    self._progress = 0

    self._step = 0
end

function QSBMoveWithHook:_execute(dt)
	--因为一些参数是要从别的脚本里传过来 所以必须从这里初始化
	if self._hero_end_position == nil then
		self:initPosition()
	end


	if not self._head_effect_id or not self._body_src or not self._target_position then
		self:finished()
		return
	end

	--第一步先初始化钩子
	if self._step == 0 then
		self:initHook()
		self._step = 1
		self._progress = 0
		self._passed_time = 0
		return
	end
	--钩子飞到制定目标
	if self:onStep1(dt) then
		self._step = 2
		self._progress = 0
		self._passed_time = 0
		return
	end
	--英雄移动过去,并收回钩子
	if self:onStep2(dt) then
		self._step = -1
		self:finished()
	end
end

function QSBMoveWithHook:initPosition()
	local options = self._options
	--英雄位移到的目标位置
    local targetPosition = options.target_pos or self._attacker:getDragPosition()
    if targetPosition == nil then
    	self._target_position = nil
    	return
    end
    local grid_area = app.grid:getRangeArea()
	if targetPosition.x < grid_area.left then targetPosition.x = grid_area.left end
    if targetPosition.x > grid_area.right then targetPosition.x = grid_area.right end
    if targetPosition.y < grid_area.bottom then targetPosition.y = grid_area.bottom end
    if targetPosition.y > grid_area.top then targetPosition.y = grid_area.top end
    self._hero_end_position = targetPosition
   	--表现层移动到的目标位置
    self._target_position = {x = self._hero_end_position.x, y = self._hero_end_position.y}

    local distance = q.distOf2Points(self._hero_end_position, self._attacker:getPosition())

    self._animation_time = distance/options.animation_speed
    self._move_time = distance/options.move_speed
end

function QSBMoveWithHook:initHook()
	if self._step ~= 0 then return end
	local actorPos = clone(self._attacker:getPosition())
	--英雄的起始位置
	self._hero_start_pos = {x = actorPos.x, y = actorPos.y}
	actorPos.y = actorPos.y + self._attacker:getRect().size.height / 2 + (self._options.start_off and self._options.start_off.y or 0)
	actorPos.x = actorPos.x + (self._options.start_off and self._options.start_off.x or 0)
	--表现层的起始位置
	self._start_pos = actorPos
	if not IsServerSide then
		self._baseNode = display.newNode()
		self._head = QBaseEffectView.createEffectByID(self._head_effect_id)
		self._body = display.newSprite(self._body_src)
		self._body:setAnchorPoint(0,1)
		self._baseNode:addChild(self._head, 1)
		self._baseNode:addChild(self._body, -1)
		if self._options.body_offset then
			self._body:setPosition(ccp(self._options.body_offset.x, self._options.body_offset.y))
		end
		self._baseNode:setRotation(math.atan2(self._target_position.y - actorPos.y, self._target_position.x - actorPos.x) * (-180) / math.pi)
		self._baseNode:setPosition(ccp(self._start_pos.x, self._start_pos.y))
		self._baseNode:setScaleY((self._target_position.x - actorPos.x) >= 0 and 1 or -1)
		self._body:setScaleX(0)
		self._baseNode._dummy_as_position = self._head._dummy_as_position	--为了在QBattleScene:removeAllDummyAsPositionViews()中删除
		app.scene:addEffectViews(self._baseNode, {isGroundEffect = true})
		self._head:playAnimation(self._head:getPlayAnimationName(), true)
	end
	self._attacker:lockDrag()
    function self._attacker:canMove() return false end
end

function QSBMoveWithHook:onStep1(dt)
	if self._step ~= 1 then return end
	self._passed_time = self._passed_time + dt
	self._progress = math.clamp( self._passed_time / self._animation_time , 0, 1)

	if not IsServerSide then
		self._baseNode:setPosition(ccp(self._target_position.x * self._progress + (1 - self._progress) * self._start_pos.x, self._target_position.y * self._progress + (1 - self._progress) * self._start_pos.y))
		self._body:setScaleX(q.distOf2Points(self._start_pos, self._target_position)/self._options.body_width * self._progress * (-1))
	end

	if self._progress >= 0.9999 then
		return true
	end
end

function QSBMoveWithHook:onStep2(dt)
	if self._step ~= 2 then return end
	self._passed_time = self._passed_time + dt
	self._progress = math.clamp( self._passed_time / self._move_time , 0, 1)

	local newx = self._hero_end_position.x * self._progress + (1 - self._progress) * self._hero_start_pos.x
	local newy = self._hero_end_position.y * self._progress + (1 - self._progress) * self._hero_start_pos.y

	local _, gridPos = app.grid:_toGridPos(newx, newy)
    app.grid:_resetActorFollowStatus(self._attacker)
    app.grid:_setActorGridPos(self._attacker, gridPos, nil, true)

    self._attacker:setActorPosition({x = newx, y = newy})

    if not IsServerSide then
 	   self._body:setScaleX(q.distOf2Points(self._start_pos, self._target_position)/self._options.body_width * (1 - self._progress) * (-1))
    end

	if self._progress >= 0.9999 then
		return true
	end
end

function QSBMoveWithHook:finished()
	QSBMoveWithHook.super.finished(self)
	if (not IsServerSide) and self._baseNode then
		self._head:stopAnimation()
		app.scene:removeEffectViews(self._baseNode)
	end
	self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

-- cancel会调用finished
-- function QSBMoveWithHook:_onCancel()
--     if (not IsServerSide) and self._baseNode then
-- 		self._head:stopAnimation()
-- 		app.scene:removeEffectViews(self._baseNode)
-- 	end
-- 	self._attacker:unlockDrag()
--     self._attacker.canMove = QActor.canMove
-- end

return QSBMoveWithHook
