-- Filename: WarcraftData.lua
-- Author: bzx
-- Date: 2014-11-15
-- Purpose: 阵法

module("WarcraftData", package.seeall)

require "db/DB_Method"
require "script/ui/warcraft/WarcraftService"
require "db/DB_Method_levelup"
require "db/DB_Method_attex"
require "db/DB_Affix"
require "db/DB_Formation"
require "db/DB_Normal_config"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyService"

local _warcraftDatas = nil
local _warcraftDatasMap = nil
local _usedWarcraftId
local _warcraftInfo
local _tagCopy
local _affixes = {}

function getWarcraftDatasMap( ... )
	if _warcraftDatasMap == nil then
		_warcraftDatasMap = {}
		for k, v in pairs(DB_Method.Method) do
			local warcraftData = {}
			warcraftData.id = v[1]
			if _warcraftInfo == nil or _warcraftInfo.warcraft[v[1]] == nil then
				warcraftData.level = 1
			else
				warcraftData.level = _warcraftInfo.warcraft[v[1]].level
			end
			_warcraftDatasMap[warcraftData.id] = warcraftData
		end
	end
	return _warcraftDatasMap
end

function getWarcraftDatas( ... )
	if _warcraftDatas == nil then
		_warcraftDatas = {}
		for k, v in pairs(DB_Method.Method) do
			local id = v[1]
			table.insert(_warcraftDatas, id)
		end
	end
	return _warcraftDatas
end

function getAllAddtion( ... )
	local allGoalDatas = getAllGoalDatas()
	local addtion = 0
	for i = #allGoalDatas, 1, -1 do
		local goalData = allGoalDatas[i]
		if goalData.isReached == true then
			addtion = addtion + goalData.addtion
		end
	end
	return addtion * 0.0001
end

function initAffixes( ... )
	local affixes = {}
	_affixes = affixes
	if _usedWarcraftId ~= nil then
		local warcraftData = getWarcraftDatasMap()[_usedWarcraftId]
		local warcraftDB = parseDB(DB_Method.getDataById(_usedWarcraftId))
		if type(warcraftDB.attarr[1]) ~= "table" then
			warcraftDB.attarr = {warcraftDB.attarr}
		end

		for i = 1, #warcraftDB.attarr do
			local affixId = warcraftDB.attarr[i][2]
			local affixValue = warcraftDB.attarr[i][3] + warcraftDB.attarr[i][4] * (warcraftData.level - 1)
			affixes[warcraftDB.attarr[i][1]] = affixes[warcraftDB.attarr[i][1]] or {}
			affixes[warcraftDB.attarr[i][1]][affixId] = affixes[warcraftDB.attarr[i][1]][affixId] or 0
			affixes[warcraftDB.attarr[i][1]][affixId] = affixes[warcraftDB.attarr[i][1]][affixId] + math.floor(affixValue * (1 + getAllAddtion()))
		end
	end
end

function getAffixes(hid, isForce)
	if isForce then
		initAffixes()
	end
	local formationInfo = DataCache.getFormationInfo()
	for i = 1, 6 do
		local hidTemp = formationInfo[tostring(i - 1)]
		if hidTemp ~= nil and tonumber(hid) == tonumber(hidTemp) then
			return _affixes[i]
		end
	end
end


function friendIsOpened(index)
	local formationDB = parseDB(DB_Formation.getDataById(1))
	for i = 1, #formationDB.openFriendmetohdlevel do
		local data = formationDB.openFriendmetohdlevel[i]
		if data[1] == index then
			local warcraftCount = getWarcraftCountByLevel(data[3])
			local needLevel = nil
			for j = 1, #formationDB.openFriendByLv do
				if formationDB.openFriendByLv[j][2] == (index + 1) then
					needLevel = formationDB.openFriendByLv[j][1]
				end
			end
			local warcraftCountCondition = warcraftCount >= data[2]
			if needLevel ~= nil and needLevel <= UserModel.getHeroLevel() and warcraftCountCondition then
				return true, data[2], data[3], warcraftCountCondition
			else
				return false, data[2], data[3], warcraftCountCondition
			end
		end
	end
	return false
end

-- 是否已经开启第8个小伙伴
function isOpenEightFriend( ... )
	return friendIsOpened(7)
end


function getWarcraftDataByIndex( index )
	return getWarcraftDatasMap()[getWarcraftDatas()[index]]
end

function getWarcraftDataById(warcraftId)
	return getWarcraftDatasMap()[warcraftId]
end

function getFormationInfo( beginIndex, endIndex, formationInfo)
	local formationInfoTemp = table.hcopy(formationInfo, {})
	local hidTemp = formationInfoTemp[tostring(beginIndex - 1)]
	formationInfoTemp[tostring(beginIndex - 1)] = formationInfoTemp[tostring(endIndex - 1)]
	formationInfoTemp[tostring(endIndex - 1)] = hidTemp
	return formationInfoTemp
end

function getServersFormationInfo( formationInfo )
	local dict = CCDictionary:create()
	for i=0, 5 do
		local i_str = tostring(i)
		if(formationInfo[i_str]~=nil)then
			if (formationInfo[i_str] > 0) then
				dict:setObject(CCInteger:create(formationInfo[i_str]), i_str)
			end
		else
			if (formationInfo[tonumber(i_str)] > 0) then
				dict:setObject(CCInteger:create(formationInfo[tonumber(i_str)]), i_str)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(dict)
	return args
end

function setFormationInfo(beginIndex, endIndex, callback, tag)
	if beginIndex == endIndex then
		callback()
		return
	end
	_tagCopy = tag
	if tag == WarcraftLayer.SHOW_TAG_GOD_WEAPON then
		local formationInfo = getFormationInfo(beginIndex, endIndex, GodWeaponCopyData.getFormationInfo())
		local handleSetFormationInfo = function ()
			GodWeaponCopyData.setFormationInfo(formationInfo)
			if callback ~= nil then
				callback(beginIndex, endIndex)
			end
		end
		local data = GodWeaponCopyData.getCopyInfo()
		local otherPlayer = CCDictionary:create()
		for i=1, 2 do
            if data.va_pass.bench ~= nil and (data.va_pass.bench[i]~=nil)then
                if (tonumber(data.va_pass.bench[i]) > 0) then
                    otherPlayer:setObject(CCInteger:create(data.va_pass.bench[i]), i-1)
                end
            end
        end
		local args = getServersFormationInfo(formationInfo)
		args:addObject(otherPlayer)
		GodWeaponCopyService.changePosCommond(handleSetFormationInfo, args)
	elseif tag == WarcraftLayer.SHOW_TAG_DEFAULT then
		local formationInfo = getFormationInfo(beginIndex, endIndex, DataCache.getFormationInfo())
		local handleSetFormationInfo = function ( cbFlag, dictData, bRet )
			if dictData.err ~= "ok" then
				return
			end
			DataCache.setFormationInfo(formationInfo)
			if callback ~= nil then
				callback(beginIndex, endIndex)
			end
		end
		local args = getServersFormationInfo(formationInfo)
		RequestCenter.setFormationInfo(handleSetFormationInfo, args)
	end
end

function setCurWarcraft(warcraftId, callback)
	local handle = function ( dictData )
		setUsed(warcraftId)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandler(warcraftId)
	WarcraftService.setCurWarcraft(handle, args)
	-- handle()
end

function craftLevelup(warcraftId, callback)
	local handle = function ( dictData )
		local warcraftData = getWarcraftDataById(warcraftId)
		local costDB = getCostDB(warcraftData.level)
		UserModel.addSilverNumber(-costDB.costsilver)
		for k, v in pairs(costDB.costitems) do
			local itemId = v[1]
			local itemCount = v[2]
			ItemUtil.addItemCountByID(itemId, -itemCount)
		end
		warcraftData.level = warcraftData.level + 1
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandler(warcraftId)
	WarcraftService.craftLevelup(handle, args)
	-- handle()
end

function isUsed(warcraftId)
	if warcraftId == _usedWarcraftId then
		return true
	end
	return false
end

function getUsed( ... )
	return _usedWarcraftId
end


function getUsedWarcraftLevel( ... )
	if _usedWarcraftId == nil then
		return 0
	end
	return getWarcraftDatasMap()[_usedWarcraftId].level
end

function setUsed(warcraftId)
	_usedWarcraftId = warcraftId
	initAffixes()
end

function getAffixType(warcraftId)
	local warcraftDB = parseDB(DB_Method.getDataById(warcraftId))
	local affixType = {}
	if warcraftDB.frame ~= nil then
		if type(warcraftDB.frame[1]) ~= "table" then
			affixType[warcraftDB.frame[1]] = warcraftDB.frame[2]
		else
			for k, v in pairs(warcraftDB.frame) do
				affixType[v[1]] = v[2]
			end
		end
	end
	return affixType
end

function getAffixValue(warcraftId, level)
	local warcraftDB = parseDB(DB_Method.getDataById(warcraftId))
	local warcraftData = table.hcopy(getWarcraftDatasMap()[warcraftId], {})
	warcraftData.level = level or warcraftData.level
	local affixValue = {}
	if warcraftDB.frame ~= nil then
		if type(warcraftDB.attarr[1]) ~= "table" then
			affixValue[warcraftDB.attarr[1]] = math.floor((warcraftDB.attarr[3] + warcraftDB.attarr[4] * (warcraftData.level - 1)) * (1 + getAllAddtion()))
		else
			for k, v in pairs(warcraftDB.attarr) do
				if affixValue[v[1]] == nil then
					affixValue[v[1]] = math.floor((v[3] + v[4] * (warcraftData.level - 1)) * (1 + getAllAddtion()))
				end
			end
		end
	end
	return affixValue
end

function isMaxLevel(warcraftData)
	local normalConfigDB = DB_Normal_config.getDataById(1)
	if warcraftData.level >= normalConfigDB.methodtoplevel  then
		return true
	end
	return false
end

function getCostDB(level)
	local costInfo = parseDB(DB_Method_levelup.getDataById(level))
	if type(costInfo.costitems[1]) ~= "table" then
		costInfo.costitems = {costInfo.costitems}
	end
	return costInfo
end

-- 得到当前目标
function getCurGoalData( ... )
	local i = 1
	local methodAttexDB = nil
	repeat
		methodAttexDB = parseDB(DB_Method_attex.getDataById(i))
		if methodAttexDB ~= nil then
			local count = getWarcraftCountByLevel(methodAttexDB.needmetohdlevel[2])
			if count < methodAttexDB.needmetohdlevel[1] then
				return methodAttexDB
			end
		end
		i = i + 1
	until methodAttexDB == nil
	return nil
end

function getAllGoalDatas( ... )
	local allGoalDatas = {}
	local methodAttexDB = nil
	local i = 1
	repeat
		methodAttexDB = parseDB(DB_Method_attex.getDataById(i))
		if methodAttexDB ~= nil then
			local goalData = {}
			goalData.id = i
			goalData.level = methodAttexDB.needmetohdlevel[2]
			goalData.count = methodAttexDB.needmetohdlevel[1]
			goalData.addtion = methodAttexDB.allMetohdAttRatio
			local count = getWarcraftCountByLevel(methodAttexDB.needmetohdlevel[2])
			if count < methodAttexDB.needmetohdlevel[1] then
				goalData.isReached = false
			else
				goalData.isReached = true
			end
			table.insert(allGoalDatas, goalData)
		end
		i = i + 1
	until methodAttexDB == nil
	return allGoalDatas
end

function getUsedIndex( ... )
	local warcraftDatas = getWarcraftDatas()
	for i=1, #warcraftDatas do
		if warcraftDatas[i] == _usedWarcraftId then
			return i
		end
	end
	return nil
end

function getWarcraftInfo( ... )
	local handle = function( dictData )
		_warcraftInfo = {}
		_warcraftInfo.warcraft = {}
		if dictData.ret.craft_id ~= nil and tonumber(dictData.ret.craft_id) ~= 0 then
			_warcraftInfo.craft_id = tonumber(dictData.ret.craft_id)
		end

		for k, v in pairs(dictData.ret.warcraft) do
			v.level = tonumber(v.level)
			_warcraftInfo.warcraft[tonumber(k)] = v
		end
		setUsed(_warcraftInfo.craft_id)
	end
	WarcraftService.getWarcraftInfo(handle)
end


-- 达到指定等级的阵法数量
function getWarcraftCountByLevel(level)
	local count = 0
	for k, v in pairs(getWarcraftDatasMap()) do
		if v.level >= level then
			count = count + 1
		end
	end
	return count
end

