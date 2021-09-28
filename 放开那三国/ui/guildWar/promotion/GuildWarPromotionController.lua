-- FileName: GuildWarPromotionController.lua 
-- Author: bzx
-- Date: 15-1-19
-- Purpose:  跨服军团战16强进8强的控制层

module("GuildWarPromotionController", package.seeall)

require "script/ui/guildWar/promotion/GuildWarPromotionService"
require "script/ui/guildWar/guildInfo/MyGuildWarInfoService"
--[[
	@desc:		军团战绩按钮的回调
	@return:	nil
--]]
function guildResultCallback( ... )
    require "script/ui/guildWar/report/GuildWarMainReportLayer"
    GuildWarMainReportLayer.showLayer(GuildWar16Layer.getTouchPriority() - 550, GuildWar16Layer.getZOrder() + 10)
end

--[[
	@desc:		战斗信息按钮的回调
	@return:	nil
--]]
function fightInfoCallback( ... )
    require "script/ui/guildWar/guildInfo/MyGuildWarInfoDialog"
    MyGuildWarInfoDialog.show(GuildWar16Layer.getTouchPriority() - 550, GuildWar16Layer.getZOrder() + 10, true) 
end

--[[
	@desc:		我的支持
	@return:	nil
--]]
function mySupporterCallback( ... )
    require "script/ui/guildWar/support/GuildWarMySupportDialog"
    GuildWarMySupportDialog.show(GuildWar16Layer.getTouchPriority() - 550, GuildWar16Layer.getZOrder() + 10)
end

--[[
    @desc:      战况回顾
    @return:    nil
--]]
function reviewWarCallback( ... )
    GuildWar16Layer.show(nil, nil, "GuildWar4Layer", true)
end

--[[
	@desc:		说明的回调
	@return:	nil
--]]
function descCallback( ... )
    require "script/ui/guildWar/GuildWarExplainLayer"
    GuildWarExplainLayer.show(GuildWar16Layer.getTouchPriority() - 550, GuildWar16Layer.getZOrder() + 10)
end

--[[
	@desc:		16进4返回的回调
	@return:	nil
--]]
function back16Callback( ... )
    local lastLayerName = GuildWar16Layer.getLastLayerName()
    if lastLayerName == "GuildWar4Layer" then
        GuildWar4Layer.show()
    else
	    GuildWarMainLayer.show()
    end
end

--[[
    @desc:          4进1返回的回调
    @return:    nil
--]]
function back4Callback( ... )
    GuildWarMainLayer.show()
end

--[[
	@desc:		增加连胜
	@return:	nil
--]]
function addWinCountCallback( ... )
    if not checkBuyWinCount() then
        return
    end

    if GuildWarPromotionData.getBuyMaxWinNumCost() > UserModel.getGoldNumber() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8503"))
        return
    end

    local buy = function(p_confirmed, arg)
        if p_confirmed == true then
            GuildWarInfoService.buyMaxWinTimes(GuildWarPromotionUtil.refreshAddWinCountItem)
        end
    end
	GuildWarPromotionUtil.showAddWinCountTipAlert()
end

--[[
    @desc:                              确认增加连胜
    @param:     bool    p_confirmed     对话框的返回值，true为确定，false为取消
    @return:    nil
--]]
function addWinCountAlertCallback(p_confirmed, arg)
    if p_confirmed == true then
        if not checkBuyWinCount() then
            return
        end
        local requestFunc = function ( ... )
            UserModel.addGoldNumber(-GuildWarPromotionData.getBuyMaxWinNumCost())
            GuildWarMainData.addMaxWinNum(1)
            GuildWarPromotionUtil.refreshAddWinCountItem()
            AnimationTip.showTip(GetLocalizeStringBy("key_8504"))
        end
        GuildWarPromotionService.buyMaxWinTimes(requestFunc)
    end
end

--[[
    @desc:                  检查能否购买连胜
    @return:    bool
--]]
function checkBuyWinCount( ... )
    -- 是否已经报名
    if not GuildWarMainData.isSignUp() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8505"))
        return false
    end
    
    -- 是否已经结束
    if GuildWarPromotionData.isEnd() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8506"))
        return false
    end
    
    -- 是否已经被淘汰
    if GuildWarPromotionData.myGuildIsEliminated() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8507"))
        return false
    end

    -- 是否在可增加连胜的时间段内
    local curStatus = GuildWarMainData.getStatus()
    local curRound = GuildWarMainData.getRound()
    local curTime = BTUtil:getSvrTimeInterval()
    local timeConfig = parseField(ActivityConfig.ConfigCache.guildwar.data[1].cdtimefresh, 2)
    if curStatus == GuildWarDef.END and curTime + timeConfig[2][2] > GuildWarMainData.getStartTime(curRound + 1) then
        AnimationTip.showTip(GetLocalizeStringBy("key_8508", timeConfig[2][2] / 60))
        return false
    elseif curStatus < GuildWarDef.END then
        AnimationTip.showTip(GetLocalizeStringBy("key_8509"))
        return false
    end
    return true
end


--[[
    @desc:          助威按钮回调
    @return:        nil
--]]
function cheerCallback(p_tag, p_btn)
    local btnIndex = math.mod(p_tag, 1000)
    local rank = math.floor(p_tag / 1000)
    local data = {}
    data.rank = rank
    data.position1 = btnIndex * 2 - 1
    data.position2 = btnIndex * 2
    require "script/ui/guildWar/support/GuildWarSupportDialog"
    GuildWarSupportDialog.show(data, GuildWar16Layer.getTouchPriority() - 550, GuildWar16Layer.getZOrder() + 10)
end

--[[
	@desc:			查看战报按钮回调
	@return:		nil
--]]
function lookCallback(p_tag, p_menuItem)
    local btnIndex = math.mod(p_tag, 1000)
    local rank = math.floor(p_tag / 1000)
    local index1 = btnIndex * 2 - 1
    local index2 = btnIndex * 2
    local guildTrapeziumInfo1 = GuildWarPromotionData.getGuildTrapeziumInfo(rank, index1)
    local guildTrapeziumInfo2 = GuildWarPromotionData.getGuildTrapeziumInfo(rank, index2)
    local ret = 0
    if guildTrapeziumInfo1 ~= nil then
        ret = ret + 1
    end
    if guildTrapeziumInfo2 ~= nil then
        ret = ret + 1
    end
    if ret == 1 then
        SingleTip.showTip(GetLocalizeStringBy("key_8510"))
    elseif ret == 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8511"))
    else
        require "script/ui/guildWar/report/GuildWarDetailReportDialog"
        local guildId1 = tonumber(guildTrapeziumInfo1.guildInfo.guild_id)
        local guildServerId1 = tonumber(guildTrapeziumInfo1.guildInfo.guild_server_id)
        local guildId2 = tonumber(guildTrapeziumInfo2.guildInfo.guild_id)
        local guildServerId2 = tonumber(guildTrapeziumInfo2.guildInfo.guild_server_id)
        GuildWarDetailReportDialog.showLayer(guildId1, guildServerId1, guildId2, guildServerId2, GuildWar16Layer.getTouchPriority() - 250, GuildWar16Layer.getZOrder() + 10 )
    end
end