-- Filename：    ComprehendLayer.lua
-- Author：      bzx
-- Date：        2014-04-18
-- Purpose：     武将领悟

module("ComprehendLayer", package.seeall)

require "db/DB_Heroes"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/hero/HeroPublicCC"
require "script/model/hero/HeroModel"
require "script/network/RequestCenter"
require "db/DB_Hero_refreshgift"
require "script/ui/star/StarUtil"
require "script/ui/item/ItemSprite"
require "script/libs/LuaCCSprite"
require "script/ui/tip/SingleTip"
require "script/model/DataCache"
require "script/GlobalVars"
require "script/ui/switch/SwitchOpen"

-- 10030147
local _layer
local _hero_hid                 -- 武将hid
local _hero_db                  -- 表数据
local _hero_data                -- 服务器传来的英雄数据
local _silver_count_labelvalue  -- 银币数量
local _gold_count_labelvalue    -- 金币数量
local _info_node                -- 武装天赋信息
local _title                    -- 标题
local _BG                       -- 背景
local _comprehend               -- 中间界面
local _not_change_btn           -- 保留
local _change_btn               -- 替换
local _comprehend_btn           -- 领悟
local _back_btn                 -- 返回
local _inherit_btn              -- 传承
local _batchComprehend_btn      -- 批量领悟
local _activate_btn             -- 激活
local _menu
local _fScaleCard = 0.835       -- 卡牌的缩放尺寸
-- 进阶需要的物品数组
local _arrNeedItems
-- 进阶所需物品种类标识
local _nItemTypeProps = 10
local _nItemTypeTreas = 11
local _nItemTypeArms = 1

local _old_talent_name          -- 当前拥有的天赋名
local _old_talent_des           -- 当前拥有的天赋简介
local _old_talent_line
local _new_talent_name          -- 新天赋名
local _new_talent_des           -- 新天赋简介
local _new_talent_line
local _cost_infos
local _item_is_full             -- 当前领悟所需消耗是否充足
local _btn_status

local _jewel_lable
local _item_lable

local _awaken_awaken_cells
local _awaken_radio_items

local _current_awaken_item
local _current_cost_index
local _current_awaken_index
local _text_bg_light
local _items_title
local _talent_info_node
local _attr
local _current_item_node_y


local _awaken_info_cell
local _to_awaken_info_cell
local _could_comprehend
local _tip_text

local _current_item_count
local _radio_data

-- 选中的单选按钮
local _selectedItem = nil

function constructor()
    _hero_ID = nil
    _item_is_full = true
end

function initWithHeroHID(hero_hid)
    _current_awaken_index = -1
    _current_cost_index = 1
    _current_awaken_item = nil
    _jewel_lable = nil
    _talent_info_node = nil
    _item_lable = nil
    _text_bg_light = nil
    _selectedItem = nil
    _hero_hid = hero_hid
    _hero_data = HeroModel.getHeroByHid(hero_hid)
    if type(_hero_data.talent.to_confirm["1"]) == "table" and table.isEmpty(_hero_data.talent.to_confirm["1"]) then
        _hero_data.talent.to_confirm["1"] = nil
    end
    if type(_hero_data.talent.to_confirm["2"]) == "table" and table.isEmpty(_hero_data.talent.to_confirm["2"]) then
        _hero_data.talent.to_confirm["2"] = nil
    end
    if type(_hero_data.talent.to_confirm["3"]) == "table" and table.isEmpty(_hero_data.talent.to_confirm["3"]) then
        _hero_data.talent.to_confirm["3"] = nil
    end
    if couldComprehendHero(_hero_data) == false then
        SingleTip.showTip(GetLocalizeStringBy("key_10004"))
        return false
    end
    _hero_db = DB_Heroes.getDataById(_hero_data.htid)
    
    _awaken_info_cell = nil
    _to_awaken_info_cell = nil
    _attr = nil
    
    -- 消耗
    _cost_infos = {}
    local cost_str = _hero_db.comprehendItems
    local cost_array = string.split(cost_str, ",")
    for i = 1, #cost_array do
        local cost_array2 = string.split(cost_array[i], "|")
        local cost_info = {}
        cost_info.jewel = tonumber(cost_array2[1])
        cost_info.gold = tonumber(cost_array2[2])
        cost_info.item_id = tonumber(cost_array2[3])
        cost_info.item_count = tonumber(cost_array2[4])
        _cost_infos[i] = cost_info
    end
    _current_item_count = ItemUtil.getCacheItemNumBy(_cost_infos[3].item_id)
    _not_change_btn = nil           -- 保留
    _change_btn = nil               -- 替换
    _comprehend_btn = nil           -- 领悟
    _back_btn = nil                 -- 返回
    _inherit_btn = nil              -- 传承
    _batchComprehend_btn = nil      -- 批量领悟
    _activate_btn = nil            -- 激活
    return true
end


function show(hero_hid, callback, isCheck)
    if initWithHeroHID(hero_hid) == false then
        return
    end

    if table.isEmpty(_hero_data.talent.confirmed) and isCheck then
        local awaken_copy_db = string.split(_hero_db.hero_copy_id, ",")
        -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
        local neeedPotential = tonumber(string.split(awaken_copy_db[1], "|")[1])
        local need_advance_level = tonumber(string.split(awaken_copy_db[1], "|")[2])
        -- 是否满足进阶等级要求
        local isLevelOpen = tonumber(_hero_db.potential) > neeedPotential or (tonumber(_hero_db.potential) == neeedPotential and tonumber(_hero_data.evolve_level) >= need_advance_level)
        if isLevelOpen == false then
            SingleTip.showTip(GetLocalizeStringBy("key_8033") .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8034"))
            return
        end
    end
    if callback ~= nil then
        callback()
    end
    create(hero_hid)
    MainScene.changeLayer(_layer, "ComprehendLayer")
    MainScene.setMainSceneViewsVisible(true, false, true)
end

function create(hero_hid)
    constructor()
    initWithHeroHID(hero_hid)
    _layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
    loadBG()
    loadPlayerInfo()
    loadTitle()
    loadFunctionMenu()
    loadMenu()
    loadComprehend()
    adaptive()
    local toConfirm = _hero_data.talent.to_confirm["1"] or _hero_data.talent.to_confirm["2"] or _hero_data.talent.to_confirm["3"]
    if toConfirm ~= nil and type(toConfirm) == "table" and #toConfirm > 0 then
        batchComprehendCallback()
    end
    return _layer
end

function loadBG()
    _BG = CCSprite:create("images/main/module_bg.png")
	-- BG:setScale(g_fBgScaleRatio)
end

function onNodeEvent(event)
    if event == "exit" then
        if _text_bg_light ~= nil then
            _text_bg_light:autorelease()
        end
    end
end

function showGotoStarLayer(hero_htid, callback)
    local function gotoStarLayer()
        if callback ~= nil then
            callback()
        end
        require "script/ui/star/StarLayer"
        local starLayer = StarLayer.createLayer(nil, hero_htid)
        MainScene.changeLayer(starLayer, "starLayer")
    end
    require "script/ui/tip/AlertTip"
    local tipText = GetLocalizeStringBy("key_1822") 
    AlertTip.showAlert(tipText, gotoStarLayer, false, nil, GetLocalizeStringBy("key_1354"))
end

function loadPlayerInfo()
	_info_node = CCNode:create()
    
    local BG = CCSprite:create("images/hero/avatar_attr_bg.png")
    _info_node:addChild(BG)
    _info_node:setContentSize(BG:getContentSize())
    
    require "script/model/user/UserModel"
	local user_info = UserModel.getUserInfo()
	
    -- 等级
    local level_icon = CCSprite:create("images/common/lv.png")
    BG:addChild(level_icon)
    level_icon:setPosition(ccp(28, 12))
    local level_label = CCLabelTTF:create(user_info.level, g_sFontName, 18)
    BG:addChild(level_label)
    level_label:setColor(ccc3(0xff, 0xe2, 0x44))
    level_label:setPosition(ccp(level_icon:getPositionX() + level_icon:getContentSize().width, 10))
   
    -- 玩家名
	local name_label = CCLabelTTF:create(user_info.uname, g_sFontName, 22)
    BG:addChild(name_label)
	name_label:setPosition(90, 8)
	name_label:setColor(ccc3(0x6c, 0xff, 0))

	-- VIP图标
    local vip_lv = CCSprite:create ("images/common/vip.png")
    BG:addChild(vip_lv)
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
    BG:addChild(_silver_count_labelvalue)
	_silver_count_labelvalue:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silver_count_labelvalue:setPosition(380, 10)

	-- 金币实际数据
    _gold_count_labelvalue = CCLabelTTF:create(user_info.gold_num, g_sFontName, 18)
    BG:addChild(_gold_count_labelvalue)
	_gold_count_labelvalue:setColor(ccc3(0xff, 0xe2, 0x44))
	_gold_count_labelvalue:setPosition(520, 10)
end

-- 创建标题栏
function loadTitle()
	require "script/libs/LuaCC"
	local tLabel = {text=GetLocalizeStringBy("key_2522"), color=ccc3(0xff, 0xe4, 0x00), fontsize=35, vOffset=4, tag=101, fontname=g_sFontPangWa}
	_title = LuaCC.createSpriteWithLabel("images/common/title_bg.png", tLabel)
    
    local menu = CCMenu:create()
    _title:addChild(menu)
    menu:setPosition(ccp(0, 0))
    local close_btn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    menu:addChild(close_btn)
    close_btn:setAnchorPoint(ccp(1, 0.5))
    close_btn:setPosition(ccp(_title:getContentSize().width + 5, _title:getContentSize().height * 0.5 + 3))
    close_btn:registerScriptTapHandler(callbackBack)
end

function loadComprehend()
    _comprehend = CCNode:create()
    _comprehend:setContentSize(CCSizeMake(640, 960))
    
    local comprehend_size = _comprehend:getContentSize()
    
    local BG_full_rect = CCRectMake(0, 0, 196, 198)
    local BG_inset_rect = CCRectMake(61, 80, 46, 36)
    local BG = CCScale9Sprite:create("images/hero/bg_ng.png", BG_full_rect, BG_inset_rect)
    _comprehend:addChild(BG)
    BG:setScale(1/MainScene.elementScale * g_fScaleX)
    local preferred_size = CCSizeMake(640, 960 - _title:getPositionY())
    BG:setPreferredSize(preferred_size)
    BG:setPosition(ccp(comprehend_size.width * 0.5, comprehend_size.height))
    BG:setAnchorPoint(ccp(0.5, 1))
    -- 选项卡
    _radio_data = {
        touch_priority      = -128,
        space               = 20,
        callback            = callbackAwakenRadio,
        direction           = 1,-- 方向 1为水平，2为竖直
        items = {}
    }
    
    local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	local btn_size_n	= CCSizeMake(177, 50)
	local btn_size_h	= CCSizeMake(179, 55)
	
	local text_color_n	= ccc3(0xf2, 0xe0, 0xcc)
	local text_color_h	= ccc3(0xff, 0xff, 0xff)
	local font			= g_sFontPangWa
	local font_size		= 30
	local strokeCor_n	= ccc3(0xf2, 0xe0, 0xcc)
	local strokeCor_h	= ccc3(0x00, 0x00, 0x00)
	local stroke_size_n	= 0
    local stroke_size_h = 1

    local awaken_copy_db = string.split(_hero_db.hero_copy_id, ",")
    local star_count_limit = string.split(_hero_db.refreshMaxStar, ",")
    local awaken_radio_items_text = {"key_8080", "key_8081", "lcy_1004"}
    for i = 1, #awaken_copy_db do
        local sprite_n = CCScale9Sprite:create(image_n, rect_full_n, rect_inset_n)
        sprite_n:setPreferredSize(btn_size_n)
        local sprite_h = CCScale9Sprite:create(image_h, rect_full_h, rect_inset_h)
        sprite_h:setPreferredSize(btn_size_h)
        local menu_item = CCMenuItemSprite:create(sprite_n, nil, sprite_h)
        local lable = CCRenderLabel:create( GetLocalizeStringBy(awaken_radio_items_text[i]), g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
        menu_item:addChild(lable)
        lable:setAnchorPoint(ccp(0.5, 0.5))
        lable:setPosition(ccp(menu_item:getContentSize().width * 0.5, menu_item:getContentSize().height * 0.5))
        table.insert(_radio_data.items, menu_item)
    end
    local awaken_radio_menu = LuaCCSprite.createRadioMenuWithItems(_radio_data)
    awaken_radio_menu:setAnchorPoint(ccp(0.5, 0))
    awaken_radio_menu:setPosition(ccp(320, comprehend_size.height - 103))
    _comprehend:addChild(awaken_radio_menu, 11000)
    -- 背景图
	local attr_full_rect = CCRectMake(0, 0, 75, 75)
    local attr_inset_rect = CCRectMake(30, 30, 15, 10)
	local attr = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", attr_full_rect, attr_inset_rect)
    _attr = attr
    _comprehend:addChild(attr)
    attr:setPreferredSize(CCSizeMake(600, --[[585]] g_winSize.height * 585 / 960))
	attr:setAnchorPoint(ccp(0.5, 1))
    -- attr:setScale(1 / g_fScaleX * MainScene.elementScale)
	attr:setPosition(ccp(comprehend_size.width * 0.5, comprehend_size.height - 103))
    local di = CCSprite:create("images/biography/di.png")
    attr:addChild(di)
    di:setAnchorPoint(ccp(0.5, 1))
    di:setPosition(ccp(attr:getContentSize().width * 0.5, attr:getContentSize().height - 8))
	local card = HeroPublicCC.createSpriteCardShow(_hero_db.id, nil, _hero_data.turned_id)
    card:setScale(_fScaleCard)
    -- 按钮
    local select_menu = CCMenu:create()
    attr:addChild(select_menu)
	select_menu:setPosition(ccp(0, 0))
    -- 选择卡牌
    local select_btn = CCMenuItemSprite:create(card, card)
    select_menu:addChild(select_btn)
	select_btn:registerScriptTapHandler(callbackSelectHero)
	select_btn:setAnchorPoint(ccp(0, 1))
    local scale = 0.45
    select_btn:setScale(scale)
    select_btn:setContentSize(CCSizeMake(select_btn:getContentSize().width * 0.8, select_btn:getContentSize().height * 0.8))
    select_btn:setPosition(20, attr:getContentSize().height - 20)

    -- 卡牌名
    local db_hero = HeroUtil.getHeroLocalInfoByHtid(tonumber(_hero_data.htid))
    local name_color = HeroPublicLua.getCCColorByStarLevel(db_hero.star_lv)
    local name_labels = {}
    name_labels[1] = CCLabelTTF:create(_hero_db.name, g_sFontPangWa, 18)
    name_labels[1]:setColor(name_color)

    local levelStr = db_hero.star_lv == 6 and "  " .. GetLocalizeStringBy("zz_99",_hero_data.evolve_level) or "  +" .. _hero_data.evolve_level
    name_labels[2] = CCLabelTTF:create(levelStr, g_sFontPangWa, 18)
    name_labels[2]:setColor(ccc3(0x00, 0xff, 0x18))
    local name_node = BaseUI.createHorizontalNode(name_labels)
    select_btn:addChild(name_node)
    name_node:setAnchorPoint(ccp(0.5, 0.5))
    name_node:setPosition(ccp(select_btn:getContentSize().width * 0.5, - 25))
    name_node:setScale(1 / scale)
    
    if  _hero_data.talent.to_confirm["2"] ~= nil then
        _current_awaken_index = 2
        _radio_data.items[_current_awaken_index]:setEnabled(false)
        _radio_data.items[1]:setEnabled(true)
        _radio_data.items[3]:setEnabled(true)
    elseif _hero_data.talent.to_confirm["3"] ~= nil then
        _current_awaken_index = 3
        _radio_data.items[_current_awaken_index]:setEnabled(false)
        _radio_data.items[1]:setEnabled(true)
        _radio_data.items[2]:setEnabled(true)
    else
        _current_awaken_index = 1
    end
    refreshTalentInfo()

    -- 觉醒预览
    local preViewItem = CCMenuItemImage:create("images/biography/preview_btn_n.png","images/biography/preview_btn_h.png")
    preViewItem:setPosition(ccp(458, _attr:getContentSize().height - 330))
    preViewItem:registerScriptTapHandler(preViewItemCallback)
    select_menu:addChild(preViewItem,10)
end

function getCostInfo( ... )
    return _cost_infos
end

--[[
    @table awaken_info
    {
        title       标题
        name        名字
        level       星级
        des         描述
        old_level   旧的星级
    }
--]]
function createAwakenCell(awaken_info)
    local cell = CCNode:create()
    local cell_size = CCSizeMake(433, 168)
    cell:setContentSize(cell_size)
    local title_label = CCRenderLabel:create(tostring(awaken_info.title), g_sFontName, 25, 1, ccc3(0, 0, 0), type_shadow)
    cell:addChild(title_label)
    title_label:setAnchorPoint(ccp(0.5, 1))
    title_label:setPosition(ccp(cell_size.width * 0.5, cell_size.height))
    title_label:setColor(ccc3(0x00, 0xff, 0x18))
    
    local bg_size = CCSizeMake(433, 137)
    local bg = CCScale9Sprite:create("images/common/s9_4.png", CCRectMake(0, 0, 49, 49), CCRectMake(20, 20, 10, 8))
    cell:addChild(bg)
    bg:setPreferredSize(bg_size)
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(cell_size.width * 0.5, cell_size.height - title_label:getContentSize().height - 2))
    
    local line_y = bg_size.height - 20
    local awaken_name_lable = nil
    local des_label = nil
    if awaken_info.name ~= nil then
        awaken_name_lable = CCRenderLabel:create(awaken_info.name, g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
        bg:addChild(awaken_name_lable)
        awaken_name_lable:setAnchorPoint(ccp(0, 0.5))
        awaken_name_lable:setPosition(ccp(10, line_y))
        if awaken_info.name ~= "" then
            awaken_name_lable:setColor(getNameColorByStar(awaken_info.level))
            local x = 300
            local star_count_lable = CCRenderLabel:create(tostring(awaken_info.level), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
            bg:addChild(star_count_lable)
            star_count_lable:setAnchorPoint(ccp(0, 0.5))
            star_count_lable:setColor(ccc3(0x00, 0xff, 0x18))
            star_count_lable:setPosition(ccp(x, line_y))
            x = x + star_count_lable:getContentSize().width
            
            local star_icon = CCSprite:create("images/common/small_star.png")
            bg:addChild(star_icon)
            star_icon:setAnchorPoint(ccp(0, 0.5))
            star_icon:setPosition(ccp(x, line_y))
            x = x + star_icon:getContentSize().width
            
            local star_count_limit = string.split(_hero_db.refreshMaxStar, ",")
            if tostring(awaken_info.level) == star_count_limit[_current_awaken_index] then
                local full_lable = CCLabelTTF:create(GetLocalizeStringBy("key_8008"), g_sFontName, 20)
                bg:addChild(full_lable)
                full_lable:setAnchorPoint(ccp(0, 0.5))
                full_lable:setPosition(ccp(x, line_y))
                full_lable:setColor(ccc3(0xe4, 0x00, 0x00))
                x = x + full_lable:getContentSize().width
            end
            
            local arrow = nil
            if awaken_info.old_level ~= 0 and awaken_info.old_level < awaken_info.level then
                arrow = CCSprite:create("images/common/green_arrow.png")
                arrow:setRotation(-90)
            elseif awaken_info.old_level > awaken_info.level then
                arrow = CCSprite:create("images/common/red_arrow.png")
                arrow:setRotation(90)
            end
            if arrow ~= nil then
                bg:addChild(arrow)
                arrow:setAnchorPoint(ccp(0.5, 0.5))
                arrow:setPosition(ccp(x + arrow:getContentSize().width * 0.5, line_y))
                x = x + arrow:getContentSize().width
            end
        end
        des_label = CCLabelTTF:create(awaken_info.des, g_sFontName, 21)
        bg:addChild(des_label)
        des_label:setDimensions(CCSizeMake(390, 126))
        des_label:setHorizontalAlignment(kCCTextAlignmentLeft)
        des_label:setAnchorPoint(ccp(0, 1))
        des_label:setColor(awaken_info.des_color)
    else
        local tip = {}
        tip[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8082"), g_sFontName, 25)
        tip[1]:setColor(ccc3(0xff, 0xf6, 0x00))
        tip[2] = CCSprite:create("images/common/xiangxia.png")
        local tip_node = BaseUI.createHorizontalNode(tip)
        bg:addChild(tip_node)
        tip_node:setAnchorPoint(ccp(0.5, 0.5))
        tip_node:setPosition(ccp(210, 57))
    end
    
    local line = CCSprite:create("images/common/line02.png")
    bg:addChild(line)
    line:setScaleX(4)
    line:setAnchorPoint(ccp(0.5, 0.5))
    line:setPosition(ccp(bg_size.width * 0.5, line_y -  20))

    if des_label ~= nil then
        des_label:setPosition(ccp(10, line_y - 25))
    end
    return cell
end


function callbackAwakenRadio(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    
    local to_confirm = _hero_data.talent.to_confirm[tostring(_current_awaken_index)]
    if to_confirm ~= nil then
        require "script/ui/tip/SingleTip"
        SingleTip.showTip(GetLocalizeStringBy("key_8089"))
        _radio_data.items[tag]:setEnabled(true)
        _radio_data.items[_current_awaken_index]:setEnabled(false)
        return
    else
        _radio_data.items[tag]:setEnabled(false)
        if _current_awaken_index ~= -1 then
            _radio_data.items[_current_awaken_index]:setEnabled(true)
        end
    end
    
    _current_awaken_index = tag
    if _attr ~= nil then
        refreshTalentInfo()
    end
end

function getNameColorByStar(level)
    local name_color = ccc3(0xe4, 0x00, 0xff)
    if level >= 1 and level <= 2 then
        name_color = ccc3(0xff, 0xff, 0xff)
   elseif level >= 3 and level <= 5 then
        name_color = ccc3(0x00, 0xff, 0x18)
   elseif level >= 6 and level <= 7 then
        name_color = ccc3(0x00, 0xe4, 0xff)
   elseif level >= 8 and level <= 10 then
        name_color = ccc3(0xe4, 0x00, 0xff)
   end
   return name_color
end

-- 刷新天赋信息
function refreshTalentInfo()
    _could_comprehend = true
    -- local copy_level_tip = {"key_8001", "key_8002", "key_8003"}
    local copy_level_tip = {"lgx_1020","lgx_1020","lgx_1021"}
    local current_index = tostring(_current_awaken_index)
    if _to_awaken_info_cell ~= nil then
        _to_awaken_info_cell:removeFromParentAndCleanup(true)
    end
    if _awaken_info_cell ~= nil then
        _awaken_info_cell:removeFromParentAndCleanup(true)
    end
    print("cur_indoex =", current_index)
    local awaken_id = _hero_data.talent.confirmed[ current_index]
    local awaken_info_db = nil
    local awaken_info = {}
    awaken_info.title = GetLocalizeStringBy("key_8083")
    if awaken_id ~= nil then
        awaken_info_db = DB_Hero_refreshgift.getDataById(tonumber(awaken_id))
        awaken_info.level = awaken_info_db.level
        awaken_info.name = awaken_info_db.name
        awaken_info.des = awaken_info_db.des
        awaken_info.old_level = 0
        awaken_info.des_color = ccc3(0xff, 0xff, 0xff)
        local awaken_copy_db = string.split(_hero_db.hero_copy_id, ",")
        -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
        local neeedPotential = tonumber(string.split(awaken_copy_db[_current_awaken_index], "|")[1])
        local need_advance_level = tonumber(string.split(awaken_copy_db[_current_awaken_index], "|")[2])
        -- 是否满足进阶等级要求
        local isLevelOpen = tonumber(_hero_db.potential) > neeedPotential or (tonumber(_hero_db.potential) == neeedPotential and tonumber(_hero_data.evolve_level) >= need_advance_level)
        if isLevelOpen == false then
            _could_comprehend = false
            _tip_text = GetLocalizeStringBy(copy_level_tip[_current_awaken_index]) .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8006") 
        end
    else
        awaken_info.name = ""--GetLocalizeStringBy("key_8004")
        local awaken_copy_db = string.split(_hero_db.hero_copy_id, ",")
        -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
        local neeedPotential = tonumber(string.split(awaken_copy_db[_current_awaken_index], "|")[1])
        local need_advance_level = tonumber(string.split(awaken_copy_db[_current_awaken_index], "|")[2])
        -- 是否满足进阶等级要求
        local isLevelOpen = tonumber(_hero_db.potential) > neeedPotential or (tonumber(_hero_db.potential) == neeedPotential and tonumber(_hero_data.evolve_level) >= need_advance_level)
        if isLevelOpen == false then
            awaken_info.des = GetLocalizeStringBy(copy_level_tip[_current_awaken_index]) .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8006")
            awaken_info.des_color = ccc3(0xe4, 0x00, 0x00)
            _could_comprehend = false
            _tip_text = awaken_info.des
        else
            awaken_info.des = GetLocalizeStringBy("key_8007")
            awaken_info.des_color = ccc3(0xff, 0xff, 0xff)
        end
    end
    _awaken_info_cell = createAwakenCell(awaken_info)
    _attr:addChild(_awaken_info_cell)
    _awaken_info_cell:setPosition(ccp(152, _attr:getContentSize().height - 186))
    
    local to_awaken_id = _hero_data.talent.to_confirm[ current_index]
    to_awaken_info = {}
    to_awaken_info.title = GetLocalizeStringBy("key_8084")
    if to_awaken_id ~= nil and type(to_awaken_id) == "string" then
        print("_hero_data==========")
        print_t(_hero_data)
        local to_awaken_info_db = DB_Hero_refreshgift.getDataById(tonumber(to_awaken_id))
        to_awaken_info.level = to_awaken_info_db.level
        to_awaken_info.name = to_awaken_info_db.name
        to_awaken_info.des = to_awaken_info_db.des
        to_awaken_info.des_color = ccc3(0xfe, 0xdb, 0x1c)
        if awaken_id ~= nil then
            to_awaken_info.old_level = awaken_info_db.level
        else
            to_awaken_info.old_level = 0
        end
        setMenuVisible(true)
    else
        setMenuVisible(false)
    end
    _to_awaken_info_cell = createAwakenCell(to_awaken_info)
    _attr:addChild(_to_awaken_info_cell)
    _to_awaken_info_cell:setPosition(ccp(23, _attr:getContentSize().height - 353))
end

function loadMenu()
    _menu = CCMenu:create()
    _menu:setContentSize(CCSizeMake(640, 70))
    _menu:setScale(MainScene.elementScale * 0.98)
    local picture_n = "images/common/btn/btn_blue_n.png"
    local picture_h = "images/common/btn/btn_blue_h.png"
    local text_color = ccc3(0xfe, 0xdb, 0x1c)
    local btn_size = CCSizeMake(185, 70)
    local left_point = ccp(120, 0)
    local center_point = ccp(320, 0)
    local right_point = ccp(520, 0)
    
    -- 保留
	_not_change_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, btn_size, GetLocalizeStringBy("key_1202"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_menu:addChild(_not_change_btn)
    _not_change_btn:setAnchorPoint(ccp(0.5, 0))
    _not_change_btn:setPosition(center_point)
	_not_change_btn:registerScriptTapHandler(callbackNotChange)
    
    -- 替换
    _change_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, btn_size, GetLocalizeStringBy("key_1871"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_menu:addChild(_change_btn)
    _change_btn:setAnchorPoint(ccp(0.5, 0))
    _change_btn:setPosition(right_point)
	_change_btn:registerScriptTapHandler(callbackChange)
    
    -- 激活
    _activate_btn = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png", "images/common/btn/purple01_h.png", btn_size, GetLocalizeStringBy("zzh_1286"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_menu:addChild(_activate_btn)
    _activate_btn:setAnchorPoint(ccp(0.5, 0))
    _activate_btn:setPosition(right_point)
	_activate_btn:registerScriptTapHandler(activateCallback)
    
    -- 批量领悟
    _batchComprehend_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, btn_size, GetLocalizeStringBy("key_10207"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_batchComprehend_btn)
    _batchComprehend_btn:setAnchorPoint(ccp(0.5, 0))
    _batchComprehend_btn:setPosition(ccp(640 - 232, 0))
    _batchComprehend_btn:registerScriptTapHandler(batchComprehendCallback)
    
    -- 传承
    _inherit_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, btn_size, GetLocalizeStringBy("key_8192"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_menu:addChild(_inherit_btn)
    _inherit_btn:setAnchorPoint(ccp(0.5, 0))
    _inherit_btn:setPosition(center_point)
	_inherit_btn:registerScriptTapHandler(callbackInherit)
    
    
    if table.isEmpty(_hero_data.talent.to_confirm) then
        setMenuVisible(false)
    else
        setMenuVisible(true)
    end
end

-- 批量领悟
function batchComprehendCallback( ... )
    if not _could_comprehend then
        SingleTip.showTip(_tip_text)
        return
    end
    require "script/ui/biography/ComprehendBatchLayer"
    local callback = function ( ... )
        ComprehendBatchLayer.show(_hero_hid, _current_awaken_index, _current_cost_index, -700, 1000)
        refreshAfterComprehend()
    end
    if table.isEmpty(_hero_data.talent.to_confirm[tostring(_current_awaken_index)]) then
        local item_is_full = checkItemIsfull(_current_cost_index)
        if not item_is_full then
            return
        end
        local alertCallback = function (p_confirmed)
            if p_confirmed == true then
                ComprehendBatchLayer.comprehend(_hero_data, _current_awaken_index, _current_cost_index, _cost_infos, callback)
            end
        end
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_10208"), alertCallback, true)
    else
        callback()
    end
end

-- 激活觉醒能力
function activateCallback()
    local copy_level_tip = {"lgx_1020","lgx_1020","lgx_1021"}
    local awaken_copy_db = string.split(_hero_db.hero_copy_id, ",")
    -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
    local neeedPotential = tonumber(string.split(awaken_copy_db[_current_awaken_index], "|")[1])
    local need_advance_level = tonumber(string.split(awaken_copy_db[_current_awaken_index], "|")[2])
    -- 是否满足进阶等级要求
    local isLevelOpen = tonumber(_hero_db.potential) > neeedPotential or (tonumber(_hero_db.potential) == neeedPotential and tonumber(_hero_data.evolve_level) >= need_advance_level)
    if isLevelOpen == false then
        local tip = GetLocalizeStringBy(copy_level_tip[_current_awaken_index]) .. tostring(need_advance_level) .. GetLocalizeStringBy("key_8006")
        AnimationTip.showTip(tip)
        return
    end
    local args = Network.argsHandler(_hero_data.hid)
    RequestCenter.heroActivateSealTalent(handleActivate, args)
end

function handleActivate(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
   _hero_data.talent.sealed = _hero_data.talent.sealed or {}
    local richInfo = {}
    richInfo.elements = {}
    local texts = {["1"] = GetLocalizeStringBy("key_8336"), ["2"] = GetLocalizeStringBy("key_8337"), ["3"] = GetLocalizeStringBy("lgx_1022")}
    for k, v in pairs(_hero_data.talent.sealed) do
        if v ~= "0" and (dictData.ret.talent.sealed[k] == nil or dictData.ret.talent.sealed[k] == "0") then
            local element = {}
            element.type = "CCLabelTTF"
            element.text = texts[k]
            if #richInfo.elements > 1 then
                element.newLine = true
            end
            table.insert(richInfo.elements, element)
            local element2 = {}
            element2.type = "CCRenderLabel"
            local awaken_info_db = DB_Hero_refreshgift.getDataById(tonumber(dictData.ret.talent.confirmed[k]))
            element2.text = awaken_info_db.name
            element2.color = getNameColorByStar(awaken_info_db.level)
            element2.font = g_sFontPangWa
            table.insert(richInfo.elements, element2)
        end
    end
    require "script/ui/tip/RichAnimationTip"
    RichAnimationTip.showTip(richInfo)
    _hero_data.talent = dictData.ret.talent
    setMenuVisible(_btn_status)
end

function callbackInherit()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if isNeedActivate() == true then
        SingleTip.showTip(GetLocalizeStringBy("key_10160"))
        return
    end
    require "script/ui/biography/ComprehendInheritLayer"
    ComprehendInheritLayer.show(_hero_hid)
end

-- 保留按钮回调
function callbackNotChange()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local args = Network.argsHandler(_hero_data.hid, _current_awaken_index)
    RequestCenter.heroKeepTalent(handleKeepTalent, args)
end

-- 替换按钮回调
function callbackChange()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local args = Network.argsHandler(_hero_data.hid, _current_awaken_index, _hero_data.talent.to_confirm[tostring(_current_awaken_index)])
    RequestCenter.heroReplaceTalent(handleReplaceTalent, args)
    refreshTalentInfo()
end

function callbackBack()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
       
    require "script/ui/hero/HeroLayer"
    _layer:removeFromParentAndCleanup(true)
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
end

-- 领悟按钮回调
function callbackComprehend()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if isNeedActivate() == true then
        SingleTip.showTip(GetLocalizeStringBy("key_10161"))
        return
    end
    if not _could_comprehend then
        SingleTip.showTip(_tip_text)
        return
    end
    local item_is_full = checkItemIsfull(_current_cost_index)
    if not item_is_full then
        return
    end
    
    -- todo
    local new_awaken_info = {}
    local new_awaken_id = _hero_data.talent.to_confirm[tostring(_current_awaken_index)]
    local awaken_info_db = nil
    if new_awaken_id ~= nil and tonumber(new_awaken_id) ~= 0 then
        awaken_info_db = DB_Hero_refreshgift.getDataById(tonumber(new_awaken_id))
    end
    if new_awaken_id ~= nil and awaken_info_db.level >= 8 then
        
        new_awaken_info.level = awaken_info_db.level
        new_awaken_info.name = awaken_info_db.name
            
        local richInfo =
        {
            elements =
            {
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("key_8310"),
                },
                {
                    type = "CCRenderLabel", 
                    text = string.format("%s", new_awaken_info.name),
                    font = g_sFontPangWa,
                    renderType = 2,
                    color = getNameColorByStar(new_awaken_info.level)
                },
                {
                    type = "CCLabelTTF", 
                    text = GetLocalizeStringBy("key_8311"),
                },
            }
        }
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(richInfo, comprehend, true, nil, GetLocalizeStringBy("key_2864"))
    else
        comprehend(true)
    end
end

function comprehend(p_confirmed, arg)
    if p_confirmed == true then
        local args = Network.argsHandler(_hero_data.hid, _current_awaken_index, _current_cost_index, 0, 1)
        RequestCenter.heroComprehendTalent(handleComprehendTalent, args)
    end
end

function checkItemIsfull(index)
    local cost_info = _cost_infos[index]
    local jewel_count = UserModel.getJewelNum()
    local tip = nil
    local item_is_full = true
    if jewel_count < cost_info.jewel then
        item_is_full = false
        tip = GetLocalizeStringBy("key_8011")
    else
        local gold = UserModel.getGoldNumber()
        if gold < cost_info.gold then
            item_is_full = false
            tip = GetLocalizeStringBy("key_8012")
        else
            if _current_item_count < cost_info.item_count then
                item_is_full = false
                tip = ItemUtil.getItemById(cost_info.item_id).name .. GetLocalizeStringBy("key_8013")
            end
        end
    end
    if not item_is_full then
        SingleTip.showTip(tip)
    end
    return item_is_full
end

function createCurrentItemCount(node)
     -- 当前拥有
    local current_lable = CCRenderLabel:create(GetLocalizeStringBy("key_8014"), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    node:addChild(current_lable)
    current_lable:setColor(ccc3(0x00, 0xff, 0x18))
    current_lable:setAnchorPoint(ccp(1, 0))
    current_lable:setPosition(ccp(290, _items_title:getPositionY() ))
    _current_item_node_y = current_lable:getPositionY()
    
    local jewel_icon = CCSprite:create("images/common/jewel_small.png")
    node:addChild(jewel_icon)
    jewel_icon:setPosition(ccp(285, current_lable:getPositionY() - 3))

    local item_icon = CCSprite:create("images/common/tiger_icon.png")
    node:addChild(item_icon)
    item_icon:setPosition(ccp(410, current_lable:getPositionY() - 3))
    
    refreshCurrentItemCount(node)
end

function refreshCurrentItemCount(node)
    if _jewel_lable ~= nil then
        if node == nil then
            node = _jewel_lable:getParent()
        end
        _jewel_lable:removeFromParentAndCleanup(true)
        _item_lable:removeFromParentAndCleanup(true)
    end
    local current_jewel_count = UserModel.getJewelNum()
    _jewel_lable = CCRenderLabel:create(GetLocalizeStringBy("key_8075", tostring(current_jewel_count)), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    node:addChild(_jewel_lable)
    _jewel_lable:setColor(ccc3(0x00, 0xff, 0x18))
    _jewel_lable:setAnchorPoint(ccp(0, 0))
    _jewel_lable:setPosition(ccp(320, _current_item_node_y))
    
    _item_lable = CCRenderLabel:create(GetLocalizeStringBy("key_8076", tostring(_current_item_count)), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    node:addChild(_item_lable)
    _item_lable:setColor(ccc3(0x00, 0xff, 0x18))
    _item_lable:setAnchorPoint(ccp(0, 0))
    _item_lable:setPosition(460, _current_item_node_y)

end

-- 领悟网络回调
function handleComprehendTalent(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    print("领悟成功")
    print_t(dictData)
    local cost_info = _cost_infos[_current_cost_index]
    -- 扣除魂玉
    UserModel.addJewelNum(-cost_info.jewel)
    -- 扣除物品
    addItemCount(-cost_info.item_count)
    
    UserModel.addGoldNumber(-cost_info.gold)
   
    _hero_data.talent.to_confirm[tostring(_current_awaken_index)] = dictData.ret
    
    refreshAfterComprehend()
end

function addItemCount( itemCount )
    _current_item_count = _current_item_count + itemCount
end

function refreshAfterComprehend( ... )
    _gold_count_labelvalue:setString(tostring(UserModel.getGoldNumber()))
    refreshTalentInfo()
    refreshCurrentItemCount()
end

-- 替换网络回调
function handleReplaceTalent(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    _hero_data.talent.confirmed[tostring(_current_awaken_index)] = _hero_data.talent.to_confirm[tostring(_current_awaken_index)]
    _hero_data.talent.to_confirm = {}
    refreshTalentInfo()
end

-- 保留网络回调
function handleKeepTalent(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    _hero_data.talent.to_confirm = {}
    refreshTalentInfo()
    setMenuVisible(false)
end

function isNeedActivate()
    local awaken_id = _hero_data.talent ~= nil and (_hero_data.talent.sealed ~= nil and _hero_data.talent.sealed[tostring(_current_awaken_index)] or nil) or nil
    if awaken_id ~= nil and awaken_id ~= "0" then
        return true
    else
        return false
    end
end


function refreshBackBtn( ... )
    if _back_btn then
        _back_btn:removeFromParentAndCleanup(true)
    end
    local picture_n = "images/common/btn/btn_blue_n.png"
    local picture_h = "images/common/btn/btn_blue_h.png"
    local text_color = ccc3(0xfe, 0xdb, 0x1c)
    local btn_size = CCSizeMake(185, 70)
    local position = ccp(120, 0)
    local center_point = ccp(320, 0)
    local right_point = ccp(520, 0)
    if table.isEmpty(_hero_data.talent.to_confirm) or type(_hero_data.talent.to_confirm[tostring(_current_awaken_index)]) == "table" --[[or _hero_data.talent.to_confirm[tostring(_current_awaken_index)] == nil--]] then
        if not isNeedActivate() then
            btn_size = CCSizeMake(130, 70)
            position = ccp(85, 0)
        end
    end
    --  返回
    _back_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, btn_size, GetLocalizeStringBy("key_8009"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_back_btn)
    _back_btn:setAnchorPoint(ccp(0.5, 0))
    _back_btn:setPosition(position)
    _back_btn:registerScriptTapHandler(callbackBack)

end

function refreshComprehendBtn( ... )
    if _comprehend_btn ~= nil then
        _comprehend_btn:removeFromParentAndCleanup(true)
        _comprehend_btn = nil
    end
    local picture_n = "images/common/btn/btn_blue_n.png"
    local picture_h = "images/common/btn/btn_blue_h.png"
    local text_color = ccc3(0xfe, 0xdb, 0x1c)
    local btn_size = CCSizeMake(130, 70)
    local position = ccp(640 - 85, 0)
    if not table.isEmpty(_hero_data.talent.to_confirm) and type(_hero_data.talent.to_confirm[tostring(_current_awaken_index)]) ~= "table" --[[and _hero_data.talent.to_confirm[tostring(_current_awaken_index)] ~= nil--]] then
        if not isNeedActivate() then
            btn_size = CCSizeMake(185, 70)
            position = ccp(320, 0)
        end
    end
    --  领悟
    _comprehend_btn = LuaCC.create9ScaleMenuItem(picture_n, picture_h, btn_size, GetLocalizeStringBy("key_8000"), text_color, 35, g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_comprehend_btn)
    _comprehend_btn:setAnchorPoint(ccp(0.5, 0))
    _comprehend_btn:setPosition(position)
    _comprehend_btn:registerScriptTapHandler(callbackComprehend)
end

-- 按钮是否可见的相互转换
function setMenuVisible(is_visible)
    refreshBackBtn()
    refreshComprehendBtn()
    _btn_status = is_visible
    local left_point = ccp(120, 0)
    local center_point = ccp(320, 0)
    local right_point = ccp(640 - 120, 0)
    _batchComprehend_btn:setVisible(false)
    _inherit_btn:setPosition(center_point)
    if is_visible then
        --_back_btn:setPosition(left_point)
        _not_change_btn:setPosition(left_point)
        --_comprehend_btn:setPosition(center_point)
        _change_btn:setPosition(right_point)
        if isNeedActivate() == true then
            _activate_btn:setVisible(true)
            _change_btn:setVisible(false)
        else
            _activate_btn:setVisible(false)
            _change_btn:setVisible(true)
        end
    else
        --_back_btn:setPosition(left_point)--(ccp(190 * MainScene.elementScale, 0))
        --_comprehend_btn:setPosition(right_point)--(ccp(g_winSize.width - 190 * MainScene.elementScale, 0))
        if isNeedActivate() == true then
            _activate_btn:setVisible(true)
            _comprehend_btn:setVisible(false)
        else
            _activate_btn:setVisible(false)
            _comprehend_btn:setVisible(true)
            _batchComprehend_btn:setVisible(true)
            _inherit_btn:setPosition(ccp(232, 0))
        end
        -- todo
    end
    --_comprehend_btn:setVisible(not is_visible)
    _not_change_btn:setVisible(is_visible)
    _change_btn:setVisible(is_visible)
    _back_btn:setVisible(not is_visible)
    _inherit_btn:setVisible(not is_visible)

 

end

function createTip()
    local tip_lables = {}
    tip_lables[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8016"), g_sFontPangWa, 25)
    tip_lables[1]:setColor(ccc3(0x78, 0x25, 0x00))
    tip_lables[2] = CCLabelTTF:create(GetLocalizeStringBy("key_8017"), g_sFontPangWa, 28)
    tip_lables[2]:setColor(ccc3(0x83, 0x00, 0x92))
    tip_lables[3] = CCLabelTTF:create(GetLocalizeStringBy("key_8019"), g_sFontPangWa, 25)
    tip_lables[3]:setColor(ccc3(0x78, 0x25, 0x00))
    local tip_lable = BaseUI.createHorizontalNode(tip_lables)
    for i = 1, #tip_lables do
        tip_lables[i]:setAnchorPoint(ccp(0, 0))
    end
    return tip_lable
end

function createCostInfoNode()
    -- 背景图
	local fullRect = CCRectMake(0, 0, 61, 47)
	local insetRect = CCRectMake(24, 16, 10, 4)
    local bg_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
    bg_ng:setPreferredSize(CCSizeMake(571, 161))

    local radio_menu = CCMenu:create()
    radio_menu:ignoreAnchorPointForPosition(false)
    radio_menu:setTouchPriority(-128)
    radio_menu:setContentSize(bg_ng:getContentSize())
    bg_ng:addChild(radio_menu)
    radio_menu:setAnchorPoint(ccp(0, 0.5))
    radio_menu:setPosition(ccp(43, bg_ng:getContentSize().height * 0.5 - 5))
    radio_menu:setScale(1)
    local bg_content_size = bg_ng:getContentSize()
    local n = #_cost_infos
    for i = 1, n do

        local row = math.floor((i-1)/2)+1
        local col = (i-1)%2
        print("row:"..row.."col:"..col)
        local radioItem = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
        radioItem:setPosition(bg_content_size.width*0.48*col, bg_content_size.height - 10 - (row  - 0.5) * 65)
        radioItem:setAnchorPoint(ccp(0.5, 0.5))
        radioItem:registerScriptTapHandler(selectedCost)
        radio_menu:addChild(radioItem,1,i)
        if i == 1 then
            --设置默认选择
            _selectedItem = radioItem
            _selectedItem:selected()
        end

        local cost_info = _cost_infos[i]
        local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8015"), g_sFontName, 21)
        bg_ng:addChild(tip)
        tip:setColor(ccc3(0x78, 0x25, 0x00))
        tip:setAnchorPoint(ccp(0, 0.5))
        local y = bg_content_size.height - 10 - (row  - 0.5) * 65 - 4
        tip:setPosition(ccp(75+bg_content_size.width*0.48*col, y))
        
        local cost_cell_datas = {
            {icon = "images/common/jewel_small.png", space = 10, count = cost_info.jewel, color = ccc3(0x00, 0xe4, 0xff), size = 21},
            {icon = "images/common/gold.png", space = 10, count = cost_info.gold, color = ccc3(0xff, 0xf6, 0x00), size = 21},
            {icon = "images/common/tiger_icon.png", space = 10, count = cost_info.item_count, color = ccc3(0x00, 0xff, 0x18), size = 21}
        }
        local cost_cell_position_x
        if (Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
            cost_cell_position_x = {180, 240, 380}
        else
            cost_cell_position_x = {148, 226, 363}
        end
        local current_index = 1
        for i = 1, #cost_cell_datas do
            local cost_cell_data = cost_cell_datas[i]
            if cost_cell_data.count ~= 0 then
                local cost_cell = CCNode:create()
                bg_ng:addChild(cost_cell)
                cost_cell:setPosition(ccp(cost_cell_position_x[current_index]+bg_content_size.width*0.48*col, y))
                local icon = CCSprite:create(cost_cell_data.icon)
                cost_cell:addChild(icon)
                icon:setAnchorPoint(ccp(0.5, 0.5))
                local count_label = CCRenderLabel:create(tostring(cost_cell_data.count), g_sFontName, cost_cell_data.size, 1, ccc3(0, 0, 0), type_shadow)
                icon:addChild(count_label)
                count_label:setColor(cost_cell_data.color)
                count_label:setAnchorPoint(ccp(0, 0.5))
                count_label:setPosition(ccp(icon:getContentSize().width + cost_cell_data.space, icon:getContentSize().height * 0.5))
                current_index = current_index + 1
            end
            
        end
    end
    -- 领悟消耗
    _items_title = CCRenderLabel:create(GetLocalizeStringBy("key_1212"), g_sFontPangWa, 21, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    bg_ng:addChild(_items_title)
    _items_title:setAnchorPoint(ccp(0, 0))
    _items_title:setColor(ccc3(0xff, 0xff, 0xff))
    _items_title:setPosition(ccp(0,bg_ng:getContentSize().height + 5))
    
    createCurrentItemCount(bg_ng)
    
    return bg_ng
end

function selectedCost(tag, menu_item)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 选中按钮
    _selectedItem:unselected()
    _selectedItem = menu_item
    _selectedItem:selected()
    _current_cost_index = tag
end

-- 创建物品列表单元
function createCell(tParam, index)
	local ccCell = CCTableViewCell:create()

    local headIcon
    if index + 1 == #_arrNeedItems then
        if tonumber(_hero_db.costJewel) > 0 then
            headIcon = ItemSprite.getJewelSprite()
        end
    else
        headIcon = ItemSprite.getItemSpriteById(tParam.id, nil, nil, nil, -500, 1000, nil,true)
    end
	ccCell:addChild(headIcon, 1, 10001)
	-- 武将或物品个数比例显示
	local ccRenderLabelCount = CCRenderLabel:create(tParam.realCount .. "/" .. tParam.needCount, g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	if tParam.realCount < tParam.needCount then
        _item_is_full = false
		ccRenderLabelCount:setColor(ccc3(0xff, 0, 0))
	else
		ccRenderLabelCount:setColor(ccc3(0, 0xff, 0x18))
	end
	ccRenderLabelCount:setPosition(headIcon:getContentSize().width/2, ccRenderLabelCount:getContentSize().height/2+2)
	ccRenderLabelCount:setAnchorPoint(ccp(0.5, 0.5))
	headIcon:addChild(ccRenderLabelCount)

	return ccCell
end

function loadFunctionMenu()
    MenuLayer.getObject():setVisible(true)
end

-- 屏幕适配
function adaptive()
	local bulletin_layer_size = BulletinLayer.getLayerContentSize()
	local menu_layer_size = MenuLayer.getLayerContentSize()
    
    _layer:addChild(_BG)
    _BG:setAnchorPoint(ccp(0, 0))
    _BG:setScale(g_fBgScaleRatio)
    
    _layer:addChild(_info_node, 10)
	local _info_node_y = g_winSize.height - bulletin_layer_size.height * g_fScaleX
    _info_node:setAnchorPoint(ccp(0, 1))
    _info_node:setScale(g_fScaleX)
    _info_node:setPosition(0, _info_node_y)
    
    _layer:addChild(_title, 10)
    _title:setScale(g_fScaleX)
    _title:setAnchorPoint(ccp(0.5, 1))
    local title_y = _info_node_y - _info_node:getContentSize().height * g_fScaleX
    _title:setPosition(g_winSize.width * 0.5, title_y)
    
    
    
    _layer:addChild(_comprehend)
    _comprehend:setScale(MainScene.elementScale * 0.97)
    _comprehend:setAnchorPoint(ccp(0.5, 1))
    _comprehend:setPosition(ccp(g_winSize.width * 0.5, _title:getPositionY() - 20 * MainScene.elementScale))
    
    -- 物品列表
    local items_list = createCostInfoNode()--createItemsList()
    _layer:addChild(items_list)
    items_list:setAnchorPoint(ccp(0.5, 1))
    items_list:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.365))
    items_list:setScale(MainScene.elementScale * 0.97)
    
    _layer:addChild(_menu)
    _menu:setAnchorPoint(ccp(0.5, 0))
    _menu:ignoreAnchorPointForPosition(false)
    _menu:setPosition(ccp(g_winSize.width * 0.5, menu_layer_size.height * g_fScaleX + 12 * MainScene.elementScale))

end

-- 选择武将
function callbackSelectHero()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "script/ui/hero/HeroSelectLayer"
	require "script/ui/main/MainScene"

	local tArgsOfModule = {withoutExp=true, isSingle=true}
	tArgsOfModule.sign="ComprehendLayer"
	tArgsOfModule.fnCreate = function(selected_data)
        local hero_data
        if #selected_data.selectedHeroes >= 1 then
            hero_data = selected_data.selectedHeroes[1]
        else
            hero_data = selected_data.selectedHeroes
        end
        show(hero_data.hid,nil,true)
    end
    tArgsOfModule.selected = {tostring(_hero_data.hid), }
    tArgsOfModule.filters = getHeroesFileter()
	MainScene.changeLayer(HeroSelectLayer.createLayer(tArgsOfModule), "HeroSelectLayer")
end

-- 对武将进行筛选
function getHeroesFileter()
    local hero_htid_fileter = {}
    local heros = HeroModel.getAllHeroes()
    for htid, hero in pairs(heros) do
		if not couldComprehendHero(hero) then
            hero_htid_fileter[#hero_htid_fileter + 1] = hero.hid
        end
	end
    return hero_htid_fileter
end

-- 筛选条件
function couldComprehendHero(hero)
    local hero_db = DB_Heroes.getDataById(hero.htid)
    local awaken_copy_db = string.split(hero_db.hero_copy_id, ",")
    if #awaken_copy_db >= 1 then
        return true
    end
    return false
end


function couldComprehend(hero_hid)
    local hero_data = HeroModel.getHeroByHid(hero_hid)
    return StarUtil.isHasHeroCopyBy(hero_data.htid)
end

--[[
    @desc:  觉醒预览按钮回调
--]]
function preViewItemCallback()
    -- 显示觉醒预览界面
    require "script/ui/biography/ComprehendPreviewDialog"
    ComprehendPreviewDialog.showLayer(_current_awaken_index)
end


