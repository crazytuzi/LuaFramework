--
-- Author: Kumo.Wang
-- Date: Tue May 31 15:18:14 2016
-- Boss击杀宝箱元素
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonChest = class("QUIWidgetSocietyDungeonChest", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetSocietyDungeonChest.EVENT_CLICK = "QUIWIDGETSOCIETYDUNGEONCHEST_EVENT_CLICK"
QUIWidgetSocietyDungeonChest.EVENT_OPENED = "QUIWIDGETSOCIETYDUNGEONCHEST_EVENT_OPENED"

function QUIWidgetSocietyDungeonChest:ctor(options)
	local ccbFile = "ccb/Widget_society_fuben_baoxiang.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSocietyDungeonChest._onTriggerClick)},
	}
	QUIWidgetSocietyDungeonChest.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isOnEnter = false
    self._awardTbl = {}

	self._index = options.index -- boxId
	self._wave = options.wave
	self._chapter = options.chapter
	self._isBoss = options.isBoss

	self._animationStage = "normal"
	self._animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("normal")
    -- print("[Kumo] ctor run ", self._animationStage)
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))

	-- self._ccbOwner.tf_name = setShadow5(self._ccbOwner.tf_name)

	self:_init()
end

function QUIWidgetSocietyDungeonChest:onEnter()
	self._isOnEnter = true
end

function QUIWidgetSocietyDungeonChest:onExit()
	self._isOnEnter = false
end

function QUIWidgetSocietyDungeonChest:viewAnimationEndHandler(name)
	self._animationStage = name
	if name == "open" then
		self._openNode:setVisible(true)
		self._closeNode:setVisible(false)
		self._animationManager:runAnimationsForSequenceNamed("normal")
		-- print("[Kumo] viewAnimationEndHandler run ", self._animationStage)
		self._animationStage = "normal"

		if self._awardTbl and table.nums(self._awardTbl) > 0 then
			self:update(self._awardTbl)
		else
			self:update()
		end
		self:dispatchEvent( {name = QUIWidgetSocietyDungeonChest.EVENT_OPENED, index = self._index, wave = self._wave, chapter = self._chapter} )
	end
end

function QUIWidgetSocietyDungeonChest:openChest(tbl)
	self._awardTbl = {}
	if self._isOnEnter then
		if not self._animationStage or self._animationStage == "normal" then
			self._awardTbl = tbl
			self._openNode:setVisible(true)
			self._closeNode:setVisible(true)
			self._animationManager:runAnimationsForSequenceNamed("open")
			-- print("[Kumo] openChest run ", self._animationStage)
			self._animationStage = "open"
		end
	end
end

function QUIWidgetSocietyDungeonChest:getHeight()
	return self._openNode:getContentSize().height
end

function QUIWidgetSocietyDungeonChest:getWidth()
	return self._openNode:getContentSize().width
end

function QUIWidgetSocietyDungeonChest:update( tbl, index )
	if not tbl then
		self._openNode:setVisible(false)
		self._closeNode:setVisible(true)
		self._ccbOwner.tf_index:setString(self._index)
		self._ccbOwner.node_item:setVisible(false)
		self._ccbOwner.tf_name:setString("")
	else
		self._openNode:setVisible(true)
		self._closeNode:setVisible(false)
		self._ccbOwner.tf_index:setString("")
		self:_showAward(tbl.award)
		self._ccbOwner.node_item:setVisible(true)
		self._ccbOwner.tf_name:setString(tbl.nickname)
	end
end

function QUIWidgetSocietyDungeonChest:_onTriggerClick()
	-- print("QUIWidgetSocietyDungeonChest:_onTriggerClick()")
	self:dispatchEvent( {name = QUIWidgetSocietyDungeonChest.EVENT_CLICK, index = self._index, wave = self._wave, chapter = self._chapter} )
end

function QUIWidgetSocietyDungeonChest:_init()
	if self._isBoss then
		self._ccbOwner.node_1:setVisible(false)
		self._ccbOwner.node_2:setVisible(true)
		self._openNode = self._ccbOwner.sp_opened2
		self._closeNode = self._ccbOwner.sp_normal2
	else
		self._ccbOwner.node_1:setVisible(true)
		self._ccbOwner.node_2:setVisible(false)
		self._openNode = self._ccbOwner.sp_opened1
		self._closeNode = self._ccbOwner.sp_normal1
	end
	
	self._openNode:setVisible(false)
	self._closeNode:setVisible(true)
	self._ccbOwner.tf_index:setString(self._index)
	self._ccbOwner.node_item:setVisible(false)
	self._ccbOwner.tf_name:setString("")
end

function QUIWidgetSocietyDungeonChest:_showAward( str )
	local s, e = string.find(str, ";")
	local newStr = ""
	if s then
		newStr = string.sub(str, 1, s - 1)
	else
		newStr = str
	end

	s, e = string.find(newStr, "%^")
	if s then
		local item = QUIWidgetItemsBox.new()
    	item:setPromptIsOpen(true)
		self._ccbOwner.node_item:addChild(item)

		local a = string.sub(newStr, 1, s - 1)
		local b = string.sub(newStr, e + 1)
		-- print("[Kumo] QUIWidgetSocietyDungeonChest:_showAward() ", a, b)
		local n = tonumber(a)
		if n then
			-- 数字， item
			item:setGoodsInfo(a, ITEM_TYPE.ITEM, tonumber(b))
		else
			-- 字母，resource
			item:setGoodsInfo(nil, a, tonumber(b))
		end

		local index = 0
		local awardList = remote.union:analyseAwards(self._wave, self._chapter)
		-- QPrintTable(awardList)
		for _, value in pairs(awardList) do
			index = index + 1
			-- print(value.itemCount, tonumber(b), index)
			if tonumber(value.itemCount) == tonumber(b) then
				break
			end
		end

		if index < 3 then
			local ccbFile = "ccb/effects/heji_kuang_2.ccbi"
		    local aniPlayer = QUIWidgetAnimationPlayer.new()
		    self._ccbOwner.node_item:addChild(aniPlayer)
		    aniPlayer:playAnimation(ccbFile, nil, nil, false)
		end
	end
end

return QUIWidgetSocietyDungeonChest