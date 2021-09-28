-- FileName: GodWeaponService.lua 
-- Author: licong 
-- Date: 14-12-18 
-- Purpose: 神兵后端接口文件 


module("GodWeaponService", package.seeall)

require "script/ui/godweapon/GodWeaponData"

-- /**
-- * 神兵强化
-- *
-- * @param $itemId int 神兵id
-- * @param $arrItemId array 材料数组
-- * @param $arrItemNum array 材料数组对应的数量
-- * <code>
-- *'$itemId'(物品id),
-- * </code>
-- * @return array
-- * <code>
-- *'reinForceLevel':int    强化等级
-- *'reinForceCost':int 本次强化费用
-- *'reinForceExp':int  当前总强化经验(炼化返还用)
-- * </code>
-- */
function reinForce(p_itemId, p_itemIdArr, p_itemNumArr, callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("reinForce---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_itemId)))
	local args2 = CCArray:create()
	for k,v in pairs(p_itemIdArr) do
		args2:addObject(CCInteger:create(tonumber(v)))
	end
	args:addObject(args2)
	local args3 = CCArray:create()
	for k,v in pairs(p_itemNumArr) do
		args3:addObject(CCInteger:create(tonumber(v)))
	end
	args:addObject(args3)
	Network.rpc(requestFunc, "godweapon.reinForce", "godweapon.reinForce", args, true)
end

--[[
	@des 	:神兵进化
	@param 	: $p_itemId 	: 神兵id
	@param 	: $p_consumeId 	: 消耗的神兵id
--]]
function evolve(p_itemId,p_consumeId,p_callBack)
	local consumeId = p_consumeId

	local requestFunc = function (cbFlag,dictData,bRet)
		if(dictData.err == "ok")then
			p_callBack(dictData.ret.evolveNum,dictData.ret.reinForceLevel,dictData.ret.reinForceExp)
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_itemId))
	local subArgs = CCArray:create()
	for i = 1,#consumeId do
		subArgs:addObject(CCInteger:create(consumeId[i]))
	end
	args:addObject(subArgs)
	Network.rpc(requestFunc, "godweapon.evolve", "godweapon.evolve",args,true)
end

--[[
	@des 	:卸下神兵
	@param 	: $p_hid 		: 英雄hid
	@param 	: $p_posId 		: 装备位置id
	@param 	: $p_callBack 	: 回调
--]]
function removeGodWeapon(p_hid,p_posId,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			p_callBack()
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_hid))
	args:addObject(CCInteger:create(p_posId))
	Network.rpc(requestFunc,"hero.removeGodWeapon","hero.removeGodWeapon",args,true)
end

--[[
	@des 	:得到神兵录信息
	@param 	:回调
--]]
function getGodWeaponBook(p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			GodWeaponData.setServiceBookInfo(dictData.ret)
			if p_callBack ~= nil then
				p_callBack()
			end
		end
	end
	Network.rpc(requestFunc,"iteminfo.getGodWeaponBook","iteminfo.getGodWeaponBook",nil,true)
end

--[[
	@des 	:神兵加锁
	@param 	:回调
--]]
function lock(p_itemId,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if p_callBack ~= nil then
				p_callBack(1)
			end
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_itemId))

	Network.rpc(requestFunc,"godweapon.lock","godweapon.lock",args,true)
end

--[[
	@des 	:神兵解锁
	@param 	:回调
--]]
function unLock(p_itemId,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if p_callBack ~= nil then
				p_callBack(0)
			end
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_itemId))
	
	Network.rpc(requestFunc,"godweapon.unLock","godweapon.unLock",args,true)
end