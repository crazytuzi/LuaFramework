--WeddingCar.lua
--/*-----------------------------------------------------------------
 --* Module:  WeddingCar.lua
 --* Author:  goddard
 --* Modified: 2016年9月18日
 --* Purpose: 婚车信息
 -------------------------------------------------------------------*/

WeddingCar = class()

function WeddingCar:__init(info, wedding)
	self._info = info
	self._wedding = wedding
	self._lastCarDropItemTime = nil
	self._weddingCarRunningStatus = WEDDINGCAR_MOVE_STATUS.UNSTART
	self._weddingCarStopTime = nil
	self._targetID = nil
	self._targetStep = nil
	self._startMove = false
	self._onCarFlag = {}
end

function WeddingCar:update(time)
	if not self._targetID then
		self:createCar()
	end
	if WEDDINGCAR_MOVE_STATUS.UNSTART == self._weddingCarRunningStatus and (time >= (self._wedding._createCarTime + WEDDING_CAR_START_PERIOD)) then
		self:startMove()
	end
	if WEDDINGCAR_MOVE_STATUS.UNSTART ~= self._weddingCarRunningStatus then
		if WEDDINGCAR_MOVE_STATUS.MOVING == self._weddingCarRunningStatus then
			self:dropProcess(time)
		elseif WEDDINGCAR_MOVE_STATUS.ARRIVED == self._weddingCarRunningStatus then
			if not self._weddingCarStopTime then
				self._weddingCarStopTime = time
			end
			if self._weddingCarStopTime > WeddingCarConfig.q_continue_destination then
				local target = g_entityMgr:getMonster(self._targetID)
				if target then
					target:dropItemByDropID(WeddingCarConfig.q_last_dropid)
				end
				self:finish()
			end
		end
	end
end

function WeddingCar:dropProcess(time)
	if not self._lastCarDropItemTime then
		self._lastCarDropItemTime = time
	end
	local drop_period = time - self._lastCarDropItemTime
	if drop_period > WeddingCarConfig.q_drop_period then
	local target = g_entityMgr:getMonster(self._targetID)
	if target then
		target:dropItemByDropID(WeddingCarConfig.q_running_dropid)
	end
	self._lastCarDropItemTime = time
	end
end

function WeddingCar:startMove()
	self._targetStep = 1
	self._weddingCarRunningStatus = WEDDINGCAR_MOVE_STATUS.MOVING
	self:move(WEDDING_CAR_SPEED)
end

function WeddingCar:createCar()
	target = g_entityFct:createMonster(WeddingCarConfig.q_monster_id)
	if target then
		local carName = self._info:getMaleName() .. "与" .. self._info:getFemaleName() .. "的婚车"
		target:setName(carName)
		self._targetID = target:getID()
		g_sceneMgr:enterPublicScene(self._targetID, WeddingCarConfig.q_map_id, WEDDINGCAR_RUNNING_ROUTE[1].x, WEDDINGCAR_RUNNING_ROUTE[1].y)
		local scene = target:getScene()
		if scene then
			scene:addMonster(target)
		end
		g_marriageMgr:addWeddingCarMap(self._targetID, self._info)

		local pos = target:getPosition()
		local ret = {
						x = pos.x,
						y = pos.y,
						targetID = self._targetID,
					}
		local male = self._info:getMale()
		if male then
			fireProtoMessage(male:getID(), MARRIAGE_SC_WEDDING_CAR_START, "MarriageSCWeddingCarStart", ret)
		end
		local female = self._info:getFemale()
		if female then
			fireProtoMessage(female:getID(), MARRIAGE_SC_WEDDING_CAR_START, "MarriageSCWeddingCarStart", ret)
		end
	end
end

function WeddingCar:move(moveSpeed)
	local target = g_entityMgr:getMonster(self._targetID)
	if target then
		self._moveState = ConvoyMoveState.move
		self._moveStamp = os.time()

		local pos = target:getPosition()
		local posStep = WEDDINGCAR_RUNNING_ROUTE[self._targetStep]
		if pos.x == posStep.x and pos.y == posStep.y then
			self._targetStep = self._targetStep + 1
		end

		posStep = WEDDINGCAR_RUNNING_ROUTE[self._targetStep]
		if not posStep then
			return
		end

		local dir, len = GetMoveDirAndLen(pos, posStep, true)
		if dir == nil then
			return
		end

		target:setMoveSpeed(moveSpeed)
		target:moveDir(dir, 0, len)
	end
end

function WeddingCar:stopMove(monID)
	if monID ~= self._targetID then
		return
	end
	local target = g_entityMgr:getMonster(self._targetID)
	if target then
		local pos = target:getPosition()
		for _, player in pairs(self._onCarFlag) do
			if player then
				player:setPosition(pos)
			end
		end
		local posStep = WEDDINGCAR_RUNNING_ROUTE[#(WEDDINGCAR_RUNNING_ROUTE)]
		if #(WEDDINGCAR_RUNNING_ROUTE) == self._targetStep and pos.x == posStep.x and pos.y == posStep.y then
			g_marriageMgr:delWeddingCarMap(self._targetID)
			self._weddingCarRunningStatus = WEDDINGCAR_MOVE_STATUS.ARRIVED
		else
			self:move(WEDDING_CAR_SPEED)
		end
	end
end

function WeddingCar:finish()
	local target = g_entityMgr:getMonster(self._targetID)
	if target then
		g_entityMgr:destoryEntity(self._targetID)
		g_marriageMgr:delWeddingCarMap(self._targetID)
		self._targetID = nil
	end
	self._wedding:weddingCarFini()
end

function WeddingCar:reqWeddingOnTheCar(player)
	if not self._targetID then
		return false, MarriageErrorCode.WeddingCarOnNoCar
	end
	local target = g_entityMgr:getMonster(self._targetID)
	if not target then
		return false, MarriageErrorCode.WeddingCarOnNoCar
	end
	local pos = target:getPosition()
	player:setPosition(pos)
	player:setShowStatus(0)
	self._onCarFlag[player:getSerialID()] = player
	return true
end

function WeddingCar:reqWeddingUnderTheCar(player)
	player:setShowStatus(1)
	self._onCarFlag[player:getSerialID()] = nil
end

function WeddingCar:onPlayerOffline(player)
	if self._onCarFlag[player:getSerialID()] then
		player:setShowStatus(1)
		self._onCarFlag[player:getSerialID()] = nil
	end
end