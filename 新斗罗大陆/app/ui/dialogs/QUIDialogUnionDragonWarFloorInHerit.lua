-- @Author: xurui
-- @Date:   2019-04-30 16:00:55
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-21 20:40:43
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarFloorInHerit = class("QUIDialogUnionDragonWarFloorInHerit", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

function QUIDialogUnionDragonWarFloorInHerit:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_dwjc.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogUnionDragonWarFloorInHerit.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._rewardInfo = options.rewardInfo
    end
end

function QUIDialogUnionDragonWarFloorInHerit:viewDidAppear()
	QUIDialogUnionDragonWarFloorInHerit.super.viewDidAppear(self)

	self:setFloorInfo()
	remote.unionDragonWar:dragonWarGetDailyRewardRequest(self._rewardInfo.rewardId, function(data)
	end)
end

function QUIDialogUnionDragonWarFloorInHerit:viewWillDisappear()
  	QUIDialogUnionDragonWarFloorInHerit.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonWarFloorInHerit:setFloorInfo()
	local floorName = remote.unionDragonWar:getFloorTextureName(self._rewardInfo.oldFloor)
	local unionName = ""
	if remote.union.consortia and remote.union.consortia.name then
		unionName = remote.union.consortia.name
	end
    local richText = QRichText.new({
        {oType = "font", content = "    尊敬的魂师大人，因为您的宗门", size = 24, color = COLORS.a},
        {oType = "font", content = "【"..unionName.."】",size = 24, color = COLORS.g},
        {oType = "font", content = "上赛季的段位达到了"..floorName,size = 24, color = ccc3(255,232,191)},
    },340, {autoCenter = false})
    richText:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_text:addChild(richText)


	local floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
	floorIcon:setInfo(self._rewardInfo.newFloor, "unionDragonWar")
	self._ccbOwner.node_floor:setScale(0.45)
	floorIcon:setPositionY(-20)
	self._ccbOwner.node_floor:addChild(floorIcon)
end 

function QUIDialogUnionDragonWarFloorInHerit:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    self:_onTriggerClose()
end

function QUIDialogUnionDragonWarFloorInHerit:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonWarFloorInHerit:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionDragonWarFloorInHerit:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogUnionDragonWarFloorInHerit
