-- FileName: ChangeItemShowLayer.lua 
-- Author: licong 
-- Date: 14-5-29 
-- Purpose: 兑换预览 


module("ChangeItemShowLayer", package.seeall)
require "script/ui/rechargeActive/ActiveCache"

local _bgLayer 				= nil
local _backGround			= nil 

local _itemsInfo 			= {}
local _itemsNames 			= {}
local _listHeight 			= nil
local _listBg  				= nil

local function init( ... )
	_bgLayer 				= nil
	_backGround				= nil
	_itemsInfo 				= {}
	_itemsNames 			= {}
	_listHeight 			= nil
	_listBg  				= nil
end

-- 查看物品信息返回回调 为了显示下排按钮
local function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, false)
end

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true   
end

-- 关闭按钮回调
local function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-433,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

-- 创建列表cell
local function createListCell( nameId, cellData )
    -- 物品个数
    local iconHeight = 135
    local itemCount = table.count(cellData)
    local cellHeight = math.ceil(itemCount/4)*iconHeight + 100
    -- 大背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(570,cellHeight))

    -- 二级背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local height = math.ceil(itemCount/4) * iconHeight+10
    local goodsBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    goodsBg:setContentSize(CCSizeMake(535,height))
    goodsBg:setAnchorPoint(ccp(0.5,0))
    goodsBg:setPosition(ccp(cellBg:getContentSize().width*0.5,45))
    cellBg:addChild(goodsBg)

    -- 名字
    local  descBg= CCScale9Sprite:create("images/digCowry/star_bg.png")
    -- descBg:setContentSize(CCSizeMake(200,171))
    descBg:setAnchorPoint(ccp(0,1))
    descBg:setPosition(ccp(3,cellBg:getContentSize().height))
    cellBg:addChild(descBg)
    local desStr =  _itemsNames[tonumber(nameId)]
    local desLabel = CCRenderLabel:create( desStr, g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    desLabel:setColor(ccc3(0xff,0xe4,0x00))
    desLabel:setAnchorPoint(ccp(0.5,0.5))
    desLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
    descBg:addChild(desLabel)

     for i=1,#cellData do
        -- 构造数据
        local goodsValues = {}
        goodsValues.type = "item"
        goodsValues.tid = cellData[i]
        goodsValues.num = 1

        -- 图标
        local iconSprite = ItemUtil.createGoodsIcon(goodsValues, -435, 1010, -450, showDownMenu )
        iconSprite:setAnchorPoint(ccp(0.5,1))
        local posX = {0.85,0.15,0.385,0.62}
        local yNum = math.ceil(i/4)-1
        local xNum = nil
        if(i <= 4 )then
        	xNum = i
        else
        	xNum = math.mod(i,4)+1
        end
        print("xNum,yNum",xNum,yNum)
        iconSprite:setPosition(ccp(goodsBg:getContentSize().width*posX[xNum],goodsBg:getContentSize().height-(10+iconHeight*yNum)))
        goodsBg:addChild(iconSprite)
    end

    return cellBg
end

-- 创建ContainerLayer
local function createContainerLayer( ... )
    local containerLayer = CCNode:create()
    containerLayer:setContentSize(CCSizeMake(580,0))
    local cellHeight = 10

    for k,v in pairs(_itemsInfo) do
        local cell = createListCell(v.nameKey,v.itemsTid)
        cell:setAnchorPoint(ccp(0.5,0))
        cell:setPosition(ccp(containerLayer:getContentSize().width*0.5,cellHeight))
        containerLayer:addChild(cell)
        -- 累积高度
        cellHeight = cellHeight+cell:getContentSize().height+10
    end
    -- 设置containerLayer的size
    containerLayer:setContentSize(CCSizeMake(580,cellHeight))
    return containerLayer
end

-- 创建scrollView
local function createScrollView( ... )
    -- scrollView
    local listView = CCScrollView:create()
    listView:setViewSize(CCSizeMake(580, _listHeight-6))
    listView:setBounceable(true)
    listView:setTouchPriority(-437)
    -- 垂直方向滑动
    listView:setDirection(kCCScrollViewDirectionVertical)
    listView:setPosition(ccp(0,3))
    _listBg:addChild(listView)
    -- 创建显示内容layer Container
    local containerLayer = createContainerLayer()
    listView:setContainer(containerLayer)
    listView:setContentOffset(ccp(0,listView:getViewSize().height-containerLayer:getContentSize().height))
end

-- 初始化界面
local function initLayer( ... )
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1001)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(618, 852))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1045"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-437)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 活动说明
	local titleFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1046"), g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_stroke)
    titleFont:setColor(ccc3(0x25,0x8b,0x23))
    titleFont:setAnchorPoint(ccp(0.5,0))
    titleFont:setPosition(ccp(_backGround:getContentSize().width*0.5,778))
    _backGround:addChild(titleFont)

    -- 活动说明内容
    local height = _backGround:getContentSize().height - 80
    local texts = string.split(ActivityConfig.ConfigCache.actExchange.data[1].act_des, "|")
    for i = 1, #texts do
        local text = texts[i]
        local text_label = CCLabelTTF:create(text, g_sFontName, 21)
        _backGround:addChild(text_label)
        text_label:setAnchorPoint(ccp(0, 1))
        text_label:setPosition(50, height)
        text_label:setColor(ccc3(0x78, 0x25, 0x00))
        local dimensions_width = 540
        text_label:setDimensions(CCSizeMake(dimensions_width, 0))
        text_label:setHorizontalAlignment(kCCTextAlignmentLeft)
        height = height - text_label:getContentSize().height - 5
    end

    -- 二级背景
    _listHeight = height - 50
    _listBg = BaseUI.createContentBg(CCSizeMake(580,_listHeight))
    _listBg:setAnchorPoint(ccp(0.5,1))
    _listBg:setPosition(ccp(_backGround:getContentSize().width*0.5,height))
    _backGround:addChild(_listBg)

    -- 创建列表
    createScrollView()
end




-- 显示兑换预览界面
function showChangeItemLayer( ... )
	init()
	-- 兑换物品大类 名字
	_itemsNames = ActiveCache.getChangeNames()
	-- print("121")
	-- print_t(_itemsNames)
	-- 兑换物品id
	_itemsInfo = ActiveCache.getChangeItemTid()
	-- print("122")
	-- print_t(_itemsInfo)

	initLayer()
end









































