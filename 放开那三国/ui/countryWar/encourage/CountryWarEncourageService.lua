-- FileName: CountryWarEncourageService.lua
-- Author: yangrui
-- Date: 2015-11-18
-- Purpose: 国战鼓舞

module("CountryWarEncourageService", package.seeall)

-- /**
--  * 鼓舞
--  * @param 鼓舞类型 $type					1|2|3|4|5|6,金攻击|银攻击|金防御|银防御|金血|银血
--  * 
--  * <code>
--  * 
--  * @return
--  * {
--  * 		ret=>string					
--  * }
--  * 
--  * </code>
--  * 
-- */
-- public function inspire($type);
function inspire( pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpcCountry(requestFunc,"countrywarcross.inspire","countrywarcross.inspire",nil)
end

-- /**
--  * 清除达阵后的cd
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret:string						ok|fail|poor|limit|cooled,成功|失败|数值不足|已达上限|已经过了冷却时间 
--  * }
--  * 
--  * </code>
--  * 
-- */
-- public function clearJoinCd();
function clearJoinCd( pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpcCountry(requestFunc,"countrywarcross.clearJoinCd","countrywarcross.clearJoinCd",nil)
end

-- /**
--  * 手动回血
--  *
--  *<code>
--  *
--  * @return
--  * {
--  * 		ret:string						ok|fail|poor,成功|失败|数值不足
--  *
--  * }
--  * 
--  *</code>
--  * 
-- */
-- public function recoverByUser();
function recoverByUser( pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpcCountry(requestFunc,"countrywarcross.recoverByUser","countrywarcross.recoverByUser",nil)
end

-- /**
--  * 手动设置恢复参数
--  * @param int $percent				3000 表示30%
--  * 
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret:string						ok|fail|poor,成功|失败|数值不足
--  * }
--  * 
--  * </code>
--  * 
--  */
-- public function setRecoverPara( $percent );
function setRecoverPara( percent, pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({percent})
	Network.rpcCountry(requestFunc,"countrywarcross.setRecoverPara","countrywarcross.setRecoverPara",args)
end

-- /**
--  * 自动回血开关
--  * @return int 1 开 2关
--  * @return
--  *
--  * <code>
--  *
--  * {
--  * 		ret:string						ok|fail|poor,成功|失败|数值不足
--  * }
--  *
--  * </code>
--  *
--  */
-- public function turnAutoRecover( $onOrOff );
function turnAutoRecover( onOrOff, pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({onOrOff})
	Network.rpcCountry(requestFunc,"countrywarcross.turnAutoRecover","countrywarcross.turnAutoRecover",args)
end
