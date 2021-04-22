-- @Author: xurui
-- @Date:   2018-11-14 10:47:46
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 15:37:13
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStormArenaList = class("QUIWidgetStormArenaList", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetStormArena = import("..widgets.QUIWidgetStormArena")

function QUIWidgetStormArenaList:ctor(options)
    QUIWidgetStormArenaList.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._stormArenaClient = {}
	self._ccbOwner = {}
	self._bgScale = 1
end

function QUIWidgetStormArenaList:onEnter()
end

function QUIWidgetStormArenaList:onExit()
end

function QUIWidgetStormArenaList:setInfo(data, index, isManualRefresh)
	if data == nil then return end

	self:showBgImage(index)

	local pos = {{x = 120, y = 20}, {x = 280, y = -300}, {x = -30, y = -480}}
	if index == 1 then
		pos = {{x = 120, y = -60}, {x = 280, y = -380}, {x = -30, y = -560}}
	end
	for i = 1, 3 do
		if data[i] then
			if self._stormArenaClient[i] == nil then
				self._stormArenaClient[i] = QUIWidgetStormArena.new()
		    	self._stormArenaClient[i]:addEventListener(QUIWidgetStormArena.EVENT_BATTLE, handler(self, self._clickEvent))
		    	self._stormArenaClient[i]:addEventListener(QUIWidgetStormArena.EVENT_VISIT, handler(self, self._clickEvent))
		    	self._stormArenaClient[i]:addEventListener(QUIWidgetStormArena.EVENT_WORSHIP, handler(self, self._clickEvent))
		    	self._stormArenaClient[i]:addEventListener(QUIWidgetStormArena.EVENT_QUICK_BATTLE, handler(self, self._clickEvent))
		    	self._stormArenaClient[i]:addEventListener(QUIWidgetStormArena.EVENT_FAST_BATTLE, handler(self, self._clickEvent))
				self:getView():addChild(self._stormArenaClient[i])
			end

			self._stormArenaClient[i]:setInfo(data[i], (index - 1)*3 + i, isManualRefresh)
			self._stormArenaClient[i]:setVisible(true)
			self._stormArenaClient[i]:setScale(0.8)
			self._stormArenaClient[i]:setPosition(pos[i].x, pos[i].y + (self._bgScale - 1.25) * pos[i].y)
		else
			if self._stormArenaClient[i] ~= nil then
				self._stormArenaClient[i]:setVisible(false)
			end
		end
	end

	self._offsetY = (#data - 3) * 150
end

function QUIWidgetStormArenaList:showBgImage(index)
	if index then
		local widgets = {"ccb/Dialog_StormArena1.ccbi", "ccb/Dialog_StormArena2.ccbi", "ccb/Dialog_StormArena3.ccbi"}
        local owner, proxy = {}, CCBProxy:create()
        local widgetClass = widgets[index]
		if widgets[index] == nil then
			widgetClass = widgets[#widgets]
		end
		if self._bgWidget then
			self._bgWidget:removeFromParent()
			self._bgWidget = nil
		end

    	self._bgWidget = CCBuilderReaderLoad(widgetClass, proxy, owner)
		self._bgWidget.owner = owner
		self._bgScale = 1.25
		local bef_ = self._bgWidget:getScale()
		local cur_ = CalculateUIBgSize(self._bgWidget, 1024) -- 地图按照1024设计 左右各补充了60px
		if bef_ ~= cur_ then
			self._bgScale = cur_
		else
			self._bgWidget:setScale(self._bgScale)
		end
		--self._bgScale = CalculateUIBgSize(self._bgWidget, self._bgWidget.owner.sp_bg:getContentSize().width)
		self._bgWidget.getContentSize = function(widget)
			local contentSize = widget.owner.sp_bg:getContentSize()
			return CCSize(contentSize.width*self._bgScale, contentSize.height*self._bgScale)
		end
		self:getView():addChild(self._bgWidget, -1)
		self._bgWidget:setPositionY(-(self._bgWidget:getContentSize().height/2))
	end
end

function QUIWidgetStormArenaList:registerBtnHandler(list, index)
	for i = 1, #self._stormArenaClient do
		local clientIndex = i

		self._ccbOwner["btn_onPress"..i] = self._stormArenaClient[i]:getTouchNodeByName("btn_onPress")
		self._ccbOwner["btn_visit"..i] = self._stormArenaClient[i]:getTouchNodeByName("btn_visit")
		self._ccbOwner["btn_visit1"..i] = self._stormArenaClient[i]:getTouchNodeByName("btn_visit1")
		self._ccbOwner["btn_fans"..i] = self._stormArenaClient[i]:getTouchNodeByName("btn_fans")
		self._ccbOwner["btn_fast_fight"..i] = self._stormArenaClient[i]:getTouchNodeByName("btn_fast_fight")
		
    	list:registerBtnHandler(index, "btn_fans"..i, "_onTriggerFans"..i, nil, true)
    	list:registerBtnHandler(index, "btn_fast_fight"..i, "_onTriggerFastFighter"..i, nil, true)
    	list:registerBtnHandler(index, "btn_onPress"..i, "_onPress"..i)
    	list:registerBtnHandler(index, "btn_visit"..i, "_onTriggerVisit"..i, nil, true)
    	list:registerBtnHandler(index, "btn_visit1"..i, "_onTriggerVisit"..i, nil, true)
	end
end

function QUIWidgetStormArenaList:showDeadEffect(index, callback)
	if self._stormArenaClient[index] then
		self._stormArenaClient[index]:showDeadEffect(callback)
	end
end

function QUIWidgetStormArenaList:_clickEvent(event)
	self:dispatchEvent(event)
end

function QUIWidgetStormArenaList:getContentSize()
	local contentSize = CCSize(0, 0)
	if self._bgWidget then
		contentSize = self._bgWidget:getContentSize()
	end
	return CCSize(contentSize.width, contentSize.height + self._offsetY)
end

function QUIWidgetStormArenaList:_onPress1()
	if self._stormArenaClient[1] then
		self._stormArenaClient[1]:_onPress()
	end
end

function QUIWidgetStormArenaList:_onPress2()
	if self._stormArenaClient[2] then
		self._stormArenaClient[2]:_onPress()
	end
end

function QUIWidgetStormArenaList:_onPress3()
	if self._stormArenaClient[3] then
		self._stormArenaClient[3]:_onPress()
	end
end

function QUIWidgetStormArenaList:_onTriggerVisit1()
	if self._stormArenaClient[1] then
		self._stormArenaClient[1]:_onTriggerVisit()
	end
end

function QUIWidgetStormArenaList:_onTriggerVisit2()
	if self._stormArenaClient[2] then
		self._stormArenaClient[2]:_onTriggerVisit()
	end
end

function QUIWidgetStormArenaList:_onTriggerVisit3()
	if self._stormArenaClient[3] then
		self._stormArenaClient[3]:_onTriggerVisit()
	end
end

function QUIWidgetStormArenaList:_onTriggerFans1()
	if self._stormArenaClient[1] then
		self._stormArenaClient[1]:_onTriggerFans()
	end
end

function QUIWidgetStormArenaList:_onTriggerFans2()
	if self._stormArenaClient[2] then
		self._stormArenaClient[2]:_onTriggerFans()
	end
end

function QUIWidgetStormArenaList:_onTriggerFans3()
	if self._stormArenaClient[3] then
		self._stormArenaClient[3]:_onTriggerFans()
	end
end


function QUIWidgetStormArenaList:_onTriggerFastFighter1()
	if self._stormArenaClient[1] then
		self._stormArenaClient[1]:_onTriggerFastFighter()
	end
end

function QUIWidgetStormArenaList:_onTriggerFastFighter2()
	if self._stormArenaClient[2] then
		self._stormArenaClient[2]:_onTriggerFastFighter()
	end
end

function QUIWidgetStormArenaList:_onTriggerFastFighter3()
	if self._stormArenaClient[3] then
		self._stormArenaClient[3]:_onTriggerFastFighter()
	end
end

return QUIWidgetStormArenaList
