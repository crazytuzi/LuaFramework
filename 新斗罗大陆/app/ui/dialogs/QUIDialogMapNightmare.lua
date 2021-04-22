-- 地图副本类
-- 主要依靠map和build实现不同的业务逻辑，主类只负责移动

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMapNightmare = class("QUIDialogMapNightmare", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetInstanceNightmareMap = import("..widgets.QUIWidgetInstanceNightmareMap")
local QUIWidgetInstanceNightmare = import("..widgets.QUIWidgetInstanceNightmare")
local QUIWidgetInstanceNightmareBuild = import("..widgets.QUIWidgetInstanceNightmareBuild")
local QUIViewController = import("..QUIViewController")

function QUIDialogMapNightmare:ctor(options)
	local ccbFile = "ccb/Dialog_BigEliteChoose_em.ccbi"
	local callBacks = {
						{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
						{ccbCallbackName = "onTriggerElite", callback = handler(self, self._onTriggerElite)},
						{ccbCallbackName = "onTriggerWelfare", callback = handler(self, self._onTriggerWelfare)},
						{ccbCallbackName = "onTriggerNightmare", callback = handler(self, self._onTriggerNightmare)},
						{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
					}
	self.super.ctor(self,ccbFile,callBacks,options)

	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)

	self:_checkEliteIsOpen()
	self:_checkWelfareIsOpen()

	self._selectIndex = options.selectIndex

	self._totalWidth = 0
	self._maxWidth = 3420.4 --最大宽度
	self:madeTouchLayer()
	self._cellWidth = 853.6 --单位区块的宽度
	self._moveCell = {} --需要根据区块移动的单位
	self._buildNode = {} --需要根据区块移动的地图节点
	self._totalNodeCount = 0
end

function QUIDialogMapNightmare:viewDidAppear()
    QUIDialogMapNightmare.super.viewDidAppear(self)
    self:addBackEvent()

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

	self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.userUpdateHandler))

    self:selectType(DUNGEON_TYPE.NIGHTMARE)
end

function QUIDialogMapNightmare:viewWillDisappear()
    QUIDialogMapNightmare.super.viewWillDisappear(self)
    self:removeBackEvent()

    self._userProxy:removeAllEventListeners()
    self._userProxy = nil

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

	self:_stopOnEnterFrame()
end

function QUIDialogMapNightmare:selectType(instanceType)
	if self._instanceType ~= nil and self._instanceType ~= instanceType then
    	self._totalWidth = 0
    	self._selectIndex = nil
    	self._offsetCell = nil
    	self:getOptions().selectIndex = nil
	end
	self._instanceType = instanceType
	self:resetAll()

	local options = self:getOptions()
	options.instanceType = instanceType

	if instanceType == DUNGEON_TYPE.NIGHTMARE then
		self._mapWidget = QUIWidgetInstanceNightmareMap.new()
		self._ccbOwner.map_content:addChild(self._mapWidget)
		self._maxWidth = self._mapWidget:getMaxWidth()

		self._buildWidget = QUIWidgetInstanceNightmare.new({parent = self})
		self._buildWidget:addEventListener(QUIWidgetInstanceNightmareBuild.EVENT_SELECT_INDEX, function (event)
			if self._isMove == true then return end
			app.sound:playSound("common_small")
			if event ~= nil and event.renderIndex ~= nil then
				self:getOptions().selectIndex = event.renderIndex
			end
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNightmareInstance", 
				options = {nightmareId = event.nightmareId, parentOptions = self:getOptions()}})
		end)
		self._mapWidget:addBuild(self._buildWidget)
		self:removeBuildNodes()
		self:addBuildNodes(self._buildWidget:getNode())

		self._ccbOwner.btn_nightmare:setHighlighted(true)
		self._ccbOwner.btn_nightmare:setTouchEnabled(false)
	end

	if self._mapWidget.getMapNode ~= nil then
		local mapNodes = self._mapWidget:getMapNode()
		for _,node in ipairs(mapNodes) do
			self:addToMoveNode(node)
		end
	end
	self:initPage()

	local _, normalBoo = remote.instance:getDungeonRedPointList(DUNGEON_TYPE.NORMAL)
	local _, eliteBoo = remote.instance:getDungeonRedPointList(DUNGEON_TYPE.ELITE)
	local welfareBoo = remote.welfareInstance:isShowRedPoint()
	
	self._ccbOwner.dungeon_tips_normal:setVisible( normalBoo )
	self._ccbOwner.dungeon_tips_elite:setVisible( eliteBoo )
	self._ccbOwner.dungeon_tips_welfare:setVisible( welfareBoo )
end

--根据关卡显示副本
function QUIDialogMapNightmare:initPage()
	self._totalIndex = self._buildWidget:initPage()
	self._nextIndex = self._totalIndex

	for i=1,self._nextIndex-1 do
		local nextWidth = self:getNodePositionXByIndex(i) + self._pageWidth
		if nextWidth > self._totalWidth then
			self._totalWidth = nextWidth
		end
	end

	--禁止操作
	self:enableTouchSwallowTop()

	self._buildWidget:getFlagEffect(function ()
		self:disableTouchSwallowTop()
	end)

	if self._selectIndex ~= nil then
		local nextWidth = self:getNodePositionXByIndex(self._selectIndex) + self._pageWidth
		self:moveTo(self._pageWidth - nextWidth, false , true)
	else
		self:moveTo(self._pageWidth - self._totalWidth, false , true)
	end
end

--根据地图索引获取在地图中的位置
function QUIDialogMapNightmare:getNodePositionXByIndex(index)
	local offsetX = (math.ceil(index/self._totalNodeCount) - 1) * self._maxWidth
	local count = index%self._totalNodeCount
	if count == 0 then count = self._totalNodeCount end
	local _node = self._buildNode[count]
	return _node._originPosX + offsetX, _node:getPositionY()
end

function QUIDialogMapNightmare:addBuildNodes(nodes)
	self._totalNodeCount = 0
	for _,node in ipairs(nodes) do
		self._totalNodeCount = self._totalNodeCount + 1
		self:addToMoveNode(node)
		table.insert(self._buildNode, node)
	end
end

function QUIDialogMapNightmare:removeBuildNodes()
	if self._buildNode ~= nil then
		for _,node in ipairs(self._buildNode) do
			self:removeMoveNode(node)
		end
	end
end

--移除node
function QUIDialogMapNightmare:removeMoveNode(node)
	for _,cells in ipairs(self._moveCell) do
		for index,cell in ipairs(cells) do
			if cell == node then
				table.remove(cells, index)
			end
		end
	end
end

--添加node
function QUIDialogMapNightmare:addToMoveNode(node)
	local posX = node:getPositionX()
	node._originPosX = posX --保存起始位置
	local pos = math.ceil(posX/self._cellWidth)%4
	if pos < 1 then pos = 4 - pos end
	if self._moveCell[pos] == nil then
		self._moveCell[pos] = {}
	end
	node._cellPosX = posX%self._cellWidth --相对的区块的位置
	table.insert(self._moveCell[pos], node)
end

function QUIDialogMapNightmare:madeTouchLayer()
	self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = self._size.width
	self._pageHeight = self._size.height
	self._mapContent = self._ccbOwner.node_map

	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer,self._size.width,self._size.height,-self._size.width/2,-self._size.height/2, handler(self, self.onTouchEvent))
end

function QUIDialogMapNightmare:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:moveTo(event.distance.x, true, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startX = event.x
  		self._pageX = self._mapContent:getPositionX()
    elseif event.name == "moved" then
    	local offsetX = self._pageX + event.x - self._startX
        if math.abs(event.x - self._startX) > 10 then
            self._isMove = true
        end
		if self._totalWidth > self._pageWidth then
			if offsetX < -(self._totalWidth - self._pageWidth) then
				offsetX = -(self._totalWidth - self._pageWidth)
			elseif offsetX > 0 then
				offsetX = 0
			end
			self:moveTo(offsetX, false)
		end
	elseif event.name == "ended" then
    	scheduler.performWithDelayGlobal(function ()
    		self._isMove = false
    		end,0)
    end
end

function QUIDialogMapNightmare:_removeAction()
	if self._actionHandler ~= nil then
		self._mapContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogMapNightmare:moveTo(posX, isAnimation, isCheck)
	local targetX = posX
	if isCheck == true then
		local contentX = self._mapContent:getPositionX()
		if self._totalWidth <= self._pageWidth then
			targetX = 0
		elseif contentX + posX < -(self._totalWidth - self._pageWidth) then
			targetX = -(self._totalWidth - self._pageWidth)
		elseif contentX + posX > 0 then
			targetX = 0
		else
			targetX = contentX + posX
		end
	end
	if isAnimation == false then
		self._mapContent:setPositionX(targetX)
		self:_onMoveHandler()
		return 
	end
	self:_contentRunAction(targetX, 0)
	self:_startOnEnterFrame()
end

function QUIDialogMapNightmare:_contentRunAction(posX,posY)
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(0.5, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:_removeAction()
    											self:_stopOnEnterFrame()
												self:_onMoveHandler()
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._mapContent:runAction(ccsequence)
end

--缓动过程中随时刷新
function QUIDialogMapNightmare:_startOnEnterFrame()
	self:_stopOnEnterFrame()
	self._enterFrameHandler = scheduler.scheduleGlobal(function ()
		self:_onMoveHandler()
	end,0)
end

function QUIDialogMapNightmare:_stopOnEnterFrame()
	if self._enterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._enterFrameHandler)
		self._enterFrameHandler = nil
	end
end

function QUIDialogMapNightmare:_onMoveHandler(isForce)
	local posX = self._mapContent:getPositionX()
	local offsetCell = math.ceil(posX/self._cellWidth)
	if self._offsetCell == offsetCell and isForce ~= true then return end
	self._offsetCell = offsetCell
	local startCell = self._offsetCell%4
	startCell = 4 - startCell
	for i = 1, 4 do
		local cells = self._moveCell[startCell]
		if cells ~= nil then
			for _,node in ipairs(cells) do
				node:setPositionX((i - 2 - self._offsetCell) * self._cellWidth + node._cellPosX)
			end
		end
		startCell = startCell + 1
		if startCell > 4 then
			startCell = 1
		end
	end

	--计算起始的node节点
	local totalIndex = self._totalNodeCount
	local offsetIndex = -math.ceil((offsetCell+1)/4) --此处加1为了让cell从第二格子计算(默认第一个格子会是最后一个cell块，则会造成从第20个开始计算)
	local startIndex = 1
	local smallPosX = nil
	for index,node in ipairs(self._buildNode) do
		if smallPosX == nil then
			smallPosX = node:getPositionX()
			startIndex = index
		elseif smallPosX > node:getPositionX() then
			smallPosX = node:getPositionX()
			startIndex = index
		end
	end
	for index,node in ipairs(self._buildNode) do
		local renderIndex = index
		if index < startIndex then
			renderIndex = ((offsetIndex + 1) * totalIndex) + index
		else
			renderIndex = (offsetIndex * totalIndex) + index
		end
		self._buildWidget:hideStep(index)
		if renderIndex > 0 then
			self._buildWidget:render(renderIndex, node, index)
		end
	end
end

--先不显示所有的副本
function QUIDialogMapNightmare:resetAll()
	for index,node in ipairs(self._buildNode) do
		-- self:resetAllNode(node, index)
	end
	self._ccbOwner.btn_normal:setHighlighted(false)
	self._ccbOwner.btn_normal:setTouchEnabled(true)
	self._ccbOwner.btn_elite:setHighlighted(false)
	self._ccbOwner.btn_elite:setTouchEnabled(true)
	self:_checkEliteIsOpen()
	self._ccbOwner.btn_welfare:setHighlighted(false)
	self._ccbOwner.btn_welfare:setTouchEnabled(true)
	self:_checkWelfareIsOpen()
	self._ccbOwner.btn_nightmare:setHighlighted(false)
	self._ccbOwner.btn_nightmare:setTouchEnabled(true)
end


function QUIDialogMapNightmare:userUpdateHandler(event)
	self:_checkEliteIsOpen()
	self:_checkWelfareIsOpen()
end

function QUIDialogMapNightmare:_checkEliteIsOpen()
	local isUnlock = app.unlock:getUnlockElite()
	if isUnlock then
		self._ccbOwner.btn_elite:setEnabled(isUnlock)
		makeNodeFromGrayToNormal(self._ccbOwner.btn_elite)
	else
		makeNodeFromNormalToGray(self._ccbOwner.btn_elite)
	end

	self:_checkEliteTutorial()
end

function QUIDialogMapNightmare:_checkWelfareIsOpen()
	local isUnlock = app.unlock:getUnlockWelfare()
	if isUnlock then
		self._ccbOwner.btn_welfare:setEnabled(isUnlock)
		makeNodeFromGrayToNormal(self._ccbOwner.btn_welfare)
	else
		makeNodeFromNormalToGray(self._ccbOwner.btn_welfare)
	end
	
	self:_checkWelfareTutorial()
end

function QUIDialogMapNightmare:_checkEliteTutorial()
	if app.tip:isUnlockTutorialFinished() == false then
	    local unlockTutorial = app.tip:getUnlockTutorial()
	    if unlockTutorial.elites == app.tip.UNLOCK_TUTORIAL_OPEN then
			if self.eliteHandTouch == nil then
				self.eliteHandTouch = app.tip:createUnlockTutorialTip("elites", self)
			end
	    end
	end
end

function QUIDialogMapNightmare:_checkWelfareTutorial()
	if app.tip:isUnlockTutorialFinished() == false then
	    local unlockTutorial = app.tip:getUnlockTutorial()
	    if unlockTutorial.welfare == app.tip.UNLOCK_TUTORIAL_OPEN then
	    	-- self._ccbOwner.welfare_light:setVisible(true)
	    	if self.welfareHandTouch == nil then
				self.welfareHandTouch = app.tip:createUnlockTutorialTip("welfare", self)
			end
	    end
	end
end

function QUIDialogMapNightmare:_onTriggerNormal() 
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap",  
        options = {instanceType = DUNGEON_TYPE.NORMAL}})
end

function QUIDialogMapNightmare:_onTriggerElite()
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	if app.unlock:getUnlockElite(true) == false then
		return
	end
	local instanceInfos = remote.instance:getInstancesByIndex(1, DUNGEON_TYPE.ELITE)

	if instanceInfos[1].isLock == false then
		local needLevel = instanceInfos[1].unlock_team_level or 0
		if app.unlock:checkLevelUnlock(needLevel) == false then
	 		app.unlock:tipsLevel(needLevel)
			return
		end
		if instanceInfos[1].unlock_dungeon_id ~= nil then
			local needDungeonIds = string.split(instanceInfos[1].unlock_dungeon_id, ",")
			for _,id in ipairs(needDungeonIds) do
			 	if id ~= nil and app.unlock:checkDungeonUnlock(id) == false then
			 		app.unlock:tipsDungeon(id)
					return
			 	end
			 end
		 end
		return
	end

	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap",  
        options = {instanceType = DUNGEON_TYPE.ELITE}})
end

function QUIDialogMapNightmare:_onTriggerWelfare()
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	if app.unlock:getUnlockWelfare(true) == false then
		return
	end
	
	if app.tip:isUnlockTutorialFinished() == false then
	    local unlockTutorial = app.tip:getUnlockTutorial()
	    if unlockTutorial.welfare == app.tip.UNLOCK_TUTORIAL_OPEN then
	    	-- self._ccbOwner.welfare_light:setVisible(false)
	    	unlockTutorial.welfare = 2
  			app.tip:setUnlockTutorial(unlockTutorial)
	    end
	end
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap",  
        options = {instanceType = DUNGEON_TYPE.WELFARE}})
end

function QUIDialogMapNightmare:_onTriggerNightmare()
    app.sound:playSound("battle_change")
end

function QUIDialogMapNightmare:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogMapNightmare:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogMapNightmare:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMapNightmare:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMapNightmare