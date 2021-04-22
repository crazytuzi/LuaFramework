-- @Author: xurui
-- @Date:   2017-04-28 11:53:06
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-21 20:30:46
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarCheckFastBattle = class("QUIDialogUnionDragonWarCheckFastBattle", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText") 

function QUIDialogUnionDragonWarCheckFastBattle:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_saodang.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, self._onTriggerAttack)},
		{ccbCallbackName = "onTriggerFastBattle", callback = handler(self, self._onTriggerFastBattle)},
	}
	QUIDialogUnionDragonWarCheckFastBattle.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._callback = options.callback
	end
end

function QUIDialogUnionDragonWarCheckFastBattle:viewDidAppear()
	QUIDialogUnionDragonWarCheckFastBattle.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogUnionDragonWarCheckFastBattle:viewWillDisappear()
	QUIDialogUnionDragonWarCheckFastBattle.super.viewWillDisappear(self)

end

function QUIDialogUnionDragonWarCheckFastBattle:setInfo()
	local myInfo = remote.unionDragonWar:getMyInfo() or {}
	local hurt = myInfo.todayMaxPerHurt or 0
	local num, word = q.convertLargerNumber(hurt)

	local data = {
            {oType = "font", content = "您今日的最高伤害为", size = 22, color = GAME_COLOR_SHADOW.normal},
            {oType = "font", content = num..word, size = 22, color = GAME_COLOR_SHADOW.stress},
        }
    local data1 = {
            {oType = "font", content = "是否按照此伤害值进行一次扫荡？", size = 22, color = GAME_COLOR_SHADOW.normal},
        }
	local richText = QRichText.new(data, 360)
	local richText1 = QRichText.new(data1, 360)
	richText:setPositionY(-10)
	richText1:setPositionY(-45)
	self._ccbOwner.node_tf_content:addChild(richText)
	self._ccbOwner.node_tf_content:addChild(richText1)
end

function QUIDialogUnionDragonWarCheckFastBattle:_onTriggerAttack(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_attack) == false then return end
	self._isAttack = true
	self:_onTriggerClose()
end

function QUIDialogUnionDragonWarCheckFastBattle:_onTriggerFastBattle(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fast_battle) == false then return end
	self._isFastBattle = true
	self:_onTriggerClose()
end

function QUIDialogUnionDragonWarCheckFastBattle:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonWarCheckFastBattle:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionDragonWarCheckFastBattle:viewAnimationOutHandler()
	local isFastBattle = self._isFastBattle
	local isAttack = self._isAttack
	local callback = self._callback

	self:popSelf()

	if isFastBattle == true then
		remote.unionDragonWar:dragonWarFastBattleRequest(BattleTypeEnum.DRAGON_WAR, function (data)
			local response = data.gfQuickResponse.dragonWarQuickFightResponse

			remote.user:addPropNumForKey("todayDragonWarFightCount")

            app.taskEvent:updateTaskEventProgress(app.taskEvent.DRAGON_WAR_TASK_EVENT, 1, false, false)
			
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonWarFastBattle", 
				options = {normalAward = response.normalAward, addAward = response.addAward}})
		end)
	else
		if isAttack == true and callback then
			callback()
		end
	end
end

return QUIDialogUnionDragonWarCheckFastBattle