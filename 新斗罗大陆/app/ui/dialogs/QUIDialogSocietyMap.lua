--
-- Author: Kumo.Wang
-- Date: Thu May 19 17:52:33 2016
-- 宗门副本的一级场景
--
-- local QUIDialog = import(".QUIDialog")
local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QUIDialogSocietyMap = class("QUIDialogSocietyMap", QUIDialogBaseUnion)
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetInstanceProgress = import("..widgets.QUIWidgetInstanceProgress")
local QUIWidgetSocietyNormalMap = import("..widgets.QUIWidgetSocietyNormalMap")
-- local QUIWidgetInstanceEliteMap = import("..widgets.QUIWidgetInstanceEliteMap")
-- local QUIWidgetInstanceWelfareMap = import("..widgets.QUIWidgetInstanceWelfareMap")
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogSocietyMap:ctor(options)
	local ccbFile = "ccb/Dialog_SocietyDungeon_Map.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerClickRank", callback = handler(self, self._onTriggerClickRank)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
	}
	QUIDialogSocietyMap.super.ctor(self, ccbFile, callBacks, options)

end

function QUIDialogSocietyMap:viewDidAppear()
    QUIDialogSocietyMap.super.viewDidAppear(self)
    self:addBackEvent()

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

	-- self._userProxy = cc.EventProxy.new(remote.user)
	-- self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.userUpdateHandler))

 	self.unionProxy = cc.EventProxy.new(remote.union)
    self.unionProxy:addEventListener(remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.SOCIETY_RECEIVED_AWARD_SUCCESS, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.SOCIETY_BOSS_DEAD, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.NEW_DAY, handler(self, self.updateUnionHandler))

    self._ccbOwner.award_tips:setVisible(false)

	self._isRefresh = true -- 宗门副本的进度条刷新限制，不然拖动地图的时候会很卡
	self._preStarIndex = 0 -- 记录一下起始需要刷新的node位置
	self._gapNum = 5   -- 地图章节间距

	-- 因为服务器是异步处理生产下一章节BOSS信息的，可能会出现没有拉到的情况，所以，前端在进入的时候，发现当前战斗的章节BOSS都死了，就再拉一次数据
	local isCurChapterPass = remote.union:getCurBossHpByChapter(remote.union:getFightChapter()) == 0
	local options = self:getOptions()
	local totalChapter = table.nums(QStaticDatabase.sharedDatabase():getAllScoietyChapter())
	if isCurChapterPass and remote.union:getFightChapter() < totalChapter then
		remote.union:unionGetBossListRequest(function()
			if options.instanceType ~= nil then
		    	self:selectType(options.instanceType)
			else
		    	self:selectType(DUNGEON_TYPE.NORMAL)
			end
		end, function()
			app.tip:floatTip("无法获取实时BOSS信息，请检查下当前网络是否稳定")
		end)
	end

	if options.instanceType ~= nil then
    	self:selectType(options.instanceType)
	else
    	self:selectType(DUNGEON_TYPE.NORMAL)
	end

	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIDialogSocietyMap:viewWillDisappear()
	self:_stopOnEnterFrame()
	if self._animationDelayHandler ~= nil then
		scheduler.unscheduleGlobal(self._animationDelayHandler)
		self._animationDelayHandler = nil
	end

    QUIDialogSocietyMap.super.viewWillDisappear(self)
	self:removeBackEvent()

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    -- self._userProxy:removeAllEventListeners()
    -- self._userProxy = nil
    
    self.unionProxy:removeAllEventListeners()

    if self._stepSchedulers ~= nil then
    	for _,handler in pairs(self._stepSchedulers) do
    		scheduler.unscheduleGlobal(handler)
    	end
    end
    if self._passEffect ~= nil then
    	self._passEffect:disappear()
    	self._passEffect = nil
    end
    if self._battleEffect ~= nil then
    	self._battleEffect:disappear()
    	self._battleEffect = nil
    end

	-- if self.eliteHandTouch ~= nil then
	-- 	self.eliteHandTouch:removeFromParent()
	-- 	self.eliteHandTouch = nil
	-- end
	-- if self.welfareHandTouch ~= nil then
	-- 	self.welfareHandTouch:removeFromParent()
	-- 	self.welfareHandTouch = nil
	-- end
	if self._moveEffectSchduler ~= nil then
		scheduler.unscheduleGlobal(self._moveEffectSchduler)
		self._moveEffectSchduler = nil
	end

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIDialogSocietyMap:_init(options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)
	if options == nil then
		options = {}
		self:setOptions(options)
	end

	self._selectIndex = options.selectIndex

	self._totalWidth = 0
	self._maxWidth = 4500 --最大宽度
	self:madeTouchLayer()
	-- self._ccbOwner.elite_light:setVisible(false)
	-- self._ccbOwner.welfare_light:setVisible(false)
	-- self:_checkEliteIsOpen()
	-- self:_checkWelfareIsOpen()
	self._isRefresh = true
	self._preStarIndex = 0
	self._gapNum = 5

	-- local animation = nil
	-- animation = QSkeletonActor:create("tujiu_03_yasuo")
	-- self._ccbOwner.vulture:addChild(animation)
	-- animation:playAnimation("feixin", true)

	-- animation = QSkeletonActor:create("tujiu_03_yasuo")
	-- self._ccbOwner.vulture2:addChild(animation)
	-- animation:playAnimation("feixin", true)

	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.4)
	-- animation:setSkeletonScaleY(0.4)

	-- animation = QSkeletonActor:create("blc")
	-- self._ccbOwner.boat1:addChild(animation)
	-- animation:playAnimation("animation", true)
	-- animation:setSkeletonScaleX(0.9)
	-- animation:setSkeletonScaleY(0.9)
	-- animation:setAnimationScale(0.333)

	-- animation = QSkeletonActor:create("lmc")
	-- self._ccbOwner.boat2:addChild(animation)
	-- animation:setSkeletonScaleX(0.9)
	-- animation:setSkeletonScaleY(0.9)
	-- animation:setAnimationScale(0.333)
	-- animation:setVisible(false)
	-- self._animationDelayHandler = scheduler.performWithDelayGlobal(function()
	-- 	animation:setVisible(true)
	-- 	animation:playAnimation("animation", true)
	-- 	self._animationDelayHandler = nil
	-- end, 10.0)

	self._cellWidth = 942 --单位区块的宽度
	self._moveCell = {} --需要根据区块移动的单位
	self._moveNode = {} --需要根据区块移动的地图节点

	self:addToMoveNode(self._ccbOwner.vulture)
	self:addToMoveNode(self._ccbOwner.boat1)
	self:addToMoveNode(self._ccbOwner.boat2)

	local index = 1
	while true do
		local node = self._ccbOwner["node"..index]
		local node_info = self._ccbOwner["node_info"..index]
		if node ~= nil and node_info ~= nil then
			self:addToMoveNode(node)
			self:addToMoveNode(node_info)
			table.insert(self._moveNode, node)
			self:resetAllNode(node, index)
			index = index + 1
		else
			break
		end
	end

	self._totalNodeCount = #self._moveNode
	self:resetAll()

	local barClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
    self._stencil = barClippingNode:getStencil()
    self._totalStencilWidth = self._stencil:getContentSize().width * self._stencil:getScaleX()
    -- self._stencil:setPositionX(-self._totalStencilWidth + 0 * self._totalStencilWidth)
	-- self._initTotalHpScaleX = self._ccbOwner.sp_progress:getScaleX()
	self._chapter = remote.union:getFightChapter()

	-- self._ccbOwner.tf_name = setShadow5(self._ccbOwner.tf_name)
	-- self._ccbOwner.tf_reset_info = setShadow5(self._ccbOwner.tf_reset_info)
end

function QUIDialogSocietyMap:_onTriggerRule()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if self._isAnimation == true then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonRuleNew"})
end

function QUIDialogSocietyMap:_onTriggerReset()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if self._isAnimation == true then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonReset", options = {resetMode = 0}}, {isPopCurrentDialog = false})
end

function QUIDialogSocietyMap:_onTriggerAward()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if self._isAnimation == true then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyDungeonAward"}, {isPopCurrentDialog = false} )
end

function QUIDialogSocietyMap:_onTriggerShop()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if self._isAnimation == true then return end
	remote.stores:openShopDialog(SHOP_ID.consortiaShop)
end 

function QUIDialogSocietyMap:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if self._isAnimation == true then return end
	
	if remote.union:checkUnionDungeonIsOpen(true) == false then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionInstance"}})
end

function QUIDialogSocietyMap:updateUnionHandler( event )
	if event.name == remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS then
		self._isRefresh = true
		self:_updateMapInfo()
	elseif event.name == remote.union.SOCIETY_RECEIVED_AWARD_SUCCESS then
		self._isRefresh = true
		-- 刷新通关奖励小红点
		if remote.union:checkSocietyDungeonAwardRedTips() then
			self._ccbOwner.award_tips:setVisible(true)
		else
			self._ccbOwner.award_tips:setVisible(false)
		end
		self:_updateMapInfo()
		
	elseif event.name == remote.union.SOCIETY_BOSS_DEAD then
		-- print("[Kumo] QUIDialogSocietyMap:updateUnionHandler() SOCIETY_BOSS_DEAD", self._chapter, remote.union:getFightChapter())
		self._isRefresh = true
		if remote.union:getCurBossHpByChapter(self._chapter) == 0 then
			self._chapter = remote.union:getFightChapter()
			local options = self:getOptions()
			if options.instanceType ~= nil then
		    	self:selectType(options.instanceType)
			else
		    	self:selectType(DUNGEON_TYPE.NORMAL)
			end
		else
		    self:_updateMapInfo()
		    self:_updateCapterProgress()
		end
	elseif event.name == remote.union.NEW_DAY then
		self._isRefresh = true
		local options = self:getOptions()
		if options.instanceType ~= nil then
	    	self:selectType(options.instanceType)
		else
	    	self:selectType(DUNGEON_TYPE.NORMAL)
		end
	end
end

--先不显示所有的副本
function QUIDialogSocietyMap:resetAll()
	for index, node in ipairs(self._moveNode) do
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
end

--重置node点
function QUIDialogSocietyMap:resetAllNode(node, index)
	makeNodeFromNormalToGray(node)
	node.renderIndex = nil
	-- self._ccbOwner["sp_star"..index]:setVisible(false)
	self._ccbOwner["sp_pass"..index]:setVisible(false)
	self._ccbOwner["tf_name"..index]:setString("")
	-- self._ccbOwner["tf_star"..index]:setString("")
	self._ccbOwner["tf_explanation"..index]:setString("")
	self._ccbOwner["tf_explanation"..index]:setVisible(false)
	if self._isRefresh then
		self._ccbOwner["node_progressStrip"..index]:setVisible(false)
		if self._ccbOwner["dungeon_tips_" .. index] ~= nil then self._ccbOwner["dungeon_tips_" .. index]:setVisible( false ) end
	end
	if self._ccbOwner["dot"..index] ~= nil then self._ccbOwner["dot"..index]:setVisible(false) end
	
	-- self._ccbOwner["btn"..index.."_welfare"]:setVisible(false)
	self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
	-- self._ccbOwner["btn"..index.."_elite"]:setVisible(false)
	self._ccbOwner["node_info"..index]:setVisible(false)
end

function QUIDialogSocietyMap:addToMoveNode(node)
	local posX = node:getPositionX()
	node._originPosX = posX --保存起始位置
	local pos = math.ceil(posX/self._cellWidth)%self._gapNum
	if pos < 1 then pos = self._gapNum - pos end
	if self._moveCell[pos] == nil then
		self._moveCell[pos] = {}
	end
	node._cellPosX = posX%self._cellWidth --相对的区块的位置
	table.insert(self._moveCell[pos], node)
end

--根据副本类型显示副本内容
function QUIDialogSocietyMap:selectType(instanceType)
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
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		self._mapWidget = QUIWidgetSocietyNormalMap.new()
		self._ccbOwner.map_content:addChild(self._mapWidget)
		self._maxWidth = self._mapWidget:getMaxWidth()
		if self._mapEffect ~= nil then 
			self._ccbOwner.map_effect_content:removeChild(self._mapEffect)
			self._mapEffect = nil
		end
	end
	self._cellWidth = math.floor(self._maxWidth / self._gapNum)
	if self._mapWidget.getMapNode ~= nil then
		local mapNodes = self._mapWidget:getMapNode()
		for _,node in ipairs(mapNodes) do
			self:addToMoveNode(node)
		end
	end
	self:initPage()
end

--根据关卡显示副本
function QUIDialogSocietyMap:initPage()
	local index = 1

	if self._instanceType == DUNGEON_TYPE.WELFARE then
	else
		self._renderFun = handler(self, self.renderNormalDungen)
		-- self._needPassID = remote.union:getFightChapter()
		-- self._societyData = remote.instance:getInstancesWithUnlockAndType(self._instanceType) -- [Kumo] 保存了一级地图中已经开启的章节
		self._societyData = remote.union:getSocietyUnlockData()
		-- QPrintTable(self._societyData)
		self._totalIndex = #self._societyData or 0
		--Kumo
		-- self._redPointTbl = remote.instance:getDungeonRedPointList(self._instanceType) -- 获取二级地图小红点列表
		index = self._totalIndex + 1
	end

	self._nextIndex = index

	for i = 1, index - 1 do
		local nextWidth = self:getNodePositionXByIndex(i) + self._pageWidth
		if nextWidth > self._totalWidth then
			self._totalWidth = nextWidth
		end
	end
	if self._totalWidth > self._maxWidth*2 then
		self._totalWidth = self._totalWidth - display.width/2 + 100
	end
	
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		-- print("[Kumo] QUIDialogSocietyMap:initPage() flag get", remote.flag.FLAG_SOCIETY_MAP)
		self._isAnimation = true
		remote.flag:get({remote.flag.FLAG_SOCIETY_MAP}, handler(self, self.mapMoveEffect))
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		-- self._isAnimation = true
		-- remote.flag:get({remote.flag.FLAG_ELITE_MAP}, handler(self, self.mapMoveEffect))
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		-- self._isAnimation = true
		-- remote.flag:get({remote.flag.FLAG_WELFARE_MAP}, handler(self, self.mapMoveEffect))
	end

	if self._selectIndex ~= nil then
		local nextWidth = self:getNodePositionXByIndex(self._selectIndex) + self._pageWidth
		self:moveTo(self._pageWidth - nextWidth, false , true)
	else
		self:moveTo(self._pageWidth - self._totalWidth, false , true)
	end
end

--根据地图索引获取在地图中的位置
function QUIDialogSocietyMap:getNodePositionXByIndex(index)
	local offsetX = (math.ceil(index/self._totalNodeCount) - 1) * self._maxWidth
	local count = index%self._totalNodeCount
	if count == 0 then count = self._totalNodeCount end
	local _node = self._ccbOwner["node"..count]
	return _node._originPosX + offsetX, _node:getPositionY()
end

--渲染普通\精英副本
function QUIDialogSocietyMap:renderNormalDungen(renderIndex, node, index)
	print("[Kumo] QUIDialogSocietyMap:renderNormalDungen()", renderIndex, node, index)
	local value = self._societyData[renderIndex]
	self:resetAllNode(node, index)
	if renderIndex < self._totalIndex and renderIndex ~= self._preIndex and renderIndex > 0 then
		self:showStep(index, false)
	end
	if value ~= nil then
		print("[Kumo] QUIDialogSocietyMap:renderNormalDungen(1)", renderIndex, node, index)
		node.renderIndex = renderIndex
		local societyName = value[1].chapter_name
		local name = ""
		-- if societyName ~= nil then
		--     local start = string.find(societyName, " ") + 1
		--     name = string.sub(societyName, start, -1)
		-- end
		name = societyName
		makeNodeFromGrayToNormal(node)
		if node ~= nil then
			node:setVisible(true)
			-- self._ccbOwner["tf_star"..index]:setString("")
			-- self._ccbOwner["sp_star"..index]:setVisible(true)
			-- self._ccbOwner["tf_star"..index]:setString(value.star.."/"..(#value.data * 3))
			self._ccbOwner["node_info"..index]:setVisible(true)
			self._ccbOwner["node_name"..index]:setVisible(true)
			self._ccbOwner["tf_name"..index]:setString(name)
			-- self._ccbOwner["tf_name"..index]:setGap(-1)
			self._ccbOwner["tf_chapter"..index]:setString("第"..renderIndex.."章")

			if self._instanceType == DUNGEON_TYPE.NORMAL then
				self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
			elseif self._instanceType == DUNGEON_TYPE.ELITE then
				-- self._ccbOwner["btn"..index.."_elite"]:setVisible(true)
				-- self._ccbOwner["btn"..index.."_normal"]:setVisible(false)
			else
				self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
			end

			local minChapter = remote.union:getMinChapter()
			if renderIndex < minChapter then
				self._ccbOwner["sp_pass" .. index]:setVisible( true ) 
			else
				self:_updateCapterProgress(renderIndex)
			end
			-- 显示小红点
			-- if self._redPointTbl and self._redPointTbl[renderIndex] ~= nil and renderIndex >= minChapter then 
			-- 	self._ccbOwner["dungeon_tips_" .. index]:setVisible(self._redPointTbl[renderIndex]) 
			-- else
			-- 	self._ccbOwner["dungeon_tips_" .. index]:setVisible( false ) 
			-- end
		end
	elseif renderIndex == self._nextIndex then
		local config = remote.union:getSocietyDataByChapter(renderIndex)
		if config then
			local societyName = config[1].chapter_name
			local name = ""
			-- if societyName ~= nil then
			--     local start = string.find(societyName, " ") + 1
			--     name = string.sub(societyName, start, -1)
			-- end
			name = societyName
			node:setVisible(true)
			self._ccbOwner["btn"..index.."_normal"]:setVisible(true)
			makeNodeFromNormalToGray(node)
			-- makeNodeFromGrayToNormal(node)
			-- self._ccbOwner["tf_star"..index]:setString("")
			-- self._ccbOwner["sp_star"..index]:setVisible(false)
			self._ccbOwner["node_info"..index]:setVisible(true)
			self._ccbOwner["node_name"..index]:setVisible(true)
			-- self._ccbOwner["tf_name"..index]:setString("")
			self._ccbOwner["tf_name"..index]:setString(name)
			-- self._ccbOwner["tf_name"..index]:setGap(-1)
			self._ccbOwner["tf_chapter"..index]:setString("第"..renderIndex.."章")

			-- local tbl = remote.union:getSocietyDataByChapter(self._totalIndex + 1)
			-- self._ccbOwner["tf_explanation"..index]:setString("敬请期待")
			self._ccbOwner["tf_explanation"..index]:setString("")
			-- if #tbl > 0 then
			-- 	local preTbl = remote.union:getSocietyDataByChapter(self._totalIndex)
			-- 	if preTbl then
			-- 	    local text = "通关" .. preTbl[1].chapter_name .. "章节后开启"
			-- 		self._ccbOwner["tf_explanation"..index]:setString(text)
			-- 	else
			-- 		local name = ""
			-- 		local societyName = tbl[1].chapter_name
			-- 		-- if societyName ~= nil then
			-- 		--     local start = string.find(societyName, " ") + 1
			-- 		--     name = string.sub(societyName, start, -1)
			-- 		-- end
			-- 		name = societyName
			-- 		self._ccbOwner["node_info"..index]:setVisible(true)
			-- 		self._ccbOwner["tf_name"..index]:setString(name)
			-- 	end
			-- end
			self._ccbOwner["sp_pass"..index]:setVisible(false)
			self._ccbOwner["tf_explanation"..index]:setVisible(false)
		end
	end
	-- 初始化地图关卡和名字
	if not self._isMove then
		self._ccbOwner.tf_name:setString("")
		local id = self._chapter
		local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(id)
		if scoietyChapterConfig and #scoietyChapterConfig > 0 then
			self._ccbOwner.tf_name:setString("第 "..id.." 章  "..scoietyChapterConfig[1].chapter_name)
		end
	end
	self:_updateMapInfo(renderIndex)
end

-- 烟花+小点
function QUIDialogSocietyMap:mapMoveEffect(tbl)
	-- QPrintTable(tbl)
	local effectIndex = 0
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		effectIndex = tonumber(tbl[remote.flag.FLAG_SOCIETY_MAP])
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		-- effectIndex = tonumber(tbl[remote.flag.FLAG_ELITE_MAP])
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		-- effectIndex = tonumber(tbl[remote.flag.FLAG_WELFARE_MAP])
	end

	self._preIndex = self._totalIndex
	-- print("[Kumo] QUIDialogSocietyMap:mapMoveEffect()", self._preIndex, effectIndex)
	if effectIndex ~= nil and effectIndex > 0 and self._preIndex > 1 and effectIndex ~= self._preIndex then
		self._preIndex = self._preIndex - 1
		local nextFun = function ()
			self:showStep(self._preIndex, true, handler(self, self.showBattleEffect))
			self._preIndex = self._totalIndex
		end
		self._moveEffectSchduler = scheduler.performWithDelayGlobal(function ()
			self._moveEffectSchduler = nil
			self:showPassEffect(self._preIndex, nextFun)
		end, 0)
	else
		self:showBattleEffect()
	end
	self._stepSchedulers = {}

	if self._instanceType == DUNGEON_TYPE.NORMAL then
		-- print("[Kumo] QUIDialogSocietyMap:mapMoveEffect() flag set", remote.flag.FLAG_SOCIETY_MAP)
		remote.flag:set(remote.flag.FLAG_SOCIETY_MAP,self._totalIndex)
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		-- remote.flag:set(remote.flag.FLAG_ELITE_MAP,self._totalIndex)
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		-- remote.flag:set(remote.flag.FLAG_WELFARE_MAP,self._totalIndex)
	end
end

--烟花
function QUIDialogSocietyMap:showPassEffect(index, callback)
	index = index % self._totalNodeCount
	if index == 0 then
		index = self._totalNodeCount
	end
	local node = self._ccbOwner["node"..index]
	if node ~= nil then
		if self._passEffect == nil then
			self._passEffect = QUIWidgetAnimationPlayer.new()
			self._ccbOwner.node_fight:addChild(self._passEffect)
			self._passEffect:setPosition(ccp(node:getPositionX()-40, node:getPositionY()+80))
			self._passEffect:playAnimation("effects/fireworks.ccbi",nil,callback)
    		app.sound:playSound("map_fireworks")
		end
	end
end

--小点
function QUIDialogSocietyMap:showStep(index, isDelay, callback)
	index = index % self._totalNodeCount
	if index == 0 then
		index = self._totalNodeCount
	end
	local dotNode = self._ccbOwner["dot"..index]
	if dotNode == nil then
		-- nzhang: http://jira.joybest.com.cn/browse/WOW-11425
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

function QUIDialogSocietyMap:hideStep(index)
	local dotNode = self._ccbOwner["dot"..index]
	dotNode:setVisible(false)
end

function QUIDialogSocietyMap:showBattleEffect()
	if self._battleEffect == nil then
		local posX,posY = self:getNodePositionXByIndex(self._totalIndex)
		self._battleEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_fight:addChild(self._battleEffect)
		self._battleEffect:setPosition(ccp(posX, posY + 60))
		self._battleEffect:playAnimation("effects/battle_ing.ccbi",nil,nil,false)
	end
	self._isAnimation = false
end

function QUIDialogSocietyMap:selectMap(index)
	remote.union:unionGetBossListRequest(function ( response )
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeon", options = {chapter =index}})				
	end, function ( response )
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeon", options = {chapter =index}})				
		app.tip:floatTip("无法获取实时BOSS信息，请检查下当前网络是否稳定。")
	end)
	
end

function QUIDialogSocietyMap:madeTouchLayer()
	self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = self._size.width
	self._pageHeight = self._size.height
	self._mapContent = self._ccbOwner.node_map
    CalculateBattleUIPosition(self._ccbOwner.node_offside , true)

	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer,self._size.width,self._size.height,-self._size.width/2,-self._size.height/2, handler(self, self.onTouchEvent))
end

function QUIDialogSocietyMap:onTouchEvent(event)
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

function QUIDialogSocietyMap:_removeAction()
	if self._actionHandler ~= nil then
		self._mapContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogSocietyMap:moveTo(posX, isAnimation, isCheck)
	-- print("[Kumo] QUIDialogSocietyMap:moveTo()", posX, isAnimation, isCheck)
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

function QUIDialogSocietyMap:_contentRunAction(posX,posY)
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
function QUIDialogSocietyMap:_startOnEnterFrame()
	self:_stopOnEnterFrame()
	self._enterFrameHandler = scheduler.scheduleGlobal(function ()
		self:_onMoveHandler()
	end,0)
end

function QUIDialogSocietyMap:_stopOnEnterFrame()
	if self._enterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._enterFrameHandler)
		self._enterFrameHandler = nil
	end
end

function QUIDialogSocietyMap:_onMoveHandler(isForce)
	local posX = self._mapContent:getPositionX()
	local offsetCell = math.ceil(posX/self._cellWidth)
	-- print("[Kumo] QUIDialogSocietyMap:_onMoveHandler() 0", posX, self._cellWidth, self._offsetCell, offsetCell, isForce )
	if self._offsetCell == offsetCell and isForce ~= true then return end
	self._offsetCell = offsetCell
	local startCell = self._offsetCell%self._gapNum
	startCell = self._gapNum - startCell
	for i = 1, self._gapNum do
		local cells = self._moveCell[startCell]
		if cells ~= nil then
			for _,node in ipairs(cells) do
				node:setPositionX((i - 2 - self._offsetCell) * self._cellWidth + node._cellPosX)
			end
		end
		startCell = startCell + 1
		if startCell > self._gapNum then
			startCell = 1
		end
	end

	--计算起始的node节点
	local totalIndex = self._totalNodeCount
	local offsetIndex = -math.ceil((offsetCell+1)/self._gapNum) --此处加1为了让cell从第二格子计算(默认第一个格子会是最后一个cell块，则会造成从第20个开始计算)
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
	if startIndex ~= self._preStarIndex then  
		self._isRefresh = true
		self._preStarIndex = startIndex 
	end

	-- print("[Kumo] QUIDialogSocietyMap:_onMoveHandler() 1", startIndex, self._isRefresh)
	-- QPrintTable(self._moveNode)
	for index,node in ipairs(self._moveNode) do
		local renderIndex = index
		if index < startIndex then
			renderIndex = ((offsetIndex + 1) * totalIndex) + index
		else
			renderIndex = (offsetIndex * totalIndex) + index
		end
		-- print("[Kumo] QUIDialogSocietyMap:_onMoveHandler() 2", renderIndex)
		self:hideStep(index)
		if renderIndex > 0 then
			self._renderFun(renderIndex, node, index)
		end
	end
	self._isRefresh = false
end

function QUIDialogSocietyMap:_onTriggerClick(event, target)
	if q.buttonEventShadow(event, target) == false then return end
	if self._isMove == true then return end
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
    local config = QStaticDatabase.sharedDatabase():getAllScoietyChapter()
    local count = 0
	for k,v in pairs(config) do
    	count = count + 1
    end
	local index = 1
	while true do
		local btn = nil
		if self._instanceType == DUNGEON_TYPE.NORMAL then
			btn = self._ccbOwner["btn"..index.."_normal"]
		elseif self._instanceType == DUNGEON_TYPE.ELITE then
			-- btn = self._ccbOwner["btn"..index.."_elite"]
		elseif self._instanceType == DUNGEON_TYPE.WELFARE then
			-- btn = self._ccbOwner["btn"..index.."_welfare"]

			-- 如果福利副本第一章不可以攻打，则弹出提示
			-- if index == 1 and remote.instance:checkIsPassByDungeonId("wailing_caverns_3_elite") == false then
			-- 	app.tip:floatTip("魂师大人，通关哀嚎洞穴上才能开启史诗副本哟~继续加油哦！")
			-- end
		else
			btn = self._ccbOwner["btn"..index.."_normal"]
		end
		if index <= self._totalIndex and btn ~= nil then
			if btn == target then
				local renderIndex = self._ccbOwner["node"..index].renderIndex
				if renderIndex ~= nil then
					local minChapter = remote.union:getMinChapter()
					if renderIndex < minChapter then
						app.tip:floatTip("该章节已通关")
					else
						self:selectMap(renderIndex)
					end
				end
				break
			end
		elseif index == self._nextIndex and btn ~= nil then
			if btn == target then
				local tbl = remote.union:getSocietyDataByChapter(self._nextIndex)
				if nil ~= tbl and #tbl > 0 then
					local preTbl = remote.union:getSocietyDataByChapter(self._nextIndex - 1)
					if preTbl then
					    local text = "通关" .. preTbl[1].chapter_name .. "章节后开启"
						app.tip:floatTip(text)
					end
				end
				if index > count then
					app.tip:floatTip("章节暂未开放")
				end
				break
			end
		else
			if index > count then
				app.tip:floatTip("章节暂未开放")
			end
			break
		end
		index = index + 1
	end
end

function QUIDialogSocietyMap:_onTriggerClickRank()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "union", initChildRank = 3}}, {isPopCurrentDialog = false})
end

-- function QUIDialogSocietyMap:userUpdateHandler(event)
-- 	self:_checkEliteIsOpen()
-- 	self:_checkWelfareIsOpen()
-- end

-- function QUIDialogSocietyMap:_checkEliteIsOpen()
-- 	local isUnlock = app.unlock:getUnlockElite()

-- 	--[[
-- 		没有开启的时候，按钮还是要相应点击事件，然后弹出多少级开启的tips —— by Kumo wow-13410
-- 	]]
-- 	if isUnlock then
-- 		self._ccbOwner.btn_elite:setEnabled(isUnlock)
-- 		makeNodeFromGrayToNormal(self._ccbOwner.btn_elite)
-- 	else
-- 		makeNodeFromNormalToGray(self._ccbOwner.btn_elite)
-- 	end

-- 	self:_checkEliteTutorial()
-- end

-- function QUIDialogSocietyMap:_checkWelfareIsOpen()
-- 	local isUnlock = app.unlock:getUnlockWelfare()

-- 	--[[
-- 		没有开启的时候，按钮还是要相应点击事件，然后弹出多少级开启的tips —— by Kumo wow-13410
-- 	]]
-- 	if isUnlock then
-- 		self._ccbOwner.btn_welfare:setEnabled(isUnlock)
-- 		makeNodeFromGrayToNormal(self._ccbOwner.btn_welfare)
-- 	else
-- 		makeNodeFromNormalToGray(self._ccbOwner.btn_welfare)
-- 	end
	
-- 	self:_checkWelfareTutorial()
-- end

-- function QUIDialogSocietyMap:_checkEliteTutorial()
-- 	if app.tip:isUnlockTutorialFinished() == false then
-- 	    local unlockTutorial = app.tip:getUnlockTutorial()
-- 	    if unlockTutorial.elites == app.tip.UNLOCK_TUTORIAL_OPEN then
-- 			if self.eliteHandTouch == nil then
-- 				self.eliteHandTouch = app.tip:createUnlockTutorialTip("elites", self)
-- 			end
-- 	    end
-- 	end
-- end

-- function QUIDialogSocietyMap:_checkWelfareTutorial()
-- 	if app.tip:isUnlockTutorialFinished() == false then
-- 	    local unlockTutorial = app.tip:getUnlockTutorial()
-- 	    if unlockTutorial.welfare == app.tip.UNLOCK_TUTORIAL_OPEN then
-- 	    	-- self._ccbOwner.welfare_light:setVisible(true)
-- 	    	if self.welfareHandTouch == nil then
-- 				self.welfareHandTouch = app.tip:createUnlockTutorialTip("welfare", self)
-- 			end
-- 	    end
-- 	end
-- end

--关闭解锁引导
-- function QUIDialogSocietyMap:_closeUnlockTutorial(data)
-- 	if data.type == "elites" then
-- 		if self.eliteHandTouch ~= nil then
-- 			self.eliteHandTouch:removeFromParent()
-- 			self.eliteHandTouch = nil
-- 			self:_onTriggerElite()
-- 		end
-- 	elseif data.type == "welfare" then
-- 		if self.welfareHandTouch ~= nil then
-- 			self.welfareHandTouch:removeFromParent()
-- 			self.welfareHandTouch = nil
-- 			self:_onTriggerWelfare()
-- 		end
-- 	end
-- end

-- function QUIDialogSocietyMap:_onTriggerNormal() 
--     app.sound:playSound("battle_change")
-- 	if self._isMove == true then return end
-- 	self:selectType(DUNGEON_TYPE.NORMAL)
-- end

-- function QUIDialogSocietyMap:_onTriggerElite()
--     app.sound:playSound("battle_change")
-- 	if self._isMove == true then return end
-- 	if app.unlock:getUnlockElite(true) == false then
-- 		-- local config = QStaticDatabase.sharedDatabase:getUnlock()
-- 		-- local level = config["UNLOCK_ELITE"].team_level
-- 		-- app.tip:floatTip("战队等级"..level.."级开启")
-- 		return
-- 	end
-- 	local instanceInfos = remote.instance:getInstancesByIndex(1, DUNGEON_TYPE.ELITE)

-- 	if instanceInfos[1].isLock == false then
-- 		local needLevel = instanceInfos[1].unlock_team_level or 0
-- 		if app.unlock:checkLevelUnlock(needLevel) == false then
-- 	 		app.unlock:tipsLevel(needLevel)
-- 			return
-- 		end
-- 		if instanceInfos[1].unlock_dungeon_id ~= nil then
-- 			local needDungeonIds = string.split(instanceInfos[1].unlock_dungeon_id, ",")
-- 			for _,id in ipairs(needDungeonIds) do
-- 			 	if id ~= nil and app.unlock:checkDungeonUnlock(id) == false then
-- 			 		app.unlock:tipsDungeon(id)
-- 					return
-- 			 	end
-- 			 end
-- 		 end
-- 		return
-- 	end

-- 	self:selectType(DUNGEON_TYPE.ELITE)
-- end

-- function QUIDialogSocietyMap:_onTriggerWelfare()
--     app.sound:playSound("battle_change")
-- 	if self._isMove == true then return end
-- 	if app.unlock:getUnlockWelfare(true) == false then
-- 		-- local config = QStaticDatabase.sharedDatabase:getUnlock()
-- 		-- local level = config["UNLOCK_FULIFUBEN_TRIAL"].team_level
-- 		-- app.tip:floatTip("战队等级"..level.."级开启")
-- 		return
-- 	end
	
-- 	if app.tip:isUnlockTutorialFinished() == false then
-- 	    local unlockTutorial = app.tip:getUnlockTutorial()
-- 	    if unlockTutorial.welfare == app.tip.UNLOCK_TUTORIAL_OPEN then
-- 	    	self._ccbOwner.welfare_light:setVisible(false)
-- 	    	unlockTutorial.welfare = 2
--   			app.tip:setUnlockTutorial(unlockTutorial)
-- 	    end
-- 	end
-- 	self:selectType(DUNGEON_TYPE.WELFARE)
-- end

function QUIDialogSocietyMap:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogSocietyMap:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogSocietyMap:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyMap:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

-- {
    -- sec: 40
    -- min: 27
    -- day: 28
    -- isdst: false
    -- wday: 7
    -- yday: 149
    -- year: 2016
    -- month: 5
    -- hour: 16
-- }
function QUIDialogSocietyMap:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local h,m,s = 0,0,0
	local timeStr = ""
	m = 59 - curTimeTbl.min
	s = 60 - curTimeTbl.sec
	-----------------------------------------------------------------------------
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	local count = remote.union:getSocietyCount()
	local cd = remote.union:getSocietyCD()

	if curTimeTbl.hour == startTime and curTimeTbl.min == 0 and curTimeTbl.sec == 0 then
		self._fightCounts = count
		local userConsortia = remote.user:getPropForKey("userConsortia")
		userConsortia.consortia_boss_fight_count = self._fightCounts
		self._ccbOwner.tf_count:setString( self._fightCounts )
	elseif (curTimeTbl.hour == startTime + cd and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 2 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 3 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 4 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 5 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 6 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) then
		if curTimeTbl.hour < endTime then
			self._fightCounts = self._fightCounts + 1
			local userConsortia = remote.user:getPropForKey("userConsortia")
			userConsortia.consortia_boss_fight_count = self._fightCounts
			self._ccbOwner.tf_count:setString( self._fightCounts )
		end
	end
	if curTimeTbl.hour < startTime or curTimeTbl.hour >= endTime then
		self._fightCounts = 0
		local userConsortia = remote.user:getPropForKey("userConsortia")
		userConsortia.consortia_boss_fight_count = self._fightCounts
		self._ccbOwner.tf_count:setString( self._fightCounts )
	end
	if curTimeTbl.hour >= startTime and curTimeTbl.hour < startTime + cd then
		h = startTime + cd - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd and curTimeTbl.hour < startTime + cd * 2 then
		h = startTime + cd * 2 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 2 and curTimeTbl.hour < startTime + cd * 3 then
		h = startTime + cd * 3 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 3 and curTimeTbl.hour < startTime + cd * 4 then
		h = startTime + cd * 4 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 4 and curTimeTbl.hour < startTime + cd * 5 then
		h = startTime + cd * 5 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 5 and curTimeTbl.hour < startTime + cd * 6 then
		h = startTime + cd * 6 - 1 - curTimeTbl.hour
	else
		h = -1
	end
	if h >= 0 then
		-- self._ccbOwner.node_time:setVisible(true)
		self._ccbOwner.node_time:setVisible(false)
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
		self._ccbOwner.tf_time:setString(timeStr.."后")
	else
		self._ccbOwner.node_time:setVisible(false)
		self._ccbOwner.tf_time:setString("")
	end
	-----------------------------------------------------------------------------
	if curTimeTbl.hour > 4 then
		h = 24 - curTimeTbl.hour + 4
	else
		h = 4 - curTimeTbl.hour
	end
	-- m = 59 - curTimeTbl.min
	-- s = 60 - curTimeTbl.sec
	timeStr = string.format("%02d:%02d:%02d", h, m, s)
	-- print("===============")
	-- print(string.format("%02d:%02d:%02d", curTimeTbl.hour, curTimeTbl.min, curTimeTbl.sec))
	-- print(timeStr)
	-- print("===============")
	local consortia  = remote.union.consortia
	local maxChapter = consortia.max_chapter
	local mapID = 0
	-- // 宗门更新每日刷新类型 1为最远关卡 2为最远关卡前一关卡
	if consortia.bossResetType == 1 then
		mapID = maxChapter
	else
		-- 这里不考虑"maxChapter == 1"的情况，这个放在重置选择界面里做规避。当maxChapter为1的时候，不让宗主选择第2种重置方式
		mapID = maxChapter - 1
	end
	self._ccbOwner.tf_reset_time:setString("")
	self._ccbOwner.tf_reset_info:setString("")
	-- local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(mapID)
	-- if not scoietyChapterConfig or #scoietyChapterConfig == 0 then return end
	-- self._ccbOwner.tf_reset_info:setString(timeStr.."后重置至"..scoietyChapterConfig[1].chapter_name)
	self._ccbOwner.tf_reset_time:setString(timeStr)
	self._ccbOwner.tf_reset_info:setString("后重置至第 "..mapID.." 章")
end

function QUIDialogSocietyMap:_updateMapInfo(renderIndex)
	local userConsortia = remote.user:getPropForKey("userConsortia")

	-- 刷新可挑战BOSS次数
	self._fightCounts = userConsortia.consortia_boss_fight_count
	self._ccbOwner.tf_count:setString( self._fightCounts )
    local buyCount = userConsortia.consortia_boss_buy_count or 0
	if userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_buy_at then
		buyCount = 0
	end
	local totalVIPNum = QVIPUtil:getCountByWordField("sociaty_chapter_times", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("sociaty_chapter_times")
	self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)

	-- 刷新副本的进度
	local cur = remote.union:getCurBossHpByChapter(self._chapter)
	local total = remote.union:getTotalBossHpByChapter(self._chapter)
	local sx = (total - cur) / total
	-- local sx = (total - cur) / total * self._initTotalHpScaleX
	-- print("[Kumo] 地图所有BOSS总血条 ", cur, total, sx, self._initTotalHpScaleX)
	-- self._ccbOwner.sp_progress:setScaleX( sx )
	self._stencil:setPositionX(-self._totalStencilWidth + sx * self._totalStencilWidth)
	self._ccbOwner.tf_progress:setString( math.floor(( (total - cur) / total )* 100) .."%" )
	-- self._ccbOwner.tf_progress:setString( string.format("%.2f", (curTotalBossHp / self._maxTotalBossHp)* 100) .."%" )
	-- self._ccbOwner.tf_progress:setString(curTotalBossHp.."/"..self._maxTotalBossHp)

	-- 刷新通关奖励小红点
	if remote.union:checkSocietyDungeonAwardRedTips() then
		self._ccbOwner.award_tips:setVisible(true)
	else
		self._ccbOwner.award_tips:setVisible(false)
	end

	-- 刷新宝箱奖励小红点 
	if self._isRefresh then
		local minChapter = remote.union:getMinChapter()
		-- print("[Kumo] ", minChapter, self._chapter)
		for i = minChapter, self._chapter, 1 do
			if not renderIndex or renderIndex == i then
				local index = i
				if index > self._totalNodeCount then
					index = index % self._totalNodeCount
					if index == 0 then index = self._totalNodeCount end
				end
				if i == self._chapter then
					if remote.union:checkSocietyDungeonRedTips() or remote.union:checkSocietyDungeonChestRedTips(i) then
						self._ccbOwner["dungeon_tips_" .. index]:setVisible(true) 
					else
						self._ccbOwner["dungeon_tips_" .. index]:setVisible(false) 
					end
				else
					if remote.union:checkSocietyDungeonChestRedTips(i) then
						self._ccbOwner["dungeon_tips_" .. index]:setVisible(true) 
					else
						self._ccbOwner["dungeon_tips_" .. index]:setVisible(false) 
					end
				end
			end
		end
	end

	if remote.union:checkUnionShopRedTips() then
        self._ccbOwner.shop_tips:setVisible(true)
    else
    	self._ccbOwner.shop_tips:setVisible(false)
    end
end

function QUIDialogSocietyMap:_updateCapterProgress( chapter )
	-- print("[Kumo] QUIDialogSocietyMap:_updateCapterProgress( chapter )", chapter)
	local minChapter = remote.union:getMinChapter()
	local fightChapter = self._chapter
	if chapter then
		local index = chapter
		if index > self._totalNodeCount then
			index = index % self._totalNodeCount
			if index == 0 then index = self._totalNodeCount end
		end
		if chapter >= minChapter then
			if self._isRefresh then
				if fightChapter - chapter <= 1 then
					self._ccbOwner["node_progressStrip"..index]:removeAllChildren()
					local node = QUIWidgetInstanceProgress.new()
					self._ccbOwner["node_progressStrip"..index]:addChild(node)
					self._ccbOwner["node_progressStrip"..index]:setVisible(true)
					local cur = remote.union:getCurBossHpByChapter(chapter)
					local total = remote.union:getTotalBossHpByChapter(chapter)
					node:updateProgress(total - cur, total, true)
				else
					self._ccbOwner["node_progressStrip"..index]:removeAllChildren()
					local node = QUIWidgetInstanceProgress.new()
					node:updateProgress(1, 1, true)
					self._ccbOwner["node_progressStrip"..index]:addChild(node)
					self._ccbOwner["node_progressStrip"..index]:setVisible(true)
				end
			end
		else
			self._ccbOwner["node_progressStrip"..index]:removeAllChildren()
			self._ccbOwner["node_progressStrip"..index]:setVisible(false)
		end
	else
		for i = minChapter, fightChapter, 1 do
			local index = i
			if index > self._totalNodeCount then
				index = index % self._totalNodeCount
				if index == 0 then index = self._totalNodeCount end
			end
			if fightChapter - i <= 1 then
				self._ccbOwner["node_progressStrip"..index]:removeAllChildren()
				local node = QUIWidgetInstanceProgress.new()
				self._ccbOwner["node_progressStrip"..index]:addChild(node)
				self._ccbOwner["node_progressStrip"..index]:setVisible(true)
				local cur = remote.union:getCurBossHpByChapter(i)
				local total = remote.union:getTotalBossHpByChapter(i)
				node:updateProgress(total - cur, total, true)
			else
				self._ccbOwner["node_progressStrip"..index]:removeAllChildren()
				local node = QUIWidgetInstanceProgress.new()
				node:updateProgress(1, 1, true)
				self._ccbOwner["node_progressStrip"..index]:addChild(node)
				self._ccbOwner["node_progressStrip"..index]:setVisible(true)
			end
		end
	end
end

return QUIDialogSocietyMap