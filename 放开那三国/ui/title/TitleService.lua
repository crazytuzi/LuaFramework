-- Filename: TitleService.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号系统网络接口

module("TitleService", package.seeall)

--[[
	@desc 	: 获取玩家称号信息
	@param 	: pCallback 回调方法
	@return : 
	/**
	 * 获取称号信息
	 * 
	 * @return array
	 * <code>
	 * {
	 * 		'title'
	 * 		{
	 * 			$id => $deadline 激活的称号id=>截止时间，截止时间为0表示非限时称号
	 * 		}
	 * }
	 * </code>
	 */
	 public function getStylishInfo();
--]]
function getStylishInfo( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"stylish.getStylishInfo","stylish.getStylishInfo",nil,true)
end

--[[
	@desc 	: 玩家装备称号
	@param 	: pTitleId 称号ID
	@return : 
	/**
	 * 设置称号
	 * @param int $id 称号id
	 * @return string 'ok'
	 */
	 public function setTitle($id);
--]]
function setTitle( pCallback, pTitleId )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pTitleId })
	Network.rpc(requestFunc,"stylish.setTitle","stylish.setTitle",args,true)
end

--[[
	@desc 	: 玩家激活(使用)称号
	@param 	: pTitleId 称号ID pItemId 消耗物品ID pItemNum 消耗物品数量
	@return : 
	/**
	 * 激活称号
	 * @param int $id 称号id
	 * @param int $itemId 消耗物品id
	 * @param int $itemNum 消耗的物品数量
	 * @return string 'ok'
	 */
	public function activeTitle($id, $itemId, $itemNum);
--]]
function activeTitle( pCallback, pTitleId, pItemId, pItemNum )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pTitleId, pItemId, pItemNum })
	Network.rpc(requestFunc,"stylish.activeTitle","stylish.activeTitle",args,true)
end