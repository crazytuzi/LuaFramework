-- FileName: TuanLayer.lua 
-- Author: licong 
-- Date: 14-5-21 
-- Purpose: 团购活动 

module("TuanLayer", package.seeall)

require "script/ui/rechargeActive/ActiveCache"
require "script/utils/TimeUtil"
require "script/model/utils/ActivityConfigUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/rechargeActive/TuanData"
require "script/ui/rechargeActive/TuanService"

local _bgLayer 				= nil
local _topBg 				= nil
local _titleBg 				= nil
local _sellItemBg 			= nil   -- 卖出物品背景
local _buyLabelNode         = nil   -- 购买人数字体背景
local _listTableView        = nil   -- 奖励列表
local _timeFont             = nil   -- 倒计时
local _leftArrowSp          = nil
local _rightArrowSp         = nil

local _listHight            = nil   -- 列表高度
local _listWidth            = nil   -- 列表宽度

local _tongTag 				= nil   -- 青铜档
local _yinTag				= nil   -- 白银档
local _jinTag 				= nil   -- 黄金档
local _zuanTag				= nil   -- 钻石档

local _curMarkItem 			= nil 	-- 当前标签
local _curMarkTag			= nil 	-- 当前标签tag

local _serviceData          = nil   -- 当前服务器数据
local _curMarkData          = nil   -- 当前标签数据
local _listData             = nil   -- 奖励列表数据

local listBg                = nil   -- 列表背景
local _intervalHeight       = nil   -- 三个节点之间的间隔

local _isOver               = false -- 团购是否结束
local _endTime              = nil   -- 团购结束时间戳

local function init( ... )
	_bgLayer 				= nil
	_topBg 					= nil
	_titleBg 				= nil
	_curMarkItem 			= nil
	_curMarkTag				= nil
	_sellItemBg 			= nil
    _buyLabelNode           = nil 
    _listHight              = nil
    _listWidth              = nil
    _listTableView          = nil 
    _timeFont               = nil
    _serviceData            = nil
    _curMarkData            = nil
    _leftArrowSp            = nil
    _rightArrowSp           = nil
    listBg                  = nil 
    _intervalHeight         = nil
    _isOver                 = false
    _endTime                = nil 
end

-- 用于发奖界面初始化
function init2( ... )
    _topBg                  = nil
    _titleBg                = nil
    _curMarkItem            = nil
    _curMarkTag             = nil
    _sellItemBg             = nil
    _buyLabelNode           = nil 
    _listHight              = nil
    _listWidth              = nil
    _listTableView          = nil 
    _timeFont               = nil
    _serviceData            = nil
    _curMarkData            = nil
    _leftArrowSp            = nil
    _rightArrowSp           = nil
    listBg                  = nil 
    _intervalHeight         = nil
    _isOver                 = false
end

local function onNodeEvent( event )
    if (event == "enter") then
    elseif (event == "exit") then
       _bgLayer = nil
       -- 离开请求
       TuanService.leaveGroupOn()
    end
end

-- 得到是哪个档次的
-- return 1,2,3,4
function getButtonMarkType( id )
    local index = nil
    local idTab = TuanData.getDataByDay(_serviceData.day)
    for i=1,#idTab do
        if(tonumber(id) == tonumber(idTab[i]))then
            index = i
            break
        end
    end
    return index
end

-- 团购推送刷新函数
function pushRefreshFun( ret )
    if(_bgLayer ~= nil)then
        require "script/ui/rechargeActive/TuanData"
        -- 修改数量
        TuanData.setBuyGoodsNum(ret)
        -- 新数据
        _curMarkData = TuanData.getGoodsDataById(_curMarkTag)
        -- 显示购买人数
        createBuyLabel()
        -- 设置位置
        _buyLabelNode:setAnchorPoint(ccp(0.5,1))
        local posY2 = _sellItemBg:getPositionY()-_sellItemBg:getContentSize().height*g_fScaleX - _intervalHeight
        _buyLabelNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY2))
        -- 奖励列表
        if(_listTableView ~= nil)then
            local offset = _listTableView:getContentOffset()
            _listData = _curMarkData.listData
            _listTableView:reloadData()
            _listTableView:setContentOffset(offset)
        end
    end
end

-- 刷新tableView
function refreshTableView( ... )
    -- if(_listTableView ~= nil)then
    --     _curMarkData = TuanData.getGoodsDataById(_curMarkTag)
    --     print("_curMarkData")
    --     print_t(_curMarkData)
    --     local offset = _listTableView:getContentOffset()
    --     _listData = nil
    --     _listData = _curMarkData.listData
    --     _listTableView:reloadData()
    --     _listTableView:setContentOffset(offset)
    -- end
    -- if(_listTableView)then
    --     _listTableView:removeFromParentAndCleanup(true)
    --     _listTableView = nil
    -- end
    _curMarkData = TuanData.getGoodsDataById(_curMarkTag)
    createRewardList()

end

-- 箭头的动画
local function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end

-- 创建奖励列表
 function createRewardList(isChange,tag)
    if(_listTableView)then
        _listTableView:removeFromParentAndCleanup(true)
        _listTableView = nil
    end
    if(listBg)then
        listBg:removeFromParentAndCleanup(true)
        listBg = nil
    end
    local isChange = isChange or false
    _listHight = nil
    _listWidth = nil
    -- 列表背景
    local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(30,30,15,10)
    listBg = CCScale9Sprite:create("images/astrology/astro_btnbg.png",fullRect, insetRect)
    -- _listHight = _buyLabelNode:getPositionY()-_buyLabelNode:getContentSize().height*g_fScaleX-MenuLayer.getHeight()-38*g_fScaleX
    _listHight = 215*g_fScaleX
    _listWidth = 560
    listBg:setContentSize(CCSizeMake(_listWidth+75,_listHight/g_fScaleX))
    listBg:setAnchorPoint(ccp(0.5,0))
    local posY = (_buyLabelNode:getPositionY()-_buyLabelNode:getContentSize().height*g_fScaleX-MenuLayer.getHeight())/2
    listBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
    _bgLayer:addChild(listBg)
    listBg:setScale(g_fScaleX)
    -- 标题
    local fullRect = CCRectMake(0,0,75,35)
    local insetRect = CCRectMake(35,14,5,6)
    local titleSp = CCScale9Sprite:create("images/astrology/astro_labelbg.png",fullRect, insetRect)
    titleSp:setContentSize(CCSizeMake(182,35))
    titleSp:setAnchorPoint(ccp(0.5,0.5))
    titleSp:setPosition(ccp(listBg:getContentSize().width*0.5,listBg:getContentSize().height))
    listBg:addChild(titleSp)
    local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2295"), g_sFontPangWa, 24)
    titleFont:setAnchorPoint(ccp(0.5,0.5))
    titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
    titleSp:addChild(titleFont)

    -- 创建tableView
    _listData = nil
    _listData = _curMarkData.listData
    -- print("_listData tableView ")
    -- print_t(_listData)
    require "script/ui/rechargeActive/TuanRewardCell"
    local cellSize = CCSizeMake(150,202)
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif (fn == "cellAtIndex") then
            r = TuanRewardCell.createCell( _listData[a1+1] )
            if(isChange)then
               r = TuanRewardCell.createCell( _listData[a1+1],isChange,tag)  
            end
        elseif (fn == "numberOfCells") then
            r = #_listData
        elseif (fn == "cellTouched") then
            -- print ("a1: ", a1, ", a2: ", a2)
            -- print ("cellTouched, index is: ", a1:getIdx())
        else
            -- print (fn, " event is not handled.")
        end
        return r
    end)

    _listTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(_listWidth,_listHight/g_fScaleX-22))
    _listTableView:setBounceable(true)
    _listTableView:setAnchorPoint(ccp(0, 0))
    _listTableView:setPosition(ccp(40, 2))
    listBg:addChild(_listTableView)
    _listTableView:setDirection(kCCScrollViewDirectionHorizontal)
    -- 设置单元格升序排列
    _listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _listTableView:setTouchPriority(-340)

    -- 左箭头
    _leftArrowSp = CCSprite:create( "images/common/arrow_left.png")
    _leftArrowSp:setPosition(0, listBg:getContentSize().height*0.5)
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    listBg:addChild(_leftArrowSp,1, 101)
    _leftArrowSp:setVisible(false)


    -- 右箭头
    _rightArrowSp = CCSprite:create( "images/common/arrow_right.png")
    _rightArrowSp:setPosition(listBg:getContentSize().width, listBg:getContentSize().height*0.5)
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    listBg:addChild(_rightArrowSp,1, 102)
    _rightArrowSp:setVisible(true)

    arrowAction(_rightArrowSp)
    arrowAction(_leftArrowSp)
end

-- 创建购买人数
-- haveNum:已购买人数，subNum:还差多少人数，nextNum:下一奖励需求人数
function createBuyLabel()
    if(_buyLabelNode ~= nil)then
        _buyLabelNode:removeFromParentAndCleanup(true)
        _buyLabelNode = nil
    end
    _buyLabelNode = CCNode:create()
    _buyLabelNode:setContentSize(CCSizeMake(640,30))
    -- _buyLabelNode:setAnchorPoint(ccp(0.5,1))
    -- local posY = _sellItemBg:getPositionY()-_sellItemBg:getContentSize().height*g_fScaleX
    -- _buyLabelNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
    _bgLayer:addChild(_buyLabelNode)
    _buyLabelNode:setScale(g_fScaleX)

    local haveNum,subNum,nextNum = TuanData.getPeopleNum(_curMarkData)
    local str1 = GetLocalizeStringBy("lic_1016")
    local str2 = haveNum 
    local str3 = ""
    if(nextNum)then
        str3 = GetLocalizeStringBy("lic_1017")
    else
        str3 = GetLocalizeStringBy("lic_1018")
    end
    local font1 = CCLabelTTF:create(str1,g_sFontPangWa,21)
    font1:setAnchorPoint(ccp(0,0))
    font1:setColor(ccc3(0xff,0xff,0xff))
    _buyLabelNode:addChild(font1)
    local font2 = CCLabelTTF:create(str2,g_sFontPangWa,21)
    font2:setAnchorPoint(ccp(0,0))
    font2:setColor(ccc3(0x00,0xff,0x18))
    _buyLabelNode:addChild(font2)
    local font3 = CCLabelTTF:create(str3,g_sFontPangWa,21)
    font3:setAnchorPoint(ccp(0,0))
    font3:setColor(ccc3(0xff,0xff,0xff))
    _buyLabelNode:addChild(font3)
    if(nextNum)then
        local str4 = subNum
        local str5 = GetLocalizeStringBy("lic_1019")
        local str6 = nextNum
        local str7 = GetLocalizeStringBy("lic_1020")
        local font4 = CCLabelTTF:create(str4,g_sFontPangWa,21)
        font4:setAnchorPoint(ccp(0,0))
        font4:setColor(ccc3(0x00,0xff,0x18))
        _buyLabelNode:addChild(font4)
        local font5 = CCLabelTTF:create(str5,g_sFontPangWa,21)
        font5:setAnchorPoint(ccp(0,0))
        font5:setColor(ccc3(0xff,0xff,0xff))
        _buyLabelNode:addChild(font5)
        local font6 = CCLabelTTF:create(str6,g_sFontPangWa,21)
        font6:setAnchorPoint(ccp(0,0))
        font6:setColor(ccc3(0x00,0xff,0x18))
        _buyLabelNode:addChild(font6)
        local font7 = CCLabelTTF:create(str7,g_sFontPangWa,21)
        font7:setAnchorPoint(ccp(0,0))
        font7:setColor(ccc3(0xff,0xff,0xff))
        _buyLabelNode:addChild(font7)
        -- 居中显示
        local pox = (_buyLabelNode:getContentSize().width-font1:getContentSize().width-font2:getContentSize().width-font3:getContentSize().width-font4:getContentSize().width-font5:getContentSize().width-font6:getContentSize().width-font7:getContentSize().width)/2
        font1:setPosition(ccp(pox,0))
        font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
        font3:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font1:getPositionY()))
        font4:setPosition(ccp(font3:getPositionX()+font3:getContentSize().width,font1:getPositionY()))
        font5:setPosition(ccp(font4:getPositionX()+font4:getContentSize().width,font1:getPositionY()))
        font6:setPosition(ccp(font5:getPositionX()+font5:getContentSize().width,font1:getPositionY()))
        font7:setPosition(ccp(font6:getPositionX()+font6:getContentSize().width,font1:getPositionY()))
    else
        -- 居中显示
        local pox = (_buyLabelNode:getContentSize().width-font1:getContentSize().width-font2:getContentSize().width-font3:getContentSize().width)/2
        font1:setPosition(ccp(pox,0))
        font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
        font3:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font1:getPositionY()))
    end
end

-- 卖出物品按钮事件
local function sellIconItemFun( tag, itemBtn )
	-- print("icon tag =>" .. tag)
    local itemsData = ItemUtil.getItemsDataByStr( _curMarkData.dbData.reward )
    -- print("jiangli ")
    -- print_t(itemsData)
    -- 展示奖励
    require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( itemsData, nil , 1001, -455, GetLocalizeStringBy("lic_1021") )
end

-- 购买回调
local function buyItemCallFun( tag, itemBtn )
	-- print("buy tag =>" .. tag)
    -- 判断活动是否结束
    if( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.groupon.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.groupon.end_time) ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
        return
    end 
    -- 判断购买活动是否结束
    if( BTUtil:getSvrTimeInterval() >= _endTime ) then 
        AnimationTip.showTip(GetLocalizeStringBy("lic_1455"))
        return
    end 
    -- 物品背包满了
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    if(tonumber(UserModel.getVipLevel()) < tonumber(_curMarkData.dbData.vip) ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2751") .. _curMarkData.dbData.vip .. GetLocalizeStringBy("key_2856") )
        return 
    end
    if( UserModel.getGoldNumber() < tonumber(_curMarkData.dbData.price) )then
        -- 金币不足
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end
    local function nextCallFun( ... )
        -- 把按钮移除
        if(itemBtn ~= nil)then
            itemBtn:removeFromParentAndCleanup(true)
        end
        -- 已购买按钮
        -- local itemSp = CCSprite:create("images/common/btn/btn_blue_hui.png")
        -- itemSp:setAnchorPoint(ccp(0,0))
        -- itemSp:setPosition(ccp(458, _sellItemBg:getContentSize().height*0.18))
        -- _sellItemBg:addChild(itemSp,1)
        -- local menuItemFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1022"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- menuItemFont:setColor(ccc3(0xf1, 0xf1, 0xf1))
        -- menuItemFont:setAnchorPoint(ccp(0.5,0.5))
        -- menuItemFont:setPosition(ccp(itemSp:getContentSize().width*0.5,itemSp:getContentSize().height*0.5))
        -- itemSp:addChild(menuItemFont)
         local hasReceiveItem = CCSprite:create("images/common/showqing.png")
        hasReceiveItem:setAnchorPoint(ccp(1,0.5))
        hasReceiveItem:setPosition(ccp(_sellItemBg:getContentSize().width-25,_sellItemBg:getContentSize().height*0.45))
        _sellItemBg:addChild(hasReceiveItem)
        -- 购买次数 1/1
        if(_sellItemBg ~= nil)then
            if(_sellItemBg:getChildByTag(1001) ~= nil)then
                tolua.cast(_sellItemBg:getChildByTag(1001),"CCLabelTTF"):setString("(1/1)")
            end
        end
        -- 弹出奖励物品
        local rewardData = ItemUtil.getItemsDataByStr( _curMarkData.dbData.reward )
        -- 扣除购买金币
        UserModel.addGoldNumber(-tonumber(_curMarkData.dbData.price))
        -- 修改本地数据 加奖励
        -- print("rewardData")
        -- print_t(rewardData)
        ItemUtil.addRewardByTable(rewardData)
        -- 展现领取奖励列表
        require "script/ui/item/ReceiveReward"
        ReceiveReward.showRewardWindow( rewardData, nil , 1001, -455 )
        -- 修改参团状态
        TuanData.setGoodsState(tag)
        -- 刷新列表
        refreshTableView()
    end 
    -- 发送购买请求
    TuanService.buyGood(tag,nextCallFun)
end

-- 创建参团物品
local function createSellItem()
	if( _sellItemBg ~= nil )then
		_sellItemBg:removeFromParentAndCleanup(true)
		_sellItemBg = nil
	end
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    _sellItemBg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
    _sellItemBg:setContentSize(CCSizeMake(614,154))
    -- _sellItemBg:setAnchorPoint(ccp(0.5,1))
    -- local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX 
    -- _sellItemBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
    _bgLayer:addChild(_sellItemBg)
    _sellItemBg:setScale(g_fScaleX)
    -- 二级背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local goodsBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    goodsBg:setContentSize(CCSizeMake(280,94))
    goodsBg:setAnchorPoint(ccp(0,0.5))
    goodsBg:setPosition(ccp(123,_sellItemBg:getContentSize().height*0.5))
    _sellItemBg:addChild(goodsBg)
    -- 物品icon
    local iconBg = CCSprite:create("images/everyday/headBg1.png")
    iconBg:setAnchorPoint(ccp(0,0.5))
    iconBg:setPosition(ccp(13,_sellItemBg:getContentSize().height*0.56))
    _sellItemBg:addChild(iconBg)
    -- 图标底
    local iconSpriteBg1 = CCSprite:create("images/base/potential/props_" .. _curMarkData.dbData.quality .. ".png")
    iconSpriteBg1:setAnchorPoint(ccp(0.5,0.5))
    iconSpriteBg1:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
    iconBg:addChild(iconSpriteBg1)

    -- icon按钮
    local iconMenu = CCMenu:create()
    iconMenu:setAnchorPoint(ccp(0,0))
    iconMenu:setPosition(ccp(0,0))
    iconSpriteBg1:addChild(iconMenu)
    iconMenu:setTouchPriority(-341)
    local iconSp_n = CCSprite:create("images/recharge/tuan/" .. _curMarkData.dbData.icon .. ".png")
    local iconSp_h = CCSprite:create("images/recharge/tuan/" .. _curMarkData.dbData.icon .. ".png")
    local iconItem = CCMenuItemSprite:create(iconSp_n,iconSp_h)
    iconItem:setAnchorPoint(ccp(0.5,0.5))
    iconItem:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
    iconMenu:addChild(iconItem,1,tonumber(_curMarkTag))
    iconItem:registerScriptTapHandler(sellIconItemFun)
    -- 物品名字
    local nameColor = HeroPublicLua.getCCColorByStarLevel(tonumber(_curMarkData.dbData.quality))
    local iconName = CCRenderLabel:create(_curMarkData.dbData.name,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    iconName:setColor(nameColor)
    iconName:setAnchorPoint(ccp(0.5,0.5))
    iconName:setPosition(ccp(iconBg:getContentSize().width*0.5,-10))
    iconBg:addChild(iconName)

    -- 原价
    local oldSp = CCSprite:create("images/recharge/tuan/old.png")
    oldSp:setAnchorPoint(ccp(0,0))
    oldSp:setPosition(ccp(61,55))
    goodsBg:addChild(oldSp,10)
    local goldSp1 = CCSprite:create("images/common/gold.png")
    goldSp1:setAnchorPoint(ccp(0,0))
    goldSp1:setPosition(ccp(oldSp:getPositionX()+oldSp:getContentSize().width+10,oldSp:getPositionY()))
    goodsBg:addChild(goldSp1)
    local oldNum = _curMarkData.dbData.oriprice
    local oldNumFont = CCRenderLabel:create(oldNum,g_sFontPangWa,25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    oldNumFont:setColor(ccc3(0x00,0xe4,0xff))
    oldNumFont:setAnchorPoint(ccp(0,0))
    oldNumFont:setPosition(ccp(goldSp1:getPositionX()+goldSp1:getContentSize().width+10,oldSp:getPositionY()))
    goodsBg:addChild(oldNumFont)
    local redSp = CCSprite:create("images/common/redline.png")
    redSp:setAnchorPoint(ccp(0,0.5))
    redSp:setPosition(ccp(-23,oldSp:getContentSize().height*0.5))
    oldSp:addChild(redSp)

    -- 现价
    local newSp = CCSprite:create("images/recharge/tuan/now.png")
    newSp:setAnchorPoint(ccp(0,0))
    newSp:setPosition(ccp(50,10))
    goodsBg:addChild(newSp)
    local goldSp2 = CCSprite:create("images/common/gold.png")
    goldSp2:setAnchorPoint(ccp(0,0))
    goldSp2:setPosition(ccp(newSp:getPositionX()+newSp:getContentSize().width+10,newSp:getPositionY()))
    goodsBg:addChild(goldSp2)
    local newNum = _curMarkData.dbData.price
    local newNumFont = CCRenderLabel:create(newNum,g_sFontPangWa,25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    newNumFont:setColor(ccc3(0xff,0xf6,0x00))
    newNumFont:setAnchorPoint(ccp(0,0))
    newNumFont:setPosition(ccp(goldSp2:getPositionX()+goldSp2:getContentSize().width+10,newSp:getPositionY()))
    goodsBg:addChild(newNumFont)

    -- 可购买次数
    local font1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1008"),g_sFontName,21)
    font1:setColor(ccc3(0x78,0x25,0x00))
    font1:setAnchorPoint(ccp(0,1))
    font1:setPosition(ccp(430,_sellItemBg:getContentSize().height-30))
    _sellItemBg:addChild(font1)
    -- 购买次数
    local haveNum = 0
    local maxNum = 1
    if( tonumber(_curMarkData.retData.state) == 1 )then
        -- 已购买
        haveNum = 1
    end
    local numFont = CCLabelTTF:create("(" .. haveNum .. "/" .. maxNum .. ")",g_sFontName,21)
    numFont:setColor(ccc3(0x00,0x8d,0x3d))
    numFont:setAnchorPoint(ccp(0,1))
    numFont:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width+2,font1:getPositionY()))
    _sellItemBg:addChild(numFont,1,1001)

    -- 购买按钮
    if(haveNum == 0)then
        local menu = CCMenu:create()
        menu:setAnchorPoint(ccp(0,0))
        menu:setPosition(ccp(0,0))
        _sellItemBg:addChild(menu)
        menu:setTouchPriority(-341)
        
        local menuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png")
        menuItem:setAnchorPoint(ccp(0,0))
        menuItem:setPosition(ccp(458, _sellItemBg:getContentSize().height*0.18))
        menu:addChild(menuItem,1,tonumber(_curMarkTag))
        -- 字体
        local menuItemFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1023"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        menuItemFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
        menuItemFont:setAnchorPoint(ccp(0.5,0.5))
        menuItemFont:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
        menuItem:addChild(menuItemFont)
        -- 注册兑换回调
        menuItem:registerScriptTapHandler(buyItemCallFun)
    else
        -- local itemSp = CCSprite:create("images/common/btn/btn_blue_hui.png")
        -- itemSp:setAnchorPoint(ccp(0,0))
        -- itemSp:setPosition(ccp(458, _sellItemBg:getContentSize().height*0.18))
        -- _sellItemBg:addChild(itemSp,1)
        -- local menuItemFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1022"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- menuItemFont:setColor(ccc3(0xf1, 0xf1, 0xf1))
        -- menuItemFont:setAnchorPoint(ccp(0.5,0.5))
        -- menuItemFont:setPosition(ccp(itemSp:getContentSize().width*0.5,itemSp:getContentSize().height*0.5))
        -- itemSp:addChild(menuItemFont)
        local hasReceiveItem = CCSprite:create("images/common/showqing.png")
        hasReceiveItem:setAnchorPoint(ccp(1,0.5))
        hasReceiveItem:setPosition(ccp(_sellItemBg:getContentSize().width-25,_sellItemBg:getContentSize().height*0.45))
        _sellItemBg:addChild(hasReceiveItem)
    end
end

-- 创建参团物品和奖励列表
local function createSellItemAndList()
	-- 数据准备
    _curMarkData = TuanData.getGoodsDataById(_curMarkTag)
	-- 创建卖出的物品
	createSellItem()
    -- 显示购买人数
    createBuyLabel()
    -- 奖励列表
    if(_listTableView == nil)then
        createRewardList()
    else
        _listData = _curMarkData.listData
        _listTableView:reloadData()
    end

    -- 设置三个节点坐标 居中
    local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX 
    _sellItemBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
    local allHeight = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-MenuLayer.getHeight()
    local nodeHeight = _sellItemBg:getContentSize().height*g_fScaleX+_buyLabelNode:getContentSize().height*g_fScaleX+listBg:getContentSize().height*g_fScaleX+50*g_fScaleX
    _intervalHeight = (allHeight - nodeHeight)/4
    -- 1
    _sellItemBg:setAnchorPoint(ccp(0.5,1))
    local posY1 = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX - _intervalHeight
    _sellItemBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY1))
    -- 2
    _buyLabelNode:setAnchorPoint(ccp(0.5,1))
    local posY2 = _sellItemBg:getPositionY()-_sellItemBg:getContentSize().height*g_fScaleX - _intervalHeight
    _buyLabelNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY2))
    -- 3
    listBg:setAnchorPoint(ccp(0.5,1))
    local posY3 = _buyLabelNode:getPositionY()-_buyLabelNode:getContentSize().height*g_fScaleX - _intervalHeight-25*g_fScaleX
    listBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY3))
end

-- 四个标签按钮事件
local function markCallFun( tag, itemBtn )
	itemBtn:selected()
	if(itemBtn ~= _curMarkItem) then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
		_curMarkItem:unselected()
		_curMarkItem = itemBtn
		_curMarkItem:selected()
		_curMarkTag = tag
		-- 创建参团物品和奖励列表
		createSellItemAndList()
        refreshTableView()
	end
end

-- 创建4个标签
local function createMenuItem(  )
	local country_text = {GetLocalizeStringBy("lic_1024"), GetLocalizeStringBy("lic_1025"), GetLocalizeStringBy("lic_1026"), GetLocalizeStringBy("lic_1027")}
	-- local country_text = {"青铜档", "白银档", "黄金档", "钻石档"}
	local tagTab = {_tongTag, _yinTag, _jinTag, _zuanTag}
	local itemPositionX = {0.125, 0.373, 0.623, 0.87}

	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	local btn_size_n	= CCSizeMake(150, 43)
	local btn_size_h	= CCSizeMake(158, 53)
	
	local text_color_n	= {
		ccc3(0x00, 0xff, 0x18),
		ccc3(0x00, 0xe4, 0xff),
		ccc3(0xe4, 0x00, 0xff),
		ccc3(0xff, 0x78, 0x00)
	} 
	local text_color_h	= {
		ccc3(0x00, 0xff, 0x18),
		ccc3(0x00, 0xe4, 0xff),
		ccc3(0xe4, 0x00, 0xff),
		ccc3(0xff, 0x78, 0x00)
	}
	local font			= g_sFontPangWa
	local font_size		= 25
	local strokeCor_n	= ccc3(0x00, 0x00, 0x00) 
	local strokeCor_h	= ccc3(0x00, 0x00, 0x00)  
	local stroke_size	= 1

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	_topBg:addChild(menuBar)

    -- 今天配置的礼包id
    local idTab = TuanData.getDataByDay(_serviceData.day)
	for k,v in pairs(_serviceData.goods_list) do
        -- 标签id
        local index = nil
        for i=1,#idTab do
            if(tonumber(k) == tonumber(idTab[i]))then
                index = i
                break
            end
        end
        -- tag == goodsId
        tagTab[index] = tonumber(k)
        -- 创建标签
        local text = country_text[index]
        local menuItem = LuaCCMenuItem.createMenuItemOfRender(  image_n, image_h, rect_full_n, rect_inset_n, rect_full_h, rect_inset_h, btn_size_n, btn_size_h, text, text_color_n[index], text_color_h[index], font, font_size, strokeCor_n, strokeCor_h, stroke_size )
        menuItem:setAnchorPoint(ccp(0.5,0))
        menuItem:setPosition(ccp(_topBg:getContentSize().width*itemPositionX[index], 12))
        menuItem:registerScriptTapHandler(markCallFun)
        menuBar:addChild(menuItem, 1, tagTab[index])
        if(index == 1) then
            _curMarkItem = menuItem
            _curMarkItem:selected()
            _curMarkTag = tagTab[index]
            -- 默认显示 青铜档
            createSellItemAndList( _curMarkTag )
        end
    end
end

-- 0点刷新
local function freeRefreshFun( ... )
    if(_bgLayer ~= nil)then
        -- 清除所有
        _bgLayer:removeAllChildrenWithCleanup(true)
        -- 网络请求
        TuanService.getShopInfo(serviceFun)
    end
end 

-- 活动0点系统刷新
local function freeRefresh( ... )
    if(_bgLayer ~= nil)then
        -- 计算下一0点时间戳
        local curTimeStr = TimeUtil.getTimeFormatYMDHMS( TimeUtil.getSvrTimeByOffset(0) )
        local curZeroStr = string.gsub(curTimeStr, "%d%d:%d%d:%d%d", "00:00:00")
        local curZeroTime = TimeUtil.getIntervalByTimeString(curZeroStr)
        local nextZeroTime = curZeroTime + 24*60*60
        local subTime = nextZeroTime - TimeUtil.getSvrTimeByOffset(0)
        if(subTime > 0 and _endTime > nextZeroTime)then
            local actionArray = CCArray:create()
            actionArray:addObject(CCDelayTime:create(subTime))
            actionArray:addObject(CCCallFunc:create(freeRefreshFun))
            _bgLayer:runAction(CCSequence:create(actionArray))
        end
    end
end

-- 活动结束倒计时
local function timeDownFun( ... )
    if(_timeFont ~= nil)then
        local subNum = tonumber(ActivityConfig.ConfigCache.groupon.end_time) - TimeUtil.getSvrTimeByOffset(0)
        if(subNum > 0)then
            local str = TimeUtil.getTimeDesByInterval(subNum)
            _timeFont:setString(str)
        else
            _timeFont:stopAllActions()
            _timeFont:setString(GetLocalizeStringBy("lic_1010"))
        end

        local actionArray = CCArray:create()
        actionArray:addObject(CCDelayTime:create(1))
        actionArray:addObject(CCCallFunc:create(timeDownFun))
        _timeFont:runAction(CCSequence:create(actionArray))
    end

    if(_listTableView ~= nil)then
        local offset =  _listTableView:getContentSize().width+ _listTableView:getContentOffset().x-_listWidth
        -- print("offset:",offset,"width:",_listTableView:getContentSize().width,"offset.x:",_listTableView:getContentOffset().x,"_listWidth:",_listWidth)
        if(_rightArrowSp~= nil )  then
            if(offset>1 or offset<-1) then
                _rightArrowSp:setVisible(true)
            else
                _rightArrowSp:setVisible(false)
            end
        end

        if(_leftArrowSp ~= nil) then
            if( _listTableView:getContentOffset().x ~=0) then
                _leftArrowSp:setVisible(true)
            else
                _leftArrowSp:setVisible(false)
            end
        end
    end
end

-- 初始化界面
local function initTuanActiveLayer( ... )
    require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
    local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX

    if( _isOver == true )then 
        -- 背景
        local bgSp = CCSprite:create("images/recharge/tuan/endbg.jpg")
        bgSp:setAnchorPoint(ccp(0.5,0.5))
        bgSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
        _bgLayer:addChild(bgSp)
        bgSp:setScale(g_fBgScaleRatio)
        -- 上半部分背景
        _topBg = CCSprite:create()
        _topBg:setContentSize(CCSizeMake(640,140))
    else
        -- 上半部分背景
	   _topBg = CCSprite:create("images/recharge/tuan/top_bg.png")
    end

    _topBg:setAnchorPoint(ccp(0.5,1))
    _topBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-topMenuHeight+10))
    _bgLayer:addChild(_topBg)
    _topBg:setScale(g_fScaleX)
	-- 标题背景
	_titleBg = CCSprite:create("images/recharge/tuan/title_bg.png")
    _titleBg:setAnchorPoint(ccp(0.5,1))
    _titleBg:setPosition(ccp(_topBg:getContentSize().width*0.5,_topBg:getContentSize().height-3))
    _topBg:addChild(_titleBg)
    -- 标题
	local titleSprite = CCSprite:create("images/recharge/tuan/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(_titleBg:getContentSize().width*0.5,_titleBg:getContentSize().height*0.5+2))
	_titleBg:addChild(titleSprite)

    -- 开放时间
    local timeFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1015"), g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeFont:setColor(ccc3(0x00,0xe4,0xff))
    timeFont:setAnchorPoint(ccp(0,0.5))
    timeFont:setPosition(ccp(255,73))
    _topBg:addChild(timeFont)
    -- 开始时间 --- 结束时间
    -- 开始时间
    local startTime = tonumber(ActivityConfig.ConfigCache.groupon.start_time)
    local startTimeStr = TimeUtil.getTimeForDayTwo( startTime )
    -- 结束时间
    local endTime = tonumber(ActivityConfig.ConfigCache.groupon.end_time)
    local endTimeStr = TimeUtil.getTimeForDayTwo( endTime )
    local timeStr = startTimeStr .. " — " ..  endTimeStr
    local timeStr_font = CCRenderLabel:create( timeStr, g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeStr_font:setColor(ccc3(0x00,0xff,0x18))
    timeStr_font:setAnchorPoint(ccp(0,0.5))
    timeStr_font:setPosition(ccp(timeFont:getPositionX()+timeFont:getContentSize().width+5,timeFont:getPositionY()))
    _topBg:addChild(timeStr_font)

	-- 活动剩余时间
    local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1012"),g_sFontName,18, 1, ccc3(0x00,0x00,0x00), type_stroke)
    font1:setColor(ccc3(0x00,0xe4,0xff))
    font1:setAnchorPoint(ccp(0,0.5))
    font1:setPosition(ccp(5,73))
    _topBg:addChild(font1)
 
    -- 时间倒计时
    local endTimeNum = tonumber(ActivityConfig.ConfigCache.groupon.end_time) - TimeUtil.getSvrTimeByOffset(0)
    local endTimeStr = TimeUtil.getTimeDesByInterval(endTimeNum)
    _timeFont = CCLabelTTF:create(endTimeStr,g_sFontName,18)
    _timeFont:setColor(ccc3(0x00,0xff,0x18))
    _timeFont:setAnchorPoint(ccp(0,0.5))
    _timeFont:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width+2,font1:getPositionY()))
    _topBg:addChild(_timeFont)

    -- 倒计时
    timeDownFun()

    if( _isOver == true )then 
        timeFont:setPosition(ccp(255,43))
        timeStr_font:setPosition(ccp(timeFont:getPositionX()+timeFont:getContentSize().width+5,timeFont:getPositionY()))
        font1:setPosition(ccp(5,43))
        _timeFont:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width+2,font1:getPositionY()))

        -- girl
        local girlSp = CCSprite:create("images/recharge/tuan/endgirl.png")
        girlSp:setAnchorPoint(ccp(0,0))
        girlSp:setPosition(ccp(0,_bgLayer:getContentSize().height*0.18))
        _bgLayer:addChild(girlSp)
        girlSp:setScale(g_fElementScaleRatio)

        -- gift
        local giftSp = CCSprite:create("images/recharge/tuan/endgift.png")
        giftSp:setAnchorPoint(ccp(1,0))
        giftSp:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.18))
        _bgLayer:addChild(giftSp)
        giftSp:setScale(g_fElementScaleRatio)

        -- 主公，限时团购已结束。
        local desFont1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1398"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        desFont1:setColor(ccc3(0xff,0xf6,0x00))
        desFont1:setAnchorPoint(ccp(0,1))
        desFont1:setPosition(ccp(334*g_fElementScaleRatio,_bgLayer:getContentSize().height*0.6))
        _bgLayer:addChild(desFont1)
        desFont1:setScale(g_fElementScaleRatio)

        -- 系统正在补发未领取的奖励。
        local fontTab = {}
        fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1399"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        fontTab[1]:setColor(ccc3(0xff,0xf6,0x00))
        fontTab[2] = CCRenderLabel:create(GetLocalizeStringBy("lic_1454"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        fontTab[2]:setColor(ccc3(0x00,0xe4,0xff))
        fontTab[3] = CCRenderLabel:create("。", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        fontTab[3]:setColor(ccc3(0xff,0xf6,0x00))
        local desFont2 = BaseUI.createHorizontalNode(fontTab)
        desFont2:setColor(ccc3(0xff,0xf6,0x00))
        desFont2:setAnchorPoint(ccp(0,1))
        desFont2:setPosition(ccp(312*g_fElementScaleRatio,desFont1:getPositionY()-desFont1:getContentSize().height-18*g_fElementScaleRatio))
        _bgLayer:addChild(desFont2)
        desFont2:setScale(g_fElementScaleRatio)
    else
        -- 0点刷新
        freeRefresh()
    	-- 创建标签
    	createMenuItem()
    end
end

-- 网络请求回调
function serviceFun( dataRet )
    -- 设置数据
    TuanData.setServiceData(dataRet)

    -- 得到服务器数据
    _serviceData = TuanData.getServiceData()

    -- 初始化界面
    initTuanActiveLayer()
end

-- 创建团购界面
function createTuanLayer( ... )
	init()
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)

    -- 活动是否结束
    _endTime = TuanData.getTuanEndTime()
    print("_endTime:",_endTime)
    local curTime = TimeUtil.getSvrTimeByOffset(0)
    if(curTime >= _endTime)then
        _isOver = true
    else
        _isOver = false

        local endFreshFun = function ( ... )
            -- 购买活动结束 换UI
            _bgLayer:removeAllChildrenWithCleanup(true)
            -- 初始化2
            init2()
            -- 结束了
            _isOver = true
            -- 初始化界面
            initTuanActiveLayer()
        end
        performWithDelay(_bgLayer, endFreshFun, _endTime-TimeUtil.getSvrTimeByOffset(0) )
    end

    if(_isOver)then
        -- 初始化界面
        initTuanActiveLayer()
    else
        -- 网络请求
        TuanService.getShopInfo(serviceFun)
    end

	return _bgLayer
end











































