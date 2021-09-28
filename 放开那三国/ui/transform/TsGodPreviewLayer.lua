-- FileName: TsGodPreviewLayer.lua 
-- Author: licong 
-- Date: 16/3/4 
-- Purpose: 转换神兵预览界面


module("TsGodPreviewLayer", package.seeall)

local _bgLayer 							= nil
local _bgSprite 						= nil
local _listTableView 					= nil
local _secondBg 						= nil

local _callBack 						= nil -- 关闭回调
local _layer_priority 					= nil -- 界面优先级
local _zOrderNum 						= nil -- 界面z轴
local _showItems 						= nil

--[[  
	@des 	:初始化
	@param 	:
	@return :
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil
	_listTableView 						= nil
	_secondBg 							= nil

	_callBack  							= nil
	_layer_priority 					= nil 
	_zOrderNum  						= nil
	_showItems 							= nil
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
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	_showItems = TransformGodData.getAllTransformItemTid()
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(550, 140)
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.13,0.37,0.62,0.87}
			for i=1,4 do
				if(_showItems[a1*4+i] ~= nil)then
					-- 物品图标
					local tab = {}
					tab.tid = _showItems[a1*4+i]
					tab.num = 1
					tab.type = "item"
					local iconSp = ItemUtil.createGoodsIcon(tab, _layer_priority-3, 1020, _layer_priority-50)
					a2:addChild(iconSp)
					iconSp:setAnchorPoint(ccp(0.5,1))
					iconSp:setPosition(ccp(550*posArrX[i],130))
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_showItems
			r = math.ceil(num/4)
			print("num is : ", num)
		else
		end
		return r
	end)

	_listTableView = LuaTableView:createWithHandler(h, CCSizeMake(_secondBg:getContentSize().width,_secondBg:getContentSize().height-20))
	_listTableView:setBounceable(true)
	_listTableView:setTouchPriority(_layer_priority-4)
	_listTableView:ignoreAnchorPointForPosition(false)
	_listTableView:setAnchorPoint(ccp(0.5,0.5))
	_listTableView:setPosition(ccp(_secondBg:getContentSize().width*0.5,_secondBg:getContentSize().height*0.5))
	_secondBg:addChild(_listTableView)
	-- 设置单元格升序排列
	_listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return :
--]]
function createUI()
	-- 创建背景
	_bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setContentSize(CCSizeMake(600, 540))
    -- 适配
    setAdaptNode(_bgSprite)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_bgSprite:getContentSize().width/2, _bgSprite:getContentSize().height-6.6 ))
	_bgSprite:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1799"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_layer_priority-30)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_bgSprite:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_bgSprite:getContentSize().width * 0.955, _bgSprite:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 二级背景
	_secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_secondBg:setContentSize(CCSizeMake(550, 400))
 	_secondBg:setAnchorPoint(ccp(0.5,1))
 	_secondBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height-50))
 	_bgSprite:addChild(_secondBg)

 	-- 创建列表
 	createTableView()

 	-- 提示
 	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1800"), g_sFontPangWa, 25)
	tipFont:setColor(ccc3(0x78, 0x25, 0x00))
	tipFont:setAnchorPoint(ccp(0.5,0.5))
	tipFont:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _secondBg:getPositionY()-_secondBg:getContentSize().height-30))
	_bgSprite:addChild(tipFont)
end

--[[
	@des 	: 显示选择
	@param 	: 
	@return :
--]]
function showLayer( p_CallBack, p_layer_priority, p_zOrderNum )

	-- 初始化变量
	init()

	-- 接收参数
	_callBack = p_CallBack
	_layer_priority = p_layer_priority or -550
	_zOrderNum = p_zOrderNum or 1000

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrderNum,1)

    -- 初始化界面
    createUI()
end


