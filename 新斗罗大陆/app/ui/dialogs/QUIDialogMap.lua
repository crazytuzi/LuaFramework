--
-- Author: wkwang
-- Date: 2014-05-05 14:22:52
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMap = class("QUIDialogMap", QUIDialog)
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetInstanceProgress = import("..widgets.QUIWidgetInstanceProgress")
local QUIWidgetInstanceNormalMap = import("..widgets.QUIWidgetInstanceNormalMap")
local QUIWidgetInstanceEliteMap = import("..widgets.QUIWidgetInstanceEliteMap")
local QUIWidgetInstanceWelfareMap = import("..widgets.QUIWidgetInstanceWelfareMap")
local QUIWidgetInstanceNightmareMap = import("..widgets.QUIWidgetInstanceNightmareMap")
local QUIWidgetUnlockTutorialHandTouch = import("..widgets.QUIWidgetUnlockTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QUserData = import("...utils.QUserData")

local MAP_WRAP_COUNT = 2

function QUIDialogMap:ctor(options)
	local ccbFile = "ccb/Dialog_BigEliteChoose1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
		{ccbCallbackName = "onTriggerElite", callback = handler(self, self._onTriggerElite)},
		{ccbCallbackName = "onTriggerWelfare", callback = handler(self, self._onTriggerWelfare)},
		{ccbCallbackName = "onTriggerNightmare", callback = handler(self, self._onTriggerNightmare)},
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
	}

	QUIDialogMap.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.__cname == "QUIPageMainMenu" then
		page:setAllUIVisible()
		page:setScalingVisible(false)
	end
	if options == nil then
		options = {}
		self:setOptions(options)
	else
		self._cloudInterludeCallBack = options.cloudInterludeCallBack
	end

	self._isShowTanNian = options.isShowTanNian or false
	self._showType = options.showType or nil
	self._selectIndex = options.selectIndex

	self._totalWidth = 0
	self._maxWidth = 3428.9

	self:madeTouchLayer()
	self:_checkEliteIsOpen()
	self:_checkWelfareIsOpen()
	self:_checkNightmareIsOpen()
	self:_checkUnlockTutorial()

	self._cellWidth = 942 --单位区块的宽度
	self._cellCount = 5 --背景图数量
	self._moveCell = {} --需要根据区块移动的单位
	self._moveNode = {} --需要根据区块移动的地图节点

	self:addToMoveNode(self._ccbOwner.vulture)
	self:addToMoveNode(self._ccbOwner.vulture2)
	self:addToMoveNode(self._ccbOwner.boat1)
	self:addToMoveNode(self._ccbOwner.boat2)

	local index = 1
	while true do
		local node = self._ccbOwner["node"..index]
		local dot = self._ccbOwner["dot"..index]
		local sp_pass = self._ccbOwner["sp_pass"..index]
		local tips = self._ccbOwner["dungeon_tips_" .. index]
		local node_info = self._ccbOwner["node_info"..index]
		local effect = self._ccbOwner["effect"..index]
		if node ~= nil then
			self:addToMoveNode(node)
			self:addToMoveNode(dot)
			self:addToMoveNode(sp_pass)
			self:addToMoveNode(tips)
			self:addToMoveNode(node_info)
			self:addToMoveNode(effect)
			table.insert(self._moveNode, node)
			self:resetAllNode(node, index)
			index = index + 1
		else
			break
		end
	end
	self._totalNodeCount = #self._moveNode
	self:resetAll()
    CalculateBattleUIPosition(self._ccbOwner.node_map, true)
	
end

function QUIDialogMap:viewDidAppear()
    QUIDialogMap.super.viewDidAppear(self)
    self:addBackEvent()

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

	self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.userUpdateHandler))

	local options = self:getOptions()
	if options.instanceType ~= nil then
    	self:selectType(options.instanceType)
	else
    	self:selectType(DUNGEON_TYPE.NORMAL)
	end
end

function QUIDialogMap:viewAnimationInHandler()
	self._cloudInterludeScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() and self._cloudInterludeCallBack then
				self._cloudInterludeCallBack()
			end
		end, 0.3)
end

function QUIDialogMap:viewWillDisappear()
	self:_stopOnEnterFrame()
	if self._animationDelayHandler ~= nil then
		scheduler.unscheduleGlobal(self._animationDelayHandler)
		self._animationDelayHandler = nil
	end

    QUIDialogMap.super.viewWillDisappear(self)
	self:removeBackEvent()

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    self._userProxy:removeAllEventListeners()
    self._userProxy = nil
    
    if self._stepSchedulers ~= nil then
    	for _,handler in pairs(self._stepSchedulers) do
    		scheduler.unscheduleGlobal(handler)
    	end
    end
	
    if self._cloudInterludeScheduler then
    	scheduler.unscheduleGlobal(self._cloudInterludeScheduler)
		self._cloudInterludeScheduler = nil
    end
    
    if self._passEffect ~= nil then
    	self._passEffect:disappear()
    	self._passEffect = nil
    end
    if self._battleEffect ~= nil then
    	self._battleEffect:disappear()
    	self._battleEffect = nil
    end

	if self.eliteHandTouch ~= nil then
		self.eliteHandTouch:removeFromParent()
		self.eliteHandTouch = nil
	end
	if self.welfareHandTouch ~= nil then
		self.welfareHandTouch:removeFromParent()
		self.welfareHandTouch = nil
	end
	if self._moveEffectSchduler ~= nil then
		scheduler.unscheduleGlobal(self._moveEffectSchduler)
		self._moveEffectSchduler = nil
	end
end

--先不显示所有的副本
function QUIDialogMap:resetAll()
	for index,node in ipairs(self._moveNode) do
		self:resetAllNode(node, index)
	end
    if self._passEffect ~= nil then
    	self._passEffect:disappear()
    	self._passEffect = nil
    end
    if self._battleEffect ~= nil then
    	self._battleEffect:disappear()
    	self._battleEffect = nil
    end
    if self._stepSchedulers ~= nil then
    	for _,handler in pairs(self._stepSchedulers) do
    		scheduler.unscheduleGlobal(handler)
    	end
    end
    if self._mapWidget ~= nil then
		if self._mapWidget.getMapNode ~= nil then
			local mapNodes = self._mapWidget:getMapNode()
			for _,node in ipairs(mapNodes) do
				self:removeMoveNode(node)
			end
		end
    	self._mapWidget:removeFromParentAndCleanup(true)
    	self._mapWidget = nil
    end
end

--重置node点
function QUIDialogMap:resetAllNode(node, index)
	makeNodeFromNormalToGray(node)
	makeNodeFromNormalToGray(self._ccbOwner["effect"..index])
	node.renderIndex = nil
	self._ccbOwner["sp_star"..index]:setVisible(false)
	self._ccbOwner["sp_pass"..index]:setVisible(false)
	self._ccbOwner["tf_name"..index]:setString("")
	self._ccbOwner["tf_star"..index]:setString("")
	self._ccbOwner["tf_explanation"..index]:setString("")
	self._ccbOwner["tf_explanation"..index]:setVisible(false)
	self._ccbOwner["node_progressStrip"..index]:setVisible(false)
	-- if self._ccbOwner["dot"..index] ~= nil then self._ccbOwner["dot"..index]:setVisible(false) end
	if self._ccbOwner["dungeon_tips_" .. index] ~= nil then self._ccbOwner["dungeon_tips_" .. index]:setVisible( false ) end
	self._ccbOwner["btn"..index.."_welfare"]:setVisible(false)
	self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
	self._ccbOwner["btn"..index.."_elite"]:setVisible(false)
	self._ccbOwner["node_info"..index]:setVisible(false)
end

function QUIDialogMap:addToMoveNode(node)
	if not node then
		return
	end
	local posX = node:getPositionX()
	node._originPosX = posX --保存起始位置
	local pos = math.ceil(posX/self._cellWidth)%self._cellCount
	if pos < 1 then pos = self._cellCount - pos end
	if self._moveCell[pos] == nil then
		self._moveCell[pos] = {}
	end
	node._cellPosX = posX%self._cellWidth --相对的区块的位置
	table.insert(self._moveCell[pos], node)
end

function QUIDialogMap:removeMoveNode(node)
	for _,cellNodes in pairs(self._moveCell) do
		for index,moveNode in ipairs(cellNodes) do
			if moveNode == node then
				table.remove(cellNodes, index)
			end
		end
	end
end

--根据副本类型显示副本内容
function QUIDialogMap:selectType(instanceType)
	if self._instanceType ~= nil and self._instanceType ~= instanceType then
    	self._totalWidth = 0
    	self._selectIndex = nil
    	self._offsetCell = nil
    	self:getOptions().selectIndex = nil
	end
	self._instanceType = instanceType
	self:resetAll()
	self._ccbOwner.tf_welfareCount:setVisible(false)
	self._ccbOwner.tf_normal_name:setColor(COLORS.V)
	self._ccbOwner.tf_elite_name:setColor(COLORS.V)
	self._ccbOwner.tf_welfare_name:setColor(COLORS.V)
	self._ccbOwner.btn_month_card:setVisible(false)
	self._ccbOwner.tf_welfareAddCount:setVisible(false)
	local options = self:getOptions()
	options.instanceType = instanceType
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		self._mapWidget = QUIWidgetInstanceNormalMap.new()
		self._ccbOwner.map_content:addChild(self._mapWidget)
		self._maxWidth = self._mapWidget:getMaxWidth()
		if self._mapEffect ~= nil then 
			self._ccbOwner.map_effect_content:removeChild(self._mapEffect)
			self._mapEffect = nil
		end
		self._ccbOwner.btn_normal:setTouchEnabled(false)
		self._ccbOwner.btn_normal:setHighlighted(true)
		self._ccbOwner.tf_normal_name:setColor(COLORS.U)
		if app.unlock:getUnlockElite() == true then
			self._ccbOwner.btn_elite:setTouchEnabled(true)
			self._ccbOwner.btn_elite:setHighlighted(false)
		end
		if app.unlock:getUnlockWelfare() == true then
			self._ccbOwner.btn_welfare:setTouchEnabled(true)
			self._ccbOwner.btn_welfare:setHighlighted(false)
		end
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		self._mapWidget = QUIWidgetInstanceEliteMap.new()
		self._ccbOwner.map_content:addChild(self._mapWidget)
		self._maxWidth = self._mapWidget:getMaxWidth()
		local ccbFile = "ccb/effects/instance_snow.ccbi"
		if self._mapEffect ~= nil then 
			self._ccbOwner.map_effect_content:removeChild(self._mapEffect)
			self._mapEffect = nil
		end
		self._mapEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.map_effect_content:addChild(self._mapEffect)
		self._mapEffect :setPosition(ccp(0, 0))
		local effectFun = function()
			local owner = self._mapEffect:playAnimation(ccbFile, function() end, function() end, false)
			local snow_1 = tolua.cast(tolua.cast(owner.snow_1:getChildren():objectAtIndex(0), "CCNode"):getChildren():objectAtIndex(0), "CCParticleSystemQuad")
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			snow_1:update(0.125)
			local snow_2 = tolua.cast(tolua.cast(owner.snow_2:getChildren():objectAtIndex(0), "CCNode"):getChildren():objectAtIndex(0), "CCParticleSystemQuad")
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			snow_2:update(0.125)
			local snow_3 = tolua.cast(tolua.cast(owner.snow_3:getChildren():objectAtIndex(0), "CCNode"):getChildren():objectAtIndex(0), "CCParticleSystemQuad")
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
			snow_3:update(0.125)
		end
		effectFun()
		self._ccbOwner.btn_normal:setTouchEnabled(true)
		self._ccbOwner.btn_normal:setHighlighted(false)
		self._ccbOwner.tf_elite_name:setColor(COLORS.U)
		if app.unlock:getUnlockElite() == true then
			self._ccbOwner.btn_elite:setTouchEnabled(false)
			self._ccbOwner.btn_elite:setHighlighted(true)
		end
		if app.unlock:getUnlockWelfare() == true then
			self._ccbOwner.btn_welfare:setTouchEnabled(true)
			self._ccbOwner.btn_welfare:setHighlighted(false)
		end
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		self._mapWidget = QUIWidgetInstanceWelfareMap.new()
		self._ccbOwner.map_content:addChild(self._mapWidget)
		self._maxWidth = self._mapWidget:getMaxWidth()
		local ccbFile = "ccb/effects/instance_fire.ccbi"
		if self._mapEffect ~= nil then 
			self._ccbOwner.map_effect_content:removeChild(self._mapEffect)
			self._mapEffect = nil
		end
		self._mapEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.map_effect_content:addChild(self._mapEffect)
		self._mapEffect :setPosition(ccp(0, 0))
		local effectFun = function()
			local owner = self._mapEffect:playAnimation(ccbFile, function() end, function() end, false)
			local fire_1 = owner.fire_1
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			fire_1:update(0.125)
			local fire_2 = owner.fire_2
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
			fire_2:update(0.125)
		end
		effectFun()
		self._ccbOwner.btn_normal:setTouchEnabled(true)
		self._ccbOwner.btn_normal:setHighlighted(false)
		self._ccbOwner.tf_welfare_name:setColor(COLORS.U)
		if app.unlock:getUnlockElite() == true then
			self._ccbOwner.btn_elite:setTouchEnabled(true)
			self._ccbOwner.btn_elite:setHighlighted(false)
		end
		if app.unlock:getUnlockWelfare() == true then
			self._ccbOwner.btn_welfare:setTouchEnabled(false)
			self._ccbOwner.btn_welfare:setHighlighted(true)
			self._ccbOwner.tf_welfareCount:setVisible(true)
		end
	end

	local cellWidth = math.floor(self._maxWidth / self._cellCount)
	if cellWidth > 0 then
		self._cellWidth = cellWidth
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
	local nightmareBoo = remote.nightmare:getDungeonRedPoint()

	self._ccbOwner.dungeon_tips_normal:setVisible( normalBoo )
	self._ccbOwner.dungeon_tips_elite:setVisible( eliteBoo )
	self._ccbOwner.dungeon_tips_welfare:setVisible( welfareBoo )
	self._ccbOwner.dungeon_tips_nightmare:setVisible(nightmareBoo)
end

--根据关卡显示副本
function QUIDialogMap:initPage()
	local index = 1

	if self._instanceType == DUNGEON_TYPE.WELFARE then
		self._renderFun = handler(self, self.renderWelfareDungen)
		self._currentInstanceIndex = remote.welfareInstance:getCurrentInstanceIndex()
		index = remote.welfareInstance:getNextInstanceIndex()
		self._totalIndex = remote.welfareInstance:getTotalOpenedInstanceCount()

		local leftCount = QVIPUtil:getWelfareCount() - remote.welfareInstance:getPassCount()
		if remote.activity:checkMonthCardActive(2) then
			leftCount = leftCount + 1
			self._ccbOwner.btn_month_card:setVisible(true)
		end
		if leftCount > QVIPUtil:getWelfareCount() then
			self._ccbOwner.tf_welfareAddCount:setVisible(true)
			self._ccbOwner.tf_welfareCount:setString("挑战次数：3   次")
		else
			self._ccbOwner.tf_welfareCount:setString(string.format("挑战次数：%d次", leftCount))
		end
		self._redPointTbl = remote.welfareInstance:getDungeonRedPointList() -- 获取二级地图小红点列表
		local tbl = remote.welfareInstance:getWelfareInfo(self._totalIndex)
		if tbl and tbl.grottos and tbl.grottos[1] and tbl.grottos[1].unlock_team_level ~= nil and remote.user.level < tonumber(tbl.grottos[1].unlock_team_level) then
			self._totalIndex = self._totalIndex -1
			index = index -1
		end
	else
		self._renderFun = handler(self, self.renderNormalDungen)
		self._needPassID = remote.instance:countNeedPassForType(self._instanceType)
		self._instanceData = remote.instance:getInstancesWithUnlockAndType(self._instanceType) -- [Kumo] 保存了一级地图中已经开启的章节
		self._totalIndex = #self._instanceData 
		self._redPointTbl = remote.instance:getDungeonRedPointList(self._instanceType) -- 获取二级地图小红点列表
		index = self._totalIndex + 1
	end

	self._nextIndex = index

	for i=1,index-1 do
		--   - 370
		local nextWidth = self:getNodePositionXByIndex(i) + self._pageWidth
		if nextWidth > self._totalWidth then
			self._totalWidth = nextWidth
		end
	end

	--禁止操作
	self:enableTouchSwallowTop()

	if self._instanceType == DUNGEON_TYPE.NORMAL then
		remote.flag:get({remote.flag.FLAG_MAP}, handler(self, self.mapMoveEffect))
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		remote.flag:get({remote.flag.FLAG_ELITE_MAP}, handler(self, self.mapMoveEffect))
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		remote.flag:get({remote.flag.FLAG_WELFARE_MAP}, handler(self, self.mapMoveEffect))
	end
	--   - 370
	if self._selectIndex ~= nil then
		local nextWidth = self:getNodePositionXByIndex(self._selectIndex) + self._pageWidth
		self:moveTo(self._pageWidth - nextWidth, false , true)
	else
		self:moveTo(self._pageWidth - self._totalWidth, false , true)
	end
end

function QUIDialogMap:getCurIndex()
	local count = (self._preIndex or 1)%self._totalNodeCount
	if count == 0 then count = self._totalNodeCount end
	return self._preIndex, count
end

--根据地图索引获取在地图中的位置
function QUIDialogMap:getNodePositionXByIndex(index)
	local offsetX = (math.ceil(index/self._totalNodeCount) - 1) * self._maxWidth
	local count = index%self._totalNodeCount
	if count == 0 then count = self._totalNodeCount end
	local _node = self._ccbOwner["node"..count]
	return _node._originPosX + offsetX, _node:getPositionY()
end

--渲染普通\精英副本
function QUIDialogMap:renderNormalDungen(renderIndex, node, index)
	if not node then 
		node = self._ccbOwner["node"..index]
	if not node then return end
	end
	self:resetAllNode(node, index)
	
	if renderIndex < self._totalIndex and renderIndex ~= self._preIndex and renderIndex > 0 then
		self:showStep(index, false)
	end
	local value = self._instanceData[renderIndex]
	if value ~= nil then
		node.renderIndex = renderIndex
		local instanceName = value.data[1].instance_name
		local name = ""
		if instanceName ~= nil then
		    local start = string.find(instanceName, " ") + 1
		    name = string.sub(instanceName, start, -1)
		end
		makeNodeFromGrayToNormal(node)
		makeNodeFromGrayToNormal(self._ccbOwner["effect"..index])
		if node ~= nil then
			node:setVisible(true)
			self._ccbOwner["tf_star"..index]:setString("")
			self._ccbOwner["sp_star"..index]:setVisible(true)
			self._ccbOwner["tf_star"..index]:setString(value.star.."/"..(#value.data * 3))
			self._ccbOwner["node_info"..index]:setVisible(true)
			self._ccbOwner["node_name"..index]:setVisible(true)
			self._ccbOwner["tf_name"..index]:setString(name)
			self._ccbOwner["tf_chapter"..index]:setString("第"..renderIndex.."章")
			-- 显示小红点
			if self._redPointTbl and self._redPointTbl[renderIndex] ~= nil then 
				self._ccbOwner["dungeon_tips_" .. index]:setVisible(self._redPointTbl[renderIndex]) 
			else
				self._ccbOwner["dungeon_tips_" .. index]:setVisible( false ) 
			end

			if self._instanceType == DUNGEON_TYPE.NORMAL then
				self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
			elseif self._instanceType == DUNGEON_TYPE.ELITE then
				self._ccbOwner["btn"..index.."_elite"]:setVisible(true)
				self._ccbOwner["btn"..index.."_normal"]:setVisible(false)
			else
				self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
			end
		end
	elseif renderIndex == self._nextIndex then
		node:setVisible(true)
		self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
		makeNodeFromNormalToGray(node)
		self._ccbOwner["tf_star"..index]:setString("")
		self._ccbOwner["sp_star"..index]:setVisible(false)
		self._ccbOwner["node_info"..index]:setVisible(true)
		self._ccbOwner["node_name"..index]:setVisible(true)
		self._ccbOwner["tf_name"..index]:setString("")
		self._ccbOwner["tf_chapter"..index]:setString("第"..renderIndex.."章")

		local tbl = remote.instance:getInstancesByIndex(self._totalIndex+1, self._instanceType)
		self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
		if #tbl > 0 then
			local preTbl = remote.instance:getInstancesByIndex(self._totalIndex, self._instanceType)
			if #preTbl > 0 and preTbl[#preTbl].info ~= nil and (preTbl[#preTbl].info.lastPassAt or 0) > 0 then
				if self._instanceType == DUNGEON_TYPE.ELITE then
					local lockIds = string.split(tbl[1].unlock_dungeon_id, ",")
					local lockId = lockIds[1]
					local lockInfo = remote.instance:getDungeonById(lockId)
				    -- local start = string.find(lockInfo.instance_name, " ") + 1
				    -- text = "通关" .. string.sub(lockInfo.instance_name, start, -1) .. "章节后开启"
				    local text = "通关普通第"..lockInfo.instanceIndex.."章节后开启"
					self._ccbOwner["tf_explanation"..index]:setString(text)
				elseif self._instanceType == DUNGEON_TYPE.NORMAL then
					self._ccbOwner["tf_explanation"..index]:setString("战队等级达到"..tbl[1].unlock_team_level.."开启")
					self._ccbOwner["tf_explanation"..index]:setColor(GAME_COLOR_LIGHT.warning)
					if tbl[1].unlock_team_level > 130 then
						self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
					end
				end
			elseif #preTbl > 0 and tbl[1].unlock_team_level > remote.user.level and self._instanceType == DUNGEON_TYPE.NORMAL then
				self._ccbOwner["tf_explanation"..index]:setString("战队等级达到"..tbl[1].unlock_team_level.."开启")
				self._ccbOwner["tf_explanation"..index]:setColor(GAME_COLOR_LIGHT.warning)
				if tbl[1].unlock_team_level > 130 then
					self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
				end

			else
				local name = ""
				local instanceName = tbl[1].instance_name
				if instanceName ~= nil then
				    local start = string.find(instanceName, " ") + 1
				    name = string.sub(instanceName, start, -1)
				end
				self._ccbOwner["node_info"..index]:setVisible(true)
				self._ccbOwner["tf_name"..index]:setString(name)
				self._ccbOwner["tf_explanation"..index]:setString("")
			end
		end
		self._ccbOwner["sp_pass"..index]:setVisible(false)
		self._ccbOwner["tf_explanation"..index]:setVisible(true)
	end
end

--渲染福利副本
function QUIDialogMap:renderWelfareDungen(renderIndex, node, index)
	local node = self._ccbOwner["node"..index]
	self:resetAllNode(node, index)
	if renderIndex < self._totalIndex and renderIndex ~= self._preIndex then
		self:showStep(index, false)
	end
	if renderIndex <= self._totalIndex then
		node.renderIndex = renderIndex
		makeNodeFromGrayToNormal(node)
		makeNodeFromGrayToNormal(self._ccbOwner["effect"..index])
		if node ~= nil then
			node:setVisible(true)
			self._ccbOwner["tf_star"..index]:setString("")
			self._ccbOwner["sp_star"..index]:setVisible(false)
			self._ccbOwner["node_info"..index]:setVisible(true)
			self._ccbOwner["node_name"..index]:setVisible(true)
			self._ccbOwner["tf_explanation"..index]:setVisible(false)
			if renderIndex < tonumber(self._totalIndex) then
				self._ccbOwner["sp_pass"..index]:setVisible(true)
			else
				local isPass = remote.welfareInstance:isThisInstanceAllPass(self._totalIndex)
				if isPass then
					self._ccbOwner["sp_pass"..index]:setVisible(true)
				else
					self._ccbOwner["sp_pass"..index]:setVisible(false)
				end
				
			end
			local instanceProgress = QUIWidgetInstanceProgress.new()
			self._ccbOwner["node_progressStrip"..index]:removeAllChildren()
			self._ccbOwner["node_progressStrip"..index]:addChild(instanceProgress)
			self._ccbOwner["node_progressStrip"..index]:setVisible(true)
			local cur, total = remote.welfareInstance:getProgressByIndex(renderIndex)
			instanceProgress:updateProgress(cur, total)

			-- 显示小红点
			if self._redPointTbl[renderIndex] ~= nil then 
				self._ccbOwner["dungeon_tips_" .. index]:setVisible(self._redPointTbl[renderIndex]) 
			else
				self._ccbOwner["dungeon_tips_" .. index]:setVisible( false ) 
			end 

			self._ccbOwner["btn"..index.."_welfare"]:setVisible(true)
			self._ccbOwner["btn"..index.."_normal"]:setVisible(false)
			local tbl = remote.welfareInstance:getWelfareInfo(renderIndex)
		    local start = string.find(tbl.instance_name, " ") + 1
		    local name = string.sub(tbl.instance_name, start, -1)
			self._ccbOwner["tf_name"..index]:setString(name)
			self._ccbOwner["tf_chapter"..index]:setString("第"..renderIndex.."章")	
		end
	elseif renderIndex == self._nextIndex then
		node:setVisible(true)
		self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
		makeNodeFromNormalToGray(node)
		self._ccbOwner["tf_star"..index]:setString("")
		self._ccbOwner["sp_star"..index]:setVisible(false)
		self._ccbOwner["node_info"..index]:setVisible(true)
		self._ccbOwner["node_name"..index]:setVisible(true)
		self._ccbOwner["tf_name"..index]:setString("")
		self._ccbOwner["tf_chapter"..index]:setString("第"..renderIndex.."章")		
		self._ccbOwner["sp_pass"..index]:setVisible(false)
		if remote.welfareInstance:isInstanceExistence(renderIndex) then
			local tbl = remote.welfareInstance:getWelfareInfo(self._totalIndex+1)
			self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
			if tbl then
				local preTbl = remote.welfareInstance:getWelfareInfo(self._totalIndex)
				if preTbl and preTbl.grottos and preTbl.grottos[1] and preTbl.grottos[1].unlock_team_level ~= nil and remote.user.level < tonumber(preTbl.grottos[1].unlock_team_level) then
					if self._instanceType == DUNGEON_TYPE.WELFARE then
						self._ccbOwner["tf_explanation"..index]:setString("战队等级达到"..tbl.grottos[1].unlock_team_level.."开启")
						self._ccbOwner["tf_explanation"..index]:setColor(GAME_COLOR_LIGHT.warning)
						if preTbl.grottos[1].unlock_team_level > 130 then
							self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
						end
						self._ccbOwner["tf_explanation"..index]:setVisible(true)
					end
				else
					local text = remote.welfareInstance:getExplanationText(renderIndex)
					if text ~= "" then
						self._ccbOwner["tf_explanation"..index]:setString(text)
						self._ccbOwner["tf_explanation"..index]:setVisible(true)
					else
						self._ccbOwner["node_name"..index]:setVisible(false)
					end
				end
			end	
		else
			self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
			self._ccbOwner["tf_explanation"..index]:setVisible(false)
		end
	end
end

function QUIDialogMap:mapMoveEffect(tbl)
	local effectIndex = 0
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		effectIndex = tonumber(tbl[remote.flag.FLAG_MAP])
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		effectIndex = tonumber(tbl[remote.flag.FLAG_ELITE_MAP])
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		effectIndex = tonumber(tbl[remote.flag.FLAG_WELFARE_MAP])
	end
	if self._moveEffectSchduler ~= nil then
		scheduler.unscheduleGlobal(self._moveEffectSchduler)
		self._moveEffectSchduler = nil
	end
	self._preIndex = self._totalIndex
	if effectIndex ~= nil and effectIndex > 0 and self._preIndex > 1 and effectIndex ~= self._preIndex then
		self._preIndex = self._preIndex - 1
		local nextFun = function ()
			self:showStep(self._preIndex, true, function ()
				self:showBattleEffect()
			end)
			self._preIndex = self._totalIndex
		end
		self._moveEffectSchduler = scheduler.performWithDelayGlobal(function ()
			self._moveEffectSchduler = nil
			self:showPassEffect(self._preIndex, nextFun)
		end,0)
	else
		self._moveEffectSchduler = scheduler.performWithDelayGlobal(function ()
			self._moveEffectSchduler = nil
			self:showBattleEffect()
		end,0)
	end
	self._stepSchedulers = {}

	if self._instanceType == DUNGEON_TYPE.NORMAL then
		remote.flag:set(remote.flag.FLAG_MAP,self._totalIndex)
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		remote.flag:set(remote.flag.FLAG_ELITE_MAP,self._totalIndex)
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		remote.flag:set(remote.flag.FLAG_WELFARE_MAP,self._totalIndex)
	end
end

function QUIDialogMap:showPassEffect(index, callback)
	index = index % self._totalNodeCount
	if index == 0 then
		index = self._totalNodeCount
	end
	local node = self._ccbOwner["node"..index]
	if node ~= nil then
		if self._passEffect == nil then
			self._passEffect = QUIWidgetAnimationPlayer.new()
			self._ccbOwner.node_fight:addChild(self._passEffect)
			self._passEffect:setPosition(ccp(node:getPositionX(), node:getPositionY()))
			self._passEffect:playAnimation("effects/fireworks.ccbi",nil,callback)
    		app.sound:playSound("map_fireworks")
		end
	end
end

function QUIDialogMap:showStep(index, isDelay, callback)
	index = index % self._totalNodeCount
	if index == 0 then
		index = self._totalNodeCount
	end
	local dotNode = self._ccbOwner["dot"..index]
	if dotNode == nil then
		return false
	end
	dotNode:setVisible(true)
	local dotCount = dotNode:getChildrenCount()
    local dots = dotNode:getChildren()
	for i=1,dotCount do
		local dot = tolua.cast(dots:objectAtIndex(i-1), "CCNode")
		dot:setVisible(false)
		if isDelay == true then
			local handler = scheduler.performWithDelayGlobal(function ()
				dot:setVisible(true)
			end, i*0.2)
			table.insert(self._stepSchedulers, handler)
		else
			dot:setVisible(true)
		end
	end

	if callback ~= nil then
		local handler = scheduler.performWithDelayGlobal(function ()
			self._stepSchedulers = {}
			callback()
		end, dotCount*0.2)
		table.insert(self._stepSchedulers, handler)
	end
	return true
end

function QUIDialogMap:hideStep(index)
	local dotNode = self._ccbOwner["dot"..index]
	dotNode:setVisible(false)
end

function QUIDialogMap:showBattleEffect()
	--允许操作
	self:disableTouchSwallowTop()
	if self._battleEffect == nil then
		local posX,posY
		if self._totalIndex == 0 then
			posX,posY = self:getNodePositionXByIndex(1)
		else
			posX,posY = self:getNodePositionXByIndex(self._totalIndex)
		end
		self._battleEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_fight:addChild(self._battleEffect)
		self._battleEffect:setPosition(ccp(posX, posY + 60))
		self._battleEffect:playAnimation("effects/battle_ing.ccbi",nil,nil,false)
	end
end

function QUIDialogMap:selectMap(index)
	local options = self:getOptions()
	options.selectIndex = index
	app:showCloudInterlude(function( cloudInterludeCallBack )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {currentIndex = index, instanceType = self._instanceType, cloudInterludeCallBack = cloudInterludeCallBack}})		
		end)
end

function QUIDialogMap:madeTouchLayer()
	self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = self._size.width
	self._pageHeight = self._size.height
	self._mapContent = self._ccbOwner.node_map
    CalculateBattleUIPosition(self._ccbOwner.node_offside , true)

	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer,self._size.width,self._size.height, 0, -self._size.height/2, handler(self, self.onTouchEvent))
end

function QUIDialogMap:onTouchEvent(event)
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

function QUIDialogMap:_removeAction()
	if self._actionHandler ~= nil then
		self._mapContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogMap:moveTo(posX, isAnimation, isCheck)
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

function QUIDialogMap:_contentRunAction(posX,posY)
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
function QUIDialogMap:_startOnEnterFrame()
	self:_stopOnEnterFrame()
	self._enterFrameHandler = scheduler.scheduleGlobal(function ()
		self:_onMoveHandler()
	end,0)
end

function QUIDialogMap:_stopOnEnterFrame()
	if self._enterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._enterFrameHandler)
		self._enterFrameHandler = nil
	end
end

function QUIDialogMap:_onMoveHandler(isForce)
	local posX = self._mapContent:getPositionX()
	local offsetCell = math.ceil(posX/self._cellWidth)
	if self._offsetCell == offsetCell and isForce ~= true then return end
	self._offsetCell = offsetCell
	local startCell = self._cellCount - self._offsetCell%self._cellCount
	for i = 1, self._cellCount do
		local cells = self._moveCell[startCell]
		if cells ~= nil then
			for _,node in ipairs(cells) do
				node:setPositionX((i - 2 - self._offsetCell) * self._cellWidth + node._cellPosX)
			end
		end
		startCell = startCell + 1
		if startCell > self._cellCount then
			startCell = 1
		end
	end

	--计算起始的node节点
	local totalIndex = self._totalNodeCount
	local offsetIndex = -math.ceil((offsetCell+1)/self._cellCount) --此处加1为了让cell从第二格子计算(默认第一个格子会是最后一个cell块，则会造成从第20个开始计算)
	local startIndex = 1
	local smallPosX = nil
	for index,node in ipairs(self._moveNode) do
		if smallPosX == nil then
			smallPosX = node:getPositionX()
			startIndex = index
		elseif smallPosX > node:getPositionX() then
			smallPosX = node:getPositionX()
			startIndex = index
		end
	end
	local printStr = ""
	for index,node in ipairs(self._moveNode) do
		local renderIndex = index
		if index < startIndex then
			renderIndex = ((offsetIndex + 1) * totalIndex) + index
		else
			renderIndex = (offsetIndex * totalIndex) + index
		end
		self:hideStep(index)
		if renderIndex > 0 then
			self._renderFun(renderIndex, node, index)
		end
	end
end

function QUIDialogMap:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIDialogMap:_onTriggerClick(event, target)
	if q.buttonEventShadow(event, target) == false then return end
	if self._isMove == true then return end

    app.sound:playSound("common_small")
	local index = 1
	while true do
		local btn = nil
		if self._instanceType == DUNGEON_TYPE.NORMAL then
			btn = self._ccbOwner["btn"..index.."_normal"]
		elseif self._instanceType == DUNGEON_TYPE.ELITE then
			btn = self._ccbOwner["btn"..index.."_elite"]
		elseif self._instanceType == DUNGEON_TYPE.WELFARE then
			btn = self._ccbOwner["btn"..index.."_welfare"]

			-- 如果福利副本第一章不可以攻打，则弹出提示
			if index == 1 and remote.instance:checkIsPassByDungeonId("wailing_caverns_3_elite") == false then
				app.tip:floatTip("魂师大人，通关学院报名才能开启史诗副本哟~继续加油哦！")
			end
		else
			btn = self._ccbOwner["btn"..index.."_normal"]
		end
		if index <= self._totalIndex and btn ~= nil then
			if btn == target then
				local renderIndex = self._ccbOwner["node"..index].renderIndex
				if renderIndex ~= nil then
					self:selectMap(renderIndex)
				end
				break
			end
		else
			break
		end
		index = index + 1
	end
end

function QUIDialogMap:userUpdateHandler(event)
	self:_checkEliteIsOpen()
	self:_checkWelfareIsOpen()
	self:_checkUnlockTutorial()
end

function QUIDialogMap:_checkEliteIsOpen()
	local isUnlock = app.unlock:getUnlockElite()
	if isUnlock then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_elite)
	else
		makeNodeFromNormalToGray(self._ccbOwner.btn_elite)
	end
end

function QUIDialogMap:_checkWelfareIsOpen()
	local isUnlock = app.unlock:getUnlockWelfare()
	if isUnlock then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_welfare)
	else
		makeNodeFromNormalToGray(self._ccbOwner.btn_welfare)
	end
end

function QUIDialogMap:_checkNightmareIsOpen()
	if ENABLE_NIGHTMARE == false then
		self._ccbOwner.btn_nightmare:setVisible(ENABLE_NIGHTMARE)
		self._ccbOwner.dungeon_tips_nightmare:setVisible(ENABLE_NIGHTMARE)
		return
	end

	local isUnlock = app.unlock:getUnlockNightmare()

	self._ccbOwner.btn_nightmare:setVisible(isUnlock)
	self._ccbOwner.dungeon_tips_nightmare:setVisible(isUnlock)
	if isUnlock then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_nightmare)
	else
		makeNodeFromNormalToGray(self._ccbOwner.btn_nightmare)
	end
end

function QUIDialogMap:_checkUnlockTutorial()
	if app.tip:isUnlockTutorialFinished() == false then
	    local unlockTutorial = app.tip:getUnlockTutorial()
	    if unlockTutorial.elites == app.tip.UNLOCK_TUTORIAL_OPEN then
			if self.eliteHandTouch == nil then
				self.eliteHandTouch = app.tip:createUnlockTutorialTip("elites", self)
			end
	    elseif unlockTutorial.welfare == app.tip.UNLOCK_TUTORIAL_OPEN then
	    	if self.welfareHandTouch == nil then
				self.welfareHandTouch = app.tip:createUnlockTutorialTip("welfare", self)
			end

	  --   elseif unlockTutorial.night == app.tip.UNLOCK_TUTORIAL_OPEN then
	  --   	if self.nightHandTouch == nil then
			-- 	self.nightHandTouch = app.tip:createUnlockTutorialTip("night", self)
			-- end
	    end
	    
	    if self._isShowTanNian and self._showType then
			if app.tip.UNLOCK_TIP_ISTRUE == false then
				app.tip:showUnlockTips(self._showType)
			else
				app.tip:addUnlockTips(self._showType)
			end
			self._showType = nil
			self:getOptions().showType = nil
	    end
	end
end

--关闭解锁引导
function QUIDialogMap:_closeUnlockTutorial(data)
	if data.type == "elites" then
		if self.eliteHandTouch ~= nil then
			self.eliteHandTouch:removeFromParent()
			self.eliteHandTouch = nil
			self:_onTriggerElite()
		end
	elseif data.type == "welfare" then
		if self.welfareHandTouch ~= nil then
			self.welfareHandTouch:removeFromParent()
			self.welfareHandTouch = nil
			self:_onTriggerWelfare()
		end
	elseif data.type == "night" then
		if self.nightHandTouch ~= nil then
			self.nightHandTouch:removeFromParent()
			self.nightHandTouch = nil
			self:_onTriggerNightmare()
		end
	end

	app.tip:removeouchNode()
end

function QUIDialogMap:_onTriggerNormal() 
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	-- if self._isAnimation == true then return end
	app:showCloudInterlude(function( cloudInterludeCallBack )
			if self:safeCheck() then
				self:selectType(DUNGEON_TYPE.NORMAL)
				if cloudInterludeCallBack then
					cloudInterludeCallBack()
				end
			end
		end)
end

function QUIDialogMap:_onTriggerElite()
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	-- if self._isAnimation == true then return end
	if app.unlock:getUnlockElite(true) == false then
		-- local config = QStaticDatabase.sharedDatabase:getUnlock()
		-- local level = config["UNLOCK_ELITE"].team_level
		-- app.tip:floatTip("战队等级"..level.."级开启")
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
	app:showCloudInterlude(function( cloudInterludeCallBack )
			if self:safeCheck() then
				self:selectType(DUNGEON_TYPE.ELITE)
				if cloudInterludeCallBack then
					cloudInterludeCallBack()
				end
			end
		end)
end

function QUIDialogMap:_onTriggerWelfare()
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	-- if self._isAnimation == true then return end
	if app.unlock:getUnlockWelfare(true) == false then
		-- local config = QStaticDatabase.sharedDatabase:getUnlock()
		-- local level = config["UNLOCK_FULIFUBEN_TRIAL"].team_level
		-- app.tip:floatTip("战队等级"..level.."级开启")
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
	app:showCloudInterlude(function( cloudInterludeCallBack )
			if self:safeCheck() then
				self:selectType(DUNGEON_TYPE.WELFARE)
				if cloudInterludeCallBack then
					cloudInterludeCallBack()
				end
			end
		end)
end

function QUIDialogMap:_onTriggerNightmare()
    app.sound:playSound("battle_change")
	if self._isMove == true then return end
	if ENABLE_NIGHTMARE == false or app.unlock:getUnlockNightmare(true) == false then
		return
	end
	remote.nightmare:setDungeonClick()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMapNightmare",  
        options = {}})
end

function QUIDialogMap:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogMap:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogMap:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMap:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMap