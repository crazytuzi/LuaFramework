-- Filename: LordWarCheerLayer.lua
-- Author: bzx
-- Date: 2014-08-07
-- Purpose: 助威

module("LordWarCheerLayer", package.seeall)

require "script/ui/lordWar/LordWarService"

local _layer 
local _dialog
local _menu
local _data
local _touch_priority = -650
local _cost_count
local _cost_type
local _cheer_index
local _cheer_position
--[[
    data = {
        group               -- 组
        rank                -- 排名
        position_1          -- 第一个英雄的位置
        position_2          -- 第二个英雄的位置
        refreshCallback     -- 助威成功的回调
    }
--]]
function show(p_data)
    local layer = create(p_data)
    if layer ~= nil then
        CCDirector:sharedDirector():getRunningScene():addChild(layer, 150)
    end
end

function init(p_data)
    p_data.hero_1 = LordWarData.getProcessPromotionInfoBy(p_data.group, p_data.rank, p_data.position_1)
    p_data.hero_2 = LordWarData.getProcessPromotionInfoBy(p_data.group, p_data.rank, p_data.position_2)
    local result = 0
    result = result + (p_data.hero_1 == nil and 0 or 1)
    result = result + (p_data.hero_2 == nil and 0 or 1)

    if LordWarData.is32() then
        SingleTip.showTip(GetLocalizeStringBy("key_8243"))
        return false
    end
    if not LordWarData.canCheer() then
        SingleTip.showTip(GetLocalizeStringBy("key_8244"))
        return false
    end
    if result == 1 then
        SingleTip.showTip(GetLocalizeStringBy("key_8245"))
        return false
    elseif result == 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8246"))
        return false
    end
    
    local curRoundStatus = LordWarData.getCurRoundStatus()
    if curRoundStatus == LordWarData.kRoundFighted then
        SingleTip.showTip(GetLocalizeStringBy("key_8247"))
        return false
    end 
    
    
    _data = p_data
    _layer = nil
    return true
end

function create(p_data)
    if init(p_data) == true then
        _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
        _layer:registerScriptHandler(onNodeEvent)
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
        callbackClose = closeCallback,
        size = CCSizeMake(630, 772),
        priority = _touch_priority - 1
    }
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)

end

function loadVS()
    local bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _dialog:addChild(bg)
    bg:setPreferredSize(CCSizeMake(586, 533))
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 65))
    local hero1 = createHero(_data.hero_1)
    bg:addChild(hero1)
    hero1:setAnchorPoint(ccp(0.5, 0.5))
    hero1:setPosition(ccp(130, 355))
   
    local vs = CCSprite:create("images/arena/vs.png")
    bg:addChild(vs)
    vs:setAnchorPoint(ccp(0.5, 0.5))
    vs:setPosition(ccp(bg:getContentSize().width * 0.5, 355))
    
    local hero2 = createHero(_data.hero_2)
    bg:addChild(hero2)
    hero2:setAnchorPoint(ccp(0.5, 0.5))
    hero2:setPosition(ccp(455, 355))
   
    local line = CCSprite:create("images/common/line02.png")
    bg:addChild(line)
    line:setAnchorPoint(ccp(0.5, 0.5))
    line:setPosition(ccp(bg:getContentSize().width * 0.5, 120))
    line:setScaleX(4.8)
    
    local radio_data = {
        touch_priority  = _touch_priority - 1,
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
    
    local cheer_rewards = LordWarData.getCheerRewards()
    local reward_datas = {}
    local icons = {}
    icons["silver"] = "images/common/coin_silver.png"
    icons["jewel"] = "images/common/jewel_small.png"
    icons["prestige"] = "images/common/prestige.png"
    icons["wm_num"] = "images/common/wm_small.png"
    local names = {}
    names["silver"] = GetLocalizeStringBy("key_8250")
    names["jewel"] = GetLocalizeStringBy("key_8251")
    names["prestige"] = GetLocalizeStringBy("key_8252")
    names["wm_num"] = GetLocalizeStringBy("lcyx_1912")
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


function createHero(hero_data)
    local bg = CCSprite:create("images/lord_war/di.png")
    local center_x = 113
    local hero_name = CCRenderLabel:create(hero_data.uname, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(hero_name)
    hero_name:setAnchorPoint(ccp(0.5, 0.5))
    hero_name:setPosition(ccp(center_x, 291))
    hero_name:setColor(ccc3(0xff, 0xf6, 0x00))
    
    local server_name = CCRenderLabel:create( string.format("（%s）", hero_data.serverName), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(server_name)
    server_name:setAnchorPoint(ccp(0.5, 0.5))
    server_name:setPosition(ccp(center_x, 263))
    
    local hero_icon_bg = CCSprite:create("images/everyday/headBg1.png")
    bg:addChild(hero_icon_bg)
    hero_icon_bg:setAnchorPoint(ccp(0.5, 0.5))
    hero_icon_bg:setPosition(ccp(center_x, 190))
    
    local hero_icon = HeroUtil.getHeroIconByHTID(tonumber(hero_data.htid), dressId,nil, hero_data.vip)
    hero_icon_bg:addChild(hero_icon)
    hero_icon:setAnchorPoint(ccp(0.5, 0.5))
    hero_icon:setPosition(ccpsprite(0.5, 0.5, hero_icon_bg))
    
    local lv_bg = CCScale9Sprite:create("images/common/bg/9s_7.png")
    bg:addChild(lv_bg)
    lv_bg:setPreferredSize(CCSizeMake(85, 23))
    lv_bg:setAnchorPoint(ccp(0.5, 0.5))
    lv_bg:setPosition(ccp(center_x, 119))
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_bg:addChild(lv_sprite)
    lv_sprite:setAnchorPoint(ccp(0, 0.5))
    lv_sprite:setPosition(ccp(3, lv_bg:getContentSize().height * 0.5))
    local level = hero_data.level or "0"
    local lv_label = CCRenderLabel:create(level, g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    lv_bg:addChild(lv_label)
    lv_label:setAnchorPoint(ccp(0, 0.5))
    lv_label:setPosition(ccp(44, lv_bg:getContentSize().height * 0.5))
    lv_label:setColor(ccc3(0xff, 0xf6, 0x00))
    
    local fight_value = {}
    fight_value[1] = CCSprite:create("images/common/fight_value02.png")
    fight_value[2] = CCRenderLabel:create(tostring(hero_data.fightForce), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    fight_value[2]:setColor(ccc3(0xff, 0xf6, 0x00))
    local fight_value_node = BaseUI.createHorizontalNode(fight_value)
    bg:addChild(fight_value_node)
    fight_value_node:setAnchorPoint(ccp(0.5, 0.5))
    fight_value_node:setPosition(ccp(center_x, 72))
    
    --[[
    local cheers = {}
    cheers[1] = CCRenderLabel:create("支持人数:", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    cheers[2] = CCRenderLabel:create("90", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    cheers[2]:setColor(ccc3(0x00, 0xff, 0x18))
    local cheers_node = BaseUI.createHorizontalNode(cheers)
    bg:addChild(cheers_node)
    cheers_node:setAnchorPoint(ccp(0.5, 0.5))
    cheers_node:setPosition(ccp(center_x, 37))
    --]]
    return bg
end

function loadMenu()
    _menu = CCMenu:create()
    _dialog:addChild(_menu)
    _menu:setPosition(ccp(0, 0))
    _menu:setContentSize(_dialog:getContentSize())
    _menu:setTouchPriority(_touch_priority - 1)
    local cost = LordWarData.getCheerCost()
    _cost_type = cost[1]
    _cost_count = cost[2]
    local icon_image = nil
    if _cost_type == 2 then
        icon_image = "images/common/gold.png"
    elseif _cost_type == 1 then
        icon_image = "images/common/coin_silver.png"
    end
    local cheer_btn_data = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        disabled = nil,
        size = CCSizeMake(240, 73),
        icon = icon_image,
        text = GetLocalizeStringBy("key_8253"),
        number = tostring(_cost_count)
    }
    local cheer_btn = LuaCCSprite.createNumberMenuItem(cheer_btn_data)
    _menu:addChild(cheer_btn)
    cheer_btn:setAnchorPoint(ccp(0.5, 0.5))
    cheer_btn:setPosition(ccp(180, 82))
    cheer_btn:registerScriptTapHandler(cheerCallback)

    local cancel_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(240, 73), GetLocalizeStringBy("key_8254"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(cancel_btn)
    cancel_btn:setAnchorPoint(ccp(0.5, 0.5))
    cancel_btn:setPosition(ccp(_menu:getContentSize().width - cheer_btn:getPositionX(), 82))
    cancel_btn:registerScriptTapHandler(cancelCallback)
end

function cheerCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if _cost_type == 1 then
        if _cost_count > UserModel.getSilverNumber() then
            SingleTip.showTip(GetLocalizeStringBy("key_8255"))
            return
        end
    elseif _cost_type == 2 then
        if _cost_count > UserModel.getGoldNumber() then
            SingleTip.showTip(GetLocalizeStringBy("key_8256"))
            return
        end
    end
    if _cheer_index == 1 then
        _cheer_position = _data.position_1
    elseif _cheer_index == 2 then
        _cheer_position = _data.position_2
    end
    local cheered_hero = LordWarData.getProcessPromotionInfoBy(_data.group, _data.rank, _cheer_position)
    require "script/model/user/UserModel"
    if cheered_hero.serverId == LordWarData.getMyServerId() and cheered_hero.uid == tostring(UserModel.getUserUid()) then
        SingleTip.showTip(GetLocalizeStringBy("key_8257"))
        return
    end
    local serviceTeamType = LordWarData.getServerTeamType(_data.group)
    LordWarService.support(cheered_hero.serverPos - 1, serviceTeamType, handleCheer)
end

function handleCheer()
    if _cost_type == 1 then
        UserModel.addSilverNumber(-_cost_count)
    elseif _cost_type == 2 then
        UserModel.addGoldNumber(-_cost_count)
    end
    local cheered_hero = LordWarData.getProcessPromotionInfoBy(_data.group, _data.rank, _cheer_position)
    print(cheered_hero.serverId, cheered_hero.uid)
    LordWarData.setCheerInfo(cheered_hero.serverId, cheered_hero.uid)
    if _data.refreshCallback ~= nil then
        _data.refreshCallback(_data.rank, _cheer_position)
    end
    close()
    SingleTip.showTip(GetLocalizeStringBy("key_8258"))
end

function cancelCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    close()
end

function onTouchesHandler(event)
    return true
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function closeCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    close()
end

function close()
    if _layer ~= nil then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
end