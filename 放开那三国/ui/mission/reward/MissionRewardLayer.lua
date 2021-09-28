-- FileName: MissionRewardLayer
-- Author: shengyixian
-- Date: 2015-09-06
-- Purpose: 奖励预览

module("MissionRewardLayer",package.seeall)

require "script/ui/mission/reward/MissionRewardCell"
require "script/ui/mission/reward/MissionRewardData"
require "db/DB_Bounty_reward"
-- 悬赏榜活动标识
local kBounty = "bounty"
-- 国战活动标识
local kCountryWar = "countryWar"
-- 界面层
local _layer = nil
-- 表示图背景
local _tableViewBg = nil
-- 表示图
local _tableView = nil
-- 触摸优先级
local _touchPriority = nil
-- 资源路径
local _imagePath = nil
-- 当前显示内容的数据
local _currData = nil
-- 当前显示的活动名称
local _acticityName = nil
-- 标签数组
local _tabAry = nil

function init()
    _imagePath = {
		bg = "images/common/viewbg1.png",
		closeMenuItem_n = "images/common/btn_close_n.png",
		closeMenuItem_h = "images/common/btn_close_h.png",
		tableViewBg = "images/common/bg/bg_ng_attr.png",
		btn_blue_n = "images/common/btn/btn_blue_n.png",
		btn_blue_h = "images/common/btn/btn_blue_h.png",
		tap_btn_n = "images/common/btn/tab_button/btn1_n.png",
		tap_btn_h = "images/common/btn/tab_button/btn1_h.png"
    }
    _layer = nil
	_tableViewBg = nil
	_tableView = nil
	_currData = nil
	_tabAry = nil
end
--[[
	@des 	: 初始化界面
	@param 	: 
	@return : 
--]]
function initView(layer)
	-- 背景尺寸
	local bgSize = CCSizeMake(620,840)
    -- 背景
    local bg = CCScale9Sprite:create(_imagePath.bg)
    bg:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bg:setAnchorPoint(ccp(0.5,0.5))
    bg:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height/2))
    bg:setScale(MainScene.elementScale)
    layer:addChild(bg)
    local titleStr,firstTabStr,secondTabStr
    if _acticityName == kBounty then
    	titleStr = GetLocalizeStringBy("syx_1012")
    	firstTabStr = GetLocalizeStringBy("syx_1013")
    	secondTabStr = GetLocalizeStringBy("syx_1014")
    	_currData = MissionRewardData.getRankData()
    else
    	titleStr = GetLocalizeStringBy("syx_1040")
    	firstTabStr = GetLocalizeStringBy("syx_1041")
    	secondTabStr = GetLocalizeStringBy("syx_1042")
    	_currData = MissionRewardData.getPreliminaryData()
    end
    local tabStrAry = {firstTabStr,secondTabStr}
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bg:getContentSize().width/2, bg:getContentSize().height-6.6 ))
	bg:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(titleStr, g_sFontPangWa, 33)
	titleLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
    -- 按钮层
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority-1)
    bg:addChild(menu)
    -- 关闭按钮
    local closeMenuItem = CCMenuItemImage:create(_imagePath.closeMenuItem_n, _imagePath.closeMenuItem_h)
    closeMenuItem:setPosition(ccp(bg:getContentSize().width*1.03,bg:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    menu:addChild(closeMenuItem)
    _tabAry = {}
    for i=1,2 do
    	local tab = createBtn(tabStrAry[i])
    	tab:setPosition(ccp(179 + 241 * (i - 1),760))
    	menu:addChild(tab,1,i)
    	table.insert(_tabAry,tab)
    end
    _tabAry[1]:setEnabled(false)
   	_tableViewBg = CCScale9Sprite:create(_imagePath.tableViewBg)
    _tableViewBg:setContentSize(CCSizeMake(575,665))
    _tableViewBg:setAnchorPoint(ccp(0.5,0.5))
    _tableViewBg:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2-15))
    bg:addChild(_tableViewBg)
    createTableView()
end

--[[
	@des 	: 创建界面
	@param 	: 
	@return : 
--]]
function create()
	init()
	local layer = CCLayerColor:create(ccc4(11,11,11,166))
	layer:registerScriptTouchHandler(function (eventType,x,y)
		if eventType == "began" then
			return true
		end
	end,false,_touchPriority,true)
	layer:setTouchEnabled(true)
	initView(layer)
    return layer
end

--[[
	@des 	: 生成切换标签
	@param 	: 
	@return : 
--]]
function createBtn(text)
	local insertRect = CCRectMake(35,20,1,1)
   	local tapBtnN = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(211,43))
    local tapBtnH = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(211,53))
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(setCurPage)
    local label = CCRenderLabel:create(text, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    label:setColor(ccc3(0xfe, 0xdb, 0x1c))
    label:setAnchorPoint(ccp(0.5,0.5))
    label:setPosition(ccp(btn:getContentSize().width*0.5,btn:getContentSize().height*0.5))
   	btn:addChild(label) 
   	return btn
end
--[[
	@des 	: 设置当前页
	@param 	: index 
	@return : 
--]]
function setCurPage( tag )
	if tag == 1 then
		_tabAry[1]:setEnabled(false)
		_tabAry[2]:setEnabled(true)
		if _acticityName == kBounty then
			_currData = MissionRewardData.getRankData()
		else
			_currData = MissionRewardData.getPreliminaryData()
		end
	elseif tag == 2 then
		_tabAry[1]:setEnabled(true)
		_tabAry[2]:setEnabled(false)
		if _acticityName == kBounty then
			_currData = MissionRewardData.getPayData()
		else
			_currData = MissionRewardData.getFinalsData()
		end
	end
	_tableView:reloadData()
end

--[[
	@des 	: 创建table
	@param 	: 
	@return : 
--]]
function createTableView()
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(575, 210)
			elseif fn == "cellAtIndex" then
				ret = MissionRewardCell.create(_currData,a1 + 1)
			elseif fn == "numberOfCells" then
				ret = table.count(_currData)
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(575,661))
	_tableView:setTouchPriority(_touchPriority)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(0,2))
	_tableViewBg:addChild(_tableView)
end

--[[
	@des 	: 显示界面
	@param 	: 
	@return : 
--]]
function show(touchPriority,zOrder,activityName)
	_touchPriority = touchPriority or -512
	zOrder = zOrder or 512
	_acticityName = activityName or kBounty
	MissionRewardData.getDataByActName(_acticityName)
	local scene = CCDirector:sharedDirector():getRunningScene()
	_layer = create()
	scene:addChild(_layer,zOrder)
end
--[[
	@des 	: 关闭并清理
	@param 	: 
	@return : 
--]]
function closeCallBack()
	-- 播放关闭音效
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if _layer then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end