-- FileName: SignleRechargeLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-3-3
-- Purpose: 单充回馈主界面


module("SignleRechargeLayer",package.seeall)
require "script/ui/rechargeActive/singleRecharge/SignleRechargeData"
require "script/ui/main/MenuLayer"
require "script/ui/rechargeActive/singleRecharge/SingleRechargeCell"
require "script/ui/rechargeActive/singleRecharge/SignleRechargeController"
local _bgLayer = nil
local _remainLabel = nil
local _touchPriority = -345
local _viewBgSprite = nil
local _tableView =nil
local titleBg = nil
local remainNode = nil
function init( ... )
	_bgLayer = nil
	_remainLabel = nil
	_viewBgSprite = nil
	_tableView = nil
end
-- function onNodeEvent( pEvent )
-- 	if(pEvent == "enter")then
-- 	elseif(pEvent == "exit")then
-- 		_bgLayer =nil
-- 	end
-- end
--进入单充回馈界面的接口
function createLayer( ... )
	init()
	_bgLayer = CCLayer:create()
	-- _bgLayer:registerScriptHandler(onNodeEvent)
	--创建UI
	createUI()
	return _bgLayer
end
--更新时间
function updateTime( ... )
	--刷新活动倒计时
	_remainLabel:setString(SignleRechargeData.activeCountDown())
end
--创建基础UI
function createUI( ... )

	require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	-- 标题背景
	titleBg = CCScale9Sprite:create("images/recharge/blackshop/17.png") -- 640 400
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height-topMenuHeight))
    _bgLayer:addChild(titleBg)
    titleBg:setScale(g_fScaleX)

    --标题
    local titleSprite = CCSprite:create("images/recharge/singleRe/title.png")
    titleBg:addChild(titleSprite)
    titleSprite:setAnchorPoint(ccp(0,1))
    titleSprite:setPosition(ccp(5,titleBg:getContentSize().height-10))
  
     --描述
	local des = CCSprite:create("images/recharge/singleRe/wenzi.png")
	titleBg:addChild(des)
	des:setAnchorPoint(ccp(0,1))
	des:setPosition(ccp(15+titleSprite:getContentSize().width,titleBg:getContentSize().height-28))

     --活动时间
	local localInfo = {}
	localInfo.localColor = ccc3(0x00,0xe4,0xff)
	localInfo.localFontSize = 18
	localInfo.localLabelType = "strokeLabel"
	localInfo.font = g_sFontName
	local paramTable = {
							{
								ntype = "strokeLabel",
								fontSize = 18,
								text = SignleRechargeData.getFormatDate(1) .. "-" .. SignleRechargeData.getFormatDate(2),
								color = ccc3(0x00,0xff,0x18)
							}
					   }
	local timeSprite = GetLocalizeLabelSpriteBy("zzh_1195",localInfo,paramTable)
	timeSprite:setAnchorPoint(ccp(0,1))
	timeSprite:setPosition(ccp(5,titleBg:getContentSize().height-38 - des:getContentSize().height))
	titleBg:addChild(timeSprite)

	--活动剩余时间
	local remainTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1193"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	remainTimeLabel:setColor(ccc3(0x00,0xe4,0xff))
	_remainLabel = CCRenderLabel:create(SignleRechargeData.activeCountDown(),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	_remainLabel:setColor(ccc3(0x00,0xff,0x18))

	remainNode = BaseUI.createHorizontalNode( {remainTimeLabel,_remainLabel} )
	remainNode:setAnchorPoint(ccp(0,1))
	remainNode:setPosition(ccp(5+timeSprite:getContentSize().width+timeSprite:getPositionX(),titleBg:getContentSize().height-38 - des:getContentSize().height))
	titleBg:addChild(remainNode)
	schedule(_bgLayer,updateTime,1)
	SignleRechargeController.getInfo(function ( ... )
		createTableView()
	end)
    
end
--创建tableview
function createTableView( ... )
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	--tableView的背景
	local postionY = remainNode:getPositionY() - remainNode:getContentSize().height
	local remainNodePositionY = titleBg:getContentSize().height - postionY
	local height1 = _bgLayer:getContentSize().height - topMenuHeight - MenuLayer.getHeight() - remainNodePositionY*g_fScaleX-25*g_fScaleX
	viewBgSprite = CCScale9Sprite:create(CCRectMake(53,57,10,10),"images/recharge/change/zhong_bg1.png")
	viewBgSprite:setContentSize(CCSizeMake(640,height1/g_fScaleX))
	viewBgSprite:setAnchorPoint(ccp(0.5,0))
	viewBgSprite:setScale(g_fScaleX)
	viewBgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,MenuLayer.getHeight()+25*g_fScaleX))
	_bgLayer:addChild(viewBgSprite)

	local cpOffset = nil
	if( _tableView~= nil ) then
		cpOffset = _tableView:getContentOffset()
        _tableView:removeFromParentAndCleanup(true)
        _tableView=nil
    end
	local _dataInfo = SignleRechargeData.getAllInfo()
	local tableViewSize = CCSizeMake(viewBgSprite:getContentSize().width,viewBgSprite:getContentSize().height-20*g_fScaleX)
	local cellSize = CCSizeMake(tableViewSize.width,195)
	local luaHandler = LuaEventHandler:create(function ( fn,t,a1,a2 )
		local pCell = nil
		if fn == "cellSize" then
			pCell = CCSizeMake(cellSize.width,cellSize.height)
		elseif fn == "cellAtIndex" then
			pCell = SingleRechargeCell.create(_dataInfo[a1+1], a1+1,_touchPriority)
		elseif fn == "numberOfCells" then
			pCell = SignleRechargeData.getActivityDays()
		elseif fn == "cellTouched" then
			
		end
	return pCell
	end)
	_tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	_tableView:setTouchPriority(_touchPriority)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(5,5))
	viewBgSprite:addChild(_tableView)

	if cpOffset ~= nil then
		_tableView:setContentOffset(cpOffset)
	end
end

-- --0点刷新
-- function refresh()
-- 	--先判断是否在当前页面
-- 	if(_bgLayer == nil)then
-- 		return
-- 	else
-- 		refreshRedTip()
-- 	end	
-- end

--刷新小红点（同时也是充值后的刷新方法）
function refreshRedTip( ... )
	SignleRechargeController.getInfo(function ( ... )
		createTableView()
        RechargeActiveMain.refreshRechargeTip()
    end)
end

--刷新充值剩余次数
function refreshRechargeRemainNum( ... )
    --判断活动是否开启
    if( not SignleRechargeData.isOpen())then
        return
    else
        --判断是否在当前页面
        if( _bgLayer == nil)then
            return
        else
            --刷新页面
            refreshRedTip()
        end
    end
end

