-- Filename: GuildWarWorshipData.lua
-- Author: lichenyang
-- Date: 2015-01-20
-- Purpose: 个人跨服赛数据层

module("GuildWarWorshipController", package.seeall)

require "script/ui/guildWar/worship/GuildWarWorshipService"
require "script/ui/guildWar/GuildWarMainData"
require "script/ui/guildWar/worship/GuildWarWorshipData"
require "script/ui/item/ReceiveReward"
require "script/ui/tip/AnimationTip"
require "db/DB_Kuafu_legionchallengereward"

--[[
	@des:膜拜回调
--]]
function worshipCallback( p_tag, p_sender )
    p_tag = tonumber(p_tag)
	--当天尚未膜拜
	if(GuildWarMainData.getLastWorshipTime() ~= 0 and TimeUtil.getDifferDay(GuildWarMainData.getLastWorshipTime()) == 0)then
		--提示今日已经膜拜
		AnimationTip.showTip(GetLocalizeStringBy("djn_143"))
		return
	end

	--银币是否足够
	local silverCost = GuildWarWorshipData.getSilverCostByTag(p_tag)
	if(UserModel.getSilverNumber() < silverCost)then
		--提示银币不足
		AnimationTip.showTip(GetLocalizeStringBy("djn_107"))
		return
	end
	--金币是否足够
	local goldCost = GuildWarWorshipData.getGoldCostByTag(p_tag)
	if(UserModel.getGoldNumber() < goldCost)then
		--转向充值
		require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip(GuildWarWorshipDialog.getTouchPriority()-50,GuildWarWorshipDialog.getZOrder()+10)
		return
	end

	-- 宠物背包满了
	require "script/ui/pet/PetUtil"
	if PetUtil.isPetBagFull() == true then
		GuildWarWorshipDialog.closeButtonCallback()
		return
	end
	-- 物品背包满了
	require "script/ui/item/ItemUtil"
	if(ItemUtil.isBagFull() == true )then
		GuildWarWorshipDialog.closeButtonCallback()
		return
	end
	-- 武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	GuildWarWorshipDialog.closeButtonCallback()
    	return
    end
    --后端约定膜拜type id从0开始
	local worshipType = p_tag - 1
	local requestCallback = function ( ... )
	    --扣金币银币
	    UserModel.addGoldNumber(-GuildWarWorshipData.getGoldCostByTag(p_tag))
	    UserModel.addSilverNumber(-GuildWarWorshipData.getSilverCostByTag(p_tag))

		--刷新金币顶部			
        -- require "script/ui/guildWar/worship/GuildWarWorshipMainLayer"
        -- GuildWarWorshipMainLayer.updateTopUi()
		--更新缓存中的膜拜时间
        GuildWarMainData.setLastWorshipTime(TimeUtil.getSvrTimeByOffset())
        --获取本次奖励列表
		local rewardIDList = ActivityConfig.ConfigCache.guildwar.data[1].wishReward
		rewardIDList = string.split(rewardIDList,",")
		local rewardList = DB_Kuafu_legionchallengereward.getDataById(rewardIDList[p_tag]).reward
		rewardList = ItemUtil.getItemsDataByStr(rewardList)
		--更新本地的奖励缓存
        ItemUtil.addRewardByTable(rewardList) 
        --弹出奖励面板
		ReceiveReward.showRewardWindow(rewardList,nil,GuildWarWorshipDialog.getZOrder()+10,GuildWarWorshipDialog.getTouchPriority()-50,nil)
		
	end
	GuildWarWorshipService.worship(worshipType,requestCallback)
end

