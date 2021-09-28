-- Filename：	DevelopService.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-9
-- Purpose：		武将进化网络层

module ("DevelopService", package.seeall)

--[[
	武将进化
	return: 'ok'
	access: public
	string develop (int $hid, array $arrHero, array $arrItem)
	int $hid
	array $arrHero: [ hid ]
	array $arrItem: [ itemId=>itemNum ]
	@des 	:	橙卡进化
	@param 	:
	@return :
--]]
function startDevelopOrange( p_hid , p_hidArr, p_itemArr, p_funcCb)
	local callBackFunc = function ( p_cbFlag, p_retData, p_bRet )
		if p_bRet == true then
			if p_funcCb ~= nil then
				p_funcCb()
			end
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_hid))

	local hidArr = CCArray:create()
	for k,v in ipairs(p_hidArr) do
		hidArr:addObject(CCInteger:create(v))
	end
	args:addObject(hidArr)

	local itemDict = CCDictionary:create()
	for k,v in ipairs(p_itemArr) do
		itemDict:setObject(CCInteger:create(v.itemNum), v.itemId)
	end
	args:addObject(itemDict)

	Network.rpc(callBackFunc, "hero.develop2red", "hero.develop2red", args, true)
end
--[[
	武将进化
	return: 'ok'
	access: public
	string develop (int $hid, array $arrHero, array $arrItem)
	int $hid
	array $arrHero: [ hid ]
	array $arrItem: [ itemId=>itemNum ]
	@des 	:	紫卡进化
	@param 	:
	@return :
--]]
function startDevelopPurple( p_hid , p_hidArr, p_itemArr, p_funcCb)
	local callBackFunc = function ( p_cbFlag, p_retData, p_bRet )
		if p_bRet == true then
			if p_funcCb ~= nil then
				p_funcCb()
			end
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_hid))

	local hidArr = CCArray:create()
	for k,v in ipairs(p_hidArr) do
		hidArr:addObject(CCInteger:create(v))
	end
	args:addObject(hidArr)

	local itemDict = CCDictionary:create()
	for k,v in ipairs(p_itemArr) do
		itemDict:setObject(CCInteger:create(v.itemNum), v.itemId)
	end
	args:addObject(itemDict)

	Network.rpc(callBackFunc, "hero.develop", "hero.develop", args, true)
end
-- function develop(p_hid, p_arrHeros, p_items, p_callbackFunc)
-- 	local requestFunc = function( cbFlag, dictData, bRet )
-- 		if(dictData.err == "ok") then
-- 			if(p_callbackFunc ~= nil) then
-- 				p_callbackFunc()
-- 			end
-- 		end
-- 	end
-- 	local args = CCArray:create()
-- 	args:addObject(CCInteger:create(p_hid))
-- 	local heroArray = CCArray:create()
-- 	for k,v in pairs(p_arrHeros) do
-- 		heroArray:addObject(CCInteger:create(v))
-- 	end
-- 	local itemArray = CCArray:create()
-- 	for k,v in pairs(p_items) do
-- 		itemArray:addObject(CCInteger:create(v))
-- 	end
-- 	Network.rpc(requestFunc, "hero.develop", "hero.develop", nil, true)
-- end
