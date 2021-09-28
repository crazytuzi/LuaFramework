-- FileName: BlackShopLayer.lua 
-- Author: yangrui 
-- Date: 15-8-27 
-- Purpose: 变废为宝主界面 

module("BlackshopLayer", package.seeall)

require "script/ui/rechargeActive/blackshop/BlackshopService"
require "script/ui/rechargeActive/blackshop/BlackshopData"
require "script/ui/rechargeActive/blackshop/BlackshopController"
require "script/ui/rechargeActive/blackshop/BlackshopUtil"
require "script/ui/rechargeActive/blackshop/BlackshopChargeAlert"
require "script/utils/TimeUtil"
require "script/ui/tip/AnimationTip"

local _bgLayer 				= nil
local _titleBg 				= nil
local _listBg               = nil
local _listHight            = nil
local _listWidth            = nil
local _listView             = nil

--[[
	@des 	: 初始化
--]]
local function init( ... )
	_bgLayer 				= nil
	_titleBg 				= nil
    _listBg                 = nil   
	_listHight              = nil
    _listWidth              = nil
    _listView               = nil
end

-- 材料x坐标 key是材料个数
local _posXTab = {
    -- 1个材料x坐标
    {0.15, 0.8},
    -- 2个材料x坐标
    {0.15, 0.49, 0.8},
}

-- 材料y坐标 key是材料个数
local _posYTab = {
    -- 1个材料y坐标
    {0.57},
    -- 2个材料y坐标
    {0.57, 0.57},
}

-- 目标 坐标   key是材料个数
local _desPosXTab = {0.85, 0.85}
local _desPosYTab = {0.57, 0.57}

-- 加号x坐标
local _addPosX = 0.32

-- 等号x坐标
local _equalPosX = {0.5, 0.67}

-- 物品刷新类型
local kRefreshEveryDay = 1
local kRefreshNever    = 2

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( pEvent )
    if ( pEvent == "enter" ) then
    elseif ( pEvent == "exit" ) then
       _bgLayer = nil
    end
end

--[[
    @des    : 兑换的回调
    @param  : pTag  兑换所需物品id
    @return : 
--]]
function convertAction( pTag )
    local tag = tonumber(pTag)
    -- 活动是否结束
    if( BTUtil:getSvrTimeInterval() < BlackshopData.getStartTime() or BTUtil:getSvrTimeInterval() >= BlackshopData.getEndTime() ) then
        AnimationTip.showTip(GetLocalizeStringBy("yr_1010"))
        return
    end
    -- 预留10秒刷新时间
    local curTime = TimeUtil.getSvrTimeByOffset(1)
    local transFormTime = os.date("*t", curTime)
    -- 当天的零点10秒禁止操作
    local zeroTime = curTime - transFormTime.sec - transFormTime.min*60 - transFormTime.hour*5600
    if ( curTime - zeroTime <= 10 ) then
        AnimationTip.showTip(GetLocalizeStringBy("yr_1012"))
        return
    end
    -- 背包是否有剩余空间
    require "script/ui/item/ItemUtil"
    if( ItemUtil.isBagFull() == true )then
        return
    end
    -- 是否已达到最大兑换次数限制
    local convertedTimes = BlackshopData.getConvertedTimes(tag)
    local maxConvertedTimes = BlackshopData.getMaxConvertTimes(tag)
    if ( tonumber(convertedTimes) >= tonumber(maxConvertedTimes) ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1009"))
        return
    end
    BlackshopChargeAlert.showConvertLayer(tag)
end

--[[
    @des    : 查看物品信息返回回调 为了显示下排按钮
    @param  : 
    @return : 
--]]
local function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, false)
end

--[[
    @des    : 得到物品的icon
    @param  : 
    @return : 物品的icon
--]]
function getItemIconByData( itemData, menu_priority, zOrderNum, info_layer_priority, isDesIcon )
    local iconSp        = nil
    local iconName      = nil
    local itemHaveNum   = nil
    local nameColor     = nil

    if (itemData.type == "silver") then
        -- 银币拥有的数量
        itemHaveNum = UserModel.getSilverNumber()
        -- 银币
        iconSp = ItemSprite.getSiliverIconSprite()
        iconName = GetLocalizeStringBy("key_1687")
        local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (itemData.type == "gold") then
        -- 金币拥有的数量
        itemHaveNum = UserModel.getGoldNumber()
        -- 金币
        iconSp = ItemSprite.getGoldIconSprite()
        iconName = GetLocalizeStringBy("key_1491")
        local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (itemData.type == "prestige") then
        -- 声望拥有值
        itemHaveNum = UserModel.getPrestigeNum()
        -- 声望
        iconSp = ItemSprite.getPrestigeSprite()
        iconName = GetLocalizeStringBy("key_2231")
        local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (itemData.type == "honor") then
        -- 荣誉拥有值
        itemHaveNum = UserModel.getHonorNum()
        -- 荣誉
        iconSp = ItemSprite.getHonorIconSprite()
        iconName = GetLocalizeStringBy("lic_1084")
        local quality = ItemSprite.getHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (itemData.type == "item") then
        -- 物品拥有的数量
        itemHaveNum = ItemUtil.getCacheItemNumByTidAndLv(tonumber(itemData.tid))
        -- 物品
        iconSp =  ItemSprite.getItemSpriteById(tonumber(itemData.tid), nil, showDownMenu, nil, menu_priority, zOrderNum, info_layer_priority)
        local itemData = ItemUtil.getItemById(tonumber(itemData.tid))
        iconName = itemData.name
        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
    else
        print("no this type: itemData.type ", itemData.type)
    end
    -- 物品数量
    local numStr    = nil
    local numColor  = nil

    if ( isDesIcon ) then
        numStr = itemData.num
        numColor = ccc3(0x00, 0xff, 0x18)
    else
        if ( itemData.type == "item" ) then
            numStr = itemHaveNum .. "/" .. itemData.num 
        else
            numStr = itemData.num
        end
        -- label文字颜色  如果满足兑换的条件 则为 绿色   不满足 则为 红色
        if ( tonumber(itemHaveNum) >= tonumber(itemData.num) ) then
            numColor = ccc3(0x00, 0xff, 0x18)
        else
            numColor = ccc3(0xff, 0x00, 0x00)
        end
    end
    local numberLabel =  CCRenderLabel:create(numStr, g_sFontPangWa, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    numberLabel:setAnchorPoint(ccp(1, 0))
    numberLabel:setColor(numColor)
    iconSp:addChild(numberLabel)
    if ( isDesIcon ) then
        numberLabel:setPosition(ccp(iconSp:getContentSize().width-5, 5))
    else
        numberLabel:setPosition(ccp(iconSp:getContentSize().width-5, 5))
    end
    -- 物品名字
    local iconNameLabel = CCRenderLabel:create(iconName, g_sFontPangWa, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    iconNameLabel:setColor(nameColor)
    iconNameLabel:setAnchorPoint(ccp(0.5, 1))
    iconNameLabel:setPosition(ccp(iconSp:getContentSize().width*0.5, -2))
    iconSp:addChild(iconNameLabel)

    return iconSp
end

--[[
    @des    : 创建ScrollView 中的cell
    @param  : pId  物品id  pCellData  兑换所需物品数组
    @return : cell
--]]
function createListCell( pId, pCellData )
    local pid = tonumber(pId)
    -- 兑换所需物品
    local reqItems = ItemUtil.getItemsDataByStr(pCellData.need_item)
    local reqCount = table.count( reqItems )
    -- Cell背景
    local fullRect = CCRectMake(0, 0, 116, 124)
    local insetRect = CCRectMake(52, 44, 6, 4)
    local cellBg = CCScale9Sprite:create(g_pathCommonImage .. "bg/change_bg.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(614, 203))
    -- 物品背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local goodsBg = CCScale9Sprite:create(g_pathCommonImage .. "bg/goods_bg.png",fullRect, insetRect)
    goodsBg:setContentSize(CCSizeMake(414, 150))
    goodsBg:setAnchorPoint(ccp(0.5, 0))
    goodsBg:setPosition(ccp(cellBg:getContentSize().width*0.4, 28))
    cellBg:addChild(goodsBg)
    -- 物品坐标
    local posX = _posXTab[reqCount]
    local posY = _posYTab[reqCount]
    for i=1,#reqItems do
        -- 图标
        local iconSprite = getItemIconByData( reqItems[i], -340, 1010, -420)
        iconSprite:setAnchorPoint(ccp(0.5, 0.5))
        iconSprite:setPosition(ccp(goodsBg:getContentSize().width*posX[i], goodsBg:getContentSize().height*posY[i]))
        goodsBg:addChild(iconSprite)
        -- 加号
        if (reqCount > 1) then
            local addSp = CCSprite:create(g_pathCommonImage .. "add_new.png")
            addSp:setAnchorPoint(ccp(0.5, 0.5))
            addSp:setPosition(ccp(goodsBg:getContentSize().width*_addPosX, goodsBg:getContentSize().height*0.57))
            addSp:setScale(0.8)
            goodsBg:addChild(addSp)
        end
    end
    -- 等号
    local equalSp = CCSprite:create("images/recharge/blackshop/denghao.png")
    equalSp:setAnchorPoint(ccp(0.5, 0.5))
    equalSp:setPosition(ccp(goodsBg:getContentSize().width*_equalPosX[reqCount], goodsBg:getContentSize().height*0.57))
    goodsBg:addChild(equalSp)
    -- 目标物品
    local itemData   = ItemUtil.getItemsDataByStr(pCellData.get_item)
    local iconSprite = getItemIconByData(itemData[1], -340, 1010, -420, true)
    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    iconSprite:setPosition(goodsBg:getContentSize().width*_desPosXTab[reqCount], goodsBg:getContentSize().height*_desPosYTab[reqCount])
    goodsBg:addChild(iconSprite)
    -- 按钮
    local menu = CCMenu:create()
    cellBg:addChild(menu)
    menu:setPosition(ccp(0, 0))
    local convertBtn = LuaCC.create9ScaleMenuItem(g_pathCommonImage .. "btn/btn_blue_n.png", g_pathCommonImage .. "btn/btn_blue_h.png", CCSizeMake(120, 73), GetLocalizeStringBy("yr_1008"), ccc3(0xfe, 0xdb, 0x1c), 30, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(convertBtn, 1, tonumber(pCellData.id))
    convertBtn:setAnchorPoint(ccp(0.5, 0.5))
    convertBtn:setPosition(ccp(cellBg:getContentSize().width*0.85, cellBg:getContentSize().height*0.62))
    convertBtn:registerScriptTapHandler(convertAction)
    -- kRefreshEveryDay=1 kRefreshNever=2
    local convertNumLabel = nil
    if BlackshopData.getRefreshTypeByGoodsId(pid) == kRefreshEveryDay then
        -- 每天刷新
        -- 已兑换次数Label
        convertNumLabel = CCLabelTTF:create(GetLocalizeStringBy("yr_1015"), g_sFontName, 18)
    elseif BlackshopData.getRefreshTypeByGoodsId(pid) == kRefreshNever then
        -- 活动内刷新
        -- 已兑换次数Label
        convertNumLabel = CCLabelTTF:create(GetLocalizeStringBy("yr_1007"), g_sFontName, 18)
    else
        -- 每天刷新
        -- 已兑换次数Label
        convertNumLabel = CCLabelTTF:create(GetLocalizeStringBy("yr_1015"), g_sFontName, 18)
    end
    convertNumLabel:setColor(ccc3(0x78, 0x25, 0x00))
    convertNumLabel:setAnchorPoint(ccp(0.5, 1))
    convertNumLabel:setPosition(cellBg:getContentSize().width*0.85, cellBg:getContentSize().height*0.42)
    cellBg:addChild(convertNumLabel)
    -- 兑换次数
    local haveNum = BlackshopData.getConvertedTimes( pid )
    local maxNum  = BlackshopData.getMaxConvertTimes( pid )
    local convertInfoLabel = CCLabelTTF:create("（" .. haveNum .. "/" .. maxNum .. "）", g_sFontName, 18)
    convertInfoLabel:setColor(ccc3(0x78, 0x25, 0x00))
    convertInfoLabel:setAnchorPoint(ccp(0.5, 1))
    convertInfoLabel:setPosition(convertNumLabel:getPositionX(), convertNumLabel:getPositionY() - convertInfoLabel:getContentSize().height - 5)
    cellBg:addChild(convertInfoLabel)
    if(tonumber(haveNum) == tonumber(maxNum))then
        convertBtn:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
        hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
        hasReceiveItem:setPosition(ccp(cellBg:getContentSize().width*0.85,cellBg:getContentSize().height*0.62))
        cellBg:addChild(hasReceiveItem) 
    end
    return cellBg
end

--[[
	@des    : 创建显示内容layer Container
	@param  : 
	@return : Container
--]]
function createContainerLayer()
    local containerLayer = CCNode:create()
    containerLayer:setContentSize(CCSizeMake(630,0))
    local cellHeight = 10
    -- 当前第几天配置
    local todayData = BlackshopData.getTodayData( BlackshopData.whichDay() )
    for i=#todayData,1,-1 do
        local cell = createListCell( todayData[i], BlackshopData.getConvertItemsInfo(todayData[i]) )
        cell:setAnchorPoint(ccp(0.5, 0))
        cell:setPosition(ccp(containerLayer:getContentSize().width*0.5, cellHeight))
        containerLayer:addChild(cell)
        -- 累积高度
        cellHeight = cellHeight+cell:getContentSize().height+10
    end
    -- 设置containerLayer的size
    containerLayer:setContentSize(CCSizeMake(630, cellHeight))
    return containerLayer
end

--[[
	@des    : 创建ScrollView
	@param  : 
	@return : 
--]]
function createScrollView()
	if(_listView ~= nil)then
        _listView:removeFromParentAndCleanup(true)
        _listView = nil
    end
    _listView = CCScrollView:create()
    _listView:setViewSize(CCSizeMake(_listWidth, _listHight/g_fScaleX-6))
    _listView:setBounceable(true)
    _listView:setTouchPriority(-345)
    -- 垂直方向滑动
    _listView:setDirection(kCCScrollViewDirectionVertical)
    _listView:setPosition(ccp(0, 3))
    _listBg:addChild(_listView)
    -- 创建显示内容layer Container
    local containerLayer = createContainerLayer()
    _listView:setContainer(containerLayer)
    _listView:setContentOffset(ccp(0, _listView:getViewSize().height-containerLayer:getContentSize().height))
end

--[[
    @des    : 0点刷新
    @param  : 
    @return : 
--]]
function refresh()
    if ( _bgLayer ~= nil ) then
        -- 重新创建列表
        local offset = nil
        if ( _listView ~= nil )then
            offset = _listView:getContentOffset()
        end
        -- 重新创建列表
        BlackshopService.getBlackshopInfo( function( pRetData )
            BlackshopData.setConvertedTimes( pRetData )
            -- 创建列表
            createScrollView()
        end )
        if ( offset ) then
            _listView:setContentOffset(offset)
        end
    end
end

--[[
    @des    : 刷新UI
    @param  : 
    @return : 
--]]
function refreshUI()
    if ( _bgLayer ~= nil ) then
        -- 重新创建列表
        local offset = nil
        if ( _listView ~= nil )then
            offset = _listView:getContentOffset()
        end
        -- 重新创建列表
        createScrollView()
        if ( offset ) then
            _listView:setContentOffset(offset)
        end
    end
end

--[[
	@des    : 创建UI
	@param  : 
	@return : 
--]]
function createUI()
    require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	-- 标题背景
	local _titleBg = CCScale9Sprite:create("images/recharge/blackshop/17.png") -- 640 400
    _titleBg:setAnchorPoint(ccp(0.5, 1))
    _titleBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height-topMenuHeight))
    _bgLayer:addChild(_titleBg)
    _titleBg:setScale(g_fScaleX)
    -- 黑市兑换 title
    local activityTitleSp = CCSprite:create("images/recharge/blackshop/heishiduihuan.png")
    activityTitleSp:setAnchorPoint(ccp(0.5, 1))
    activityTitleSp:setPosition(ccp(_titleBg:getContentSize().width*0.55, _titleBg:getContentSize().height+activityTitleSp:getContentSize().height*0.5))
    _titleBg:addChild(activityTitleSp)
    -- 活动说明
    require "script/libs/LuaCCLabel"
    local richInfo = {
            linespace = 2, -- 行间距
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
            labelDefaultFont = g_sFontPangWa,
            labelDefaultColor = ccc3(0xff, 0xf6, 0x00),
            labelDefaultSize = 24,
            defaultType = "CCRenderLabel",
            elements =
            {
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_1001"),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = true,
                    text = GetLocalizeStringBy("yr_1002"),
                    renderType = 2,-- 1 描边， 2 投影
                },
            }
        }
    local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
    richTextLayer:setAnchorPoint(ccp(0, 1))
    richTextLayer:setPosition(ccp(_titleBg:getContentSize().width*0.41, activityTitleSp:getPositionY()-activityTitleSp:getContentSize().height))
    _titleBg:addChild(richTextLayer)
    -- 活动时间     时间倒计时
    local beginTime = TimeUtil.getTimeFormatYMDHMS(ActivityConfig.ConfigCache.blackshop.start_time)
    local endTime = TimeUtil.getTimeFormatYMDHMS(ActivityConfig.ConfigCache.blackshop.end_time)
    local endTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_1006") .. beginTime .. "~" .. endTime, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    endTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    endTimeLabel:setAnchorPoint(ccp(0.5, 1))
    endTimeLabel:setPosition(ccp(_titleBg:getContentSize().width*0.5, richTextLayer:getPositionY()-richTextLayer:getContentSize().height-6))
    _titleBg:addChild(endTimeLabel)
    -- 列表背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(50,50,6,4)
    local titleBgShift = 0.38  -- 标题背景高的偏移量
    _listBg = CCScale9Sprite:create("images/recharge/change/list_bg.png", fullRect, insetRect)
    _listHight = _titleBg:getPositionY()-_titleBg:getContentSize().height*titleBgShift*g_fScaleX - (MenuLayer.getHeight()+25*g_fScaleX)
    _listWidth = 630
    _listBg:setContentSize(CCSizeMake(_listWidth, _listHight/g_fScaleX))
    _listBg:setAnchorPoint(ccp(0.5,1))
    _listBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _titleBg:getPositionY()-_titleBg:getContentSize().height*titleBgShift*g_fScaleX))
    _bgLayer:addChild(_listBg)
    _listBg:setScale(g_fScaleX)
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 返回主界面
--]]
function createLayer()
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
    --[[  TEST TIME
    local func = function( ... )
        print("===" .. TimeUtil.getTimeFormatYMDHMS(TimeUtil.getSvrTimeByOffset(0)))
    end
    schedule(_bgLayer,func,1)
    print("===|data|===")
    print_t(ActivityConfig.ConfigCache.blackshop.data)
    --]]
    -- 创建基础UI
    createUI()
    
    BlackshopService.getBlackshopInfo( function( pRetData )
        BlackshopData.setConvertedTimes( pRetData )
        -- 创建列表
        createScrollView()
    end )

	return _bgLayer
end
