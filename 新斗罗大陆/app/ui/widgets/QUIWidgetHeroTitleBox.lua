-- 
-- zxs
-- 称号
-- 
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroTitleBox = class("QUIWidgetHeroTitleBox", QUIWidget) 

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetHeroTitleBox.CLICK_TITLE_EVENT = "CLICK_TITLE_EVENT"

function QUIWidgetHeroTitleBox:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_chenghao1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)}
	}
	QUIWidgetHeroTitleBox.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._ccbOwner.btn_click:setVisible(false)
end

function QUIWidgetHeroTitleBox:resetAll()
	self._ccbOwner.node_setting_select:setVisible(false)
	self._ccbOwner.node_setting_use:setVisible(false)
	self._ccbOwner.node_lock:setVisible(false)
	if self._effect ~= nil then
		self._effect:removeFromParent()
		self._effect = nil
	end
	self._ccbOwner.node_icon:removeAllChildren()
end 

function QUIWidgetHeroTitleBox:setInfo(params)
	self:resetAll()
	
	local titleInfo = params.titleInfo
	self._titleId = titleInfo.id
	self._locked = titleInfo.lock
	self._index = params.index

	self:setTitleInfo(titleInfo)
	self:setHeroTitle(params.addTitle, titleInfo)

	if self._locked ~= nil then
		self:showSettingLocked(self._locked)
	end

	if self._selectPosition ~= nil and self._selectPosition ~= 0 then
		self:showSettingSelect(self._selectPosition == self._index)
	end

	-- 魂力试炼
	if remote.user.title == 0 then
		if titleInfo.function_type == remote.headProp.TITLE_TRIAL_TYPE then
			local idTble = string.split(titleInfo.condition, ",")
			local min = tonumber(idTble[1])
			local max = tonumber(idTble[2])
			if min <= remote.user.soulTrial and remote.user.soulTrial <= max then
				self:showSettingUse(true)
		    end
		end
	else
		self:showSettingUse(self._titleId == remote.user.title)
	end
end

function QUIWidgetHeroTitleBox:setTitleId(titleId, soulTrial)
	self:resetAll()
	titleId = titleId or 0
	soulTrial = soulTrial or 0

	local titleInfo
	if titleId > 0 then
		titleInfo = db:getHeadInfoById(titleId)
    elseif soulTrial > 0 then 
		titleInfo = remote.headProp:getTitleInfoBySoulTrial(soulTrial)
	end

   	if not titleInfo then
		return
	end
	self:setTitleInfo(titleInfo)
end

function QUIWidgetHeroTitleBox:setTouchEnabled()
	self._ccbOwner.btn_click:setVisible(true)
end

function QUIWidgetHeroTitleBox:setTitleInfo(titleInfo)
	if titleInfo.function_type == remote.headProp.TITLE_TRIAL_TYPE then
		self:setSoulTitleIcon(titleInfo.condition)
	else
		self:setTitleIcon(titleInfo.icon)
	end
	self:setTitleEffect(titleInfo.animation)
end

function QUIWidgetHeroTitleBox:setSoulTitleIcon(condition)
	self._ccbOwner.node_icon:setScale(0.7)
	if not condition or condition == "" then
		return
	end

	local idTble = string.split(condition, ",")
	if idTble[1] and idTble[1] ~= "" then
		local configInfo = db:getSoulTrialById( idTble[1] )
		if configInfo and configInfo.title_icon1 and configInfo.title_icon2 then
			local kuang = CCSprite:create(configInfo.title_icon2)
			local sprite = CCSprite:create(configInfo.title_icon1)
			self._ccbOwner.node_icon:addChild(kuang)
			self._ccbOwner.node_icon:addChild(sprite)
		end
	end
end

function QUIWidgetHeroTitleBox:setTitleIcon(icon)
	self._ccbOwner.node_icon:setScale(0.9)
	if icon then
		local titleIcon = CCSprite:create(icon)
		self._ccbOwner.node_icon:addChild(titleIcon)
	end
end

function QUIWidgetHeroTitleBox:setTitleEffect(effects)
	if self._effect ~= nil then
		self._effect:removeFromParent()
		self._effect = nil
	end
	if effects then
	    self._effect = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_icon:addChild(self._effect)
		self._effect:playAnimation(effects, nil, nil, false)
	end
end

-- 添加title
function QUIWidgetHeroTitleBox:setHeroTitle(state, titleInfo)
	if self._title ~= nil then
		self._title:removeFromParent()
		self._title = nil
	end
	if state == true then
		local ccbOwner = {}
	    self._title = CCBuilderReaderLoad("ccb/Widget_Rongyao_title.ccbi", CCBProxy:create(), ccbOwner)
	    local contentSize = self:getContentSize()
	    self._title:setPosition(ccp(18, 70))
		self:getView():addChild(self._title)
		ccbOwner.tf_title_desc:setVisible(false)
		ccbOwner.tf_no:setVisible(false)

		local word = "魂力称号"
		if titleInfo.function_type == remote.headProp.TITLE_TRIAL_TYPE then
    		word = "魂力称号"
		elseif titleInfo.function_type == remote.headProp.TITLE_ACTIVITY_TYPE then
    		word = "活动称号"
    	elseif titleInfo.function_type == remote.headProp.TITLE_LUCKYBAG_A_TYPE then
    		word = "福袋称号"
    	elseif titleInfo.function_type == remote.headProp.TITLE_LUCKYBAG_P_TYPE then
    		word = "福袋称号"
		end
		ccbOwner.tf_title_name:setString(word or "")
	end
end

function QUIWidgetHeroTitleBox:setSelectPosition(index)
	self._selectPosition = index
end

function QUIWidgetHeroTitleBox:getIndex()	
	return self._index
end

function QUIWidgetHeroTitleBox:getTitleId()
	return self._titleId
end

function QUIWidgetHeroTitleBox:getContentSize()
	local size = self._ccbOwner.bg_layer:getContentSize()
	size.width = 450
	return size
end

function QUIWidgetHeroTitleBox:showSettingSelect(state)
	self._ccbOwner.node_setting_select:setVisible(state)
end

function QUIWidgetHeroTitleBox:showSettingUse(state)
	self._ccbOwner.node_setting_use:setVisible(state)
end

function QUIWidgetHeroTitleBox:showSettingLocked(state)
	self._ccbOwner.node_lock:setVisible(state)
end

function QUIWidgetHeroTitleBox:_onTriggerClick()
	if self._selectPosition == self._index then return end

	self:dispatchEvent({name = QUIWidgetHeroTitleBox.CLICK_TITLE_EVENT, titleId = self._titleId, index = self._index, locked = self._locked})
end

return QUIWidgetHeroTitleBox