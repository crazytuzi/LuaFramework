-- Filename: HeroExchange.lua.
-- Author: zhz.
-- Date: 2013-09-17
-- Purpose: 该文件用于武魂兑换

module("HeroExchange",package.seeall)

require "script/model/DataCache"
require "script/ui/shop/ExchangeCell"
require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"
require "script/audio/AudioUtil"
require "db/DB_Tavern_exchange"
require "db/DB_Item_hero_fragment"
require "db/DB_Heroes"
require "script/network/PreRequest"

local _bgLayer 				-- 灰色的layer
local _myTableView          -- 
local _myTableViewSpite
local _allHeroData          -- 所有兑换武将的数据
local _integralNumLabel     -- 积分的数量
local _alertContent 


local function init( )
	_bgLayer = nil
    _myTableView = nil
    _myTableViewSpite = nil
    _allHeroData = {}
    _alertContent = {}
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

-- 关闭按钮的回调函数
 function closeCb()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
    PreRequest.setBagDataChangedDelete(nil)
end

-- 创建TableView 
local function createTableView( ... )
   
    local cellSize = CCSizeMake(583, 200)           --计算cell大小
    local myScale 

    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = ExchangeCell.createCell(_allHeroData[a1+1])
           -- a2:setScale(myScale)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_allHeroData
        elseif fn == "cellTouched" then
            print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then
            
        end
        return r
    end)
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(583,570))
    _myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(0,8))
    _myTableView:setTouchPriority(-552)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewSpite:addChild(_myTableView)
end

-- added by zhz
-- 获得所有武将的数据
function getExchangeHeroData()

    for i=1, table.count(DB_Tavern_exchange.Tavern_exchange)  do 
        local tempData = DB_Tavern_exchange.getDataById(i)
        local exchange_hero_id = tempData.exchange_hero_id
        tempData.index = i
        tempData.name = DB_Item_hero_fragment.getDataById(exchange_hero_id).name
        tempData.quality =  DB_Item_hero_fragment.getDataById(exchange_hero_id).quality
        tempData.aimItem = DB_Item_hero_fragment.getDataById(exchange_hero_id).aimItem
        tempData.lv = DB_Heroes.getDataById( tempData.aimItem).lv
        tempData.hasSoulNum = DataCache.getHeroFragNumByItemTmpid(exchange_hero_id)
        tempData.needSoulNum=DB_Item_hero_fragment.getDataById(exchange_hero_id).need_part_num
        table.insert(_allHeroData, tempData)
    end
end

-- -- 
-- function getCurHeroData( index )
--     local id = _allHeroData[tonumber(index)].id
--     local curHeroData =  DB_Tavern_exchange.getDataById(tag)
-- end
local function bagChangedDelegateFunc( )
    local offset = _myTableView:getContentOffset()
    getExchangeHeroData()
    _myTableView:reloadData()
    _myTableView:setContentOffset(offset)
end


function refreshTableView( )

    PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc)
end



function refreshAtIndex( )
    
end

function refreshPoint(  )
    _alertContent[5]:setString("" .. DataCache.getShopPoint() )
end

function createHeroExchageLayer( )
    init()
    getExchangeHeroData()
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))

	  -- 设置灰色layer的优先级
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-550,true)
    -- local scene = CCDirector:sharedDirector():getRunningScene()
    -- scene:addChild(_bgLayer,999,2013)

    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(625,724)
	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local heroExchangeBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    heroExchangeBg:setContentSize(mySize)
    heroExchangeBg:setScale(myScale)
    heroExchangeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    heroExchangeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(heroExchangeBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(heroExchangeBg:getContentSize().width*0.5, heroExchangeBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	heroExchangeBg:addChild(titleBg)

	 --武将兑换的的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1310"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	 -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    heroExchangeBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.02,mySize.height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    -- 黑色的背景
    _myTableViewSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _myTableViewSpite:setContentSize(CCSizeMake(585,586))
    _myTableViewSpite:setPosition(ccp(mySize.width*0.5,86))
    _myTableViewSpite:setAnchorPoint(ccp(0.5,0))
    heroExchangeBg:addChild(_myTableViewSpite)


    _alertContent = {}

    _alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1854"), g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    _alertContent[1]:setColor(ccc3(0xfe,0x9c,0x1c))
    _alertContent[2] = CCRenderLabel:create(GetLocalizeStringBy("key_1790"), g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    _alertContent[2]:setColor(ccc3(0xec,0x4a,0xff))
    _alertContent[3] = CCRenderLabel:create(":", g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    _alertContent[3]:setColor(ccc3(0xfe,0x9c,0x1c))
    _alertContent[4] = CCSprite:create("images/common/soul_jade.png")
    _alertContent[5] =CCRenderLabel:create(" " .. DataCache.getShopPoint() , g_sFontPangWa , 30 , 1 , ccc3(0x00, 0x00, 0x00), type_stroke)
    _alertContent[5]:setColor(ccc3(0x36,0xff,0x00))

    local vipDesc = BaseUI.createHorizontalNode(_alertContent)
    vipDesc:setPosition(ccp(heroExchangeBg:getContentSize().width/2,72))
    vipDesc:setAnchorPoint(ccp(0.5,1))
    heroExchangeBg:addChild(vipDesc)
    -- 当前拥有的积分
    -- local integralLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2087"), g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    -- integralLabel:setColor(ccc3(0xf9,0x9c,0x1c))
    -- integralLabel:setPosition(ccp(139,72))
    -- heroExchangeBg:addChild(integralLabel)

    -- _integralNumLabel  = CCRenderLabel:create(" " .. DataCache.getShopPoint() , g_sFontPangWa , 30 , 1 , ccc3(0x00, 0x00, 0x00), type_stroke)
    -- _integralNumLabel:setColor(ccc3(0x36,0xff,0x00))
    -- -- _integralNumLabel:setAnchorPoint(ccp)
    -- _integralNumLabel:setPosition(ccp(vipDesc:getContentSize().width/2 +vipDesc:getPositionX(),70))
    -- _integralNumLabel:setAnchorPoint(ccp(0,1))
    -- heroExchangeBg:addChild(_integralNumLabel)
    -- print_t(DataCache.getShopCache())

    createTableView()

	return _bgLayer

end
