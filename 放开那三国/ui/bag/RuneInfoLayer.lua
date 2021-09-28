-- FileName: RuneInfoLayer.lua 
-- Author: licong 
-- Date: 15/5/5 
-- Purpose: 符印详细信息界面 


module("RuneInfoLayer", package.seeall)
require "script/ui/bag/RuneData"

local _curRuneItemId 						= nil
local _curTreasureItemId					= nil
local _callBack 							= nil
local _layer_priority						= nil
local _zOrderNum 							= nil
local _bgLayer 								= nil
local _bgSprite 							= nil
local _topBg 								= nil
local _curIndex 							= nil
local _curRuneItemInfo 						= nil

local _backGround 							= nil
local _contentBg 							= nil

--[[
	@des 	: 初始化
--]]
function init( ... )
	_curRuneItemId 							= nil
	_curTreasureItemId						= nil
	_callBack 								= nil
	_layer_priority							= nil
 	_zOrderNum 								= nil
	_bgLayer 								= nil
	_bgSprite 								= nil
	_topBg 									= nil
	_curIndex 								= nil
	_curRuneItemInfo 						= nil

	_backGround 							= nil
	_contentBg 								= nil
end

--[[
	@des 	: 初始化数据
--]]
function initData( ... )
	_curRuneItemInfo = RuneData.getRuneInfoByItemId(_curRuneItemId)
end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
	end
end

--[[
	@des 	: 关闭回调
--]]
function closeAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
end

--[[
	@des 	: 更换回调
--]]
function changeButtonAction( ... )
	-- 关闭界面
	closeAction()

	require "script/ui/treasure/ChooseRuneLayer"
	ChooseRuneLayer.showChooseLayer( _curTreasureItemId, _curIndex, _callBack, _layer_priority, _zOrderNum )
end

--[[
	@des 	: 卸下回调
--]]
function downButtonAction( ... )
	-- 符印背包满了
	if( ItemUtil.isRuneBagFull(true) == true )then
		return
	end
	local nextCallBack = function ( ... )
		-- 判断宝物位置
		local curItemInfo = ItemUtil.getItemByItemId(_curTreasureItemId)
		local isOnHero = false
		local hid = nil
		if(curItemInfo == nil)then
			curItemInfo = ItemUtil.getTreasInfoFromHeroByItemId(_curTreasureItemId)
			isOnHero = true
			hid = curItemInfo.hid
		end
		if(isOnHero)then
			-- 修改英雄身上的缓存数据
			HeroModel.changeHeroTreasureRuneBy( hid,_curTreasureItemId, nil, _curIndex)
		else
			-- 修改当前宝物缓存数据
			DataCache.changeTreasureRuneInBag( _curTreasureItemId, nil, _curIndex)
		end
		
		-- 关闭界面
		closeAction()
		-- 刷新方法
		if(_callBack ~= nil)then
			_callBack(_curIndex)
		end
	end
	require "script/ui/treasure/TreasureRuneService"
	-- 发请求
	TreasureRuneService.outlay(_curTreasureItemId, _curIndex, nextCallBack )
end


--[[
	@des 	: 创建内容界面
--]]
function createContentUI( ... )
	_contentBg = BaseUI.createContentBg(CCSizeMake(493,323))
 	_contentBg:setAnchorPoint(ccp(0.5,1))
 	_contentBg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-85))
 	_backGround:addChild(_contentBg)

 	-- 名字
 	local runeName = CCRenderLabel:create(_curRuneItemInfo.itemDesc.name,  g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	runeName:setColor(HeroPublicLua.getCCColorByStarLevel(_curRuneItemInfo.itemDesc.quality))
	runeName:setAnchorPoint(ccp(0.5,0))
	runeName:setPosition(ccp(_contentBg:getContentSize().width/2,_contentBg:getContentSize().height-78))
	_contentBg:addChild(runeName)

	-- 图标
	local iconBg = CCSprite:create("images/common/rune_bg_b.png")
	iconBg:setAnchorPoint(ccp(0.5,0.5))
	iconBg:setPosition(ccp(88,155))
	_contentBg:addChild(iconBg)

	local iconSp = ItemSprite.getItemSpriteByItemId(_curRuneItemInfo.item_template_id) 
	iconSp:setAnchorPoint(ccp(0.5,0.5))
	iconSp:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
	iconBg:addChild(iconSp)

	-- 线
	local line = CCScale9Sprite:create("images/common/line02.png")
	line:setContentSize(CCSizeMake(295,4))
	line:setAnchorPoint(ccp(0.5,0.5))
	line:setPosition(ccp(324,155))
	_contentBg:addChild(line)

	-- 类型
	local typeFontLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3024"),g_sFontName,21)
	typeFontLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	typeFontLabel:setAnchorPoint(ccp(1, 0.5))
	typeFontLabel:setPosition(ccp(310,178))
	_contentBg:addChild(typeFontLabel)

	local typeNameLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10202"),g_sFontName,21)
	typeNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
	typeNameLabel:setAnchorPoint(ccp(0, 0.5))
	typeNameLabel:setPosition(ccp(typeFontLabel:getPositionX()+10,typeFontLabel:getPositionY()))
	_contentBg:addChild(typeNameLabel)

	-- 属性
    local attrTab = RuneData.getRuneAbilityByItemId(_curRuneItemId)
	if(not table.isEmpty(attrTab) )then
		for i=1,#attrTab do
			local attrNameLabel = CCLabelTTF:create(attrTab[i].name .. "：",g_sFontName,23)
			attrNameLabel:setColor(ccc3(0xff, 0xf6, 0x00))
			attrNameLabel:setAnchorPoint(ccp(1, 0.5))
			attrNameLabel:setPosition(ccp(310,128-(i-1)*30))
			_contentBg:addChild(attrNameLabel)

			local attrNumLabel = CCLabelTTF:create("+" .. attrTab[i].showNum,g_sFontName,23)
			attrNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
			attrNumLabel:setAnchorPoint(ccp(0, 0.5))
			attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10,attrNameLabel:getPositionY()))
			_contentBg:addChild(attrNumLabel)
		end
	end
end

--[[
	@des 	: 创建界面
--]]
function initLayer( ... )
	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
	_backGround:setContentSize(CCSizeMake(555, 552))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	-- 战马印 兵书符
	local typeName = {GetLocalizeStringBy("lic_1546"),GetLocalizeStringBy("lic_1547")}
	local titleLabel = CCLabelTTF:create(typeName[tonumber(_curRuneItemInfo.itemDesc.type)], g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_layer_priority-4)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeAction)
	menu:addChild(closeButton)

	-- 创建内容
	createContentUI()

	-- 更换按钮
	local changeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73),GetLocalizeStringBy("lic_1544"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	changeButton:setAnchorPoint(ccp(0.5, 0.5))
    changeButton:setPosition(ccp(_backGround:getContentSize().width*0.3,_backGround:getContentSize().height*0.15))
    changeButton:registerScriptTapHandler(changeButtonAction)
	menu:addChild(changeButton)

	-- 卸下按钮
	local downButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73),GetLocalizeStringBy("lic_1545"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	downButton:setAnchorPoint(ccp(0.5, 0.5))
    downButton:setPosition(ccp(_backGround:getContentSize().width*0.7,_backGround:getContentSize().height*0.15))
    downButton:registerScriptTapHandler(downButtonAction)
	menu:addChild(downButton)


end

--[[
	@des 	: 显示符印信息界面
	@param 	: p_curRuneItemId 当前宝物itemId
	@param 	: p_curTreasureItemId 当前宝物itemId
	@param 	: p_index 	  当前符印位置
	@param 	: p_CallBack  回调
	@param 	: p_layer_priority 界面优先级
	@param 	: p_zOrderNum 界面z轴
	@return :
--]]
function showLayer(p_curRuneItemId, p_curTreasureItemId, p_index, p_CallBack, p_layer_priority, p_zOrderNum )
	print("showLayer p_curRuneItemId==>",p_curRuneItemId)
	print("p_curTreasureItemId==>",p_curTreasureItemId)
	print("p_index==>",p_index)
	print("p_CallBack==>",p_CallBack)
	print("p_layer_priority==>",p_layer_priority)
	print("p_zOrderNum==>",p_zOrderNum)
	-- 初始化变量
	init()

	-- 接收参数
	_curRuneItemId = p_curRuneItemId
	_curTreasureItemId = p_curTreasureItemId
	_curIndex = p_index
	_callBack = p_CallBack
	_layer_priority = p_layer_priority or -610
	_zOrderNum = p_zOrderNum or 1110

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrderNum,1)

    -- 初始化数据
    initData()

    -- 初始化界面
    initLayer()
end































