--
-- Author: Kumo
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonAward = class("QUIWidgetSocietyDungeonAward", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetSocietyDungeonAward.EVENT_CLICK = "QUIWIDGETSOCIETYDUNGEONAWARD_EVENT_CLICK"
QUIWidgetSocietyDungeonAward.WEI_WAN_CHENG = "WEI_WAN_CHENG"
QUIWidgetSocietyDungeonAward.DONE = "DONE"
QUIWidgetSocietyDungeonAward.YI_LING_QU = "YI_LING_QU"

function QUIWidgetSocietyDungeonAward:ctor(options)
	local ccbFile = "ccb/Widget_SunWall_xingji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickAwards",  callback = handler(self, QUIWidgetSocietyDungeonAward._onTriggerClick)},
	}

	QUIWidgetSocietyDungeonAward.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- setShadow5(self._ccbOwner.tf_name)
	-- setShadow5(self._ccbOwner.tf_progress)

	self._state = QUIWidgetSocietyDungeonAward.WEI_WAN_CHENG
end

function QUIWidgetSocietyDungeonAward:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetSocietyDungeonAward:onExit()   
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

-- {"chapter" = chapter[1].chapter, "lucky_draw" = chapter[1].lucky_draw, "name" = chapter[1].chapter_name}
function QUIWidgetSocietyDungeonAward:setInfo(info)
	self._achieveInfo = info
	self:resetAll()
	local id = q.numToWord( self._achieveInfo.chapter )
	local name = self._achieveInfo.name
	
	self._ccbOwner.tf_progress:setString("")
	self._ccbOwner.tf_name:setString("通关第"..id.."章 "..name)

	local consortia  = remote.union.consortia
    local maxChapter = consortia.max_chapter
    local maxChapterProgress = consortia.max_chapter_progress
    local receivedChapterIds = self:_anaylsisReceivedList()
    -- QPrintTable(receivedChapterIds)
    print("[Kumo] QUIWidgetSocietyDungeonAward:setInfo() ", maxChapter, self._achieveInfo.chapter, maxChapterProgress )
    if receivedChapterIds and receivedChapterIds[self._achieveInfo.chapter] then
    	-- print("[Kumo] 已领取第"..id.."章"..name.."的奖励！")
		self._state = QUIWidgetSocietyDungeonAward.YI_LING_QU
		self._ccbOwner.sp_yilingqu:setVisible(true)
		self._ccbOwner.normal_banner:setVisible(true)
		self._ccbOwner.sp_title_normal:setVisible(true)
		self._ccbOwner.sp_title_done:setVisible(false)		
	else
		if maxChapter > self._achieveInfo.chapter then
			-- print("[Kumo] 已完成第"..id.."章"..name.."的成就，可以领取奖励！")
			self._state = QUIWidgetSocietyDungeonAward.DONE
			self._ccbOwner.node_done:setVisible(true)
			self._ccbOwner.done_banner:setVisible(true)
			self._ccbOwner.sp_title_normal:setVisible(false)
			self._ccbOwner.sp_title_done:setVisible(true)
		elseif maxChapter == self._achieveInfo.chapter and maxChapterProgress == 100 then
			-- print("[Kumo] 已完成第"..id.."章"..name.."的成就，可以领取奖励！II ", maxChapter, maxChapterProgress )
			self._state = QUIWidgetSocietyDungeonAward.DONE
			self._ccbOwner.node_done:setVisible(true)
			self._ccbOwner.done_banner:setVisible(true)
			self._ccbOwner.sp_title_normal:setVisible(false)
			self._ccbOwner.sp_title_done:setVisible(true)			
		else
			-- print("[Kumo] 未完成第"..id.."章"..name.."的成就，继续努力！")
			self._state = QUIWidgetSocietyDungeonAward.WEI_WAN_CHENG
			self._ccbOwner.tf_weiwancheng:setVisible(true)
			self._ccbOwner.normal_banner:setVisible(true)
			self._ccbOwner.sp_title_normal:setVisible(true)
			self._ccbOwner.sp_title_done:setVisible(false)				
		end
	end

	self._items = QStaticDatabase.sharedDatabase():getluckyDrawById(self._achieveInfo.lucky_draw)
	for i = 1, #self._items, 1 do
		local node = self._ccbOwner["item"..i]
		if node then
			local box = QUIWidgetItemsBox.new()
			-- print(self._items[i].id, self._items[i].typeName, self._items[i].count)
			box:setGoodsInfo(self._items[i].id, self._items[i].typeName, self._items[i].count)
			box:setPromptIsOpen(true)
			node:addChild(box)
			node:setVisible(true)
		else
			break
		end
	end 
end

function QUIWidgetSocietyDungeonAward:_anaylsisReceivedList()
	local receivedChapterIds = {}

	local userConsortia = remote.user:getPropForKey("userConsortia")
	-- QPrintTable(userConsortia)
	local tbl = userConsortia.consortia_chapter_reward
	-- QPrintTable(tbl)
	if not tbl or #tbl == 0 then return nil end

	for _, value in pairs(tbl) do
		receivedChapterIds[value] = true
	end
	-- QPrintTable(receivedChapterIds)
	return receivedChapterIds
end

function QUIWidgetSocietyDungeonAward:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetSocietyDungeonAward:resetAll()
	self._ccbOwner.normal_banner:setVisible(false)
	self._ccbOwner.done_banner:setVisible(false)
	self._ccbOwner.sp_title_normal:setVisible(false)
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

function QUIWidgetSocietyDungeonAward:_onTriggerClick(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_done) == false then return end
	self:dispatchEvent({name = QUIWidgetSocietyDungeonAward.EVENT_CLICK, chapter = self._achieveInfo.chapter, state = self._state, items = self._items})
end

function QUIWidgetSocietyDungeonAward:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSocietyDungeonAward