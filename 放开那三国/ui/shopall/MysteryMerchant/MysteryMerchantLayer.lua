-- Filename：	MysteryMerchantLayer.lua
-- Author：		bzx
-- Date：		2014-04-01
-- Purpose：		神秘商人

module ("MysteryMerchantLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/model/user/UserModel"
require "script/ui/recycle/RecycleMain" 
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/utils/TimeUtil"
require "script/ui/shopall/MysteryMerchant/MysteryMerchantCell"
require "script/libs/LuaCC"
require "script/network/PreRequest"
require "script/ui/item/ItemUtil"
require "script/libs/LuaCCSprite"
require "script/network/RequestCenter"

local _layer                        -- 当前层
local _spirit_jade_count_tip        -- 当前剩余魂玉
local _spirit_jade_count_labelvalue -- 魂玉数量
local _disappear_time_tip           -- 神秘商人消失剩余时间
local _disappear_time_labelvalue    -- 时间值
local _border_top                   -- 上花边
local _mystery_merchant_title       -- 神秘商人标题
local _border_bottom                -- 底部花边
local _item_node                    -- 商品列表
local _arrow_up                     -- 向上的箭头
local _arrow_down                   -- 向下的箭头
local _next_refresh_time_tip        -- 下次刷新物品时间
local _next_refresh_time_labelvalue
local _refresh_tip
local _refresh_gold_count_labelvalue
local _refresh_gold_count           -- 单次刷新所花金币数
local _current_refresh_else_lable   -- 显示刷新令数量
local _current_refresh_else         -- 当前拥有刷新令。。。
local _refresh_btn                  -- 刷新按钮
local _item_table                   -- 商品数据
local _item_table_view
local _table_view_height
local _update_timer
local _menu
local _hero_node
local _summoned_btn
local _hero_table_view
local _hero_table_view_height
local _offset

local _refresh_type                 -- 刷新类型
local _refresh_type_gold    = 1     -- 金币刷新
local _refresh_type_else    = 2     -- 其它物品刷新

local _centerSize           = nil
local _centerLayer          = nil

function createCenterLayer( p_centerLayerSize )
    init()
    _centerSize = p_centerLayerSize or g_winSize
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)
    local requestCallback = function()
        if ActiveCache.MysteryMerchant:isRefreshed() then
            AnimationTip.showTip(GetLocalizeStringBy("key_2799"))
        end
        --显示神秘商人
        loadBG()
        loadMenu()
        loadJadeCount()
        if ActiveCache.MysteryMerchant:isExist() then
            _item_table = ActiveCache.MysteryMerchant:getItemTable()
            if not ActiveCache.MysteryMerchant:isPerpetual() then
                loadSummoned()
            end
            loadRefresh()
            loadItemList()
        else
            loadMysteryMerchantTip()
            loadSummoned()
            loadHeroList()
        end
    end
    ActiveCache.MysteryMerchant:requestData(requestCallback)
    return _centerLayer
end

function init()
    _refresh_btn = nil
    _hero_table_view = nil
    _arrow_down = nil 
    _arrow_up = nil
    _update_timer = nil
    _offset = nil
    _item_table_view = nil
end

-- 背景
function loadBG()
    -- 背景色
    local bg = CCScale9Sprite:create("images/recharge/mystery_merchant/bg.png",
                                CCRectMake(0, 0, 55, 50),
                                CCRectMake(26, 30, 6, 4))
    _centerLayer:addChild(bg)
    bg:setPreferredSize(_centerSize)

    -- 上面的花边
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local  activeMainWidth = ShoponeLayer.getBgWidth()
    local border_filename = "images/recharge/mystery_merchant/border.png"
    _border_top = CCSprite:create(border_filename)
    _centerLayer:addChild(_border_top)
    _border_top:setAnchorPoint(ccp(0, 0))
    _border_top:setScale(g_fScaleX)
    _border_top:setScaleY(-g_fScaleX)
    _border_top:setPosition(0, _centerSize.height)
    
    -- 神秘商人字样
    _mystery_merchant_title = CCSprite:create("images/recharge/mystery_merchant/title.png")
    _centerLayer:addChild(_mystery_merchant_title, 100)
    _mystery_merchant_title:setAnchorPoint(ccp(0, 1))
    _mystery_merchant_title:setPosition(0, _border_top:getPositionY())
    _mystery_merchant_title:setScale(g_fScaleX)
    
    -- 下面的花边
    local menuLayerSize = MenuLayer.getLayerContentSize()
    _border_bottom = CCSprite:create(border_filename)
    _centerLayer:addChild(_border_bottom)
    _border_bottom:setAnchorPoint(ccp(0, 0))
    _border_bottom:setScale(g_fScaleX)
    _border_bottom:setPosition(0, 0)
    
    -- 神秘商人图像
    local mystery_merchant_role = CCSprite:create("images/recharge/mystery_merchant/ren.png")
    _centerLayer:addChild(mystery_merchant_role)
    mystery_merchant_role:setAnchorPoint(ccp(0, 0.5))
    mystery_merchant_role:setPosition(0,  _centerSize.height * 0.5)
    mystery_merchant_role:setScale(MainScene.elementScale)
end

function loadJadeCount()
    local spirit_jade_count_tip = {}
	spirit_jade_count_tip[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1339"), g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	spirit_jade_count_tip[1]:setColor(ccc3(0x00, 0xe4, 0xff))
	spirit_jade_count_tip[2] = CCRenderLabel:create(tostring(UserModel.getJewelNum()) , g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	spirit_jade_count_tip[2]:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _spirit_jade_count_labelvalue = spirit_jade_count_tip[2]
	_spirit_jade_count_tip = BaseUI.createHorizontalNode(spirit_jade_count_tip)
	_spirit_jade_count_tip:setScale(MainScene.elementScale)
    
    local _spirit_jade_count_tip_y = _mystery_merchant_title:getPositionY() -  40 * MainScene.elementScale
	_spirit_jade_count_tip:setPosition(g_winSize.width * 25 / 64, _spirit_jade_count_tip_y)
	_spirit_jade_count_tip:setAnchorPoint(ccp(0, 0))
	_centerLayer:addChild(_spirit_jade_count_tip)
end

function heroClickedCallback(tag, menu_item)
end

function loadHeroList()
    _hero_node = CCScale9Sprite:create("images/star/intimate/bottom9s.png",
                                       CCRectMake(0, 0, 75, 75),
                                       CCRectMake(0, 0, 0, 0))
	_centerLayer:addChild(_hero_node, 100)    
    
    local hero_node_height = (_spirit_jade_count_tip:getPositionY()  - 220 * MainScene.elementScale)/ MainScene.elementScale -
    (_spirit_jade_count_tip:getContentSize().height ) - _summoned_btn:getPositionY() / MainScene.elementScale
    _hero_node:setPreferredSize(CCSizeMake(385, hero_node_height))
    _hero_node:setScale(MainScene.elementScale)
    local hero_node_y = _summoned_btn:getPositionY() + (_summoned_btn:getContentSize().height * 0.5 + 13)*
    MainScene.elementScale
    _hero_node:setPosition(ccp(g_winSize.width - 5, hero_node_y))
    _hero_node:setAnchorPoint(ccp(1, 0))
    
	local cell_size = CCSizeMake(359, 150)  
    local cell_icon_count = 3
    require "db/DB_Normal_config"
    require "script/utils/LuaUtil"
    require "script/ui/chat/ChangeHeadLayer"
    local normal_config_db = parseDB(DB_Normal_config.getDataById(1))
    local items = ActiveCache.MysteryMerchant:getHeroTable()
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
	    local r
	    if fn == "cellSize" then
	        r = CCSizeMake(cell_size.width , cell_size.height)
	    elseif fn == "cellAtIndex" then
            print("A1=", a1)
            local star_index = a1 * cell_icon_count + 1
            local end_index = star_index + cell_icon_count - 1
            if end_index > #items then
                end_index = #items
            end
            a2 = CCTableViewCell:create()
            for i = star_index, end_index do
                local item = items[i]
                local icon = createIcon(item, item.tid, heroClickedCallback, 1)
                a2:addChild(icon)
                local icon_size = icon:getContentSize()
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(ccp((icon_size.width + 30)* 0.5 + (i-1) % cell_icon_count * (icon_size.width + 30), 90))
            end
	        r = a2
	    elseif fn == "numberOfCells" then
	        r =  math.ceil(#items / cell_icon_count)
	    elseif fn == "cellTouched" then

	    elseif (fn == "scroll") then
            refreshHeroArrows()
	    end
	    return r
	end)
	_hero_table_view_height = hero_node_height - 30
	_hero_table_view = LuaTableView:createWithHandler(h, CCSizeMake(467, _hero_table_view_height))
    _hero_table_view:setBounceable(true)
    _hero_table_view:setPosition(ccp(1,15))
    -- _myTableView:setAnchorPoint(ccp(0.5,0))
    -- _myTableView:setScale(MainScene.elementScale)
    _hero_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _hero_node:addChild(_hero_table_view)


    local title_bg= CCScale9Sprite:create("images/common/astro_labelbg.png")
    title_bg:setContentSize(CCSizeMake(183,40))
    title_bg:setAnchorPoint(ccp(0.5,0.5))
    title_bg:setPosition(_hero_node:getContentSize().width * 0.5, _hero_node:getContentSize().height)
    _hero_node:addChild(title_bg)

    local title_label = CCRenderLabel:create(GetLocalizeStringBy("key_8202"), g_sFontPangWa, 23,1, ccc3(0x00,0x00,0x00), type_shadow)
    title_label:setColor(ccc3(0xff,0xf6,0x00))
    title_label:setPosition(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5)
    title_label:setAnchorPoint(ccp(0.5, 0.5))
    title_bg:addChild(title_label)
    
	-- 向上的箭头
	_arrow_up = CCSprite:create( "images/common/arrow_up_h.png")
    _hero_node:addChild(_arrow_up,1, 101)
	_arrow_up:setPosition(_hero_node:getContentSize().width * 0.5, _hero_node:getContentSize().height - 5)
	_arrow_up:setAnchorPoint(ccp(0.5,1))
	_arrow_up:setVisible(false)

	-- 向下的箭头
	_arrow_down = CCSprite:create( "images/common/arrow_down_h.png")
    _hero_node:addChild(_arrow_down,1, 102)
	_arrow_down:setPosition(_hero_node:getContentSize().width * 0.5, 5)
	_arrow_down:setAnchorPoint(ccp(0.5,0))
	_arrow_down:setVisible(true)

	arrowAction(_arrow_up)
	arrowAction(_arrow_down)
end

function createIcon(item, tag, callback, touch_priority)
    
   local itemSprite= ActiveUtil.getItemIcon(tonumber(item.type), tonumber(item.tid), touch_priority)
    -- 显示名字
    local itemInfo = ActiveUtil.getItemInfo(tonumber(item.type), tonumber(item.tid))
    local corlor =  HeroPublicLua.getCCColorByStarLevel(itemInfo.quality)
    local itemName=CCRenderLabel:create(itemInfo.name , g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    itemName:setAnchorPoint(ccp(0.5, 1))
    itemName:setPosition(itemSprite:getContentSize().width * 0.5, 0)
    itemName:setColor(corlor)
    itemSprite:addChild(itemName)
    return itemSprite
end

-- 商品列表
function loadItemList()
    _item_node = CCScale9Sprite:create("images/star/intimate/bottom9s.png",
                                       CCRectMake(0, 0, 75, 75),
                                       CCRectMake(0, 0, 0, 0))
	_centerLayer:addChild(_item_node, 100)
    local item_node_height = (_spirit_jade_count_tip:getPositionY()  - 30)/ MainScene.elementScale -
    (_spirit_jade_count_tip:getContentSize().height + _refresh_btn:getContentSize().height) -
    _refresh_btn:getPositionY() / MainScene.elementScale
    _item_node:setPreferredSize(CCSizeMake(467, item_node_height))
    _item_node:setScale(MainScene.elementScale)
    local item_node_y = _refresh_btn:getPositionY() + _refresh_btn:getContentSize().height *
    MainScene.elementScale + 13
    _item_node:setPosition(ccp(g_winSize.width - 5, item_node_y))
    _item_node:setAnchorPoint(ccp(1, 0))
    
    ActiveCache.MysteryMerchant:getItemTable()
	local cellSize = CCSizeMake(467, 142)  

    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
	    local r
	    if fn == "cellSize" then
	        r = CCSizeMake(cellSize.width , cellSize.height)
	    elseif fn == "cellAtIndex" then
	        a2 = MysteryMerchantCell.createCell(_item_table[a1+1])
	        r = a2
	    elseif fn == "numberOfCells" then
	        r =  #_item_table
	    elseif fn == "cellTouched" then

	    elseif (fn == "scroll") then
        end
	    return r
	end)
	_table_view_height = item_node_height - 30
	_item_table_view = LuaTableView:createWithHandler(h, CCSizeMake(467, _table_view_height))
    _item_table_view:setBounceable(true)
    _item_table_view:setPosition(ccp(1,15))
    -- _myTableView:setAnchorPoint(ccp(0.5,0))
    -- _myTableView:setScale(MainScene.elementScale)
    _item_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _item_node:addChild(_item_table_view)

	-- 向上的箭头
	_arrow_up = CCSprite:create( "images/common/arrow_up_h.png")
    _item_node:addChild(_arrow_up,1, 101)
	_arrow_up:setPosition(_item_node:getContentSize().width * 0.5, _item_node:getContentSize().height - 5)
	_arrow_up:setAnchorPoint(ccp(0.5,1))
	_arrow_up:setVisible(false)

	-- 向下的箭头
	_arrow_down = CCSprite:create( "images/common/arrow_down_h.png")
    _item_node:addChild(_arrow_down,1, 102)
	_arrow_down:setPosition(_item_node:getContentSize().width * 0.5, 5)
	_arrow_down:setAnchorPoint(ccp(0.5,0))
	_arrow_down:setVisible(true)

	arrowAction(_arrow_up)
	arrowAction(_arrow_down)
    
    updateRefreshTime()
    _update_timer = schedule(_centerLayer, updateRefreshTime, 1)
end

-- 刷新
function loadRefresh()
    -- 距离下次刷新物品时间
    local next_refresh_time = {}
    next_refresh_time[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1509"), g_sFontName, 23, 1, ccc3(0x00,0x00,0x0),type_shadow)
    next_refresh_time[2] = CCRenderLabel:create("00:00:00", g_sFontName, 23, 1, ccc3(0x00,0x00,0x0), type_shadow)
    _next_refresh_time_labelvalue = next_refresh_time[2]
    _next_refresh_time_labelvalue:setColor(ccc3(0x00, 0xff, 0x18))
    _next_refresh_time_tip = BaseUI.createHorizontalNode(next_refresh_time)
    _centerLayer:addChild(_next_refresh_time_tip)
    if ActiveCache.MysteryMerchant:isPerpetual() then
        _next_refresh_time_tip:setPosition(g_winSize.width - 10 * MainScene.elementScale, 90 * g_fScaleX)
    else
        _next_refresh_time_tip:setPosition(g_winSize.width - 10 * MainScene.elementScale, 135 * g_fScaleX)
    end
	_next_refresh_time_tip:setScale(MainScene.elementScale)
	_next_refresh_time_tip:setAnchorPoint(ccp(1, 0))
    
    if not ActiveCache.MysteryMerchant:isPerpetual() then
        -- 神秘商人剩余时间
        local disappear_time_tip = {}
        disappear_time_tip[1] = CCLabelTTF:create(GetLocalizeStringBy("key_2837"), g_sFontPangWa, 23)
        disappear_time_tip[2] = CCLabelTTF:create("00:00:00", g_sFontPangWa, 23)
        _disappear_time_labelvalue = disappear_time_tip[2]
        _disappear_time_labelvalue:setColor(ccc3(0x00, 0xff, 0x18))
        _disappear_time_tip = BaseUI.createHorizontalNode(disappear_time_tip)
        _centerLayer:addChild(_disappear_time_tip)
        _disappear_time_tip:setScale(MainScene.elementScale)
        _disappear_time_tip:setAnchorPoint(ccp(1, 0))
        _disappear_time_tip:setPosition(g_winSize.width - 50 * MainScene.elementScale, _centerSize.height - 70 * g_fScaleX)
   end
   refreshRefreshBtn()
end

function loadMenu()
    _menu = CCMenu:create()
	_menu:setPosition(0,0)
	_menu:setTouchPriority(-551)
	_centerLayer:addChild(_menu)
end

function recordOffset()
    _offset = _item_table_view:getContentOffset()
end

function setOffset()
    _item_table_view:setContentOffset(_offset)
end

function loadMysteryMerchantTip()
    local tip_bar = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
    _centerLayer:addChild(tip_bar)
    tip_bar:setScale(MainScene.elementScale)
    tip_bar:setPreferredSize(CCSizeMake(387, 140))
    tip_bar:setAnchorPoint(ccp(1, 1))
    tip_bar:setPosition(ccp(g_winSize.width - 5 * MainScene.elementScale, _spirit_jade_count_tip:getPositionY() - 10 * MainScene.elementScale))
    local tip_1 = CCSprite:create("images/recharge/mystery_merchant/tip_1.png")
    tip_bar:addChild(tip_1)
    tip_1:setAnchorPoint(ccp(0.5, 1))
    tip_1:setPosition(ccp(tip_bar:getContentSize().width * 0.5, tip_bar:getContentSize().height - 10))
    local tip_2 = {}
    tip_2[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8203"), g_sFontPangWa, 18)
    tip_2[1]:setColor(ccc3(0xff, 0xf6, 0x00))
    tip_2[2] = CCSprite:create("images/recharge/mystery_merchant/tip_2.png") 
    tip_2[3] = CCLabelTTF:create(GetLocalizeStringBy("key_8213"), g_sFontPangWa, 18)
    tip_2[3]:setColor(ccc3(0xff, 0xf6, 0x00))
    local tip_2_node = BaseUI.createHorizontalNode(tip_2)
    tip_bar:addChild(tip_2_node)
    tip_2_node:setAnchorPoint(ccp(0.5, 1))
    --tip_2:setDimensions(CCSizeMake(320, 100))
    --tip_2:setHorizontalAlignment(kCCTextAlignmentLeft)
    tip_2_node:setPosition(ccp(tip_bar:getContentSize().width * 0.5, tip_bar:getContentSize().height - 44))
    local tip_3 = CCLabelTTF:create(GetLocalizeStringBy("key_8212"), g_sFontPangWa, 18)
    tip_bar:addChild(tip_3)
    tip_3:setAnchorPoint(ccp(0.5, 1))
    tip_3:setColor(ccc3(0xff, 0xf6, 0x00))
    --tip_3:setDimensions(CCSizeMake(320, 100))
    --tip_3:setHorizontalAlignment(kCCTextAlignmentLeft)
    tip_3:setPosition(ccp(tip_bar:getContentSize().width * 0.5, tip_bar:getContentSize().height - 70))
    local tip_4 = CCLabelTTF:create(GetLocalizeStringBy("key_8204"), g_sFontPangWa, 18)
    tip_bar:addChild(tip_4)
    tip_4:setAnchorPoint(ccp(0.5, 1))
    tip_4:setPosition(ccp(tip_bar:getContentSize().width * 0.5, tip_bar:getContentSize().height - 90))
    tip_4:setColor(ccc3(0xff, 0xf6, 0x00))
    tip_4: setDimensions(CCSizeMake(320, 200))
    local tip_5 = CCLabelTTF:create(GetLocalizeStringBy("key_8205"), g_sFontPangWa, 18)
    tip_bar:addChild(tip_5)
    tip_5:setAnchorPoint(ccp(0.5, 1))
    tip_5:setPosition(ccp(tip_bar:getContentSize().width * 0.5, tip_bar:getContentSize().height - 110))
    tip_5:setColor(ccc3(0xff, 0xf6, 0x00))
end

function loadSummoned()
    local summoned_btn_data = {
        normal = "images/active/mineral/btn_bg_1_n.png",
        selected = "images/active/mineral/btn_bg_1_h.png",
        disabled = nil,
        size = CCSizeMake(425, 75),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_8201"),
        number = tostring(ActiveCache.MysteryMerchant:getLevelAndGold()[2])
    } 
	_summoned_btn = LuaCCSprite.createNumberMenuItem(summoned_btn_data) 
    _menu:addChild(_summoned_btn)
	_summoned_btn:setAnchorPoint(ccp(0.5, 0.5))
    _summoned_btn:registerScriptTapHandler(summonedCallback)
	_summoned_btn:setScale(MainScene.elementScale)
    if ActiveCache.MysteryMerchant:isExist() == true then
        _summoned_btn:setPosition(215 * MainScene.elementScale, 85 * MainScene.elementScale)
    else
        _summoned_btn:setPosition(g_winSize.width - 215 * MainScene.elementScale, 85 * MainScene.elementScale)
    end
    local tip_bg = CCScale9Sprite:create("images/common/bgng_lefttimes.png")
    _centerLayer:addChild(tip_bg)
    tip_bg:setAnchorPoint(ccp(0.5, 0))
    tip_bg:setPosition(ccp(g_winSize.width * 0.5, 15 * MainScene.elementScale))
    tip_bg:setPreferredSize(CCSizeMake(565, 38))
    tip_bg:setScale(MainScene.elementScale)
        
    local tip = {}
    tip[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8206"), g_sFontPangWa, 21)
    tip[1]:setColor(ccc3(0x00, 0xe4, 0xff))
    local vip_necessary = ActiveCache.MysteryMerchant:getBuyPerpetualVipLevel()
    tip[2] = CCLabelTTF:create(string.format("%d", vip_necessary), g_sFontPangWa, 21)
    tip[2]:setColor(ccc3(0xfe, 0xdb, 0x1c))
    tip[3] = CCLabelTTF:create(GetLocalizeStringBy("key_8207"), g_sFontPangWa, 21)
    tip[3]:setColor(ccc3(0x00, 0xe4, 0xff))
    local other_necessary = ActiveCache.MysteryMerchant:getLevelAndGold()
    tip[4] = CCLabelTTF:create(string.format("%d", other_necessary[1]), g_sFontPangWa, 21)
    tip[4]:setColor(ccc3(0xfe, 0xdb, 0x1c))
    tip[5] = CCLabelTTF:create(GetLocalizeStringBy("key_8208"), g_sFontPangWa, 21)
    tip[5]:setColor(ccc3(0x00, 0xe4, 0xff))
    local tip_node = BaseUI.createHorizontalNode(tip)
    tip_bg:addChild(tip_node)
    tip_node:setAnchorPoint(ccp(0.5, 0.5))
    tip_node:setPosition(ccp(tip_bg:getContentSize().width * 0.5, tip_bg:getContentSize().height * 0.5))
end

function summonedCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local vip_necessary = ActiveCache.MysteryMerchant:getBuyPerpetualVipLevel()
    if vip_necessary > UserModel.getVipLevel() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8209"))
        return
    end
    local other_necessary = ActiveCache.MysteryMerchant:getLevelAndGold()
    if other_necessary[1] > UserModel.getHeroLevel() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8210"))
        return
    end
    if other_necessary[2] > UserModel.getGoldNumber() then
        AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
        return
    end
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert(string.format(GetLocalizeStringBy("key_8211"), other_necessary[2]), buySummonedMerchant, true, nil, GetLocalizeStringBy("key_8129"))
end

function buySummonedMerchant(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    RequestCenter.mysmerchant_buyMerchantForever(handleSummoned, nil)
end

function handleSummoned(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    local other_necessary = ActiveCache.MysteryMerchant:getLevelAndGold()
    UserModel.addGoldNumber(-other_necessary[2])
    refreshLayer()
end

function refreshLayer()
    if tolua.isnull(_centerLayer) then
        return
    else
        local parent = _centerLayer:getParent()
        local anchorPoint = _centerLayer:getAnchorPoint()
        local position = ccp(_centerLayer:getPositionX(), _centerLayer:getPositionY())
        _centerLayer:removeFromParentAndCleanup(true)
        _centerLayer = createCenterLayer(_centerSize)
        parent:addChild(_centerLayer)
        _centerLayer:setAnchorPoint(anchorPoint)
        _centerLayer:setPosition(position)
    end
end

function refreshRefreshBtn()
    if _refresh_btn ~= nil then
        _refresh_btn:removeFromParentAndCleanup(true)
    end
    local refresh_btn_data = {
        normal = "images/common/btn/btn_purple2_n.png",
        selected = "images/common/btn/btn_purple2_h.png",
        disabled = nil,
        size = CCSizeMake(195, 73),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_2800"),
        number = ActiveCache.MysteryMerchant:getRefreshCostGoldCount()
    } 
	_refresh_btn = LuaCCSprite.createNumberMenuItem(refresh_btn_data) 
	_refresh_btn:setAnchorPoint(ccp(0.5, 0.5))
    if ActiveCache.MysteryMerchant:isPerpetual() then
        _refresh_btn:setPosition(g_winSize.width - 111 * MainScene.elementScale, 50 * g_fScaleX)
    else
        _refresh_btn:setPosition(g_winSize.width - 111 * MainScene.elementScale, 95 * g_fScaleX)
    end
	_refresh_btn:registerScriptTapHandler(callbackRefresh)
	_refresh_btn:setScale(MainScene.elementScale)
	_menu:addChild(_refresh_btn)
end

-- 箭头的动画
function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end

-- 刷新所有的UI
function refreshUI()
	refreshRefreshBtn()
    _spirit_jade_count_labelvalue:setString(tostring(UserModel.getJewelNum()))
	_item_table = ActiveCache.MysteryMerchant:getItemTable()
	_item_table_view:reloadData()
	-- 刷新物品：刷新令得数量 
	-- itemDelegate()
end

function bagChangedDelegateFunc()
	local current_refresh_else_count = ActiveCache.MysteryMerchant:getRefreshElseCount()
	_current_refresh_else_lable:setString(tostring(current_refresh_else_count))
end

function itemDelegate( )
    PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc)
end

-- 该层的生命周期回调
function onNodeEvent( eventType )
    if eventType == "enter" then
        
    elseif eventType == "exit"  then
        if _update_timer ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_update_timer)
        end
    end
end

function disappear()
    refreshLayer()
end

function updateRefreshTime()
    -- 下次刷新时间
    local next_refresh_time = ActiveCache.MysteryMerchant:getRefreshCdTime()
    _next_refresh_time_labelvalue:setString(TimeUtil.getTimeString(next_refresh_time))
    if next_refresh_time <= 0 then
        local getShopInfoSucceed = function()
            refreshUI()
        end
        ActiveCache.MysteryMerchant:requestData(getShopInfoSucceed)
	end
    if ActiveCache.MysteryMerchant:isPerpetual() == false then
        -- 消失剩余时间
        local disappear_time = ActiveCache.MysteryMerchant:getMerchantDisappearTime()
        _disappear_time_labelvalue:setString(TimeUtil.getTimeString(disappear_time))
        if disappear_time <= 0 then
            local getShopInfoSucceed = function()
                if ActiveCache.MysteryMerchant:isExist() then
                    refreshUI()
                else
                    disappear()
                end
            end
            ActiveCache.MysteryMerchant:requestData(getShopInfoSucceed)
        end
    end
    local offset = _item_table_view:getContentSize().height + _item_table_view:getContentOffset().y - _table_view_height
	if _arrow_up ~= nil then
		if offset > 1 or offset < -1 then
			_arrow_up:setVisible(true)
		else
			_arrow_up:setVisible(false)
		end
	end

	if _arrow_down ~= nil  then

		if _item_table_view:getContentOffset().y < 0 then
			_arrow_down:setVisible(true)
		else
			_arrow_down:setVisible(false)
		end
	end
end


function refreshHeroArrows()
    if _hero_table_view == nil then
        return
    end
    local offset = _hero_table_view:getContentSize().height + _hero_table_view:getContentOffset().y - _hero_table_view_height
	if _arrow_up ~= nil then
		if offset > 1 or offset < -1 then
			_arrow_up:setVisible(true)
		else
			_arrow_up:setVisible(false)
		end
	end

	if _arrow_down ~= nil  then

		if _hero_table_view:getContentOffset().y < 0 then
			_arrow_down:setVisible(true)
		else
			_arrow_down:setVisible(false)
		end
	end
end
-- 刷新按钮的网络回调，
function handleRefresh(cbFlag, dictData, bRet)
	if dictData.err ~= "ok" then
		return 
	end

	if _refresh_type == _refresh_type_gold then
		UserModel.addGoldNumber(-tonumber(ActiveCache.MysteryMerchant:getRefreshCostGoldCount()))
	elseif _refresh_type == _refresh_type_else then
        local cost_item_data = ActiveCache.MysteryMerchant:getRefreshElseItemData()
        ItemUtil.addItemByID(cost_item_data._info.id, cost_item_data._count)
    end

	ActiveCache.MysteryMerchant:setInfo(dictData.ret)
	refreshUI()
end

-- 刷新按钮回调
function callbackRefresh(tag, item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _refresh_type = _refresh_type_gold
	--[[
    local refresh_else_count = ActiveCache.MysteryMerchant:getRefreshElseCount()
	if refresh_else_count > 0 then
		_refresh_type = _refresh_type_else
	end
    --]]
    
	if _refresh_type == _refresh_type_gold and ActiveCache.MysteryMerchant:isRefreshMax() == false then
		AnimationTip.showTip(GetLocalizeStringBy("key_2858"))
		return
	end

    local refresh_cost_gold_count = ActiveCache.MysteryMerchant:getRefreshCostGoldCount()
	if --[[ refresh_else_count <= 0 and --]]UserModel.getGoldNumber()< tonumber(refresh_cost_gold_count) then
		require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
		return
	end
    
	local args = CCArray:create()
	args:addObject(CCInteger:create(_refresh_type))
	Network.rpc(handleRefresh, "mysmerchant.playerRfrGoodsList" , "mysmerchant.playerRfrGoodsList", args , true)
end

