-- Filename：    MysteryShopLayer.lua
-- Author：      zhz
-- Date：        2013-9-29
-- Purpose：     神秘商店

module ("MysteryShopLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/model/user/UserModel"
require "script/ui/recycle/RecycleMain" 
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/utils/TimeUtil"
require "script/ui/shopall/MysteryShop/MysteryShopCell"
require "script/libs/LuaCC"
require "script/network/PreRequest"
require "script/ui/main/MenuLayer"


local _bgLayer                  --
local _mysteryShopBg            -- 背景
local _jewelContent             -- 显示文字：当前玩家还有多少魂玉
local _jewelNumNode             -- 显示当前玩家还有多少魂玉的节点
local _costContent              -- 显示文字：使用刷新 。。。。
local _itemNumContent           -- 显示文字：当前拥有的刷新令
local _leftTimeContent          -- 下次刷新时间
local _rfrGoodsItem             -- 刷新按钮
local _myTableViewSp            -- tableView 背景
local _myTableView              -- 商品的tableView
local _upArrowSp                -- 向上的箭头
local _downArrowSp              -- 向下的箭头
local _itemTable                -- tableView 的物品信息

local _updateTimer              -- 定时器
local _rfcType
local _itemNode
local _freeNode

local _itemNum                  -- 刷新令得数量
local _centerSize
local _centerLayer 

local function init(  )
    _bgLayer        = nil
    _mysteryShopBg  = nil
    _jewelContent   = nil
    _jewelNumNode   = nil
    _costContent    = nil
    _itemNumContent = nil
    _rfrGoodsItem   = nil
    _myTableView    = nil
    _myTableViewSp  = nil
    _upArrowSp      = nil
    _downArrowSp    = nil
    _updateTimer    = nil
    _itemTable      = nil
    _rfcType        = nil
    _itemNode       = nil
    _freeNode       = nil
    _itemNum        = 0
end

function createCenterLayer(p_centerSize)
    _centerSize = p_centerSize
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)
    _bgLayer  = CCLayer:create()
    _centerLayer:addChild(_bgLayer)
    _bgLayer:setPosition(ccp(0, -MenuLayer.getHeight()))
    _mysteryShopBg = CCSprite:create("images/recharge/fund/fund_bg.png")
    _bgLayer:addChild(_mysteryShopBg)
    _mysteryShopBg:setScale(MainScene.bgScale)
    _bgLayer:registerScriptHandler(onNodeEvent)

    createTopUI()

    _menuLayerSize = MenuLayer.getLayerContentSize()

    -- 刷新UI
    -- RechargeActiveMain.refreshItemByTag(RechargeActiveMain._tagMysteryShop)

    Network.rpc(shopInfoCallBack, "mysteryshop.getShopInfo" , "mysteryshop.getShopInfo", nil , true)

    return _centerLayer

end

-- 创建上面的UI
function createTopUI( )
    local bulletinLayerSize = ShoponeLayer.getTopGoldContentSize()
    
    local  activeMainWidth = ShoponeLayer.getTopBgHeight()

    -- 灰色的背景
    local fullRect = CCRectMake(0,0,209,49)
    local insetRect = CCRectMake(60,20,3,2)
    local descBg=  CCScale9Sprite:create("images/recharge/restore_energy/desc_bg.png", fullRect, insetRect)
    descBg:setPreferredSize(CCSizeMake(640,50))
    descBg:setScale(g_fScaleX)

    local height = g_winSize.height - bulletinLayerSize.height*g_fScaleX - activeMainWidth
    descBg:setPosition(g_winSize.width/2,height )
    descBg:setAnchorPoint(ccp(0.5,1))
    _bgLayer:addChild(descBg,101)

    local descSp = CCSprite:create("images/shop/shopall/shenmishangdian.png")
    descSp:setPosition(descBg:getContentSize().width/2, descBg:getContentSize().height/2)
    descSp:setAnchorPoint(ccp(0.5,0.5))
    descBg:addChild(descSp)

    local menu= CCMenu:create()
    menu:setTouchPriority(-600)
    menu:setPosition(0,0)
    descBg:addChild(menu)
    --兼容东南亚英文版
local disintegrateItem
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    disintegrateItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(133, 64), GetLocalizeStringBy("key_2687") ,ccc3(0xfe, 0xdb, 0x1c),20,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
else
    disintegrateItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(133, 64), GetLocalizeStringBy("key_2687") ,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
end
    disintegrateItem:setPosition(ccp(descBg:getContentSize().width*0.99, descBg:getContentSize().height/2))
    disintegrateItem:setAnchorPoint(ccp(1,0.5))

    disintegrateItem:registerScriptTapHandler(disintegrateAction)
    menu:addChild(disintegrateItem)

    -- getJewelNum
    _jewelContent = {}
    _jewelContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1339") , g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    _jewelContent[1]:setColor(ccc3(0x00,0xe4,0xff))
    _jewelContent[2]=  CCRenderLabel:create(tostring(UserModel.getJewelNum()) , g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    _jewelContent[2]:setColor(ccc3(0xfe,0xdb,0x1c))

    _jewelNumNode = BaseUI.createHorizontalNode(_jewelContent)
    _jewelNumNode:setScale(MainScene.elementScale)

    height = height - descBg:getContentSize().height*g_fScaleX - 12*MainScene.elementScale 
    _jewelNumNode:setPosition(g_winSize.width*25/64,height)
    _jewelNumNode:setAnchorPoint(ccp(0,1))
    _bgLayer:addChild(_jewelNumNode)

end

-- 创建下部分得UI
function createBottomUI( )

    local menuLayerSize = MenuLayer.getLayerContentSize()

    _costContent = {}
    _costContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_3094") , g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    _costContent[1]:setColor(ccc3(0x00,0xe4,0xff))
    _costContent[2]= CCRenderLabel:create("" .. ActiveCache.getRftGoldNum() , g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    _costContent[2]:setColor(ccc3(0xff,0xf6,0x00))
    _costContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_1011"), g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    _costContent[3]:setColor(ccc3(0x00,0xe4,0xff))

    local costNode =BaseUI.createHorizontalNode(_costContent)

    local height = menuLayerSize.height*g_fScaleX + 20*MainScene.elementScale
    costNode:setPosition(g_winSize.width*0.055, height)
    costNode:setScale(MainScene.elementScale)
    _bgLayer:addChild(costNode)

    _itemNumContent = {}
    _itemNum = ActiveCache.getItemNum()
    _itemNumContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2575") , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _itemNumContent[1]:setColor(ccc3(0xff,0xff,0xff))
    _itemNumContent[2]= CCRenderLabel:create("" ..  _itemNum , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _itemNumContent[2]:setColor(ccc3(0x00,0xff,0x18))
    _itemNumContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_2557") , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _itemNumContent[3]:setColor(ccc3(0xff,0xff,0xff))
    _itemNode =BaseUI.createHorizontalNode(_itemNumContent)
    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    _itemNode:setPosition( g_winSize.width*0.45 , height + 22*MainScene.elementScale)
else
    _itemNode:setPosition( g_winSize.width*0.648 , height)
end
    _itemNode:setScale(MainScene.elementScale)
    -- itemNode:setAnchorPoint(ccp())
    _bgLayer:addChild(_itemNode)


    _freeNumContent = {}
    local freeNum = ActiveCache.getItemNum()
    _freeNumContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_3153") , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _freeNumContent[1]:setColor(ccc3(0xff,0xff,0xff))
    _freeNumContent[2]= CCRenderLabel:create("" .. ActiveCache.getAccRfcTime() , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _freeNumContent[2]:setColor(ccc3(0x00,0xff,0x18))
    _freeNumContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_3010") , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _freeNumContent[3]:setColor(ccc3(0xff,0xff,0xff))
    _freeNode =BaseUI.createHorizontalNode(_freeNumContent)
    _freeNode:setPosition( g_winSize.width*0.648 , height)
    _freeNode:setScale(MainScene.elementScale)
    _bgLayer:addChild(_freeNode)

    if( ActiveCache.getAccRfcTime()>0 ) then
        _freeNode:setVisible(true)
        _itemNode:setVisible(false)
    else
        _freeNode:setVisible(false)
        _itemNode:setVisible(true)
    end


    height = height + _itemNode:getContentSize().height*MainScene.elementScale+59*MainScene.elementScale
    -- 显示时间
    _leftTimeContent= {}
    _leftTimeContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2271") , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _leftTimeContent[1]:setColor(ccc3(0xff,0xff,0xff))
    print("ActiveCache.getRefreshCdTime()  is : ", ActiveCache.getRefreshCdTime())
    _leftTimeContent[2]= CCRenderLabel:create(TimeUtil.getTimeString(ActiveCache.getRefreshCdTime()) ,g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    _leftTimeContent[2]:setColor(ccc3(0x00,0xff,0x18))

    local leftTimeNode =BaseUI.createHorizontalNode(_leftTimeContent)
    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    leftTimeNode:setPosition(g_winSize.width*20/640, height)
else
    leftTimeNode:setPosition(g_winSize.width*0.1, height)
end
    leftTimeNode:setScale(MainScene.elementScale)
    leftTimeNode:setAnchorPoint(ccp(0,0))
    _bgLayer:addChild(leftTimeNode)

    _freeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3307"),g_sFontName,23,1, ccc3(0,0,0), type_stroke)
    _freeLabel:setPosition(leftTimeNode:getContentSize().width/2, -2)
    _freeLabel:setColor(ccc3(0x00,0xff,0x18))
    _freeLabel:setAnchorPoint(ccp(0.5,1))
    leftTimeNode:addChild(_freeLabel)

    _orangeLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1014"),g_sFontName,23,1, ccc3(0,0,0), type_stroke)
    _orangeLabel:setPosition(leftTimeNode:getContentSize().width/2, -15)
    _orangeLabel:setColor(ccc3(0x00,0xff,0x18))
    _orangeLabel:setAnchorPoint(ccp(0.5,1))
    leftTimeNode:addChild(_orangeLabel)

    if ( ActiveCache.isShopAddTimeMax() ) then
        _freeLabel:setVisible(true)
        _orangeLabel:setVisible(false)
    else
        _freeLabel:setVisible(false)
        _orangeLabel:setVisible(true)
    end 

    -- height= 
    -- local itemDesc= CCRenderLabel:create(GetLocalizeStringBy("key_2294") , g_sFontName,23,1,ccc3(0,0,0),type_stroke)
    -- itemDesc:setPosition(g_winSize.width*0.2, height+leftTimeNode:getContentSize().height+15*MainScene.elementScale )
    -- itemDesc:setColor(ccc3(0x00,0xff,0x18))
    -- itemDesc:setAnchorPoint(ccp(0,0))
    -- itemDesc:setScale(MainScene.elementScale)
    -- _bgLayer:addChild(itemDesc,111)

     _updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)

    --- 刷新按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(0,0)
    menuBar:setTouchPriority(-600)
    _bgLayer:addChild(menuBar)
    local goodsItemheight = _menuLayerSize.height*g_fScaleX +  50*MainScene.elementScale
    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    _rfrGoodsItem=  LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_2800") ,ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
else
    _rfrGoodsItem=  LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_2800") ,ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
end
    _rfrGoodsItem:setPosition(g_winSize.width*0.7,goodsItemheight)
    _rfrGoodsItem:registerScriptTapHandler(refreshAction)
    _rfrGoodsItem:setScale(MainScene.elementScale)
    menuBar:addChild(_rfrGoodsItem)

    -- 创建妹子:大乔
    local height = _rfrGoodsItem:getPositionY()+ _rfrGoodsItem:getContentSize().height*MainScene.elementScale+ 13
    local prettyGirlSp = CCSprite:create("images/recharge/mystery_shop/pretty_girl.png")
    prettyGirlSp:setPosition(0,height)
    prettyGirlSp:setScale(MainScene.elementScale)
    prettyGirlSp:setAnchorPoint(ccp(0,0))
    _bgLayer:addChild(prettyGirlSp)

end

function createTableView( )

    local height = _jewelNumNode:getPositionY()/MainScene.elementScale - (_jewelNumNode:getContentSize().height+ _rfrGoodsItem:getContentSize().height+20) - _rfrGoodsItem:getPositionY()/MainScene.elementScale
    local y = _rfrGoodsItem:getPositionY()+ _rfrGoodsItem:getContentSize().height*MainScene.elementScale+ 13
    _myTableViewSp = CCScale9Sprite:create("images/recharge/desc_bg.png")
    _myTableViewSp:setContentSize(CCSizeMake(467, height))
    _myTableViewSp:setScale(MainScene.elementScale)
    _myTableViewSp:setPosition(ccp(g_winSize.width-15, y))
    _myTableViewSp:setAnchorPoint(ccp(1,0))
    _bgLayer:addChild(_myTableViewSp,100)


    _itemTable = ActiveCache.getItemTable()
    local cellSize = CCSizeMake(467, 142)  

    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
       
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width , cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = MysteryShopCell.createCell(_itemTable[a1+1])
           -- a2:setScale(myScale)
            r = a2
        elseif fn == "numberOfCells" then
            r =  #_itemTable
        elseif fn == "cellTouched" then

        elseif (fn == "scroll") then
        end
        return r
    end)
    _tableViewHeight= height-30
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(467,_tableViewHeight))
    _myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(1,15))
    -- _myTableView:setAnchorPoint(ccp(0.5,0))
   -- _myTableView:setScale(MainScene.elementScale)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewSp:addChild(_myTableView)

    print("height is : ", _tableViewHeight)
    print( " _myTableView:getContentSize().height is: ", _myTableView:getContentSize().height )

    -- 向上的箭头
    _upArrowSp = CCSprite:create( "images/common/arrow_up_h.png")
    _upArrowSp:setPosition(_myTableViewSp:getContentSize().width/2, _myTableViewSp:getContentSize().height-5)
    _upArrowSp:setAnchorPoint(ccp(0.5,1))
    _myTableViewSp:addChild(_upArrowSp,1, 101)
    _upArrowSp:setVisible(false)


    -- 向下的箭头
    _downArrowSp = CCSprite:create( "images/common/arrow_down_h.png")
    _downArrowSp:setPosition(_myTableViewSp:getContentSize().width/2, 5)
    _downArrowSp:setAnchorPoint(ccp(0.5,0))
    _myTableViewSp:addChild(_downArrowSp,1, 102)
    _downArrowSp:setVisible(true)

    arrowAction(_downArrowSp)
    arrowAction(_upArrowSp)
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

-- 刷新显示当前魂玉ui
function refreshJewNumUI(  )
    _jewelContent[2]:setString(tostring(UserModel.getJewelNum()))
end

function refreshTableView( )
    local offset = _myTableView:getContentOffset()
    _itemTable= ActiveCache.getItemTable()
    _myTableView:reloadData()
    _myTableView:setContentOffset(offset)
end

-- 刷新所有的UI
function refreshUI(  )
    ShoponeLayer.freshTipNum()
    _costContent[2]:setString("" .. ActiveCache.getRftGoldNum())
    _itemTable= ActiveCache.getItemTable()
    _myTableView:reloadData()
    _freeNumContent[2]:setString("" .. ActiveCache.getAccRfcTime())


    if( ActiveCache.getAccRfcTime()>0 ) then
        _freeNode:setVisible(true)
        _itemNode:setVisible(false)
    else
        _freeNode:setVisible(false)
        _itemNode:setVisible(true)
    end

    
    if ( ActiveCache.isShopAddTimeMax() ) then
        _freeLabel:setVisible(true)
        _orangeLabel:setVisible(false)
    else
        _freeLabel:setVisible(false)
        _orangeLabel:setVisible(true)
    end 

    -- 刷新物品：刷新令得数量 
    itemDelegate()
end

local function bagChangedDelegateFunc( )

    local itemNum = ActiveCache.getItemNum()
    _itemNumContent[2]:setString(tostring(itemNum))
    
end

function itemDelegate( )
    PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc)
end


------------------------------------------ 回调函数 ----------------------
function onNodeEvent( eventType )

    if(eventType == "exit") then
        print(GetLocalizeStringBy("key_1799"))
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
         PreRequest.setBagDataChangedDelete(nil)
    end
end

function disintegrateAction( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- require "script/ui/recycle/RecycleMain"
    -- local RecycleLayer = RecycleMain.create()
    -- MainScene.changeLayer(RecycleLayer,"RecycleLayer")
    require "script/ui/refining/RefiningMainLayer"
    RefiningMainLayer.createLayer(true)
end

function updateShieldTime( )
    --ActiveCache.getRefreshCdTime() 是得到预计刷新时间和现在时间的差值，shieldTime为00:00:00格式
     local shieldTime = "" .. TimeUtil.getTimeString(ActiveCache.getRefreshCdTime())
    _leftTimeContent[2]:setString(shieldTime)

    if(ActiveCache.getRefreshCdTime()<= 0) then
        ActiveCache.addAccRfcTime(1) -- Network.rpc(shopInfoCallBack_02, "mysteryshop.getShopInfo" , "mysteryshop.getShopInfo", nil , true)
        _freeNumContent[2]:setString("" .. ActiveCache.getAccRfcTime())
        ActiveCache.addRefreshCdTime()
        refreshUI( )
    end 


    local offset =  _myTableView:getContentSize().height+ _myTableView:getContentOffset().y- _tableViewHeight
    if(_upArrowSp~= nil )  then
        if(offset>1 or offset<-1) then
            _upArrowSp:setVisible(true)
        else
            _upArrowSp:setVisible(false)
        end
    end

    if(_downArrowSp ~= nil) then

        if( _myTableView:getContentOffset().y ~=0) then
            _downArrowSp:setVisible(true)
        else
            _downArrowSp:setVisible(false)
        end
    end
end



-- 时间到时再请求一次数据
function shopInfoCallBack_02( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok") then
        return 
    end

    ActiveCache.setShopInfo(dictData.ret)

    _itemTable= ActiveCache.getItemTable()
    refreshUI( )
    
end

-- 获得神秘商店信息的网络回调函数
function shopInfoCallBack( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok") then
        return 
    end
    
    -- print_t(dictData.ret)
    ActiveCache.setShopInfo(dictData.ret)
    createBottomUI()
    createTableView()
    -- 炼化炉 第4步 神秘商店内部提示
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            addGuideResolveGuide4()
        end))
    _bgLayer:runAction(seq)

    -- RechargeActiveMain.refreshItemByTag(RechargeActiveMain._tagMysteryShop)
    ActiveCache.setMysteryCdTime()
    
end

-- 刷新按钮的网络回调，
function rftGoodsCallBack( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok") then
        return 
    end

    if(_rfcType== 1) then
        UserModel.addGoldNumber(-tonumber( ActiveCache.getRftGoldNum()))
    end

    print("_rfcType is ", _rfcType , " and  _itemNum is ", _itemNum )
    if(_rfcType==2 ) then
        _itemNum= _itemNum-1
        if(_itemNum <= 0) then
            AnimationTip.showTip(GetLocalizeStringBy("key_3425"))
        end
    end
    -- if(_rfcType ==3) then
        
    -- end

    ActiveCache.setShopInfo(dictData.ret)
    refreshUI( )
end


-- 刷新按钮  int $type: 1.金币刷新 2.物品刷新 ,3.累计免费时间刷新
function refreshAction(tag, item  )
    _rfcType = 1
    local rfcNum= ActiveCache.getItemNum()
    if(rfcNum>0) then
        _rfcType =2
    end 

    local freeNum= ActiveCache.getAccRfcTime()

    if(freeNum >0 ) then
        _rfcType=3
    end

    if(_rfcType==1 and ActiveCache.isRefreshMax() == false) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2858"))
        return 
    end

    if(_rfcType == 1 and rfcNum <=0 and UserModel.getGoldNumber()< tonumber(ActiveCache.getRftGoldNum())) then
        --require "script/ui/tip/AnimationTip"
        --AnimationTip.showTip(GetLocalizeStringBy("key_2450"))
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end


    local args = CCArray:create()
    args:addObject(CCInteger:create(_rfcType))
    Network.rpc(rftGoodsCallBack, "mysteryshop.playerRfrGoodsList" , "mysteryshop.playerRfrGoodsList", args , true)
end

-- 向上和向下箭头的回调函数
function arrowItemAction( tag,item )
    print("arrowItemAction tag is : ", tag)
end




---[==[炼化炉 第4步 神秘商店内部提示
---------------------新手引导---------------------------------
function addGuideResolveGuide4( ... )
    require "script/guide/NewGuide"
    require "script/guide/ResolveGuide"
    if(NewGuide.guideClass ==  ksGuideResolve and ResolveGuide.stepNum == 3) then
        ResolveGuide.show(4, nil)
    end
end
---------------------end-------------------------------------
--]==]



