-- @Author: liaoxianbo
-- @Date:   2020-09-15 16:32:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-15 17:29:25
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFightClubRankDown = class("QUIDialogFightClubRankDown", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogFightClubRankDown:ctor(options)
	local ccbFile = "ccb/Dialog_chat_interaction.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
    }
    QUIDialogFightClubRankDown.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	CalculateUIBgSize(self._ccbOwner.ly_bg)
	self._callBack = options.callBack
	self._failNames = options.oldFailUserName or {"韦香主，刘常华"}
	self._isConfirm = false
end

function QUIDialogFightClubRankDown:viewDidAppear()
	QUIDialogFightClubRankDown.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:setInfo()
end

function QUIDialogFightClubRankDown:viewWillDisappear()
  	QUIDialogFightClubRankDown.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogFightClubRankDown:setInfo()
	local config = remote.userDynamic.featureConfig[tonumber(self._configIndex)]

	self._ccbOwner.node_rank:setVisible(true)
	self._ccbOwner.node_plunder:setVisible(false)
	self._ccbOwner.node_fightClub:setVisible(false)
	self._ccbOwner.node_maritime:setVisible(false)
	self._ccbOwner.node_maritime_project:setVisible(false)
	self._ccbOwner.node_offer_reward:setVisible(false)
	self._ccbOwner.node_rank_label:setVisible(false)
	self._ccbOwner.label_btntext:setString("知道了")
	local nameStr = ""
	for _,name in pairs(self._failNames) do
		if name then
			nameStr = nameStr..name
		end
	end
	local str = {
            {oType = "font", content = "    魂师大人，在您离开的时间里，您击败的对手",size = 20,color = COLORS.a},
            {oType = "font", content = nameStr, size = 20,color = COLORS.b},
            {oType = "font", content = "因为掉到30名以外导致您的血腥玛丽数量下降，排名下降", size = 20,color = COLORS.a},
        }
	self._richText = QRichText.new(str, 350, {stringType = 1, autoCenter = false, defaultSize = 24, defaultColor = COLORS.a})
	self._richText:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_text:addChild(self._richText)
end

function QUIDialogFightClubRankDown:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFightClubRankDown:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogFightClubRankDown:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
  	app.sound:playSound("common_small")
	self._isConfirm = true

	self:playEffectOut()
end

function QUIDialogFightClubRankDown:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogFightClubRankDown
