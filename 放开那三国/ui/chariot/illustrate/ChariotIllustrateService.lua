-- FileName: ChariotIllustrateService.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车图鉴网络接口

module("ChariotIllustrateService", package.seeall)

--[[
	@desc   : 获得战车图鉴信息
    @param  : pUid 玩家uid
    @return : 
    /**
	 * 获得战车图鉴 iteminfo模块
	 *
	 * @param int $uid  用户id，默认为0是当前用户
	 * @return array
	 * <code>
	 * {
	 *     itemTplId:int	战车模板id
	 * }
	 * </code>
	 */
--]]
function getChariotBook( pCallback, pUid )
	local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pUid })
	Network.rpc(requestFunc,"iteminfo.getChariotBook","iteminfo.getChariotBook",args,true)
	-- 测试数据
	-- local testData = {}
	-- testData.err = "ok"
	-- local retTab = {}
	-- retTab[920101] = 1466524800	
	-- testData.ret = retTab
	-- requestFunc(nil,testData,true)
end
