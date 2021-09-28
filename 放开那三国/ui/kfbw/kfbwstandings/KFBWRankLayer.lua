-- FileName: KFBWRankLayer.lua
-- Author: shengyixian
-- Date: 2015-10-12
-- Purpose: 跨服排行榜
module("KFBWRankLayer",package.seeall)
require "script/ui/kfbw/kfbwstandings/KFBWRankCell"
require "script/ui/purgatorychallenge/STPurgatoryRankLayer"

local _layer = nil
local _touchPriority = -411
-- 表示图背景
local _tableViewBg = nil
-- 表示图
local _tableView = nil
-- 资源路径
local _imagePath = nil
-- 当前图示的内容标签,显示跨服奖励时值为“KF”；显示服内奖励时值为“FN”
local _contentType = nil
-- 跨服奖励按钮
local _kfBtn = nil
-- “跨服奖励”的标识
local KF = "KF"
-- 服内奖励按钮
local _fnBtn = nil
-- ”服内奖励“的标识
local FN = "FN"
-- 当前显示内容的数据
local _currData = nil

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
		tap_btn_n = "images/common/btn/tab_button/btn1_n.png",
		tap_btn_h = "images/common/btn/tab_button/btn1_h.png"
    }
    -- 默认显示排行奖励
    _contentType = KF
    _layer = nil
	_tableViewBg = nil
	_tableView = nil
	_kfBtn = nil
	_fnBtn = nil
end

function initView( layer )
	-- body
	_currData = KuafuData.getCrossRankData()
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10256"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
	-- 跨服排行描述
	local rankDes = GetLocalizeStringBy("lcyx_1968")
    local rankDesLabel = CCLabelTTF:create(rankDes, g_sFontPangWa, 25)
    rankDesLabel:setAnchorPoint(ccp(0, 0.5))
    rankDesLabel:setPosition(ccpsprite(0.12 , 0.93, bg))
    rankDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
    bg:addChild(rankDesLabel)
    local mineRank = tonumber(KuafuData.getUserCrossRank())
    local rank = mineRank <=0 and GetLocalizeStringBy("lcyx_1969") or mineRank
    local rankLabel = CCRenderLabel:create(rank, g_sFontPangWa, 25, 1, ccc3(0,0,0))
    rankLabel:setAnchorPoint(ccp(0, 0.5))
    rankLabel:setPosition(ccpsprite(1.1 , 0.5, rankDesLabel))
    rankLabel:setColor(ccc3(113, 246, 47))
    rankDesLabel:addChild(rankLabel)
    -- 服内排行描述
   	local innerRankDes = GetLocalizeStringBy("key_10268")
    local innerRankDesLabel = CCLabelTTF:create(innerRankDes, g_sFontPangWa, 25)
    innerRankDesLabel:setAnchorPoint(ccp(0, 0.5))
    innerRankDesLabel:setPosition(ccpsprite(0.5 , 0.5, rankDesLabel))
    innerRankDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
    rankLabel:addChild(innerRankDesLabel)
    local mineInnerRank = tonumber(KuafuData.getUserInnerRank())
    local innerRank = mineInnerRank <=0 and GetLocalizeStringBy("lcyx_1969") or mineInnerRank
    local innerRankLabel = CCRenderLabel:create(innerRank, g_sFontPangWa, 25, 1, ccc3(0,0,0))
    innerRankLabel:setAnchorPoint(ccp(0, 0.5))
    innerRankLabel:setPosition(ccpsprite(1.0 , 0.5, innerRankDesLabel))
    innerRankLabel:setColor(ccc3(113, 246, 47))
    innerRankDesLabel:addChild(innerRankLabel)
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
    -- 查看跨服奖励的按钮
    _kfBtn = createBtn(GetLocalizeStringBy("key_10254"))
    _kfBtn:setPosition(ccp(179,730))
    _kfBtn:setEnabled(false)
    menu:addChild(_kfBtn,1,1)
    -- 查看服内奖励的按钮
    _fnBtn = createBtn(GetLocalizeStringBy("key_10255"))
    _fnBtn:setPosition(ccp(420,730))
    menu:addChild(_fnBtn,1,2)
   	_tableViewBg = CCScale9Sprite:create(_imagePath.tableViewBg)
    _tableViewBg:setContentSize(CCSizeMake(575,652))
    _tableViewBg:setAnchorPoint(ccp(0.5,0.5))
    _tableViewBg:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2-35))
    bg:addChild(_tableViewBg)
    createTableView()
end
--[[
	@des 	: 创建表示图
	@param 	: 
	@return : 
--]]
function createTableView()
	-- local rankData = KuafuData.getCrossRankData()
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(575, 115)
			elseif fn == "cellAtIndex" then
				ret = KFBWRankCell.create(_currData[a1 + 1])
			elseif fn == "numberOfCells" then
				ret = table.count(_currData)
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(575,632))
	_tableView:setTouchPriority(_touchPriority)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(0,10))
	_tableViewBg:addChild(_tableView)
	_tableView:reloadData()
end
--[[
	@des 	: 生成切换按钮
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
    btn:registerScriptTapHandler(viewSwitchHandler)
    local label = CCRenderLabel:create(text, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    label:setColor(ccc3(0xfe, 0xdb, 0x1c))
    label:setAnchorPoint(ccp(0.5,0.5))
    label:setPosition(ccp(btn:getContentSize().width*0.5,btn:getContentSize().height*0.5))
   	btn:addChild(label) 
   	return btn
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
    return layer
end
--[[
	@des 	: 切换表示图的内容：跨服奖励或服内奖励
	@param 	: 
	@return : 
--]]
function viewSwitchHandler(tag,item)
	-- body
	if tag == 1 then
		--todo
		print("跨服奖励")
		setContentType(KF)
	elseif tag == 2 then
		print("服内奖励")
		setContentType(FN)
	end
end
--[[
	@des 	: 设置当前图示的内容标识，如果当前值被改变了，就刷新表示图，否则不作操作
	@param 	: 
	@return : 
--]]
function setContentType(value)
	-- body
	if (_contentType ~= value) then
		_contentType = value
		if (_contentType == KF) then
			_kfBtn:setEnabled(false)
			_fnBtn:setEnabled(true)
			_currData = KuafuData.getCrossRankData()
		else
			_kfBtn:setEnabled(true)
			_fnBtn:setEnabled(false)
			_currData = KuafuData.getInnerRankData()
		end
		if(_tableView) then
			_tableView:removeFromParentAndCleanup(true)
			createTableView()
		end
	end
end

function showLayer( pTouchPriority,pZOrder )
	-- body
	KuafuController.getRankList(function ( ... )
		-- body
		_touchPriority = touchPriority or -555
		zOrder = zOrder or 512
		local scene = CCDirector:sharedDirector():getRunningScene()
		_layer = createLayer()
		scene:addChild(_layer,zOrder)
	end)
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