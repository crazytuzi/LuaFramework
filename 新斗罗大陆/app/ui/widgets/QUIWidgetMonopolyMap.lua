--
-- Author: Kumo.Wang
-- 大富翁地图管理
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonopolyMap = class("QUIWidgetMonopolyMap", QUIWidget)

local QUIWidgetMonopolyActorDisplay = import("..widgets.actorDisplay.QUIWidgetMonopolyActorDisplay")
local QBaseEffectView = import("...views.QBaseEffectView")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QChatDialog = import("...utils.QChatDialog")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetMonopolyMap.Map_Move = "QUIWIDGETMONOPOLYMAP_MAP_MOVE"
QUIWidgetMonopolyMap.Actor_Move_End = "QUIWIDGETMONOPOLYMAP_ACTOR_MOVE_END"
QUIWidgetMonopolyMap.Actor_Move = "QUIWIDGETMONOPOLYMAP_ACTOR_MOVE"

function QUIWidgetMonopolyMap:ctor(options)
	local mapId = options.mapId or 1
	local ccbFile = "ccb/Widget_monopoly_map"..mapId..".ccbi"
	local callBacks = {}
	QUIWidgetMonopolyMap.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._baseViewNode = options.baseView
    self:_init()
end

function QUIWidgetMonopolyMap:_onFrame(dt)
	if self._isActorMove and not self._avatar:isWalking() then
		self:_actorMoveToNextGrid()
		self._isGag = true
		self:_removeWord()
		if self._talkHandler ~= nil then
			scheduler.unscheduleGlobal(self._talkHandler)
			self._talkHandler = nil
		end
	else
		self._isGag = false
	end

	if not self._isMapMove and not self._isInitMapView then
		self:_mapAutoMove()
	end
end

function QUIWidgetMonopolyMap:onEnter()
    self._monopolyProxy = cc.EventProxy.new(remote.monopoly)
    self._monopolyProxy:addEventListener(remote.monopoly.EVENT_COMPLETED, handler(self, self._monopolyComplete))

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QUIWidgetMonopolyMap:onExit()
	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)

	if self._talkHandler ~= nil then
		scheduler.unscheduleGlobal(self._talkHandler)
		self._talkHandler = nil
	end
end

function QUIWidgetMonopolyMap:getMapSize()
	local size = self._ccbOwner.node_mapSize:getContentSize()
	return size.width, size.height
end

function QUIWidgetMonopolyMap:setMapMoveState(b)
	self._isMapMove = b
	self._isInitMapView = b
end

function QUIWidgetMonopolyMap:actorMoveTo(gridIndex)
	if self._isActorMove or self._startGridIndex ~= 0 or self._endGridIndex ~= 0 then return end
	self._startGridIndex = self._curGridIndex
	self._endGridIndex = gridIndex
	self._isActorMove = true
end

function QUIWidgetMonopolyMap:showActorAwardEffect(colour, count)
	local effectPath = remote.monopoly:getActorAwardEffectPath()
 	if effectPath then
	    local ccbFile = effectPath
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_hero:addChild(aniPlayer)
	    aniPlayer:setPosition(ccp(0, 200))
	    aniPlayer:playAnimation(ccbFile, function(ccbOwner)
	    		local sf = remote.monopoly:getMaterialSpriteFrameByColourId(colour)
	    		if sf then
					ccbOwner.sp_icon:setDisplayFrame(sf)
					ccbOwner.tf_count:setString("+"..count)
	    		end
	    	end, function()
	        end, true)
   	end
end

function QUIWidgetMonopolyMap:showOneTrigerGoEffect()
	-- if not self._fcaAnimation then
	-- 	self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/yijiantouzhi_1", "res")
	-- 	self._fcaAnimation:playAnimation("animation", false)
	-- 	self._fcaAnimation:setPositionY(150)
	-- 	self._avatar:addChild(self._fcaAnimation)	
	-- end
	self._fcaAnimation:setVisible(true)
end

function QUIWidgetMonopolyMap:hideOneTrigerGoEffect( )
	if self._fcaAnimation then
		self._fcaAnimation:setVisible(false)
	end
end

function QUIWidgetMonopolyMap:showActorAwardEffectById(awards)
    local width = 0
    local i = 0
    local effectPath = "ccb/Widget_monopoly_award1.ccbi"
 	if QCheckFileIsExist(effectPath) then
	    local ccbFile = effectPath
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_hero:addChild(aniPlayer)
	    aniPlayer:setPosition(ccp(0, 200))
	    aniPlayer:playAnimation(ccbFile, function(ccbOwner)
	    		for i=1,10 do 
	    			ccbOwner["sp_icon"..i]:setVisible(false)
	    			ccbOwner["tf_count"..i]:setVisible(false)
	    		end
	    	    for i, value in pairs(awards) do
		    		local sf = remote.monopoly:getMonopolySpriteFrameByItemId(value.id)
		    		if sf then
		    			ccbOwner["sp_icon"..i]:setVisible(true)
		    			ccbOwner["tf_count"..i]:setVisible(true)		    			
						ccbOwner["sp_icon"..i]:setDisplayFrame(sf)
						ccbOwner["tf_count"..i]:setString("+"..value.count)
		    		end
	    		end
	    	end, function()
	        end, true)
   	end
 
end

function QUIWidgetMonopolyMap:startTalk()
	if not self._words then
		self._words = remote.monopoly.avatarWords
	end
	if self._talkHandler ~= nil then
		scheduler.unscheduleGlobal(self._talkHandler)
		self._talkHandler = nil
	end
	self:_showWord(self._words[math.random(#self._words)])
	self._talkHandler = scheduler.scheduleGlobal(function ()
			self:_showWord(self._words[math.random(#self._words)])
		end, 6)
end

function QUIWidgetMonopolyMap:onTriggerGrid(x, y)
	-- print("map touch: ", x, y)
	local isOnTrigger, gridInfo = self:_isOnTriggerGrid(x, y)
	if isOnTrigger then
		self:_onTriggerGrid(gridInfo)
	end
end

function QUIWidgetMonopolyMap:_onTriggerGrid(gridInfo)
	if gridInfo and gridInfo.eventId and gridInfo.eventId > 0 then
		local eventConfig = remote.monopoly:getMonopolyEventConfigByEventId(gridInfo.eventId)
		if eventConfig and eventConfig.text then
	        app.tip:floatTip(eventConfig.text)
	    end
	end
end

function QUIWidgetMonopolyMap:_isOnTriggerGrid(x, y)
	local gridInfos = remote.monopoly.monopolyInfo.gridInfos
    for index, gridInfo in ipairs(gridInfos) do
        local tbl = remote.monopoly:getGridTouchRegionByGridId(index)
        if x >= tbl[1] and x <= tbl[2] and y >= tbl[3] and y <= tbl[4] then
            return true, gridInfo
        end
    end
    return false
end

-- 更新经验
function QUIWidgetMonopolyMap:_monopolyComplete()
	local immortalInfos = remote.monopoly.monopolyInfo.immortalInfos or {}
	for index, flowerInfo in pairs(self._flowerNodes or {}) do
		local id = flowerInfo.id
		local flowerNode = flowerInfo.ccb
		if immortalInfos[id] then
		    local exp = immortalInfos[id].exp or 0
			local curConfig, nextConfig = remote.monopoly:getFlowerCurAndNextConfigById(id)
			local expStr = "已满级"
			local expProsess = 1
		    if nextConfig then
		    	expStr = exp.."/"..(nextConfig.exp or 1)
		    	expProsess = exp/(nextConfig.exp or 1)
		    end
		    flowerNode.sp_progress:setScaleX(expProsess)
		    flowerNode.tf_progress:setString(expStr)
			flowerNode.node_flower:setVisible(true)
		else
			flowerNode.node_flower:setVisible(false)
			flowerNode.sp_progress:setScaleX(0)
		    flowerNode.tf_progress:setString("0/100")
		end
	end
end

function QUIWidgetMonopolyMap:getMapNode(gridPos)
	local gridInfos = remote.monopoly.monopolyInfo.gridInfos
	for index, gridInfo in ipairs(gridInfos) do
		if index == gridPos and self._specialEventNodes then
			local node = self._ccbOwner["grid_"..index]
			if self._specialEventNodes[gridInfo.eventId] then
				return self._specialEventNodes[gridInfo.eventId]:getChildByTag(gridPos)
			else
				return nil
			end
		end
	end
end

function QUIWidgetMonopolyMap:playEffectByGridPos(gridpos,isSuess,fcatype,name)
	local nodeExpand = self._ccbOwner["grid_"..gridpos.."_expand"]
	local path = "fca/dafuwo_1"
	if not isSuess then
		path = "fca/dafuwo_2"
	end
    if nodeExpand then
        nodeExpand:removeChildByTag(110)
        local fcaAnimation = QUIWidgetFcaAnimation.new(path, "res")
    	fcaAnimation:setEndCallback(handler(self, function()
    		if fcatype == 1 and not isSuess then
    			remote.monopoly:continueSuccessToGo()
    		end
    	end))
        fcaAnimation:playAnimation("animation", false)
        fcaAnimation:setTag(110)
        nodeExpand:addChild(fcaAnimation)
    end
end
function QUIWidgetMonopolyMap:showLableAction(gridpos,uplevel,exp)
	local nodelabel = self._ccbOwner["grid_"..gridpos.."_lablel"]
	local nodeExpand = self._ccbOwner["grid_"..gridpos.."_expand"]
	local pos = ccp(0,0)
	if nodeExpand then
		pos = nodeExpand:getPosition()
	end
	if nodelabel then
		nodelabel:setVisible(true)
		if uplevel then
			nodelabel:setString("Level + 1")
		else
			nodelabel:setString("EXP + "..exp)
		end
		local arr = CCArray:create()
        arr:addObject(CCMoveBy:create(1.0,ccp(0,50)))
	    arr:addObject(CCCallFunc:create(function () 
						    	-- nodelabel:setPosition(ccp(pos.x,pos.y+70))
						    	nodelabel:setVisible(false)
                            end))
		nodelabel:runAction(CCSequence:create(arr))
    end	 
end

function QUIWidgetMonopolyMap:creatMap()
	local gridInfos = remote.monopoly.monopolyInfo.gridInfos
	self._ccbOwner.node_backdrop:removeAllChildren()
	self._ccbOwner.node_mediumShot:removeAllChildren()
	self._ccbOwner.node_eventIcon:removeAllChildren()
	self._ccbOwner.node_foreground:removeAllChildren()
	self._ccbOwner.node_backdrop:setVisible(true)
	self._ccbOwner.node_mediumShot:setVisible(true)
	self._ccbOwner.node_eventIcon:setVisible(true)
	self._ccbOwner.node_foreground:setVisible(true)

	self._colourNodes = {}
	self._specialEventNodes = {}
	self._eventNodes = {}
	self._flowerNodes = {}

	local flowerNum = 1
	for index, gridInfo in ipairs(gridInfos) do
		local node = self._ccbOwner["grid_"..index]
		local nodeExpand = self._ccbOwner["grid_"..index.."_expand"]
		if node then
			node:removeAllChildren()
			local img
			local id = gridInfo.colour or 1
			local colorConfig = remote.monopoly:getGridColorConfig(id)
			if not self._colourNodes[id] then
				self._colourNodes[id] = CCNode:create()
				self._ccbOwner.node_backdrop:addChild(self._colourNodes[id])
			end
			if colorConfig and colorConfig.picture then
				local path = colorConfig.picture
				img = CCSprite:create(path) 
			else
				img = remote.monopoly:getNoColorMapIcon()
			end
			self._colourNodes[colorConfig.id]:addChild(img)
			img:setPosition(ccp(node:getPosition()))
			img:setScale(1.25)


			-- print("map grid: ", index, node:getPositionX(), node:getPositionY())
			local cx, cy = node:getPosition()
			local w = img:getContentSize().width
    		local h = img:getContentSize().height
			local tbl = {cx-w/2, cx+w/2, cy-h/2, cy+h/2}
			remote.monopoly:setGridTouchRegionByGridId(index, tbl)


			if gridInfo.eventId and gridInfo.eventId > 0 then
				-- 炼药房位置固定不变的，不用删除
				if gridInfo.eventId ~= remote.monopoly.refineMedicineEventId then
					if nodeExpand then
						nodeExpand:removeAllChildren()
					end
				end

				local eventConfig = remote.monopoly:getMonopolyEventConfigByEventId(gridInfo.eventId)
				if gridInfo.eventId == remote.monopoly.flowerEventId then
					if nodeExpand then
						local effectPath = remote.monopoly:getFlowerEffectPathById(gridInfo.param)
					 	if effectPath then
						    local node = CCBuilderReaderLoad(effectPath, CCBProxy:create(), {})
						    nodeExpand:addChild(node)

						    local flowerInfo = {}
						    flowerInfo.id = tonumber(gridInfo.param)
						    flowerInfo.ccb = {}
						    local prosessNode = CCBuilderReaderLoad("ccb/Widget_Monopoly_PlantPrograssbar.ccbi", CCBProxy:create(), flowerInfo.ccb)
						    nodeExpand:addChild(prosessNode)
						    
						    self._flowerNodes[flowerNum] = flowerInfo
						    flowerNum = flowerNum + 1
					   	end
					else
						print("QUIWidgetMonopolyMap:creatMap() 缺少"..index.."的node扩展点信息，检查ccb！")
					end
				elseif eventConfig and eventConfig.picture then
					if gridInfo.eventId == remote.monopoly.refineMedicineEventId then
						if nodeExpand then
						else
							print("QUIWidgetMonopolyMap:creatMap() 缺少"..index.."的node扩展点信息，检查ccb！")
						end
					elseif gridInfo.eventId == remote.monopoly.buyEventId or gridInfo.eventId == remote.monopoly.fingerEventId then
						if not self._specialEventNodes[gridInfo.eventId] then
							self._specialEventNodes[gridInfo.eventId] = CCNode:create()
							self._ccbOwner.node_eventIcon:addChild(self._specialEventNodes[gridInfo.eventId])
						end
						local path = eventConfig.picture
						img = CCSprite:create(path) 
						self._specialEventNodes[gridInfo.eventId]:addChild(img)
						img:setTag(index)
						img:setPosition(ccp(node:getPosition()))
						img:setScale(1.25)
					else
						if not self._eventNodes[gridInfo.eventId] then
							self._eventNodes[gridInfo.eventId] = CCNode:create()
							self._ccbOwner.node_mediumShot:addChild(self._eventNodes[gridInfo.eventId])
						end
						local path = eventConfig.picture
						img = CCSprite:create(path) 
						self._eventNodes[gridInfo.eventId]:addChild(img)
						img:setTag(index)
						img:setPosition(ccp(node:getPosition()))
						img:setScale(1.25)
					end
				end
			end
		else
			print("QUIWidgetMonopolyMap:creatMap() 缺少"..index.."的node点信息，检查ccb！")
		end
	end

	self:_monopolyComplete()
end

function QUIWidgetMonopolyMap:_init()
	self._curGridIndex = remote.monopoly.monopolyInfo.nowGridId
	self._endGridIndex = 0
	self._startGridIndex = 0

	self._isActorMove = false -- 人物是否移动
	self._isMapMove = false -- 地图是否移动
	self._isInitMapView = false -- 每次操作完，校准一次地图镜头

	local baseViewNodePos = self._baseViewNode:convertToWorldSpace(ccp(0, 0))
	self._baseViewMinX = baseViewNodePos.x
	self._baseViewMaxX = baseViewNodePos.x + self._baseViewNode:getContentSize().width
	self._baseViewMinY = baseViewNodePos.y
	self._baseViewMaxY = baseViewNodePos.y + self._baseViewNode:getContentSize().height

	self:creatMap()
	self:_creatActor()
end

function QUIWidgetMonopolyMap:_creatActor()
	print("QUIWidgetMonopolyMap:_creatActor()", self._curGridIndex)
	self._avatar = QUIWidgetMonopolyActorDisplay.new(1002)
	self._ccbOwner.node_hero:addChild(self._avatar)
	self._ccbOwner.node_hero:setPosition(ccp(self._ccbOwner["grid_"..self._curGridIndex]:getPosition()))

	self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/yijiantouzhi_1", "res")
	self._fcaAnimation:playAnimation("animation", true)
	self._fcaAnimation:setPositionY(160)
	self._avatar:addChild(self._fcaAnimation)	
	self._fcaAnimation:setVisible(false)

	self:_setActorFaceTo()
end

function QUIWidgetMonopolyMap:autoCheckActorPos()
	if self._avatar and not self._isActorMove then
		self._curGridIndex = remote.monopoly.monopolyInfo.nowGridId
		self._endGridIndex = 0
		self._startGridIndex = 0
		self._ccbOwner.node_hero:setPosition(ccp(self._ccbOwner["grid_"..self._curGridIndex]:getPosition()))
		self:_setActorFaceTo()
	end
end

-- 设置英雄面向
function QUIWidgetMonopolyMap:_setActorFaceTo()
	local curNode = self._ccbOwner["grid_"..self._curGridIndex]
	local nextNode = self._ccbOwner["grid_"..self._curGridIndex + 1]
	if nextNode then
		if nextNode:getPositionX() < curNode:getPositionX() then
			self._actorFaceToleft = true
			self._avatar:setScaleX(math.abs(self._avatar:getScaleX()))
			self._fcaAnimation:setScaleX(math.abs(self._avatar:getScaleX()))	
		else
			self._actorFaceToleft = false
			self._avatar:setScaleX(-math.abs(self._avatar:getScaleX()))
			self._fcaAnimation:setScaleX(-math.abs(self._avatar:getScaleX()))
		end
	end
end

function QUIWidgetMonopolyMap:_actorMoveToNextGrid()
	print("[QUIWidgetMonopolyMap:_actorMoveToNextGrid()] self._curGridIndex, self._endGridIndex : ", self._curGridIndex, self._endGridIndex)
	self:_setActorFaceTo()
	self:_mapAutoMove()
	if self._curGridIndex >= self._endGridIndex then
		if not self._ccbOwner["grid_"..self._curGridIndex] then
			return
		end
		self._curGridIndex = self._endGridIndex
		self._startGridIndex = 0
		self._endGridIndex = 0
		self._isActorMove = false

		self._ccbOwner.node_hero:setPosition(ccp(self._ccbOwner["grid_"..self._curGridIndex]:getPosition()))
		self._avatar:setPosition(0, 0)
		self._avatar:resetActor()

		local curNodePos = self._avatar:convertToWorldSpace(ccp(0, 0))
		self:dispatchEvent({name = QUIWidgetMonopolyMap.Actor_Move_End, curPosX = curNodePos.x})
		return
	end

	local curNode = self._ccbOwner["grid_"..self._curGridIndex]
	local nextNode = self._ccbOwner["grid_"..self._curGridIndex + 1]
	if not nextNode then
		nextNode = curNode
	end
	local nodeDurationX = nextNode:getPositionX() - curNode:getPositionX()
	local nodeDurationY = nextNode:getPositionY() - curNode:getPositionY()
	local workDurationX = self._avatar:getPositionX() + nodeDurationX
	local workDurationY = self._avatar:getPositionY() + nodeDurationY
	self._avatar:walkto({x = workDurationX, y = workDurationY})

	self:dispatchEvent({name = QUIWidgetMonopolyMap.Actor_Move, curGridIndex = self._curGridIndex})
	self._curGridIndex = self._curGridIndex + 1
end

function QUIWidgetMonopolyMap:_mapAutoMove()
	if self._isMapMove then return end
	self._isInitMapView = true

	local showMinX, showMaxX, showMinY, showMaxY
	local moveX = 0
	local moveY = 0
	local curNode = self._ccbOwner["grid_"..self._curGridIndex]
	if not curNode then
		return
	end
	local curNodePos = curNode:convertToWorldSpace(ccp(0, 0))
	local nextNode = self._ccbOwner["grid_"..self._curGridIndex + 1]
	if not nextNode then
		showMinX = curNodePos.x
		showMaxX = curNodePos.x
		showMinY = curNodePos.y
		showMaxY = curNodePos.y
	else
		local nextNodePos = nextNode:convertToWorldSpace(ccp(0, 0))
		showMinX = curNodePos.x <= nextNodePos.x and curNodePos.x or nextNodePos.x
		showMaxX = curNodePos.x >= nextNodePos.x and curNodePos.x or nextNodePos.x
		showMinY = curNodePos.y <= nextNodePos.y and curNodePos.y or nextNodePos.y
		showMaxY = curNodePos.y >= nextNodePos.y and curNodePos.y or nextNodePos.y
	end

	if showMinX >= self._baseViewMinX and showMaxX <= self._baseViewMaxX and showMinY >= self._baseViewMinY and showMaxY <= self._baseViewMaxY then
		return
	else
		if showMinX < self._baseViewMinX then
			moveX = moveX + self._baseViewMinX - showMinX
		end
		if showMaxX > self._baseViewMaxX then
			moveX = moveX + self._baseViewMaxX - showMaxX
		end

		if showMinY < self._baseViewMinY then
			moveY = moveY + self._baseViewMinY - showMinY
		end
		if showMaxY > self._baseViewMaxY then
			moveY = moveY + self._baseViewMaxY - showMaxY
		end
	end
	-- print("show :", showMinX, showMaxX, showMinY, showMaxY)
	-- print("base :", self._baseViewMinX, self._baseViewMaxX, self._baseViewMinY, self._baseViewMaxY)
	-- print("move :", moveX, moveY)
	self:dispatchEvent({name = QUIWidgetMonopolyMap.Map_Move, moveX = moveX, moveY = moveY})
end

function QUIWidgetMonopolyMap:_showWord(str)
	self:_removeWord()
	if self._isGag == true then return end --禁言状态不准说话

	local word = str or "啦啦啦！啦啦啦！我是卖报的小行家！"
	self._wordWidget = QChatDialog.new()
	if self._actorFaceToleft then
		self._wordWidget:setScaleX(-1)
		self._wordWidget:setPosition(ccp(-30, 110))
	else
		self._wordWidget:setScaleX(1)
		self._wordWidget:setPosition(ccp(30, 110))
	end
	self._ccbOwner.node_foreground:addChild(self._wordWidget)
	self._ccbOwner.node_foreground:setPosition(ccp(self._ccbOwner.node_hero:getPosition()))
	self._wordWidget:setString(word)

	-- local size = self._wordWidget:getContentSize()
	-- local pos = self._wordWidget:convertToWorldSpace(ccp(0,0))
	-- if (pos.x + size.width) > display.width then
	-- 	self._wordWidget:setScaleX(-1)
	-- else
	-- 	self._wordWidget:setScaleX(1)
	-- end
end

function QUIWidgetMonopolyMap:_removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

return QUIWidgetMonopolyMap