-- FileName: HeroTurnedService.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统网络接口

module("HeroTurnedService", package.seeall)

--[[
	@desc 	: 获得所有的武将 幻化图鉴
	@param 	: pCallback 请求回调
	@return : 
	/**
	 * 获得所有的幻化列表，图鉴
	 * @return array
	 * <code>
	 * array
	 * (
	 * 		$baseHtid => array(turnedId,......)
	 * 		......
	 * )
	 * </code>
	 */
	public function getAllTurnInfo();
--]]
function getAllTurnInfo( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"heroturned.getAllTurnInfo","heroturned.getAllTurnInfo",nil,true)
end

--[[
	@desc 	: 获取武将可幻化列表
	@param 	: pCallback 请求回调
	@param 	: pHid 武将Id
	@return : 
	/**
	 * 获取武将可幻化列表
	 * @param int $hid
	 * @return array
	 * <code>
	 * array(turnedId,......)
	 * </code>
	 */
	public function getTurnInfoByHid($hid);
--]]
function getTurnInfoByHid( pCallback, pHid )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pHid })
	Network.rpc(requestFunc,"heroturned.getTurnInfoByHid","heroturned.getTurnInfoByHid",args,true)
end

--[[
	@desc	: 幻化武将
    @param	: pCallback 请求回调
    @param	: pHid 武将Id
    @param	: pTurnId 幻化Id
    @return	: 
    /**
	 * 幻化
	 * @param int $hid 武将id
	 * @param int $turnedId 幻化id
	 * @return string 'ok' or 'err'
	 */
	public function heroTruned($hid, $turnedId);
—-]]
function heroTruned( pCallback, pHid, pTurnId )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pHid,pTurnId })
	Network.rpc(requestFunc,"heroturned.heroTruned","heroturned.heroTruned",args,true)
end

