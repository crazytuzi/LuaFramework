-- @Author: liaoxianbo
-- @Date:   2020-08-06 16:24:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-17 10:54:13
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMazeExploreMemoryAwardCell = class("QUIWidgetMazeExploreMemoryAwardCell", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetMazeExploreMemoryAwardCell.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetMazeExploreMemoryAwardCell.WEI_WAN_CHENG = "WEI_WAN_CHENG"
QUIWidgetMazeExploreMemoryAwardCell.DONE = "DONE"
QUIWidgetMazeExploreMemoryAwardCell.YI_LING_QU = "YI_LING_QU"

function QUIWidgetMazeExploreMemoryAwardCell:ctor(options)
	local ccbFile = "ccb/Widget_SunWall_xingji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickAwards",  callback = handler(self, self._onTriggerClick)},
	}

	QUIWidgetMazeExploreMemoryAwardCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()

	self._score = self._mazeExploreDataHandle:getMazeExploreScore()

	self._state = QUIWidgetMazeExploreMemoryAwardCell.WEI_WAN_CHENG
end

function QUIWidgetMazeExploreMemoryAwardCell:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetMazeExploreMemoryAwardCell:onExit()   
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

-- ["floor"] = chapter.soul_tower_floor, ["lucky_draw"] = chapter.pass_reward, ["wave"] = chapter.soul_tower_wave
function QUIWidgetMazeExploreMemoryAwardCell:setInfo(info)
	self._achieveInfo = info
	self:resetAll()
	QPrintTable(info)
	self._ccbOwner.tf_progress:setString("拥有"..self._score.."/"..self._achieveInfo.memeryPieceNum)
	self._ccbOwner.tf_name:setString("收集"..(self._achieveInfo.memeryPieceNum or "一定数量").. "个记忆碎片")

    local receivedChapterIds = self._mazeExploreDataHandle:_anaylsisReceivedMemoryList()

    if receivedChapterIds and receivedChapterIds[self._achieveInfo.id] then
		self._state = QUIWidgetMazeExploreMemoryAwardCell.YI_LING_QU
		self._ccbOwner.sp_yilingqu:setVisible(true)
		self._ccbOwner.normal_banner:setVisible(true)
	else
		if self._score >= self._achieveInfo.memeryPieceNum then
			self._state = QUIWidgetMazeExploreMemoryAwardCell.DONE
			self._ccbOwner.node_done:setVisible(true)
			self._ccbOwner.done_banner:setVisible(true)
			self._ccbOwner.sp_title_normal:setVisible(false)
			self._ccbOwner.sp_title_done:setVisible(true)					
		else	
			self._state = QUIWidgetMazeExploreMemoryAwardCell.WEI_WAN_CHENG
			self._ccbOwner.tf_weiwancheng:setVisible(true)
			self._ccbOwner.normal_banner:setVisible(true)
		end
	end
	
	self._items = db:getluckyDrawById(self._achieveInfo.award)
	QPrintTable(self._items)
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

function QUIWidgetMazeExploreMemoryAwardCell:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetMazeExploreMemoryAwardCell:resetAll()
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

function QUIWidgetMazeExploreMemoryAwardCell:_onTriggerClick(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_done) == false then return end
	self:dispatchEvent({name = QUIWidgetMazeExploreMemoryAwardCell.EVENT_CLICK, id = self._achieveInfo.id, state = self._state, items = self._items})
end

function QUIWidgetMazeExploreMemoryAwardCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetMazeExploreMemoryAwardCell
