--
-- Author: Kumo.Wang
-- Date: Fri Mar 11 13:03:07 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSunWarChest = class("QUIWidgetSunWarChest", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetSunWarChest.CHEST_APPEAR = 1
QUIWidgetSunWarChest.CHEST_JUMP = 2
QUIWidgetSunWarChest.CHEST_OPEN = 3
QUIWidgetSunWarChest.CHEST_DISAPPEAR = 4
QUIWidgetSunWarChest.CHEST_STATIC = 5

QUIWidgetSunWarChest.CHEST_OPENED = "CHEST_OPENED"

function QUIWidgetSunWarChest:ctor(options)
	local ccbFile = "ccb/Widget_SunWar_Chest.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChest", callback = handler(self, QUIWidgetSunWarChest._onTriggerChest)}
	}
	QUIWidgetSunWarChest.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self.animationIsFinish = false

	self._waveID = options.waveID
	self._isOpen = false

	self:_init()
end

function QUIWidgetSunWarChest:onEnter()
end

function QUIWidgetSunWarChest:onExit()
end

function QUIWidgetSunWarChest:_init()
	-- 绿
	local _, appearCCB = remote.sunWar:getChestAppearURL(1)
	local _, staticCCB = remote.sunWar:getChestStaticURL(1)
	local _, jumpCCB = remote.sunWar:getChestJumpURL(1)
	local _, openCCB = remote.sunWar:getChestOpenURL(1)
	local _, disappearCCB = remote.sunWar:getChestDisappearURL(1)

	self._ccbGreenFile = {appearCCB, jumpCCB, openCCB, disappearCCB, staticCCB}

	-- 蓝
	local _, appearCCB = remote.sunWar:getChestAppearURL(2)
	local _, staticCCB = remote.sunWar:getChestStaticURL(2)
	local _, jumpCCB = remote.sunWar:getChestJumpURL(2)
	local _, openCCB = remote.sunWar:getChestOpenURL(2)
	local _, disappearCCB = remote.sunWar:getChestDisappearURL(2)

	self._ccbBlueFile = {appearCCB, jumpCCB, openCCB, disappearCCB, staticCCB}

	-- 金
	local _, appearCCB = remote.sunWar:getChestAppearURL(3)
	local _, staticCCB = remote.sunWar:getChestStaticURL(3)
	local _, jumpCCB = remote.sunWar:getChestJumpURL(3)
	local _, openCCB = remote.sunWar:getChestOpenURL(3)
	local _, disappearCCB = remote.sunWar:getChestDisappearURL(3)

	self._ccbGoldFile = {appearCCB, jumpCCB, openCCB, disappearCCB, staticCCB}

	self._ccbFile = self._ccbGoldFile

	if self._aniPlayer == nil then
		self._aniPlayer = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(self._aniPlayer)
	end
end

function QUIWidgetSunWarChest:setIndex( color )
	if color == 1 then
		self._ccbFile = self._ccbGreenFile
	elseif color == 2 then
		self._ccbFile = self._ccbBlueFile
	else
		self._ccbFile = self._ccbGoldFile
	end
end

function QUIWidgetSunWarChest:playAppearAnimation()
	if self._ccbFile == nil then return	end
	self._isOpen = false
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetSunWarChest.CHEST_APPEAR], function ()
		-- print("[Kumo] appear play")
	end, function ()
			self:playStaticAnimation()
		end, false)
end

function QUIWidgetSunWarChest:playJumpAnimation()
	if self._ccbFile == nil then return	end
	self._isOpen = false
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetSunWarChest.CHEST_JUMP], function ()
		-- print("[Kumo] jump play") 
	end, function ()
			self._isActive = true
		end, false)
end

function QUIWidgetSunWarChest:playStaticAnimation()
	if self._ccbFile == nil then return	end
	self._isOpen = false
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetSunWarChest.CHEST_STATIC], function ()
		-- print("[Kumo] static play")
	end, function ()
		end, false)
end

function QUIWidgetSunWarChest:playDisappearAnimation()
	if self._ccbFile == nil then return	end
	self._isOpen = true
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetSunWarChest.CHEST_DISAPPEAR], function ()
		-- print("[Kumo] disappear play")
	end, function ()
		end, false)
end


function QUIWidgetSunWarChest:playOpenAnimation()
	if self._ccbFile == nil then return	end
	self._aniPlayer:playAnimation(self._ccbFile[QUIWidgetSunWarChest.CHEST_OPEN], function ()
		-- print("[Kumo] open play")
	end, function ()
		self._isOpen = true
		self:playDisappearAnimation()
		self:_requestWaveAward()
	end,false)
end

--宝箱打开动画结束时调用
function QUIWidgetSunWarChest:_requestWaveAward()
	app:getClient():sunwarGetWaveAwardRequest(self._waveID, false, function( data )
		remote.sunWar:responseHandler(data)
	end)
end

function QUIWidgetSunWarChest:_dispathEvent()
	self:dispatchEvent({name = QUIWidgetSunWarChest.CHEST_OPENED})
end

function QUIWidgetSunWarChest:resetAll()
	self._ccbFile = nil

	if self._aniPlayer ~= nil then
		self._aniPlayer:disappear()
	end
end

function QUIWidgetSunWarChest:setActive(b)
	self._isActive = b
end

function QUIWidgetSunWarChest:_onTriggerChest()
	-- print("[Kumo] 再点，再点我就不客气了。", self._waveID, self._isOpen, self._isActive)
    app.sound:playSound("common_small")
	if self._waveID ~= nil and self._isOpen == false then
		if self._isActive then
			self:playOpenAnimation()
		else
			remote.sunWar:sendInspectChestAwardEvent( self._waveID )
		end
	end
end

return QUIWidgetSunWarChest
