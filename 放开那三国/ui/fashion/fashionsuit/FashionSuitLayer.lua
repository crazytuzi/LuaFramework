-- FileName: FashionSuitLayer.lua 
-- Author: licong 
-- Date: 15/8/4 
-- Purpose: 时装套装界面 


module("FashionSuitLayer", package.seeall)

require "script/model/utils/HeroUtil"
require "script/ui/fashion/fashionsuit/FashionSuitData"

local _bgLayer  					= nil
local _bgSprite 					= nil
local _bulletSize 					= nil
local _topSprite 					= nil
local _middleTabView 				= nil
local _bottomBg 					= nil
local _leftArrowSp 					= nil
local _rightArrowSp 				= nil

local _touchPriority 				= -300

--[[
	@des 	: 初始化
	@param 	: 
	@return :
--]]
function init( ... )
	_bgLayer  						= nil
	_bgSprite 						= nil
	_bulletSize 					= nil
	_topSprite 						= nil
	_middleTabView 					= nil
	_bottomBg 						= nil
	_leftArrowSp 					= nil
	_rightArrowSp 					= nil
end
---------------------------------------------------------------------------- 按钮事件 -------------------------------------------------------------------------
--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
	elseif (event == "exit") then
	end
end

--[[
	@des 	: 返回按钮回调
	@param 	: 
	@return :
--]]
function backCallback( ... )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/fashion/FashionLayer"
    local mark = FashionLayer.getMark()
    local fashionLayer = FashionLayer:createFashion()
    MainScene.changeLayer(fashionLayer, "FashionLayer")
    FashionLayer.setMark(mark)
end
---------------------------------------------------------------------------- 创建UI -------------------------------------------------------------------------
--[[
	@des 	: 创建下部分界面
	@param 	: 
	@return :
--]]
function createBottomUI()
	-- 背景
	_bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
	_bottomBg:setContentSize(CCSizeMake(544,142))
	_bottomBg:setAnchorPoint(ccp(0.5,0))
	_bottomBg:setPosition(_bgLayer:getContentSize().width/2, MenuLayer.getHeight()+20*g_fElementScaleRatio)
	_bgLayer:addChild(_bottomBg)
	_bottomBg:setScale(g_fElementScaleRatio)

	-- 标题
	local titleFontBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleFontBg:setContentSize(CCSizeMake(200,40))
	titleFontBg:setAnchorPoint(ccp(0.5,0.5))
	titleFontBg:setPosition(_bottomBg:getContentSize().width/2, _bottomBg:getContentSize().height)
	_bottomBg:addChild(titleFontBg)

	--	标题文字
	local titleFont= CCLabelTTF:create(GetLocalizeStringBy("lic_1627"), g_sFontPangWa, 24)
	titleFont:setColor(ccc3(0xff,0xf6,0x00))
	titleFont:setPosition(titleFontBg:getContentSize().width/2, titleFontBg:getContentSize().height/2)
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFontBg:addChild(titleFont)

	-- scrollView
	local viewSize = CCSizeMake(540,115)
	local scroll = CCScrollView:create()
	scroll:setViewSize(viewSize)
	scroll:setDirection(kCCScrollViewDirectionVertical)
	scroll:setTouchPriority(_touchPriority-1)
	scroll:setBounceable(true)
	scroll:ignoreAnchorPointForPosition(false)
	scroll:setAnchorPoint(ccp(0.5,0))
	scroll:setPosition(ccp(_bottomBg:getContentSize().width*0.5, 5))
	_bottomBg:addChild(scroll)

	-- 计算containerLayer的size
	local containerHight = 0
	-- 当前属性
	local haveAttrTab = FashionSuitData.getHaveActivateSuitAttr()
	containerHight = containerHight + math.ceil(table.count(haveAttrTab)/2) *30 + 10

	-- containerLayer
	local containerLayer = CCLayer:create()
	containerLayer:setContentSize(CCSizeMake(viewSize.width,containerHight))
	scroll:setContainer(containerLayer)
	scroll:setContentOffset(ccp(0,scroll:getViewSize().height-containerLayer:getContentSize().height))
	
	local i = 0
	local posX = {160,420}
	local posY = containerHight
	for attr_id,attr_value in pairs(haveAttrTab) do
		i = i + 1
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
		local attrNameLabel = CCRenderLabel:create(affixInfo.sigleName .. "：", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		containerLayer:addChild(attrNameLabel)

		if(i%2 == 1)then
   			posY = posY - 30
   			attrNameLabel:setPosition(ccp(posX[1],posY))
   		else
   			attrNameLabel:setPosition(ccp(posX[2],posY))
   		end

		local attrNumLabel = CCRenderLabel:create( showNum,g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+5,attrNameLabel:getPositionY()))
		containerLayer:addChild(attrNumLabel)
	end
end

--[[
	@des 	: 创建中间界面
	@param 	: 
	@return :
--]]
function createMiddleUI()
	require "script/ui/fashion/fashionsuit/FashionSuitCell"

	local num = FashionSuitData.getSuitAllNum()

	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return CCSizeMake(640,490)
		elseif functionName == "cellAtIndex" then
			return FashionSuitCell.createCell(index)
		elseif functionName == "numberOfCells" then
			return num
		elseif functionName == "cellTouched" then
			
		elseif functionName == "scroll" then
			
		elseif functionName == "moveEnd" then
			-- 箭头
			if(index == 1)then 
				_leftArrowSp:setVisible(false)
				_rightArrowSp:setVisible(true)
			elseif(index == num)then 
				_leftArrowSp:setVisible(true)
				_rightArrowSp:setVisible(false)
			else
				_leftArrowSp:setVisible(true)
				_rightArrowSp:setVisible(true)
			end
		end
	end
	-- 中间tabView
    _middleTabView = STTableView:create()
    _middleTabView:setDirection(kCCScrollViewDirectionHorizontal)
    _middleTabView:setContentSize(CCSizeMake(640,490))
	_middleTabView:setEventHandler(eventHandler)
	_middleTabView:setPageViewEnabled(true)
	_middleTabView:setTouchPriority(_touchPriority - 10)
	_middleTabView:ignoreAnchorPointForPosition(false)
	_middleTabView:setAnchorPoint(ccp(0.5,0.5))
	_middleTabView:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.58))
	_bgLayer:addChild(_middleTabView)
	_middleTabView:reloadData()
	_middleTabView:setScale(g_fElementScaleRatio)

	-- 箭头
    -- 左箭头
    _leftArrowSp = CCSprite:create( "images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(10*g_fElementScaleRatio,_bgLayer:getContentSize().height*0.45)
    _bgLayer:addChild(_leftArrowSp,10)
    _leftArrowSp:setVisible(false)
    _leftArrowSp:setScale(g_fElementScaleRatio)

    -- 右箭头
    _rightArrowSp = CCSprite:create( "images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(_bgLayer:getContentSize().width-10*g_fElementScaleRatio,_bgLayer:getContentSize().height*0.45)
    _bgLayer:addChild(_rightArrowSp,10)
    _rightArrowSp:setVisible(true)
    _rightArrowSp:setScale(g_fElementScaleRatio)

end

--[[
	@des 	: 创建套装界面
	@param 	: 
	@return :
--]]
function createLayer()
	-- 初始化
	init()

	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    _bulletSize = BulletinLayer.getLayerContentSize()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

	MainScene.setMainSceneViewsVisible(true, false, true)

	-- 大背景
    _bgSprite = CCScale9Sprite:create("images/recharge/mystery_merchant/bg.png",CCRectMake(0, 0, 55, 50),CCRectMake(26, 30, 6, 4))
    _bgSprite:setContentSize(CCSizeMake(640, 960))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 上边
    _topSprite = HeroUtil.createNewAttrBgSprite(UserModel.getHeroLevel(),UserModel.getUserName(),UserModel.getVipLevel(),UserModel.getSilverNumber(),UserModel.getGoldNumber())
    _topSprite:setAnchorPoint(ccp(0.5,1))
    _topSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height -_bulletSize.height*g_fScaleX))
    _bgLayer:addChild(_topSprite)
    _topSprite:setScale(g_fScaleX)

    -- 花纹
    local huaSp = CCSprite:create("images/recharge/mystery_merchant/border.png")
    huaSp:setAnchorPoint(ccp(0.5,0))
    huaSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_topSprite:getPositionY()-_topSprite:getContentSize().height*g_fScaleX))
    _bgLayer:addChild(huaSp)
    huaSp:setRotation(180)
    huaSp:setScale(g_fScaleX)

    -- 时装图鉴
    local titleSp = CCSprite:create("images/fashion/fashionsuit/title.png")
    titleSp:setAnchorPoint(ccp(0.5,0))
    titleSp:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.84)
    _bgLayer:addChild(titleSp)
    titleSp:setScale(g_fElementScaleRatio)

    -- 返回按钮
    local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(menuBar)
	menuBar:setTouchPriority(_touchPriority - 10)

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	backItem:setAnchorPoint(ccp(1,0))
    backItem:setPosition(_bgLayer:getContentSize().width - 10 * g_fElementScaleRatio, _bgLayer:getContentSize().height*0.83)
    backItem:registerScriptTapHandler(backCallback)
	menuBar:addChild(backItem)
	backItem:setScale(g_fElementScaleRatio)

	-- 创建中间UI
	createMiddleUI()

	-- 创建底部UI
	createBottomUI()

    return _bgLayer
end


--[[
	@des 	: 显示套装界面
	@param 	: 
	@return :
--]]
function showLayer()
	local layer = createLayer()
	MainScene.changeLayer(layer, "FashionSuitLayer")
end



