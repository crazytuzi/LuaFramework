-- Filename：    GuildShopLayer.lua
-- Author：      zhz
-- Date：        2014-01-13
-- Purpose：     军团商店

module("GuildShopLayer",  package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/utils/TimeUtil"
require "script/ui/guild/GuildUtil"
require "script/ui/shopall/GuildShopCell"
require "script/ui/main/BulletinLayer"


local _bottomSprite
local _curDonateSp              -- 当前贡献的sp
local _curDonateLabel           -- 当前贡献的label
local _myTableViewSp            -- 列表的
local _myTableView
local _goodsInfo
local _girlSp
local _centerLayer
local _layer = nil
local _ksNormalTag = 1001       -- 道具的tag
local _ksValueTag = 1002        -- 珍品的tag
local _ksBackTag = 1003         -- 返回按钮的tag

local _index=1                  -- 当前在那个页面
local _curItem= nil
local _updateTimer= nil         -- 定时器
local _laySize = nil
local blackNode = nil
-- 初始化
local function init( )
    _bottomSprite= nil
    _curDonateSp= nil
    _curDonateLabel= nil
    _girlSp= nil
    _myTableViewSp=nil
    _myTableView= nil
    _goodsInfo= {}
    _layer = nil
    _updateTimer= nil
    _index= 1
    _curItem= nil
    _centerLayer = nil
    -- _layer = nil
    _laySize = nil
    blackNode = nil
end





-- 创建中间的UI,物品列表
function createMiddleUI( )
    createCurDonateUI()
    refreshGoodTableView()

end



function createCurDonateUI( )
    --  商店标题 LV等级
    local height = _laySize.height
    local shopTitleSp = CCSprite:create("images/guild/shop/shopname.png")
    shopTitleSp:setPosition(_centerLayer:getContentSize().width*0.38,height )
    shopTitleSp:setScale(g_fElementScaleRatio)
    shopTitleSp:setAnchorPoint(ccp(0,1))
    print("gggggggggg",shopTitleSp)
    print("hhhhhhhhhhh",_centerLayer)
    _centerLayer:addChild(shopTitleSp)

    local shopLevelLabel= CCRenderLabel:create( "Lv." .. tostring(GuildDataCache.getShopLevel() ) , g_sFontPangWa , 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    shopLevelLabel:setColor(ccc3(0xff,0xe4,0x00))

    shopLevelLabel:setPosition(shopTitleSp:getContentSize().width+5, shopLevelLabel:getContentSize().height)
    shopLevelLabel:setAnchorPoint(ccp(0,0))
    shopTitleSp:addChild(shopLevelLabel)

    local tall = shopLevelLabel:getPositionY() - shopLevelLabel:getContentSize().height*g_fElementScaleRatio
    --  当前的贡献值文字
    local _curDonateSp = CCRenderLabel:create(GetLocalizeStringBy("fqq_006"),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    _curDonateSp:setColor(ccc3(0xff,0xf6,0x00))
    _curDonateSp:setAnchorPoint(ccp(0,1))
    _curDonateSp:setScale(g_fScaleX)
    _curDonateSp:setPosition(g_winSize.width*0.6,shopTitleSp:getPositionY() - shopTitleSp:getContentSize().height*g_fElementScaleRatio)
    _centerLayer:addChild(_curDonateSp)

    -- 当前贡献值
    _curDonateLabel = CCRenderLabel:create(tostring(GuildDataCache.getSigleDoante() ) , g_sFontPangWa , 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _curDonateLabel:setColor(ccc3(0x00,0xff,0x18))
    _curDonateLabel:setPosition(_curDonateSp:getContentSize().width, _curDonateSp:getContentSize().height/2)
    _curDonateLabel:setAnchorPoint(ccp(0,0.5))
    _curDonateSp:addChild(_curDonateLabel)


    local nextNeed1 = CCRenderLabel:create(GetLocalizeStringBy("key_3041"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local specialButton1 = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1544"), 30)
    local tableheight = _curDonateSp:getPositionY() - _curDonateSp:getContentSize().height*g_fScaleX - nextNeed1:getContentSize().height*g_fScaleX*1.5 - specialButton1:getContentSize().height*g_fScaleX 

    --tableview的背景黑框
    blackNode = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/9s_1.png")
    blackNode:setContentSize(CCSizeMake(460*g_fScaleX, tableheight))
    blackNode:setAnchorPoint(ccp(1,1))
    blackNode:setPosition(ccp(g_winSize.width - 10*g_fScaleX,_curDonateSp:getPositionY() - _curDonateSp:getContentSize().height*g_fScaleX - specialButton1:getContentSize().height*g_fScaleX))
    _centerLayer:addChild(blackNode, 10)
    print("111111111111")
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0, blackNode:getContentSize().height))
    menuBar:setAnchorPoint(ccp(0,1))
    menuBar:setTouchPriority(_priority-20)
    blackNode:addChild(menuBar, 10)

    -- 珍品的按钮
    local specialButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1544"), 30)
    specialButton:setAnchorPoint(ccp(0, 0))
    specialButton:setScale(g_fScaleX)
    specialButton:setPosition(ccp(blackNode:getContentSize().width*0.1, 0))
    specialButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(specialButton,1, _ksValueTag)
    specialButton:selected()
    _curItem= specialButton

    -- 道具的按钮
    local normalButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1870"), 30)
    normalButton:setAnchorPoint(ccp(0, 0))
    normalButton:setPosition(ccp(blackNode:getContentSize().width*0.1+specialButton:getContentSize().width*g_fScaleX, 0))
    normalButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(normalButton,1, _ksNormalTag)
    normalButton:setScale(g_fScaleX)
    -- normalButton:selected()
    print("22222222222")
    -- 总的建设度
    local width = 0
    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
        width = 355/640*_laySize.width
    else
        width = 388/640*_laySize.width
    end

    --总建设度
    local height = _laySize.height- 48*g_fScaleX - blackNode:getContentSize().height - 30*g_fScaleX
    local totalDonate = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    totalDonate:setColor(ccc3(0xfe, 0xdb, 0x1c))
    local donateNumber = CCRenderLabel:create(GuildDataCache.getGuildDonate(), g_sFontPangWa, 17, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    donateNumber:setColor(ccc3(0xff,0xff,0xff))

    local label1 = BaseUI.createHorizontalNode({totalDonate, donateNumber})
    label1:setAnchorPoint(ccp(0, 1))
    label1:setPosition(ccp(blackNode:getContentSize().width*0.1,0))
    label1:setScale(g_fScaleX)
    blackNode:addChild(label1)
    -- label1:setScale(MainScene.elementScale)

    --升级所需
    local nextNeed = CCRenderLabel:create(GetLocalizeStringBy("key_3041"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nextNeed:setColor(ccc3(0xfe, 0xdb, 0x1c))
    local nextLv = GuildDataCache.getShopLevel() +1
    local maxLevel= GuildUtil.getMaxShopLevel()
    local needNumber =nil
    if(GuildDataCache.getShopLevel()< tonumber(maxLevel)) then
        needNumber= CCRenderLabel:create(GuildUtil.getShopNeedExpByLv(nextLv) , g_sFontPangWa, 17, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    else
        needNumber= CCRenderLabel:create("--" , g_sFontPangWa, 17, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    end
    needNumber:setColor(ccc3(0xff,0xff,0xff))
    -- height = height- label1:getContentSize().height-10*MainScene.elementScale
    local label2 = BaseUI.createHorizontalNode({nextNeed, needNumber})
    label2:setAnchorPoint(ccp(0, 1))
    label2:setPosition(ccp(blackNode:getContentSize().width*0.6,0))
    label2:setScale(g_fScaleX)
    blackNode:addChild(label2)



end

function refreshCurDonateLabel( )
    _curDonateLabel:setString(tostring(GuildDataCache.getSigleDoante()))
end

--
function refreshGoodTableView( )
    if(_index==1) then
        _goodsInfo= GuildUtil.getSpecialGoods()
    else
        _goodsInfo= GuildUtil.getNormalGoods()
    end
    if not tolua.isnull(_myTableView) then
        _myTableView:reloadData()
        return
    end
    local cellSize = CCSizeMake(454*g_fScaleX, 182*g_fScaleX)           --计算cell大小
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            a2 = GuildShopCell.createCell(_goodsInfo[a1+1],_index ,refreshMiddleUI,_centerSize.width)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_goodsInfo
        elseif fn == "cellTouched" then
            print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then

        end
        return r
    end)


    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(450*g_fScaleX, blackNode:getContentSize().height - 10))
    _myTableView:setBounceable(true)
    _myTableView:setTouchPriority(_priority-10)
    print("_priority-10===",_priority-10)
    _myTableView:setAnchorPoint(ccp(0.5, 0.5))
    _myTableView:setPosition(ccpsprite(0.5, 0.5, blackNode))
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableView:ignoreAnchorPointForPosition(false)
    blackNode:addChild(_myTableView)

    -- 当为珍品时，设置定时器，刷新
    if(_index==1 and tolua.isnull(_leftTimeLabel)) then
        _leftTimeLabel= CCLabelTTF:create(TimeUtil.getTimeString(GuildDataCache.getShopRefreshCd()) , g_sFontName,23)
        _leftTimeLabel:setPosition(ccp(10,10*g_fScaleX))
        _leftTimeLabel:setColor(ccc3(0x00,0xff,0x18))
        _leftTimeLabel:setScale(g_fScaleX)
        _centerLayer:addChild(_leftTimeLabel)
        sheildLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2272"),g_sFontName,23) --刷新倒计时
        sheildLabel:setColor(ccc3(0x00,0xff,0x18))
        sheildLabel:setPosition(ccp(16*g_fScaleX,35*g_fScaleX))
        sheildLabel:setScale(g_fScaleX)
        _centerLayer:addChild(sheildLabel)
        schedule(_centerLayer, updateShieldTime, 1)
    end

end

-- 刷新TableView
function refreshTableView( )
    if(_index==1) then
        _goodsInfo= GuildUtil.getSpecialGoods()
    else
        _goodsInfo= GuildUtil.getNormalGoods()
    end
    local contentOffset = _myTableView:getContentOffset()
    _myTableView:reloadData()
    _myTableView:setContentOffset(contentOffset)
end

function refreshTableView_02( ... )
    if(_index==1) then
        _goodsInfo= GuildUtil.getSpecialGoods()
    else
        _goodsInfo= GuildUtil.getNormalGoods()
    end
    _myTableView:reloadData()
end

-- 刷新中部的UI
function refreshMiddleUI( )
    refreshTableView()
    refreshCurDonateLabel()
end

function refreshMiddleUI_2( ... )
    refreshTableView_02()
     refreshCurDonateLabel()
end

function updateShieldTime( )
    local shieldTime = "" .. TimeUtil.getTimeString(GuildDataCache.getShopRefreshCd())
    _leftTimeLabel:setString(shieldTime)
    if _index ~= 1 then
        sheildLabel:setVisible(false)
        _leftTimeLabel:setVisible(false)
    else
        sheildLabel:setVisible(true)
        _leftTimeLabel:setVisible(true)
    end

    if(GuildDataCache.getShopRefreshCd()<= 0) then
        Network.rpc(refreshListCallBack, "guildshop.refreshList", "guildshop.refreshList", nil, true)
    end
end




---------------------------------------------- 网络及回调函数 -----------------------------------------------

-- 按钮事件的回调函数
function menuCallBack( tag,item)
    --
    _curItem:unselected()
    item:selected()
    _curItem= item
    if(tag== _ksNormalTag ) then
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        print(GetLocalizeStringBy("key_1352"))
        _index=2
        refreshTableView_02()

    elseif(tag== _ksValueTag) then
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        print(GetLocalizeStringBy("key_1455"))
        _index=1
        refreshTableView_02()

    end
end

-- 获得军团商店信息的网络回调
function getShopInfoCb( cbFlag, dictData, bRet )
    if (dictData.err ~= "ok") then
        return
    end
    GuildDataCache.setShopInfo(dictData.ret)
    createMiddleUI()
end

-- 刷新的回调函数
function refreshListCallBack( cbFlag, dictData, bRet )
    if (dictData.err ~= "ok") then
        return
    end
    GuildDataCache.setSpecialGoodsInfo(dictData.ret.special_goods,dictData.ret.refresh_cd)

    refreshTableView_02()
end


-- 在原来进入的接口
function show(p_touchPriority, p_zOrder)
    local player = create(p_touchPriority, p_zOrder)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    -- local showlayer = MainScene:getOnRunningLayer()
    curScene:addChild(player, _zOrder)
end


--商店整合入口
function createCenterLayer(p_centerLayerSizse, p_touchPriority, p_zOrder, p_isShow)
    if(p_isShow ~= true)then
        init()
    end
    _priority = p_touchPriority or -700
    _isShow = p_isShow or false
    _zOrder = p_zOrder or 10
    _centerSize = p_centerLayerSizse
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)
    _laySize= {width=0,height=0}
    _laySize.width= _centerLayer:getContentSize().width
    _laySize.height= _centerLayer:getContentSize().height
    -- createMenuSp()--创建珍品和道具按钮
    createButtonBg()
    -- 获得军团商店信息
    Network.rpc(getShopInfoCb, "guildshop.getShopInfo", "guildshop.getShopInfo", nil, true)

    return _centerLayer
end

function create(p_touchPriority, p_zOrder)
    init()
    _layer = CCLayerColor:create(ccc4(11,11,11,200))
   
    _priority = p_touchPriority or -700
    _zOrder = p_zOrder or 10
    require "script/ui/shopall/ShoponeLayer"
    local centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(), _priority, _zOrder, true)
     _layer:registerScriptHandler(onNodeEvent)
    _layer:addChild(centerLayer)
    centerLayer:ignoreAnchorPointForPosition(false)
    centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    centerLayer:setPosition(ccpsprite(0.5, 0.5, _layer))
    return _layer
end

--创建背景颜色 上波浪 下波浪  返回按钮
function createButtonBg( ... )
    if not _isShow then
        --背景
        local underLayer = CCScale9Sprite:create("images/guild/shop/buttonbg.png")
        underLayer:setContentSize(_centerSize)
        underLayer:setAnchorPoint(ccp(0,0))
        underLayer:setPosition(ccp(0,0))
        _centerLayer:addChild(underLayer)

        --上波浪
        local up = CCSprite:create("images/match/shang.png")
        up:setAnchorPoint(ccp(0,1))
        up:setPosition(ccp(0, _centerSize.height))
        up:setScale(g_fScaleX)
        underLayer:addChild(up)
        --下波浪
        local down = CCSprite:create("images/match/xia.png")
        down:setPosition(ccp(0,0))
        down:setScale(g_fScaleX)
        underLayer:addChild(down)
    else
        local menuBar = CCMenu:create()
        menuBar:setPosition(ccp(0, 0))
        -- menuBar:setScale(g_fScaleX)
        menuBar:setTouchPriority(_priority-30)
        _layer:addChild(menuBar, 10)
        -- 返回按钮的回调函数
        local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
        backBtn:setScale(g_fElementScaleRatio)
        backBtn:setAnchorPoint(ccp(1,0.5))
        backBtn:setPosition(ccp(_layer:getContentSize().width-20,_layer:getContentSize().height*0.9))
        backBtn:registerScriptTapHandler(backCallfun)
        menuBar:addChild(backBtn,1,_ksBackTag)
    end
    _girlSp= CCSprite:create("images/shop/shopall/juntuan.png")
    _girlSp:setPosition(0, _centerSize.height*0.5)
    _girlSp:setAnchorPoint(ccp(0,0.5))
    _girlSp:setScale(g_fScaleX)
    _centerLayer:addChild(_girlSp)


end
function backCallfun( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_layer) then
        _layer:removeFromParentAndCleanup(true)
    end
end


--[[
    @des    :事件注册函数
    @param  :事件类型
    @return :
--]]
function onTouchesHandler(eventType)
    if (eventType == "began") then
        print("123123123123")
        print("_priority====",_priority)
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end

--[[
    @des    :事件注册函数
    @param  :事件
    @return :
--]]
function onNodeEvent(event)
    if event == "enter" then
        _layer:registerScriptTouchHandler(onTouchesHandler,false,_priority,true)
        _layer:setTouchEnabled(true)

    elseif eventType == "exit" then
        _layer:unregisterScriptTouchHandler()

    end
end










