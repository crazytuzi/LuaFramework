-- @Author: zhouxiaoshu
-- @Date:   2019-06-20 14:50:51
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-06-20 15:00:05

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarFloorInHerit = class("QUIDialogConsortiaWarFloorInHerit", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

function QUIDialogConsortiaWarFloorInHerit:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_dwjc.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogConsortiaWarFloorInHerit.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._rewardInfo = options.rewardInfo
    end
end

function QUIDialogConsortiaWarFloorInHerit:viewDidAppear()
	QUIDialogConsortiaWarFloorInHerit.super.viewDidAppear(self)

	self:setFloorInfo()
	remote.consortiaWar:consortiaWarGetDailyRewardRequest(self._rewardInfo.rewardId)
end

function QUIDialogConsortiaWarFloorInHerit:viewWillDisappear()
  	QUIDialogConsortiaWarFloorInHerit.super.viewWillDisappear(self)
end

function QUIDialogConsortiaWarFloorInHerit:setFloorInfo()
	local floorName = remote.consortiaWar:getFloorTextureName(self._rewardInfo.oldFloor)
	local unionName = ""
	if remote.union.consortia then
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
	floorIcon:setInfo(self._rewardInfo.newFloor, "consortiaWar")
	self._ccbOwner.node_floor:setScale(0.45)
	floorIcon:setPositionY(-20)
	self._ccbOwner.node_floor:addChild(floorIcon)
end 

function QUIDialogConsortiaWarFloorInHerit:_onTriggerOK()
    self:_onTriggerClose()
end

function QUIDialogConsortiaWarFloorInHerit:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogConsortiaWarFloorInHerit:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogConsortiaWarFloorInHerit:viewAnimationOutHandler()
	self:popSelf()
	if self._callBack then
		self._callBack()
	end
end

return QUIDialogConsortiaWarFloorInHerit
