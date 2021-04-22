-- @Author: xurui
-- @Date:   2017-01-03 20:03:10
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-11 19:34:29
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaritimeReplayClient = class("QUIWidgetMaritimeReplayClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText") 

QUIWidgetMaritimeReplayClient.EVENT_SHARE = "EVENT_SHARE"
QUIWidgetMaritimeReplayClient.EVENT_SCORE = "EVENT_SCORE"
QUIWidgetMaritimeReplayClient.EVENT_REPLAY = "EVENT_REPLAY"

function QUIWidgetMaritimeReplayClient:ctor(options)
	local ccbFile = "ccb/Widget_Haishang_jiangli1.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
	}
	QUIWidgetMaritimeReplayClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_share)
	q.setButtonEnableShadow(self._ccbOwner.btn_record)
	q.setButtonEnableShadow(self._ccbOwner.btn_info)
end

function QUIWidgetMaritimeReplayClient:onEnter()
end

function QUIWidgetMaritimeReplayClient:onExit()
end

function QUIWidgetMaritimeReplayClient:setInfo(param)
	self._info = param.info
	self._index = param.index

	local isAttack = false
	local isSuccess = self._info.success
	if self._info.fighterId == remote.user.userId then
		isAttack = true
	end

	local time = q.date("%m-%d %H:%M", self._info.fightAt/1000)
	local shipInfo = remote.maritime:getMaritimeShipInfoByShipId(self._info.shipId)
	local shipName = shipInfo.ship_name or ""
	local nickName = ""
	local areaName = ""
	local stringFormat = ""
	local success = "掠夺成功"
	local color = isSuccess == false and "##n" or "##n"
	if isAttack then
		nickName = self._info.defenseName or ""
		areaName = self._info.defenseGameAreaName or ""
    	stringFormat = "##n%s ##n您掠夺了##e%s（%s）##n的##e%s##n，比分%s，"..color.."%s"
    	success = isSuccess == false and "掠夺失败" or "掠夺成功"

	    self._ccbOwner.sp_win:setVisible(isSuccess)
	    self._ccbOwner.sp_lose:setVisible(not isSuccess)
	else
		if self._info.escortId == remote.user.userId then
	    	color = isSuccess == true and "##n" or "##n"
			nickName = self._info.fighterName or ""
			areaName = self._info.fighterGameAreaName or ""
			stringFormat = "##n%s ##e%s（%s）##n掠夺了您保护的##e%s##n的##e%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == true and "防守失败" or "防守成功"
	    else
	    	color = isSuccess == true and "##n" or "##n"
			nickName = self._info.fighterName or ""
			areaName = self._info.fighterGameAreaName or ""
			stringFormat = "##n%s ##e%s（%s）##n掠夺了您的##e%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == true and "防守失败" or "防守成功"
    	end

	    self._ccbOwner.sp_win:setVisible(not isSuccess)
	    self._ccbOwner.sp_lose:setVisible(isSuccess)
	end
	local scroe = self._info.attack_score..":"..self._info.defense_score

    if self._richText == nil then
        self._richText = QRichText.new(nil, 300, {stringType = 1, defaultSize = 20, fontName = global.font_name})
        self._richText:setAnchorPoint(0,1)
        self._ccbOwner.node_content:addChild(self._richText)
    end
    if self._info.escortId == remote.user.userId then
    	stringFormat = string.format(stringFormat, time, nickName, areaName, self._info.defenseName,shipName, scroe, success)
    else
		stringFormat = string.format(stringFormat, time, nickName, areaName, shipName, scroe, success)
	end
    self._richText:setString(stringFormat)


    -- self._ccbOwner.node_bg:setVisible(self._index%2==0)
end

function QUIWidgetMaritimeReplayClient:getReplayInfo(state)
	return self._info
end

function QUIWidgetMaritimeReplayClient:getContentSize()
	return self._ccbOwner.ly_bg:getContentSize()
end

function QUIWidgetMaritimeReplayClient:_onTriggerShare()
	self:dispatchEvent({name = QUIWidgetMaritimeReplayClient.EVENT_SHARE, info = self._info})
end

function QUIWidgetMaritimeReplayClient:_onTriggerDetail()
	self:dispatchEvent({name = QUIWidgetMaritimeReplayClient.EVENT_SCORE, info = self._info})
end

function QUIWidgetMaritimeReplayClient:_onTriggerReplay()
	self:dispatchEvent({name = QUIWidgetMaritimeReplayClient.EVENT_REPLAY, info = self._info})
end


return QUIWidgetMaritimeReplayClient