-- Filename: GuildWarSupportDialog.lua
-- Author: bzx
-- Date: 2015-1-19
-- Purpose: 助威

module("GuildWarSupportDialog", package.seeall)

require "script/ui/guildWar/support/GuildWarSupportService"
require "script/ui/guildWar/support/GuildWarSupportData"
require "script/ui/guildWar/support/GuildWarSupportController"

local _layer 
local _dialog
local _menu
local _data
local _touchPriority = -650
local _cheer_index
local _cheer_position
local _costData
local _zOrder

--[[
    data = {
        group               -- 组
        rank                -- 排名
        position1          -- 第一个英雄的位置
        position2          -- 第二个英雄的位置
        refreshCallback     -- 助威成功的回调
    }
--]]
function show(p_data, p_touchPriority, p_zOrder)
    local layer = create(p_data, p_touchPriority, p_zOrder)
    if layer ~= nil then
        CCDirector:sharedDirector():getRunningScene():addChild(layer, _zOrder)
    end
end

function init(p_data, p_touchPriority, p_zOrder)
    _touchPriority = p_touchPriority or -650
    _zOrder = p_zOrder or 150
    if GuildWarPromotionData.getGuildTrapeziumInfo(p_data.rank, p_data.position1) ~= nil then
        p_data.guildInfo1 = GuildWarPromotionData.getGuildTrapeziumInfo(p_data.rank, p_data.position1).guildInfo
    end
    if GuildWarPromotionData.getGuildTrapeziumInfo(p_data.rank, p_data.position2) ~= nil then
        p_data.guildInfo2 = GuildWarPromotionData.getGuildTrapeziumInfo(p_data.rank, p_data.position2).guildInfo
    end
    _data = p_data
    _layer = nil
    local result = 0
    result = result + (p_data.guildInfo1 == nil and 0 or 1)
    result = result + (p_data.guildInfo2 == nil and 0 or 1)
    if GuildWarPromotionData.myGuildIsPromoted() then
        SingleTip.showTip(GetLocalizeStringBy("key_8522"))
        return false
    end
    local _, cheerGuildId = GuildWarMainData.getCheerGuild()
    if cheerGuildId ~= 0  then
        SingleTip.showTip(GetLocalizeStringBy("key_8523"))
        return false
    end
    if result == 1 then
        SingleTip.showTip(GetLocalizeStringBy("key_8524"))
        return false
    elseif result == 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8525"))
        return false
    end
    return true
end

function create(p_data, p_touchPriority, p_zOrder)
    if init(p_data, p_touchPriority, p_zOrder) == true then
        loadDialog()
        loadVS()
        loadMenu()
        return _layer
    end
    return nil
end

function loadDialog()
    local dialog_info = {
        title = GetLocalizeStringBy("key_8248"),
        callbackClose = nil,
        size = CCSizeMake(630, 772),
        priority = _touchPriority,
        swallowTouch = true
    }
    _layer = LuaCCSprite.createDialog_1(dialog_info)
    _dialog = dialog_info.dialog
    --_layer:setAnchorPoint(ccp(0.5, 0.5))
    --_dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    --_dialog:setScale(MainScene.elementScale)
    return _layer
end

function loadVS()
    local bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _dialog:addChild(bg)
    bg:setPreferredSize(CCSizeMake(586, 533))
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 65))
    local guild1 = createGuildSprite(_data.guildInfo1)
    bg:addChild(guild1)
    guild1:setAnchorPoint(ccp(0.5, 0.5))
    guild1:setPosition(ccp(130, 355))
   
    local vs = CCSprite:create("images/arena/vs.png")
    bg:addChild(vs)
    vs:setAnchorPoint(ccp(0.5, 0.5))
    vs:setPosition(ccp(bg:getContentSize().width * 0.5, 355))
    
    local guild2 = createGuildSprite(_data.guildInfo2)
    bg:addChild(guild2)
    guild2:setAnchorPoint(ccp(0.5, 0.5))
    guild2:setPosition(ccp(455, 355))
   
    local line = CCSprite:create("images/common/line02.png")
    bg:addChild(line)
    line:setAnchorPoint(ccp(0.5, 0.5))
    line:setPosition(ccp(bg:getContentSize().width * 0.5, 120))
    line:setScaleX(4.8)
    
    local radio_data = {
        touch_priority  = _touchPriority - 1,
        space           = 300,
        callback        = function(tag, menu_item)
            require "script/audio/AudioUtil"
            AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
            _cheer_index = tag
        end,
        items           = {
            {normal = "images/common/btn/radio_normal.png", selected = "images/common/btn/radio_selected.png"},
            {normal = "images/common/btn/radio_normal.png", selected = "images/common/btn/radio_selected.png"},
        }
    }
    local radio_menu = LuaCCSprite.createRadioMenu(radio_data)
    bg:addChild(radio_menu)
    radio_menu:setAnchorPoint(ccp(0.5, 0.5))
    radio_menu:setPosition(ccp(bg:getContentSize().width * 0.5, 158))
    
    local tip =  CCRenderLabel:create(GetLocalizeStringBy("key_8249"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(tip)
    tip:setAnchorPoint(ccp(0, 0.5))
    tip:setPosition(ccp(13, 87))
    
    
    local createRewardNode = function(data)
        local nodes = {}
        nodes[1] = CCRenderLabel:create(tostring(data.count), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
        nodes[1]:setColor(ccc3(0x00, 0xff, 0x18))
        if data.icon ~= nil then
            nodes[2] = CCSprite:create(data.icon)
        else
            nodes[2] = CCLabelTTF:create("  ", g_sFontPangWa, 21)
        end
        nodes[3] = CCRenderLabel:create(data.name, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
        nodes[3]:setColor(ccc3(0x00, 0xff, 0x18))
        require "script/utils/BaseUI"
        return BaseUI.createHorizontalNode(nodes)
    end
    
    local cheer_rewards = GuildWarSupportData.getCheerRewards()
    local reward_datas = {}
    local icons = {}
    icons["silver"] = "images/common/coin_silver.png"
    icons["jewel"] = "images/common/jewel_small.png"
    icons["prestige"] = "images/common/prestige.png"
    local names = {}
    names["silver"] = GetLocalizeStringBy("key_8250")
    names["jewel"] = GetLocalizeStringBy("key_8251")
    names["prestige"] = GetLocalizeStringBy("key_8252")
    for k, v in pairs(cheer_rewards) do
        local reward_data = {}
        reward_data.count = v.num
        reward_data.icon = icons[v.type]
        reward_data.name = names[v.type] or v.name
        table.insert(reward_datas, reward_data)
    end
    local positions = {ccp(198, 44), ccp(363, 44), ccp(528, 44)}
    for i = 1, #reward_datas do
        local reward_data = reward_datas[i]
        local position = positions[i]
        local reward_node = createRewardNode(reward_data)
        bg:addChild(reward_node)
        reward_node:setAnchorPoint(ccp(1, 0.5))
        reward_node:setPosition(position)
    end
end


function createGuildSprite(p_guildInfo)
    local bg = CCSprite:create("images/lord_war/di.png")
    local center_x = 113
    local hero_name = CCRenderLabel:create(p_guildInfo.guild_name, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(hero_name)
    hero_name:setAnchorPoint(ccp(0.5, 0.5))
    hero_name:setPosition(ccp(center_x, 291))
    hero_name:setColor(ccc3(0xff, 0xf6, 0x00))
    
    local server_name = CCRenderLabel:create( string.format("（%s）", p_guildInfo.guild_server_name), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(server_name)
    server_name:setAnchorPoint(ccp(0.5, 0.5))
    server_name:setPosition(ccp(center_x, 263))
    
    -- local hero_icon_bg = CCSprite:create("images/everyday/headBg1.png")
    -- bg:addChild(hero_icon_bg)
    -- hero_icon_bg:setAnchorPoint(ccp(0.5, 0.5))
    -- hero_icon_bg:setPosition(ccp(center_x, 190))
    
    local hero_icon = GuildUtil.getGuildIcon(tonumber(p_guildInfo.guild_badge))
    bg:addChild(hero_icon)
    hero_icon:setAnchorPoint(ccp(0.5, 0.5))
    hero_icon:setPosition(ccp(center_x, 190))
    
    local lv_bg = CCScale9Sprite:create("images/common/bg/9s_7.png")
    bg:addChild(lv_bg)
    lv_bg:setPreferredSize(CCSizeMake(85, 23))
    lv_bg:setAnchorPoint(ccp(0.5, 0.5))
    lv_bg:setPosition(ccp(center_x, 119))
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_bg:addChild(lv_sprite)
    lv_sprite:setAnchorPoint(ccp(0, 0.5))
    lv_sprite:setPosition(ccp(3, lv_bg:getContentSize().height * 0.5))
    local level = p_guildInfo.guild_level or "0"
    local lv_label = CCRenderLabel:create(level, g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    lv_bg:addChild(lv_label)
    lv_label:setAnchorPoint(ccp(0, 0.5))
    lv_label:setPosition(ccp(44, lv_bg:getContentSize().height * 0.5))
    lv_label:setColor(ccc3(0xff, 0xf6, 0x00))
    
    local fight_value = {}
    fight_value[1] = CCSprite:create("images/common/fight_value02.png")
    fight_value[2] = CCRenderLabel:create(tostring(p_guildInfo.fight_force), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    fight_value[2]:setColor(ccc3(0xff, 0xf6, 0x00))
    local fight_value_node = BaseUI.createHorizontalNode(fight_value)
    bg:addChild(fight_value_node)
    fight_value_node:setAnchorPoint(ccp(0.5, 0.5))
    fight_value_node:setPosition(ccp(center_x, 72))
    return bg
end

function loadMenu()
    _menu = CCMenu:create()
    _dialog:addChild(_menu)
    _menu:setPosition(ccp(0, 0))
    _menu:setContentSize(_dialog:getContentSize())
    _menu:setTouchPriority(_touchPriority - 1)
    _costData = GuildWarSupportData.getCheerCost()
    local icon_image = nil
    if _costData.costType == 2 then
        icon_image = "images/common/gold.png"
    elseif _costData.costType == 1 then
        icon_image = "images/common/coin_silver.png"
    end
    local cheer_btn_data = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        disabled = nil,
        size = CCSizeMake(240, 73),
        icon = icon_image,
        text = GetLocalizeStringBy("key_8253"),
        number = tostring(_costData.costCount)
    }
    local cheer_btn = LuaCCSprite.createNumberMenuItem(cheer_btn_data)
    _menu:addChild(cheer_btn)
    cheer_btn:setAnchorPoint(ccp(0.5, 0.5))
    cheer_btn:setPosition(ccp(180, 82))
    cheer_btn:registerScriptTapHandler(GuildWarSupportController.cheerCallback)

    local cancel_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(240, 73), GetLocalizeStringBy("key_8254"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(cancel_btn)
    cancel_btn:setAnchorPoint(ccp(0.5, 0.5))
    cancel_btn:setPosition(ccp(_menu:getContentSize().width - cheer_btn:getPositionX(), 82))
    cancel_btn:registerScriptTapHandler(GuildWarSupportController.cancelCallback)
end

function getSelectedPosition( ... )
    local position = 0
    if _cheer_index == 1 then
        position = _data.guildInfo1.pos
    elseif _cheer_index == 2 then
        position = _data.guildInfo2.pos
    end
    return tonumber(position)
end

function getRank( ... )
    return _data.rank
end

function close( ... )
    if tolua.cast(_layer, "CCNode") then
        _layer:removeFromParentAndCleanup(true)
    end
end
