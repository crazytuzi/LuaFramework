-- FileName: DevelopSoulLayer.lua 
-- Author: licong 
-- Date: 15/8/31 
-- Purpose: 战魂进阶界面


module("DevelopSoulLayer", package.seeall)

require "script/ui/huntSoul/developSoul/DevelopSoulController"
require "script/ui/huntSoul/HuntSoulData"

local _bgLayer 							= nil   
local _bgSprite  						= nil
local _topBg 							= nil
local _silverLabel 						= nil
local _goldLabel 						= nil
local _btnBgSprite 						= nil

local _srcItemId 						= nil
local _srcItemInfo 						= nil
local _isOnHero 						= false
local _disItemInfo 						= nil
local _materialData 					= nil
local _maskLayer 						= nil
local _showMark 						= nil

local _touchPriority 					= -230

-- 页面跳转tag
kTagBag 				= 100
kTagFormation 			= 101

--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 							= nil
	_bgSprite 							= nil
	_topBg 								= nil
	_silverLabel 						= nil
	_goldLabel 							= nil
	_btnBgSprite 						= nil

	_srcItemId 							= nil
	_srcItemInfo 						= nil
	_isOnHero 							= false
	_disItemInfo 						= nil
	_materialData 						= nil
	_maskLayer 							= nil
	_showMark 							= nil
end
---------------------------------------------------------------- 界面跳转记忆 --------------------------------------------------------------------
--[[
	@des 	:设置页面跳转记忆
	@param 	:p_mark:页面跳转mark
	@return :
--]]
function setLayerMark( p_mark )
  	_showMark = p_mark
end

--[[
	@des 	:得到页面跳转记忆
--]]
function getLayerMark()
  	return _showMark 
end

--[[
	@des 	:页面跳转记忆
	@param 	:
	@return :
--]]
function layerMark()
  	if(_showMark == kTagBag)then
  		-- 背包
  		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer("fightSoulBag")
		MainScene.changeLayer(layer,"HuntSoulLayer")
  	elseif(_showMark == kTagFormation)then
  		-- 阵容
  		require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer(_srcItemInfo.hid, false, false, false, 2)
        MainScene.changeLayer(formationLayer, "formationLayer")
  	else
  		-- 背包
  		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer("fightSoulBag")
		MainScene.changeLayer(layer,"HuntSoulLayer")
  	end
end
---------------------------------------------------------------- 按钮事件 --------------------------------------------------------------------

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
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	layerMark()
end

--[[
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function developMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 橙色进阶需要人物等级
	if( tonumber(_srcItemInfo.itemDesc.quality) >= 6 )then
		local needLv = HuntSoulData.getDevelopRedNeedLv()
		if( UserModel.getHeroLevel() < needLv )then
			require "script/ui/tip/AnimationTip"
	        AnimationTip.showTip(GetLocalizeStringBy("lic_1830",needLv))
			return
		end
	end

   	local nextCallBack = function ( p_retData )
   		-- 特效
		local successLayerSprite = XMLSprite:create("images/base/effect/hero/transfer/zhuangchang")
		successLayerSprite:setPosition(ccp((g_winSize.width-320*2*g_fElementScaleRatio)*0.5,g_winSize.height))
		successLayerSprite:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(successLayerSprite,9999)

	    local animationEnd = function()
	        successLayerSprite:removeFromParentAndCleanup(true)
	        successLayerSprite = nil
			-- 干掉屏蔽层
			if(_maskLayer ~= nil)then
				_maskLayer:removeFromParentAndCleanup(true)
				_maskLayer = nil
			end
	        -- 弹出成功界面
			require "script/ui/huntSoul/developSoul/SDevelopSuccessLayer"
			local attr = HuntSoulData.getFightSoulAttrByItem_id( nil, nil, p_retData )
			SDevelopSuccessLayer.showLayer(p_retData,attr, _showMark)
	    end
	    successLayerSprite:registerEndCallback( animationEnd )
   	end
   	
	local maskLayerCallBack = function ( ... )
		-- 添加特效屏蔽层
	    if(_maskLayer ~= nil)then
			_maskLayer:removeFromParentAndCleanup(true)
			_maskLayer = nil
		end
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		_maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
		runningScene:addChild(_maskLayer, 10000)
	end
   	DevelopSoulController.soulDevelopCallback( _srcItemInfo, _materialData, _isOnHero, nextCallBack, maskLayerCallBack )
end

---------------------------------------------------------------- 创建UI --------------------------------------------------------------------
-- 星星 最多6星
function getStarByQuality( num )
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(40*tonumber(num),32))
	for i=1,num do
		local sprite = CCSprite:create("images/common/star.png")
		sprite:setAnchorPoint(ccp(0,0))
		sprite:setPosition(ccp((i-1)*(sprite:getContentSize().width+10),0))
		node:addChild(sprite)
	end
	return node
end

--[[
	@des 	: 创建战魂信息
	@param 	: 
	@return : 
--]]
function createSoulSprite( p_itemInfo )
	-- local retSprite = CCLayerColor:create(ccc4(255,0,0,111))
	-- retSprite:ignoreAnchorPointForPosition(false) 
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(260,345))

	-- 战魂名字
	local nameColor = HeroPublicLua.getCCColorByStarLevel(p_itemInfo.itemDesc.quality)
	local soulNameFont = CCRenderLabel:create( p_itemInfo.itemDesc.name , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    soulNameFont:setColor(nameColor)
    soulNameFont:setAnchorPoint(ccp(0.5,0.5))
    soulNameFont:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-20))
    retSprite:addChild(soulNameFont)

	local iconBg = CCSprite:create("images/hunt/fsoul_bg.png")
	iconBg:setAnchorPoint(ccp(0.5,1))
	iconBg:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
	retSprite:addChild(iconBg)

	-- 战魂icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(p_itemInfo.item_template_id,p_itemInfo.va_item_text.fsLevel,true)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
	iconBg:addChild(iconSprite)

	-- 星星
	local starSprite = getStarByQuality(p_itemInfo.itemDesc.quality)
	starSprite:setAnchorPoint(ccp(0.5,0))
	starSprite:setPosition(ccp(iconBg:getContentSize().width*0.5,40))
	iconBg:addChild(starSprite)

	-- 类型
    local leixingFont = CCRenderLabel:create( GetLocalizeStringBy("key_2519") , g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixingFont:setColor(ccc3(0x00,0xff,0x18))
    leixingFont:setAnchorPoint(ccp(1,0.5))
    leixingFont:setPosition(ccp(70,retSprite:getContentSize().height-250))
    retSprite:addChild(leixingFont)
 	local leixingDes = CCRenderLabel:create(p_itemInfo.itemDesc.info, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixingDes:setColor(ccc3(0xff,0xff,0xff))
    leixingDes:setAnchorPoint(ccp(0,0.5))
    leixingDes:setPosition(ccp(leixingFont:getPositionX()+15,leixingFont:getPositionY()))
    retSprite:addChild(leixingDes)

    -- 属性
    local attrFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1641") , g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attrFont:setColor(ccc3(0x00,0xff,0x18))
    attrFont:setAnchorPoint(ccp(1,0.5))
    attrFont:setPosition(ccp(70,leixingFont:getPositionY()-40))
    retSprite:addChild(attrFont)
    local attrData = HuntSoulData.getFightSoulAttrByItem_id( nil, nil, p_itemInfo )
	local index = 0
	for k,v in pairs(attrData) do
		local displayName = v.desc.displayName
		local displayNum = v.displayNum
		index = index + 1
	    local attr_font = CCRenderLabel:create(displayName .. "+" .. displayNum , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    attr_font:setColor(ccc3(0x00,0xff,0x18))
	    attr_font:setAnchorPoint(ccp(0,0.5))
	    attr_font:setPosition(ccp(attrFont:getPositionX()+15,leixingFont:getPositionY()-index*40))
	    retSprite:addChild(attr_font,2)
	end

	return retSprite
end

--[[
	@des 	: 创建上边UI
	@param 	: 
	@return : 
--]]
function createTopUI()
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    bulletinLayerSize = BulletinLayer.getLayerContentSize()

    -- 上标题栏 显示战斗力，银币，金币
	_topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
	_topBg:setAnchorPoint(ccp(0,1))
	_topBg:setPosition(ccp(0, _bgLayer:getContentSize().height-bulletinLayerSize.height*g_fScaleX))
	_bgLayer:addChild(_topBg,10)
	_topBg:setScale(g_fScaleX)
	
	-- 战斗力
	local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    local powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue(), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(powerDescLabel)

	-- 银币
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)  -- modified by yangrui at 2015-12-03
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(390, 10))
	_topBg:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 10))
	_topBg:addChild(_goldLabel)

	--按钮背景
    local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	_btnBgSprite = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_btnBgSprite:setPreferredSize(CCSizeMake(640, 100))
	_btnBgSprite:setAnchorPoint(ccp(0.5, 1))
	_btnBgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height-_topBg:getContentSize().height*g_fScaleX-bulletinLayerSize.height*g_fScaleX))
	_bgLayer:addChild(_btnBgSprite,10)
	_btnBgSprite:setScale(g_fScaleX)

	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(_touchPriority-5)
	menuBar:setPosition(ccp(0, 0))
	_btnBgSprite:addChild(menuBar)
	-- 进阶战魂
	local developBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1640"))
	developBtn:setAnchorPoint(ccp(0, 0))
	developBtn:setPosition(ccp(_btnBgSprite:getContentSize().width*0.01, _btnBgSprite:getContentSize().height*0.1))
	menuBar:addChild(developBtn)
	-- 禁用按钮
	developBtn:setEnabled(false)
	developBtn:selected()

   	-- 返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeMenuItemCallBack)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnBgSprite:getContentSize().width-20,_btnBgSprite:getContentSize().height*0.5))
	menuBar:addChild(closeMenuItem)

end

--[[
	@des 	: 创建上边UI
	@param 	: 
	@return : 
--]]
function createMiddleUI()
	-- 源战魂
	local srcSprite = createSoulSprite(_srcItemInfo)
	srcSprite:setAnchorPoint(ccp(0.5,0.5))
	srcSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.2,_bgLayer:getContentSize().height*0.62))
	_bgLayer:addChild(srcSprite)
	srcSprite:setScale(g_fElementScaleRatio)

	-- 新战魂
	local disSprite = createSoulSprite(_disItemInfo)
	disSprite:setAnchorPoint(ccp(0.5,0.5))
	disSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.77,_bgLayer:getContentSize().height*0.62))
	_bgLayer:addChild(disSprite)
	disSprite:setScale(g_fElementScaleRatio)

	--箭头
	local arrowSp = CCSprite:create("images/hero/transfer/arrow.png")
	arrowSp:setAnchorPoint(ccp(0.5,0.5))
	arrowSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.62))
	_bgLayer:addChild(arrowSp)
	arrowSp:setScale(g_fElementScaleRatio)

end

--[[
	@des 	:创建材料列表
	@param 	:p_data 材料数据
--]]
function createListCell( p_data )
	local cell = CCTableViewCell:create()
	local iconBg = ItemUtil.createGoodsIcon(p_data, _touchPriority-1, nil, _touchPriority-200, nil,nil,nil,nil,false)
	iconBg:setAnchorPoint(ccp(0,1))
	iconBg:setPosition(ccp(18,120))
	cell:addChild(iconBg)

	local haveNum = nil
	local showStr = nil
	if( p_data.type == "silver")then
		haveNum = UserModel.getSilverNumber()
		showStr = string.convertSilverUtilByInternational(p_data.num)  -- modified by yangrui at 2015-12-03
	else
		haveNum = ItemUtil.getCacheItemNumBy(p_data.tid)
		showStr = haveNum .. "/" .. p_data.num
	end

	local labelColor = nil
	if(haveNum >= p_data.num)then
	 	labelColor = ccc3(0x00,0xff,0x18) 
	else
		labelColor = ccc3(0xff,0x00,0x00)
	end

	local numLabel = CCRenderLabel:create(showStr, g_sFontName, 18, 1 , ccc3(0x00,0x00,0x00), type_shadow)
	numLabel:setColor(labelColor)
	numLabel:setAnchorPoint(ccp(0.5,0))
	numLabel:setPosition(iconBg:getContentSize().width*0.5, 2)
	iconBg:addChild(numLabel)

	return cell
end 

--[[
	@des 	: 创建上边UI
	@param 	: 
	@return : 
--]]
function createBottomUI()
	-- 材料框
	-- _bottomBg = CCLayerColor:create(ccc4(255,0,0,111))
	-- _bottomBg:ignoreAnchorPointForPosition(false) 
	_bottomBg = CCSprite:create()
	_bottomBg:setContentSize(CCSizeMake(640,155))
	_bottomBg:setAnchorPoint(ccp(0.5,0.5))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.35))
	_bgLayer:addChild(_bottomBg)
	_bottomBg:setScale(g_fScaleX)

	-- up
	local upSprite = CCSprite:create("images/hunt/up_line.png")
	upSprite:setAnchorPoint(ccp(0.5,1))
	upSprite:setPosition(ccp(_bottomBg:getContentSize().width*0.5,_bottomBg:getContentSize().height))
	_bottomBg:addChild(upSprite,10)
	-- down
	local downSprite = CCSprite:create("images/hunt/down_line.png")
	downSprite:setAnchorPoint(ccp(0.5,0))
	downSprite:setPosition(ccp(_bottomBg:getContentSize().width*0.5,0))
	_bottomBg:addChild(downSprite,10)

	-- 进阶按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-2) 
    _bgLayer:addChild(menuBar)

	-- 创建进阶按钮 
	local developMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73), GetLocalizeStringBy("lic_1642"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	developMenuItem:setAnchorPoint(ccp(0.5, 0))
	developMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().width*0.23 ))
	menuBar:addChild(developMenuItem)
	developMenuItem:registerScriptTapHandler(developMenuItemCallBack)
	developMenuItem:setScale(g_fElementScaleRatio)

	-- 材料列表
	_materialData = DevelopSoulData.getSoulDevelopCostData( _srcItemInfo.item_template_id )
	if( table.isEmpty(_materialData) )then
		return
	end
	local cellSize = CCSizeMake(101, 120)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = createListCell(_materialData[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_materialData
			r = num
		else
		end
		return r
	end)
	local listTableView = LuaTableView:createWithHandler(h, CCSizeMake(600, 120))
	listTableView:setBounceable(true)
	listTableView:setTouchEnabled(false)
	listTableView:setTouchEnabled(true)
	listTableView:setDirection(kCCScrollViewDirectionHorizontal)
	listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	listTableView:ignoreAnchorPointForPosition(false)
	listTableView:setAnchorPoint(ccp(0.5,0.5))
	listTableView:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.5))
	_bottomBg:addChild(listTableView)
	listTableView:setTouchPriority(_touchPriority-2)
end

--[[
	@des 	: 显示主界面
	@param 	: p_itemId 
	@return : 
--]]
function createLayer( p_itemId )
	-- 初始化
	init()

	-- 源战魂数据
	_srcItemId = p_itemId
	_srcItemInfo = ItemUtil.getItemByItemId(_srcItemId)
	if(_srcItemInfo == nil)then
		_srcItemInfo = ItemUtil.getFightSoulInfoFromHeroByItemId(_srcItemId)
		_isOnHero = true
	end

	-- 进阶后战魂数据
	_disItemInfo = DevelopSoulData.getSoulDevelopExpectData( _srcItemInfo )

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 隐藏按钮
	MainScene.setMainSceneViewsVisible(true, false, true)

	-- 大背景
    _bgSprite = CCSprite:create("images/hunt/jing_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 创建上部分
    createTopUI()

    -- 创建中间部分
    createMiddleUI()
  
    -- 创建下部分
    createBottomUI()

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: p_itemId 
	@return : 
--]]
function showLayer( p_itemId )
	local layer = createLayer(p_itemId)
	MainScene.changeLayer(layer, "DevelopSoulLayer")
end









