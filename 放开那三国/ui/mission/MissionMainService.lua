-- FileName: MissionMainService.lua
-- Author: 
-- Date: 2015-08-28
-- Purpose: 悬赏榜网络层
--[[TODO List]]

module("MissionMainService", package.seeall)



--登陆拉悬赏榜信息接口
function getMissionInfoLogin( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"mission.getMissionInfoLogin","mission.getMissionInfoLogin",nil,true)
end

-- /**
--  * @return
--  * 
--  * 获取信息
--  * [
--  * 
--  *  donate_item_num => int, 本轮捐献的物品数量（这个也可以拿到任务进度里去吧）
--  *  spec_mission_fame => int, 本轮做任务获得的名望
--  *  dayreward_time => int, 每日奖励领取时间
--  *  teamId => int, 分组id <= 0 为未分组
--  *  rank => int, 没有排名 -1
--  *missionInfo => [ 	任务进度
--  *  					missionId(int) =>[ num => int ], 
--  *  			   ],
--  *  
--  *  configInfo => [	配置信息
--  *  				rankRewardArr => array((int,int),(int,int)...), 排名奖励前段展示用
--  *  				dayRewardArr => array((int,int),(int,int)...), 每日奖励前段展示用
--  *  				missionBackground => array( (int,int),(int, int) ),背景展示
--  *  		  ],
--  *  
--  * ]
--  * 
--  */
function getMissionInfo(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		-- local dictData = {
		-- 	ret = {
		-- 		fame = 10,
		-- 		donate_item_num = 20,
		-- 		spec_mission_fame = 500,
		-- 		rank = 5,
		-- 		missionInfo = {
		-- 			["10"] = 2,
		-- 			["5"]  = 3,
		-- 			["4"]  = 8,
		-- 			["2"]  = 4,
		-- 		},
		-- 		configInfo = {
		-- 			sess = 1,
		-- 			rankRewardArr = {
		-- 				[1] = {29,19},
		-- 				[2] = {29,19},
		-- 				[3] = {29,19},
		-- 			},
		-- 			dayRewardArr = {
		-- 				[1] = {1,10},
		-- 				[2] = {2,12},
		-- 				[3] = {3,13},
		-- 			},
		-- 		}
		-- 	},
		-- 	err = "ok",
		-- }
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	-- requestFunc()
	Network.rpc(requestFunc,"mission.getMissionInfo","mission.getMissionInfo",nil,true)
end

-- /**
--  * 贡献物品
--  * @param array $itemArr
--  * [
--  * 	itemid =>itemnum,
--  * ]
--  * 
--  * @return array('res' => ok);
--  * 
--  */
function doMissionItem(pItemArr, pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		-- local dictData = {
		-- 	ret = "ok",
		-- 	err = "ok",
		-- }
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pItemArr})
	-- requestFunc()
	Network.rpc(requestFunc,"mission.doMissionItem","mission.doMissionItem",args,true)
end

-- /**
--  * 贡献金币
--  * @param int pGoldNum
--  * 
--  */
function doMissionGold( pGoldNum, pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		-- local dictData = {
		-- 	ret = "ok",
		-- 	err = "ok",
		-- }
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pGoldNum})
	-- requestFunc()
	Network.rpc(requestFunc,"mission.doMissionGold","mission.doMissionGold",args,true)
end

-- /**
--  *领取每日奖励
--  * 
--  */
function receiveDayReward(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		-- local dictData = {
		-- 	ret = "ok",
		-- 	err = "ok",
		-- }
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	-- requestFunc()
	Network.rpc(requestFunc,"mission.receiveDayReward","mission.receiveDayReward",nil,true)
end
