-- Filename: TreasureDialog.lua
-- Author: bzx
-- Date: 2014-06-13
-- Purpose: 寻龙探宝各种事件的对话框

module("TreasureDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/forge/FindTreasureData"
require "script/libs/LuaCCSprite"
require "script/model/utils/HeroUtil"

local _layer
local _event
local _touch_priority   = -450
local _z                = 1000
local _args
local _could_move       = false
local _isFromDescLayer

function show(event, args, touch_priority)
    _touch_priority = touch_priority or -450
    -- test
    --event = DB_Explore_long_event.getDataById(20001)
    create(event, args)
    if _layer ~= nil then
        CCDirector:sharedDirector():getRunningScene():addChild(_layer, _z)
    end
end

function previewTreasure(event, could_move, args, isFromDescLayer, touch_priority)
    _touch_priority = touch_priority or -450
    createPreview(event, could_move, args, isFromDescLayer)
    if _layer ~= nil then
        CCDirector:sharedDirector():getRunningScene():addChild(_layer, _z)
    end
end

function init(event, args, isFromDescLayer)
    local event_db = DB_Explore_long_event.getDataById(event.id)
    event.pointTips = string.split(event_db.pointTips, "|")
    event.exploreExplain = string.split(event_db.exploreExplain, "|")
    _event = event
    _args = args
    _layer = nil
    _isFromDescLayer = isFromDescLayer or false
end

function createPreview(event, could_move, args, isFromDescLayer)
    init(event, args, isFromDescLayer)
    _could_move = could_move
    local dialog_info = {
        title = "images/forge/sjts.png"
    }
    
    local dialog = createBaseDialog(dialog_info, true)
    dialog:setScale(MainScene.elementScale)
    dialog:setAnchorPoint(ccp(0.5, 0.5))
    dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:addChild(dialog)
    _layer:registerScriptHandler(onNodeEvent)
    
    
    
    local icon = CCSprite:create("images/forge/treasure_icon/" .. _event.isIcon)
    dialog:addChild(icon)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(ccp(260, 210))
    
    
    local name_label = CCRenderLabel:create(_event.pointTips[1], g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog:addChild(name_label)
    name_label:setColor(ccc3(0x00, 0xff, 0x18))
    name_label:setAnchorPoint(ccp(0, 1))
    name_label:setPosition(ccp(310, 260))
    local text = _event.pointTips[2]
    local desc = CCLabelTTF:create(text, g_sFontPangWa, 21)
    dialog:addChild(desc)
    desc:setAnchorPoint(ccp(0, 1))
    desc:setPosition(ccp(310, 225))
    desc:setDimensions(CCSizeMake(280, 300))
    desc:setHorizontalAlignment(kCCTextAlignmentLeft)
    desc:setColor(ccc3(0xff, 0xf6, 0x00))
    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))

    local confirm_btn = nil
    if could_move then
        confirm_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8140"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        menu:addChild(confirm_btn)
        confirm_btn:setAnchorPoint(ccp(0.5, 0.5))
        confirm_btn:setPosition(ccp(384, 68))
        local goCallback = function()
            closeCallback()
            if _args.moveCallFunc ~= nil then
                _args.moveCallFunc()
            end
        end
        confirm_btn:registerScriptTapHandler(goCallback)

    else
        confirm_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8141"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        menu:addChild(confirm_btn)
        confirm_btn:setAnchorPoint(ccp(0.5, 0.5))
        confirm_btn:setPosition(ccp(384, 68))
        confirm_btn:registerScriptTapHandler(closeCallback)
    end
    if event.exploreType == 8 and _isFromDescLayer == false then
        local lookBossesItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8470"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        menu:addChild(lookBossesItem)
        lookBossesItem:setAnchorPoint(ccp(0.5, 0.5))
        lookBossesItem:setPosition(ccp(300, 68))
        lookBossesItem:registerScriptTapHandler(lookBossesCallback)
        confirm_btn:setPosition(ccp(470, 68))
    end

    return _layer
end

function lookBossesCallback( ... )
    FindTreasureTrialLayer.show(_touch_priority - 10, 1000, _event.id, true, FindTreasureLayer.backFromTrialLayerCallback)
    _layer:removeFromParentAndCleanup(true)
end

function create(event, args)
    init(event, args)
    local dialog = nil
    if event.exploreType == 1 then
        dialog = createDoubleDialog()
    elseif event.exploreType == 2 then
        dialog = createFightDialog()
    elseif event.exploreType == 3 or event.exploreType == 5 then
        dialog = createNormalDialog()
    elseif event.exploreType == 4 then
        dialog = createAnswerDialog()
    elseif event.exploreType == 6 then
        dialog = createShopDialog()
    elseif event.exploreType == 7 then
        dialog = createContributeDialog()
    end
    if dialog ~= nil then
        dialog:setScale(MainScene.elementScale)
        dialog:setAnchorPoint(ccp(0.5, 0.5))
        if event.exploreType == 6 then
            dialog:setPosition(ccp(g_winSize.width * 0.5 + 15 * MainScene.elementScale, g_winSize.height * 0.5 - 70 * MainScene.elementScale))
        else
            dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
        end
        _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
        _layer:addChild(dialog)
        _layer:registerScriptHandler(onNodeEvent)
        return _layer
    else
        executeCallFunc()
    end
    return nil
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

-- 普通
function createNormalDialog()
    local dialog_info = {
        title = "images/forge/sj.png",
    }
    dialog_info.tip_node = CCRenderLabel:create(GetLocalizeStringBy("key_8142"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog_info.tip_node:setColor(ccc3(0xff, 0xf6, 0x00))
    local dialog = createBaseDialog(dialog_info)
    
    local icon = CCSprite:create("images/forge/treasure_icon/" .. _event.isIcon)
    dialog:addChild(icon)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(ccp(295, 210))
    local name_label = CCRenderLabel:create(_event.exploreExplain[1], g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog:addChild(name_label)
    name_label:setColor(ccc3(0xff, 0xf6, 0x00))
    name_label:setAnchorPoint(ccp(0, 1))
    name_label:setPosition(ccp(348, 260))
    local desc = CCLabelTTF:create(_event.exploreExplain[2], g_sFontPangWa, 21)
    dialog:addChild(desc)
    desc:setAnchorPoint(ccp(0, 0.5))
    desc:setPosition(ccp(348, 170))
    desc:setDimensions(CCSizeMake(240, 110))
    desc:setHorizontalAlignment(kCCTextAlignmentLeft)
    desc:setColor(ccc3(0xff, 0xf6, 0x00))
    local point_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8143"), _event.integralReward[2]), g_sFontPangWa, 21)
    dialog:addChild(point_label)
    point_label:setAnchorPoint(ccp(0, 0.5))
    point_label:setPosition(ccp(275, 140))
    point_label:setColor(ccc3(0x00, 0xff, 0x18))
    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    local confirm_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8144"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(confirm_btn)
    confirm_btn:setAnchorPoint(ccp(0.5, 0.5))
    confirm_btn:setPosition(ccp(375, 68))
    confirm_btn:registerScriptTapHandler(closeCallback)
    return dialog
end

-- 战斗
function createFightDialog()
     local dialog_info = {
        title = "images/forge/zd.png",
    }
    local name = nil
    local enemy_head = nil
    local move_data = FindTreasureData.getMoveData()
    local enemy_data = move_data.other.fb
    enemy_data.dress = enemy_data.dress or {}
    require "db/DB_Army"
    require "script/ui/arena/ArenaData"
    require "db/DB_Monsters"
    require "db/DB_Team"
    if enemy_data == nil then
        print("fuck=", move_data.other.sj)
        local army_db = DB_Army.getDataById(tonumber(move_data.other.sj))
        local team_db = DB_Team.getDataById(army_db.monster_group)
        local monsters_id = string.split(team_db.monsterID, ',')[1]
        enemy_data = DB_Monsters.getDataById(monsters_id)
        enemy_head = HeroUtil.getHeroIconByHTID(enemy_data.htid, nil, tonumber(enemy_data.utid))
        name = army_db.display_name
    elseif enemy_data.isNpc == "true" or enemy_data.isNpc == true then
        enemy_head =  ArenaData.getNpcIconByhid(tonumber(enemy_data.htid[1]))
        name = ArenaData.getNpcName(enemy_data.uid, enemy_data.utid)
    else
        enemy_head = HeroUtil.getHeroIconByHTID(enemy_data.htid, enemy_data.dress["1"] , tonumber(enemy_data.utid))
        name = enemy_data.uname
    end
    -- local tip = {}
    -- tip[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8145"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    -- tip[1]:setColor(ccc3(0xff, 0xf6, 0x00))
    -- if g_system_type == kBT_PLATFORM_WP8 then
    --     tip[2] = CCLabelTTF:create(name, g_sFontPangWa, 23)
    -- else
    --     tip[2] = CCRenderLabel:create(name, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    -- end
    -- tip[2]:setColor(ccc3(0x00, 0xe4, 0xff))
    -- tip[3] =  CCRenderLabel:create("！", g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    -- tip[3]:setColor(ccc3(0xff, 0xf6, 0x00))
    -- dialog_info.tip_node = BaseUI.createHorizontalNode(tip)
    dialog_info.type = "fight"
    dialog_info.tip_node = CCRenderLabel:create(GetLocalizeStringBy("key_8145"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog_info.tip_node:setColor(ccc3(0xff, 0xf6, 0x00))

    local nameTip = {}
    if g_system_type == kBT_PLATFORM_WP8 then
        nameTip[1] = CCLabelTTF:create(name, g_sFontPangWa, 23)
    else
        nameTip[1] = CCRenderLabel:create(name, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    end
    nameTip[1]:setColor(ccc3(0x00, 0xe4, 0xff))
    nameTip[2] =  CCRenderLabel:create("！", g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    nameTip[2]:setColor(ccc3(0xff, 0xf6, 0x00))


    local dialog = createBaseDialog(dialog_info)--LuaCCSprite.createDialog_1(dialog_info)
    local nameNode = BaseUI.createHorizontalNode(nameTip)
    dialog:addChild(nameNode)
    nameNode:setAnchorPoint(ccp(0.5, 0.5))
    nameNode:setPosition(ccp(379, 270))
    local player_head = HeroUtil.getHeroIconByHTID(UserModel.getAvatarHtid(), UserModel.getDressIdByPos("1"), UserModel.getUserSex())
    dialog:addChild(player_head)
    player_head:setAnchorPoint(ccp(0.5, 0.5))
    player_head:setPosition(ccp(268, 190))
    local player_name_label = nil
    if g_system_type == kBT_PLATFORM_WP8 then
        player_name_label = CCLabelTTF:create(UserModel.getUserName(), g_sFontPangWa, 22)
    else
        player_name_label = CCRenderLabel:create(UserModel.getUserName(), g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_shadow)
    end
    player_head:addChild(player_name_label)
    player_name_label:setAnchorPoint(ccp(0.5, 1))
    player_name_label:setPosition(ccp(player_head:getContentSize().width * 0.5, 2))
    player_name_label:setColor(ccc3(0xff, 0xf6, 0x00))
    
    local vs_sprite = CCSprite:create("images/arena/vs.png")
    dialog:addChild(vs_sprite)
    vs_sprite:setAnchorPoint(ccp(0.5, 0.5))
    vs_sprite:setPosition(ccp(379, 190))



    dialog:addChild(enemy_head)
    enemy_head:setAnchorPoint(ccp(0.5, 0.5))
    enemy_head:setPosition(ccp(490, 190))
    local enemy_name_label = nil
    if g_system_type == kBT_PLATFORM_WP8 then
        enemy_name_label = CCLabelTTF:create(name, g_sFontPangWa, 22)
    else
        enemy_name_label = CCRenderLabel:create(name, g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_shadow)  
    end
    enemy_head:addChild(enemy_name_label)
    enemy_name_label:setAnchorPoint(ccp(0.5, 1))
    enemy_name_label:setPosition(ccp(enemy_head:getContentSize().width * 0.5, 2))
    enemy_name_label:setColor(ccc3(0xff, 0xf6, 0x00))

    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    local fight_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8146"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(fight_btn)
    fight_btn:setAnchorPoint(ccp(0.5, 0.5))
    fight_btn:setPosition(ccp(260, 68))
    local handleFight = function(dictData)
        FindTreasureLayer.refreshHp()
        FindTreasureLayer.refreAddtion(0)
        closeCallback()
        require "script/ui/forge/FightResultLayer"
        local result_layer = FightResultLayer.create(dictData.ret.atkRet.server.appraisal, FindTreasureLayer.playBgm, _event)
        require "script/battle/BattleLayer"
        BattleLayer.showBattleWithString(dictData.ret.atkRet.client, nil, result_layer, "xunlong.jpg",nil,nil,nil,nil,true)
    end
    local fightCallback = function()
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

        FindTreasureService.dragonFight(handleFight, {_event.id})
    end
    fight_btn:registerScriptTapHandler(fightCallback)
    local bribe_btn_data = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        size = CCSizeMake(260, 73),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_8147"),
        number = tostring(_event.completePay)
    }
    local bribe_btn = LuaCCSprite.createNumberMenuItem(bribe_btn_data)
    menu:addChild(bribe_btn)
    bribe_btn:setAnchorPoint(ccp(0.5, 0.5))
    bribe_btn:setPosition(ccp(490, 68))
    local handleBribe = function()
          SingleTip.showTip(string.format(GetLocalizeStringBy("key_8148"), _event.integralReward[8][2]))
          FindTreasureLayer.refreshPoint()
          closeCallback()
    end
    local bribeCallback = function()
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
        if _event.completePay > UserModel.getGoldNumber() then
            SingleTip.showTip(GetLocalizeStringBy("key_8130"))
            return
        end
        FindTreasureService.dragonBribe(handleBribe, {_event.id}, _event)
    end
    bribe_btn:registerScriptTapHandler(bribeCallback)
    return dialog
end

-- 宝物
function createDoubleDialog()
     local dialog_info = {
        title = "images/forge/bz.png",
    }
    dialog_info.tip_node = CCRenderLabel:create(GetLocalizeStringBy("key_8149"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog_info.tip_node:setColor(ccc3(0xff, 0xf6, 0x00))

    require "db/DB_Item_normal"
    local dialog = createBaseDialog(dialog_info)
    local move_data = FindTreasureData.getMoveData()
    local item_id = nil
    local item_count = nil
    for k, v in pairs(move_data.other.drop.item) do
       item_id = tonumber(k)
       item_count = tonumber(v)
    end
    local item_normal = DB_Item_normal.getDataById(item_id)
    local goodsValues = {}
    goodsValues.type = "item"
    goodsValues.tid = item_id
    goodsValues.num = item_count
    local icon= ItemUtil.createGoodsIcon(goodsValues, -435, 1010, -450, nil)
    dialog:addChild(icon)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(ccp(288, 190))
    
    local name_label = CCRenderLabel:create(item_normal.name, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    name_label:setColor(ccc3(0xff, 0xf6, 0x00))
    name_label:setAnchorPoint(ccp(0.5, 1))
    name_label:setPosition(ccp(icon:getContentSize().width * 0.5, -8))
    local desc = CCLabelTTF:create(item_normal.desc, g_sFontPangWa, 21)
    dialog:addChild(desc)
    desc:setAnchorPoint(ccp(0, 0.5))
    desc:setPosition(ccp(348, 190))
    desc:setDimensions(CCSizeMake(240, 110))
    desc:setHorizontalAlignment(kCCTextAlignmentLeft)
    local point_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8143"), _event.integralReward[2]), g_sFontPangWa, 21)
    dialog:addChild(point_label)
    point_label:setAnchorPoint(ccp(0, 0.5))
    point_label:setPosition(ccp(348, 155))
    point_label:setColor(ccc3(0x00, 0xff, 0x18))
    
    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    local continue_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(175, 73), GetLocalizeStringBy("key_8150"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(continue_btn)
    continue_btn:setAnchorPoint(ccp(0.5, 0.5))
    continue_btn:setPosition(ccp(375, 68))
    continue_btn:registerScriptTapHandler(skipCallback)

    return dialog
end

-- 答题
function createAnswerDialog()
    local dialog_info = {
        title = "images/forge/dt.png",
    }
    dialog_info.tip_node = CCRenderLabel:create(GetLocalizeStringBy("key_8151"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog_info.tip_node:setColor(ccc3(0xff, 0xf6, 0x00))
    local dialog = createBaseDialog(dialog_info)
    local icon = CCSprite:create("images/forge/treasure_icon/" .. _event.isIcon)
    dialog:addChild(icon)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(ccp(288, 210))
    local answer_id = _event.exploreConditions[2]
    require "db/DB_Explore_long_answer"
    answer_db = DB_Explore_long_answer.getDataById(answer_id)
    local sure_answer = ""
    if answer_db["true"] == "2" then
        sure_answer = answer_db.answerB
    elseif answer_db["true"] == "1" then
        sure_answer = answer_db.answerA
    else
        print("DB_Explore_long_answer表有误")
    end
    local questions_desc = answer_db.questions
    require "db/DB_Vip"
    local vip_db = DB_Vip.getDataById(UserModel.getVipLevel() + 1)
    if vip_db.treasure_answer == 1 then
        questions_desc = string.format("%s[%s]", questions_desc, sure_answer)
    end
    local desc = CCLabelTTF:create(questions_desc, g_sFontPangWa, 21)
    dialog:addChild(desc)
    desc:setAnchorPoint(ccp(0, 0.5))
    desc:setPosition(ccp(348, 200))
    desc:setDimensions(CCSizeMake(240, 110))
    desc:setHorizontalAlignment(kCCTextAlignmentLeft)
    local selected_answer_index = nil
    local radio_data = {
        touch_priority  = _touch_priority - 1,
        space           = 150,
        callback        = function(tag, menu_item)
            require "script/audio/AudioUtil"
            AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
            selected_answer_index = tag
        end,
        items           ={
            {normal = "images/common/btn/radio_normal.png", selected = "images/common/btn/radio_selected.png"},
            {normal = "images/common/btn/radio_normal.png", selected = "images/common/btn/radio_selected.png"},
        }
    }
    local radio_menu = LuaCCSprite.createRadioMenu(radio_data)
    dialog:addChild(radio_menu)
    radio_menu:setAnchorPoint(ccp(0, 0))
    radio_menu:setPosition(ccp(230, 115))
    local answer_A = CCLabelTTF:create(answer_db.answerA, g_sFontPangWa, 21)
    dialog:addChild(answer_A)
    answer_A:setAnchorPoint(ccp(0, 0.5))
    answer_A:setPosition(ccp(280, 140))
    answer_A:setColor(ccc3(0x00, 0xff, 0x18))
    local answer_B = CCLabelTTF:create(answer_db.answerB, g_sFontPangWa, 21)
    dialog:addChild(answer_B)
    answer_B:setAnchorPoint(ccp(0, 0.5))
    answer_B:setPosition(ccp(475, 140))
    answer_B:setColor(ccc3(0x00, 0xff, 0x18))
    
    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    local confirm_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(175, 73), GetLocalizeStringBy("key_8152"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(confirm_btn)
    confirm_btn:setAnchorPoint(ccp(0.5, 0.5))
    confirm_btn:setPosition(ccp(247, 68))
    local handleConfirm = function(dictData, add_point)
        if dictData.ret == "true" or dictData.ret == true then
            SingleTip.showTip(string.format(GetLocalizeStringBy("key_8153"), add_point))
        elseif dictData.ret == "false" or dictData.ret == true then
            SingleTip.showTip(string.format(GetLocalizeStringBy("key_8154"), add_point))
        end
        FindTreasureLayer.refreshPoint()
        closeCallback()
    end
    local confirmCallback = function()
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        FindTreasureService.dragonAnswer(handleConfirm, {_event.id, selected_answer_index}, _event)
    end
    confirm_btn:registerScriptTapHandler(confirmCallback)
    local item_info = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        size = CCSizeMake(260, 73),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_8155"),
        number = tostring(_event.completePay)
    }
    if vip_db.treasure_answer ~= 1 then
        local one_key_btn = LuaCCSprite.createNumberMenuItem(item_info)
        menu:addChild(one_key_btn)
        one_key_btn:setAnchorPoint(ccp(0.5, 0.5))
        one_key_btn:setPosition(ccp(475, 68))
        local handleOneKey = function()
            SingleTip.showTip(string.format(GetLocalizeStringBy("key_8153"), _event.integralReward[1][2]))
            closeCallback()
            FindTreasureLayer.refreshPoint()

        end
        local oneKeyCallback = function()
            require "script/audio/AudioUtil"
            AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
            if UserModel.getGoldNumber() < _event.completePay then
                require "script/ui/tip/LackGoldTip"
                LackGoldTip.showTip()
                return
            end
             FindTreasureService.dragonOnekey(handleOneKey, {_event.id}, _event)
        end
        one_key_btn:registerScriptTapHandler(oneKeyCallback)
    else
        confirm_btn:setPosition(ccp(384, 68))
    end
    return dialog
end

-- 商人
function createShopDialog( ... )
    local dialog = CCScale9Sprite:create("images/forge/dialog_9s.png")
    dialog:setPreferredSize(CCSizeMake(572, 762))
    local beautifulGirl = CCSprite:create("images/forge/meizi.png")
    dialog:addChild(beautifulGirl)
    beautifulGirl:setPosition(ccp(-75, dialog:getContentSize().height - 300))

    local title = CCSprite:create("images/forge/sr.png")
    dialog:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccpsprite(0.5, 1, dialog))

    local titleTip = CCRenderLabel:create(GetLocalizeStringBy("key_8457"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog:addChild(titleTip)
    titleTip:setColor(ccc3(0xff, 0xf6, 0x00))
    titleTip:setAnchorPoint(ccp(0, 0.5))
    titleTip:setPosition(ccp(180, dialog:getContentSize().height - 40))
    local shopData = FindTreasureData.getShopData(_event)
    local cellSize = CCSizeMake(540, 202)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            r = createShopCell(a1 + 1, shopData[a1 + 1])
        elseif fn == "numberOfCells" then
            r = #shopData
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
        end
        return r
    end)
    local shopTableView = LuaTableView:createWithHandler(h, CCSizeMake(544, 603))
    dialog:addChild(shopTableView)
    shopTableView:setAnchorPoint(ccp(0.5, 0))
    shopTableView:setPosition(ccp(dialog:getContentSize().width * 0.5, 109))
    shopTableView:ignoreAnchorPointForPosition(false)
    --_myTableView:setBounceable(true)
    shopTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- _myTableView:setScale(1/_bgLayer:getElementScale()
    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touch_priority - 5)
    local leaveItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8452"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(leaveItem)
    leaveItem:setAnchorPoint(ccp(0.5, 0.5))
    leaveItem:setPosition(ccp(dialog:getContentSize().width * 0.5, 68))
    leaveItem:registerScriptTapHandler(skipCallback)
    return dialog
end

function createShopCell( index, shopData )
    local shopDb = DB_Explore_long_event_shop.getDataById(shopData.id)
    local cell = CCTableViewCell:create()
    local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBg:setContentSize(CCSizeMake(541, 190))
    cell:setContentSize(cellBg:getContentSize())
    cell:addChild(cellBg)

    local titlebg = CCSprite:create("images/reward/cell_title_panel.png")
    titlebg:setAnchorPoint(ccp(0, 1))
    titlebg:setPosition(ccp(0, cellBg:getContentSize().height + 10))
    cellBg:addChild(titlebg)

    local title = CCRenderLabel:create(GetLocalizeStringBy("key_8458"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    titlebg:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccpsprite(0.5, 0.52, titlebg))

    -- todo
    local itemBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
    cellBg:addChild(itemBg)
    itemBg:setPreferredSize(CCSizeMake(336, 123))
    itemBg:setAnchorPoint(ccp(0, 0))
    itemBg:setPosition(ccp(26, 21))
    local itemData = parseField(shopDb.item)
    local itemType = itemData[1]
    local itemId = itemData[2]
    local itemCount = itemData[3]
    local item = ItemSprite.getItemSpriteById(itemId, nil, nil, nil, _touch_priority - 5, nil, _touch_priority- 20)
    cellBg:addChild(item)
    item:setAnchorPoint(ccp(0, 0))
    item:setPosition(ccp(43, 48))

    local itemName = ItemUtil.getItemNameByItmTid(itemId)
    local itemNameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    item:addChild(itemNameLabel)
    itemNameLabel:setAnchorPoint(ccp(0.5, 0.5))
    itemNameLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    itemNameLabel:setPosition(ccpsprite(0.5, -0.1, item))

    local labelCount = CCRenderLabel:create(tostring(itemCount), g_sFontPangWa, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    item:addChild(labelCount)
    labelCount:setAnchorPoint(ccp(1, 0))
    labelCount:setPosition(ccp(item:getContentSize().width - 4, 3))
    labelCount:setColor(ccc3(0x00, 0xff, 0x18))

    local hotTag = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/remai/remai"), -1,CCString:create(""))
    hotTag:setPosition(ccp(-5, item:getContentSize().height - 15))
    item:addChild(hotTag)

    local oldRichInfo = {}
    oldRichInfo.lineAlignment = 2
    oldRichInfo.labelDefaultColor = ccc3(0xab, 0xab, 0xab)
    oldRichInfo.labelDefaultSize = 21
    oldRichInfo.defaultType = "CCRenderLabel"
    oldRichInfo.elements = {
        {
            type = "CCSprite",
            image = "images/common/gold.png"
        },
        {
            text = tostring(shopDb.originalcost),
            color = ccc3(0xff, 0xf6, 0x00)
        }
    }
    local oldPrice = GetLocalizeLabelSpriteBy_2("key_8459", oldRichInfo)
    itemBg:addChild(oldPrice)
    oldPrice:setAnchorPoint(ccp(0, 0.5))
    oldPrice:setPosition(ccp(147, 90))
    local line = CCSprite:create("images/recharge/limit_shop/no_more.png")
    oldPrice:addChild(line)
    line:setPosition(ccp(-10, 10))

    local newRichInfo = {}
    newRichInfo.lineAlignment = 2
    newRichInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
    newRichInfo.labelDefaultSize = 21
    newRichInfo.defaultType = "CCRenderLabel"
    newRichInfo.elements = {
        {
            type = "CCSprite",
            image = "images/common/gold.png"
        },
        {
            text = tostring(shopDb.nowcost),
        }
    }
    local newPrice = GetLocalizeLabelSpriteBy_2("key_8460", newRichInfo)
    itemBg:addChild(newPrice)
    newPrice:setAnchorPoint(ccp(0, 0.5))
    newPrice:setPosition(ccp(147, 55))

    local pointTipRichInfo = {}
    pointTipRichInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
    pointTipRichInfo.labelDefaultSize = 18
    pointTipRichInfo.defaultType = "CCRenderLabel"
    pointTipRichInfo.elements = {
        {
            text = tostring(shopDb.eachpoint),
            color = ccc3(0x00, 0xff, 0x18)
        }
    }
    local pointTip = GetLocalizeLabelSpriteBy_2("key_8461", pointTipRichInfo)
    itemBg:addChild(pointTip)
    pointTip:setAnchorPoint(ccp(0, 0.5))
    pointTip:setPosition(ccp(147, 21))

    require "script/ui/item/ItemSprite"
    local menu = BTSensitiveMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touch_priority - 5)
    cellBg:addChild(menu)

    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_shop_n.png")
    normalSprite:setContentSize(CCSizeMake(144,85))

    local normalLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1523"), g_sFontPangWa, 36, 1, ccc3(0x00, 0x00, 0x00))
    normalLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    normalSprite:addChild(normalLabel)  
    local x = (normalSprite:getContentSize().width - normalLabel:getContentSize().width) * 0.5
    local y = normalSprite:getContentSize().height - (normalSprite:getContentSize().height - normalLabel:getContentSize().height) * 0.5
    normalLabel:setPosition(ccp(x, y))

    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_shop_h.png")
    selectSprite:setContentSize(CCSizeMake(144,85))

    local selectLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1523"), g_sFontPangWa, 36, 1, ccc3(0x00, 0x00, 0x00))
    selectLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    selectSprite:addChild(selectLabel)
    local x = (selectSprite:getContentSize().width - selectLabel:getContentSize().width) * 0.5
    local y = selectSprite:getContentSize().height - (selectSprite:getContentSize().height - selectLabel:getContentSize().height) * 0.5
    selectLabel:setPosition(ccp(x, y))  

    local disableSprite = CCSprite:create("images/shop/buyed.png")

    local buyItem  = CCMenuItemSprite:create(normalSprite,selectSprite,disableSprite)
    buyItem:setAnchorPoint(ccp(0.5, 0.5))
    buyItem:setPosition(ccp(440, cellBg:getContentSize().height * 0.5))
    if shopData.bought == true then
        buyItem:setEnabled(false)
    end
    buyItem:setTag(index)
    buyItem:registerScriptTapHandler(buyGoodCallback)
    menu:addChild(buyItem, 1, index)
    return cell
end

function buyGoodCallback(tag, menuItem)
    local goodIndex = tag
    local shopData = FindTreasureData.getShopData(_event)
    local shopDb =  DB_Explore_long_event_shop.getDataById(shopData[goodIndex].id)
    if shopDb.nowcost > UserModel.getGoldNumber() then
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end
    local handleBuyGood = function ()
        SingleTip.showTip(GetLocalizeStringBy("key_8462", shopDb.eachpoint))
        FindTreasureLayer.refreshPoint()
        menuItem:setEnabled(false)
    end
    FindTreasureService.dragonBuyGood(handleBuyGood, {_event.id, goodIndex - 1}, shopDb)
end


-- 捐献
function createContributeDialog( ... )
    local dialog_info = {
        title = "images/forge/jx.png",
    }
    dialog_info.tip_node = CCRenderLabel:create(GetLocalizeStringBy("key_8463"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    dialog_info.tip_node:setColor(ccc3(0xff, 0xf6, 0x00))
    dialog_info.type = "contribute"
    local dialog = createBaseDialog(dialog_info)
    local itemBg = CCScale9Sprite:create("images/reward/cell_back.png")
    dialog:addChild(itemBg)
    itemBg:setPreferredSize(CCSizeMake(449, 192))
    itemBg:setAnchorPoint(ccp(1, 0))
    itemBg:setPosition(ccp(dialog:getContentSize().width - 8, 95))

    local shopDb = DB_Explore_long_event_shop.getDataById(_event.goodsid)
    local itemData =parseField(shopDb.item)
    local itemType = itemData[1]
    local itemId = itemData[2]
    local itemCount = itemData[3]
    local item = ItemSprite.getItemSpriteById(itemId, nil, nil, nil, _touch_priority - 5, nil, _touch_priority- 20)
    itemBg:addChild(item)
    item:setAnchorPoint(ccp(0, 0))
    item:setPosition(ccp(20, 60))

    local itemName = ItemUtil.getItemNameByItmTid(itemId)
    local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    item:addChild(itemNameLabel)
    itemNameLabel:setAnchorPoint(ccp(0.5, 0.5))
    itemNameLabel:setColor(ccc3(0x00, 0xff, 0x18))
    itemNameLabel:setPosition(ccpsprite(0.5, -0.1, item))
    local moveData = FindTreasureData.getMoveData()
    moveData.other.conNum = moveData.other.conNum or 0
    local contributeCount = itemCount + tonumber(moveData.other.conNum) * shopDb.add
    local labelCount = CCRenderLabel:create(tostring(contributeCount), g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    item:addChild(labelCount)
    labelCount:setAnchorPoint(ccp(1, 0))
    labelCount:setPosition(ccp(item:getContentSize().width - 4, 3))
    labelCount:setColor(ccc3(0x00, 0xff, 0x18))

    local infoBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
    itemBg:addChild(infoBg)
    infoBg:setAnchorPoint(ccp(0, 0))
    infoBg:setPreferredSize(CCSizeMake(303, 105))
    infoBg:setPosition(ccp(120, 58))

    local normalConfigDb = DB_Normal_config.getDataById(1)
    local remainCount = normalConfigDb.exploreContributeMax - tonumber(moveData.other.conNum)
    local contributeCountTip = CCLabelTTF:create(GetLocalizeStringBy("key_8464", remainCount), g_sFontName, 20)
    infoBg:addChild(contributeCountTip)
    contributeCountTip:setAnchorPoint(ccp(0, 0.5))
    contributeCountTip:setColor(ccc3(0x00, 0x00, 0x00))
    contributeCountTip:setPosition(ccp(10, 85))

    local line = CCSprite:create("images/item/equipinfo/line.png")
    infoBg:addChild(line)
    line:setAnchorPoint(ccp(0, 0.5))
    line:setPosition(ccp(8, 70))
    line:setScaleX(2.5)

    local itemData = ItemUtil.getItemById(itemId)
    local desc = CCLabelTTF:create(itemData.desc, g_sFontName, 20)
    infoBg:addChild(desc)
    desc:setAnchorPoint(ccp(0, 1))
    desc:setColor(ccc3(0x78, 0x25, 0x00))
    desc:setDimensions(CCSizeMake(270, 78))
    desc:setPosition(ccp(10, 70))
    desc:setHorizontalAlignment(kCCTextAlignmentLeft)

    local contributePointRichInfo = {}
    contributePointRichInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
    contributePointRichInfo.labelDefaultSize = 18
    contributePointRichInfo.defaultType = "CCRenderLabel"
    contributePointRichInfo.elements = {
        {
            text = tostring(shopDb.eachpoint),
            color = ccc3(0x00, 0xff, 0x18)
        }
    }
    local contributePointTip = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_8465"), contributePointRichInfo)
    itemBg:addChild(contributePointTip)
    contributePointTip:setAnchorPoint(ccp(0.5, 0.5))
    contributePointTip:setPosition(ccpsprite(0.5, 0.2, itemBg))

    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touch_priority - 5)

    local leaveItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_10031"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(leaveItem)
    leaveItem:setAnchorPoint(ccp(0.5, 0.5))
    leaveItem:setPosition(ccp(dialog:getContentSize().width * 0.5, 68))
    leaveItem:registerScriptTapHandler(skipCallback)

    local contributeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_10032"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(contributeItem)
    contributeItem:setAnchorPoint(ccp(0.5, 0.5))
    contributeItem:setPosition(ccp(dialog:getContentSize().width * 0.8, 68))
    local itemTotalCount = ItemUtil.getCacheItemNumBy(itemId)
    local contributeCallback = function ( ... )
        if contributeCount > itemTotalCount then
            SingleTip.showTip(GetLocalizeStringBy("key_8466"))
            return
        end
        if remainCount == 0 then
            SingleTip.showTip(GetLocalizeStringBy("key_8467"))
            return
        end
        local handleContribute = function ( ... )
            itemTotalCount = itemTotalCount - contributeCount
            contributeCount = itemCount + tonumber(moveData.other.conNum) * shopDb.add
            local moveData = FindTreasureData.getMoveData()
            labelCount:setString(tostring(contributeCount))
            remainCount = remainCount - 1
            contributeCountTip:setString(GetLocalizeStringBy("key_8464", remainCount))
            FindTreasureLayer.refreshPoint()
            SingleTip.showTip(GetLocalizeStringBy("key_8468", shopDb.eachpoint))
        end
        FindTreasureService.dragonContribute(handleContribute, {_event.id, _event.goodsid}, shopDb, itemId, contributeCount)
    end
    contributeItem:registerScriptTapHandler(contributeCallback)

    return dialog
end

function createBaseDialog(dialog_info, close)
    local dialog = CCSprite:create("images/forge/dialog_bg.png")
    local center_bar = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
    dialog:addChild(center_bar)
    center_bar:setAnchorPoint(ccp(1, 0))
    center_bar:setPosition(ccp(618, 105))
    local title = CCSprite:create(dialog_info.title)
    dialog:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0))
    title:setPosition(ccp(375, 313))
    if dialog_info.tip_node ~= nil then
        local tip_node= dialog_info.tip_node
        dialog:addChild(tip_node)
        tip_node:setAnchorPoint(ccp(0, 0.5))
        tip_node:setPosition(ccp(222, 300))
    end
    if dialog_info.type == "fight" then
        center_bar:setPreferredSize(CCSizeMake(420, 150))
        if dialog_info.tip_node ~= nil then
            dialog_info.tip_node:setAnchorPoint(ccp(0.5, 0.5))
            dialog_info.tip_node:setPosition(ccp(379, 300))
        end
    else
        center_bar:setPreferredSize(CCSizeMake(420, 164))
    end
    if close == true then
        local menu = CCMenu:create()
        dialog:addChild(menu)
        menu:setContentSize(dialog:getContentSize())
        menu:setPosition(ccp(0, 0))
        menu:setTouchPriority(_touch_priority - 1)
        
        local close_btn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
        menu:addChild(close_btn)
        close_btn:setAnchorPoint(ccp(0.5, 0.5))
        close_btn:setPosition(ccp(592, 335))
        close_btn:registerScriptTapHandler(closeCallback)
    end
    return dialog
end

-- 关闭
function closeCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
       
    _layer:removeFromParentAndCleanup(true)
    executeCallFunc()
end

function executeCallFunc()
    if _args ~= nil then
        if _args.closeCallFunc~= nil then
            _args.closeCallFunc(_args.close_call_func_args)
        end
    end
end

function skipCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    FindTreasureService.dragonSkip(handleSkip, {FindTreasureData.getMapInfo().posid - 1})
end


function handleSkip()
    closeCallback()
end