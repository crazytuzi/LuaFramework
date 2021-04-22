--
-- Author: Kumo.Wang
-- Date: Fri Mar 11 13:03:07 2016
-- 宝箱类
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChest = class("QUIWidgetChest", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetChest.CHEST_APPEAR = 1
QUIWidgetChest.CHEST_CLOSE = 2
QUIWidgetChest.CHEST_READY = 3
QUIWidgetChest.CHEST_OPEN = 4
QUIWidgetChest.CHEST_OPENED = 5
QUIWidgetChest.CHEST_DISAPPEAR = 6

QUIWidgetChest.CHEST_CLICK = "CHEST_CLICK"

function QUIWidgetChest:ctor(options)
	local ccbFile = "ccb/Widget_Chest.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChest", callback = handler(self, QUIWidgetChest._onTriggerChest)}
	}
	QUIWidgetChest.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self.animationIsFinish = false

	self._index = options.index
	self._chestType = options.chestType or 1
	self._isOpen = false

	self:_init()
end

function QUIWidgetChest:onEnter()
end

function QUIWidgetChest:onExit()
end

function QUIWidgetChest:_init()
	local appearCCB = "ccb/effects/chest/chest_appear.ccbi"
	local closeCCB = "ccb/effects/chest/chest_close.ccbi"
	local readyCCB = "ccb/effects/chest/chest_ready.ccbi"
	local openCCB = "ccb/effects/chest/chest_open.ccbi"
	local openedCCB = "ccb/effects/chest/chest_close.ccbi"

	self._ccbFile = {appearCCB, closeCCB, readyCCB, openCCB, openedCCB}

	local resPathList = QResPath("chest")[self._chestType]
	if not resPathList then
		resPathList = QResPath("chest")[1]
	end
	-- self._closeFrame = QSpriteFrameByPath(resPathList[1])
	-- self._openFrame = QSpriteFrameByPath(resPathList[2])
	self._closePath = resPathList[1]
	self._openPath = resPathList[2]

	if self._aniPlayer == nil then
		self._aniPlayer = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(self._aniPlayer)
	end
end

function QUIWidgetChest:setAppear()
	if self._ccbFile == nil then return	end
	self._isOpen = false
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetChest.CHEST_APPEAR], function ()
		-- print("[Kumo] appear play")
		self:setVisible(true)
		local _closeFrame = QSpriteFrameByPath(self._closePath)
		if _closeFrame then
			self._aniPlayer._ccbOwner.sp_chest_close:setDisplayFrame(_closeFrame)
			q.addSpriteShadow(self._aniPlayer._ccbOwner.sp_chest_close, _closeFrame)
		end
	end, function ()
		self:setClose()
	end, false)
end

function QUIWidgetChest:setClose()
	if self._ccbFile == nil then return	end
	self._isOpen = false
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetChest.CHEST_CLOSE], function ()
		-- print("[Kumo] static play")
		self:setVisible(true)
		local _closeFrame = QSpriteFrameByPath(self._closePath)
		if _closeFrame then
			self._aniPlayer._ccbOwner.sp_chest_close:setDisplayFrame(_closeFrame)
			q.addSpriteShadow(self._aniPlayer._ccbOwner.sp_chest_close, _closeFrame)
		end
	end, function ()
	end, false)
end

function QUIWidgetChest:setReady()
	if self._ccbFile == nil then return	end
	self._isOpen = false
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetChest.CHEST_READY], function ()
		-- print("[Kumo] jump play") 
		self:setVisible(true)
		local _closeFrame = QSpriteFrameByPath(self._closePath)
		if _closeFrame then
			self._aniPlayer._ccbOwner.sp_chest_close:setDisplayFrame(_closeFrame)
			q.addSpriteShadow(self._aniPlayer._ccbOwner.sp_chest_close, _closeFrame)
		end
	end, function ()
		self._isActive = true
	end, false)
end

function QUIWidgetChest:setOpen(isAutoDisappear)
	if self._ccbFile == nil then return	end
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetChest.CHEST_OPEN], function ()
		-- print("[Kumo] open play")
		self:setVisible(true)
		local _closeFrame = QSpriteFrameByPath(self._closePath)
		if _closeFrame then
			self._aniPlayer._ccbOwner.sp_chest_close:setDisplayFrame(_closeFrame)
			q.addSpriteShadow(self._aniPlayer._ccbOwner.sp_chest_close, _closeFrame)
		end
		local _openFrame = QSpriteFrameByPath(self._openPath)
		if _openFrame then
			self._aniPlayer._ccbOwner.sp_chest_open:setDisplayFrame(_openFrame)
			q.addSpriteShadow(self._aniPlayer._ccbOwner.sp_chest_open, _openFrame)
		end
	end, function ()
		self._isOpen = true
		if isAutoDisappear then
			self:setDisappear()
		end
	end,false)
end

function QUIWidgetChest:setOpened()
	if self._ccbFile == nil then return	end
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetChest.CHEST_OPENED], function ()
		-- print("[Kumo] open play")
		self:setVisible(true)
		self._isOpen = true
		local _openFrame = QSpriteFrameByPath(self._openPath)
		if _openFrame then
			self._aniPlayer._ccbOwner.sp_chest_close:setDisplayFrame(_openFrame)
			q.addSpriteShadow(self._aniPlayer._ccbOwner.sp_chest_close, _openFrame)
		end
	end, function ()
	end,false)
end

function QUIWidgetChest:setDisappear()
	if self._ccbFile == nil then return	end
	self._isOpen = true
	if self._ccbFile[QUIWidgetChest.CHEST_DISAPPEAR] then
		self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetChest.CHEST_DISAPPEAR], function ()
			-- print("[Kumo] disappear play")
		end, function ()
			self:setVisible(false)
		end, false)
	else
		self:setVisible(false)
	end
	
end

function QUIWidgetChest:_dispathEvent()
	self:dispatchEvent({name = QUIWidgetChest.CHEST_CLICK})
end

function QUIWidgetChest:resetAll()
	self._ccbFile = nil
	if self._aniPlayer ~= nil then
		self._aniPlayer:disappear()
	end
end

function QUIWidgetChest:setActive(b)
	self._isActive = b
end

function QUIWidgetChest:setVisible(b)
	self._ccbOwner.node_chest:setVisible(b)
end

function QUIWidgetChest:_onTriggerChest()
	-- print("[Kumo] 再点，再点我就不客气了。")
    app.sound:playSound("common_small")
    self:dispatchEvent({name = QUIWidgetChest.CHEST_CLICK, isActive = self._isActive, isOpen = self._isOpen, index = self._index})
end

return QUIWidgetChest
