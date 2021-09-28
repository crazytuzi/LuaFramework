-- FileName: GuildWar16Controller.lua 
-- Author: bzx
-- Date: 15-1-19
-- Purpose:  跨服军团战16强进8强的控制层

module("GuildWar16Controller", package.seeall)

--[[
	@desc:		军团战绩按钮的回调
	@return:	nil
--]]
function guildResultCallback( ... )
end

--[[
	@desc:		战斗信息按钮的回调
	@return:	nil
--]]
function fightInfoCallback( ... )
    -- require "script/utils/ModuleUtil"
    ModuleUtil.cleanupModuleByName("MyGuildWarInfoDialog", "script/ui/guildWar/guildInfo/MyGuildWarInfoDialog")

    require "script/ui/guildWar/guildInfo/MyGuildWarInfoDialog"
    MyGuildWarInfoDialog.show(GuildWar16Layer.getTouchPriority() - 550, GuildWar16Layer.getZOrder() + 10)
end

--[[
	@desc:		我的支持
	@return:	nil
--]]
function mySupporterCallback( ... )
	
end

--[[
	@desc:		说明的回调
	@return:	nil
--]]
function descCallback( ... )
	
end

--[[
	@desc:		返回的回调
	@return:	nil
--]]
function backCallback( ... )
    local lastLayerName = GuildWar16Layer.getLastLayerName()
    if lastLayerName == "GuildWar4Layer" then
        GuildWar4Layer.show()
    else
	    GuildWarMainLayer.show()
    end
end

--[[
	@desc:		增加连胜
	@return:	nil
--]]
function addWinCountCallback( ... )
	
end

--[[
	@desc:			助威按钮回调
	@return:		nil
--]]
function cheerCallback(tag, btn)
    -- local btn_index = math.mod(tag, 1000)
    -- local stage = math.floor(tag / 1000)
    -- print(btn_index, stage)
    -- require "script/ui/lordWar/LordWarCheerLayer"
    -- local data = {}
    -- data.group = _lord_type 
    -- data.rank = stage
    -- data.position_1 = btn_index * 2 - 1
    -- data.position_2 = btn_index * 2
    -- data.btn_index = btn_index
    -- data.refreshCallback = function()
    --     _table_view:reloadData()
    --     if _offset ~= nil then
    --         _table_view:setContentOffset(_offset)
    --     end
    -- end
    -- LordWarCheerLayer.show(data)
    --]]
end

--[[
	@desc:			查看战报按钮回调
	@return:		nil
--]]
function lookCallback(p_tag, p_menuItem)
    -- local btn_index = math.mod(tag, 1000)
    -- local rank = math.floor(tag / 1000)
    -- local round = LordWarData.getRoundByRoundRank(rank, _innerOrCross)
    -- local position_1 = btn_index * 2 - 1
    -- local position_2 = btn_index * 2
    -- local hero_1 = LordWarData.getProcessPromotionInfoBy(_lord_type, rank, position_1)
    -- local hero_2 = LordWarData.getProcessPromotionInfoBy(_lord_type, rank, position_2)
    -- local ret = 0
    -- if hero_1 ~= nil then
    --     ret = ret + 1
    -- end
    -- if hero_2 ~= nil then
    --     ret = ret + 1
    -- end
    -- if ret == 1 then
    --     SingleTip.showTip(GetLocalizeStringBy("key_8240"))
    -- elseif ret == 0 then
    --     SingleTip.showTip(GetLocalizeStringBy("key_8241"))
    -- else
    --     local lookCallFunc= function(ret)
    --         local fight_info = {}
    --         fight_info.hero_1 = hero_1
    --         fight_info.hero_2 = hero_2
    --         local is_inner = LordWarData.isInInner(_innerOrCross)
    --         require "script/ui/lordWar/warReport/WarReportLayer"
    --         WarReportLayer.showLayer(ret, _touch_priority - 600, _layer:getZOrder() + 10, is_inner, nil, nil, nil, nil, fight_info)
    --     end
    --     local teamType = LordWarData.getServerTeamType(_lord_type)
    --     LordWarService.getPromotionBtl(round, teamType, hero_1.serverId, hero_1.uid, hero_2.serverId, hero_2.uid, lookCallFunc)
    -- end
end