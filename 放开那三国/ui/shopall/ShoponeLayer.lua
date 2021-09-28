-- FileName: shoponeLayer.lua
-- Author: FQQ
-- Date: 15-08-28
-- Purpose: 商店整合

module ("ShoponeLayer",package.seeall)
require "script/model/user/UserModel"
require "script/ui/rechargeActive/ActiveCache"
require "script/model/DataCache"
require "script/ui/tip/AnimationTip"
require "script/ui/shopall/ShopUtils"
require "script/ui/guild/GuildDataCache"
require "script/ui/kfbw/KuafuService"
require "script/ui/countryWar/CountryWarMainData"
require "script/utils/TopGoldSilver"
local _bgLayer
local _buttomLayer                  --顶端scrollview的layer
local _topBgSp            = nil      --顶端scrollview的背景
local tipSprite           = nil
local _scrollView                   --顶端scrollview
local _mainMenu
local _oldTag                       --记录顶端button选定项
local _tagArray                     --保存tag的数组
local _curTag                       --当前选定的tag
local _defaultIndex                 --进入页面时默认显示的index
local _touchPriority
local isGetKuafuData      = false  -- 是否拉了跨服比武的接口
local  oldTag            = 0
local _ksTagMainMenu      = 10001
ksTagPropShop        = 2000    --道具商店
ksTagMysteryPerson   = 2001    --神秘商人
ksTagArenaShop       = 2002    --竞技商店
ksTagMysteryShop     = 2003    --神秘商店
ksTagLegionShop      = 2004    --军团商店
ksTagBattabelShop    = 2005    --战功商店
ksTagLiangcaoShop    = 2006    --粮草商店
ksTagMatchShop       = 2007    --比武商店
ksTagLianyuShop      = 2008    --炼狱商店
ksTagZhoumoPerson    = 2009    --周末商人
ksTagGodShop         = 2010    --神兵商店
ksTagMoonShop        = 2011    --符印商店
ksTagXunLongShop     = 2012    --寻龙商店
ksTagKuaFuShop       = 2013    --跨服商店
ksTagMingWang        = 2014    --名望商店
ksTagKuaWu           = 2015    --跨服比武商店
ksTagCountryWar      = 2016    --国战商店
ksTagTallyShop       = 2017    --兵符商店
ksTagDevilTowerShop  = 2018    --梦魇商店
ksTagSevenLotteryShop = 2019   --七星台商店
local  oldTag             = 0
local _ksTagActivityNewIn = 1001  -- 新活动开启时的，提示图片
local shopTable = nil
local _shopIndex          = 1
local _redTipNum = 0
local tipSprite = nil
local numLabel = nil
_topBgSp                 = nil       --顶端scrollview的背景
-- _tagPropShop             = 2000      --道具商店
-- _tagMysteryShop          = 2002      --神秘商店

local _centerSize       = nil          -- 中间UI的尺寸
local _centerLayer      = nil          -- 中间的Layer
local _centerLayerElementScale = nil
local _curMenuItem      = nil        -- 当前选中的按钮
local _topBg            = nil      

function show(p_shopTag)
    if DataCache.getSwitchNodeState( ksSwitchKFBW,false ) then
        if isGetKuafuData == false then
            KuafuService.getWorldCompeteInfo(function( ... )
                createAllShop(p_shopTag)
            end)
            isGetKuafuData = true
        else
            createAllShop(p_shopTag)
        end
    else
        createAllShop(p_shopTag)
    end
    
end

-- 创建商店   add by yangrui 2015-11-18
function createAllShop( p_shopTag )
    local callback = function ( ... )
        _shopIndex = ShopUtils.getShopIndexByTag(p_shopTag or ksTagPropShop)
        local layer = createUI(_shopIndex)
        MainScene.changeLayer(layer,"ShoponeLayer")
    end
    local handleGetGuildInfo = function( cbFlag, dictData, bRet )
        if dictData.err ~= "ok" then
            return
        end
        GuildDataCache.setGuildInfo(dictData.ret)
        callback()
    end
    if DataCache.getSwitchNodeState(ksSwitchGuild, false) and GuildDataCache.getMineSigleGuildId() ~= 0 then
        RequestCenter.guild_getGuildInfo(handleGetGuildInfo)
    else
        callback()
    end
end

local function init( ... )
    _bgLayer        =   nil
    _buttomLayer    =   nil             --顶端scrollview的layer
    _topBgSp        =   nil             --顶端scrollview的背景
    _scrollView     =   nil             --顶端scrollview
    _touchPriority  =   nil
    _defaultIndex   =   nil
    _curTag         =   ksTagPropShop    --默认进入时展示道具商店
    oldTag          = 0
    shopTable      = nil
    _redTipNum = 0
    tipSprite = nil
    numLabel = nil
    _topBg    = nil 
end

--开始创建UI
function createUI( index )
    init()
    count = 0
    _shopIndex = index
    MainScene.setMainSceneViewsVisible(true, false, false)
    _bgLayer = CCLayer:create()
    _bgLayer:setPosition(ccp(0,0))
    local bgLayerSize = _bgLayer:getContentSize()

    -- 默认背景
    _defaultBg = CCSprite:create("images/recharge/fund/fund_bg.png")
    _bgLayer:addChild(_defaultBg)
    _defaultBg:setScale(MainScene.bgScale)

    -- 上标题栏 显示战斗力，银币，金币
    _topBg = TopGoldSilver.create()
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,bgLayerSize.height)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg,1100)

    --背景
    local winHeight = CCDirector:sharedDirector():getWinSize().height
    _topBgSp = CCScale9Sprite:create("images/common/bg/bg_2.png")
    _topBgSp:setContentSize(CCSizeMake(640,130))
    _topBgSp:setAnchorPoint(ccp(0.5,1))
    _topBgSp:setPosition(ccp(CCDirector:sharedDirector():getWinSize().width/2, winHeight - _topBg:getContentSize().height*g_fScaleX))
    _bgLayer:addChild(_topBgSp, 99)
    _topBgSp:setScale(g_fScaleX)

   
    --左按钮
    local leftBtn = CCSprite:create("images/formation/btn_left.png")
    leftBtn:setAnchorPoint(ccp(0, 0.5))
    leftBtn:setPosition(ccp(0, _topBgSp:getContentSize().height/2))
    _topBgSp:addChild(leftBtn, 10001, 10001)
    -- 右按钮
    local rightBtn = CCSprite:create("images/formation/btn_right.png")
    rightBtn:setAnchorPoint(ccp(1, 0.5))
    rightBtn:setPosition(ccp(_topBgSp:getContentSize().width, _topBgSp:getContentSize().height/2))
    _topBgSp:addChild(rightBtn, 10002, 10002)


    _buttomLayer = CCLayer:create()
    _buttomLayer:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height-MenuLayer.getLayerContentSize().height*g_fScaleX-_topBg:getContentSize().height*g_fScaleX-getTopBgHeight()))
    _buttomLayer:setPosition(ccp(0,0))
    _buttomLayer:registerScriptTouchHandler(onTouchesHandler)
    _buttomLayer:setTouchEnabled(true)
    _bgLayer:addChild(_buttomLayer)
    --顶端滑动scrollview
    createScrollView()
    return _bgLayer
end

--得到中间UI的Size added by bzx
function getCenterSize( ... )
    if _centerSize == nil then
        local height = g_winSize.height - 48 * g_fScaleX - MenuLayer.getHeight() - 130 * g_fScaleX
        _centerSize = CCSizeMake(g_winSize.width, height)
    end
    return _centerSize
end

--触点
function onTouchesHandler( eventType, x, y )
    if(eventType == "began")then
        _touchBeganPoint = ccp(x,y)
        return true
    elseif(eventType == "moved")then
    else
    end
end
--[[
    @desc   活动图标
    @para   none
    @return  void
--]]
function createScrollView( ... )
    if( _scrollView ~= nil)then
        _scrollView:removeFromParentAndCleanup(true)
        _scrollView = nil
    end
    local width = 513
    _scrollView = CCScrollView:create()
    _scrollView:setContentSize(CCSizeMake(width,_topBgSp:getContentSize().height))
    _scrollView:setViewSize(CCSizeMake(513,_topBgSp:getContentSize().height))
    _scrollView:setPosition(66,0)
    _scrollView:setTouchPriority(-400)
    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setContentOffset(ccp(0,0))
    _topBgSp:addChild(_scrollView,1,2000)

    _mainMenu = BTMenu:create()
    _mainMenu:setPosition(0,0)
    _mainMenu:setTouchPriority(-390)
    _mainMenu:setScrollView(_scrollView)
    _scrollView:addChild(_mainMenu,1 , _ksTagMainMenu)
    local count = 0

    shopTable = ShopUtils.shopAllInfo()


    for i=1,#shopTable do
        --判断商店是否开启
        if(shopTable[i].note_data.isOpen)then
            local img_n = shopTable[i].img.images_n
            local img_h = shopTable[i].img.images_h
            local menuItem = CCMenuItemImage:create(img_n,img_h, img_h)
            _mainMenu:addChild(menuItem,1,shopTable[i].tag)
            menuItem:ignoreAnchorPointForPosition(false)
            menuItem:setAnchorPoint(ccp(0.5,0.5))

            menuItem:setPosition(ccp(60+120*count , _scrollView:getContentSize().height/2))
            menuItem:registerScriptTapHandler(touchButton)
            -- menuItem:setTag(i)
            count = count + 1
            if _shopIndex == i then
                touchButton(_shopIndex+1999, menuItem)
            end

            --判断商店是否有小红点提示
            if(shopTable[i].note_data.hasTip) and ActiveCache.getAccRfcTime()~=0 then
                tipSprite = TipSpriteNum()
                tipSprite:setAnchorPoint(ccp(1,1))
                tipSprite:setPosition(ccp(menuItem:getContentSize().width*0.98,menuItem:getContentSize().height*0.98))
                menuItem:addChild(tipSprite,1,4)
            end
        end

    end

    if(count >= 4)then
        _scrollView:setContentSize(CCSizeMake(120*count, _topBgSp:getContentSize().height-50))
    end
end


--按钮回调
function touchButton( tag, menuItem)

    if not tolua.isnull(_curMenuItem) then
        _curMenuItem:setEnabled(true)
    end
    _curMenuItem = menuItem
    _curMenuItem:setEnabled(false)
    -- local kTableBgSize = CCSizeMake(472,kMidRectSize.height-212)
    -- if(shopTable[tag].hasTip)then
    --     --点击后红点提示消失
    --     if(tipSprite)then
    --         tipSprite:removeFromParentAndCleanup(true)
    --         tipSprite = nil
    --     end
    -- end
    if not tolua.isnull(_centerLayer) then
        _centerLayer:removeFromParentAndCleanup(true)
    end
    print("tag=-======")
    _centerLayer =  shopTable[tag-1999].note_data.callback(unpack(shopTable[tag-1999].note_data.args or {}))
    _bgLayer:addChild(_centerLayer)
    _centerLayer:setAnchorPoint(ccp(0, 0))
    _centerLayer:setPosition(ccp(0, MenuLayer.getHeight()))
end

function changeButtomLayer( layer )
    _buttomLayer:removeAllChildrenWithCleanup(true)
    _buttomLayer:setPosition(0,0)
    _buttomLayer:addChild(layer)
end

-- 得到中间Layer的设计尺寸
function getDesignCenterLayerSize( ... )
    return CCSizeMake(640, 669)
end

function getCenterLayerElementScale( ... )
    if _centerLayerElementScale == nil then
        local centerLayerSize = getCenterSize()
        local designCenterLayerSize = getDesignCenterLayerSize()
        local scaleX = centerLayerSize.width / designCenterLayerSize.width
        local scaleY = centerLayerSize.height / designCenterLayerSize.height
        _centerLayerElementScale = math.min(scaleX, scaleY)
    end
    return _centerLayerElementScale
end

function getTopBgHeight()
    -- print("_topBgSp:getContentSize().height *g_fScaleX",_topBgSp:getContentSize().height *g_fScaleX)
    -- return _topBgSp:getContentSize().height *g_fScaleX
    return 130*g_fScaleX
end
function getBgWidth()
    return 640 * g_fScaleX
end

--小红圈
function TipSpriteNum(  )
    local tipSprite= CCSprite:create("images/common/tip_2.png")
    numLabel = CCLabelTTF:create(ActiveCache.getAccRfcTime(),g_sFontName, 21)
    numLabel:setPosition(ccp(tipSprite:getContentSize().width/2,tipSprite:getContentSize().height/2))
    numLabel:setAnchorPoint(ccp(0.5,0.5))
    tipSprite:addChild(numLabel)
    return tipSprite
end

--刷新提示数量
function freshTipNum()
    -- body
    local menuItem = _mainMenu:getChildByTag(ksTagMysteryShop)
    local tipSprite = menuItem:getChildByTag(4) 
    if not tolua.isnull(tipSprite) then
        tipSprite:removeFromParentAndCleanup(true)
    end
    if(ActiveCache.getAccRfcTime()~=0)then
        local tipSprite = TipSpriteNum()
        tipSprite:setAnchorPoint(ccp(1,1))
        tipSprite:setPosition(ccp(menuItem:getContentSize().width*0.98,menuItem:getContentSize().height*0.98))
        menuItem:addChild(tipSprite,1,4)
    end
    
end
 
 function isOpenCW( ... )
    local ret = true
    --是否满足开服天数
    local openServerTime = tonumber(ServerList.getSelectServerInfo().openDateTime)
    local openDay = math.floor((TimeUtil.getSvrTimeByOffset() - openServerTime)/86400)
    local needOpenDay = tonumber(CountryWarMainData.getNeedDay())
    if openDay < needOpenDay then
        ret = false
    end
    --玩家等级是否满足
    if UserModel.getHeroLevel() < tonumber(CountryWarMainData.getNeedLevel()) then
        ret = false
    end
    return ret
 end
 
--[[
    @des    : 得到金币栏大小
    @param  : 
    @return :
--]]
function getTopGoldContentSize( ... )
    return CCSizeMake(640,48)
end












