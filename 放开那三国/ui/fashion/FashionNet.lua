-- Filename：	FashionNet.lua
-- Author：		Li Pan
-- Date：		2014-2-11
-- Purpose：		时装

module("FashionNet", package.seeall)

require "script/ui/fashion/FashionData"

--穿时装
function dressFashion( uiCallBack ,hid)
	local function callback( flag,dictData,err )
		local ret = dictData.err
		if(ret ~= "ok") then
			return
		end
		FashionData.isSuccess = dictData.ret
		-- BossData.rebirthData = dictData.ret
		print("FashionData.isSuccess"..FashionData.isSuccess)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	args:addObject(CCString:create(tostring(hid)))

	Network.rpc(callback, "hero.addFashion", "hero.addFashion", args, true)
end

--脱时装
function offFashion( uiCallBack , hid)
	local function callback( flag,dictData,err )
		local ret = dictData.err
		if(ret ~= "ok") then
			return
		end
		FashionData.isSuccess = dictData.ret
		print("FashionData.isSuccess"..FashionData.isSuccess)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	-- args:addObject(CCString:create(tostring(1)))

	Network.rpc(callback, "hero.removeFashion", "hero.removeFashion", args, true)
end

