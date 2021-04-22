local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceNightmare = class("QUIWidgetInstanceNightmare", QUIWidget)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetInstanceNightmareBuild = import("..widgets.QUIWidgetInstanceNightmareBuild")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetInstanceNightmare:ctor(options)
	local ccbFile = "ccb/Widget_Instance_city_em.ccbi"
	local callbacks = {
		{ccbCallbackName = "onTriggerBadge", callback = handler(self, self._onTriggerBadge)},
	}
	QUIWidgetInstanceNightmare.super.ctor(self, ccbFile, callbacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._stepSchedulers = {}
	self._badgeConfigs = {}
	local configs= QStaticDatabase:sharedDatabase():getBadge()
	for _,value in pairs(configs) do
		table.insert(self._badgeConfigs, value)
	end
	table.sort(self._badgeConfigs, function (a,b)
		return a.number < b.number
	end)
	
	self._nodes = {}
	local index = 1
	while true do
		local node = self._ccbOwner["node"..index]
		if node ~= nil then
			table.insert(self._nodes, node)
			self:resetNode(node, index)
			index = index + 1
		else
			break
		end
	end
	self._totalNodeCount = index

	self.parent = options.parent

	local nodeUI = self._ccbOwner.node_ui
	nodeUI:retain()
	nodeUI:removeFromParent()
	self.parent:getView():addChild(nodeUI)
	nodeUI:release()
	nodeUI:setPosition(ccp(-display.width/2 + 40, display.height/2 - 150))

	self.parent:getView():addChild(QUIWidget.new("ccb/effects/emeng_changjing_fx.ccbi"))

	local count = (remote.user.nightmareDungeonPassCount or 0)
	local totalCount = 0
	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(count)
	local nextConfig = nil
	if config ~= nil then
		for index,value in ipairs(self._badgeConfigs) do
			if nextConfig ~= nil then
				nextConfig = value
				break
			end
			if value.number == config.number then
				nextConfig = value
			end
		end
	else
		nextConfig = self._badgeConfigs[1]
	end
	totalCount = nextConfig.number
	self._ccbOwner.tf_progress:setString(count.."/"..totalCount)
	self._ccbOwner.node_bar:setScaleX(count/totalCount)
	self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(nextConfig.alphaicon))
	self._ccbOwner.tf_badge_name:setString("下级（"..nextConfig.badge_name.."）：")
	self._ccbOwner.tf_prop1:setString("＋"..nextConfig.attack_value)
	self._ccbOwner.tf_prop2:setString("＋"..nextConfig.hp_value)
	self._ccbOwner.tf_prop3:setString("＋"..nextConfig.armor_physical)
	self._ccbOwner.tf_prop4:setString("＋"..nextConfig.armor_magic)
end

function QUIWidgetInstanceNightmare:onExit()
	QUIWidgetInstanceNightmare.super.onExit(self)
	self:removeAllEventListeners()

    if self._stepSchedulers ~= nil then
    	for _,handler in pairs(self._stepSchedulers) do
    		scheduler.unscheduleGlobal(handler)
    	end
    end
	if self._moveEffectSchduler ~= nil then
		scheduler.unscheduleGlobal(self._moveEffectSchduler)
		self._moveEffectSchduler = nil
	end
end

function QUIWidgetInstanceNightmare:getNode()
	return self._nodes
end

function QUIWidgetInstanceNightmare:initPage()
	self:resetAll()
	self.dungeonConfigs,self._totalIndex = remote.nightmare:getNightmareMaps()
	-- self._totalIndex = #self.dungeonConfigs
	return self._totalIndex
end

function QUIWidgetInstanceNightmare:getFlagEffect(callback)
	self._callback = callback
	remote.flag:get({remote.flag.FLAG_NIGHTMARE_MAP}, handler(self, self.mapMoveEffect))
end

function QUIWidgetInstanceNightmare:mapMoveEffect(tbl)
	if self._moveEffectSchduler ~= nil then
		scheduler.unscheduleGlobal(self._moveEffectSchduler)
		self._moveEffectSchduler = nil
	end

	local effectIndex = tonumber(tbl[remote.flag.FLAG_NIGHTMARE_MAP]) or 0
	self._preIndex = self._totalIndex
	if effectIndex ~= nil and effectIndex > 0 and self._preIndex > 1 and effectIndex ~= self._preIndex then
		self._preIndex = self._preIndex - 1
		local nextFun = function ()
			self:showStep(self._preIndex, true, function ()
				self:showBattleEffect()
				self:checkNightmareUnlock(tbl)
			end)
			self._preIndex = self._totalIndex
			if self._callback ~= nil then
				self._callback()
			end
		end
		self._moveEffectSchduler = scheduler.performWithDelayGlobal(function ()
			self._moveEffectSchduler = nil
			nextFun()
			-- self:showPassEffect(self._preIndex, nextFun)
		end,0)
	else
		self._moveEffectSchduler = scheduler.performWithDelayGlobal(function ()
			self._moveEffectSchduler = nil
			self:showBattleEffect() 
			self:checkNightmareUnlock(tbl)
		end,0)
		if self._callback ~= nil then
			self._callback()
		end
	end
end

-- 检查是否有噩梦本开启
function QUIWidgetInstanceNightmare:checkNightmareUnlock(tbl)
	local nightmareIndex = tonumber(tbl[remote.flag.FLAG_NIGHTMARE_MAP])
	nightmareIndex = nightmareIndex or 0
	if nightmareIndex ~= self._totalIndex then
		local index = self._totalIndex % self._totalNodeCount
		if index == 0 then
			index = self._totalNodeCount
		end
		self:showNightmare(index, self._totalIndex, true)
		remote.flag:set(remote.flag.FLAG_NIGHTMARE_MAP,self._totalIndex)
	end
end

--显示噩梦本关卡
function QUIWidgetInstanceNightmare:showNightmare(index, renderIndex, isAnimation)
	local nightmareId = self.dungeonConfigs[renderIndex]
	if nightmareId ~= nil then
		local mapWidget = QUIWidgetInstanceNightmareBuild.new()
		-- --侦听事件用来改变选中的位置
		mapWidget:addEventListener(QUIWidgetInstanceNightmareBuild.EVENT_SELECT_INDEX, function (event)
    		self:dispatchEvent(event)	
		end)
		self._ccbOwner["build"..index]:removeAllChildren()
		self._ccbOwner["build"..index]:addChild(mapWidget)
		mapWidget:setNightmareId(nightmareId, renderIndex)
		if isAnimation == true then
			mapWidget:playAppear()
		end
	end
end

function QUIWidgetInstanceNightmare:showStep(index, isDelay, callback)
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

function QUIWidgetInstanceNightmare:hideStep(index)
	local dotNode = self._ccbOwner["dot"..index]
	dotNode:setVisible(false)
end

function QUIWidgetInstanceNightmare:showBattleEffect()
	if self._callback ~= nil then
		self._callback()
		self._callback = nil
	end
end

function QUIWidgetInstanceNightmare:resetAll()
end

function QUIWidgetInstanceNightmare:resetNode(node, index)
	
end

function QUIWidgetInstanceNightmare:render(renderIndex, node, index)
	self:resetNode(node, index)
	print(renderIndex, self._totalIndex, self._preIndex)
	if renderIndex < self._totalIndex and renderIndex > 0 then
		if renderIndex ~= self._preIndex then
			self:showStep(index, false)
		end
		self:showNightmare(index, renderIndex, false)
	elseif renderIndex == self._totalIndex then
		remote.flag:get({remote.flag.FLAG_NIGHTMARE_MAP}, function (tbl)
			local nightmareIndex = tonumber(tbl[remote.flag.FLAG_NIGHTMARE_MAP])
			if nightmareIndex == self._totalIndex then
				self:showNightmare(index, renderIndex, false)
			end
		end)
	elseif renderIndex > self._totalIndex then
		self:showNightmare(index, renderIndex, false)
	end
end

function QUIWidgetInstanceNightmare:_onTriggerBadge()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNightmareBadgeList"})
end

return QUIWidgetInstanceNightmare