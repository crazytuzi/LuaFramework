-- FileName: GuildWarMainController.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarMainController 跨服军团战接口模块

module("GuildWarMainController", package.seeall)
require "script/ui/guildWar/GuildWarMainData"
require "script/ui/guildWar/GuildWarStageEvent"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/GuildDef"
--[[
	@des : 跨服战况回顾
--]]
function promotionInfoCallback()
	require "script/ui/guildWar/promotion/GuildWar16Layer"
	require "script/ui/guildWar/promotion/GuildWar4Layer"
	GuildWar4Layer.show()
end

--[[
	@des : 膜拜冠军
--]]
function worshipCallback()
	require "script/ui/guildWar/worship/GuildWarWorshipMainLayer"
	GuildWarWorshipMainLayer.show()
end

--[[
	@des : 进入赛场
--]]
function enterCallback()
	require "script/ui/guildWar/promotion/GuildWar16Layer"
	require "script/ui/guildWar/promotion/GuildWar4Layer"

	local curRound = GuildWarMainData.getRound()
	local curStatus = GuildWarMainData.getStatus()
	local curTime = TimeUtil.getSvrTimeByOffset(-1)
    if (curRound == GuildWarDef.AUDITION and curStatus >= GuildWarDef.DONE) 
    	or (curRound >= GuildWarDef.ADVANCED_16 and curRound <= GuildWarDef.ADVANCED_8) then
    		if curRound == GuildWarDef.ADVANCED_8 
    			and curStatus >= GuildWarDef.DONE 
    			and curTime > GuildWarMainData.getEndTime(GuildWarDef.ADVANCED_8) then
        			GuildWar4Layer.show()
        	else
        			GuildWar16Layer.show()
        	end
    elseif (curRound >= GuildWarDef.ADVANCED_8 and curRound <= GuildWarDef.ADVANCED_2) then
    	GuildWar4Layer.show()
    end
end

--[[
	@des:战斗信息按钮回调
--]]
function battleInfoCallback()
	require "script/ui/guildWar/guildInfo/MyGuildWarInfoDialog"
    MyGuildWarInfoDialog.show(-800, 800)
end


--[[
	@des: 关闭按钮回调事件
--]]
function closeCallFunc()
	require "script/model/utils/ActivityConfigUtil"
	if(ActivityConfigUtil.isActivityOpen("guildwar") == true) then
		GuildWarMainService.leave(function ()
			AudioUtil.playMainBgm()
			GuildWarStageEvent.destory()
			require "script/ui/main/MainBaseLayer"
			local main_base_layer = MainBaseLayer.create()
			MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		    MainScene.setMainSceneViewsVisible(true,true,true)
		    print("closeCallFunc")
		end)
	else
		AudioUtil.playMainBgm()
		GuildWarStageEvent.destory()
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
	end	
end

--[[
	@des: 活动说明按钮
--]]
function explainCallFunc()
	require "script/ui/guildWar/GuildWarExplainLayer"
	GuildWarExplainLayer.show(-1024)
end

--[[
	@des: 奖励预览按钮
--]]
function rewardPreviewCallback(tag,menuItem)
	require "script/ui/guildWar/reward/GuildWarRewardDialog"
	GuildWarRewardDialog.showLayer()
end

--[[
	@des : 查看战绩
--]]
function checkReportCallback( ... )
	require "script/ui/guildWar/report/GuildWarMainReportLayer"
	GuildWarMainReportLayer.showLayer()
end

--[[
	@des: 报名按钮回调事件
--]]
function registerCallback()

	--玩家有没有军团
	if GuildDataCache.getMineSigleGuildId() <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_168"))
		return
	end
	--军团等级大于报名要求等级
	local guildNeedLevel = GuildWarMainData.getNeedSignGuildLevel()
	if GuildDataCache.getGuildHallLevel() < guildNeedLevel then
		AnimationTip.showTip(string.format(GetLocalizeStringBy("lcyx_169"), guildNeedLevel))
		return
	end
	--军团长和副军团长才可以报名
	local mineMemberType = GuildDataCache.getMineMemberType()
	if mineMemberType ~= GuildDef.PRESIDENT 
		and mineMemberType ~= GuildDef.VICE_PRESIDENT then
	   		AnimationTip.showTip(GetLocalizeStringBy("lcyx_170"))
	   		return
	end
	--处于报名时间内
	local curTime = TimeUtil.getSvrTimeByOffset(-1)
	if  GuildWarMainData.getEndTime(GuildWarDef.SIGNUP) < curTime  then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_171"))
   		return
	end
	if GuildWarMainData.getStartTime(GuildWarDef.SIGNUP) > curTime then
		
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_172"))
   		return
	end
	--军团人数>=配置人数
	local guildMemberNum = GuildDataCache.getMemberCount()
	local signNeedGuildNum = GuildWarMainData.getSignNeedMemberNum()
	if guildMemberNum < signNeedGuildNum then
		AnimationTip.showTip(string.format(GetLocalizeStringBy("lcyx_173"), signNeedGuildNum))
	   	return
	end
	--未报名
	if GuildWarMainData.isSignUp() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_174"))
		return
	end
	local requestCallback = function ()
		--更新报名时间
		GuildWarMainData.setSignUpTime(curTime)
		--报名提示
        AnimationTip.showTip(GetLocalizeStringBy("key_8259"))
		--更新主界面按钮
		GuildWarMainLayer.updateButtonStatus()
	end
	GuildWarMainService.signUp(requestCallback)
end


