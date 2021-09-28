-- Filename: MissionService.lua
-- Author: lichenyang
-- Date: 2014-6-10
-- Purpose: 军团任务网络层

module("MissionService", package.seeall)

require "script/ui/battlemission/MissionData"
require "script/ui/item/ItemUtil"
require "script/ui/guild/GuildDataCache"
-- /**
--  * 当前任务的信息
--  * @return
--  * 
--  * 'task_num' => int, 今天已经完成任务的数量
--  * 'forgive_time' => int,放弃任务的时间
--  * 'ref_num' => int, 刷新任务的次数
--  * 'task' => array
--  * 		(
--  * 			0 => array( 'id' => int, 'status' => int, 'num' => int, ),
--  * 			1...
--  * 			2...
--  * 		)
--  */
function getTaskInfo( p_callbackFunc )
    if not MissionData.isGuildMissonOpen() then
        return
    end
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			MissionData.setTaskInfo(dictData.ret )
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(cbFlag, dictData, bRet)
			end
		end
	end
	Network.rpc(requestFunc, "guildtask.getTaskInfo", "guildtask.getTaskInfo", nil, true)
end

--刷新后的任务信息
function refTask(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			UserModel.addGoldNumber(-MissionData.getRfcGold()) 	--减去花费金币，必须先计算上次花费的金币
			MissionData.setRefreshData(dictData.ret)   			--修改任务数据
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(cbFlag, dictData, bRet)
			end
		end
	end
	Network.rpc(requestFunc, "guildtask.refTask", "guildtask.refTask", nil, true)
end


-- /**
--  * 接一个任务
--  * @param int $p_pos 任务位置
--  * @param int $p_taskId 任务id
--  */
function acceptTask(p_pos, p_taskId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			MissionData.setTaskStatus(p_pos+1, 1)  -- 设置任务状态为进行中
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_pos))
	args:addObject(CCInteger:create(p_taskId))
	Network.rpc(requestFunc, "guildtask.acceptTask", "guildtask.acceptTask", args, true)
end

-- /**
--  * 放弃一个任务
--  * @param int $p_pos
--  * @param int $p_taskId
--  */
function forgiveTask(p_pos, p_taskId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			MissionData.setForgiveTime(BTUtil:getSvrTimeInterval())	--刷新上次放弃任务时间
			MissionData.setTaskStatus(p_pos+1, 0)  -- 设置任务状态为可接受
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_pos))
	args:addObject(CCInteger:create(p_taskId))
	Network.rpc(requestFunc, "guildtask.forgiveTask", "guildtask.forgiveTask", args, true)
end

-- /**
--  * 完成一个任务（领取已完成任务的奖励）
--  * @param int $p_pos
--  * @param int $p_taskId
--  * @param string $p_isUserGold 是否用金币强制完成1 为强制完成
--  * @return
--  * array
--  * (
--  * 		0 => array( 'id' => int, 'status' => int, 'num' => int, ),
--  * 		1
--  * 		2...
--  * )
--  */
function doneTask(p_pos, p_taskId, p_isUserGold, p_callbackFunc)
	local taskPos = p_pos + 1
	local achie_reward = ItemUtil.getItemsDataByStr(MissionData.getTaskReward(taskPos))
	local spendGold = MissionData.getCompleteTaskGoldByPos(taskPos)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			-- 刷新任务数据
			MissionData.setDoneTaskData(dictData.ret) 		
			-- 增加奖励数据
			ItemUtil.addRewardByTable(achie_reward)
			print("p_isUserGold", p_isUserGold)
			if(p_isUserGold == 1) then
				UserModel.addGoldNumber(-spendGold) 		--金币完成扣除花费金币
			end
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_pos))
	args:addObject(CCInteger:create(p_taskId))
	args:addObject(CCInteger:create(p_isUserGold))
	Network.rpc(requestFunc, "guildtask.doneTask", "guildtask.doneTask", args, true)
end

-- /**
--  * 贡献物品
--  * @param int $p_pos
--  * @param int $p_taskId
--  * @param array $p_itemIdArray  要贡献物品的id组
-- /
function handIn(p_pos, p_taskId, p_itemIdArray, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		MissionData.setTaskNum(p_pos + 1, table.count(p_itemIdArray))	--设置任务进度
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end

	local itemArray = CCArray:create()
	for i,v in ipairs(p_itemIdArray) do
		itemArray:addObject(CCInteger:create(v))
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_pos))
	args:addObject(CCInteger:create(p_taskId))
	args:addObject(itemArray)
	Network.rpc(requestFunc, "guildtask.handIn", "guildtask.handIn", args, true)
end

