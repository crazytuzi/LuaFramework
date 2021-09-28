-- FileName: GuildRobEnemyListLayer.lua 
-- Author: licong 
-- Date: 14-11-15 
-- Purpose: 抢粮敌人列表


module("GuildRobEnemyListLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/liangcang/BarnService"
require "script/ui/guild/guildRobList/GuildRobData"

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil
local _enemyTableView 				= nil

local _enemyListData 					= nil

--[[
    @des    :init
    @param  :
    @return :
--]]
function init( ... )
	_bgLayer                    		= nil
	_backGround 						= nil
	_enemyTableView 					= nil
	_second_bg  						= nil

	_enemyListData 						= nil

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
	if( tolua.cast(_bgLayer,"CCLayer") ~= nil )then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

----------------------------------------------------------- 创建UI ---------------------------------------------------------------

--[[
	@des 	: 创建抢粮敌人tableview
	@param 	:
	@return :
--]]
function createEnemyTableView()
	-- cell的size
	local cellSize = { width = 588, height = 180 } 

	require "script/ui/guild/guildRobList/GuildRobEnemyListCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 5
			r = CCSizeMake(cellSize.width, (cellSize.height + interval))
		elseif (fn == "cellAtIndex") then
			r = GuildRobEnemyListCell.createCell(_enemyListData[a1+1])
		elseif (fn == "numberOfCells") then
			r = #_enemyListData
		else
		end
		return r
	end)
	
	_enemyTableView = LuaTableView:createWithHandler(handler, CCSizeMake(600,675))
	_enemyTableView:setBounceable(true)
	_enemyTableView:ignoreAnchorPointForPosition(false)
	_enemyTableView:setAnchorPoint(ccp(0.5, 0.5))
	_enemyTableView:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height*0.5))
	_second_bg:addChild(_enemyTableView)
	-- 设置单元格升序排列
	_enemyTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	_enemyTableView:setTouchPriority(-623)
end

--[[
	@des 	:创建界面
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,-620,true)
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
    menu:setTouchPriority(-625)
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

	local titleLabel = CCLabelTTF:create( GetLocalizeStringBy("lic_1320"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(600,685))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-57))
 	_backGround:addChild(_second_bg)

	if( not table.isEmpty( _enemyListData ) )then 
	 	-- 创建奖励列表
	 	createEnemyTableView()
	else
		local tipFont = CCLabelTTF:create( GetLocalizeStringBy("lic_1367"), g_sFontPangWa, 40)
		tipFont:setColor(ccc3(0xff, 0xe4, 0x00))
		tipFont:setAnchorPoint(ccp(0.5,0.5))
		tipFont:setPosition(ccp(_second_bg:getContentSize().width*0.5, _second_bg:getContentSize().height*0.5))
		_second_bg:addChild(tipFont)
	end
end


--[[
	@des 	: 显示抢粮敌人列表
	@param 	:
	@return :
--]]
function showGuildRobEnemyListLayer()
	-- 初始化
	init()
	
	-- 请求回调
	local nextFunction = function ( retData )
		-- 初始化数据
		GuildRobData.setRobEnemyList(retData)
		-- 得到列表数据
		_enemyListData = GuildRobData.getRobEnemyList()

		-- 创建界面
		createTipLayer()
	end
	-- 发请求 策划需求显示最新的20条
	BarnService.getEnemyList(0,20,nextFunction)
end











































