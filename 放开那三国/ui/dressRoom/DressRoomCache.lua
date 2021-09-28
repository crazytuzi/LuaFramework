-- Filename：	DressRoomCache.lua
-- Author：		bzx
-- Date：		2014-11-04
-- Purpose：		时装屋数据

module("DressRoomCache", package.seeall)

require "script/network/RequestCenter"
require "db/DB_Item_dress"
require "script/model/user/UserModel"

GET = "1"
NOT_GET = "0"

ACTIVED = "1"
NOT_ACTIVED = "0"


local _dressInfo = nil
local _dressDatas = nil
local _extenseAffixes = nil

function getInfo()
	return _dressInfo
end

function handleGetDressRoomInfo(cbFlag, dictData, bRet)
	if dictData.err ~= "ok" then
		return
	end
	_dressInfo = dictData.ret
	_dressInfo.cur_dress = tonumber(_dressInfo.cur_dress)
	getExtenseAffixes(true)
	if callback ~= nil then
		callback()
	end
end

function changeDress(dressID, callback)
	local handleChangeDress = function (cbFlag, dictData, bRet)
		if dictData.err ~= "ok" then
			return
		end
		_dressInfo.cur_dress = dressID
		UserModel.setDressIdByPos(1, dressID)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandler(dressID)
	RequestCenter.dressRoomChangeDress(handleChangeDress, args)
end

function setCurDress( dressID )
	dressID = tonumber(dressID)
	_dressInfo.cur_dress = dressID
	UserModel.setDressIdByPos(1, dressID)
end


function activeDress(dressID, callback)
	local handleActiveDress = function (cbFlag, dictData, bRet)
		if dictData.err ~= "ok" then
			return
		end
		for i = 1, #_dressDatas do
			if _dressDatas[i].id == dressID then
				_dressDatas[i].as = ACTIVED
			end
		end
		getExtenseAffixes(true)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandler(dressID)
	RequestCenter.dressRoomActiveDress(handleActiveDress, args)
	-- for i = 1, #_dressDatas do
	-- 	if _dressDatas[i].id == dressID then
	-- 		_dressDatas[i].as = ACTIVED
	-- 	end
	-- end
	-- 	if callback ~= nil then
	-- 		callback()
	-- end
end

function getDressDatas( ... )
	if _dressDatas == nil then
		_dressDatas = {}
		require "db/DB_Normal_config"
		local normalConfig = parseDB(DB_Normal_config.getDataById(1))
		for i = 1, #normalConfig.dressID  do
			local dressData = {}
			local dressId = normalConfig.dressID[i]
			dressData.id = dressId
			_dressInfo = _dressInfo or {}
			_dressInfo.arr_dress = _dressInfo.arr_dress or {}
			local dressInfo = _dressInfo.arr_dress[tostring(dressId)]
			if dressInfo ~= nil then
				dressData.as = dressInfo.as or NOT_ACTIVED
				dressData.gs = GET
			else
				dressData.gs = NOT_GET
				dressData.as = NOT_ACTIVED
			end
			table.insert(_dressDatas, dressData)
		end
	end
	return _dressDatas
end

function getExtenseAffixes(isForce)
	if not isForce then
		return _extenseAffixes
	end 
	_extenseAffixes = {}
	local dressDatas = getDressDatas()
	for i = 1, #dressDatas do
		local dressData = dressDatas[i]
		if dressData.as == ACTIVED then
			local dressDB = parseDB(DB_Item_dress.getDataById(dressData.id))
			if dressDB.additionalAffix ~= nil then
				for j=1, #dressDB.additionalAffix do
					local affix = dressDB.additionalAffix[j]
					_extenseAffixes[affix[1]] = _extenseAffixes[affix[1]] or 0
					_extenseAffixes[affix[1]] = _extenseAffixes[affix[1]] + affix[2]
				end
			end
		end
	end
	return _extenseAffixes
end

function getWearDressId()
	return _dressInfo.cur_dress
end

function addNewDress(id)
	print("addNewDress()", id)
	if(id == nil)then
		return
	end
	local dressDatas = getDressDatas()
	for i=1, #dressDatas do
		local dressData = dressDatas[i]
		if dressData.id == tonumber(id) then
			dressData.gs = GET
		end
	end
end
