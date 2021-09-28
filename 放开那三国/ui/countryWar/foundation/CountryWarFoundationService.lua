-- FileName : CountryWarFoundationService.lua
-- Author   : YangRui
-- Date     : 2015-11-23
-- Purpose  : 

module("CountryWarFoundationService", package.seeall)

-- /**
--  * 划出一部分钱来给国战用
--  * @param int $amount 划出的数量
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret:string									ok|fail|poor|limit,成功|失败|数值不足|已达上限
--  * }
--  * 
--  * </code>
--  * 
--  */
-- public function exchangeCocoin( $amount );//TODO 订单系统，（游乐场）
function exchangeCocoin( pNum, pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pNum})
	Network.rpc(requestFunc,"countrywarinner.exchangeCocoin","countrywarinner.exchangeCocoin",args)
end