-- Filename：    ComprehendInheritLayer.lua
-- Author：      bzx
-- Date：        2014-07-16
-- Purpose：     武将觉醒互换

module("ComprehendInheritLayer", package.seeall)

require "script/model/user/UserModel"
require "script/libs/LuaCC"
require "script/libs/LuaCCSprite"
require "db/DB_Normal_config"

local _layer
local _hero_data              
local _hero_db
local _info_node                -- 顶部信息
local _silver_count_labelvalue  -- 当前拥有的银币
local _gold_count_labelvalue    -- 当前拥有的金币
local _back_btn                 -- 返回
local _inherit_btn              -- 传承
local _fScaleCard = 0.835       -- 卡牌的缩放尺寸
local _selected_hero_data           
local _selected_hero_db
local _scrollview
local _selected_info
local _gold_count               -- 传承需要消耗的金币

function show(hero_hid, selected_hero_data)
    create(hero_hid, selected_hero_data)
    MainScene.changeLayer(_layer, "ComprehendInheritLayer")
    MainScene.setMainSceneViewsVisible(true, false, true)
end

function init(hero_hid, selected_hero_data)
    _hero_data = HeroModel.getHeroByHid(hero_hid)
    _hero_db = parseDB(DB_Heroes.getDataById(_hero_data.htid))
    _selected_hero_data = selected_hero_data
    if selected_hero_data ~= nil then
        _selected_hero_data = HeroModel.getHeroByHid(selected_hero_data.hid)
        _selected_hero_db = parseDB(DB_Heroes.getDataById(_selected_hero_data.htid))
    else
        _selected_hero_db = nil
    end
    _inherit_btn = nil
    _scrollview = nil
    _selected_info = {}
    _gold_count = 0
end

function create(hero_hid, selected_hero_data)
    init(hero_hid, selected_hero_data)
    _layer = CCLayer:create()
    loadTop()
    loadBg()
    loadMenu()
    loadCard()
    refreshScrollView()
    return _layer
end

function loadTop()
	_info_node = CCNode:create()
    _layer:addChild(_info_node, 10)
    local bulletin_layer_size = BulletinLayer.getLayerContentSize()
    
	local info_node_y = g_winSize.height - bulletin_layer_size.height * g_fScaleX
    _info_node:setAnchorPoint(ccp(0, 1))
    _info_node:setScale(g_fScaleX)
    _info_node:setPosition(0, info_node_y)
    
    local bg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _info_node:addChild(bg)
    _info_node:setContentSize(bg:getContentSize())
    

	local user_info = UserModel.getUserInfo()
	
    -- 等级
    local level_icon = CCSprite:create("images/common/lv.png")
    bg:addChild(level_icon)
    level_icon:setPosition(ccp(28, 12))
    local level_label = CCLabelTTF:create(user_info.level, g_sFontName, 18)
    bg:addChild(level_label)
    level_label:setColor(ccc3(0xff, 0xe2, 0x44))
    level_label:setPosition(ccp(level_icon:getPositionX() + level_icon:getContentSize().width, 10))
   
    -- 玩家名
	local name_label = CCLabelTTF:create(user_info.uname, g_sFontName, 22)
    bg:addChild(name_label)
	name_label:setPosition(90, 8)
	name_label:setColor(ccc3(0x6c, 0xff, 0))

	-- VIP图标
    local vip_lv = CCSprite:create ("images/common/vip.png")
    bg:addChild(vip_lv)
	vip_lv:setPosition(250, 10)

    -- VIP对应级别
    require "script/libs/LuaCC"
    local vip_lv_num = LuaCC.createSpriteOfNumbers("images/main/vip", user_info.vip, 15)
    if vip_lv_num ~= nil then
        vip_lv:addChild(vip_lv_num)
        vip_lv_num:setPosition(vip_lv:getContentSize().width, 10)
    end

    -- 银币实际数据
    _silver_count_labelvalue = CCLabelTTF:create(string.convertSilverUtilByInternational(user_info.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    bg:addChild(_silver_count_labelvalue)
	_silver_count_labelvalue:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silver_count_labelvalue:setPosition(380, 10)

	-- 金币实际数据
    _gold_count_labelvalue = CCLabelTTF:create(user_info.gold_num, g_sFontName, 18)
    bg:addChild(_gold_count_labelvalue)
	_gold_count_labelvalue:setColor(ccc3(0xff, 0xe2, 0x44))
	_gold_count_labelvalue:setPosition(520, 10)
end

function loadBg()
    local bg = CCSprite:create("images/main/module_bg.png")
    _layer:addChild(bg)  
    bg:setAnchorPoint(ccp(0, 0))
    bg:setScale(g_fBgScaleRatio)

	local tLabel = {text=GetLocalizeStringBy("key_8192"), color=ccc3(0xff, 0xe4, 0x00), fontsize=35, vOffset=4, tag=101, fontname=g_sFontPangWa}
	_title = LuaCC.createSpriteWithLabel("images/common/title_bg.png", tLabel)
    _layer:addChild(_title, 10)
    _title:setScale(g_fScaleX)
    _title:setAnchorPoint(ccp(0.5, 1))
    
    local title_y = _info_node:getPositionY() - _info_node:getContentSize().height * g_fScaleX
    _title:setPosition(g_winSize.width * 0.5, title_y)
    
    local bg_full_rect = CCRectMake(0, 0, 196, 198)
    local bg_inset_rect = CCRectMake(61, 80, 46, 36)
    _bg = CCScale9Sprite:create("images/hero/bg_ng.png", bg_full_rect, bg_inset_rect)
    _layer:addChild(_bg)
    _bg:setScale(g_fScaleX)
    local preferred_size = CCSizeMake(640, 960)
    _bg:setPreferredSize(preferred_size)
    _bg:setPosition(ccp(g_winSize.width * 0.5, title_y))
    _bg:setAnchorPoint(ccp(0.5, 1))
end

function loadMenu()
    _menu = CCMenu:create()
    _layer:addChild(_menu)
    local menu_layer_size = MenuLayer.getLayerContentSize()
    _menu:setPosition(ccp(0, menu_layer_size.height * g_fScaleX + 12 * MainScene.elementScale))
    
    local picture_n = "images/common/btn/btn_blue_n.png"
    local picture_h = "images/common/btn/btn_blue_h.png"
    local text_color = ccc3(0xfe, 0xdb, 0x1c)
    local btn_size = CCSizeMake(200, 70)
    local left_point = ccp(120 * MainScene.elementScale, 0)
    local center_point = ccp(g_winSize.width * 0.5, 0)
    local right_point = ccp(g_winSize.width - 120 * MainScene.elementScale, 0)
    
    --  返回
    _back_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, CCSizeMake(200, 70), GetLocalizeStringBy("key_8193"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _back_btn:setScale(MainScene.elementScale * 0.98)
	_menu:addChild(_back_btn)
    _back_btn:setAnchorPoint(ccp(0.5, 0))
    _back_btn:setPosition(ccp(154 * MainScene.elementScale, 0))
	_back_btn:registerScriptTapHandler(backCallback)
    
    refreshInheritBtn()
end

function loadCard()

    local card = HeroPublicCC.createSpriteCardShow(_hero_db.id, nil, _hero_data.turned_id)
    card:setScale(_fScaleCard)
    -- 按钮
    local select_menu = CCMenu:create()
    _bg:addChild(select_menu)
	select_menu:setPosition(ccp(0, 0))
    -- 选择卡牌
    local select_btn = CCMenuItemSprite:create(card, card)
    select_menu:addChild(select_btn)
	-- select_btn:registerScriptTapHandler(callbackSelectHero)
	select_btn:setAnchorPoint(ccp(0, 1))
    local scale = 0.58
    select_btn:setScale(scale)
    select_btn:setContentSize(CCSizeMake(select_btn:getContentSize().width * 0.8, select_btn:getContentSize().height * 0.8))
    select_btn:setPosition(ccp(20, _bg:getContentSize().height - 80))

    -- 卡牌名
    local name_labels = {}
    name_labels[1] = CCRenderLabel:create(_hero_db.name, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    name_labels[1]:setColor(ccc3(0xe4, 0x00, 0xff))
    name_labels[2] = CCRenderLabel:create("  +" .. _hero_data.evolve_level, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    name_labels[2]:setColor(ccc3(0x00, 0xff, 0x18))
    local name_node = BaseUI.createHorizontalNode(name_labels)
    select_btn:addChild(name_node)
    name_node:setAnchorPoint(ccp(0.5, 0.5))
    name_node:setPosition(ccp(select_btn:getContentSize().width * 0.5, - 20))
    name_node:setScale(1 / scale)
    
    local card = nil
    if _selected_hero_data ~= nil then
        card = HeroPublicCC.createSpriteCardShow(_selected_hero_db.id)
        card:setScale(_fScaleCard)
    else
        card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setPreferredSize(CCSizeMake(148, 214))
        local select_lable = CCSprite:create("images/biography/select_card.png")
        card:addChild(select_lable)
        select_lable:setAnchorPoint(ccp(0.5, 0.5))
        select_lable:setPosition(ccp(card:getContentSize().width * 0.5, card:getContentSize().height * 0.5))
    end
    -- 按钮
    local select_menu = CCMenu:create()
    _bg:addChild(select_menu)
	select_menu:setPosition(ccp(0, 0))
    -- 选择卡牌
    local select_btn = CCMenuItemSprite:create(card, card)
    select_menu:addChild(select_btn)
    select_btn:registerScriptTapHandler(callbackSelectHero)
	select_btn:setAnchorPoint(ccp(1, 1))
    if _selected_hero_data ~= nil then
        select_btn:setPosition(ccp(_bg:getContentSize().width - 30, _bg:getContentSize().height - 80))
    else
        select_btn:setPosition(ccp(_bg:getContentSize().width - 22, _bg:getContentSize().height - 70))
    end
    if _selected_hero_data ~= nil then
        select_btn:setContentSize(CCSizeMake(select_btn:getContentSize().width * 0.8, select_btn:getContentSize().height * 0.8))
        select_btn:setScale(scale)
        -- 卡牌名
        local name_labels = {}
        name_labels[1] = CCRenderLabel:create(_selected_hero_db.name, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        name_labels[1]:setColor(ccc3(0xe4, 0x00, 0xff))
        name_labels[2] = CCRenderLabel:create("  +" .. _selected_hero_data.evolve_level, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        name_labels[2]:setColor(ccc3(0x00, 0xff, 0x18))
        local name_node = BaseUI.createHorizontalNode(name_labels)
        select_btn:addChild(name_node)
        name_node:setAnchorPoint(ccp(0.5, 0.5))
        name_node:setPosition(ccp(select_btn:getContentSize().width * 0.5, - 20))
        name_node:setScale(1 / scale)
    end
    
    local tip_bg = CCScale9Sprite:create("images/common/s9_1.png")
    _bg:addChild(tip_bg)
    tip_bg:setPreferredSize(CCSizeMake(293, 206))
    tip_bg:setAnchorPoint(ccp(0.5, 1))
    tip_bg:setPosition(ccp(_bg:getContentSize().width * 0.5, select_btn:getPositionY()))
    
    local tip1 = CCLabelTTF:create(GetLocalizeStringBy("key_8194"), g_sFontName, 21)
    tip_bg:addChild(tip1)
    tip1:setColor(ccc3(0x78, 0x25, 0x00))
    tip1:setDimensions(CCSizeMake(254, 124))
    tip1:setAnchorPoint(ccp(0.5, 1))
    tip1:setPosition(ccp(tip_bg:getContentSize().width * 0.5, tip_bg:getContentSize().height - 35))
    tip1:setHorizontalAlignment(kCCTextAlignmentLeft)

    local tip2 =  CCLabelTTF:create(GetLocalizeStringBy("key_8195"), g_sFontName, 21)
    tip_bg:addChild(tip2)
    tip2:setColor(ccc3(0x78, 0x25, 0x00))
    tip2:setDimensions(CCSizeMake(254, 124))
    tip2:setAnchorPoint(ccp(0.5, 0))
    tip2:setPosition(ccp(tip_bg:getContentSize().width * 0.5, 35))
    tip2:setHorizontalAlignment(kCCTextAlignmentLeft)
    tip2:setVerticalAlignment(kCCVerticalTextAlignmentBottom)
end

function refreshScrollView()
    if _scrollview == nil then
        local scrollview_bg = CCScale9Sprite:create("images/common/s9_5.png", CCRectMake(0, 0, 75, 75), CCRectMake(35, 35, 5, 5))
        _bg:addChild(scrollview_bg)
        scrollview_bg:setPreferredSize(CCSizeMake(606, _title:getPositionY() / g_fScaleX - _title:getContentSize().height - (290 + 145) ))
        scrollview_bg:setAnchorPoint(ccp(0.5, 0))
        scrollview_bg:setPosition(ccp(g_winSize.width / g_fScaleX * 0.5, _bg:convertToNodeSpace(ccp(0, 192 * g_fScaleX)).y))
        
        _scrollview = CCScrollView:create()
        scrollview_bg:addChild(_scrollview)
        _scrollview:ignoreAnchorPointForPosition(false)
        _scrollview:setAnchorPoint(ccp(0.5, 0.5))
        _scrollview:setPosition(ccp(scrollview_bg:getContentSize().width * 0.5, scrollview_bg:getContentSize().height * 0.5))
        _scrollview:setTouchPriority(-129)
        _scrollview:setViewSize(CCSizeMake(606, scrollview_bg:getContentSize().height - 12 * g_fScaleX))
        _scrollview:setDirection(kCCScrollViewDirectionVertical)
    end
    local layer = CCLayer:create()
    layer:setContentSize(CCSizeMake(600, 570))
    _scrollview:setContainer(layer)
    _scrollview:setContentOffset(ccp(0, _scrollview:getViewSize().height - _scrollview:getContentSize().height))
    local cell_y = layer:getContentSize().height
    local title_text = {"key_8080", "key_8081", "lcy_1004"}
    for i = 1, #title_text do
        local cell = CCScale9Sprite:create("images/common/s9_4.png")
        layer:addChild(cell)
        cell:setPreferredSize(CCSizeMake(586, 180))
        cell:setAnchorPoint(ccp(0.5, 1))
        cell:setPosition(layer:getContentSize().width * 0.5, cell_y)
        
        local fullRect = CCRectMake(0,0,31,41)
        local insetRect = CCRectMake(8,17,2,2)
        local title_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
        cell:addChild(title_bg)
        title_bg:setPreferredSize(CCSizeMake(197, 41))
        title_bg:setAnchorPoint(ccp(0, 1))
        title_bg:setPosition(ccp(0, cell:getContentSize().height))
        
        local title = CCRenderLabel:create(GetLocalizeStringBy(title_text[i]), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
        title_bg:addChild(title)
        title:setAnchorPoint(ccp(0.5, 0.5))
        title:setPosition(ccp(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5))
        local awaken_id = nil
        if _hero_data.talent ~= nil and _hero_data.talent.confirmed ~= nil then
            awaken_id = _hero_data.talent.confirmed[tostring(i)]
        end 
        if awaken_id ~= nil then
            local awaken_db = DB_Hero_refreshgift.getDataById(tonumber(awaken_id))
            local name_label = CCRenderLabel:create(awaken_db.name, g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
            cell:addChild(name_label)
            name_label:setAnchorPoint(ccp(0, 0.5))
            name_label:setPosition(ccp(20, cell:getContentSize().height - 50))
            name_label:setColor(ComprehendLayer.getNameColorByStar(awaken_db.level))
            local star_label = CCRenderLabel:create(awaken_db.level, g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
            cell:addChild(star_label)
            star_label:setColor(ccc3(0x00, 0xff, 0x18))
            star_label:setAnchorPoint(ccp(0, 0.5))
            star_label:setPosition(ccp(137, cell:getContentSize().height - 50))
            local star_icon = CCSprite:create("images/common/small_star.png")
            cell:addChild(star_icon)
            star_icon:setAnchorPoint(ccp(0, 0.5))
            star_icon:setPosition(ccp(156, star_label:getPositionY()))
            
            local des_label = CCLabelTTF:create(awaken_db.des, g_sFontName, 21)
            cell:addChild(des_label)
            des_label:setDimensions(CCSizeMake(220, 126))
            des_label:setHorizontalAlignment(kCCTextAlignmentLeft)
            des_label:setAnchorPoint(ccp(0, 1))
            des_label:setColor(ccc3(0xff, 0xf6, 0x00))
            des_label:setPosition(ccp(10, cell:getContentSize().height - 75))
        else
            -- local copy_level_tip = {"key_8001", "key_8002", "key_8003"}
            local copy_level_tip = {"lgx_1020","lgx_1020","lgx_1021"}
            local des = nil
            local des_color = nil
            -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
            local neeedPotential = tonumber(_hero_db.hero_copy_id[i][1])
            local need_advance_level = _hero_db.hero_copy_id[i][2]
            -- 是否满足进阶等级要求
            local isLevelOpen = tonumber(_hero_db.potential) > neeedPotential or (tonumber(_hero_db.potential) == neeedPotential and tonumber(_hero_data.evolve_level) >= need_advance_level)
            if isLevelOpen == false then
                des = GetLocalizeStringBy(copy_level_tip[i]) .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8006") 
                des_color = ccc3(0xe4, 0x00, 0x00)
            else
                des = GetLocalizeStringBy("key_8007")
                des_color = ccc3(0xff, 0xff, 0xff)
            end
            local des_label = CCLabelTTF:create(des, g_sFontName, 21)
            cell:addChild(des_label)
            des_label:setDimensions(CCSizeMake(214, 126))
            des_label:setHorizontalAlignment(kCCTextAlignmentLeft)
            des_label:setAnchorPoint(ccp(0, 1))
            des_label:setColor(des_color)
            des_label:setPosition(ccp(10, cell:getContentSize().height - 75))
        end
        local line = CCSprite:create("images/common/line02.png")
        cell:addChild(line)
        line:setAnchorPoint(ccp(0, 0.5))
        line:setScaleX(2.2)
        line:setPosition(ccp(0, cell:getContentSize().height - 66))
        
        local gold = {}
        local normal_config_db = parseDB(DB_Normal_config.getDataById(1))
        gold[1] = CCSprite:create("images/common/gold.png")
        gold[2] = CCRenderLabel:create(normal_config_db.comprehendCost[i], g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        gold_node = BaseUI.createHorizontalNode(gold)
        cell:addChild(gold_node)
        gold_node:setAnchorPoint(ccp(0.5, 0.5))
        gold_node:setPosition(ccp(cell:getContentSize().width * 0.5, cell:getContentSize().height - 20))
        local normal = CCScale9Sprite:create("images/common/checkbg.png")
        normal: setPreferredSize(CCSizeMake(57, 49))
        local menu = BTSensitiveMenu:create()
        cell:addChild(menu)
        menu:setAnchorPoint(ccp(0, 0))
        menu:setPosition(ccp(0, 0))
        menu:setContentSize(cell:getContentSize())
        
        local select_btn = CCMenuItemSprite:create(normal, normal)
        menu:addChild(select_btn)
        select_btn:setAnchorPoint(ccp(0.5, 0.5))
        select_btn:setPosition(ccp(cell:getContentSize().width * 0.5, cell:getContentSize().height - 74))
        select_btn:setTag(i)
        select_btn:registerScriptTapHandler(selectAwakenCallback)
        
        local arrows = CCSprite:create("images/common/two_arrow.png")
        cell:addChild(arrows)
        arrows:setAnchorPoint(ccp(0.5, 0.5))
        arrows:setPosition(ccp(cell:getContentSize().width * 0.5, cell:getContentSize().height - 151))
        
        local selected_title_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
        cell:addChild(selected_title_bg)
        selected_title_bg:setPreferredSize(CCSizeMake(197, 41))
        selected_title_bg:setAnchorPoint(ccp(0, 1))
        selected_title_bg:setPosition(ccp(cell:getContentSize().width, cell:getContentSize().height))
        selected_title_bg:setScaleX(-1)
        
        local selected_title = CCRenderLabel:create(GetLocalizeStringBy(title_text[i]), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
        cell:addChild(selected_title)
        selected_title:setAnchorPoint(ccp(0.5, 0.5))
        selected_title:setPosition(ccp(selected_title_bg:getPositionX() - selected_title_bg:getContentSize().width * 0.5, selected_title_bg:getPositionY() - selected_title_bg:getContentSize().height * 0.5))
        
        if _selected_hero_data ~= nil then
            local selected_awaken_id = nil
            if _selected_hero_data.talent ~= nil and _selected_hero_data.talent.confirmed ~= nil then
                selected_awaken_id = _selected_hero_data.talent.confirmed[tostring(i)] 
            end
            if selected_awaken_id ~= nil then
                local selected_awaken_db = DB_Hero_refreshgift.getDataById(tonumber(selected_awaken_id))
                local selected_name_label = CCRenderLabel:create(selected_awaken_db.name, g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
                cell:addChild(selected_name_label)
                selected_name_label:setAnchorPoint(ccp(0, 0.5))
                selected_name_label:setPosition(ccp(401, cell:getContentSize().height - 50))
                selected_name_label:setColor(ComprehendLayer.getNameColorByStar(selected_awaken_db.level))
                local selected_star_label = CCRenderLabel:create(selected_awaken_db.level, g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
                cell:addChild(selected_star_label)
                selected_star_label:setColor(ccc3(0x00, 0xff, 0x18))
                selected_star_label:setAnchorPoint(ccp(0, 0.5))
                selected_star_label:setPosition(ccp(520, cell:getContentSize().height - 50))
                local selected_star_icon = CCSprite:create("images/common/small_star.png")
                cell:addChild(selected_star_icon)
                selected_star_icon:setAnchorPoint(ccp(0, 0.5))
                selected_star_icon:setPosition(ccp(545, selected_star_label:getPositionY()))
                local selected_des_label = CCLabelTTF:create(selected_awaken_db.des, g_sFontName, 21)
                cell:addChild(selected_des_label)
                selected_des_label:setDimensions(CCSizeMake(220, 126))
                selected_des_label:setHorizontalAlignment(kCCTextAlignmentLeft)
                selected_des_label:setAnchorPoint(ccp(0, 1))
                selected_des_label:setColor(ccc3(0xff, 0xf6, 0x00))
                selected_des_label:setPosition(ccp(350, cell:getContentSize().height - 75))
            else
                -- local copy_level_tip = {"key_8001", "key_8002", "key_8003"}
                local copy_level_tip = {"lgx_1020","lgx_1020","lgx_1021"}
                local des = nil
                local des_color = nil
                -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
                local neeedPotential = tonumber(_selected_hero_db.hero_copy_id[i][1])
                local need_advance_level = _selected_hero_db.hero_copy_id[i][2]
                -- 是否满足进阶等级要求
                local isLevelOpen = tonumber(_selected_hero_db.potential) > neeedPotential or (tonumber(_selected_hero_db.potential) == neeedPotential and tonumber(_selected_hero_data.evolve_level) >= need_advance_level)
                if isLevelOpen == false then
                    des = GetLocalizeStringBy(copy_level_tip[i]) .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8006") 
                    des_color = ccc3(0xe4, 0x00, 0x00)
                else
                    des = GetLocalizeStringBy("key_8007")
                    des_color = ccc3(0xff, 0xff, 0xff)
                end
                local selected_des_label = CCLabelTTF:create(des, g_sFontName, 21)
                cell:addChild(selected_des_label)
                selected_des_label:setDimensions(CCSizeMake(220, 126))
                selected_des_label:setHorizontalAlignment(kCCTextAlignmentLeft)
                selected_des_label:setAnchorPoint(ccp(0, 1))
                selected_des_label:setColor(des_color)
                selected_des_label:setPosition(ccp(350, cell:getContentSize().height - 75))
            end
        end
        local selected_line = CCSprite:create("images/common/line02.png")
        cell:addChild(selected_line)
        selected_line:setAnchorPoint(ccp(1, 0.5))
        selected_line:setScaleX(2.2)
        selected_line:setPosition(ccp(cell:getContentSize().width, cell:getContentSize().height - 66))
        
        cell_y = cell_y - cell:getContentSize().height - 10
    end
end


function callbackSelectHero()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "script/ui/hero/HeroSelectLayer"
	require "script/ui/main/MainScene"

	local tArgsOfModule = {withoutExp=true, isSingle=true, touchPriority = -500}
	tArgsOfModule.sign="ComprehendLayer"
	tArgsOfModule.fnCreate = function(selected_data)
        local selected_hero_data
        if #selected_data.selectedHeroes >= 1 then
            selected_hero_data = selected_data.selectedHeroes[1]
        else
            selected_hero_data = selected_data.selectedHeroes
        end
        if table.isEmpty(selected_hero_data) then
            selected_hero_data = nil
        end
        show(_hero_data.hid, selected_hero_data)
    end
    tArgsOfModule.selected = {}
    if _selected_hero_data ~= nil then
        table.insert(tArgsOfModule.selected, tostring(_selected_hero_data.hid))
    end
    tArgsOfModule.filters = getHeroesFileter()
	MainScene.changeLayer(HeroSelectLayer.createLayer(tArgsOfModule), "HeroSelectLayer")
end

-- 对武将进行筛选
function getHeroesFileter()
    local hero_htid_fileter = {}
    local heros = HeroModel.getAllHeroes()
    for htid, hero in pairs(heros) do
		if not couldComprehendHero(hero) or hero.hid == _hero_data.hid then
            hero_htid_fileter[#hero_htid_fileter + 1] = hero.hid
        end
	end
    return hero_htid_fileter
end

-- 筛选条件
function couldComprehendHero(hero)
    local hero_db = parseDB(DB_Heroes.getDataById(hero.htid))
    if hero_db.hero_copy_id ~= nil and #hero_db.hero_copy_id >= 1 then
        hero.talent = hero.talent or {}
        hero.talent.to_confirm = hero.talent.to_confirm or {}
        -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
        local neeedPotential = tonumber(hero_db.hero_copy_id[1][1])
        if  tonumber(hero_db.potential) > neeedPotential or (tonumber(hero_db.potential) == neeedPotential and tonumber(hero.evolve_level) >= hero_db.hero_copy_id[1][2]) then
            if (hero.talent.to_confirm["1"] == nil or type(hero.talent.to_confirm["1"]) == "table" and table.isEmpty(hero.talent.to_confirm["1"])) and 
                (hero.talent.to_confirm["2"] == nil or type(hero.talent.to_confirm["2"]) == "table" and table.isEmpty(hero.talent.to_confirm["2"])) and
                (hero.talent.to_confirm["3"] == nil or type(hero.talent.to_confirm["3"]) == "table" and table.isEmpty(hero.talent.to_confirm["3"])) then
                return true
            end
        end
    end
    return false
end


function selectAwakenCallback(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if _selected_hero_data == nil then
        SingleTip.showTip(GetLocalizeStringBy("key_8196"))
        return
    end
    -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
    local neeedPotential = tonumber(_selected_hero_db.hero_copy_id[tag][1])
    local need_advance_level = _selected_hero_db.hero_copy_id[tag][2]
    -- 是否满足进阶等级要求
    local isLevelOpen = tonumber(_selected_hero_db.potential) > neeedPotential or (tonumber(_selected_hero_db.potential) == neeedPotential and tonumber(_selected_hero_data.evolve_level) >= need_advance_level)
    if isLevelOpen == false then
        SingleTip.showTip(GetLocalizeStringBy("key_8033") .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8034"))
        return
    end

    _hero_data.talent = _hero_data.talent or {}
    _selected_hero_data.talent = _selected_hero_data.talent or {}
    _hero_data.talent.confirmed = _hero_data.talent.confirmed or {}
    _selected_hero_data.talent.confirmed = _selected_hero_data.talent.confirmed or {}
    if _hero_data.talent.confirmed[tostring(tag)] == nil and _selected_hero_data.talent.confirmed[tostring(tag)] == nil then
        SingleTip.showTip(GetLocalizeStringBy("key_8197"))
        return
    end

    local normal_config_db = parseDB(DB_Normal_config.getDataById(1))
    local gold = normal_config_db.comprehendCost[tag]
    if _selected_info[tostring(tag)] == nil then
        local selected_sprite = CCSprite:create("images/common/checked.png")
        menu_item:addChild(selected_sprite)
        selected_sprite:setAnchorPoint(ccp(0.5, 0.5))
        selected_sprite:setPosition(ccp(menu_item:getContentSize().width * 0.5, menu_item:getContentSize().height * 0.5))
        _selected_info[tostring(tag)] = selected_sprite
        _gold_count = _gold_count + gold
    else
        _selected_info[tostring(tag)]:removeFromParentAndCleanup(true)
        _selected_info[tostring(tag)] = nil
        _gold_count = _gold_count - gold
    end
    refreshInheritBtn()
end

function refreshInheritBtn()
    if _inherit_btn ~= nil then
        _inherit_btn:removeFromParentAndCleanup(true)
    end
    local btn_data = {
        normal = "images/common/btn/btn_blue_n.png",
        selected = "images/common/btn/btn_blue_h.png",
        disabled = nil,
        size = CCSizeMake(271, 70),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_8198"),
        number = tostring(_gold_count),
    }
    _inherit_btn = LuaCCSprite.createNumberMenuItem(btn_data)
    _inherit_btn:setScale(MainScene.elementScale * 0.98)
	_menu:addChild(_inherit_btn)
    _inherit_btn:setAnchorPoint(ccp(0.5, 0))
    _inherit_btn:setPosition(ccp(g_winSize.width - 198 * MainScene.elementScale, 0))
	_inherit_btn:registerScriptTapHandler(inheritCallback)
end

function inheritCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if _gold_count == 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8199"))
        return
    end
    if _gold_count > UserModel.getGoldNumber() then
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(_hero_data.hid))
    args:addObject(CCInteger:create(_selected_hero_data.hid))
    local indexes = CCArray:create()
    for k, v in pairs(_selected_info) do
        indexes:addObject(CCString:create(k))
    end
    args:addObject(indexes)
    RequestCenter.heroInheritTalent(handleInherit, args)
end

function handleInherit(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    UserModel.addGoldNumber(-_gold_count)
    for k, v in pairs(_selected_info) do
        if _selected_hero_data.talent == nil then
            _selected_hero_data.talent = {}
            _selected_hero_data.talent.confirmed = {}
        else
            if _selected_hero_data.talent.confirmed == nil then
                _selected_hero_data.talent.confirmed = {}
            end
        end
        local confirmedTemp = _selected_hero_data.talent.confirmed[k]
        _selected_hero_data.talent.confirmed[k] = _hero_data.talent.confirmed[k]
        _hero_data.talent.confirmed[k] = confirmedTemp
    end
    
    show(_hero_data.hid, _selected_hero_data)
    SingleTip.showTip(GetLocalizeStringBy("key_8200"))
end

function backCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
       
    require "script/ui/biography/ComprehendLayer"
    ComprehendLayer.show(_hero_data.hid)
end