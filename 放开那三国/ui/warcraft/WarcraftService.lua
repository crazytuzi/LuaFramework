-- Filename: WarcraftService.lua
-- Author: bzx
-- Date: 2014-11-20
-- Purpose: 阵法网络请求

module("WarcraftService", package.seeall)

-- 启用阵法
function setCurWarcraft( cbFunc,params )
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		if cbFunc ~= nil then
			cbFunc(dictData)
		end
	end
	Network.rpc(handle, "formation.setCurWarcraft", "formation.setCurWarcraft", params, true)
end

-- 升级阵法
function craftLevelup(cbFunc, params )
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		if cbFunc ~= nil then
			cbFunc(dictData)
		end
	end
	Network.rpc(handle, "formation.craftLevelup", "formation.craftLevelup", params, true)
end

-- 得到阵法信息
function getWarcraftInfo( cbFunc, params )
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		if cbFunc ~= nil then
			cbFunc(dictData)
		end
	end
	Network.rpc(handle, "formation.getWarcraftInfo", "formation.getWarcraftInfo", params, true)
end