-- FileName: HuntSoulService.lua 
-- Author: Li Cong 
-- Date: 14-2-11 
-- Purpose: function description of module 


module("HuntSoulService", package.seeall)
require "script/ui/huntSoul/HuntSoulData"
require "script/model/user/UserModel"

-- 得到猎魂数据
-- callbackFunc:回调
function getHuntInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getHuntInfo---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 设置当前场景
			HuntSoulData.setHuntPlaceId(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "hunt.getHuntInfo", "hunt.getHuntInfo", nil, true)
end


-- 召唤神龙
-- type:类型:0物品,1金币,默认值0
-- callbackFunc:回调
function skip( type, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("skip---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 设置当前场景
			HuntSoulData.setHuntPlaceId(dataRet.place)
			-- 回调
			if(callbackFunc)then
				callbackFunc( dataRet.item,  dataRet.extra)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(type))
	Network.rpc(requestFunc, "hunt.skip", "hunt.skip", args, true)
end


-- /**
-- * 猎魂
-- * 
-- * @param int $num 次数：默认值1
-- * @return array
-- * <code>
-- * {
-- * 		'item':战魂数组
-- * 		{
-- * 			$itemId => $itemTplId
-- * 		}
-- * 		'material':材料
-- * 		{
-- * 			$itemTplId => $num
-- * 		}
-- * 		'place':下一个场景id
-- * 		'silver':花费银币
-- * 		'white':白色战魂个数
-- * 		'green':绿色战魂个数
-- * 		'blue':蓝色战魂个数
-- * 		'purple':紫色战魂个数
-- * 		'exp':经验
-- * }
-- * </code>
-- */
-- 	public function huntSoul($num = 1);
function huntSoul( num, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			print ("huntSoul---后端数据")
			print_t(dictData.ret)
			-- 设置当前场景
			HuntSoulData.setHuntPlaceId(dictData.ret.place)
			-- 扣除花费的银币
			UserModel.addSilverNumber(-tonumber(dictData.ret.silver))
			-- 回调
			if(callbackFunc)then
				callbackFunc( dictData.ret.item, dictData.ret.white, dictData.ret.green, dictData.ret.blue, dictData.ret.purple, dictData.ret.exp, dictData.ret.silver, dictData.ret.material )
			end

		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(num))
	Network.rpc(requestFunc, "hunt.huntSoul", "hunt.huntSoul", args, true)
end


-- 升级战魂
-- itemId: 目标id
-- itemIds:被吃掉的战魂
-- callbackFunc:回调
function promote( itemId, itemIds, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("promote---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 回调
			if(callbackFunc)then
				callbackFunc(dataRet.va_item_text.fsLevel,dataRet.va_item_text.fsExp,dataRet.item_id)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(itemId))
	local idArray = CCArray:create()
	print("----itemIds---")
	for k,v in pairs(itemIds) do
		print(k,v)
		idArray:addObject(CCInteger:create(v))
	end
	args:addObject(idArray)
	Network.rpc(requestFunc, "forge.promote", "forge.promote", args, true)
end



-- /**
-- * 跳转猎魂
-- * 
-- * @param int $num 次数：默认值10
-- * @return array
-- * <code>
-- * {
-- * 		'item':战魂数组
-- * 		{
-- * 			$id 第N次
-- * 			{
-- * 				$itemId => $itemTplId
-- * 			}
-- * 		}
-- * 		'material':材料
-- * 		{
-- * 			$itemTplId => $num
-- * 		}
-- * 		'extra':额外掉落
-- * 		{
-- * 			$itemTplId => $num
-- * 		}
-- * 		'place':下一个场景id
-- * 		'silver':花费银币
-- * }
-- * </code>
-- */
-- public function skipHunt($num = 10);
function skipHunt( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			print ("skipHunt---后端数据")
			print_t(dictData.ret)
			-- 设置当前场景
			HuntSoulData.setHuntPlaceId(dictData.ret.place)
			-- 扣除花费的银币
			UserModel.addSilverNumber(-tonumber(dictData.ret.silver))
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret.item, dictData.ret.extra, dictData.ret.material)
			end
		end
	end
	-- 参数
	-- local args = CCArray:create()
	-- args:addObject(CCInteger:create(p_num))
	Network.rpc(requestFunc, "hunt.skipHunt", "hunt.skipHunt", args, true)
end


-- /**
-- * 极速猎魂
-- * 
-- * @param int $type 类型1,2,3
-- * @param array $quality 保留的品质，默认0不保留
-- * @return array
-- * <code>
-- * {
-- * 		'item':战魂数组
-- * 		{
-- * 			$itemId => $itemTplId
-- * 		}
-- * 		'material':材料
-- * 		{
-- * 			$itemTplId => $num
-- * 		}
-- * 		'place':下一个场景id
-- * 		'silver':花费银币
-- * 		'fs_exp':战魂经验
-- * }
-- * </code>
-- */
function rapidHunt(p_type, p_qualityArr,p_callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			print ("rapidHunt---后端数据")
			print_t(dictData.ret)
			-- 设置当前场景
			HuntSoulData.setHuntPlaceId(dictData.ret.place)
			-- 扣除花费的银币
			UserModel.addSilverNumber(-tonumber(dictData.ret.silver))
			-- 加经验战魂
			UserModel.addFSExpNum(tonumber(dictData.ret.fs_exp))
			-- 回调
			if(p_callbackFunc)then
				p_callbackFunc( dictData.ret.item, dictData.ret.fs_exp, dictData.ret.silver, dictData.ret.material )
			end
		end
	end
	-- 参数
	local args = Network.argsHandlerOfTable({ p_type, p_qualityArr })
	Network.rpc(requestFunc, "hunt.rapidHunt", "hunt.rapidHunt", args, true)
end



-- /**
-- * 经验升级战魂
-- * 
-- * @param int $itemId 			物品id
-- * @param int $addLevel			增加等级
-- * @return array
-- * <code>
-- * {
-- * 		item_id:int				物品ID
-- * 		item_template_id:int	物品模板ID
-- * 		item_num:int			物品数量
-- * 		item_time:int			物品产生时间
-- * 		va_item_text:			物品扩展信息
-- * 		{
-- * 			fsLevel:int	当前等级
-- * 			fsExp:int	总经验值
-- * 		}
-- * 		'fs_exp':吃掉的战魂经验
-- * }
-- */
function promoteByExp(p_itemId, p_addLevel, p_callbackFunc)

	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			print ("promoteByExp---后端数据")
			print_t(dictData.ret)
			
			-- 回调
			if(p_callbackFunc)then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	-- 参数
	local args = Network.argsHandlerOfTable({ tostring(tonumber(p_itemId)), p_addLevel })
	Network.rpc(requestFunc, "forge.promoteByExp", "forge.promoteByExp", args, true)
end


-- /**
-- * 战魂重生
-- * @param array $arrItemId
-- * @return array
-- * <code>
-- * [
-- *     silver:int
-- *     fs_exp:int
-- *     item:array
-- *         [
-- *             item_template_id=>num
-- *         ]
-- * ]
-- * </code>
-- */
function rebornFightSoul(p_itemId,p_callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			print ("rebornFightSoul---后端数据")
			print_t(dictData.ret)
			
			-- 回调
			if(p_callbackFunc)then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	-- 参数
	local args = Network.argsHandlerOfTable({ {tostring(tonumber(p_itemId))} })
	Network.rpc(requestFunc, "mysteryshop.rebornFightSoul", "mysteryshop.rebornFightSoul", args, true)
end







