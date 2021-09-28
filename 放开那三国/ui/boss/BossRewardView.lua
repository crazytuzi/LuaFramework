-- FileName: BossRewardView.lua 
-- Author: licong 
-- Date: 14-10-20 
-- Purpose: 世界boos奖励预览


module("BossRewardView", package.seeall)
require "script/ui/boss/BossData"

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil
local _rewadTableView 				= nil

local _isNewBoos 					= nil

function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil
	_second_bg  					= nil
	_rewadTableView 				= nil

	_isNewBoos 						= nil
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
	@des 	:创建提奖励列表
	@param 	:
	@return :
--]]
function createRewardTableView( )
	local cellSize = CCSizeMake(563, 208)           --计算cell大小

    local rewardData = {}
    if(_isNewBoos)then
    	rewardData = BossData.getNewBoosRewardIds()
    else
    	rewardData = BossData.getOldBoosRewardIds()
    end
	print_t(rewardData)
	require "script/ui/boss/BossRewardViewCell"
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            a2 = BossRewardViewCell.createCell(rewardData[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r = #rewardData
        else
        end
        return r
    end)
    _rewadTableView = LuaTableView:createWithHandler(h, CCSizeMake(571,650))
    _rewadTableView:setTouchPriority(-654)
    _rewadTableView:setBounceable(true)
    _rewadTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _rewadTableView:ignoreAnchorPointForPosition(false)
    _rewadTableView:setAnchorPoint(ccp(0.5,0.5))
    _rewadTableView:setPosition(ccpsprite(0.5,0.5,_second_bg))
    _second_bg:addChild(_rewadTableView)
end

--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,-650,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(640,798))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-651)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCScale9Sprite:create("images/common/viewtitle1.png")
    titlePanel:setContentSize(CCSizeMake(370,61))
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	require "db/DB_Worldboss"
	local tileStr = nil
	if(_isNewBoos)then
    	tileStr = DB_Worldboss.getDataById(1).boss2name
    else
    	tileStr = DB_Worldboss.getDataById(1).name
    end
	local titleLabel = CCLabelTTF:create( tileStr .. GetLocalizeStringBy("lic_1272"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(571,661))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-57))
 	_backGround:addChild(_second_bg)

 	-- 创建奖励列表
 	createRewardTableView()
 	
 	-- 魔神等级达到30级后可掉落高级丹药盒
 	local itemData1 = ItemUtil.getItemById(30107)
 	local itemData2 = ItemUtil.getItemById(61000)
    local textInfo = {
     		width = 600, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        defaultStrokeColor = ccc3(0xff, 0xff, 0xff),
	        defaultType = "CCRenderLabel",
	        linespace = 10, -- 行间距
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = tostring(30),
	            	color = ccc3(0x00, 0xff, 0x18),
	            	strokeColor = ccc3(0x00, 0x00, 0x00),
	        	},
	        	{
	            	type = "CCRenderLabel", 
	            	text = itemData1.name,
	            	color = HeroPublicLua.getCCColorByStarLevel(itemData1.quality),
	            	strokeColor = ccc3(0x00, 0x00, 0x00),
	        	},
	        	{
	            	type = "CCRenderLabel", 
	            	text = itemData2.name,
	            	color = HeroPublicLua.getCCColorByStarLevel(itemData2.quality),
	            	strokeColor = ccc3(0x00, 0x00, 0x00),
	        	},
	        }
	 	}
 	local tipNode = GetLocalizeLabelSpriteBy_2("lic_1591", textInfo)
 	tipNode:setAnchorPoint(ccp(0.5,0))
 	tipNode:setPosition(ccp(_backGround:getContentSize().width*0.5,30))
 	_backGround:addChild(tipNode)
end

--[[
	@des 	:显示奖励预览
	@param 	:
	@return :
--]]
function showRewardView( ... )
	-- 初始化
	init()

	-- 是否是新boos
	_isNewBoos = BossData.getIsNewBoos()

	-- 创建提示layer
	createTipLayer()
end













































