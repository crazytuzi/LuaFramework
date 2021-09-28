-- FileName: BagEnlargeDialog.lua 
-- Author: licong 
-- Date: 15/8/7 
-- Purpose: 背包扩充选择提示框


module("BagEnlargeDialog", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/bag/BagEnlargeService"
require "script/ui/bag/BagUtil"

local _bgLayer  						= nil
local _touchPriority  					= nil
local _zOrder 							= nil
local _curButton 						= nil

local _curChooseType 					= nil
local _curEnlargeBagType 				= nil
local _curCostGoldNum 					= nil
local _curHaveItemNum 					= nil
local _callBack 						= nil

local _curEnlargeGidNum 				= 5 -- 固定一次开5个格子
local _curCostItemNum 					= 1 -- 开5个格子消耗1个道具

local _costGoldType 					= 1 -- 消耗金币
local _costItemType 					= 2 -- 消耗道具

local _openItemTid 						= 60029 -- 背包扩充道具tid

local tipBagTab 						= {
	GetLocalizeStringBy("key_2869"), -- 1装备
	GetLocalizeStringBy("key_3328"), -- 2道具
	GetLocalizeStringBy("key_2570"), -- 3宝物
	GetLocalizeStringBy("key_2104"), -- 4装备碎片
	GetLocalizeStringBy("key_3152"), -- 5时装
	GetLocalizeStringBy("lic_1425"), -- 6神兵
	GetLocalizeStringBy("lic_1426"), -- 7神兵碎片
	GetLocalizeStringBy("lic_1531"), -- 8符印
	GetLocalizeStringBy("lic_1532"), -- 9符印碎片
	GetLocalizeStringBy("lic_1625"), -- 10锦囊
	GetLocalizeStringBy("lic_1773"), -- 11兵符
	GetLocalizeStringBy("lic_1772"), -- 12兵符碎片
	GetLocalizeStringBy("zq_0019"),  -- 13战车
	14,15,16,17,18,19,--预留背包位置
	GetLocalizeStringBy("lic_1635"), -- 20宠物
	GetLocalizeStringBy("lic_1636"), -- 21武将
}

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil
	_touchPriority  					= nil
	_zOrder 							= nil	
	_curButton 							= nil

	_curChooseType 						= nil
	_curEnlargeBagType 					= nil
	_curCostGoldNum 					= nil
	_curHaveItemNum 					= nil
	_callBack 							= nil

end

--[[
	@des 	: touch事件处理
	@param 	: 
	@return : 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
	@des 	: onNodeEvent事件
	@param 	: 
	@return : 
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end


--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeBtnCallFunc( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

   	if( _bgLayer ~= nil )then
   		_bgLayer:removeFromParentAndCleanup(true)
   		_bgLayer = nil
   	end
end

--[[
	@des 	:选择按钮回调
	@param 	:
	@return :
--]]
function chooseMenuItemCallback( tag, itemBtn )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    itemBtn:selected()
	if (_curButton ~= itemBtn) then
		if(_curButton == nil)then
			_curButton = itemBtn
		else
			_curButton:unselected()
		end
		_curButton = itemBtn
		_curButton:selected()
		
		_curChooseType = tag
	end
end

--[[
	@des 	:确定按钮回调
	@param 	:
	@return :
--]]
function okMenuItemCallBack( tag, sender )
	
	print("_curChooseType", _curChooseType)
	if( _curChooseType == nil)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1633"))
		return
	end

	-- 判断条件
	if( _curChooseType == _costItemType )then 
		-- 判断道具
		if(_curHaveItemNum < _curCostItemNum )then 
			AnimationTip.showTip(GetLocalizeStringBy("lic_1634"))
			return
		end
	end

	-- 关闭自己
	closeBtnCallFunc()

	if( _curChooseType == _costGoldType)then
		if( UserModel.getGoldNumber() < _curCostGoldNum )then 
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			return
		end
	end

	local nextCallFun = function ( ret )

		if(ret ~= "ok")then
			return
		end

		-- 扣除金币
		if( _curChooseType == _costGoldType)then
			UserModel.addGoldNumber(-_curCostGoldNum) 
		end
		-- 加格子
		DataCache.addGidNumByByBagType( _curEnlargeBagType, _curEnlargeGidNum )
		-- 提示
		AnimationTip.showTip(GetLocalizeStringBy("lic_1534",tipBagTab[_curEnlargeBagType]))

		-- 回调
		if(_callBack ~= nil)then 
			_callBack()
		end
	end
	if( _curChooseType == _costGoldType)then
		if( _curEnlargeBagType == BagUtil.PET_TYPE )then 
			-- 宠物背包
			BagEnlargeService.openKeeperSlot(0, 1, nextCallFun)
		elseif( _curEnlargeBagType == BagUtil.HERO_TYPE )then 
			-- 武将背包
			BagEnlargeService.openHeroGrid(1, nextCallFun)
		else
			BagEnlargeService.openGridByGold(_curEnlargeGidNum, _curEnlargeBagType, nextCallFun)
		end
	elseif( _curChooseType == _costItemType)then
		if( _curEnlargeBagType == BagUtil.PET_TYPE )then 
			-- 宠物背包
			BagEnlargeService.openKeeperSlot(1, 1, nextCallFun)
		elseif( _curEnlargeBagType == BagUtil.HERO_TYPE )then 
			-- 武将背包
			BagEnlargeService.openHeroGrid(2, nextCallFun)
		else
			BagEnlargeService.openGridByItem(_curEnlargeGidNum, _curEnlargeBagType, nextCallFun)
		end
	else
		print("erro")
	end
end

------------------------------------------------------------- 创建ui -------------------------------------------------------------------
--[[
	@des 	: 创建消耗UI
	@param 	: p_type: 消耗类型
	@return : 
--]]
function createCostUI( p_type )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(170,120))
	local fontTab = {GetLocalizeStringBy("lic_1630"), GetLocalizeStringBy("lic_1631") }
	local font = CCLabelTTF:create(fontTab[p_type], g_sFontName, 23)
    font:setColor(ccc3(0x78, 0x25, 0x00))
	font:setAnchorPoint(ccp(0.5,1))
    font:setPosition(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height)
    retSprite:addChild(font)

    -- 背景框
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
    attrBg:setContentSize(CCSizeMake(170,80))
    attrBg:setAnchorPoint(ccp(0.5,0))
    attrBg:setPosition(ccp(retSprite:getContentSize().width*0.5,0))
    retSprite:addChild(attrBg)

    -- 花费
    local fontTab2 = {}
    if(p_type == _costGoldType )then 
    	-- 金币
    	fontTab2[1] = CCRenderLabel:create(_curCostGoldNum .. " ", g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab2[1]:setColor(ccc3(0xff,0xf6,0x00))
	    fontTab2[2] = CCSprite:create("images/common/gold.png")
    elseif(p_type == _costItemType)then  
    	-- 道具 
	    fontTab2[1] = CCSprite:create("images/common/kuo.png")
    	fontTab2[2] = CCRenderLabel:create(" X" .. _curCostItemNum, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab2[2]:setColor(ccc3(0xff,0xf6,0x00))
    else
    end

    local costFont = BaseUI.createHorizontalNode(fontTab2)
    costFont:setAnchorPoint(ccp(0.5,0.5))
	costFont:setPosition(ccp(attrBg:getContentSize().width*0.5,attrBg:getContentSize().height*0.5))
	attrBg:addChild(costFont)
    
    return retSprite
end

--[[
	@des 	: 创建内部UI
	@param 	: 
	@return : 
--]]
function createContentUI( ... )
	local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1629"), g_sFontName, 25, 1, ccc3( 0, 0, 0), type_stroke)
    tipFont:setColor(ccc3(0x00, 0xe4, 0xff))
	tipFont:setAnchorPoint(ccp(0.5,1))
    tipFont:setPosition(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height-70)
    _bgSprite:addChild(tipFont)

    -- 花费
    local costSp1 = createCostUI( _costGoldType )
    costSp1:setAnchorPoint(ccp(0.5,1))
    costSp1:setPosition(ccp(_bgSprite:getContentSize().width*0.3,tipFont:getPositionY()-tipFont:getContentSize().height-20))
    _bgSprite:addChild(costSp1)

    local costSp2 = createCostUI( _costItemType )
    costSp2:setAnchorPoint(ccp(0.5,1))
    costSp2:setPosition(ccp(_bgSprite:getContentSize().width*0.7,costSp1:getPositionY()))
    _bgSprite:addChild(costSp2)

    -- 选择按钮
   local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority-3)
    _bgSprite:addChild(menu)

    -- 创建选择按钮1
	local chooseMenuItem1 = CCMenuItemImage:create("images/common/duigou_n.png","images/common/duigou_h.png")
	chooseMenuItem1:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem1:setPosition(ccp(_bgSprite:getContentSize().width*0.3,costSp1:getPositionY()-costSp1:getContentSize().height-50))
	menu:addChild(chooseMenuItem1,1,_costGoldType)
	chooseMenuItem1:registerScriptTapHandler(chooseMenuItemCallback)

	-- 创建选择按钮2
	local chooseMenuItem2 = CCMenuItemImage:create("images/common/duigou_n.png","images/common/duigou_h.png")
	chooseMenuItem2:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem2:setPosition(_bgSprite:getContentSize().width*0.7,chooseMenuItem1:getPositionY())
	menu:addChild(chooseMenuItem2,1,_costItemType)
	chooseMenuItem2:registerScriptTapHandler(chooseMenuItemCallback)

	-- 拥有道具数量
	local fontTab3 = {}
	fontTab3[1] = CCLabelTTF:create(GetLocalizeStringBy("lic_1632"), g_sFontName, 23)
    fontTab3[1]:setColor(ccc3(0x78,0x25,0x00))
    fontTab3[2] = CCSprite:create("images/common/kuo.png")
    fontTab3[3] = CCRenderLabel:create(" X" .. _curHaveItemNum, g_sFontName, 23, 1, ccc3( 0, 0, 0), type_stroke)
    fontTab3[3]:setColor(ccc3(0x00, 0xe4, 0xff))

    local haveFont = BaseUI.createHorizontalNode(fontTab3)
    haveFont:setAnchorPoint(ccp(0.5,0.5))
	haveFont:setPosition(ccp(_bgSprite:getContentSize().width*0.5,chooseMenuItem1:getPositionY()-chooseMenuItem1:getContentSize().height-10))
	_bgSprite:addChild(haveFont)

	-- 确定按钮
	require "script/libs/LuaCC"
	local okMenuItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1097"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	okMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	okMenuItem:setPosition(ccp(_bgSprite:getContentSize().width*0.5, haveFont:getPositionY()-haveFont:getContentSize().height-40))
    okMenuItem:registerScriptTapHandler(okMenuItemCallBack)
	menu:addChild(okMenuItem)
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(500, 500))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    setAdaptNode(_bgSprite)
    
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_bgSprite:getContentSize().width/2, _bgSprite:getContentSize().height-6.6 ))
	_bgSprite:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1194"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-3)
    _bgSprite:addChild(menuBar)
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*1.02, _bgSprite:getContentSize().height*1.02))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler( closeBtnCallFunc )
	
	-- 创建里边的UI
	createContentUI()

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( p_bagType, p_callBack, p_touchPriority, p_zOrder )
	-- 初始化
	init()

	_curEnlargeBagType = p_bagType
	_callBack = p_callBack
	_touchPriority = p_touchPriority or -1000
	_zOrder = p_zOrder or 1010

	_curCostGoldNum = BagUtil.getNextOpenCostByBagType(_curEnlargeBagType)

	_curHaveItemNum = ItemUtil.getCacheItemNumBy(_openItemTid)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer()
    runningScene:addChild(layer,_zOrder)
end


