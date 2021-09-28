-- Filename: GuildWarSupportController.lua
-- Author: bzx
-- Date: 2015-1-19
-- Purpose: 助威数据

module("GuildWarSupportController", package.seeall)

require "script/model/user/UserModel"

function cheerCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local rank = GuildWarSupportDialog.getRank()
    local btnStatus = GuildWarPromotionUtil.getBtnStatus(rank)
    if btnStatus == GuildWarPromotionUtil.BtnStatus.look then
        SingleTip.showTip(GetLocalizeStringBy("key_8520"))
        return
    end
    
    local costData = GuildWarSupportData.getCheerCost()
    if costData.costType == 1 then
        if costData.costCount > UserModel.getSilverNumber() then
            SingleTip.showTip(GetLocalizeStringBy("key_8255"))
            return
        end
    elseif costData.costType == 2 then
        if costData.costCount > UserModel.getGoldNumber() then
            SingleTip.showTip(GetLocalizeStringBy("key_8256"))
            return
        end
    end
    local cheeredPosition = GuildWarSupportDialog.getSelectedPosition()
    local cheeredGuildWarInfo = GuildWarPromotionData.getGuildWarInfoByPosition(cheeredPosition)
    local requestFunc = function ( ... )
        if costData.costType == 1 then
            UserModel.addSilverNumber(-costData.costCount)
        elseif costData.costType == 2 then
            UserModel.addGoldNumber(-costData.costCount)
        end
        GuildWarMainData.setCheerGuild(cheeredGuildWarInfo.guild_id, cheeredGuildWarInfo.guild_server_id)
        GuildWarSupportDialog.close()
        GuildWar16Layer.refreshTableView()
        GuildWar4Layer.refreshCenterNode()
        SingleTip.showTip(GetLocalizeStringBy("key_8521"))
    end    
    GuildWarSupportService.cheer(cheeredGuildWarInfo.guild_id, cheeredGuildWarInfo.guild_server_id, requestFunc)
end


function cancelCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    GuildWarSupportDialog.close()
end

function closeCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    GuildWarSupportDialog.close()
end
