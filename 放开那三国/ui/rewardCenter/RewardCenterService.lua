-- Filename: RewardCenterService.lua
-- Author: lichenyang
-- Date: 2013-08-12
-- Purpose: 奖励中心业务层

require "script/ui/rewardCenter/RewardCenterData"
require "script/utils/LuaUtil"
module("RewardCenterService", package.seeall)

--return:
-- { [ rid int:奖励的唯一ID
-- 	source int:类型，系统补偿、首充奖励等...(前后端预先约定好)
-- 	send_time int:发奖时间
-- 	reward: 具体的奖励。
-- 	{ item: 奖励物品
-- 		[ { tplId int: 物品模板ID num int: 物品个数 } ]
-- 		 gold: 金币
-- 		 silver: 银币
-- 		 soul: 将魂
-- 	}
--   ]
-- }
--offset 起始位置
--limit  内容数量
function getRewardList( offset,limit,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			RewardCenterData.rewardList = dictData.ret
			print_t(dictData.ret)
			callbackFunc()
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(offset))
	args:addObject(CCInteger:create(limit))
	Network.rpc(requestFunc, "reward.getRewardList", "reward.getRewardList", nil, true)
end

function getRewardRecordList( offset,limit,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			RewardCenterData.rewardrecordList = dictData.ret
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "reward.getReceivedList", "reward.getReceivedList", nil, true)
end


--领取奖励
--奖励id
function receiveReward( rid,callbackFunc )
	--是否已过期
	if(RewardCenterData.isTimeOut(rid)) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1797"))
		return
	end

	--背包够用
	require "script/ui/item/ItemUtil"
	-- added by zhz 判断背包里是否有物品
	local isItem = true
	local rewardInfo = RewardCenterData.getSingleRewardInfo(rid)
	if(table.isEmpty(rewardInfo.va_reward.item)  ) then
		isItem = false
	end

	if(isItem  and ItemUtil.isBagFull() == true) then
		require "script/ui/tip/AnimationTip"
		RewardCenterView.closeLayer()
		--AnimationTip.showTip(GetLocalizeStringBy("key_2811"))
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			-- require "script/ui/tip/AnimationTip"
			-- AnimationTip.showTip(RewardCenterData.getRewardInfo(rid))

			--得到物品提示
			require "script/ui/item/ReceiveReward"
 			ReceiveReward.showRewardWindow( RewardCenterData.getRewardListInfo(rid),nil,nil, -690)  -- -9700


			local rewardInfo = RewardCenterData.getSingleRewardInfo(rid)
			if(rewardInfo.va_reward.gold ~= nil) then
				UserModel.addGoldNumber(tonumber(rewardInfo.va_reward.gold))
			end
			if(rewardInfo.va_reward.soul ~= nil) then
				UserModel.addSoulNum(tonumber(rewardInfo.va_reward.soul))
			end
			if(rewardInfo.va_reward.silver ~= nil) then
				UserModel.addSilverNumber(tonumber(rewardInfo.va_reward.silver))
			end
			if(rewardInfo.va_reward.prestige ~= nil) then
				UserModel.addPrestigeNum(tonumber(rewardInfo.va_reward.prestige))
			end
			if(rewardInfo.va_reward.jewel ~= nil) then
				UserModel.addJewelNum(tonumber(rewardInfo.va_reward.jewel))
			end
			if(rewardInfo.va_reward.wm_num ~= nil) then
				UserModel.addWmNum(tonumber(rewardInfo.va_reward.wm_num))
			end
			if(rewardInfo.va_reward.honor ~= nil) then
				UserModel.addHonorNum(tonumber(rewardInfo.va_reward.honor))
			end
			if(rewardInfo.va_reward.cross_honor ~= nil) then
				UserModel.addCrossHonor(tonumber(rewardInfo.va_reward.cross_honor))
			end
			if(rewardInfo.va_reward.fs_exp ~= nil) then
				UserModel.addFSExpNum(tonumber(rewardInfo.va_reward.fs_exp))
			end
			if(rewardInfo.va_reward.jh ~= nil) then
				UserModel.addHeroJh(tonumber(rewardInfo.va_reward.jh))
			end
			if(rewardInfo.va_reward.tally_point ~= nil) then
				UserModel.addTallyPointNumber(tonumber(rewardInfo.va_reward.tally_point))
			end
			if(rewardInfo.va_reward.book_num ~= nil) then
				UserModel.addTallyPointNumber(tonumber(rewardInfo.va_reward.book_num))
			end
			if(rewardInfo.va_reward.grain ~= nil) then
				require "script/ui/guild/GuildDataCache"
				GuildDataCache.addMyselfGrainNum(tonumber(rewardInfo.va_reward.grain))
			end
			RewardCenterData.deleteReward(rid)
			callbackFunc()
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(rid))
	Network.rpc(requestFunc, "reward.receiveReward", "reward.receiveReward", args, true)
end


--领取所有奖励
--暂时没用
function receiveAllReward(callbackFunc)
	--是否过期
	--背包是否够用


	if(ItemUtil.isBagFull() == true) then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2811"))
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1969"))
			RewardCenterData.rewardList = {}
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "reward.receiveAllReward", "reward.receiveAllReward", nil, true)
end

--
function receiveByRidArr( rid_table,callbackFunc )

	--是否已过期
	local isAllTimeOut = true
	for k,v in pairs(rid_table) do
		if not RewardCenterData.isTimeOut(v) then
			isAllTimeOut = false
		end
	end
	if isAllTimeOut == true then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1797"))
		return
	end
	
	--背包是否满
	--背包够用
	require "script/ui/item/ItemUtil"
	local isItem = true
	for k,v in pairs(rid_table) do
		local rewardInfo = RewardCenterData.getSingleRewardInfo(v)
		if(table.isEmpty(rewardInfo.va_reward.item)  ) then
			isItem = false	
		end
	end

	if(isItem and ItemUtil.isBagFull() == true) then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2811"))
		RewardCenterView.closeLayer()
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1969"))
			--更新数据
			for k,v in pairs(rid_table) do
				local rewardInfo = RewardCenterData.getSingleRewardInfo(v)
				if(rewardInfo.va_reward.gold ~= nil) then
					UserModel.addGoldNumber(tonumber(rewardInfo.va_reward.gold))
				end
				if(rewardInfo.va_reward.soul ~= nil) then
					UserModel.addSoulNum(tonumber(rewardInfo.va_reward.soul))
				end
				if(rewardInfo.va_reward.silver ~= nil) then
					UserModel.addSilverNumber(tonumber(rewardInfo.va_reward.silver))
				end
				if(rewardInfo.va_reward.prestige ~= nil) then
					UserModel.addPrestigeNum(tonumber(rewardInfo.va_reward.prestige))
				end
				if(rewardInfo.va_reward.wm_num ~= nil) then
					UserModel.addWmNum(tonumber(rewardInfo.va_reward.wm_num))
				end
				if(rewardInfo.va_reward.jewel ~= nil) then
					UserModel.addJewelNum(tonumber(rewardInfo.va_reward.jewel))
				end
				if(rewardInfo.va_reward.honor ~= nil) then
					UserModel.addHonorNum(tonumber(rewardInfo.va_reward.honor))
				end
				if(rewardInfo.va_reward.cross_honor ~= nil) then
					UserModel.addCrossHonor(tonumber(rewardInfo.va_reward.cross_honor))
				end
				if(rewardInfo.va_reward.fs_exp ~= nil) then
					UserModel.addFSExpNum(tonumber(rewardInfo.va_reward.fs_exp))
				end
				if(rewardInfo.va_reward.jh ~= nil) then
					UserModel.addHeroJh(tonumber(rewardInfo.va_reward.jh))
				end
				if(rewardInfo.va_reward.tally_point ~= nil) then
					UserModel.addTallyPointNumber(tonumber(rewardInfo.va_reward.tally_point))
				end
				if(rewardInfo.va_reward.book_num ~= nil) then
					UserModel.addTallyPointNumber(tonumber(rewardInfo.va_reward.book_num))
				end
				if(rewardInfo.va_reward.grain ~= nil) then
					require "script/ui/guild/GuildDataCache"
					GuildDataCache.addMyselfGrainNum(tonumber(rewardInfo.va_reward.grain))
				end
				RewardCenterData.deleteReward(v)
			end
			callbackFunc()
		end
	end
	local args = CCArray:create()
	local ridArray = CCArray:create()
	for k,v in pairs(rid_table) do
		if(RewardCenterData.isTimeOut(v) ~= true) then
			ridArray:addObject(CCString:create(v))
		end
	end
	args:addObject(ridArray)
	Network.rpc(requestFunc, "reward.receiveByRidArr", "reward.receiveByRidArr", args, true)
end


