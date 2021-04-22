--
-- Author: Kumo
-- Date: Tue Mar  1 18:42:10 2016
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetArchaeologyTitle = class("QUIWidgetArchaeologyTitle", QUIWidget)

QUIWidgetArchaeologyTitle.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetArchaeologyTitle.EVENT_MOVE_STOP = "EVENT_MOVE_STOP"

function QUIWidgetArchaeologyTitle:ctor(options)
	local ccbFile = "ccb/Widget_Archaeology_title.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetArchaeologyTitle._onTriggerClick)}
	}

	QUIWidgetArchaeologyTitle.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetArchaeologyTitle:setMapID(mapID)
	self._mapID = mapID
	self:_showIcon()
end

function QUIWidgetArchaeologyTitle:_showIcon()
	local mapInfo = remote.archaeology:getMapInfoByID( self._mapID )
	local iconUrl = mapInfo[1].title_icon
	local iconTexture = CCTextureCache:sharedTextureCache():addImage(iconUrl)
    local icon = CCSprite:createWithTexture( iconTexture )
    icon:setPosition(0, 0)
    local scale = mapInfo[1].title_scale
    icon:setScale(scale)
    self._ccbOwner.node_icon:addChild(icon)

	local tbl = string.split(mapInfo[1].describle, "-")    
    self._ccbOwner.tf_name:setString(tbl[1])

    self:update()
	local currentMapID = remote.archaeology:getCurrentMapID()
	if currentMapID == self._mapID then
		self:select(true)
	else
		self:select(false)
	end
end

function QUIWidgetArchaeologyTitle:update()

	local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
	if self._mapID <= lastNeedEnableMapID then
		makeNodeFromGrayToNormal(self._ccbOwner.node_icon)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_icon)
	end
end

function QUIWidgetArchaeologyTitle:select(isSelect)
	if isSelect then
		print("makeButtonLight")
		q.makeButtonLight(self._ccbOwner.node_icon)
	else
		q.makeButtonNormal(self._ccbOwner.node_icon)
		self:update()
	end
end

function QUIWidgetArchaeologyTitle:onEnter()
	-- self._ccbOwner.node_icon:setScale(0.75)
	-- if remote.archaeology:getCurrentMapID() == self._mapID then
	-- 	self:dispatchEvent( {name = QUIWidgetArchaeologyTitle.EVENT_MOVE_STOP} )
	-- end
end

function QUIWidgetArchaeologyTitle:onExit()
	if self._scheduler then
    	scheduler.unscheduleGlobal(self._scheduler)
    	self._scheduler = nil
    end
end

function QUIWidgetArchaeologyTitle:getWidth()
	return self._ccbOwner.btn:getContentSize().width
end

function QUIWidgetArchaeologyTitle:getHeight()
	return self._ccbOwner.btn:getContentSize().height
end

function QUIWidgetArchaeologyTitle:_onTriggerClick(...)
	local args = {...}
	if args[1] == "1" then
		self._isReadyClick = true
	elseif args[1] == "32" then
		self._isClick = true
	-- elseif args[1] == "64" then
	else
		self._isReadyClick = false
		self._isClick = false
		return
	end

	if self._scheduler then
    	scheduler.unscheduleGlobal(self._scheduler)
    	self._scheduler = nil
    end

    self._ccbOwner.node_icon:setScale(0.7)

	self._scheduler = scheduler.performWithDelayGlobal(function()
		self._ccbOwner.node_icon:setScale(1)
		app.sound:playSound("common_confirm")
		if self._scheduler then
	    	scheduler.unscheduleGlobal(self._scheduler)
	    	self._scheduler = nil
	    end
	end, 2/30)

	if remote.archaeology:getCurrentMapID() == self._mapID then
		self._isReadyClick = false
		self._isClick = false
		return
	end

	if self._isReadyClick and self._isClick then
		self:dispatchEvent( {name = QUIWidgetArchaeologyTitle.EVENT_CLICK, mapID = self._mapID} )
	end
end

return QUIWidgetArchaeologyTitle