--
-- Author: Kumo
-- Date: 2015-08-27 16:25:50
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArchaeologyBuff = class("QUIDialogArchaeologyBuff", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QColorLabel = import("...utils.QColorLabel")
local QActorProp = import("...models.QActorProp")

function QUIDialogArchaeologyBuff:ctor(options)
	local ccbFile = "ccb/Dialog_archaeology_Buffup.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogArchaeologyBuff._onTriggerClose)},
	}
	QUIDialogArchaeologyBuff.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self.isAnimation = true --是否动画显示

	self._size = self._ccbOwner.buff_size:getContentSize()
end

function QUIDialogArchaeologyBuff:viewDidAppear()
	QUIDialogArchaeologyBuff.super.viewDidAppear(self)
	self:addBackEvent()
	self:_getBuffs()
	self:_updateProgress()
end

function QUIDialogArchaeologyBuff:viewWillDisappear()
	QUIDialogArchaeologyBuff.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogArchaeologyBuff:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogArchaeologyBuff:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogArchaeologyBuff:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogArchaeologyBuff:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogArchaeologyBuff:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogArchaeologyBuff:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogArchaeologyBuff:_getBuffs()
	local buffs = getArchaeologyPropByFragmentID(remote.archaeology:getLastEnableFragmentID())
	local tbl = {}

	for key, value in pairs(buffs) do
		-- if QActorProp._field[key] then
			-- local name = QActorProp._field[key].archaeologyName or QActorProp._field[key].name
			-- tbl[name] = value
		-- end
		if self._ccbOwner[key] then
			if string.find(key, "pvp") then
				-- self._ccbOwner[key]:setString(string.format("+%s%%", value*100))
				self._ccbOwner[key]:setString(q.PropPercentHanderFun(value))
			else
				self._ccbOwner[key]:setString("+"..value)
			end
		end
	end

	-- for key, value in pairs(buffs) do
	-- 	if QActorProp._field[key] then
	-- 		local name = QActorProp._field[key].archaeologyName or QActorProp._field[key].name
	-- 		tbl[name] = value
	-- 	end
	-- end
	-- print("-----------------------------11-----------")
	-- printTable(buffs)


	-- self._pvpBuff = ""
	-- self._normalBuff = ""

	--[[
		记录这2种属性各有几条，用于计算位置
	]]
	-- self._pvpNum = 0
	-- self._normalNum = 0

	-- for name, value in pairs(tbl) do
	-- 	if string.find(name, "玩家对战") then
	-- 		self._pvpBuff = self._pvpBuff.."##d"..name.." : +##g"..(value*100).."%\n"
	-- 		self._pvpNum = self._pvpNum + 1
	-- 	else
	-- 		self._normalBuff = self._normalBuff.."##d"..name.." : +##g"..value.."\n"
	-- 		self._normalNum = self._normalNum + 1
	-- 	end
	-- end

	-- self:_showBuffs()
end

function QUIDialogArchaeologyBuff:_updateProgress()
	local chapter, color = remote.archaeology:getLastChapterAndColor()
	self._ccbOwner.tf_enableNum:setString(tostring(chapter))
	self._ccbOwner.tf_enableNum:setColor(color)
end
  
-- function QUIDialogArchaeologyBuff:_showBuffs()
-- 	local normalText = QColorLabel:create(self._normalBuff, self._size.width/2, self._size.height)
-- 	self._ccbOwner.node_buff:addChild(normalText)
-- 	normalText:setPosition(ccp(0, 0))
-- 	local normalH = normalText:getActualHeight() -- 文本实际高度
-- 	if self._pvpNum == 0 then
-- 		normalText:setPosition(ccp(self._size.width/4, 0))
-- 	else
-- 		normalText:setPosition(ccp(0, 0))
-- 	end

-- 	local pvpText = QColorLabel:create(self._pvpBuff, self._size.width/2, self._size.height)
-- 	self._ccbOwner.node_buff:addChild(pvpText)
-- 	pvpText:setPosition(ccp(self._size.width/2 - 100, 0))
-- 	local pvpH = pvpText:getActualHeight() -- 文本实际高度
-- 	local h = 0
-- 	if normalH > pvpH then
-- 		h = normalH
-- 	else
-- 		h = pvpH
-- 	end
-- 	local x, y = self._ccbOwner.node_buff:getPosition()
-- 	self._ccbOwner.node_buff:setPosition(ccp(x + 120, y - (self._size.height - h)/2))
-- end

----------------------------------------------------- System callbacks --------------------------------------------------

function QUIDialogArchaeologyBuff:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogArchaeologyBuff
