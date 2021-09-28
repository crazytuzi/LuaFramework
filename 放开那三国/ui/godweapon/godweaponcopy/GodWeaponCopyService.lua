-- FileName: GodWeaponCopyService.lua
-- Author: LLP
-- Date: 14-12-15
-- Purpose: 神兵副本网络命令接口


module("GodWeaponCopyService", package.seeall)

require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"


--获取神兵副本信息
function getCopyInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			GodWeaponCopyData.setCopyInfo(dataRet)
			GodWeaponCopyData.setLoseTimes(tonumber(dataRet.lose_num))
			GodWeaponCopyData.setBuyTimes(tonumber(dataRet.buy_num))
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.enter", "pass.enter", nil, true)
end

--对手信息
function getOpponentList( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			GodWeaponCopyData.setOpponentInfo(dataRet)
			-- 回调
			if(callbackFunc)then
				print ("getActiveInfo---后端数据")
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.getOpponentList", "pass.getOpponentList", pArgs, true)
end

--排行榜信息
function getRankList( callbackFunc )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			GodWeaponCopyData.setRankInfo(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.getRankList", "pass.getRankList", nil, true)
end

--战斗信息
function attack( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "pass.attack", "pass.attack", pArgs, true)
end

--奖励信息
function rewardInfo( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			GodWeaponCopyData.setRewardInfo(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.dealChest", "pass.dealChest", pArgs, true)
end
--商店信息
function shopInfo( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			print("商店信息")
			print_t(dataRet)
			GodWeaponCopyData.setShopInfo(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.getShopInfo", "pass.getShopInfo", nil, true)
end

--买buff信息
function buyBuffInfo( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.dealBuff", "pass.dealBuff", pArgs, true)
end

--买宝箱信息
function buyChestInfo( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.dealChest", "pass.dealChest", pArgs, true)
end

--放弃买宝箱信息
function leaveLuxuryChest( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.leaveLuxuryChest", "pass.leaveLuxuryChest", pArgs, true)
end

--更改阵容信息
function changePosCommond( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.setPassFormation", "pass.setPassFormation", pArgs, true)
end

--购买次数
function buyTimeCommond( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.buyAttackNum", "pass.buyAttackNum",pArgs, true)
end

--扫荡
function sweep( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			GodWeaponCopyData.setHaveSweep()
			local dataRet = dictData.ret
			local sweepCost = 0
			for k,v in pairs(dataRet)do
				if(v[4]~=0)then
					sweepCost = sweepCost+tonumber(v[4])
				end
			end
			local rewardT = {}
			for k,v in pairs(dataRet)do
				if(not table.isEmpty(v[1]))then
					for key,value in pairs(v[1])do
						table.insert(rewardT,value)
					end
				end
			end

			local rewardTable = {}
			for k,v in pairs(rewardT)do
				rewardData = DB_Overcome_chest.getDataById(tonumber(v))
				table.insert(rewardTable,rewardData.RewardItem)
			end

			for i=1,table.count(rewardTable) do
				local rewardArrySp = ItemUtil.getItemsDataByStr(rewardTable[i])
				rewardArrySp[1].num = rewardArrySp[1].num

				if(tostring(rewardArrySp[1].type)=="silver")then
					rewardArrySp[1].num = rewardArrySp[1].num
					UserModel.addSilverNumber(rewardArrySp[1].num)
				end
			end
			UserModel.addGoldNumber(-sweepCost)
			GodWeaponCopyData.setSweepResult(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.sweep", "pass.sweep",pArgs, true)
end