-- Filename:	CopyService.lua
-- Author:		chengliang
-- Date: 		2015-02-05
-- Purpose: 	副本网络层

module("CopyService", package.seeall)

-- 拉取副本列表
function ncopyGetCopyList(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "ncopy.getCopyList", "ncopy.getCopyList", nil, true)
end

-- 拉取副本列表  -- 无loadingUI的
function ncopyGetCopyList_noLoading()
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			DataCache.setNormalCopyData( dictData.ret )
		end
	end
	Network.no_loading_rpc(requestFunc, "ncopy.getCopyList", "ncopy.getCopyList", nil, true)
end

--注册新副本推送
function registerNewCopyPush()
	local requestFunc = function (cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			require "script/battle/BattleLayer"
			if(not table.isEmpty(dictData.ret) and (not BattleLayer.isBattleOnGoing) )then
				local copyId = 0
				for k,v in pairs(dictData.ret) do
					if(tonumber(v.copy_id) > copyId) then
						copyId = tonumber(v.copy_id)
					end
				end
				ShowNewCopyLayer.showNewCopy(copyId)
				-- added by zhz ,台湾炫耀系统
				-- require "script/ui/showOff/ShowOffUtil"
				-- ShowOffUtil.sendShowOffByType(4 ,copyId )
			end
		end
	end
	Network.re_rpc(requestFunc, "push.copy.newcopy", "push.copy.newcopy")
end