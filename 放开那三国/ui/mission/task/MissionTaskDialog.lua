-- FileName: MissonTaskDialog.lua
-- Author: shengyixian
-- Date: 2015-08-28
-- Purpose: 悬赏榜任务
module("MissionTaskDialog",package.seeall)
require "script/ui/mission/task/MissionTaskCell"
require "script/ui/mission/task/MissionTaskData"
--界面层
local _layer = nil
--图片路径
local _imgPath = nil
--表示图
local _tableView = nil
--触摸优先级
local _touchPriority = nil
-- 累计名望值文本
local _totalFameLabel = nil
--[[
	@des 	: 初始化变量
	@param 	: 
	@return : 
--]]
function init()
	_imgPath = "images/everyday/"
	_layer = nil
	_tableView = nil
	_totalFameLabel = nil
end
--[[
	@des 	:初始化视图
	@param 	: 
	@return : 
--]]
function initView( ... )
	-- 背景尺寸
	local bgSize = CCSizeMake(628,797)
	-- 背景缩放系数
    local bgScale = MainScene.elementScale

	-- 背景
	local backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    backGround:setAnchorPoint(ccp(0.5,0.5))
    backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5 - 24))
    backGround:setContentSize(bgSize)
    _layer:addChild(backGround)
    backGround:setScale(bgScale)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(backGround:getContentSize().width/2, backGround:getContentSize().height-6.6 ))
	backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizedSourceStringsByKey("lcyx_1930"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(backGround:getContentSize().width * 0.955, backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 表示图背景
	local rect = CCRectMake(0,0,75,75)
	local insert = CCRectMake(28,28,6,6)
	_tableViewSp = CCScale9Sprite:create("images/sign/tableBg.png",rect,insert)
	_tableViewSp:setPreferredSize(CCSizeMake(574,630))
	_tableViewSp:setAnchorPoint(ccp(0.5,0.5))
	_tableViewSp:setPosition(ccp(309,437))
	backGround:addChild(_tableViewSp)

	-- 累计名望值文本
	_totalFameLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1001",MissionTaskData.getTotalFameValue()),g_sFontPangWa,25)
	_totalFameLabel:setColor(ccc3( 0xa1, 0x35, 0x00))
	_totalFameLabel:setAnchorPoint(ccp(0.5,0.5))
	_totalFameLabel:setPosition(ccp(bgSize.width / 2,87))
	backGround:addChild(_totalFameLabel)
	--  名望任务每日重置说明
	local explainLabel = CCLabelTTF:create(GetLocalizedSourceStringsByKey("syx_1002"),g_sFontPangWa,25)
	explainLabel:setColor(ccc3( 0xa1, 0x35, 0x00))
	explainLabel:setAnchorPoint(ccp(0.5,0.5))
	explainLabel:setPosition(ccp(bgSize.width / 2,50))
	backGround:addChild(explainLabel)
	createTableView()
end

--[[
	@des 	:创建界面
	@param 	: 
	@return : 
--]]
function create()
	init()
	_layer = CCLayerColor:create(ccc4(11,11,11,166))
	_layer:registerScriptTouchHandler(function (eventType,x,y)
		if eventType == "began" then
			--todo
			return true
		end
	end,false,_touchPriority,true)
	_layer:setTouchEnabled(true)
	initView()
	return _layer
end

function showLayer(touchPriority,zOrder)
    MissionTaskData.getTaskProgressInfo(function ()
		_touchPriority = touchPriority or -512
		zOrder = zOrder or 512
		local scene = CCDirector:sharedDirector():getRunningScene()
	    local layer = create()
	    scene:addChild(layer,zOrder,1231)
    end)
end

--[[
	@des 	: 创建表示图
	@param 	: 
	@return : 
--]]
function createTableView()
	local cellSize = CCSizeMake(574, 164)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(cellSize.width,cellSize.height)
			elseif fn == "cellAtIndex" then
				-- print(a1)
				ret =  MissionTaskCell.createCell(MissionTaskData.getTaskInfo()[a1 + 1])
			elseif fn == "numberOfCells" then
				ret = #(MissionTaskData.getTaskInfo())
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(574,620))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(_touchPriority)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(0,5))
	_tableViewSp:addChild(_tableView)
end

--[[
	@des 	: 关闭
	@param 	: 
	@return : 
--]]
function closeButtonCallback()
	-- 播放关闭音效
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if _layer then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end