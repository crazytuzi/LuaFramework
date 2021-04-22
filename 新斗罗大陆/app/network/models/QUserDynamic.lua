-- @Author: xurui
-- @Date:   2019-03-05 16:43:04
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-26 10:39:22
local QBaseModel = import("...models.QBaseModel")
local QUserDynamic = class("QUserDynamic", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")
local QUIViewController = import("...ui.QUIViewController")

QUserDynamic.featureConfig = {
	{dynamicType = 200, titleType = 1, content = "魂师大人，在您离开的时间里，魂师##s【%s】##j击败了您的小队，让您的排名下降了##s%s##j名。"},      	--竞技场排名下降
	{dynamicType = 600, titleType = 1, content = "魂师大人，在您离开的时间里，魂师##s【%s】##j击败了您的小队，让您的排名下降了##s%s##j名。"},      	--索托斗魂场排名下降
	{dynamicType = 400, titleType = 2, content = "魂师大人，在您离开的时间里，魂师##s【%s】##j击败了您的小队，抢夺了您的##s%s##j。"},      		--魂兽区变化
	{dynamicType = 500, titleType = 2, content = "魂师大人，在您离开的时间里，魂师##s【%s】##j击败了您的小队，抢夺了您的##s%s##j。"},      		--极北之地魂兽区变化
	{dynamicType = 700, titleType = 3, content = "魂师大人，在您离开的时间里，魂师##s【%s】##j击败了您的小队，夺走了您的血腥玛丽。"},      			--地狱杀戮场酒杯变化
	{dynamicType = 800, titleType = 4, content = "魂师大人，在您离开的时间里，魂师##s【%s】##j击败了您的小队，让您损失了##s%s##j个宝箱。"},      	--仙品聚宝盆被掠夺
	{dynamicType = 900, titleType = 5, content = "魂师大人，在您离开的时间里，魂师##s【%s】##选择了你作为保护者,太感谢了！"},--仙品聚宝盆被保护
	{dynamicType = 1000, titleType = 6, content = "魂师大人，在您离开的时间里，魂师##s【%s】##答应您的要求，借给您魂师！"},--魂师派遣
}

function QUserDynamic:ctor(options)
    QUserDynamic.super.ctor(self, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()


	self._dynamicSetting = {}
	self._serverDynamicSetting = {}
	self._offLineCheckStatus = {}     --每次登陆只检查一次
end

function QUserDynamic:init()
	self:setDynamicSetting()
end

function QUserDynamic:loginEnd(success)
	if success then
		success()
	end
end

function QUserDynamic:disappear()
	self._offLineCheckStatus = {}     
end

function QUserDynamic:updateServerDynamicStatus(data)
	if data then
		local serverData = string.split(data, ";")
		for _, value in pairs(serverData) do
			local data = string.split(value, "^")
			self._serverDynamicSetting[data[1]] = tonumber(data[2])
		end
	end
end

function QUserDynamic:setServerDynamicStatus(index, status, updateServer)
	if index then
		if status == true then
			self._serverDynamicSetting[tostring(index)] = 1
		else
			self._serverDynamicSetting[tostring(index)] = 0
		end
	end

	if updateServer and q.isEmpty(self._serverDynamicSetting) == false then
		local _value = table.formatString(self._serverDynamicSetting, "^", ";")
		remote.flag:set(remote.flag.DYNAMIC_CONFIG_KEY, _value)
	end
end

function QUserDynamic:getCurrentUnlockDynamic()
	self._serverDynamicSetting = {}
	for _, value in pairs(self._dynamicSetting) do
		if value.unlock and app.unlock:checkLock(value.unlock) then
			self._serverDynamicSetting[tostring(value.index)] = 1
		end
	end

	return self._serverDynamicSetting
end

function QUserDynamic:getServerDynamicStatus(index, status)
	if self._serverDynamicSetting[tostring(index)] == 1 or self._serverDynamicSetting[tostring(index)] == nil then
		return true
	end
	return false
end

function QUserDynamic:setDynamicSetting( ... )
	if q.isEmpty(self._dynamicSetting) then
		self._dynamicSetting = QStaticDatabase.sharedDatabase():getStaticByName("dynamic") or {}
	end
end

function QUserDynamic:getDynamicSetting()
	return self._dynamicSetting	
end

function QUserDynamic:checkDynamicUnlock()
	local unlock = false
	for _, value in pairs(self._dynamicSetting) do
		if value.unlock and app.unlock:checkLock(value.unlock) then
			unlock = true
			break
		end
	end

	return unlock
end

function QUserDynamic:getDynamicSettingByIndex(index)
	if index == nil then return end

	return self._dynamicSetting[tostring(index)]
end

function QUserDynamic:gotoDynamicFunction(index)
	if index == nil then return end

	local dynamicConfig = self:getDynamicSettingByIndex(index)
	if q.isEmpty(dynamicConfig) then return end

	if dynamicConfig.shortcut then
		-- 检查shortcut表
		local shortcutInfo = QStaticDatabase.sharedDatabase():getShortcut()
		local quickInfo = {}
		for _, value in pairs(shortcutInfo) do
			if value.cname == dynamicConfig.shortcut then
				quickInfo = value
				break
			end
		end
		-- 检查item_user_link表
		if next(quickInfo) == nil then
			local linkInfo = QStaticDatabase.sharedDatabase():getItemUseLink()
			for _, value in pairs(linkInfo) do
				if value.cname == dynamicConfig.shortcut then
					quickInfo = value
					break
				end
			end
		end

		if next(quickInfo) then
			QQuickWay:clickGoto(quickInfo)
		end
	end
end

function QUserDynamic:sendUserDynamicMessage(dynamicInfo)
	if q.isEmpty(dynamicInfo) then return end

	local dynamicConfig = self:getDynamicSettingByIndex(dynamicInfo.type)
	if q.isEmpty(dynamicConfig) then return end

    local contentIndex = math.random(1, 3)
    local content = dynamicConfig["content"..contentIndex]
    if content == nil then
    	content = dynamicConfig.content1
    end
    local message = self:formatDynamicContent(content, dynamicInfo.content)
    local misc = {type = "dynamic", nickName = dynamicInfo.nickname, avatar = dynamicInfo.avatar, vip = dynamicInfo.vipLevel, badge = dynamicInfo.badge, index = dynamicInfo.type,
    			 soulTrial = dynamicInfo.title}
    app:getServerChatData():_onMessageReceived(CHANNEL_TYPE.USER_DYNAMIC_CHANNEL, dynamicInfo.userId, dynamicInfo.nickname, message, q.OSTime(), misc)

end

function QUserDynamic:formatDynamicContent(str, param)
    local message = ""
	local content = string.split(str, "%#")
	local params = string.split(param, ";")
	local index = 1
	for i = 1, #content do
		if (i%2) ~= 0 then
			message = message..(content[i] or "")
		else
			local data = params[index] or ""
			if content[i] == "forest" then
				data = remote.silverMine:getMineCNNameByQuality(tonumber(data or 1))
			end
			message = message..data
			index = index + 1
		end
	end

	return message
end

--------------------------------- 玩家进入功能玩法动态 -------------------------------

function QUserDynamic:openDynamicDialog(dynamicIndex, callback,dynamicIndex2,callback2)
	local config = self.featureConfig[dynamicIndex]
	if q.isEmpty(config) == false and remote.userDynamic:checkOffLineStatus(config.dynamicType) then
		remote.userDynamic:requestOffLineStatus(config.dynamicType, function(data)
			if data.userOfflineEventInfo then
				local params = remote.userDynamic:getOffLineParamByResponse(data.userOfflineEventInfo)
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFeatureDynamicAlert", 
					options = {configIndex = dynamicIndex, params = params, callBack = function(isConfirm)
						if callback then
							callback(isConfirm)
						end
					end}}, {isPopCurrentDialog = false})
				return true
			else
				if dynamicIndex2 then
					local config2 = self.featureConfig[dynamicIndex2]
					remote.userDynamic:requestOffLineStatus(config2.dynamicType,function(data)
						if data.userOfflineEventInfo then
							local params = remote.userDynamic:getOffLineParamByResponse(data.userOfflineEventInfo)
							app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFeatureDynamicAlert", 
								options = {configIndex = dynamicIndex2, params = params, callBack = function(isConfirm)
									if callback2 then
										callback2(isConfirm)
									end
								end}}, {isPopCurrentDialog = false})
						end
					end)
				end
			end
		end)
	else
		return false
	end
end

function QUserDynamic:checkOffLineStatus(dynamicType)
	if q.isEmpty(self._offLineCheckStatus) then return true end

	if self._offLineCheckStatus[dynamicType] == true then 
		return false
	end

	return true
end

function QUserDynamic:getOffLineParamByResponse(response)
	if response == nil then return {} end

	local params = {}
	local eventInfo = response or {}
	if eventInfo.type == self.featureConfig[1].dynamicType or eventInfo.type == self.featureConfig[2].dynamicType then
		params = {eventInfo.nowRank, eventInfo.fightNickName, tonumber(eventInfo.nowRank) - tonumber(eventInfo.startRank)}
	elseif eventInfo.type == self.featureConfig[3].dynamicType or eventInfo.type == self.featureConfig[4].dynamicType then
		local mineName = remote.silverMine:getMineCNNameByQuality(tonumber(eventInfo.startRank or 1))
		params = {eventInfo.fightNickName, mineName}
	elseif eventInfo.type == self.featureConfig[5].dynamicType then
		params = {eventInfo.nowRank, eventInfo.fightNickName}
	elseif eventInfo.type == self.featureConfig[6].dynamicType then
		params = {eventInfo.fightNickName, eventInfo.nowRank}
	elseif eventInfo.type == self.featureConfig[7].dynamicType then
		params = {eventInfo.fightNickName, eventInfo.nowRank}
	elseif eventInfo.type == self.featureConfig[8].dynamicType then
		params = {eventInfo.fightNickName}
	end
	return params
end

--进入玩法检查动态
function QUserDynamic:requestOffLineStatus(type, success, fail)
	local userOfflineEventGetRequest = {type = type}
	local request = {api = "USER_OFFLINE_EVENT_GET", userOfflineEventGetRequest = userOfflineEventGetRequest}
    app:getClient():requestPackageHandler("USER_OFFLINE_EVENT_GET", request, function(data)
    		self._offLineCheckStatus[type] = true
    		if success then
    			success(data)
    		end
    	end, fail)
end

return QUserDynamic
