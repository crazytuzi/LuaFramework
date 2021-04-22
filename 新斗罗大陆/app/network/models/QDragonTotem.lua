-- 龙纹图腾数据类
-- Author: wkwang
-- Date: 2017-2-6
--
local QBaseModel = import("...models.QBaseModel")
local QDragonTotem = class("QDragonTotem", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QDragonTotem.EVENT_TOTEM_UPDATE = "EVENT_TOTEM_UPDATE"

QDragonTotem.TOTEM_TYPE = 7

function QDragonTotem:ctor(options)
	QDragonTotem.super.ctor(self)
	self._totemInfo = {}
	self._isUnlockTotem = false
end

function QDragonTotem:didappear()
	QDragonTotem.super.didappear(self)
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self,self.userPropChangeHandler))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_APPLY_RATIFY, handler(self, self.userPropChangeHandler))
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, handler(self, self.userPropChangeHandler))
end

function QDragonTotem:disappear()
	QDragonTotem.super.disappear(self)
    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_APPLY_RATIFY,  handler(self, self.userPropChangeHandler))
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED,  handler(self, self.userPropChangeHandler))
end

function QDragonTotem:loginEnd()
	self:requestTotemInfo()
end


function QDragonTotem:onUnionConsortiaApplyRatify()
	self:requestTotemInfo()
end

--设置图腾数据
function QDragonTotem:setDragonTotem(totemInfos)
	if totemInfos == nil then
		return 
	end
	for _,totemInfo in ipairs(totemInfos) do
		self._totemInfo[totemInfo.dragonDesignId] = totemInfo
	end
	self:dispatchEvent({name = QDragonTotem.EVENT_TOTEM_UPDATE})
end

--设置图腾数据
function QDragonTotem:getDragonTotem()
	return self._totemInfo or {}
end

--清除图腾数据
function QDragonTotem:clearTotemInfo()
	self._isUnlockTotem = self:checkTotemUnlock()
	self._totemInfo = {}
	self:dispatchEvent({name = QDragonTotem.EVENT_TOTEM_UPDATE})
end

--拉取图腾数据
function QDragonTotem:requestTotemInfo()
	self._isUnlockTotem = self:checkTotemUnlock()
    if self._isUnlockTotem then
    	self:consortiaDragonDesignGetInfoRequest()
    end
end

--玩家属性发生变化
function QDragonTotem:userPropChangeHandler()
	if remote.user.userConsortia == nil or remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "" then
		if self._isUnlockTotem == true then
			self:clearTotemInfo()
			app:getClient():refreshForce()
		end
	else
		if self._isUnlockTotem == false then
			self:requestTotemInfo()
			app:getClient():refreshForce()
		end
	end 
end

--是否解锁
function QDragonTotem:checkTotemUnlock(isTips)
	if remote.user.userConsortia == nil or remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "" then
		return false
	end
	-- local unlockLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("GH_KZ_KAIQI") or 0
	if app.unlock:checkLock("TUTENG_DRAGON", isTips) == true then
		return true
	end
	return false
end

--根据ID获取图腾信息
function QDragonTotem:getTotemInfo()
	return self._totemInfo[QDragonTotem.TOTEM_TYPE]
end

--根据ID获取龙纹信息
function QDragonTotem:getDragonInfoById(id)
	return self._totemInfo[id]
end

--根据ID获取图腾等级
function QDragonTotem:getTotemLevelById(id)
	local info = self:getDragonInfoById(id)
	if info == nil or info.grade == nil then return 1 end
	return info.grade
end

--获取最小的龙纹等级
function QDragonTotem:getMinTotemLevel()
	local min = nil
	for i=1,6 do
		local totemInfo = self._totemInfo[i]
		if totemInfo == nil then
			return 1
		elseif min == nil then
			min = totemInfo.grade or 1
		else
			min = math.min(min, (totemInfo.grade or 1))
		end
	end
	return min
end

--获取最大的龙纹等级
function QDragonTotem:getMaxTotemLevel()
	local max = nil
	for i=1,6 do
		local totemInfo = self._totemInfo[i]
		if totemInfo == nil then
			return 1
		elseif max == nil then
			max = totemInfo.grade or 1
		else
			max = math.max(max, (totemInfo.grade or 1))
		end
	end
	return max
end

--根据ID和等级获取配置信息
function QDragonTotem:getConfigByIdAndLevel(id, level)
	local configs = QStaticDatabase:sharedDatabase():getDragonTotemConfigById(id)
	if configs ~= nil then
		for _,v in ipairs(configs) do
			if v.level == level then
				return v
			end
		end
	end
	return nil
end

function QDragonTotem:getDragonTotemTalent()
	if self._talentConfigs == nil then
		self._talentConfigs = {}
		local talentConfigs = QStaticDatabase:sharedDatabase():getDragonTotemTalent()
		for _,config in pairs(talentConfigs) do
			table.insert(self._talentConfigs, config)
		end
		table.sort(self._talentConfigs, function (a,b)
			return a.id < b.id
		end)
	end
	return self._talentConfigs
end

--根据等级获取激活的天赋配置
function QDragonTotem:getActiviteTalentByLevel(level)
	local talentConfigs = self:getDragonTotemTalent()
	for _,config in ipairs(talentConfigs) do
		if config.condition == level then
			return config
		end
	end
end

--计算所有龙纹的属性
function QDragonTotem:countAllDragonProp()
	local prop = {}
	for i=1,6 do
		local level = self:getTotemLevelById(i)
		local config = self:getConfigByIdAndLevel(i, level)
		if config ~= nil then
			for k,v in pairs(config) do
				if type(v) == "number" then
					prop[k] = (prop[k] or 0) + v
				end
			end
		end
	end
	return prop
end

--计算图腾的天赋属性
function QDragonTotem:countTotemTalentProp()
	local totemInfo = self:getTotemInfo()
	local level = 1
	if totemInfo ~= nil and totemInfo.grade ~= nil then
		level = totemInfo.grade
	end
	local propTbl = {}
	local talentConfigs = self:getDragonTotemTalent()
	for _,config in ipairs(talentConfigs) do
		if config.condition <= level then
	        for name,filed in pairs(QActorProp._field) do
	            if config[name] ~= nil then
	                propTbl[name] = config[name] + (propTbl[name] or 0)
	            end
	        end
		end
	end
	return propTbl
end

--检查所有的ID是否可以升级
function QDragonTotem:checkAllTotemTips()
	if self:checkTotemUnlock() == false then return false end
	for i=1,7 do
		local b = self:checkTotemTipsById(i)
		if b then
			return true
		end
	end
	return false
end

--检查指定的Id是否可以升级
function QDragonTotem:checkTotemTipsById(dragonId)
	local level = self:getTotemLevelById(dragonId)
	--图腾检查一下等级限制
	if dragonId == QDragonTotem.TOTEM_TYPE then
		if self:getMinTotemLevel() <= level then
			return false
		end
	end
	local config = self:getConfigByIdAndLevel(dragonId, level+1)
	if config == nil then return false end

	local tbl = string.split(config.consume, ",")
	for _,v in ipairs(tbl) do
		local v2 = string.split(v, ";")
		if #v2 == 2 then
			local typeName = remote.items:getItemType(v2[1])
			if typeName == nil then
				if remote.items:getItemsNumByID(v2[1]) < tonumber(v2[2]) then
					return false
				end
			else
				if remote.user[typeName] < tonumber(v2[2]) then
					return false
				end
			end
		end
	end
	return true
end

function QDragonTotem:getPropStr(config)
	local prop = nil
	for _,v in ipairs(QActorProp._uiFields) do
		if config[v.fieldName] ~= nil and prop == nil then
			prop = v
			break
		end
	end
	if prop ~= nil then
		local value = config[prop.fieldName]
		if prop.handlerFun ~= nil then
			value = prop.handlerFun(value)
		end
		return prop.name.."+"..value
	end
	return ""
end

--------------------------proto part-------------------------------

--请求获取宗门的图腾信息
function QDragonTotem:consortiaDragonDesignGetInfoRequest(success, fail)
    local request = {api = "CONSORTIA_DRAGON_DESIGN_GET_INFO"}
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_DESIGN_GET_INFO", request, function (response)
        self:consortiaDragonDesignGetInfoResponse(response, success, nil, true)
    end, function (response)
        self:consortiaDragonDesignGetInfoResponse(response, nil, fail)
    end)
end

function QDragonTotem:consortiaDragonDesignGetInfoResponse(data, success, fail, succeeded)
	if data.consortiaDragonDesignGetInfoResponse ~= nil then
		self:setDragonTotem(data.consortiaDragonDesignGetInfoResponse.dragonDesignInfo or {})
	end
    self:responseHandler(data,success,fail, succeeded)
end

--请求升级宗门的图腾信息
function QDragonTotem:consortiaDragonDesignImproveRequest(dragonId, success, fail)
	local consortiaDragonDesignImproveRequest = {dragonId = dragonId}
    local request = {api = "CONSORITA_DRAGON_DESIGN_IMPROVE", consortiaDragonDesignImproveRequest = consortiaDragonDesignImproveRequest}
    app:getClient():requestPackageHandler("CONSORITA_DRAGON_DESIGN_IMPROVE", request, function (response)
        self:consortiaDragonDesignImproveResponse(response, success, nil, true)
    end, function (response)
        self:consortiaDragonDesignImproveResponse(response, nil, fail)
    end)
end

function QDragonTotem:consortiaDragonDesignImproveResponse(data, success, fail, succeeded)
	if data.consortiaDragonDesignImproveResponse ~= nil then
		local totemInfo = data.consortiaDragonDesignImproveResponse.dragonDesignInfo
		if totemInfo ~= nil then
			self:setDragonTotem({totemInfo})
		end
	end
    self:responseHandler(data,success,fail, succeeded)
end

--请求一键升级宗门的图腾信息
function QDragonTotem:consortiaDragonDesignQuickImproveRequest(success, fail)
    local request = {api = "CONSORTIA_DRAGON_DESIGN_ONE_KEY_IMPROVE"}
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_DESIGN_ONE_KEY_IMPROVE", request, function (response)
        self:consortiaDragonDesignQuickImproveResponse(response, success, nil, true)
    end, function (response)
        self:consortiaDragonDesignQuickImproveResponse(response, nil, fail)
    end)
end

function QDragonTotem:consortiaDragonDesignQuickImproveResponse(data, success, fail, succeeded)
	if data.dragonDesignInfo ~= nil then
		self:setDragonTotem(data.dragonDesignInfo)
	end
    self:responseHandler(data,success,fail, succeeded)
end


function QDragonTotem:getDragonIconById( id )
	local _id = tonumber(id)
	if _id == 1 then
		return "ui/society_yanglong/weever_physical.png"
	elseif _id == 2 then
		return "ui/society_yanglong/weever_attack.png"
	elseif _id == 3 then
		return "ui/society_yanglong/weever_agility.png"
	elseif _id == 4 then
		return "ui/society_yanglong/weever_resistance.png"
	elseif _id == 5 then
		return "ui/society_yanglong/weever_endurance.png"
	elseif _id == 6 then
		return "ui/society_yanglong/weever_power.png"
	end

	return ""
end

function QDragonTotem:getDragonAvatarFcaAndNameByDragonId(dragonId)
	local dragonAvatarFca = nil
	local dragonName = ""
	local dragonConfig
	if dragonId then 
		dragonConfig = QStaticDatabase.sharedDatabase():getUnionDragonConfigById(dragonId)
		dragonAvatarFca = dragonConfig.fca
		dragonName = dragonConfig.dragon_name
	end
    return dragonAvatarFca, dragonName, dragonConfig
end

return QDragonTotem