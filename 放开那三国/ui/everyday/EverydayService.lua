-- FileName: EverydayService.lua 
-- Author: Li Cong 
-- Date: 14-3-18 
-- Purpose: function description of module 


module("EverydayService", package.seeall)

require "script/ui/everyday/EverydayData"

-- 得到每日任务数据
-- * @return array 活跃度信息
-- * <code>
-- * {
-- * 		'point':int			总积分
-- * 		'va_active':
-- * 		{
-- * 			'step':int		配置表id
-- * 			'task'
-- * 			{
-- * 				$id => $num 任务id对应完成次数
-- * 			}
-- * 			'prize'
-- * 			{
-- * 				$id			领取过的奖励id
-- * 			}
-- * 			'taskReward'
-- * 			{
-- * 				$taskId			领取过任务奖励的任务id
-- * 			}
-- * 		}
-- * }
-- * </code>
-- */
-- callbackFunc:回调
function getActiveInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getActiveInfo---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			EverydayData.setEverydayInfo(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "active.getActiveInfo", "active.getActiveInfo", nil, true)
end


-- 领取箱子
-- callbackFunc:回调
function getPrize( id, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getPrize---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				-- 修改领取的数据
				EverydayData.addGetBoxId(id)
				-- 回调
				if(callbackFunc)then
					callbackFunc()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(id)))
	Network.rpc(requestFunc, "active.getPrize", "active.getPrize", args, true)
end


-- /**
--  * 奖励升级
--  * @return string $ret		结果
--  * 'ok' 					领取成功
--  * 'err'					领取失败
--  */
function upgrade(callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getActiveInfo---后端数据")
		if(dictData.err == "ok")then
			print_t(dictData.ret)
			if(dictData.ret == "ok")then
				-- 回调
				if(callbackFunc)then
					callbackFunc()
				end
			elseif(dictData.ret == "remainingReward")then
				AnimationTip.showTip(GetLocalizeStringBy("lic_1789"))
			end
		end
	end
	Network.rpc(requestFunc, "active.upgrade", "active.upgrade", nil, true)
end

-- /**
--  * 领取每个任务对应的奖励
--  * @param int $taskId		任务id
--  */
function getTaskPrize( p_taskId, p_callBack )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			if(dictData.ret == "ok")then
				-- 回调
				if(p_callBack)then
					p_callBack()
				end
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_taskId })
	Network.rpc(requestFunc, "active.getTaskPrize", "active.getTaskPrize", args, true)
end





