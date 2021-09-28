-- FileName: HappySignLayer.lua 
-- Author: shengyixian
-- Date: 15-9-25
-- Purpose: 欢乐签到

module("HappySignLayer",package.seeall)
require "script/ui/main/BulletinLayer"
require "script/ui/rechargeActive/happySign/HappySignCell"
require "script/ui/rechargeActive/happySign/HappySignData"
require "script/ui/rechargeActive/happySign/HappySignController"

local _layer = nil
-- 表视图背景
local _listBg = nil
local _touchPriority = -345
local _tableView = nil
-- “您已签到：”
local _alreadySign = nil
-- 已签到多少天
local _daysLabel = nil
-- "天"
local _dayTextLabel = nil


function init( ... )
	-- body
	_layer = nil
	_listBg = nil
	_tableView = nil
	_alreadySign = nil
	_daysLabel = nil
	_dayTextLabel = nil
end
--[[
	@des 	:初始化界面
	@param 	:
	@return :
--]]
function initView( ... )
	-- body
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	local menuHeight = MenuLayer.getHeight()
	-- 标题背景
	local titleBg = CCScale9Sprite:create("images/recharge/happy_sign/di.png") -- 640 400
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(ccp(g_winSize.width*0.5, g_winSize.height-topMenuHeight))
    _layer:addChild(titleBg)
    titleBg:setScale(g_fScaleX)
    -- 列表背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(50,50,6,4)
    local titleBgShift = 0.52
    _listBg = CCScale9Sprite:create("images/recharge/change/list_bg.png", fullRect, insetRect)
    local listHight = titleBg:getPositionY() - titleBg:getContentSize().height * titleBgShift * g_fScaleX - (menuHeight+25 * g_fScaleX)
    local listWidth = 630
    _listBg:setContentSize(CCSizeMake(listWidth, listHight / g_fScaleX))
    _listBg:setAnchorPoint(ccp(0.5,1))
    _listBg:setPosition(ccp(g_winSize.width*0.5, titleBg:getPositionY()-titleBg:getContentSize().height * titleBgShift * g_fScaleX))
    _layer:addChild(_listBg)
    _listBg:setScale(g_fScaleX)
    -- title
    local activityTitleSp = CCSprite:create("images/recharge/happy_sign/title.png")
    activityTitleSp:setAnchorPoint(ccp(0.5, 1))
    activityTitleSp:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height - 20))
    titleBg:addChild(activityTitleSp)
    createTableView()
    _alreadySign = CCRenderLabel:create(GetLocalizeStringBy("syx_1027"), g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    _alreadySign:setColor(ccc3( 0xff, 0xff, 0xff))
    _alreadySign:setAnchorPoint(ccp(0.5, 0.5))
    _alreadySign:setPosition(ccpsprite(0.48,0.67,titleBg))
    titleBg:addChild(_alreadySign)
    _daysLabel = CCRenderLabel:create(HappySignData.getSignedDays(), g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    _daysLabel:setColor(ccc3( 0x00, 0xff, 0x00))
    _daysLabel:setAnchorPoint(ccp(0, 0.5))
    _daysLabel:setPosition(ccpsprite(1,0.5,_alreadySign))
    _alreadySign:addChild(_daysLabel)
    _dayTextLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10189"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    _dayTextLabel:setColor(ccc3( 0xff, 0xff, 0xff))
    _dayTextLabel:setAnchorPoint(ccp(0, 0.5))
    _dayTextLabel:setPosition(ccpsprite(1.1,0.5,_daysLabel))
    _daysLabel:addChild(_dayTextLabel)
    -- 时间背景
	local timeBgSprite = CCScale9Sprite:create("images/recharge/restore_energy/desc_bg.png")
	timeBgSprite:setPreferredSize(CCSizeMake(600,25))
	timeBgSprite:setAnchorPoint(ccp(0.5,0.5))
	timeBgSprite:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5 + 26))
    titleBg:addChild(timeBgSprite)
    -- 活动时间     时间倒计时
    local beginTime = TimeUtil.getTimeFormatYMDHMS(HappySignData.getStartTime())
    local endTime = TimeUtil.getTimeFormatYMDHMS(HappySignData.getEndTime())
    local endTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_1006") .. beginTime .. "~" .. endTime, g_sFontName, 20, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    endTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    endTimeLabel:setAnchorPoint(ccp(0.5, 0.5))
    endTimeLabel:setPosition(ccpsprite(0.5,0.5,timeBgSprite))
    timeBgSprite:addChild(endTimeLabel)
end

function createLayer( ... )
	-- body
	init()
	_layer = CCLayer:create()
	-- _layer:registerScriptHandler(onNodeEvent)
	HappySignController.getSignInfo(initView)
	return _layer
end
--[[
	@des 	:
	@param 	:
	@return :
--]]
function createTableView( ... )
	-- body
    local tableViewSize = CCSizeMake(_listBg:getContentSize().width,_listBg:getContentSize().height - 20)
	local cellSize = CCSizeMake(tableViewSize.width,200)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(cellSize.width,cellSize.height)
			elseif fn == "cellAtIndex" then
				ret = HappySignCell.create(a1 + 1)
			elseif fn == "numberOfCells" then
				ret = HappySignData.getActivityDays()
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	_tableView:setTouchPriority(_touchPriority)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(10,10))
	_listBg:addChild(_tableView)
end
--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
-- function onNodeEvent( pEvent )
--     if ( pEvent == "enter" ) then
--     elseif ( pEvent == "exit" ) then
--     	if _layer then
--        		_layer = nil
--        	end
--     end
-- end
--[[
	@des 	:更新天数文本
	@param 	:
	@return :
--]]
function updateDaysLabel( value )
	-- body
	_daysLabel:setString(value)
end