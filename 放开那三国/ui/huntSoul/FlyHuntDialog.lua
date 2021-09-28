-- FileName: FlyHuntDialog.lua 
-- Author: licong 
-- Date: 15/11/3 
-- Purpose: 急速猎魂对话框 


module("FlyHuntDialog", package.seeall)
require "script/ui/huntSoul/HuntSoulData"

local _bgLayer                  	= nil
local _backGround 					= nil
local _menuItem1 					= nil
local _menuItem2 					= nil
local _menuItem3 					= nil
local _curMenuItem 					= nil

local _isChoose4 					= false
local _isChoose5 					= true
local _curIndex 					= nil

local _touchPriority 				= -420

--[[
	@des 	:初始化
	@param 	:
	@return :
--]]
function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil
	_menuItem1 						= nil
	_menuItem2 						= nil
	_menuItem3 						= nil
 	_curMenuItem 					= nil

 	_curIndex 						= nil

end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:选择4星
	@param 	:
	@return :
--]]
function chooseMenuItem2Callback( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local item = tolua.cast(itemBtn, "CCMenuItemToggle")
	local selectIndex = item:getSelectedIndex()
	if selectIndex > 0 then
		-- 选中
		_isChoose4 = true
	else
		-- 未选中
		_isChoose4 = false
	end
end

--[[
	@des 	:选择5星
	@param 	:
	@return :
--]]
function chooseMenuItem1Callback( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local item = tolua.cast(itemBtn, "CCMenuItemToggle")
	local selectIndex = item:getSelectedIndex()
	if selectIndex > 0 then
		-- 选中
		_isChoose5 = true
	else
		-- 未选中
		_isChoose5 = false
	end
end


--[[
	@des 	:选择花费
	@param 	:
	@return :
--]]
function chooseCostCallback( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    itemBtn:selected()
    if( _curMenuItem ~= itemBtn )then 
    	_curMenuItem:unselected()
    	_curMenuItem = itemBtn
    	_curIndex = tag
    end
end

--[[
	@des 	:急速猎魂按钮回调
	@param 	:
	@return :
--]]
function flyMenuItemCallFun( tag, itemBtn )
	local isOpne,seeLv,useLv = HuntSoulData.getIsOpenFlyHunt()
	if(isOpne == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1721",useLv))
		return
	end
	
	-- 银币不足
	local maxCost = HuntSoulData.getFlyCostById(_curIndex)
	if(UserModel.getSilverNumber() < maxCost) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1720"))
        return
    end

    -- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		closeButtonCallback()
		return
	end
	-- 道具背包满了
	if(ItemUtil.isPropBagFull(true))then
		closeButtonCallback()
		return
	end

    local nextCallFun = function ( p_tItems, p_fs_exp, p_costCoin, p_material )
    	-- 调回调
    	require "script/ui/huntSoul/SearchSoulLayer"
    	SearchSoulLayer.flyHuntResultCallFun( p_tItems, p_fs_exp, p_costCoin, p_material )
    end

    require "script/ui/huntSoul/HuntSoulService"
    local curQuality = {}
    if(_isChoose4)then 
    	table.insert(curQuality,4)
    end
    if(_isChoose5)then 
    	table.insert(curQuality,5)
    end
    local arg = nil
    if(table.isEmpty(curQuality))then 
    	arg = nil
    else
    	arg = curQuality
    end
    HuntSoulService.rapidHunt(_curIndex, arg,nextCallFun)
end
----------------------------------------------------------------- UI创建 -----------------------------------------------------------------
--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createCostMenuItem(p_num, p_file )
	local menuItem = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
	local numFont = CCRenderLabel:create(p_num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numFont:setColor(ccc3(0xff, 0xff, 0xff))
    numFont:setAnchorPoint(ccp(0.5,0))
    numFont:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height+3))
    menuItem:addChild(numFont)

    local coinSprite = CCSprite:create(p_file)
    coinSprite:setAnchorPoint(ccp(0.5,0))
    coinSprite:setPosition(ccp(menuItem:getContentSize().width*0.5,numFont:getPositionY()+numFont:getContentSize().height+3))
    menuItem:addChild(coinSprite)

	return  menuItem
end


--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_touchPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(528, 540))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority-2)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1710"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
	
	-- 极速猎魂按钮
	local flyMenuItem = CCMenuItemImage:create("images/hunt/fly1_n.png","images/hunt/fly1_h.png")
	flyMenuItem:setAnchorPoint(ccp(0.5,0))
	flyMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.5, 25))
	menu:addChild(flyMenuItem)
	flyMenuItem:registerScriptTapHandler(flyMenuItemCallFun)

	-- 提示
	local textInfo = {
     		width = 500, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 21,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        linespace = 10, -- 行间距
	        defaultType = "CCLabelTTF",
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1711"),
	            	color = ccc3(0x00, 0xff, 0x18),
	        	}
	        }
	 	}
 	local tipDes = GetLocalizeLabelSpriteBy_2("lic_1712", textInfo)
    tipDes:setAnchorPoint(ccp(0.5,1))
    tipDes:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-54))
    _backGround:addChild(tipDes)

    -- 线1
    local lineSprite1 = CCScale9Sprite:create("images/common/line01.png")
    lineSprite1:setContentSize(CCSizeMake(387,4))
    lineSprite1:setAnchorPoint(ccp(0.5,0.5))
    lineSprite1:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-96))
    _backGround:addChild(lineSprite1)

    local tip1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1713"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    tip1:setColor(ccc3(0x00, 0xff, 0x18))
    tip1:setAnchorPoint(ccp(0.5,0))
    tip1:setPosition(ccp(_backGround:getContentSize().width*0.5,lineSprite1:getPositionY()-32))
    _backGround:addChild(tip1)

    -- 选择框按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    _backGround:addChild(menuBar)
    menuBar:setTouchPriority(_touchPriority-2)

    -- 五星战魂
    local isOpne,useLv = HuntSoulData.getIsOpenChooseFive()

    local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local normalSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	normalSprite:setPreferredSize(CCSizeMake(45, 45))
	local norItem = CCMenuItemSprite:create(normalSprite,normalSprite)
	norItem:setAnchorPoint(ccp(0.5, 0.5))

	local selectedSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	selectedSprite:setPreferredSize(CCSizeMake(45, 45))

	local checkedSprite = nil
	if(isOpne)then
		checkedSprite = CCSprite:create("images/common/checked.png")
	else
		checkedSprite = BTGraySprite:create("images/common/checked.png")
	end
	checkedSprite:setAnchorPoint(ccp(0.5, 0.5))
	checkedSprite:setPosition(ccpsprite(0.5, 0.5, selectedSprite))
	selectedSprite:addChild(checkedSprite)
	local higItem = CCMenuItemSprite:create(selectedSprite,selectedSprite)
	higItem:setAnchorPoint(ccp(0.5, 0.5))

	local chooseMenuItem1 = CCMenuItemToggle:create(norItem)
	chooseMenuItem1:addSubItem(higItem)
	chooseMenuItem1:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem1:setPosition(ccp(_backGround:getContentSize().width*0.3,tip1:getPositionY()-71))
	menuBar:addChild(chooseMenuItem1)
	chooseMenuItem1:registerScriptTapHandler(chooseMenuItem1Callback)

	if(_isChoose5)then 
    	chooseMenuItem1:setSelectedIndex(1)
    end
	if(isOpne)then
		chooseMenuItem1:setEnabled(true)
	else
		chooseMenuItem1:setEnabled(false)
	end

	local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1714"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font1:setColor(ccc3(0xe4, 0x00, 0xff))
    font1:setAnchorPoint(ccp(0.5,0))
    font1:setPosition(ccp(chooseMenuItem1:getContentSize().width*0.5,chooseMenuItem1:getContentSize().height+10))
    chooseMenuItem1:addChild(font1)

    -- 四星战魂
    local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local normalSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	normalSprite:setPreferredSize(CCSizeMake(45, 45))
	local norItem = CCMenuItemSprite:create(normalSprite,normalSprite)
	norItem:setAnchorPoint(ccp(0.5, 0.5))

	local selectedSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	selectedSprite:setPreferredSize(CCSizeMake(45, 45))
	local checkedSprite = CCSprite:create("images/common/checked.png")
	checkedSprite:setAnchorPoint(ccp(0.5, 0.5))
	checkedSprite:setPosition(ccpsprite(0.5, 0.5, selectedSprite))
	selectedSprite:addChild(checkedSprite)
	local higItem = CCMenuItemSprite:create(selectedSprite,selectedSprite)
	higItem:setAnchorPoint(ccp(0.5, 0.5))

	local chooseMenuItem2 = CCMenuItemToggle:create(norItem)
	chooseMenuItem2:addSubItem(higItem)
	chooseMenuItem2:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem2:setPosition(ccp(_backGround:getContentSize().width*0.7,chooseMenuItem1:getPositionY()))
	menuBar:addChild(chooseMenuItem2)
	chooseMenuItem2:registerScriptTapHandler(chooseMenuItem2Callback)

	if(_isChoose4)then 
    	chooseMenuItem2:setSelectedIndex(1)
    end

	local font2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1715"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font2:setColor(ccc3(0x00, 0xe4, 0xff))
    font2:setAnchorPoint(ccp(0.5,0))
    font2:setPosition(ccp(chooseMenuItem2:getContentSize().width*0.5,chooseMenuItem2:getContentSize().height+10))
    chooseMenuItem2:addChild(font2)

    -- 描述二
	local textInfo = {
     		width = 500, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 18,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        linespace = 10, -- 行间距
	        defaultType = "CCLabelTTF",
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = tostring(useLv),
	            	color = ccc3(0x00, 0xff, 0x18),
	        	}
	        }
	 	}
 	local tipDes2 = GetLocalizeLabelSpriteBy_2("lic_1769", textInfo)
    tipDes2:setAnchorPoint(ccp(0.5,0.5))
    tipDes2:setPosition(ccp(_backGround:getContentSize().width*0.5,chooseMenuItem1:getPositionY()-chooseMenuItem1:getContentSize().height*0.5-15))
    _backGround:addChild(tipDes2)

    -- 线2
    local lineSprite2 = CCScale9Sprite:create("images/common/line01.png")
    lineSprite2:setContentSize(CCSizeMake(387,4))
    lineSprite2:setAnchorPoint(ccp(0.5,0.5))
    lineSprite2:setPosition(ccp(_backGround:getContentSize().width*0.5,tipDes2:getPositionY()-tipDes2:getContentSize().height*0.5-10))
    _backGround:addChild(lineSprite2)

    -- 选择花费
	local second_bg = BaseUI.createContentBg(CCSizeMake(455,145))
 	second_bg:setAnchorPoint(ccp(0.5,1))
 	second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,lineSprite2:getPositionY()-10))
 	_backGround:addChild(second_bg)

 	-- 单选按钮
 	local menuBar2 = CCMenu:create()
    menuBar2:setPosition(ccp(0,0))
    second_bg:addChild(menuBar2)
    menuBar2:setTouchPriority(_touchPriority-2)

    -- 选项1
    local cost1 = HuntSoulData.getFlyCostById(1)
 	_menuItem1 = createCostMenuItem(string.formatBigNumber(cost1), "images/common/coin1.png" )
 	_menuItem1:setAnchorPoint(ccp(0.5,0))
 	_menuItem1:setPosition(ccp(second_bg:getContentSize().width*0.2,10))
 	menuBar2:addChild(_menuItem1,1,1)
 	_menuItem1:registerScriptTapHandler(chooseCostCallback)

 	-- 选项2
 	local cost2 = HuntSoulData.getFlyCostById(2)
 	_menuItem2 = createCostMenuItem(string.formatBigNumber(cost2), "images/common/coin2.png" )
 	_menuItem2:setAnchorPoint(ccp(0.5,0))
 	_menuItem2:setPosition(ccp(second_bg:getContentSize().width*0.5,10))
 	menuBar2:addChild(_menuItem2,1,2)
 	_menuItem2:registerScriptTapHandler(chooseCostCallback)

 	-- 选项3
 	local cost3 = HuntSoulData.getFlyCostById(3)
 	_menuItem3 = createCostMenuItem(string.formatBigNumber(cost3), "images/common/coin3.png" )
 	_menuItem3:setAnchorPoint(ccp(0.5,0))
 	_menuItem3:setPosition(ccp(second_bg:getContentSize().width*0.8,10))
 	menuBar2:addChild(_menuItem3,1,3)
 	_menuItem3:registerScriptTapHandler(chooseCostCallback)

 	-- 默认选项1
 	_curMenuItem = _menuItem1
 	_curMenuItem:selected()
 	_curIndex = 1
end


--[[
	@des 	:选择猎取次数的提示框
	@param 	:
	@return :
--]]
function showTip()
	-- 初始化
	init()

	-- 创建提示layer
	createTipLayer()
end
