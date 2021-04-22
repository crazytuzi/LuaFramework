-- 
-- zxs
-- 称号展示
-- 
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetShowTitleInfo = class("QUIWidgetShowTitleInfo", QUIWidget)

local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QActorProp = import("...models.QActorProp")
local QScrollView = import("...views.QScrollView") 
local QRichText = import("...utils.QRichText")

local SCROLL_HEIGHT = 440

function QUIWidgetShowTitleInfo:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_chenghao.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerUse", callback = handler(self, self._onTriggerUse)}
	}
	QUIWidgetShowTitleInfo.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	self._height = SCROLL_HEIGHT
  	self:setAllPropInfo()
end

function QUIWidgetShowTitleInfo:onEnter()
end

function QUIWidgetShowTitleInfo:onExit()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end

function QUIWidgetShowTitleInfo:setTitleInfo(titleId, locked, time)
	self._titleId = titleId

	if self._avatar == nil then
		self._avatar = QUIWidgetHeroTitleBox.new(avatar)
		self._ccbOwner.node_title:addChild(self._avatar)
	end
	self._avatar:setTitleId(self._titleId)

	self._titleInfo = db:getHeadInfoById(self._titleId)
	self._ccbOwner.tf_title_name:setString(self._titleInfo.desc or "")
	self._ccbOwner.tf_limit_content:setString(self._titleInfo.service_life_desc or "")
	self._ccbOwner.tf_condition_content:setString(self._titleInfo.tip or "无")

    if locked then
    	self._ccbOwner.node_condition:setVisible(true)
	elseif self._titleId == remote.user.title then 
    	self._ccbOwner.node_condition:setVisible(false)
    else
    	self._ccbOwner.node_condition:setVisible(false)
    end
    
    -- set remaining time
    self:checkRemainingTime(time)

    -- set prop
    local propWords = {}
    if self._titleInfo.function_type == remote.headProp.TITLE_TRIAL_TYPE then
    	local condition = string.split(self._titleInfo.condition, ",")
    	if condition[1] and condition[1] ~= "" then
			local configInfo = db:getSoulTrialById( condition[1] )
			propWords = self:setAvatatPropNativeName(configInfo)
		end
	elseif self._titleInfo.function_type == remote.headProp.TITLE_LUCKYBAG_A_TYPE or 
		self._titleInfo.function_type == remote.headProp.TITLE_LUCKYBAG_P_TYPE then
		local prop = remote.headProp:getRedpacketTitleProp(self._titleId)
    	propWords = self:setAvatatPropNativeName(prop)
    else
		propWords = self:setAvatatPropNativeName(self._titleInfo)
	end

    -- set prop
	self._ccbOwner.node_add_prop:removeAllChildren()
	local haveProp = false
	local index = 1
	for i = 1, 4 do 
		if propWords[i] ~= nil then
			local richText = QRichText.new(nil, 240, {autoCenter = true})
		    richText:setString({
		        {oType = "font", content = propWords[i].nativeName, size = 18,color = COLORS.k},
		        {oType = "font", content = "+"..propWords[i].value, size = 18,color = COLORS.l},
		    })
		    richText:setAnchorPoint(ccp(0.5, 0.5))
		    richText:setPositionY(- (index - 1) * 25)
		    self._ccbOwner.node_add_prop:addChild(richText)

		    index = index + 1
		    haveProp = true
	    end
	end

	self._ccbOwner["tf_no_prop"]:setVisible(not haveProp)
end

function QUIWidgetShowTitleInfo:checkRemainingTime(time)
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	local remainingTime = 0
	self._schedulerFunc = function()
		if remainingTime-1 > 0 then
			remainingTime = remainingTime - 1
            local word = q.timeToDayHourMinute(remainingTime)
			self._ccbOwner.tf_limit_content:setString(word)
			self._timeScheduler = scheduler.performWithDelayGlobal(self._schedulerFunc, 1)
		else
	    	self:checkRemainingTime()
		end
	end

	if time then 
		local endTime = time/1000
		local dateTime = os.date("*t", endTime)
		remainingTime = endTime - q.serverTime()
	    if dateTime and dateTime.year < 3000 and remainingTime < DAY*1000 then
			self._schedulerFunc()
			return
		end
	end
    self._ccbOwner.tf_limit_content:setString(self._titleInfo.service_life_desc or "")
end

function QUIWidgetShowTitleInfo:setAvatatPropNativeName(avatarProp)
	local newProp = {}
	local index = 1
	for key, value in pairs(QActorProp._field) do
		if avatarProp[key] ~= nil then
			newProp[index] = {}
			if value.isPercent == true then
				newProp[index].value = (avatarProp[key] * 100).."%"
			else
				newProp[index].value = avatarProp[key]
			end
			newProp[index].isPercent = value.isPercent
			if key == "pvp_physical_damage_percent_attack" then
				newProp[index].nativeName = "全队pvp物理加伤"
			elseif key == "pvp_magic_damage_percent_attack" then
				newProp[index].nativeName = "全队pvp法术加伤"
			elseif key == "pvp_physical_damage_percent_beattack_reduce" then
				newProp[index].nativeName = "全队pvp物理减伤"
			elseif key == "pvp_magic_damage_percent_beattack_reduce" then
				newProp[index].nativeName = "全队pvp法术减伤"
			else
				newProp[index].nativeName = value.name
			end 
			index = index + 1
		end
	end

	newProp = remote.headProp:sortFunc2(newProp)
	return newProp
end

function QUIWidgetShowTitleInfo:setAllPropInfo()
	local allPropInfo = remote.headProp:getTitleProp()
	self._ccbOwner.node_prop:removeAllChildren()
	local index = 0
	local label = self._ccbOwner.tf_prop
	for i, propValue in pairs(allPropInfo) do
		local str = tostring(propValue.nativeName).."+"..propValue.value
		local propFont = CCLabelTTF:create(str, label:getFontName(), label:getFontSize())
		self._ccbOwner.node_prop:addChild(propFont)
		propFont:setPositionY(-index*25)
		propFont:setAnchorPoint(ccp(0.5, 1))
		propFont:setColor(CCNode.getColor(label))
		index = index + 1
	end

	self._height = SCROLL_HEIGHT+index*25
end

function QUIWidgetShowTitleInfo:getContentSize()
	local size = CCSize(300, self._height)
	return size
end

return QUIWidgetShowTitleInfo