-- @Author: liaoxianbo
-- @Date:   2020-01-05 17:20:01
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-12 15:28:55
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmCollectProperty = class("QUIDialogGodarmCollectProperty", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")

function QUIDialogGodarmCollectProperty:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_collect.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGodarmCollectProperty.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("神器属性")
	self:resetAll()
    self:initData()
end

function QUIDialogGodarmCollectProperty:viewDidAppear()
	QUIDialogGodarmCollectProperty.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogGodarmCollectProperty:viewWillDisappear()
  	QUIDialogGodarmCollectProperty.super.viewWillDisappear(self)

	self:removeBackEvent()
end
function QUIDialogGodarmCollectProperty:resetAll( )
	self._ccbOwner.tf_team_attack_percent:setString("0")
	self._ccbOwner.tf_team_hp_percent:setString("0")
	self._ccbOwner.tf_team_armor_physical_percent:setString("0")
	self._ccbOwner.tf_team_armor_magic_percent:setString("0")
	self._ccbOwner.tf_team_attack_value:setString("0")
	self._ccbOwner.tf_team_hp_value:setString("0")
	self._ccbOwner.tf_team_armor_physical:setString("0")	
	self._ccbOwner.tf_team_armor_magic:setString("0")	
end
function QUIDialogGodarmCollectProperty:initData()

	local haveGodarms = remote.godarm:getHaveGodarmList() or {}
	local nums = 0
	

	local godarmReformProp = {}
	for _, godarmInfo in pairs(haveGodarms) do
		nums = nums + 1
		local godarmConfig = db:getCharacterByID(godarmInfo.id)
		-- 强化属性
		local refromProp = db:getGodarmLevelConfigBylevel(godarmConfig.aptitude, godarmInfo.level) or {}
		QActorProp:getPropByConfig(refromProp, godarmReformProp)
		--星级属性
		local gradeProp = db:getGradeByHeroActorLevel(godarmInfo.id, godarmInfo.grade)
		QActorProp:getPropByConfig(gradeProp, godarmReformProp)
	end

    for key, value in pairs(godarmReformProp) do
        local name = QActorProp._field[key].uiName or QActorProp._field[key].name
        local isPercent = QActorProp._field[key].isPercent
        local str = q.getFilteredNumberToString(tonumber(value or 0), isPercent, 1)  
        self:setText("tf_"..key,str)
    end	

    self._ccbOwner.tf_godarm_nums:setString(nums)
end

function QUIDialogGodarmCollectProperty:setText(name, text)
	if self._ccbOwner[name] then
		self._ccbOwner[name]:setString(text)
	end
end

function QUIDialogGodarmCollectProperty:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGodarmCollectProperty:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end	
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodarmCollectProperty:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGodarmCollectProperty
