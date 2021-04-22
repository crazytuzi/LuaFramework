--
-- zxs
-- 武魂属性
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonTrainProp = class("QUIDialogUnionDragonTrainProp", QUIDialog)
local QActorProp = import("...models.QActorProp")

function QUIDialogUnionDragonTrainProp:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_shuxing.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogUnionDragonTrainProp.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true
	self._ccbOwner.frame_tf_title:setString("武魂属性")
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local dragonInfo = remote.dragon:getDragonInfo()
	self._dragonLevel = dragonInfo.level or 1
end

function QUIDialogUnionDragonTrainProp:viewDidAppear()
	QUIDialogUnionDragonTrainProp.super.viewDidAppear(self)

	self:setProp()
end

function QUIDialogUnionDragonTrainProp:viewWillDisappear()
	QUIDialogUnionDragonTrainProp.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonTrainProp:setProp()
	self._ccbOwner.tf_cur_title:setString(self._dragonLevel.."级属性")
	self._ccbOwner.tf_next_title:setString((self._dragonLevel+1).."级属性")

	local curDragonInfo = db:getUnionDragonInfoByLevel(self._dragonLevel)
	local nextDragonInfo = db:getUnionDragonInfoByLevel(self._dragonLevel+1)
	local curProp = remote.dragon:getPropInfo(curDragonInfo)
	local nextProp = remote.dragon:getPropInfo(nextDragonInfo)
	for i = 1, 4 do
		if curProp[i] then
			self._ccbOwner["tf_cur_name"..i]:setString(curProp[i].name.."+")
			self._ccbOwner["tf_cur_value"..i]:setString(curProp[i].value)
		else
			self._ccbOwner["tf_cur_name"..i]:setString("")
			self._ccbOwner["tf_cur_value"..i]:setString("")
		end
		if nextProp[i] then
			self._ccbOwner["tf_next_name"..i]:setString(nextProp[i].name.."+")
			self._ccbOwner["tf_next_value"..i]:setString(nextProp[i].value)
		else
			self._ccbOwner["tf_next_name"..i]:setString("")
			self._ccbOwner["tf_next_value"..i]:setString("")
		end
 	end
 	if nextProp == nil or next(nextProp) == nil then
		self._ccbOwner["tf_next_value3"]:setString("已满级")
 	end
end

function QUIDialogUnionDragonTrainProp:_onTriggerOK(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainProp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainProp:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
	self:playEffectOut()
end


return QUIDialogUnionDragonTrainProp