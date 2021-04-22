--
-- Kumo.Wang
-- zhangbichen主题曲活动——活动界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenActivityGame = class("QUIWidgetZhangbichenActivityGame", QUIWidget)

local QUIViewController = import("..QUIViewController")

function QUIWidgetZhangbichenActivityGame:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Zhangbichen_Game.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
	}
	QUIWidgetZhangbichenActivityGame.super.ctor(self, ccbFile, callBacks, options)

    q.setButtonEnableShadow(self._ccbOwner.btn_goto)
end

function QUIWidgetZhangbichenActivityGame:onEnter()
	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.ZHANGBICHEN_UPDATE, handler(self, self.refreshInfo))
end

function QUIWidgetZhangbichenActivityGame:onExit()
    self._activityRoundsEventProxy:removeAllEventListeners()
end

function QUIWidgetZhangbichenActivityGame:setInfo(info)
	self._zhangbichenModel = remote.activityRounds:getZhangbichen()
	if not self._zhangbichenModel then
		return
	end
	
	self:refreshInfo()
end

function QUIWidgetZhangbichenActivityGame:refreshInfo()
	local serverInfo = self._zhangbichenModel:getServerInfo()
	if not serverInfo then return end

	self._ccbOwner.sp_goto_redTip:setVisible(not self._zhangbichenModel:isActivityClickedToday(self._zhangbichenModel.yuyinniaoniaoActivityId))

	self._ccbOwner.tf_play_count:setString((serverInfo.remainCount or 0).."次")

	if self._zhangbichenModel.isActivityNotEnd then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_goto)
	else
		makeNodeFromNormalToGray(self._ccbOwner.btn_goto)
	end
end

function QUIWidgetZhangbichenActivityGame:_onTriggerGoto()
    local serverInfo = self._zhangbichenModel:getServerInfo()
    if not serverInfo then return end

    app.sound:playSound("common_small")

    if not self._zhangbichenModel.isActivityNotEnd then
    	app.tip:floatTip("活动已结束")
		return
    end

	if serverInfo.remainCount and serverInfo.remainCount <= 0 then
		-- app.tip:floatTip("已经没有领奖次数，无法进入游戏")
		app:alert({content = "没有剩余领奖次数，无法获得任何奖励，是否继续？",title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenMusicGame"})
            end
        end})
		return
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenMusicGame"})
	end
end

return QUIWidgetZhangbichenActivityGame