-- FileName: SecondFriendService.lua 
-- Author: licong 
-- Date: 15-3-3 
-- Purpose: 第二套小伙伴网络接口


module("SecondFriendService", package.seeall)

require "script/ui/formation/secondfriend/SecondFriendData"

-- /**
--  * 返回属性小伙伴信息
--  *
--  * @return array
--  * [
--  * 		0:hid -1未开，0开了，N武将id
--  * 		1:hid
--  * 		2:hid
--  * ]
--  */
function getAttrExtra(p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if(bRet == true)then
			print ("getAttrExtra---后端数据")
			print_t(dictData.ret)
			-- 缓存信息
			SecondFriendData.setSecondFriendInfo(dictData.ret)
			if p_callBack ~= nil then
				p_callBack()
			end
		end
	end
	Network.rpc(requestFunc,"formation.getAttrExtra","formation.getAttrExtra",nil,true)
end

-- /**
--  * 加属性小伙伴
--  *
--  * @param int $hid
--  * @param int $index
--  * @return string 'ok'
--  */
function addAttrExtra(p_hid, p_index, p_callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true)then
			print ("addAttrExtra---后端数据")
			print_t(dictData.ret)
			if( dictData.ret == "ok")then
				-- 修改缓存数据 
				SecondFriendData.setPosHid( p_index, p_hid )
				if( p_callBack ~= nil)then
					p_callBack(p_index)
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_hid))
	args:addObject(CCInteger:create(tonumber(p_index)-1))
	Network.rpc(requestFunc, "formation.addAttrExtra", "formation.addAttrExtra", args, true)
end

-- /**
--  * 减属性小伙伴
--  *
--  * @param int $hid
--  * @param int $index
--  * @return string 'ok'
--  */
function delAttrExtra(p_hid, p_index, p_callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true)then
			print ("delAttrExtra---后端数据")
			print_t(dictData.ret)
			if( dictData.ret == "ok")then
				-- 修改缓存数据 该位置上置为0
				SecondFriendData.setPosHid( p_index, 0 )
				if( p_callBack ~= nil)then
					p_callBack()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_hid))
	args:addObject(CCInteger:create(tonumber(p_index)-1))
	Network.rpc(requestFunc, "formation.delAttrExtra", "formation.delAttrExtra", args, true)
end

-- /**
--  * 开属性小伙伴位置
--  *
--  * @param int $index 位置下标从0开始
--  * @return string 'ok'
-- */
function openAttrExtra(p_index, p_callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true)then
			print ("openAttrExtra---后端数据")
			print_t(dictData.ret)
			if( dictData.ret == "ok")then
				-- 修改缓存数据 0 开启
				SecondFriendData.setPosHid( p_index, 0 )

				if( p_callBack ~= nil)then
					p_callBack()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_index)-1))
	Network.rpc(requestFunc, "formation.openAttrExtra", "formation.openAttrExtra", args, true)
end








































