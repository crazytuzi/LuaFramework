local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityPreFeedback = class("QUIWidgetActivityPreFeedback", QUIWidget)
local QUIViewController = import("...ui.QUIViewController")

function QUIWidgetActivityPreFeedback:ctor(options)
	local ccbFile = "ccb/Widget_PreFeedback.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerGet", callback = handler(self, QUIWidgetActivityPreFeedback._onTriggerGet)},
  	}
	QUIWidgetActivityPreFeedback.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityPreFeedback:setInfo(info)
	self._info = info
	self._token = 0
	if self._info.records ~= nil and #self._info.records > 0 then
		self._token = self._info.records[1].complete_progress or 0
	end
	local params = string.split(self._info.params,"#")
	self._ccbOwner.tf_prepay_count:setString(self._token.."元")
	self._ccbOwner.tf_prefeedback_count:setString(self._token * tonumber(params[1]))
	self._ccbOwner.tf_prefeedback_tips:setPositionX(self._ccbOwner.tf_prefeedback_count:getPositionX()+self._ccbOwner.tf_prefeedback_count:getContentSize().width)
	self._ccbOwner.tf_vip_exp:setString(self._token * tonumber(params[2]))
	self._awards = {}
	table.insert(self._awards,  {typeName = ITEM_TYPE.TOKEN_MONEY, count = self._token * tonumber(params[1])})
	table.insert(self._awards,  {typeName = ITEM_TYPE.VIP_EXP, count = self._token * tonumber(params[2])})
	if self._info.targets[1].completeNum == 3 then
		self._ccbOwner.btn_get:setVisible(false)
	end
end

function QUIWidgetActivityPreFeedback:_onTriggerGet()
	app:getClient():activityCompleteRequest(self._info.activityId, self._info.targets[1].activityTargetId, nil, nil, function (data)
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = self._awards}},{isPopCurrentDialog = false} )
		dialog:setTitle("恭喜您获得活动奖励")
		remote.activity:setCompleteDataById(self._info.activityId, self._info.targets[1].activityTargetId)
		-- remote.activity:setCompleteDataById(id, activityTargetId)
	end)
end

return QUIWidgetActivityPreFeedback