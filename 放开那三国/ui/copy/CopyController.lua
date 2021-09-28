-- Filename：	CopyController.lua
-- Author：		shengyixian
-- Date：		2015-12-29
-- Purpose：		副本控制层

module("CopyController", package.seeall)

--[[
	@des 	: 精英副本扫荡
	@param 	: pCopyID:副本ID
	@return : 
--]]
function sweep( pCopyID,pCallback )
	local num = DataCache.getCanDefatNum()
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			DataCache.addCanDefatNum(-num)
			CopyLayer.updateAfterSweep()
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pCopyID,num })
	RequestCenter.ecopy_sweep(requestFunc,args)
end

