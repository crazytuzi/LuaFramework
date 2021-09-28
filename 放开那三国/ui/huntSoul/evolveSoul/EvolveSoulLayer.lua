-- FileName: EvolveSoulLayer.lua 
-- Author: licong 
-- Date: 15/8/31 
-- Purpose: 战魂精炼界面


module("EvolveSoulLayer", package.seeall)

require "script/ui/huntSoul/evolveSoul/EvolveSoulController"
require "script/ui/huntSoul/HuntSoulData"

local _bgLayer 							= nil   
local _bgSprite  						= nil
local _topBg 							= nil
local _silverLabel 						= nil
local _goldLabel 						= nil
local _btnBgSprite 						= nil
local _srcSprite						= nil
local _disSprite 						= nil
local _listTableView 					= nil

local _srcItemId 						= nil
local _srcItemInfo 						= nil
local _isOnHero 						= false
local _materialData 					= nil
local _curEvolveLv 						= nil
local _nextEvolveLv 					= nil
local _maxEvolveLv 						= nil

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
	_srcSprite 							= nil
	_disSprite 							= nil
	_listTableView 						= nil

	_srcItemId 							= nil
	_srcItemInfo 						= nil
	_isOnHero 							= false
	_materialData 						= nil
	_curEvolveLv 						= nil
	_nextEvolveLv 						= nil
	_maxEvolveLv 						= nil

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
function evolveMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

   	local nextCallBack = function ( p_retData )
   		-- 修改当前数据
   		_curEvolveLv = _nextEvolveLv
   		_nextEvolveLv = _curEvolveLv + 1

   		-- 三个特效
   		local successLayerSprite1 = XMLSprite:create("images/hunt/effect/jinglianZH_xi/jinglianZH_xi")
		successLayerSprite1:setPosition(ccp(_disSprite:getContentSize().width*0.5,_disSprite:getContentSize().height-95))
	    _disSprite:addChild(successLayerSprite1,9999)
	    successLayerSprite1:setReplayTimes( 1, true )
	    local animationEnd1 = function()
			-- 第二个特效
	   		local successLayerSprite2 = XMLSprite:create("images/hunt/effect/jinglianZH_bao/jinglianZH_bao")
			successLayerSprite2:setPosition(ccp(_srcSprite:getContentSize().width*0.5,_srcSprite:getContentSize().height-95))
		    _srcSprite:addChild(successLayerSprite2,9999)
		    successLayerSprite2:setReplayTimes( 1, true )
		    local animationEnd2 = function()
		    	-- 刷新UI
				refreshAll()
				-- 第三个特效
				local successLayerSprite3 = XMLSprite:create("images/treasure/evolve/jianlianchenggong/jianlianchenggong")
				successLayerSprite3:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
			    _bgLayer:addChild(successLayerSprite3,9999)
			    successLayerSprite3:setScale(g_fElementScaleRatio)
			    successLayerSprite3:setReplayTimes( 1, true )
			    local animationEnd3 = function()
					-- 干掉屏蔽层
					if(_maskLayer ~= nil)then
						_maskLayer:removeFromParentAndCleanup(true)
						_maskLayer = nil
					end
			    end
			    successLayerSprite3:registerEndCallback( animationEnd3 )
		    end
		    successLayerSprite2:registerKeyFrameCallback( animationEnd2 )
	    end
	    successLayerSprite1:registerKeyFrameCallback( animationEnd1 )
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
   	EvolveSoulController.soulEvolveCallback( _srcItemInfo, _materialData, _isOnHero, nextCallBack, maskLayerCallBack )
end

---------------------------------------------------------------- 创建UI --------------------------------------------------------------------
--[[
	@des 	: 创建精炼等级
	@param 	: 
	@return : 
--]]
function createEvolveGemPanel( p_curLv,p_maxLv )
	local row = math.floor(10/5)
	-- local gemPanle = CCScale9Sprite:create("images/hero/transfer/bg_ng_orange.png")
	local gemPanle = CCSprite:create()
	gemPanle:setContentSize(CCSizeMake(230, row * 40))
	for i=1, 10 do
		local sprite = nil
		if(i <= tonumber(p_curLv)%10)then
			sprite 	= EvolveSoulData.getEvolveLvSprite(p_curLv)
		else
			sprite 	= CCSprite:create("images/common/fs_jbg.png")
		end

		if math.floor(tonumber(p_curLv)/10) >= 1 and tonumber(p_curLv)%10==0  then
			sprite 	= EvolveSoulData.getEvolveLvSprite(p_curLv)
		end

		sprite:setAnchorPoint(ccp(0.5, 0.5))
		local dis = gemPanle:getContentSize().width/5
		local x = dis/2 + dis * ((i-1)%5)
		local y = gemPanle:getContentSize().height + 30/2 - (math.floor((i-1)/5) + 1)*40
		sprite:setPosition(ccp(x , y))
		gemPanle:addChild(sprite)
	end
	return gemPanle
end

--[[
	@des 	: 刷新UI
	@param 	: 
	@return : 
--]]
function refreshAll()
	if( not tolua.isnull(_srcSprite) )then 
		_srcSprite:removeFromParentAndCleanup(true)
		_srcSprite = nil
	end
	-- 源战魂
	_srcSprite = createSoulSprite(_srcItemInfo, _curEvolveLv )
	_srcSprite:setAnchorPoint(ccp(0.5,0.5))
	_srcSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.2,_bgLayer:getContentSize().height*0.61))
	_bgLayer:addChild(_srcSprite)
	_srcSprite:setScale(g_fElementScaleRatio)

	if( not tolua.isnull(_disSprite) )then 
		_disSprite:removeFromParentAndCleanup(true)
		_disSprite = nil
	end

	if( _curEvolveLv < _maxEvolveLv )then  
		-- 新战魂
		_disSprite = createSoulSprite(_srcItemInfo, _nextEvolveLv,true )
		_disSprite:setAnchorPoint(ccp(0.5,0.5))
		_disSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.77,_bgLayer:getContentSize().height*0.61))
		_bgLayer:addChild(_disSprite)
		_disSprite:setScale(g_fElementScaleRatio)
	end

	-- 刷新材料
	_materialData = EvolveSoulData.getSoulEvolveCostData( _srcItemInfo.item_template_id, _nextEvolveLv )
	if( table.isEmpty(_materialData) )then
		_materialData = {}
	end
	_listTableView:reloadData()
end

--[[
	@des 	: 创建战魂信息
	@param 	: 
	@return : 
--]]
function createSoulSprite( p_itemInfo, p_curLv, p_isRight )
	-- local retSprite = CCLayerColor:create(ccc4(255,0,0,111))
	-- retSprite:ignoreAnchorPointForPosition(false) 
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(260,345))

	local color = ccc3(0xff,0xff,0xff)
	if(p_isRight)then
		color = ccc3(0x00,0xff,0x18)
	end

	-- 战魂名字
	local nameColor = HeroPublicLua.getCCColorByStarLevel(p_itemInfo.itemDesc.quality)
	local soulNameFont = CCRenderLabel:create( p_itemInfo.itemDesc.name , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    soulNameFont:setColor(nameColor)
    soulNameFont:setAnchorPoint(ccp(0.5,0.5))
    soulNameFont:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-20))
    retSprite:addChild(soulNameFont)

	local iconBg = CCSprite:create("images/hunt/fsoul_bg.png")
	iconBg:setAnchorPoint(ccp(0.5,0.5))
	iconBg:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-95))
	retSprite:addChild(iconBg)

	-- 战魂icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(p_itemInfo.item_template_id,p_itemInfo.va_item_text.fsLevel,true)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
	iconBg:addChild(iconSprite)

	-- 精炼等级星星
	local evolveSprite = createEvolveGemPanel( p_curLv, _maxEvolveLv )
	evolveSprite:setAnchorPoint(ccp(0.5,1))
	evolveSprite:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-150))
	retSprite:addChild(evolveSprite)

    -- 属性
    local attrFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1641") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attrFont:setColor(ccc3(0xff,0x96,0x00))
    attrFont:setAnchorPoint(ccp(0,0))
    attrFont:setPosition(ccp(20,evolveSprite:getPositionY()-evolveSprite:getContentSize().height-30))
    retSprite:addChild(attrFont)
    -- print("==>1")
    -- print_t(p_itemInfo)
    local attrData = HuntSoulData.getFightSoulAttrByItem_id( nil, nil, p_itemInfo )
    -- print_t(attrData)
	local index = 0
	local posY = 0
	for k,v in pairs(attrData) do
		local displayName = v.desc.displayName
		local displayNum = v.displayNum
		index = index + 1
	    local attr_font = CCRenderLabel:create(displayName .. "+" .. displayNum , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    attr_font:setColor(color)
	    attr_font:setAnchorPoint(ccp(0,0))
	    attr_font:setPosition(ccp(attrFont:getPositionX()+attrFont:getContentSize().width,attrFont:getPositionY()-index*25))
	    retSprite:addChild(attr_font,2)
	    posY = attr_font:getPositionY()
	end

	-- 精炼属性
    local jinglianFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1650") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    jinglianFont:setColor(ccc3(0xff,0x96,0x00))
    jinglianFont:setAnchorPoint(ccp(0,0))
    jinglianFont:setPosition(ccp(20,posY-25))
    retSprite:addChild(jinglianFont)
    local num = EvolveSoulData.getEvolveAttrByItemInfo( p_itemInfo.item_template_id, p_curLv )
 	local leixingDes = CCRenderLabel:create(GetLocalizeStringBy("lic_1649",num), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixingDes:setColor(color)
    leixingDes:setAnchorPoint(ccp(0,1))
    leixingDes:setPosition(ccp(attrFont:getPositionX()+attrFont:getContentSize().width,jinglianFont:getPositionY()-3))
    retSprite:addChild(leixingDes)

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
	-- 精炼战魂
	local evolveBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1647") )
	evolveBtn:setAnchorPoint(ccp(0, 0))
	evolveBtn:setPosition(ccp(_btnBgSprite:getContentSize().width*0.01, _btnBgSprite:getContentSize().height*0.1))
	menuBar:addChild(evolveBtn)
	-- 禁用按钮
	evolveBtn:setEnabled(false)
	evolveBtn:selected()

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
	_srcSprite = createSoulSprite(_srcItemInfo, _curEvolveLv )
	_srcSprite:setAnchorPoint(ccp(0.5,0.5))
	_srcSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.2,_bgLayer:getContentSize().height*0.61))
	_bgLayer:addChild(_srcSprite)
	_srcSprite:setScale(g_fElementScaleRatio)

	-- 新战魂
	if( _curEvolveLv < _maxEvolveLv )then  
		_disSprite = createSoulSprite(_srcItemInfo, _nextEvolveLv,true )
		_disSprite:setAnchorPoint(ccp(0.5,0.5))
		_disSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.77,_bgLayer:getContentSize().height*0.61))
		_bgLayer:addChild(_disSprite)
		_disSprite:setScale(g_fElementScaleRatio)
	end

	--箭头
	local arrowSp = CCSprite:create("images/hero/transfer/arrow.png")
	arrowSp:setAnchorPoint(ccp(0.5,0.5))
	arrowSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.61))
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
		showStr = p_data.num
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
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.32))
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

	-- 精炼按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-2) 
    _bgLayer:addChild(menuBar)

	-- 创建精炼按钮 
	local evolveMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73), GetLocalizeStringBy("lic_1648"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	evolveMenuItem:setAnchorPoint(ccp(0.5, 0))
	evolveMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().width*0.2 ))
	menuBar:addChild(evolveMenuItem)
	evolveMenuItem:registerScriptTapHandler(evolveMenuItemCallBack)
	evolveMenuItem:setScale(g_fElementScaleRatio)

	-- 材料列表
	_materialData = EvolveSoulData.getSoulEvolveCostData( _srcItemInfo.item_template_id, _nextEvolveLv )
	-- print("_materialData++")
	-- print_t(_materialData)
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
	_listTableView = LuaTableView:createWithHandler(h, CCSizeMake(600, 120))
	_listTableView:setBounceable(true)
	_listTableView:setTouchEnabled(false)
	_listTableView:setTouchEnabled(true)
	_listTableView:setDirection(kCCScrollViewDirectionHorizontal)
	_listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_listTableView:ignoreAnchorPointForPosition(false)
	_listTableView:setAnchorPoint(ccp(0.5,0.5))
	_listTableView:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.5))
	_bottomBg:addChild(_listTableView)
	_listTableView:setTouchPriority(_touchPriority-2)
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
	-- 当前洗练等级
	if( not table.isEmpty(_srcItemInfo.va_item_text) and _srcItemInfo.va_item_text.fsEvolve )then
		_curEvolveLv = tonumber(_srcItemInfo.va_item_text.fsEvolve)
	else
		_curEvolveLv = 0
	end
	-- 下一洗练等级
	_nextEvolveLv = _curEvolveLv + 1
	-- 最大洗练等级
	_maxEvolveLv = EvolveSoulData.getSoulEvolveMaxLvByTid( _srcItemInfo.item_template_id )

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
	MainScene.changeLayer(layer, "EvolveSoulLayer")
end









