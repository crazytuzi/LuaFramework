


local QUIMazeExploreMapController = class("QUIMazeExploreMapController")
local QMazeExplore = import(".QMazeExplore")
local QNotificationCenter = import("...controllers.QNotificationCenter")


QUIMazeExploreMapController.TIMER_UPDATE = "MazeExploreMap_TIMER_UPDATE"
QUIMazeExploreMapController.PACE_UPDATE = "MazeExploreMap_PACE_UPDATE"
QUIMazeExploreMapController.PACE_UPDATE_REMOVE = "MazeExploreMap_PACE_UPDATE_REMOVE"

QUIMazeExploreMapController.MAP_GRID_UPDATE_UPDATE = "MazeExploreMap_MAP_GRID_UPDATE_UPDATE"

QUIMazeExploreMapController.MAP_GRID_EVENT_SECRET_BE_SHOW = "MazeExploreMap_GRID_EVENT_SECRET_BE_SHOW"

QUIMazeExploreMapController.MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE = "MazeExploreMap_MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE"

QUIMazeExploreMapController.PER_GRID_WIDTH = 182
QUIMazeExploreMapController.PER_GRID_HEIGHT = 92


QUIMazeExploreMapController.MOVE_PACE_DUR = 0.5	--移动一格的时间。角色与npc公用


QUIMazeExploreMapController.DEBUG = 0
QUIMazeExploreMapController.CHECKGRIDCONNECT = 0
QUIMazeExploreMapController.CHECKGRIDEVENTTYPE = 0
QUIMazeExploreMapController.OPENALL = 0
QUIMazeExploreMapController.NEED_OPEN_GRID_TEXT = 1


--活动目标类型枚举类型 对应 activityTargetId
QUIMazeExploreMapController.GRID_TYPE ={
	INVISIBLE = 0, 			--不可见
	VISIBLE = 99, 			--可见             	

	--与服务器对应
	DEFAULT = 1, 			--默认状态 关闭
	OPEN = 2, 				--开启
	NULL_EVENT = 3,      	--失效     

}

QUIMazeExploreMapController.MOVEMENT_STATE ={	
	MOVEMENT_STATE_DAULT = 0,                        	
	MOVEMENT_STATE_STOP = 1, 				--走到后停止处理事件                       	
	MOVEMENT_STATE_CAN_NOT_WALK_NEXT = 2,   --无法向下当前格子进行移动                 	    	

}

function QUIMazeExploreMapController:ctor(chapterId)
	self._chapterId = chapterId or 1
	self._mapSvrInfo = {}
	self._paceCount = 0
	self._inTostabConfig = nil
	self._moveGrid = nil 
	self._isRemoveEventOn=false
	self._endId = 0
	self:_initMapData()
	self:_check()
	self:_startTimer()
	self._isInitData = false

    self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsProxy:addEventListener(QMazeExplore.GRID_INFO_UPDATE, handler(self, self.onGridInfoUpdate))
    self._activityRoundsProxy:addEventListener(QMazeExplore.STOP_TIMER, handler(self, self._stopTimer))
    self._activityRoundsProxy:addEventListener(QMazeExplore.CONTINUE_TIMER, handler(self, self._countinueTimer))

end

function QUIMazeExploreMapController:disappear()
	self:saveData()
	self._chapterId = 1
	self._mapSvrInfo = {}
	self._paceCount = 0
	self._cdTimer = 0
	self._isFirstEnter = false
	self:_stopTimer()
	self._moveGrid = nil 
	self._isBeforeShowBoss = false 
	self._endId = 0
	self._isInitData = false
    if self._activityRoundsProxy ~= nil then 
        self._activityRoundsProxy:removeAllEventListeners()
        self._activityRoundsProxy = nil
    end

end


function QUIMazeExploreMapController:saveData(e)
	local gridKey = self:getGridKeyByGridTbl(self._myGrid)	
	local gridData = self._gridsTbl[gridKey]
	local curGridId = gridData.id

	self._mazeExploreDataHandle:MazeExploreSavePosRequest(self._chapterId , curGridId , self._paceCount)
end

function QUIMazeExploreMapController:onGridInfoUpdate(e)
	self._updateGridsTbl = {}
	self._updateLinesTbl = {}
	print("QUIMazeExploreMapController:onGridInfoUpdate(e)")
	local svrData = self._mazeExploreDataHandle:getMazeExploreChangeChapterGrids()
	-- QPrintTable(svrData)
	for k,v in pairs(svrData or {}) do
		self._mapSvrInfo[v.gridId] = v.gridStatus
		self:_updateMapDataById(v.gridId)
	end
	-- QPrintTable(self._updateGridsTbl)
	-- QPrintTable(self._updateLinesTbl)	
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.MAP_GRID_UPDATE_UPDATE})	

end


function QUIMazeExploreMapController:debugLocalCheatData(id)
	-- print(id)
	self._updateGridsTbl = {}
	self._updateLinesTbl = {}
	if self._mapSvrInfo[id] == nil then
		self._mapSvrInfo[id] = QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT
		self:_updateMapDataById(id)
	end
	-- QPrintTable(self._updateGridsTbl)
	-- QPrintTable(self._updateLinesTbl)
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.MAP_GRID_UPDATE_UPDATE})
end

--根据地图层传输的数据	更新角色位置、处理地格事件
function QUIMazeExploreMapController:updateRolePositionAndHandleEvent(grid)
	local lastGrid = clone(self._myGrid)

	-- QPrintTable(lastGrid)
	-- QPrintTable(grid)
	local movementState = self:handleGridEvent(grid , lastGrid)

	if QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_CAN_NOT_WALK_NEXT ~= movementState then
		self:setMyGridPos(grid)
		self._paceCount = self._paceCount + 1
		if not self._isRemoveEventOn then
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.PACE_UPDATE, paceCount = self._paceCount})
		end
		if self._isBeforeShowBoss then
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE, visible = false})
			self._isBeforeShowBoss = false
		end

	end
	return movementState
end

-- ------------------------------event---------------------------------------------
-- --格子事件
-- QMazeExplore.ENUMERATE_GRID_EVENT = {	
-- 	GRID_EVENT_NORMAL = 0,                       	--普通格子
-- 	GRID_EVENT_FIXAWARDS = 1,                    	--固定奖励
-- 	GRID_EVENT_RANDAWARDS = 2,                   	--随机奖励
-- 	GRID_EVENT_EVENTAWARDS = 3,                  	--事件奖励
-- 	GRID_EVENT_CHESTAWARDS = 4,						--宝箱奖励
-- 	GRID_EVENT_ACTORSPECK = 5,						--半身像对话
-- 	GRID_EVENT_TXTSPECK	= 6,						--文本剧情
-- 	GRID_EVENT_PORTAL = 7,							--传送门
-- 	GRID_EVENT_SECRET_ONOFF = 8,					--暗格开/关
-- 	GRID_EVENT_SECRET_BE = 9,						--暗格对象
-- 	GRID_EVENT_LIGHTHOUSE = 10,						--灯塔
-- 	GRID_EVENT_ROCKS = 11,							--落石
-- 	GRID_EVENT_SOLDIERS = 12,						--追兵
-- 	GRID_EVENT_REMOVE = 13,							--解除
-- 	GRID_EVENT_LIFTS_ONOFF = 14,					--升降台升/降
-- 	GRID_EVENT_LIFTS_BE = 15,						--升降台对象
-- 	GRID_EVENT_TOSTAB = 16,							--地刺
-- 	GRID_EVENT_FINGERGAME = 17,						--猜拳
-- 	GRID_EVENT_DICE = 18,							--掷骰子
-- 	GRID_EVENT_BOSS = 19,							--BOSS
-- }
-- --------------------------------------------------------------------------------

function QUIMazeExploreMapController:handleGridEvent(grid,lastGrid)
	local gridKey = self:getGridKeyByGridTbl(grid)	
	local gridData = self._gridsTbl[gridKey]

	if gridData then
		-- QPrintTable(gridData)
		self._inTostabConfig = nil
		if QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT == gridData.state then
			return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
		else
			local idx = tonumber(gridData.id)
			local config = self._gridConfigs[idx]
			--先走再触发事件
			if not self._mapSvrInfo[idx] then -- 没有走过这个格子
				if self:_judgeMoveCostPowerEnergy(gridData) then --判断走一步的精神力
					self._mazeExploreDataHandle:mazeExploreMoveRequest(idx)
				 --  if QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == config.event_type then
					-- 	self._mazeExploreDataHandle:EventTriggerByGridInfo(config)
					-- 	return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_STOP	
				 --  else
					-- self._mazeExploreDataHandle:mazeExploreMoveRequest(idx)
				 --  end
				else
					return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_CAN_NOT_WALK_NEXT
				end
			end

			if config then
				local eventType = tonumber(config.event_type)
				
				for k,v in pairs(QMazeExplore.ENUMERATE_GRID_EVENT or {}) do
					if v == eventType then
						if QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB == v then
							self._inTostabConfig = config
							return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
							-- if not self:_judgeRoleHurtByTostab(config) then
							-- 	-- app.tip:floatTip("没刺到～～～～～!")
							-- 	return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
							-- else
							-- 	-- app.tip:floatTip("刺到我了～～～～～!")
							-- end
						elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == v then
							if self._isRemoveEventOn or not self:_judgeRoleHurtBySoldiers(config ,lastGrid ) then
								-- app.tip:floatTip("没撞着～～～～～!")
								return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
							end
						elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS == v and self._isRemoveEventOn then
							return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
						elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS == v  then --路过boss格子可以不进入事件处理
							if idx ~= self._endId then
								return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
							else
								QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE, visible = true})
							end
						elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE == v
							or QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE == v
							or QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL == v
							-- or QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == v
						then
						 	return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
						elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == v then --传送门之后没开的格子需要自动开启
							if self._mapSvrInfo[idx] and config.parameter and tonumber(config.parameter) and not self._mapSvrInfo[config.parameter] then
								if self:_judgeMoveCostPowerEnergy({state = QUIMazeExploreMapController.GRID_TYPE.VISIBLE}) then --判断走一步的精神力
									self._mazeExploreDataHandle:mazeExploreMoveRequest(tonumber(config.parameter))
								end
							end
						end 
						if QUIMazeExploreMapController.DEBUG == 1 then
							-- self:debugLocalCheatData(idx)
						else
							-- self:debugLocalCheatData(idx)
							self._eventConfig = config
							-- self._mazeExploreDataHandle:EventTriggerByGridInfo(config)
						end
						return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_STOP	
					end
				end
			end

			return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_STOP
		end

	end


	return QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT
end

function QUIMazeExploreMapController:handleGridEventAfterMove()
	if self._eventConfig  then
		local needRequest = true
		local eventType = tonumber(self._eventConfig.event_type)
		local idx = tonumber(self._eventConfig.id)
		if eventType == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE then
			print(self._mapSvrInfo[idx])
			if self._mapSvrInfo[idx] and self._mapSvrInfo[idx] == QUIMazeExploreMapController.GRID_TYPE.OPEN then
				needRequest = false
			end
		elseif eventType == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT then
			if self._mapSvrInfo[idx] and self._mapSvrInfo[idx] == QUIMazeExploreMapController.GRID_TYPE.OPEN then
				needRequest = false
			end			
		elseif eventType == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS then
			self._isBeforeShowBoss = true
			print("handleGridEventAfterMove " .. QUIMazeExploreMapController.MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE)
			-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE, visible = true})
		end
		self._mazeExploreDataHandle:EventTriggerByGridInfo(self._eventConfig,needRequest)
	end
end


function QUIMazeExploreMapController:_judgeRoleHurtByTostab(gridConfig)

	local parameter = gridConfig.parameter
	local movementParts = string.split(parameter, ",")
	local timerRemain = self._cdTimer - tonumber(movementParts[1]) or 0
	local isHurt = (timerRemain %  (tonumber(movementParts[2]) or 2 )) == 0
	return isHurt
end


function QUIMazeExploreMapController:_judgeRoleHurtBySoldiers(gridConfig ,lastGrid)


	local endIdx = gridConfig.id	
	local gridKey = self:getGridKeyByGridTbl(lastGrid)	
	local lastIdx = self._gridsTbl[gridKey].id
	local config = self._gridConfigs[lastIdx]
	local paceCount = self._paceCount + 1
	-- print(endIdx)
	-- print(lastIdx)

	local parameter = gridConfig.parameter
	local movementParts = string.split(parameter, ";")
	for k,v in pairs(movementParts or {}) do
		local moveInfo =  string.split(v, ",")
		if #moveInfo >= 3 then
			local interval = tonumber(moveInfo[1])
			local key = tonumber(moveInfo[2])
			local targetGridId = moveInfo[3]
		
			if (paceCount % interval) == key then
				print("hurt1")
				print(interval)
				print(paceCount)
				print(key)				
				return true
			end
		end
	end

	parameter = config.parameter
	movementParts = string.split(parameter, ";")
	for k,v in pairs(movementParts or {}) do
		local moveInfo =  string.split(v, ",")
		if #moveInfo >= 3 then
			local interval = tonumber(moveInfo[1])
			local key = tonumber(moveInfo[2])
			local targetGridId = moveInfo[3]
			if (paceCount % interval) == key and tonumber(endIdx) == tonumber(targetGridId) then
				print("hurt2")
				print(interval)
				print(paceCount)
				print(key)
				return true
			end
		end
	end

	return false
end

function QUIMazeExploreMapController:moveToGirdId(gridId)
	self._mazeExploreDataHandle:mazeExploreMoveRequest(gridId)
end


function QUIMazeExploreMapController:_judgeMoveCostPowerEnergy(gridData)

	if gridData and gridData.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
		local cost  = db:getConfigurationValue("power_consume") or 0 
		if self._mazeExploreDataHandle:getMazeExplorePowers() < tonumber(cost) then
			app.tip:floatTip("精神力不足无法继续移动!")
			return false 
		end
	end
	return true
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
function QUIMazeExploreMapController:_check()

	if  QUIMazeExploreMapController.CHECKGRIDCONNECT  ==0  and  QUIMazeExploreMapController.CHECKGRIDEVENTTYPE ==0  then
		return
	end
	for i=1,6 do
		local gridConfigs = self._mazeExploreDataHandle:getMazeExploreConfigsByChapterId(i)
		for _,v in pairs(gridConfigs) do
			local coord = string.split(v.coordinate, ",")
			if QUIMazeExploreMapController.CHECKGRIDEVENTTYPE then
				if not v.event_type then
					print("error id :"..v.id.." do not have event_type")
				end
			end
			if #coord > 1 then
				if QUIMazeExploreMapController.CHECKGRIDCONNECT then
					local connectIds = string.split(v.connect_id, ",")
					for k,conn_id in pairs(connectIds or {}) do
						if gridConfigs[tonumber(conn_id)] then

							local frontId ,behindId = v.id,tonumber(conn_id)
							local neighborIds = string.split(gridConfigs[behindId].connect_id, ",")
							local isNeighbor = false 
							for i,v in ipairs(neighborIds) do
								local id = tonumber(v)
								if id == tonumber(frontId) then
									isNeighbor = true
								end
							end
							if not isNeighbor then
								print("id :"..behindId.." not have neighbor id :"..frontId)
							end
						end
					
					end
				end
			end
		end
	end
end


function QUIMazeExploreMapController:getCurProgress()
	local curProgress = 0
	if self._mazeExploreDataHandle then
		curProgress = self._mazeExploreDataHandle:getMazeExploreProgress()
	end
	return curProgress * 100
	-- for k,v in pairs(self._mapSvrInfo) do
	-- 	local config = self._gridConfigs[k]
	-- 	if config then
	-- 		if 	config.event_type ~= QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL
	-- 			-- or config.event_type ~= QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_STARTPOINT
	-- 			-- or config.event_type ~= QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT
	-- 			then
	-- 			curProgress = curProgress + 1
	-- 		end
	-- 	end
	-- end
	-- -- print("getCurProgress"..curProgress)
	-- -- print("getCurProgress"..(self._totleEventGridCount or 1) )

	-- return curProgress / (self._totleEventGridCount or 1) * 100
end


--读取配置表获得地格基本信息
function QUIMazeExploreMapController:_initMapData()
	self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()
	-- if self._mazeExploreDataHandle == nil then
	-- 	self._mazeExploreDataHandle = QMazeExplore.new("MAZE_EXPLORE")
	-- end	
	self._gridConfigs = self._mazeExploreDataHandle:getMazeExploreConfigsByChapterId(self._chapterId)
	self._gridsTbl = {}
	self._linesTbl = {}
	self._mapSvrInfo = {}
	self._isRemoveEventOn = false
	self._maxiGridWidth = 0
	self._maxiGridHeight = 0
	self._paceCount = self._mazeExploreDataHandle:getMazeExploreMoveCount() or 0
	self._endId = 0
	self._isBeforeShowBoss = false 
	self._myGrid = {0,0}
	self._endGrid = {1,1}

	self._totleEventGridCount = 0

	self._hurtGrid = {1,1}
	self._bossGridId = 0
	self._moveGrid = nil 
	self._removeGridId = nil

	-- QPrintTable(self._gridConfigs)
	-- QPrintTable(self._idCotgrCoord)
	for _,v in pairs(self._gridConfigs) do
		local coord = string.split(v.coordinate, ",")
		if #coord > 1 then
			-- QPrintTable(v)
			-- QPrintTable(coord)
			--记录起点为我当前所在地格
			-- local gridType = QUIMazeExploreMapController.GRID_TYPE.INVISIBLE
			if 	v.event_type ~= QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL
				-- or v.event_type ~= QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_STARTPOINT
				-- or v.event_type ~= QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT
				then
				self._totleEventGridCount = self._totleEventGridCount + 1
			end
			if v.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE then
				self._removeGridId = tonumber(v.id)
			end
			if v.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_STARTPOINT then
				self._myGrid = coord
				-- QPrintTable(self._myGrid)
				self._mapSvrInfo[v.id] = QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT
				-- gridType = QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT
			end
			if v.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS then
				self._bossGridId = tonumber(v.id)
			end

			--记录终点
			if v.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT then
				self._endGrid = coord
				-- QPrintTable(self._endGrid)
			end
			if QUIMazeExploreMapController.OPENALL ~=0 then
				self._mapSvrInfo[v.id] = QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT
				--DEFAULT
			end
				-- self._mapSvrInfo[v.id] = QUIMazeExploreMapController.GRID_TYPE.DEFAULT

			--计算最大地格数
			if self._maxiGridWidth < tonumber(coord[1]) then
				self._maxiGridWidth = tonumber(coord[1])
			end
			if self._maxiGridHeight < tonumber(coord[2]) then
				self._maxiGridHeight = tonumber(coord[2])
			end
		end
	end

	local svrData = self._mazeExploreDataHandle:getMazeExploreCurChapterGrids()
	QPrintTable(svrData)
	local isfirst = self._mazeExploreDataHandle:checkIsFirstEnterChapter(self._chapterId)
	print(#svrData)
	print(isfirst)
	if #svrData == 0 and isfirst then
		self._isFirstEnter = true
	end
	for k,v in pairs(svrData or {}) do
		if not self._mapSvrInfo[k] then
			self._mapSvrInfo[k] = v
		end
	end

	local svrCurId = self._mazeExploreDataHandle:getMazeExploreGridId()
	if self._gridConfigs[svrCurId] then
		self._myGrid = string.split(self._gridConfigs[svrCurId].coordinate, ",")
		-- QPrintTable(self._myGrid)
	end
	self._isInitData = true
	self:_updateMapDataBySvr()
	self._isInitData = false

end
--根据服务器信息刷新数据
function QUIMazeExploreMapController:_updateMapDataBySvr()
	self._updateGridsTbl = {}
	self._updateLinesTbl = {}

	if self._removeGridId and self._mapSvrInfo[self._removeGridId] == QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT then
		self._isRemoveEventOn = true
	end

	for k,v in pairs(self._mapSvrInfo) do
		self:_updateMapDataById(k)
	end

end

function QUIMazeExploreMapController:_updateBossInfo()
	if self._bossGridId ~= nil then
		self:_updateMapDataById(self._bossGridId)
		--需要特殊刷新终点的地格 防止 地格与boss格不相邻时出现状态刷新不及时的问题
		local isLock = self._mazeExploreDataHandle:getPassStarByDungeonId(self._chapterId) < 1 
		local gridKey = self:getGridKeyByGridTbl(self._endGrid)
		local data = self._gridsTbl[gridKey]
		if data and QUIMazeExploreMapController.GRID_TYPE.VISIBLE == data.state then
			local config = self._gridConfigs[tonumber(data.id)]
			if config then
				local connectIds = string.split(config.connect_id, ",")
				for k,conn_id in pairs(connectIds or {}) do
					local conConfig = self._gridConfigs[tonumber(conn_id)]
					if conConfig  then
						local coordOther = string.split(conConfig.coordinate or "", ",")
						local maxGridX = math.max(self._endGrid[1] , coordOther[1])
						local maxGridY = math.max(self._endGrid[2] , coordOther[2])
						local strLine = self:getGridKeyByGrid(maxGridX,maxGridY)
						if self._linesTbl[strLine] then
							self._linesTbl[strLine].isLock = isLock
							self._updateLinesTbl[strLine] = self._linesTbl[strLine]
						end
					end
				end
			end
		end
	end
end


--******************主要刷新数据的处理函数******************
function QUIMazeExploreMapController:_updateMapDataById(id)
	local config = self._gridConfigs[id]
	if config == nil then
		print("_updateMapDataById	id :"..id.."	not find")
		return
	end
	local state = self._mapSvrInfo[id]
	local coord = string.split(config.coordinate, ",")
	local gridKey = self:getGridKeyByGridTbl(coord)
	local event_type = tonumber(config.event_type)

	local isNpc = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == event_type and not self._isRemoveEventOn
	local isLockType = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME == event_type 
	or event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE 
	isLockType = isLockType and state == QUIMazeExploreMapController.GRID_TYPE.DEFAULT
	local gridData = {id = config.id , gridX = coord[1] , gridY = coord[2] , state = state , config = config ,isNpc = isNpc ,paceCount = self._paceCount}

	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS then
		if tonumber(self._myGrid[1]) == tonumber(coord[1]) and tonumber(self._myGrid[2]) == tonumber(coord[2]) then
			self._isBeforeShowBoss = true 
			gridData.isOnBoss = true
		end
	end

	self._gridsTbl[gridKey] = gridData
	self._updateGridsTbl[gridKey] = gridData

	self:_setConnectGridAndLineVisible(config,coord,isNpc , isLockType)
	self:_checkConcealedGridOnOff(config,state)
	self:_checkGridLiftsOnOff(config,state)
	self:_checkGridIsRemove(config,state)
	self:_checkBoss(config,gridKey)

end


function QUIMazeExploreMapController:_checkGridIsRemove(config,state)
	local event_type = tonumber(config.event_type)
	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE and state == QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT then
		self._isRemoveEventOn = true
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.PACE_UPDATE, paceCount = -1})
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.PACE_UPDATE_REMOVE})
	end
end

function QUIMazeExploreMapController:_checkBoss(config,gridKey)
	local event_type = tonumber(config.event_type)
	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS then
		local starNum = self._mazeExploreDataHandle:getPassStarByDungeonId(self._chapterId)
		self._gridsTbl[gridKey].Star = starNum
		self._updateGridsTbl[gridKey] = self._gridsTbl[gridKey]
	end
end



function QUIMazeExploreMapController:_setConnectGridAndLineVisible(config,coord,isNpc, isLockType, NpcConnect)
	local connectIds = string.split(config.connect_id, ",")
	for k,conn_id in pairs(connectIds or {}) do
		local conConfig = self._gridConfigs[tonumber(conn_id)]
		if conConfig and self:_checkConnectGridVisible(conConfig ,config) then
			self:_setGridAndLineVisible(conConfig,coord , isNpc, isLockType,NpcConnect)
		end
	end
end	

function QUIMazeExploreMapController:_setGridAndLineVisible(config,coord ,isNpc, isLockType , NpcConnect )
	local coordOther = string.split(config.coordinate or "", ",")
	local event_type = tonumber(config.event_type)
	local curIsNpc = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == event_type and not self._isRemoveEventOn
	if NpcConnect and not curIsNpc then
		return
	end

	isNpc = isNpc and curIsNpc
	if #coordOther > 1  then
		local gridKey = self:getGridKeyByGridTbl(coordOther)
		local maxGridX = math.max(coord[1] , coordOther[1])
		local maxGridY = math.max(coord[2] , coordOther[2])
		local strLine = self:getGridKeyByGrid(maxGridX,maxGridY)
		if not self._updateLinesTbl[strLine] then
			local lineData = {id = strLine ,gridX = maxGridX , gridY = maxGridY , state = QUIMazeExploreMapController.GRID_TYPE.VISIBLE , isNpc = isNpc}
			if not self._mapSvrInfo[tonumber(config.id)] 
				and not self._updateGridsTbl[gridKey]  
				then
				local gridData = {id = config.id , gridX = coordOther[1] , gridY = coordOther[2] , state =  QUIMazeExploreMapController.GRID_TYPE.VISIBLE , config = config ,isNpc = curIsNpc,paceCount = self._paceCount}
				-- QPrintTable(gridData)
				self._gridsTbl[gridKey] = gridData
				self._updateGridsTbl[gridKey] = gridData
				--若为陷阱格则视野+1
				if event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB then
					self:_setConnectGridAndLineVisible(config,coordOther)
				elseif event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL then
					self:_setPortalGridVisible(config)
				elseif event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF  
					or event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE then
					self:_checkGridLiftsOnOff(config)
				elseif event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS then
					self:_setConnectGridAndLineVisible(config,coordOther,isNpc, isLockType , true)
				elseif isLockType then
				 	lineData.isLock = true
				end
			else
				if not NpcConnect then
					lineData.state = QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT
				end
			end
			if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT then
				lineData.isLock = self._mazeExploreDataHandle:getPassStarByDungeonId(self._chapterId) < 1 
			end
			self._linesTbl[strLine] = lineData
			self._updateLinesTbl[strLine] = lineData
		else
			if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT then
				local isLock =  self._mazeExploreDataHandle:getPassStarByDungeonId(self._chapterId) < 1 
				self._updateLinesTbl[strLine].isLock = isLock
				self._linesTbl[strLine].isLock = isLock
			end
		end
	end
end

--传送门延伸地块开启
function QUIMazeExploreMapController:_setPortalGridVisible(config)
	local keyGridId = tonumber(config.parameter)
	local onConfig = self._gridConfigs[tonumber(keyGridId)]
	local coordOther = string.split(onConfig.coordinate or "", ",")
	local gridKey = self:getGridKeyByGridTbl(coordOther)
	if not self._gridsTbl[gridKey] then
		local gridData = {id = onConfig.id , gridX = coordOther[1] , gridY = coordOther[2] , state =  QUIMazeExploreMapController.GRID_TYPE.VISIBLE , config = onConfig ,isNpc = false}
		self._gridsTbl[gridKey] = gridData
		self._updateGridsTbl[gridKey] = gridData
	end
end


--判断相邻格是否可见
--由于暗格需要触发机关才能可见 所以需要判断
function QUIMazeExploreMapController:_checkConnectGridVisible(config , neibourconfig)
	local event_type = tonumber(config.event_type)
	local event_type2 = tonumber(neibourconfig.event_type)
	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE then
		-- print("_checkConnectGridVisible")
		-- QPrintTable(config)
		local keyGridId = tonumber(config.parameter)
		-- local gridKey = self:getGridKeyById(keyGridId)
		-- QPrintTable(self._gridsTbl[gridKey])
		if not self._mapSvrInfo[tonumber(keyGridId)] or self._mapSvrInfo[tonumber(keyGridId)] == QUIMazeExploreMapController.GRID_TYPE.DEFAULT  then
			return false
		end

		-- if not self._gridsTbl[gridKey] or self._gridsTbl[gridKey].state == QUIMazeExploreMapController.GRID_TYPE.DEFAULT or not self._mapSvrInfo[tonumber(keyGridId)]  then
		-- 	-- print(gridKey)
		-- 	return false
		-- end
	end
	-- if event_type2 == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME then -- 若猜拳没有胜利则不显示
	-- 	local coordOther = string.split(neibourconfig.coordinate or "", ",")
	-- 	local gridKey = self:getGridKeyByGridTbl(coordOther)
	-- 	if not self._gridsTbl[gridKey] or self._gridsTbl[gridKey].state ~= QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT then
	-- 		return false
	-- 	end
	-- end
	-- if event_type2 == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS then
	-- 	if self._mazeExploreDataHandle:getPassStarByDungeonId(self._chapterId) < 1  then
	-- 		return false
	-- 	end
	-- end
	return true
end

--判断是否为开关 若是 则开启对应暗格
function QUIMazeExploreMapController:_checkConcealedGridOnOff(config ,state)

	if state == QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT then
		local event_type = tonumber(config.event_type)
		if event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_ONOFF then	
			local keyGridId = tonumber(config.parameter)
			-- print(keyGridId)
			local onConfig = self._gridConfigs[tonumber(keyGridId)]
			if onConfig and not self._mapSvrInfo[tonumber(keyGridId)]  then
				self:_openGridAndLine(onConfig)
			end
		elseif event_type ==QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE then	
			local lightParts = string.split(config.parameter, ";")
			if lightParts[2] then
				local onConfig = self._gridConfigs[tonumber(lightParts[2])]
				if onConfig and not self._mapSvrInfo[tonumber(lightParts[2])]  then
					self:_openGridAndLine(onConfig)
				end
			end
		end
	end
end

--开启暗格后连接对应的连线
function QUIMazeExploreMapController:_openGridAndLine(config )
	-- QPrintTable(config)


	local connectIds = string.split(config.connect_id, ",")
	local coord = string.split(config.coordinate, ",")
	local gridKey = self:getGridKeyByGridTbl(coord)
	if  self._gridsTbl[gridKey] then
		print("_openGridAndLine")
		-- QPrintTable(self._gridsTbl[gridKey] )
		return
	end 

	local isConnetOpen = false --记录对应暗格的周围地格是否有开启的
	for k,conn_id in pairs(connectIds or {}) do
		local conConfig = self._gridConfigs[tonumber(conn_id)]
		if conConfig  then
			local coordOther = string.split(conConfig.coordinate or "", ",")
			local gridKey1 = self:getGridKeyByGridTbl(coordOther)
			if self._gridsTbl[gridKey1] or tonumber(config.event_type) == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB  then
				isConnetOpen = true
				local maxGridX = math.max(coord[1] , coordOther[1])
				local maxGridY = math.max(coord[2] , coordOther[2])
				local strLine = self:getGridKeyByGrid(maxGridX,maxGridY)
				local lineData = {id = strLine ,gridX = maxGridX , gridY = maxGridY , state = QUIMazeExploreMapController.GRID_TYPE.VISIBLE , isSecret = true}
				self._linesTbl[strLine] = lineData
				self._updateLinesTbl[strLine] = lineData
			end
		end
	end

	if isConnetOpen then
		local gridData = {id = config.id , gridX = coord[1] , gridY = coord[2] , state =  QUIMazeExploreMapController.GRID_TYPE.VISIBLE , config = config}
		self._gridsTbl[gridKey] = gridData
		self._updateGridsTbl[gridKey] = gridData
		if not self._isInitData then
		self._moveGrid = coord
		end
		print("_openGridAndLine ConnetOpen")
		-- QPrintTable(coord)
	end

end

--判断是否为升降台开关与升降台的关系
function QUIMazeExploreMapController:_checkGridLiftsOnOff(config ,state)
	local event_type = tonumber(config.event_type)

	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF then
		local liftIds = string.split(config.parameter, ",")
		for k,liftId in pairs(liftIds) do
			local liftconfig = self._gridConfigs[tonumber(liftId)]
			if liftconfig then
				-- QPrintTable(liftconfig)
				local coord = string.split(liftconfig.coordinate or "", ",")
				local gridKey = self:getGridKeyByGridTbl(coord)
				if self._gridsTbl[gridKey] then
					self._gridsTbl[gridKey].isClose = self:_getGridLiftsOnOff(liftconfig)
					self._updateGridsTbl[gridKey] = self._gridsTbl[gridKey]
				end
			end
		end
	elseif event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE then
		local coord = string.split(config.coordinate or "", ",")
		local gridKey = self:getGridKeyByGridTbl(coord)
		if self._gridsTbl[gridKey] then
			local isclose = self:_getGridLiftsOnOff(config)
			self._gridsTbl[gridKey].isClose = isclose
			self._updateGridsTbl[gridKey]= self._gridsTbl[gridKey]
		end
	end
end


function QUIMazeExploreMapController:getPortalEnd(config)
	local endConfig = self._gridConfigs[tonumber(config.parameter)]
	if endConfig then 
		local coord = string.split(endConfig.coordinate or "", ",")
		return coord
	end

	return nil 
end

function QUIMazeExploreMapController:_getGridLiftsOnOff(config)
	local parma = string.split(config.parameter or "", ";")
	local initIsClose = tonumber(parma[1]) == 1 --初始状态1升2降
	local switchs = string.split(parma[2] or "", ",")
	local switch1 = switchs[1] 
	local switch2 = switchs[2]
	local switch1On = 1
	local switch2On = 1
	if switch1 and self._mapSvrInfo[tonumber(switch1)] then
		switch1On = self._mapSvrInfo[tonumber(switch1)]
	end
	if switch2On and self._mapSvrInfo[tonumber(switch2)] then
		switch2On = self._mapSvrInfo[tonumber(switch2)] 
	end
	-- print(switch1On)
	-- print(switch2On)
	if switch2On ~= switch1On then
		-- print(config.id .. "    "..parma[1].."false")
		return not initIsClose
	end
	-- print(config.id .. "    "..parma[1].."true")
	return initIsClose
end

------------------------------------------------------------------------------
function QUIMazeExploreMapController:getCurTimer()
	return self._cdTimer 
end

function QUIMazeExploreMapController:getMaxWidth()
	return self._maxiGridWidth * QUIMazeExploreMapController.PER_GRID_WIDTH
end

function QUIMazeExploreMapController:getMaxHeight()
	return self._maxiGridHeight * QUIMazeExploreMapController.PER_GRID_HEIGHT
end

function QUIMazeExploreMapController:getMapData()
	return self._gridsTbl or {}
end

function QUIMazeExploreMapController:getMapLineData()
	return self._linesTbl or {}
end

function QUIMazeExploreMapController:getUpdateMapData()
	return self._updateGridsTbl or {}
end

function QUIMazeExploreMapController:getUpdateMapLineData()
	return self._updateLinesTbl or {}
end

--
function QUIMazeExploreMapController:getMyGridPos()
	return self._myGrid or {0,0}
end

function QUIMazeExploreMapController:getEndGridPos()
	return self._endGrid or {0,0}
end

function QUIMazeExploreMapController:getIsFirstEnterMap()
	return self._isFirstEnter
end

function QUIMazeExploreMapController:setMyGridPos(myGrid)
	self._myGrid = myGrid
end

function QUIMazeExploreMapController:getMyGridPosId()
	local gridKey = self:getGridKeyByGridTbl(self._myGrid)
	if self._gridsTbl[gridKey] then
		return tonumber(self._gridsTbl[gridKey].id)
	end
	return 1
end

function QUIMazeExploreMapController:getMyMoveGrid()
	return self._moveGrid 
end 

function QUIMazeExploreMapController:setMyMoveGridToNull()
	self._moveGrid = nil
end

--判断点击的地格并返回	
--1 是否为可点击地格
--2 返回路径
function QUIMazeExploreMapController:checkIsGrid(gridX,gridY)

	print(gridX)
	print(gridY)
	local gridKey = self:getGridKeyByGrid(gridX,gridY)
	-- QPrintTable(self._myGrid)
	if tonumber(gridX) == tonumber(self._myGrid[1]) and tonumber(gridY) == tonumber(self._myGrid[2]) then
		if self._gridsTbl[gridKey] then
			self._endId = tonumber(self._gridsTbl[gridKey].id)
			print("点脚下")
			local movementState = self:handleGridEvent(self._myGrid , self._myGrid)
			if movementState == QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_STOP then
				self:handleGridEventAfterMove()
			end
			return false , {}
		end
	end



	self._routeTbl = {}
	self._compareCount = 99999

	if self._gridsTbl[gridKey] then
		self._endId = tonumber(self._gridsTbl[gridKey].id)

		--判断终点是否可以前往
		local canMove , tips = self:_judgeCanMoveTo(self._endId)
		if not canMove then
			app.tip:floatTip(tips)
			return false , {}
		end

		local routeTable = {}
		local startId = self:getMyGridPosId()
		
		routeTable[startId] = {index_ = 0 , frontId = 0 }

		self:_iterativeRouting(routeTable ,startId , 0, self._endId )

		-- QPrintTable(self._routeTbl)
		-- print(startId)
		-- print(endId)

		--判断前往的路径是否合理
		if q.isEmpty(self._routeTbl) then
			-- app.tip:floatTip("判断前往的路径不合理!")
			return false , {}
		end

		local paths = {}
		for i,v in ipairs(self._routeTbl) do
			local path = self:getGridKeyById(v)
			table.insert( paths, self:getGridKeyById(v) )
		end
		-- return true , {gridKey}
		return true , paths
	end

	return false , {}
end


--迭代深度寻路算法 获得运动路径
function QUIMazeExploreMapController:_iterativeRouting(routeTable,frontId ,index ,endId)

	local newIdx = index + 1
	local neighborIds = string.split(self._gridConfigs[frontId].connect_id, ",")
	for i,v in ipairs(neighborIds) do
		local id = tonumber(v)
		local canMoveTo = self:_judgeCanMoveTo(id) -- 这里需要根据id 判断是否可以移动

		if canMoveTo and (routeTable[id] == nil or routeTable[id].index_ > newIdx ) then
			routeTable[id] = {index_ = newIdx , frontId = frontId }
			-- QPrintTable(routeTable)
			if id == endId then
				if newIdx < self._compareCount then
					self._compareCount = newIdx
					self._routeTbl = self:transferRouteTableToMovePath(routeTable,endId)
				end
			else
				self:_iterativeRouting(routeTable , id ,newIdx,endId)
			end
		end
	end
end

function QUIMazeExploreMapController:_judgeCanMoveTo(id)
	local gridConfig = self._gridConfigs[id]
	if not gridConfig then return false end 

	local event_type = tonumber(gridConfig.event_type)
	-- --若为暗格 判断是否开启 可见的暗格都是可以移动的
	-- if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE then

	-- end 
	--若为升降台 判断是否开启
	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE  then
		local coord = string.split(gridConfig.coordinate, ",")
		local gridKey = self:getGridKeyByGridTbl(coord)
		if self._gridsTbl[gridKey] and self._gridsTbl[gridKey].isClose  then
			return false ,"升降门升起时无法前往"
		end
	end 
	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT and self._mazeExploreDataHandle:getPassStarByDungeonId(self._chapterId) < 1  then
		return false , "需要通过前置格子的考验!"
	end

	--判断相邻格子是否开启
	local neighborIds = string.split(gridConfig.connect_id, ",")
	for i,v in ipairs(neighborIds) do
		local gridKey = self:getGridKeyById(v)
		if self._gridsTbl[gridKey] then
			local state = self._gridsTbl[gridKey].state or QUIMazeExploreMapController.GRID_TYPE.INVISIBLE
			if tonumber(state) ~= QUIMazeExploreMapController.GRID_TYPE.INVISIBLE then
				local config = self._gridConfigs[tonumber(v)]
				if tonumber(config.event_type) == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE 
					or  tonumber(config.event_type) == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME 
					then
					if state == QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT then
						return true,""
					end
				else
					return true,""
				end
			end
		end
	end

	return false ,"需要通过前置格子的考验!"
end



--转化成路径表
function QUIMazeExploreMapController:transferRouteTableToMovePath(routeTable , endId )
	local returnTbl = {}
	local x = tonumber(endId)
	while x ~= 0 do
		local data = routeTable[x]
		if data.index_ == 0 then
			break
		end
		returnTbl[data.index_] = x
		x = tonumber(data.frontId)
	end
	return returnTbl
end



-------------------------转化------------------------------
function QUIMazeExploreMapController:getGridKeyById(id)
	local data = self._gridConfigs[tonumber(id)]
	if data then
		local coord = string.split(data.coordinate, ",")
		return  self:getGridKeyByGridTbl(coord)
	end
end

function QUIMazeExploreMapController:getGridKeyByGrid(gridX,gridY)
	return gridX.."|"..gridY
end

function QUIMazeExploreMapController:getGridKeyByGridTbl(gridTbl)
	return self:getGridKeyByGrid(gridTbl[1],gridTbl[2])
end

-------------------------启动定时器------------------------------
function QUIMazeExploreMapController:_startTimer()
	self._cdTimer = 0
	self:_countinueTimer()
end


function QUIMazeExploreMapController:_countinueTimer(e)

	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._timeHandler = scheduler.performWithDelayGlobal(function ()
		self:_timeCountDown()
	end,1)

end

function QUIMazeExploreMapController:_stopTimer(e)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end


-------------------------启动定时器函数自增时间 间隔为1秒------------------------------
function QUIMazeExploreMapController:_timeCountDown()

	if self._isRemoveEventOn then
		self:_stopTimer()
		return
	end

	self._cdTimer = self._cdTimer + 1
	-- print("time "..self._cdTimer)
	if self._inTostabConfig then
		if self:_judgeRoleHurtByTostab(self._inTostabConfig) then
			if QUIMazeExploreMapController.DEBUG == 1 then
				self:debugLocalCheatData(tonumber(self._inTostabConfig.id))
			else
				self._mazeExploreDataHandle:EventTriggerByGridInfo(self._inTostabConfig)
			end
			-- app.tip:floatTip("刺到我了～～～～～!")
		end
	end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.TIMER_UPDATE, timer = self._cdTimer})
	self:_countinueTimer()

end



return QUIMazeExploreMapController