-- FileName: KFBWRewardLayer.lua 
-- Author: shengyixian
-- Date: 15-10-10
-- Purpose: 跨服比武奖励预览

module("KFBWRewardLayer", package.seeall)
require "script/ui/kfbw/kfbwreward/KFBWRewardCell"
require "script/ui/kfbw/kfbwreward/KFBWRewardData"
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

function init( ... )
	-- body
	_imagePath = {
		bg = "images/common/viewbg1.png",
		titlePanel = "images/common/viewtitle1.png",
		closeMenuItem_n = "images/common/btn_close_n.png",
		closeMenuItem_h = "images/common/btn_close_h.png",
		tableViewBg = "images/common/bg/bg_ng_attr.png",
		btn_blue_n = "images/common/btn/btn_blue_n.png",
		btn_blue_h = "images/common/btn/btn_blue_h.png",
    }
    _layer = nil
	_tableViewBg = nil
	_tableView = nil
end

function initView( layer )
	-- body
	-- 背景尺寸
	local bgSize = CCSizeMake(620,840)
	-- 背景缩放系数
    local bgScale = MainScene.elementScale
    -- 背景
    local bg = CCScale9Sprite:create(_imagePath.bg)
    bg:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bg:setAnchorPoint(ccp(0.5,0.5))
    bg:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height/2))
    bg:setScale(bgScale)
    layer:addChild(bg)
    -- 标题
    local titlePanel = CCSprite:create(_imagePath.titlePanel)
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bg:getContentSize().width/2, bg:getContentSize().height-6.6 ))
	bg:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1021"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
	-- 描述
	local des = GetLocalizeStringBy("key_3154")
    local desLabel = CCLabelTTF:create(des, g_sFontPangWa, 25)
    desLabel:setAnchorPoint(ccp(0, 0.5))
    desLabel:setPosition(ccpsprite(0.15 , 0.92, bg))
    desLabel:setColor(ccc3(0x78, 0x25, 0x00))
    bg:addChild(desLabel)
    -- 获取一二三四……字符串
    local daysAry = {}
    local index = 8106
    for i=1,7 do
    	index = index + 1
    	local week = GetLocalizeStringBy("key_"..index)
    	daysAry[i] = week
    end
    -- 判断结束时间是周几
    local day = KFBWRewardData.getCurrWeek()
    local dayLabel = CCRenderLabel:create(daysAry[day], g_sFontPangWa, 25, 1, ccc3(0,0,0))
    dayLabel:setAnchorPoint(ccp(0, 0.5))
    dayLabel:setPosition(ccpsprite(1.1 , 0.5, desLabel))
    dayLabel:setColor(ccc3(113, 246, 47))
    desLabel:addChild(dayLabel)
  	local des2 = GetLocalizeStringBy("syx_1025")
    local des2Label = CCLabelTTF:create(des2, g_sFontPangWa, 25)
    des2Label:setAnchorPoint(ccp(0, 0.5))
    des2Label:setPosition(ccpsprite(1.1 , 0.5, dayLabel))
    des2Label:setColor(ccc3(0x78, 0x25, 0x00))
    dayLabel:addChild(des2Label)
    -- 按钮层
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority-10)
    bg:addChild(menu)
    -- 关闭按钮
    local closeMenuItem = CCMenuItemImage:create(_imagePath.closeMenuItem_n, _imagePath.closeMenuItem_h)
    closeMenuItem:setPosition(ccp(bg:getContentSize().width*1.03,bg:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    menu:addChild(closeMenuItem)
   	_tableViewBg = CCScale9Sprite:create(_imagePath.tableViewBg)
    _tableViewBg:setContentSize(CCSizeMake(575,665))
    _tableViewBg:setAnchorPoint(ccp(0.5,0.5))
    _tableViewBg:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2-15))
    bg:addChild(_tableViewBg)
    createTableView()
end
--[[
	@des 	: 创建表示图
	@param 	: 
	@return : 
--]]
function createTableView()
	local rewardAry = KFBWRewardData.getRewardData()
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(575, 210)
			elseif fn == "cellAtIndex" then
				ret = KFBWRewardCell.create(rewardAry[a1 + 1])
			elseif fn == "numberOfCells" then
				ret = table.count(rewardAry)
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(575,661))
	_tableView:setTouchPriority(_touchPriority-5)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(0,2))
	_tableViewBg:addChild(_tableView)
end

function createLayer( ... )
	-- body
	init()
	local layer = CCLayerColor:create(ccc4(11,11,11,166))
	layer:registerScriptTouchHandler(function (eventType,x,y)
		if eventType == "began" then
			return true
		end
	end,false,_touchPriority,true)
	layer:setTouchEnabled(true)
	initView(layer)
	-- 界面层
    return layer
end

function showLayer( pTouchPriority,pZOrder )
	-- body
	_touchPriority = touchPriority or -555
	zOrder = zOrder or 512
	-- MissionRewardData.getTaskInfoByDB()
	local scene = CCDirector:sharedDirector():getRunningScene()
	_layer = createLayer()
	scene:addChild(_layer,zOrder)
end
--[[
	@des 	: 关闭并清理
	@param 	: 
	@return : 
--]]
function closeCallBack()
	-- body
	-- 播放关闭音效
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if _layer then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end
