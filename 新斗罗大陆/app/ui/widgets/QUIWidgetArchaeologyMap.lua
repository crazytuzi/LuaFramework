--
-- Author: Kumo
-- Date: Thu Mar  3 14:51:12 2016
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetArchaeologyMap = class("QUIWidgetArchaeologyMap", QUIWidget)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")

QUIWidgetArchaeologyMap.EVENT_ENABLE_COMPLETE = "EVENT_ENABLE_COMPLETE"
QUIWidgetArchaeologyMap.EVENT_SHOW_CHOOSE = "EVENT_SHOW_CHOOSE"

QUIWidgetArchaeologyMap.BALL_LEVEL = 1
QUIWidgetArchaeologyMap.FRAGMENT_LEVEL = 2
QUIWidgetArchaeologyMap.FRAGMENT_PIAO_LEVEL = 3
QUIWidgetArchaeologyMap.LIGHT_LEVEL = 4
QUIWidgetArchaeologyMap.ENABLE_LEVEL = 5
QUIWidgetArchaeologyMap.NEED_ENABLE_LEVEL = 6

function QUIWidgetArchaeologyMap:ctor(options)
	self:_prepareMapInfo(options.mapID)
	local ccbFile = "ccb/Widget_ArchaeologyMap.ccbi"
	local callBacks = {}

	QUIWidgetArchaeologyMap.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetArchaeologyMap:_prepareMapInfo( mapID )
	self._mapInfo = remote.archaeology:getMapInfoByID(mapID)
	self._fragmentAniManagers = {}
	self._fragmentAniCcbOwners = {}
	self._fragmentAniCcbViews = {}
	self._flagAniManagers = {}
	self._flagAniCcbOwners = {}
	self._flagAniCcbViews = {}
	self._needEnableEffectManager = nil
	self._needEnableEffectAniCcbView = nil
	self._nameAni = "Default Timeline"
	self._isFlagsOpened = {}
	self._flagIsAnimation = false
end

function QUIWidgetArchaeologyMap:onEnter()
	local count = #self._mapInfo
	local lastID = remote.archaeology:getLastEnableFragmentID()
	local index = remote.archaeology:getLastEnableIndexByID(lastID, self._mapInfo[1].map_id)
	local boo = false

	for i = 1, count, 1 do
		if index then
			boo = i <= index
		end

		self:_updateLine(i, true) --策划要求连线始终常亮
		self:_showBall(i, boo)
		self:_showFragmentIcon(i, boo)
		self:_showLight(i)
	end

	self:_showRedFlagText()
	self:_showNeedEnableEffect()
end

function QUIWidgetArchaeologyMap:onExit()
	for _, manager in pairs(self._fragmentAniManagers) do
		manager:stopAnimation()
		manager = nil
	end
	self._fragmentAniManagers = {}

	for _, owner in pairs(self._fragmentAniCcbOwners) do
		owner = nil
	end
	self._fragmentAniCcbOwners = {}

	for _, view in pairs(self._fragmentAniCcbViews) do
		view:removeFromParent()
		view = nil
	end
	self._fragmentAniCcbViews = {}

	if self._needEnableEffectManager then
		self._needEnableEffectManager:stopAnimation()
		self._needEnableEffectManager = nil
	end
	if self._needEnableEffectAniCcbView then
		self._needEnableEffectAniCcbView:removeFromParent()
		self._needEnableEffectAniCcbView = nil
	end

	for _, manager in pairs(self._flagAniManagers) do
		manager:stopAnimation()
		manager = nil
	end
	self._flagAniManagers = {}

	for _, owner in pairs(self._flagAniCcbOwners) do
		owner = nil
	end
	self._flagAniCcbOwners = {}

	for _, view in pairs(self._flagAniCcbViews) do
		view:removeFromParent()
		view = nil
	end
	self._flagAniCcbViews = {}
end

function QUIWidgetArchaeologyMap:enableFragmentByID()
	local lastID = remote.archaeology:getLastEnableFragmentID()
	local index = remote.archaeology:getLastEnableIndexByID(lastID)
	local pos, ccbFile = remote.archaeology:getEnableURL()
	local effectShow = QUIWidgetAnimationPlayer.new()
	local level = QUIWidgetArchaeologyMap.ENABLE_LEVEL
	effectShow:setPosition(ccp(pos.x, pos.y))
	self._ccbOwner["node_"..index]:addChild(effectShow, level, level)
		
	local effectFun = function()
		effectShow:playAnimation(ccbFile, nil, function()
				self:_updateBall(index, true)
				self:_updateLine(index, true)
				self:_initFragmentAni( index )
				self:_updateNeedEnableEffect()
				self:dispatchEvent( {name = QUIWidgetArchaeologyMap.EVENT_ENABLE_COMPLETE} )
			end)
	end

	effectFun()
end

function QUIWidgetArchaeologyMap:clickFragmentByIndex( int )
	if self._flagIsAnimation then return end

	for i = 1, 4, 1 do
		if self._isFlagsOpened[i] and i ~= int then
			self:_showBuffFlag(i)
			break
		end
	end

	local info = self._mapInfo[int]
	if info.describle_a then
		local isChoosed = remote.archaeology:isMarked(info.id)
		if not isChoosed then
			self:dispatchEvent( {name = QUIWidgetArchaeologyMap.EVENT_SHOW_CHOOSE, fragmentID = info.id} )
		end
	else
		if int == #self._mapInfo then 
			self._archaeologyCardChoose = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogArchaeologyTips", 
				options = {config = self._mapInfo[int]}}, {isPopCurrentDialog = false} )
			return 
		end

		self:_showBuffFlag(int)
	end
end

function QUIWidgetArchaeologyMap:updateRedFlagInfo()
	self:_showRedFlagText()
end

function QUIWidgetArchaeologyMap:_showBuffFlag( int )
	local info = self._mapInfo[int]
	local pos, ccbFile = remote.archaeology:getFlagURL()
	local str = ""

	if not self._isFlagsOpened[int] then
		self._isFlagsOpened[int] = false
		str = "open"
	else
		if self._isFlagsOpened[int] then
			str = "close"
		else
			str = "open"
		end
	end
	self._flagIsAnimation = true
    self._isFlagsOpened[int] = not self._isFlagsOpened[int]

	if not self._flagAniManagers[int] then
		local proxy = CCBProxy:create()
		self._flagAniCcbOwners[int] = {}
		self._flagAniCcbViews[int] = CCBuilderReaderLoad(ccbFile, proxy, self._flagAniCcbOwners[int])
		self._flagAniCcbViews[int]:setPosition(ccp(pos.x, pos.y))

		local tbl = remote.archaeology:getFragmentBuffNameAndValueByID(info.id)
		for name, value in pairs(tbl) do
			-- if not self._flagAniCcbOwners[int].tf_buffName_shadow then
			-- 	self._flagAniCcbOwners[int].tf_buffName_shadow = setShadow5(self._flagAniCcbOwners[int].tf_buffName)
			-- end
			-- if not self._flagAniCcbOwners[int].tf_buffValue_shadow then
			-- 	self._flagAniCcbOwners[int].tf_buffValue_shadow = setShadow5(self._flagAniCcbOwners[int].tf_buffValue)
			-- end
			self._flagAniCcbOwners[int].tf_buffName:setString(name)
			self._flagAniCcbOwners[int].tf_buffValue:setString("+"..value)
		end

	    self._flagAniManagers[int] = tolua.cast(self._flagAniCcbViews[int]:getUserObject(), "CCBAnimationManager")

	    self._flagAniManagers[int]:connectScriptHandler(function(str)
	        self._flagIsAnimation = false
	    end)

	    self._ccbOwner["node_"..int]:addChild(self._flagAniCcbViews[int], -1)
	end

	self._flagAniManagers[int]:stopAnimation()
	self._flagAniManagers[int]:runAnimationsForSequenceNamed(str or self._nameAni)	
end

function QUIWidgetArchaeologyMap:_updateLine( int, boo )
	if self._ccbOwner["line"..int] then
		self._ccbOwner["line"..int]:setVisible( boo )
	end
end

function QUIWidgetArchaeologyMap:_showBall( int, boo )
	self:_updateBall( int, boo )
end

function QUIWidgetArchaeologyMap:_updateBall( int, boo )
	local _, url = remote.archaeology:getBallURL( self._mapInfo[int].ball_color, boo )
	local sprite = CCSprite:createWithSpriteFrame(QSpriteFrameByPath(url))
	local level = QUIWidgetArchaeologyMap.BALL_LEVEL
	if self._ccbOwner["node_"..int]:getChildByTag(level) then
		self._ccbOwner["node_"..int]:removeChildByTag(level)
	end
	self._ccbOwner["node_"..int]:addChild(sprite, level, level)
end

function QUIWidgetArchaeologyMap:_showFragmentIcon( int, boo )
	local url = self._mapInfo[int].fragment_icon
	local sprite = self:_getSprite( {url} )
	local scale = self._mapInfo[int].fragment_scale
	local rotation = self._mapInfo[int].fragment_icon_rotation
	sprite:setScale(scale)
	sprite:setRotation(rotation)
	makeNodeFromNormalToGray(sprite)
	local level = QUIWidgetArchaeologyMap.FRAGMENT_LEVEL
	self._ccbOwner["node_"..int]:addChild(sprite, level, level)
	if boo then
		self:_initFragmentAni( int )
	end
end

function QUIWidgetArchaeologyMap:_showLight( int )
	local pos, urls = remote.archaeology:getGaoliangURL()
	local sprite = CCSprite:createWithSpriteFrame(QSpriteFrameByPath(urls[1]))
	sprite:setPosition(ccp(pos.x, pos.y))
	local level = QUIWidgetArchaeologyMap.LIGHT_LEVEL
	self._ccbOwner["node_"..int]:addChild(sprite, level, level)
end

function QUIWidgetArchaeologyMap:_showNeedEnableEffect()
	self:_updateNeedEnableEffect()
end

function QUIWidgetArchaeologyMap:_updateNeedEnableEffect( str )
	local isAllEnable = remote.archaeology:isAllEnable()
	if isAllEnable then 
		if self._needEnableEffectManager then
			self._needEnableEffectManager:stopAnimation()
			self._needEnableEffectManager = nil
		end
		if self._needEnableEffectAniCcbView then
			self._needEnableEffectAniCcbView:removeFromParent()
			self._needEnableEffectAniCcbView = nil
		end
		return 
	end

	local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
	if self._mapInfo[1].map_id == lastNeedEnableMapID then
		local lastID = remote.archaeology:getLastEnableFragmentID()
		local index = 1
		if not lastID or lastID == 0 then
			index = 1
		else
			index = remote.archaeology:getLastEnableIndexByID(lastID + 1)
		end
		local level = QUIWidgetArchaeologyMap.NEED_ENABLE_LEVEL

		if self._needEnableEffectManager then
			self._needEnableEffectManager:stopAnimation()
			self._needEnableEffectManager = nil
		end
		if self._needEnableEffectAniCcbView then
			self._needEnableEffectAniCcbView:removeFromParent()
			self._needEnableEffectAniCcbView = nil
		end

		local pos, ccbFile = remote.archaeology:getNeedEnableURL()
		local proxy = CCBProxy:create()
		local aniCcbOwner = {}
		self._needEnableEffectAniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
		self._needEnableEffectAniCcbView:setPosition(ccp(pos.x, pos.y))

	    self._needEnableEffectManager = tolua.cast(self._needEnableEffectAniCcbView:getUserObject(), "CCBAnimationManager")
		self._needEnableEffectManager:runAnimationsForSequenceNamed(str or self._nameAni)

		if self._ccbOwner["node_"..index]:getChildByTag(level) then
			self._ccbOwner["node_"..index]:removeChildByTag(level)
		end

		self._ccbOwner["node_"..index]:addChild(self._needEnableEffectAniCcbView, level, level)
	end
end

function QUIWidgetArchaeologyMap:_initFragmentAni( int, str )
	local level1 = QUIWidgetArchaeologyMap.FRAGMENT_LEVEL
	local level2 = QUIWidgetArchaeologyMap.FRAGMENT_PIAO_LEVEL
	local url = self._mapInfo[int].fragment_icon
	local sprite = self:_getSprite( {url} )
	local scale = self._mapInfo[int].fragment_scale
	local rotation = self._mapInfo[int].fragment_icon_rotation
	sprite:setScale(scale)
	sprite:setRotation(rotation)
	local _, ccbFile = remote.archaeology:getPiaoURL()
	local proxy = CCBProxy:create()
	local aniCcbOwner = {}
	local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)

	self._ccbOwner["node_"..int]:removeChildByTag(level1)
	aniCcbOwner.node_icon:addChild(sprite)
	self._ccbOwner["node_"..int]:addChild(aniCcbView, level2, level2)

    local manager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
	manager:runAnimationsForSequenceNamed(str or self._nameAni)
	if int == 5 then
		manager:stopAnimation()
	end
	-- manager:runAnimationsForSequenceNamed(str or self._nameAni)
	table.insert(self._fragmentAniManagers, manager)
	table.insert(self._fragmentAniCcbOwners, aniCcbOwner )
	table.insert(self._fragmentAniCcbViews, aniCcbView )
end

function QUIWidgetArchaeologyMap:_showRedFlagText()
	local str = ""
	local index = 5
	local text = self._mapInfo[index].describle_a
	local fragmentID = self._mapInfo[index].id
	if text then
		local isChoosed = remote.archaeology:isMarked(fragmentID)
		if isChoosed then
			str = "\n已领取"
		else
			str = text
			str = string.gsub(str, "级", "级\n")
			str = string.gsub(str, "*", "\n*")
		end
	else
		local tbl = remote.archaeology:getFragmentBuffNameAndValueByID(fragmentID, self._mapInfo[index].map_id)
		for name, value in pairs(tbl) do
			if string.find(name, "加伤") then
				str = "主力PVP\n加伤\n+"..(value*100).."%"
				-- str = "\n玩家对战加伤\n+"..(value*100).."%"
				break
			elseif string.find(name, "减伤") then
				str = "主力PVP\n减伤\n+"..(value*100).."%"
				-- str = "\n玩家对战减伤\n+"..(value*100).."%"
				break
			end
		end

		if str == "" then
			str = str..name.."\n"..value.."\n"
		end
	end
	if not self._tf_goods_shadow then
		self._tf_goods_shadow = setShadow5(self._ccbOwner.tf_goods)
	end

	self._ccbOwner.tf_goods:setString( str )
end

-- function QUIWidgetArchaeologyMap:_initFragmentAni( node, boo, str )
-- 	if not node then return end

-- 	local manager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
-- 	if boo then
-- 		manager:runAnimationsForSequenceNamed(str or self._nameAni)
-- 	else
-- 		manager:stopAnimation()
-- 	end
-- 	table.insert(self._fragmentAniManagers, manager)
-- end

function QUIWidgetArchaeologyMap:_getSprite( tbl )
	local sprite = nil

	if #tbl == 1 then
	    local texture = CCTextureCache:sharedTextureCache():addImage(tbl[1])
	    sprite = CCSprite:createWithTexture( texture )
	elseif #tbl == 2 then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(tbl[1])
	    local spriteFrameName = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tbl[2])
	    sprite = CCSprite:createWithSpriteFrame(spriteFrameName)
	end
	
    return sprite
end

return QUIWidgetArchaeologyMap
