-- 
-- zxs
-- 玩法日历每天的每个任务
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretary = class("QUIWidgetSecretary", QUIWidget)

function QUIWidgetSecretary:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_client2.ccbi"
	local callBack = {
		
	}
	QUIWidgetSecretary.super.ctor(self, ccbFile, callBack, options)

	q.setButtonEnableShadow(self._ccbOwner.btn_go)
	q.setButtonEnableShadow(self._ccbOwner.btn_set)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSecretary:resetAll()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_select:setVisible(false)
	self._ccbOwner.node_ok:setVisible(false)
	self._ccbOwner.node_go:setVisible(false)
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.node_active_tips:setVisible(false)
	self._ccbOwner.node_money:setVisible(false)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_tf_name:setPositionY(-22)
	self._ccbOwner.tf_unlock_level:setVisible(false)
	self._ccbOwner.tf_tip:setVisible(false)
end

function QUIWidgetSecretary:setInfo(info)
	self:resetAll()

	self._info = info
	self._ccbOwner.tf_name:setString(info.name or "")

	-- icon
	local icon = CCSprite:create(info.icon)
	icon:setScale(86/icon:getContentSize().width)
    self._ccbOwner.node_icon:addChild(icon)

	-- 是否有快捷途径
	if info.shortcut_approach_new then
		self._ccbOwner.node_go:setVisible(true)
	end

	if remote.user.level < info.min_level then
		self._ccbOwner.tf_unlock_level:setVisible(true)
		self._ccbOwner.tf_unlock_level:setString(info.min_level.."级开启")
		self._ccbOwner.node_go:setVisible(false)
	else
		self._ccbOwner.tf_unlock_level:setVisible(false)
	end
	local config = remote.secretary:getMySecretaryConfigById(info.id)
	if config.needSet and remote.user.level >= info.min_level then
		self._ccbOwner.node_btn_set:setVisible(true)
		self._ccbOwner.tf_set_desc:setString("")
	end

end

function QUIWidgetSecretary:setSecretaryOpen(state)
	if state == nil then state = false end

	self._ccbOwner.sp_select:setVisible(state)
end

function QUIWidgetSecretary:setSecretaryActive(state, desc)
	if state == nil then state = false end

	self._ccbOwner.node_active_tips:setVisible(state)
	if state then
		self._ccbOwner.tf_unlock_level:setVisible(false)
	end
	if remote.user.level >= self._info.min_level then
		self._ccbOwner.node_select:setVisible(not state)
	else
		self._ccbOwner.node_select:setVisible(false)
	end
	self._ccbOwner.node_btn_set:setVisible(not state)
	if desc then
		self._ccbOwner.tf_active_tips:setString(desc)
	end
	self._ccbOwner.node_tf_name:setPositionY(-22)
end

function QUIWidgetSecretary:setSecretaryComplete(state)
	if state == nil then state = false end
	if remote.user.level >= self._info.min_level then
		self._ccbOwner.node_select:setVisible(not state)
		self._ccbOwner.node_ok:setVisible(state)
	else
		self._ccbOwner.node_select:setVisible(false)
		self._ccbOwner.node_ok:setVisible(false)
	end
	
end

function QUIWidgetSecretary:setDescStr(str)
	self._ccbOwner.tf_set_desc:setString(str)
end

function QUIWidgetSecretary:setRankStr(state, str)
	if state == nil then state = false end

	self._ccbOwner.node_rank:setVisible(state)
	if state then
		self._ccbOwner.tf_rank:setString(str)
		self._ccbOwner.node_tf_name:setPositionY(0)
	end
end

function QUIWidgetSecretary:setResourseIcon()
	local config = remote.secretary:getMySecretaryConfigById(self._info.id)
	self._ccbOwner.node_money:setVisible(true)
	local money = remote.user[config.resourceType] or 0
	local num,unit = q.convertLargerNumber(money)
	self._ccbOwner.tf_money:setString(num..unit)
	local iconPath = remote.items:getWalletByType(config.resourceType).alphaIcon
	self._ccbOwner.sp_money:setTexture(CCTextureCache:sharedTextureCache():addImage(iconPath))
end

function QUIWidgetSecretary:setTips(tip)
	if tip then
		self._ccbOwner.tf_tip:setVisible(true)
		self._ccbOwner.tf_tip:setString(tip)
	else
		self._ccbOwner.tf_tip:setVisible(false)
	end
end

function QUIWidgetSecretary:getContentSize()
	local size = self._ccbOwner.sp_bg:getContentSize()
	size.height = size.height + 5
	return size
end

return QUIWidgetSecretary