-- FileName: OneKeyRobController.lua
-- Author: lichenyang
-- Date: 2014-04-00
-- Purpose: TM_FILENAME
--[[TODO List]]

module("OneKeyRobController", package.seeall)
require "script/ui/tip/AnimationTip"
require "script/ui/treasure/oneKeyRob/OneKeyRobService"
require "script/ui/treasure/oneKeyRob/OneKeyRobData"

local _requestCallback = nil

function oneKeySeize( pTreasureId, pIsAutoUse )
	local treasureId = pTreasureId
	local isUse      = pIsAutoUse == true and 1 or 0
	--1.等级到达可以抢夺的等级
	if UserModel.getHeroLevel() < OneKeyRobData.getUseLevel() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1996", OneKeyRobData.getUseLevel()))
		return 
	end
	--2.背包是否满
	if ItemUtil.isBagFull() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1983"))
		return
	end
	--3.耐力不足
	local costEndurance = tonumber(DB_Loot.getDataById(1).costEndurance)
	if pIsAutoUse == false and UserModel.getStaminaNumber() < costEndurance then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1984"))
		return
	end
	--4.耐力丹不足
	local itemNum = ItemUtil.getCacheItemNumBy("10042")
	if pIsAutoUse == true and itemNum < 1 and UserModel.getStaminaNumber() < costEndurance then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1985"))
		return
	end
	--5.已拥有所有碎片
	local fragments = TreasureData.getTreasureFragments(pTreasureId)
	local isHave = true
	for k,v in pairs(fragments) do
		if(TreasureData.getFragmentNum(v) == 0) then
			isHave = false
		end
	end
	if(isHave == true) then
		--没有对应的碎片
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1995"))
		return
	end
	local requestNum = 1 --请求次数
	local requestCallback = function ( pRetData )
		--1.用户自检失败 没有任何一个该宝物对应的碎片
		if(pRetData.res == "fail") then
			AnimationTip.showTip(GetLocalizeStringBy("lcyx_1986"))
			return
		end
		OneKeyRobData.setInfo(pRetData)
		--1.扣除耐力
		UserModel.addStaminaNumber(-OneKeyRobData.getCostStamina())
		--2.增加银币
		UserModel.addSilverNumber(tonumber(pRetData.silver) or 0)
		--3.增加经验
		UserModel.addExpValue(tonumber(pRetData.exp) or 0)
		--翻牌相关
		if pRetData.card then
			UserModel.addSilverNumber(tonumber(pRetData.card.silver) or 0)
			UserModel.addGoldNumber(tonumber(pRetData.card.gold) or 0)
			UserModel.addSoulNum(tonumber(pRetData.card.soul) or 0)
			UserModel.addSilverNumber(tonumber(pRetData.card.rob) or 0)
		end
	    -- 碎片够合成一个宝物
		if(pRetData.res ~= "ok") then
			require "script/ui/treasure/oneKeyRob/OneKeyRobDialog"
			OneKeyRobDialog.showLayer(-600, 600, pTreasureId)
			return
		else
			requestNum = requestNum + 1
			OneKeyRobService.oneKeySeize(treasureId, isUse, requestNum, _requestCallback)
		end
	end
	_requestCallback = requestCallback
	OneKeyRobService.oneKeySeize(treasureId, isUse, requestNum, _requestCallback)
end