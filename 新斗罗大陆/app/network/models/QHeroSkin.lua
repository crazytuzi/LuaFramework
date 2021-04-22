-- @Author: xurui
-- @Date:   2019-01-07 10:21:54
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-27 16:44:35
local QBaseModel = import("...models.QBaseModel")
local QHeroSkin = class("QHeroSkin", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")

QHeroSkin.EVENT_HEROSKIN_UPDATE = "EVENT_HEROSKIN_UPDATE"

QHeroSkin.ITEM_SKIN_NORMAL = 0
QHeroSkin.ITEM_SKIN_ACTIVATED = 1
QHeroSkin.ITEM_SKIN_HAS = 2

function QHeroSkin:ctor()
	QHeroSkin.super.ctor(self)
end

function QHeroSkin:init()   
	self._heroSkinConfigDict = {}         	--根据英雄id保存量表配置的所有皮肤
	self._skinConfigDict = {}         		--量表配置的所有皮肤List
	self._heroSkinInfoDict = {}     		--服务器保存皮肤信息
end

function QHeroSkin:loginEnd(success)
	if success then
		success()
	end
end

function QHeroSkin:disappear()
end

function QHeroSkin:checkUnlock()
	if ENABLE_HERO_SKIN and app.unlock:checkLock("UNLOCK_CHARACTER_SKINS") then
		return true
	end

	return false
end

function QHeroSkin:getHeroSkinConfigListById(heroId)
	if heroId == nil then return {} end
	
	local skinConfig = {}
	local configDict = QStaticDatabase:sharedDatabase():getStaticByName("character_skins")
	if configDict then
		for _, value in pairs(configDict) do
			if value.is_show ~= 0 and value.character_id == tonumber(heroId) and not db:checkHeroShields(value.skins_id, SHIELDS_TYPE.SKIN_ID) then
				table.insert(skinConfig, value)
			end
	
	    end
	end
	
	return skinConfig
end

function QHeroSkin:getSkinConfigDictBySkinId(skinId)
	if skinId == nil then return {} end

	if q.isEmpty(self._skinConfigDict) then
		local configDict = QStaticDatabase:sharedDatabase():getStaticByName("character_skins")
		self._skinConfigDict = configDict
	end

	local skinConfig = self._skinConfigDict[tostring(skinId)] or {}
    if skinConfig.is_show == 0 then
		skinConfig = {}
	end

	return skinConfig
end

function QHeroSkin:getHeroSkinBySkinId(heroId, skinId)
	if heroId == nil or skinId == nil then return {} end

	local skinsList = self:getHeroSkinConfigListById(heroId)
	local skinConfig = {}
	for _, value in ipairs(skinsList) do
		if value.skins_id == tonumber(skinId) then
			skinConfig = value
			break
		end
	end

	return skinConfig
end

function QHeroSkin:checkSkinIsActivation(heroId, skinId)
	if heroId == nil or skinId == nil then return false end

	if self:getActivationHeroSkinsByHeroIdAndSkinId(heroId, skinId) then
		return true
	end

	return false
end

function QHeroSkin:checkHeroHasSkin(heroId)
	if heroId == nil then return false end

	local skinConfig = self:getHeroSkinConfigListById(heroId)
	for _, value in ipairs(skinConfig) do
		if self:getActivationHeroSkinsByHeroIdAndSkinId(heroId, value.skins_id) then
			return true
		end
	end

	return false
end

function QHeroSkin:checkHeroHaveSkinItem(heroId)
	if heroId == nil then return false end

	local heroSkinsList = self:getHeroSkinConfigListById(heroId)
	local haveItem = false
	for _, value in ipairs(heroSkinsList) do
		if value.skins_item then
			local isActivtion = self:checkSkinIsActivation(value.character_id, value.skins_id)
			if isActivtion == false then
				local itemNum = remote.items:getItemsNumByID(value.skins_item)
				if itemNum > 0 then
					haveItem = true
					break
				end
			end
		end
	end

	return haveItem
end

function QHeroSkin:getAllHeroSkinProp()
	local prop = {}

	if q.isEmpty(self._heroSkinInfoDict) == false then
		for heroId, heroSkins in pairs(self._heroSkinInfoDict) do
			for skinId, _ in pairs(heroSkins) do
				local skinConfig = self:getSkinConfigDictBySkinId(skinId)
				self:getHeroSkinProp(skinConfig, prop)
			end
		end
	end

	return prop
end

function QHeroSkin:getHeroSkinProp(skinInfo, prop)
	if q.isEmpty(skinInfo) then return end

	local propFields = QActorProp:getPropFields()
	for k, v in pairs(skinInfo) do
		if propFields[k] then
			if prop[k] == nil then
				local name = propFields[k].uiName
				if name == nil then
					name = propFields[k].name
				end
				prop[k] = {name = name, value = v, isPercent = propFields[k].isPercent}
			else
				prop[k].value = prop[k].value + v
			end
		end
	end
end

function QHeroSkin:openRecivedSkinDialog(heroSkins)
	if q.isEmpty(heroSkins) then return end

    app.taskEvent:updateTaskEventProgress(app.taskEvent.ACTIVE_SKIN_EVENT, 1, false, false)

	local skinInfo = self:getHeroSkinBySkinId(heroSkins[1].actorId, heroSkins[1].skinId)
    -- QPrintTable(skinConfig)
    if skinInfo.skins_ccb then
    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookHeroImageCard", 
	        options = {actorId = heroSkins[1].actorId, skinId = heroSkins[1].skinId, disableOutEffect = true, callback = function()
	        	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinBuySuccess", 
					options = {skinInfo = skinInfo}})
	        end}}) 
    else
    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinBuySuccess", 
			options = {skinInfo = skinInfo}})
    end
	
end

function QHeroSkin:openSkinDetailDialog(skinId)
	if skinId == nil then return end

	local skinInfo = self:getSkinConfigDictBySkinId(tonumber(skinId))
    if q.isEmpty(skinInfo) then
        app.tip:floatTip("该皮肤已下线")
        return
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinDetail", 
        options = {skinId = skinId, heroId = skinInfo.character_id}}, {isPopCurrentDialog = false})
end


function QHeroSkin:getSkinDisplaySetConfigById(id)
	local returnTbl = {}
	if id == nil then return returnTbl end

	local skinDisplaySetConfig = QStaticDatabase:sharedDatabase():getStaticByName("skins_display_set")
	returnTbl = skinDisplaySetConfig[tostring(id)]
	if tostring(returnTbl.id) ~= tostring(id) then
		returnTbl = {}
		for _, value in pairs(skinDisplaySetConfig) do
			if tostring(value.id) == tostring(id) then
				returnTbl = value
			end
		end
	end

	return returnTbl
end

----------------------------- update server info -------------------------------
--[[
message UserHeroSkin{
    optional int32  actorId         = 1;                    //英雄ID
    optional int64  skinId          = 2;                    //皮肤ID
}
]]
function QHeroSkin:setActivationHeroSkins(heroSkins)
	for _, value in ipairs(heroSkins) do
		if q.isEmpty(self._heroSkinInfoDict[value.actorId]) then
			self._heroSkinInfoDict[value.actorId] = {}
		end
		self._heroSkinInfoDict[value.actorId][value.skinId] = value.skinId
	end
	
	local heroSkins = self:getActivationHeroSkins()
	self:dispatchEvent({name = QHeroSkin.EVENT_HEROSKIN_UPDATE, heroSkins = heroSkins})
end

function QHeroSkin:getActivationHeroSkinsByHeroIdAndSkinId(heroId, skinId)
	if heroId == nil or skinId == nil then return {} end
	
	local heroSkins = self._heroSkinInfoDict[heroId] or {}
	return heroSkins[skinId]
end

--替代 remote.user.heroSkins
function QHeroSkin:getActivationHeroSkins()
	local heroSkins = {}
	
	for actorId, heroSkin in pairs(self._heroSkinInfoDict) do
		for skinId, skin in pairs(heroSkin) do
			table.insert(heroSkins, {actorId = tonumber(actorId), skinId = tonumber(skinId)})
		end
	end

	return heroSkins
end


function QHeroSkin:checkItemSkinByItem(itemId)
	local skinStatus = QHeroSkin.ITEM_SKIN_NORMAL
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo and itemInfo.type and itemInfo.type == ITEM_CONFIG_TYPE.SKIN_ITEM then
		local contents = string.split(itemInfo.content, "^")
		if contents[2] then
			local heroSkins = remote.heroSkin:getActivationHeroSkins()
			for i,v in pairs(heroSkins) do
				if v.skinId == tonumber(contents[2]) then
					skinStatus = QHeroSkin.ITEM_SKIN_ACTIVATED
					break
				end
			end
			if skinStatus == QHeroSkin.ITEM_SKIN_NORMAL then
				local items = remote.items:getItemsByCategory( ITEM_CONFIG_CATEGORY.CONSUM)
				for k,v in pairs(items) do
					if v.type == itemInfo.id then
						skinStatus = QHeroSkin.ITEM_SKIN_HAS
						break
					end
				end
			end
		end
	end
	return skinStatus
end

function QHeroSkin:checkItemSkinIsHave(itemId)
	local skinStatus = QHeroSkin.ITEM_SKIN_NORMAL
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo and itemInfo.type and itemInfo.type == ITEM_CONFIG_TYPE.SKIN_ITEM then
		local contents = string.split(itemInfo.content, "^")
		if contents[2] then
			local heroSkins = remote.heroSkin:getActivationHeroSkins()
			for i,v in pairs(heroSkins) do
				if v.skinId == tonumber(contents[2]) then
					skinStatus = QHeroSkin.ITEM_SKIN_ACTIVATED
					break
				end
			end
		end
		if skinStatus == QHeroSkin.ITEM_SKIN_NORMAL then

			local items = remote.items:getItemsByCategory( ITEM_CONFIG_CATEGORY.CONSUM)
			for k,v in pairs(items) do
				if v.type == itemInfo.id then
					skinStatus = QHeroSkin.ITEM_SKIN_HAS
					break
				end
			end
		end
		
		if skinStatus == QHeroSkin.ITEM_SKIN_NORMAL then
			local items = remote.items:getItemsByType( ITEM_CONFIG_TYPE.CONSUM_CHOOSE_PACKAGE)
			for k,v in pairs(items) do
				local packageInfo = QStaticDatabase:sharedDatabase():getItemByID(v.type)

				if packageInfo and packageInfo.content then
					local skinContent = string.split(packageInfo.content, ";") or {}
					for _,skin in pairs(skinContent) do
						local skinInfo = string.split(skin, "^")
						if skinInfo[1] and skinInfo[1] == tostring(itemId) then
							skinStatus = QHeroSkin.ITEM_SKIN_HAS
							break
						end
					end
				end
			end
		end
	end

	return skinStatus
end
----------------------------- request handler -------------------------------

function QHeroSkin:responseHandler(response, success, fail, succeeded)

	QHeroSkin.super.responseHandler(self, response, success, fail, succeeded)
end

--[[
message HeroSkinChangeRequest {
    optional int32 actorId = 1;                                             //英雄ID
    optional int32 skinId  = 2;                                             //皮肤ID
}
]]
--更换英雄皮肤
function QHeroSkin:changeHeroSkinRequest(actorId, skinId, success, fail, status)
    local heroSkinChangeRequest = {actorId = actorId, skinId = skinId}
    local request = {api = "HERO_SKIN_CHANGE", heroSkinChangeRequest = heroSkinChangeRequest}
    app:getClient():requestPackageHandler("HERO_SKIN_CHANGE", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
message HeroSkinBuyRequest {
    optional int32 skinId = 1;                                              //皮肤ID
}
]]
--购买英雄皮肤
function QHeroSkin:buyHeroSkinRequest(skinId, success, fail, status)
    local heroSkinBuyRequest = {skinId = skinId}
    local request = {api = "HERO_SKIN_BUY", heroSkinBuyRequest = heroSkinBuyRequest}
    app:getClient():requestPackageHandler("HERO_SKIN_BUY", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


return QHeroSkin