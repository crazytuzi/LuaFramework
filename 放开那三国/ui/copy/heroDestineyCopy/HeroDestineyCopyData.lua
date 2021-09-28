-- Filename: HeroDestineyCopyData.lua
-- Author: zhangqiang
-- Date: 2016-05-30
-- Purpose: 英雄天命副本

module("HeroDestineyCopyData", package.seeall)
require "script/model/DataCache"
require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyService"

kHeroDestineyTid = 300006

--事件名称
kBuyDestinyAtkNumSuccess = "kBuyDestinyAtkNumSuccess"

--获取数据
function getCache()
	local tbCache, tbAllActiveCopyData = nil, DataCache.getActiveCopyData()
	if (not table.isEmpty(tbAllActiveCopyData)) then
		for nIdx, tbData in ipairs(tbAllActiveCopyData) do
			if (tonumber(tbData.copy_id) == HeroDestineyCopyData.kHeroDestineyTid) then
				tbCache = tbData
				break
			end
		end
	end	

	return tbCache
end

--英雄天命是否开启
function isOpen( ... )
	local tbCache, nOpen, sDesc = getCache(), 0, ""

	--没有获取到英雄天命数据
	if table.isEmpty(tbCache) then
		nOpen, sDesc = 1, GetLocalizeStringBy("zq_0001")
		return nOpen, sDesc
	end

	--是否满足等级限制
	local level = UserModel.getHeroLevel()
	if tbCache.copyInfo ~= nil and tbCache.copyInfo.limit_lv ~= nil and level < tbCache.copyInfo.limit_lv then
		nOpen, sDesc = 2, GetLocalizeStringBy("zq_0002", tbCache.copyInfo.limit_lv)
		return nOpen, sDesc
	end

	--剩余攻打次数是否足够
	local nLeftAtkNum = getLeftAtkNum()
	if nLeftAtkNum <= 0 then
		nOpen, sDesc = 3, GetLocalizeStringBy("zq_0003")
		return nOpen, sDesc
	end

	return nOpen, sDesc
end

--获取剩余攻打次数
function getLeftAtkNum( ... )
	local nNum = 0
	local tbCache = getCache()
	if not table.isEmpty(tbCache) then
		nNum = tonumber(tbCache.can_defeat_num)
	end
	
	return nNum
end

--修改英雄天命剩余攻打次数
function setLeftAtkNum( pNum )
	local nNum = tonumber(pNum or 0)
	local tbCache = getCache()
	if not table.isEmpty(tbCache) then
		tbCache.can_defeat_num = nNum
	end
end

--增加剩余攻打次数
function addLeftAtkNum( pDeltaNum )
	local nDeltaNum = tonumber(pDeltaNum or 0)
	local tbCache = getCache()
	if not table.isEmpty(tbCache) then
		tbCache.can_defeat_num = tonumber(tbCache.can_defeat_num) + nDeltaNum
		tbCache.can_defeat_num = tbCache.can_defeat_num < 0 and 0 or tbCache.can_defeat_num
	end
end

--获取购买的攻打次数
function getBuyNum( ... )
	local nNum = 0
	local tbCache = getCache()
	if not table.isEmpty(tbCache) then
		nNum = tonumber(tbCache.buy_atk_num)
	end

	return nNum
end

--增加购买的攻打次数
function addBuyNum( pDeltaNum )
	local nDeltaNum = tonumber(pDeltaNum or 0)
	local tbCache = getCache()
	if not table.isEmpty(tbCache) then
		tbCache.buy_atk_num = tonumber(tbCache.buy_atk_num) + nDeltaNum
		tbCache.buy_atk_num = tbCache.buy_atk_num < 0 and 0 or tbCache.buy_atk_num
	end
end

--获取购买次数花费(最大购买次数｜基础花费｜花费增量)
function getBuyAtkNumString( ... )
	require "db/DB_Normal_config"
	local str = DB_Normal_config.getDataById(1).destiny_price or "999|999|999"

	return str
end

--获取每天的最大购买次数
function getMaxBuyNumPerDay( ... )
	local sCostString = getBuyAtkNumString()
	local tbCostDetail = lua_string_split(sCostString, "|")

	local nMax = tonumber(tbCostDetail[1])

	return nMax
end

--获取当前还能购买的最大攻打次数
function getMaxLeftBuyNumPerDay( ... )
	local nMaxNum = getMaxBuyNumPerDay()
	local nHasBuyNum = getBuyNum()

	local nMaxLeftNum = 0
	if nMaxNum >= nHasBuyNum then
		nMaxLeftNum = nMaxNum - nHasBuyNum
	end

	return nMaxLeftNum
end


--获取总花费
function getTotalCostByNum( pWillBuyNum )
	local nWillBuyNum = tonumber(pWillBuyNum or 0)
	local nTotalCost = 0

	local sCostString = getBuyAtkNumString()
	local tbCostDetail = lua_string_split(sCostString, "|")
	local nBaseCost, nIncrement = tonumber(tbCostDetail[2]), tonumber(tbCostDetail[3])

	if nWillBuyNum > 0 then
		local nHasBuyNum = getBuyNum()  --已购买次数
		for i = 1, nWillBuyNum do
			local nCost = nBaseCost + (nHasBuyNum + i - 1) * nIncrement   --本次花费
			nTotalCost = nTotalCost + nCost
		end
	end

	return nTotalCost
end

--------------------------------------网络请求------------------------------------
--发送请求
function sendBuyDestinyAtkNum( pNum )
	local nNum = tonumber(pNum or 1)
	local nMaxLeftNum = getMaxLeftBuyNumPerDay()
	if nNum > nMaxLeftNum or nNum == 0 then
		print("[HeroDestineyCopyData sendBuyDestinyAtkNum] nNum: ", nNum, " nMaxLeftNum: ", nMaxLeftNum)
		return
	end

	--金币是否足够
	local nWillCost = getTotalCostByNum(nNum)
	local nUserGold = UserModel.getGoldNumber()
	if nUserGold < nWillCost then
		AnimationTip.showTip(GetLocalizeStringBy("zq_0014"))   --金币不足
		return
	end
	

	HeroDestineyCopyService.buyDestinyAtkNum(nNum, buyDestinyAtkNumCb)
end

--请求返回后的处理
function buyDestinyAtkNumCb( pDictRet, pParams )
	if(pDictRet == "ok")then
		local nBuyNum = tonumber(pParams[1] or 0)

		--必须在 addBuyNum 前调用，计算本次花费
		local gold = getTotalCostByNum(nBuyNum)
		print("buyDestinyAtkNumCb ========= nHasBuyNum: ", getBuyNum(), " nWillBuyNum : ", nBuyNum, "total cost: ", gold)
		UserModel.addGoldNumber( - gold )

		addLeftAtkNum(nBuyNum)
		addBuyNum(nBuyNum)

		AnimationTip.showTip(GetLocalizeStringBy("zq_0007", nBuyNum))   --购买成功提示

		require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyCtrl"
		local tbData = {}
		HeroDestineyCopyCtrl.dispatchEvent(kBuyDestinyAtkNumSuccess, tbData)
	end
end