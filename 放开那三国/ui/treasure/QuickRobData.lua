
-- Filename：    QuickData.lua
-- Author：      DJN
-- Date：        2014-7-8
-- Purpose：     连续抢夺数据函数
module("QuickRobData", package.seeall)
local _QuickRobInfo
local _itemid
--[[
    @des    :设置连续抢夺结果数据
    @param  :
    @return :
--]]
function setQuickRobData( listData )
    _QuickRobInfo = listData  
    
end
--[[
    @des    :得到连续抢夺数据
    @param  :
    @return :
--]]
function getQuickRobData( ... )
    
    return _QuickRobInfo
end
--[[
    @des    :更新奖励的银币和经验
    @param  :
    @return :
--]]
function UpdateSilverInReward( items )
   
    local silver = 0
    if(items.reward.silver ~=nil )then
        silver = silver + tonumber(items.reward.silver)
    end
    if(silver~=0) then
        UserModel.addSilverNumber(silver)
    end

    local exp = 0
    if(items.reward.exp ~=nil )then
        exp = exp + tonumber(items.reward.exp)
    end
    if(exp~=0) then
        UserModel.addExpValue(exp)
    end
end

--[[
    @des    :更新翻牌的金币，银币，武魂
    @param  :
    @return :
--]]
function UpdateSilverInCard( items )
    local donum = tonumber(items.donum)
    local card = items.card
    if(table.isEmpty(card) == true)then
        return
    end
    local gold = 0
    local silver = 0
    local soul = 0
    for i = 1 ,donum do
        if(card[i].gold ~= nil )then
        gold = gold + tonumber(card[i].gold)
        end
        if(card[i].silver ~=nil )then
        silver = silver + tonumber(card[i].silver)
        end
        if(card[i].rob ~=nil )then
        silver = silver + tonumber(card[i].rob)
        end
        if(card[i].soul ~=nil )then
        soul = soul + tonumber(card[i].soul)
        end

    end

    require "script/model/user/UserModel"
    if(gold ~=0) then 
        UserModel.addGoldNumber(gold)
    end
    if(silver~=0) then
        UserModel.addSilverNumber(silver)
    end
    if(soul ~=0) then 
        UserModel.addSoulNum(soul)
    end
end
--[[
    @des    :记录欲抢夺的碎片，在抢到后做展示使用
    @param  :
    @return :
--]]
function setItemid( id )
    _itemid = id
end
--[[
    @des    :获取当时欲抢夺的碎片
    @param  :
    @return :
--]]
function getItemid( ... )
    return _itemid 
    
end




