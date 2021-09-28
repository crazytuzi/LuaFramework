-- FileName: GodWeaponFixService.lua 
-- Author: licong 
-- Date: 15-1-13 
-- Purpose: 神兵洗练网络接口 


module("GodWeaponFixService", package.seeall)

-- /**
-- * 神兵洗练
-- * @param $itemId int 物品id
-- * @param $type int 洗练类型0:普通洗练 1:金币洗练
-- * @param $index int 洗练第几层 从1开始
-- * @return mixed
-- */
-- public function wash($itemId, $type, $index);
function wash(p_itemId,p_type,p_index,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--wash-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_itemId))
	args:addObject(CCInteger:create(p_type))
	args:addObject(CCInteger:create(p_index))
	Network.rpc(requestFunc,"godweapon.wash","godweapon.wash",args,true)
end


-- /**
-- * 替换洗练属性
-- * @param $itemId int 物品id
-- * @param $index int 替换第几层 从1开始
-- * @return mixed
-- */
-- public function replace($itemId, $index);
function replace(p_itemId,p_index,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--replace-----------")
			print_t(dictData)
			if(dictData.ret == "ok")then
				if(p_callBack ~= nil)then
					p_callBack()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_itemId))
	args:addObject(CCInteger:create(p_index))
	Network.rpc(requestFunc,"godweapon.replace","godweapon.replace",args,true)
end












