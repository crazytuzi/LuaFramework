-- FileName: LittleFriendService.lua 
-- Author: Li Cong 
-- Date: 13-12-2 
-- Purpose: function description of module 

require "script/ui/formation/LittleFriendData"
module("LittleFriendService", package.seeall)


--[[
	@des 	:拉取玩家所有小伙伴信息
	@param 	:callbackFunc 完成回调方法
	@return :
--]]
function getLittleFriendInfoService( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getLittleFriendInfoService---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 小伙伴数据
			LittleFriendData.setLittleFriendeData( dataRet ) 
			if( callbackFunc ~= nil)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "formation.getExtra", "formation.getExtra", nil, true)
end


--[[
	@des 	:添加小伙伴
	@param 	:hid:要添加英雄hid, position:要添加的位置, callbackFunc 完成回调方法
	@return :
--]]
function addLittleFriendService( hid, position, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				-- 更新小伙伴阵容信息
				LittleFriendData.setLittleFriendDataByPos(position,hid)
				-- 成功回调
				if( callbackFunc ~= nil)then
					callbackFunc( position )
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(hid))
	args:addObject(CCInteger:create(tonumber(position)-1))
	Network.rpc(requestFunc, "formation.addExtra", "formation.addExtra", args, true)
end



--[[
	@des 	:卸下小伙伴
	@param 	:hid:要卸下英雄hid, position:要卸下的位置, callbackFunc 完成回调方法
	@return :
--]]
function delLittleFriendService( hid, position, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				-- 更新小伙伴阵容信息
				LittleFriendData.setLittleFriendDataByPos(position,0)
				-- 成功回调
				if( callbackFunc ~= nil)then
					callbackFunc( position )
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(hid))
	args:addObject(CCInteger:create(tonumber(position)-1))
	Network.rpc(requestFunc, "formation.delExtra", "formation.delExtra", args, true)
end


--[[
	@des 	:购买位置
	@param 	:position:要购买的位置, callbackFunc 完成回调方法
	@return :
--]]
function openExtra( position, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				-- 更新小伙伴阵容信息
				LittleFriendData.setLittleFriendDataByPos(position,0)
				-- 成功回调
				if( callbackFunc ~= nil)then
					callbackFunc( position )
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(position)-1))
	Network.rpc(requestFunc, "formation.openExtra", "formation.openExtra", args, true)
end





