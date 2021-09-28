-- FileName: GodBatchFixService.lua 
-- Author: licong 
-- Date: 15/3/25 
-- Purpose: 神兵批量洗练接口 


module("GodBatchFixService", package.seeall)


-- /**
-- * 批量洗练
-- * @param $itemId int 物品id
-- * @param $type int 洗练类型0:普通洗练 1:金币洗练
-- * @param $index int 洗练第几层 从1开始
-- * @return array
-- * [
-- *  arrAttrId => array{attrId, ...} 洗出的属性数组
-- *  num => int 洗练次数
-- * ]
-- */
function batchWash(p_itemId, p_type, p_index,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if(bRet == true)then
			print("--------后端返回数据--batchWash-----------")
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
	Network.rpc(requestFunc,"godweapon.batchWash","godweapon.batchWash",args,true)
end

-- /**
-- * 批量洗练后，确认属性
-- * @param $itemId int 物品id
-- * @param $index int 替换第几层 从1开始
-- * @param $attrId int 属性id
-- * @return string ok
-- */  
function ensure(p_itemId, p_index, p_attrId,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if(bRet == true)then
			print("--------后端返回数据--ensure-----------")
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
	args:addObject(CCInteger:create(p_attrId))
	Network.rpc(requestFunc,"godweapon.ensure","godweapon.ensure",args,true)
end

-- /**
-- * 取消批量洗练的属性
-- * @param $itemId int 物品id
-- * @param $index int 层 从1开始
-- * @return string ok
-- */
function cancel(p_itemId, p_index,p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if(bRet == true)then
			print("--------后端返回数据--cancel-----------")
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
	Network.rpc(requestFunc,"godweapon.cancel","godweapon.cancel",args,true)
end
















