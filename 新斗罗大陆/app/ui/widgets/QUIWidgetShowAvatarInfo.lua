-- 
-- zxs
-- 头像显示效果
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetShowAvatarInfo = class("QUIWidgetShowAvatarInfo", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")

local SCROLL_HEIGHT = 440

function QUIWidgetShowAvatarInfo:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_chenghao.ccbi"
	local callBacks = {
		--{ccbCallbackName = "onTriggerUse", callback = handler(self, self._onTriggerUse)}
	}
	QUIWidgetShowAvatarInfo.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	self._height = SCROLL_HEIGHT
  	self:setAllPropInfo()
end

function QUIWidgetShowAvatarInfo:onEnter() 	
end

function QUIWidgetShowAvatarInfo:onExit()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end

function QUIWidgetShowAvatarInfo:setAvatarInfo(avatarId, locked, time)
	local avatar = remote.headProp:getAvatar(avatarId, nil)
	if self._avatar == nil then
		self._avatar = QUIWidgetAvatar.new(avatar)
		self._ccbOwner.node_title:addChild(self._avatar)
	end
	self._avatar:setInfo(avatar)
	
	self._avatarInfo = db:getHeadInfoById(avatarId)
    self._ccbOwner.tf_title_name:setString(self._avatarInfo.desc or "")
	self._ccbOwner.tf_limit_content:setString(self._avatarInfo.service_life_desc or "")
	self._ccbOwner.tf_condition_content:setString(self._avatarInfo.tip or "无")
    self._ccbOwner.node_condition:setVisible(locked)

    -- set remaining time
    self:checkRemainingTime(time)

	local propWords = self:setAvatatPropNativeName(self._avatarInfo)
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

function QUIWidgetShowAvatarInfo:checkRemainingTime(time)
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
	    if dateTime and dateTime.year < 3000 and remainingTime < DAY*100 then
			self._schedulerFunc()
			return
		end
	end
    self._ccbOwner.tf_limit_content:setString(self._avatarInfo.service_life_desc or "")
end

function QUIWidgetShowAvatarInfo:setAvatatPropNativeName(avatarProp)
	local newProp = {}
	self._index = 1
	for key, value in pairs(QActorProp._field) do
		if avatarProp[key] ~= nil then
			newProp[self._index] = {}
			if value.isPercent == true then
				newProp[self._index].value = (avatarProp[key] * 100).."%"
			else
				newProp[self._index].value = avatarProp[key]
			end
			newProp[index].isPercent = value.isPercent
			newProp[self._index].nativeName = value.name.." "
			if key == "pvp_physical_damage_percent_attack" then
				newProp[self._index].nativeName = "全队pvp物理加伤"
			elseif key == "pvp_magic_damage_percent_attack" then
				newProp[self._index].nativeName = "全队pvp法术加伤"
			elseif key == "pvp_physical_damage_percent_beattack_reduce" then
				newProp[self._index].nativeName = "全队pvp物理减伤"
			elseif key == "pvp_magic_damage_percent_beattack_reduce" then
				newProp[self._index].nativeName = "全队pvp法术减伤"
			end 
			self._index = self._index + 1
		end
	end

	newProp = remote.headProp:sortFunc2(newProp)
	return newProp
end

function QUIWidgetShowAvatarInfo:setAllPropInfo()
	local allPropInfo = remote.headProp:getAvatarProp()
	self._ccbOwner.node_prop:removeAllChildren()
	local index = 0
	local label = self._ccbOwner.tf_prop
	for i, propValue in pairs (allPropInfo) do
		local str = tostring(propValue.nativeName).."+"..propValue.value
		local propFont = CCLabelTTF:create(str, label:getFontName(), label:getFontSize())
		propFont:setAnchorPoint(ccp(0.5, 1))
		self._ccbOwner.node_prop:addChild(propFont)
		propFont:setPositionY(-index*25)
		propFont:setColor(CCNode.getColor(label))
		index = index + 1
	end

	self._height = SCROLL_HEIGHT+index*25
end

function QUIWidgetShowAvatarInfo:getContentSize()
	local size = CCSize(300, self._height)
	return size
end

return QUIWidgetShowAvatarInfo