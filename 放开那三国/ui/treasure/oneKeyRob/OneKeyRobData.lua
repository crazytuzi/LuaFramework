-- FileName: OneKeyRobData.lua
-- Author: lichenyang
-- Date: 2014-04-00
-- Purpose: TM_FILENAME
--[[TODO List]]

module("OneKeyRobData", package.seeall)
require "db/DB_Loot"
local _info      = nil
local _cardInfo  = {} --翻牌信息
local costItemId = "10042"

function setInfo( pInfo )
	_info = pInfo
    --记录翻牌信息
    -- table.paste(_cardInfo, _info)
    _cardInfo.res = _info.res
    _cardInfo.detail = _cardInfo.detail or {}
    if _info.detail then
        for k,v in pairs(_info.detail) do
            table.insert(_cardInfo.detail, v)
        end
    end
    if _info.card then
        _cardInfo.card = _cardInfo.card or {}
        if _info.card.rob then
            _cardInfo.card.rob = _cardInfo.card.rob or 0
            _cardInfo.card.rob = _cardInfo.card.rob + tonumber(_info.card.rob)
        end
        if _info.card.gold then
            _cardInfo.card.gold = _cardInfo.card.gold or 0
            _cardInfo.card.gold = _cardInfo.card.gold + tonumber(_info.card.gold)
        end
        if _info.card.soul then
            _cardInfo.card.soul = _cardInfo.card.soul or 0
            _cardInfo.card.soul = _cardInfo.card.soul + tonumber(_info.card.soul)
        end
        if _info.card.silver then
            _cardInfo.card.silver = _cardInfo.card.silver or 0
            _cardInfo.card.silver = _cardInfo.card.silver + tonumber(_info.card.silver)
        end
        if _info.card.item then
            _cardInfo.card.item = _cardInfo.card.item or {}
            _cardInfo.card.item = table.add(_cardInfo.card.item, _info.card.item)
        end
        if _info.card.treasFrag then
            _cardInfo.card.treasFrag = _cardInfo.card.treasFrag or {}
            _cardInfo.card.treasFrag = table.add(_cardInfo.card.treasFrag, _info.card.treasFrag)
        end
    end
end

function getInfo()
	return _info
end

function clearCardInfo()
    _cardInfo = {}
end

function getCardInfo()
    return _cardInfo
end


function getRobTimes()
    if _info then
        return table.count(_info.detail)
    end
    return 0
end

function getStopErr()
    return _cardInfo.res
end

function getShowLevel()
    require "db/DB_Normal_config"
    local config = DB_Normal_config.getDataById(1).duobaodisplay_lv
    local showLevel = string.split(config, "|")[1]
    return tonumber(showLevel) or 55
end

function getUseLevel()
    require "db/DB_Normal_config"
    local config = DB_Normal_config.getDataById(1).duobaodisplay_lv
    local showLevel = string.split(config, "|")[2]
    return tonumber(showLevel) or 60
end

function getCostStamina()
    local itemStaminaNum = DB_Item_direct.getDataById(costItemId).endurance
    local costEndurance = tonumber(DB_Loot.getDataById(1).costEndurance)
    local itemNum = 0
    local costNum = 0
    if _info and _info.detail then
       for k,v in pairs(_info.detail) do
            if v.medicine then
                itemNum = itemNum + 1
            end
            costNum = costNum + costEndurance
       end
    end
    costNum = costNum - tonumber(itemStaminaNum)*itemNum
    return costNum
end

--[[
    @des    :奖励数据
    @param  :
    @return :
--]]
function getReward()
	local card = _cardInfo.card
	-- for k,v in pairs(_info.detail) do
	-- 	if v.card and v.card[1] then
	-- 		table.insert(card, v.card[1])
	-- 	end
	-- end
    printTable("card", card)
    local array_list = {} --存放奖励
    card.item = card.item or {}
    card.hero = card.hero or {}
    card.treasFrag = card.treasFrag or {}
    for k,v in pairs(card.item) do
        local itemInfo = {}
        itemInfo.type="item"
        itemInfo.num = v or 0
        itemInfo.tid = k
        array_list["item,"..k] = itemInfo
    end
    for k,v in pairs(card.hero) do
        local itemInfo = {}
        itemInfo.type="hero"
        itemInfo.num = v or 0
        itemInfo.tid = k
        array_list["hero,"..k] = itemInfo
    end
    for k,v in pairs(card.treasFrag) do
        local itemInfo = {}
        itemInfo.type="item"
        itemInfo.num = v or 0
        itemInfo.tid = k
        array_list["item,"..k] = itemInfo
    end
    if card.silver then
        local itemInfo = {}
        itemInfo.type = "silver"
        itemInfo.num = card.silver or 0
        itemInfo.tid = "silver,silver"
        array_list["silver,silver"] = itemInfo
    end

    if card.rob then
        local itemInfo = {}
        itemInfo.type = "silver"
        itemInfo.num = card.rob or 0
        itemInfo.tid = "silver,rob"
        array_list["silver,rob"] = itemInfo
    end

    if card.gold then
        local itemInfo = {}
        itemInfo.type = "gold"
        itemInfo.num = card.gold or 0
        itemInfo.tid = "gold,gold"
        array_list["gold,gold"] = itemInfo
    end

    if card.soul then
        local itemInfo = {}
        itemInfo.type = "soul"
        itemInfo.num = card.soul or 0
        itemInfo.tid = "soul,soul"
        array_list["soul,soul"] = itemInfo
    end
    return array_list
end