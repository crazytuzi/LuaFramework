-- -- Filename：	PetLockTip.lua
-- -- Author：		zhang zihang
-- -- Date：		2014-4-16
-- -- Purpose：		带金币图标的锁定提示

-- module("OpenPetSquandTip", package.seeall)

-- require "script/ui/common/LuaMenuItem"
-- require "script/ui/main/MainScene"
-- require "script/ui/tip/AnimationTip"
-- require "script/audio/AudioUtil"

-- local _cormfirmCBFunc = nil 

-- local _alertLayer	= nil

-- local function init( ... )
-- 	_alertLayer = nil
-- 	_cormfirmCBFunc = nil
-- end


-- local function onTouchesHandler( eventType, x, y )

-- 	return true
-- end

-- function closeAction()
	
-- 	AudioUtil.playEffect("audio/effect/guanbi.mp3")
-- 	if(_alertLayer) then
-- 		_alertLayer:removeFromParentAndCleanup(true)
-- 		_alertLayer = nil
-- 	end
-- end


-- -- 按钮响应
-- function menuAction( tag, itemBtn )
-- 	require "script/audio/AudioUtil"
-- 	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
-- 	print ("tag==", tag)
-- 	if(tag == 10001) then
-- 		if (_cormfirmCBFunc) then
-- 			_cormfirmCBFunc()
-- 		end
-- 	elseif (tag == 10002) then
		
-- 	end

-- 	if(_alertLayer) then
-- 		_alertLayer:removeFromParentAndCleanup(true)
-- 		_alertLayer = nil
-- 	end
-- end



-- function showAlert(goldNum, needLv, confirmCBFunc)
	
-- 	init()

-- 	confirmTitle = GetLocalizeStringBy("key_1985")
-- 	cancelTitle = GetLocalizeStringBy("key_1202")
-- 	_cormfirmCBFunc = confirmCBFunc


-- 	-- if(_alertLayer) then
-- 	-- 	_alertLayer:removeFromParentAndCleanup(true)
-- 	-- 	alertLayer = nil
-- 	-- end

-- 	-- layer
-- 	_alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
-- 	_alertLayer:registerScriptTouchHandler(onTouchesHandler, false, -560, true)
-- 	_alertLayer:setTouchEnabled(true)
-- 	local runningScene = CCDirector:sharedDirector():getRunningScene()
-- 	runningScene:addChild(_alertLayer, 2000)

-- 	-- 背景
-- 	local fullRect = CCRectMake(0,0,213,171)
-- 	local insetRect = CCRectMake(50,50,113,71)
-- 	local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
-- 	alertBg:setPreferredSize(CCSizeMake(520, 360))
-- 	alertBg:setAnchorPoint(ccp(0.5, 0.5))
-- 	alertBg:setPosition(ccp(_alertLayer:getContentSize().width*0.5, _alertLayer:getContentSize().height*0.5))
-- 	_alertLayer:addChild(alertBg)
-- 	alertBg:setScale(g_fScaleX)	

-- 	local alertBgSize = alertBg:getContentSize()

-- 	-- 关闭按钮bar
-- 	local closeMenuBar = CCMenu:create()
-- 	closeMenuBar:setPosition(ccp(0, 0))
-- 	alertBg:addChild(closeMenuBar)
-- 	closeMenuBar:setTouchPriority(-561)
-- 	-- 关闭按钮
-- 	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
-- 	closeBtn:registerScriptTapHandler(closeAction)
-- 	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
--     closeBtn:setPosition(ccp(alertBg:getContentSize().width*0.95, alertBg:getContentSize().height*0.98))
-- 	closeMenuBar:addChild(closeBtn)

-- 	-- 标题
-- 	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
--     titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
--     titleLabel:setAnchorPoint(ccp(0.5, 0.5))
--     titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.8))
--     alertBg:addChild(titleLabel)


--         -- 金币图标
--     -- 描述
-- 	local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2781"), g_sFontName, 25)
-- 	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
--     local goldSprite = CCSprite:create("images/common/gold.png")
--  	local numberLabel= CCLabelTTF:create(goldNum ..GetLocalizeStringBy("key_1491"), g_sFontName,25)
--  	numberLabel:setColor(ccc3(0x78,0x25,0x00))

--  	local numberNode=  BaseUI.createHorizontalNode({descLabel ,goldSprite, numberLabel})
--  	numberNode:setAnchorPoint(ccp(0.5,0.5))
--     numberNode:setPosition(ccp(alertBg:getContentSize().width/2, alertBg:getContentSize().height*0.6))
--     alertBg:addChild(numberNode)

--     if(needLv~= nil) then
--     	local reachLvLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2997") .. needLv .. GetLocalizeStringBy("key_1226"), g_sFontName, 25)
--     	reachLvLabel:setAnchorPoint(ccp(0.5,0.5))
--     	reachLvLabel:setColor(ccc3(0x78,0x25,0x00))
--     	 numberNode:setPosition(ccp(alertBg:getContentSize().width/2, alertBg:getContentSize().height*0.6))
--     	reachLvLabel:setPosition(ccp(alertBg:getContentSize().width/2, alertBg:getContentSize().height*0.6 - numberNode:getContentSize().height ))
--     	alertBg:addChild(reachLvLabel)
--     end

--  --    -- 金币图标
--  --    local goldSprite = CCSprite:create("images/common/gold.png")
--  --    goldSprite:setAnchorPoint(ccp(0.5,0.5))
--  --    goldSprite:setPosition(ccp(110+5*25, 225))
--  --    alertBg:addChild(goldSprite)


-- 	-- -- 描述
-- 	-- local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2848") ..  gold_num .. tip_text, g_sFontName, 25, CCSizeMake(460, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
-- 	-- descLabel:setColor(ccc3(0x78, 0x25, 0x00))
-- 	-- descLabel:setAnchorPoint(ccp(0.5, 0.5))
-- 	-- descLabel:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height*0.5))
-- 	-- alertBg:addChild(descLabel)



-- 	-- 按钮
-- 	local menuBar = CCMenu:create()
-- 	menuBar:setPosition(ccp(0,0))
-- 	menuBar:setTouchPriority(-561)
-- 	alertBg:addChild(menuBar)

-- 	-- 确认
-- 	-- local confirmBtn = LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png", menuAction )
-- 	require "script/libs/LuaCC"
-- 	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
-- 	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))

--     confirmBtn:registerScriptTapHandler(menuAction)
-- 	menuBar:addChild(confirmBtn, 1, 10001)

-- 	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), cancelTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
-- 	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
--     -- cancelBtn:setPosition(alertBgSize.width*520/640, alertBgSize.height*0.4))
--     cancelBtn:registerScriptTapHandler(menuAction)
-- 	menuBar:addChild(cancelBtn, 1, 10002)

	
-- 	confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
-- 	cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
	
-- end
-- FileName: BagEnlargeDialog.lua 
-- Author: licong 
-- Date: 15/8/7 
-- Purpose: 背包扩充选择提示框


module("OpenPetSquandTip", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/bag/BagEnlargeService"
require "script/ui/bag/BagUtil"
require "db/DB_Pet_cost"

local _bgLayer  						= nil
local _touchPriority  					= nil
local _zOrder 							= nil
local _curButton 						= nil

local _curChooseType 					= nil
local _curEnlargeBagType 				= nil
local _curCostGoldNum 					= nil
local _curHaveItemNum 					= nil
local _callBack 						= nil
local _cormfirmCBFunc 					= nil
local _curCostItemNum 					= 1 -- 开5个格子消耗1个道具
local _dbInfo 							= DB_Pet_cost.getDataById(1)
local _costGoldType 					= 0 -- 消耗金币
local _costItemType 					= 1 -- 消耗道具

local _openItemTid 						= 60029 -- 背包扩充道具tid

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
	_cormfirmCBFunc 					= nil
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
	if(_curChooseType==nil)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_457"))
		return
	end

	if(_curChooseType==0)then
		if(_curCostGoldNum> UserModel.getGoldNumber() ) then
	        LackGoldTip.showTip()
	        return 
	    end
	else
		local dbData = string.split(_dbInfo.openPetItemNum,"|")
		if(_curHaveItemNum<tonumber(dbData[2]))then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1634"))
			return
		end
	end
	

	if (_cormfirmCBFunc) then
		_cormfirmCBFunc(_curChooseType)
	end

	if( _bgLayer ~= nil )then
   		_bgLayer:removeFromParentAndCleanup(true)
   		_bgLayer = nil
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
	local font = CCLabelTTF:create(fontTab[p_type+1], g_sFontName, 23)
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
    local dbData = string.split(_dbInfo.openPetItemNum,"|")
    _openItemTid = dbData[1]
    local data = DB_Item_normal.getDataById(_openItemTid)
    -- 花费
    local fontTab2 = {}
    if(p_type == _costGoldType )then 
    	-- 金币
    	fontTab2[1] = CCRenderLabel:create(_curCostGoldNum .. " ", g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab2[1]:setColor(ccc3(0xff,0xf6,0x00))
	    fontTab2[2] = CCSprite:create("images/common/gold.png")
    elseif(p_type == _costItemType)then  
    	local dbData = string.split(_dbInfo.openPetItemNum,"|")
    	-- 道具 
	    fontTab2[1] = CCSprite:create("images/base/props/"..data.icon_little)
    	fontTab2[2] = CCRenderLabel:create(" X" .. dbData[2], g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
	local tipFont = CCRenderLabel:create(GetLocalizeStringBy("llp_456"), g_sFontName, 25, 1, ccc3( 0, 0, 0), type_stroke)
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

	local data = DB_Item_normal.getDataById(_openItemTid)
	-- 拥有道具数量
	local fontTab3 = {}
	fontTab3[1] = CCLabelTTF:create(GetLocalizeStringBy("lic_1632"), g_sFontName, 23)
    fontTab3[1]:setColor(ccc3(0x78,0x25,0x00))
    fontTab3[2] = CCSprite:create("images/base/props/"..data.icon_little)
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
function showAlert( p_cost, p_needLv, p_callBack )
	-- 初始化
	init()

	_cormfirmCBFunc = p_callBack
	_touchPriority = p_touchPriority or -300
	_zOrder = p_zOrder or 1010

	_curCostGoldNum = p_cost
	local dbData = string.split(_dbInfo.openPetItemNum,"|")
	_curHaveItemNum = ItemUtil.getCacheItemNumBy(dbData[1])

	local runningScene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer()
    runningScene:addChild(layer,_zOrder)
end