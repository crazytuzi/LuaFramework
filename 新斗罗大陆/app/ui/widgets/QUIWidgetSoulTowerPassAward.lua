-- @Author: liaoxianbo
-- @Date:   2020-04-12 19:31:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-24 15:51:11
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerPassAward = class("QUIWidgetSoulTowerPassAward", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetSoulTowerPassAward.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetSoulTowerPassAward.WEI_WAN_CHENG = "WEI_WAN_CHENG"
QUIWidgetSoulTowerPassAward.DONE = "DONE"
QUIWidgetSoulTowerPassAward.YI_LING_QU = "YI_LING_QU"

function QUIWidgetSoulTowerPassAward:ctor(options)
	local ccbFile = "ccb/Widget_SunWall_xingji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickAwards",  callback = handler(self, self._onTriggerClick)},
	}

	QUIWidgetSoulTowerPassAward.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._state = QUIWidgetSoulTowerPassAward.WEI_WAN_CHENG
end

function QUIWidgetSoulTowerPassAward:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetSoulTowerPassAward:onExit()   
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

-- ["floor"] = chapter.soul_tower_floor, ["lucky_draw"] = chapter.pass_reward, ["wave"] = chapter.soul_tower_wave
function QUIWidgetSoulTowerPassAward:setInfo(info)
	self._achieveInfo = info
	self:resetAll()
	local floor = q.numToWord( self._achieveInfo.floor )
	local wave = q.numToWord( self._achieveInfo.wave )
	
	self._ccbOwner.tf_progress:setString("")
	self._ccbOwner.tf_name:setString("首次通关第"..floor.."层".."第"..wave.."关")

    local maxfloor, maxFloorWave = remote.soultower:getHistoryPassFloorWave(true)
    local receivedChapterIds = remote.soultower:_anaylsisReceivedList()

    if receivedChapterIds and receivedChapterIds[self._achieveInfo.id] then
		self._state = QUIWidgetSoulTowerPassAward.YI_LING_QU
		self._ccbOwner.sp_yilingqu:setVisible(true)
		self._ccbOwner.normal_banner:setVisible(true)
	else
		if maxfloor > self._achieveInfo.floor then
			self._state = QUIWidgetSoulTowerPassAward.DONE
			self._ccbOwner.node_done:setVisible(true)
			self._ccbOwner.done_banner:setVisible(true)
			self._ccbOwner.sp_title_normal:setVisible(false)
			self._ccbOwner.sp_title_done:setVisible(true)			
		elseif maxfloor == self._achieveInfo.floor and maxFloorWave >= self._achieveInfo.wave then
			self._state = QUIWidgetSoulTowerPassAward.DONE
			self._ccbOwner.node_done:setVisible(true)
			self._ccbOwner.done_banner:setVisible(true)
			self._ccbOwner.sp_title_normal:setVisible(false)
			self._ccbOwner.sp_title_done:setVisible(true)			
		else	
			self._state = QUIWidgetSoulTowerPassAward.WEI_WAN_CHENG
			self._ccbOwner.tf_weiwancheng:setVisible(true)
			self._ccbOwner.normal_banner:setVisible(true)
		end
	end

	self._items = db:getluckyDrawById(self._achieveInfo.lucky_draw)
	for i = 1, #self._items, 1 do
		local node = self._ccbOwner["item"..i]
		if node then
			local box = QUIWidgetItemsBox.new()
			box:setGoodsInfo(self._items[i].id, self._items[i].typeName, self._items[i].count)
			box:setPromptIsOpen(true)
			node:addChild(box)
			node:setVisible(true)
		else
			break
		end
	end 
end

function QUIWidgetSoulTowerPassAward:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetSoulTowerPassAward:resetAll()
	self._ccbOwner.normal_banner:setVisible(false)
	self._ccbOwner.done_banner:setVisible(false)
	self._ccbOwner.sp_title_normal:setVisible(true)
	self._ccbOwner.sp_title_done:setVisible(false)	
	local i = 1
	while true do
		if self._ccbOwner["item"..i] then
			self._ccbOwner["item"..i]:setVisible(false)
			i = i + 1
		else
			break
		end
	end
	self._ccbOwner.tf_weiwancheng:setVisible(false)
	self._ccbOwner.node_done:setVisible(false)
	self._ccbOwner.sp_yilingqu:setVisible(false)
	self._ccbOwner.tf_progress:setString("")
end

function QUIWidgetSoulTowerPassAward:_onTriggerClick(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_done) == false then return end
	self:dispatchEvent({name = QUIWidgetSoulTowerPassAward.EVENT_CLICK, id = self._achieveInfo.id, state = self._state, items = self._items})
end

function QUIWidgetSoulTowerPassAward:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSoulTowerPassAward
