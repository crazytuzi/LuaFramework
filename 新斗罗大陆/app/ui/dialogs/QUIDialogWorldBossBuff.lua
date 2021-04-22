-- @Author: Kumo
-- @Date:   2016-10-24 10:13:06

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBossBuff = class("QUIDialogWorldBossBuff", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 

QUIDialogWorldBossBuff.GLOTY_TAB = "GLOTY_TAB"
QUIDialogWorldBossBuff.KILL_TAB = "KILL_TAB"

function QUIDialogWorldBossBuff:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_Boss_zongmenjiacheng.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
	}
	QUIDialogWorldBossBuff.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	self.successCallback = options.successCallback
	self._ccbOwner.frame_tf_title:setString("宗门加成")
	self:_init()
end

function QUIDialogWorldBossBuff:viewDidAppear()
	QUIDialogWorldBossBuff.super.viewDidAppear(self)
end

function QUIDialogWorldBossBuff:viewWillDisappear()
	QUIDialogWorldBossBuff.super.viewWillDisappear(self)
end

function QUIDialogWorldBossBuff:_resetAll()
	local index = 1
	while true do
		local node = self._ccbOwner["on_"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogWorldBossBuff:_init()
	self:_resetAll()
	self._buffIndex = remote.worldBoss:getWorldBossInfo().additionTimeId or 0 -- 0未没有选择
	if self._buffIndex > 0 then
		self._ccbOwner["on_"..self._buffIndex]:setVisible(true)
	end
end

function QUIDialogWorldBossBuff:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_small")
	if self._buffIndex ~= remote.worldBoss:getWorldBossInfo().additionTimeId then
		remote.worldBoss:worldBossChooseAdditionTimeRequest(self._buffIndex, function(data)
				app.tip:floatTip("设置成功")
				self._success = true
				remote.worldBoss:updateWorldBossParam(data.userWorldBossResponse or {})
				self:_onTriggerClose()
			end, function()
				app.tip:floatTip("设置失败，请稍后再试")
			end)
	elseif remote.worldBoss:getWorldBossInfo().additionTimeId > 0 then
		app.tip:floatTip("设置成功")
		self:_onTriggerClose()
	end
end

function QUIDialogWorldBossBuff:_onTriggerCancel(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
	app.sound:playSound("common_small")
	self:_onTriggerClose()
end

-- 1,12_14;	  2,14_16;	 3,16_18;	 4,18_20;	 5,20_22;
function QUIDialogWorldBossBuff:_onTriggerSelect(event, target)
	app.sound:playSound("common_small")

	self._isSaved = false
	self:_resetAll()
	local index = 1
	local _select = 0
	while true do
		local node = self._ccbOwner["btn_select_"..index]
		if node then
			if target == node then
				_select = index
				break
			end
			index = index + 1
		else
			break
		end
	end

	if _select > 0 then
		self._ccbOwner["on_".._select]:setVisible(true)
		self._buffIndex = _select
	end
end

function QUIDialogWorldBossBuff:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogWorldBossBuff:_onTriggerClose(e)
	if e then
  		app.sound:playSound("common_close")
  	end
	self:playEffectOut()
	if self._success and self.successCallback then
		self.successCallback()
	end
end

function QUIDialogWorldBossBuff:viewAninmationOutHandler()
	self:popSelf()
end

return QUIDialogWorldBossBuff