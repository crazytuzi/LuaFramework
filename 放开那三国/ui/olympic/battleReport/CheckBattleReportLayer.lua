-- Filename: CheckBattleReportLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-07-16
-- Purpose: 擂台争霸战报

module("CheckBattleReportLayer",package.seeall)

require "script/ui/olympic/battleReport/ReportTableView"
require "script/audio/AudioUtil"

local _touchPriority 		--触摸优先级
local _ZOrder				--Z轴
local _bgLayer 				--触摸屏蔽层
local _wholeMenuItem		--战体战报按钮
local _personalMenuItem		--个人战报按钮
local _currentTag 			--当前的界面Tag，防止按钮重复点击重复创建窗口
local _brownSprite 			--二级背景，方便更改tableView
local _allReportTable 		--所有战报table
local _personalTable 		--个人战报table
local kWholeTag = 1001		--整体界面tag
local kPersonalTag = 1002 	--个人界面tag

----------------------------------------初始化函数----------------------------------------
local function init()
	_touchPriority = nil
	_ZOrder = nil
	_bgLayer = nil
	_wholeMenuItem = nil
	_personalMenuItem = nil
	_brownSprite = nil
	_currentTag = kWholeTag
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:战报选择按钮回调
	@param 	:按钮tag
	@return :
--]]
--本可以不这么复杂，想用reloadData()解决问题，结果发现用global变量不管用
function reportMenuCallBack(tag)
	--点击了整体战报按钮
	if tag == kWholeTag then
		_wholeMenuItem:selected()
		_personalMenuItem:unselected()

		--为了防止重复创建窗口
		if _currentTag ~= kWholeTag then
			_brownSprite:removeChildByTag(kPersonalTag,true)

			local wholeTableView = ReportTableView.createWholeTableView(_allReportTable)
			wholeTableView:setAnchorPoint(ccp(0,0))
			wholeTableView:setPosition(ccp(0,0))
			wholeTableView:setTouchPriority(_touchPriority - 1)
			_brownSprite:addChild(wholeTableView,1,kWholeTag)
			
			_currentTag = kWholeTag
		end
	--点击了个人战报按钮
	elseif tag == kPersonalTag then
		_personalMenuItem:selected()
		_wholeMenuItem:unselected()

		--为了防止重复创建窗口
		if _currentTag ~= kPersonalTag then
			_brownSprite:removeChildByTag(kWholeTag,true)
			
			local personalTableView = ReportTableView.createPersonalTableView(_personalTable)
			personalTableView:setAnchorPoint(ccp(0,0))
			personalTableView:setPosition(ccp(0,0))
			personalTableView:setTouchPriority(_touchPriority - 1)
			_brownSprite:addChild(personalTableView,1,kPersonalTag)
			
			_currentTag = kPersonalTag
		end
	else
		print("点击无反应")
	end
end


function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end
----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	require "script/ui/main/MainScene"
	local bgSize = CCSizeMake(600,700)
	local bgScale = MainScene.elementScale

	--主背景图
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
	bgSprite:setScale(bgScale)
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleSprite)

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3414"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
	titleSprite:addChild(titleLabel)

	--棕色背景
	_brownSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_brownSprite:setContentSize(CCSizeMake(555,560))
	_brownSprite:setAnchorPoint(ccp(0.5,0))
	_brownSprite:setPosition(ccp(bgSprite:getContentSize().width/2,50))
	bgSprite:addChild(_brownSprite)

	local bgMenu = CCMenu:create()
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	--按钮标签初始化内容

	--按钮图片
	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	--九宫格参数
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	--按钮明暗大小
	local btn_size_n	= CCSizeMake(255, 50)
	local btn_size_h	= CCSizeMake(260, 55)
	--文字颜色
	local text_color_n	= ccc3(0xf2, 0xe0, 0xcc)
	local text_color_h	= ccc3(0xff, 0xff, 0xff)
	--字体，大小
	local font			= g_sFontPangWa
	local font_size		= 30
	--描边颜色
	local strokeCor_n	= ccc3(0xf2, 0xe0, 0xcc)
	local strokeCor_h	= ccc3(0x00, 0x00, 0x00)
	--描边深度
	local stroke_size_n	= 0
    local stroke_size_h = 1

    --整体战报按钮
    _wholeMenuItem = LuaCCMenuItem.createMenuItemOfRender2(image_n,image_h,nil,
    	rect_full_n,rect_inset_n,rect_full_h,rect_inset_h,nil,nil,
    	btn_size_n,btn_size_h,nil,GetLocalizeStringBy("zzh_1030"),
    	text_color_n,text_color_h,nil,font,font_size,
    	strokeCor_n,strokeCor_h,nil,stroke_size_n,stroke_size_h,nil)
    _wholeMenuItem:setAnchorPoint(ccp(0,0))
    _wholeMenuItem:setPosition(ccp(38,_brownSprite:getContentSize().height+50))
    --初始状态为选中状态
    _wholeMenuItem:selected()
    _wholeMenuItem:registerScriptTapHandler(reportMenuCallBack)
    bgMenu:addChild(_wholeMenuItem,1,kWholeTag)

    --个人战报按钮
    _personalMenuItem = LuaCCMenuItem.createMenuItemOfRender2(image_n,image_h,nil,
    	rect_full_n,rect_inset_n,rect_full_h,rect_inset_h,nil,nil,
    	btn_size_n,btn_size_h,nil,GetLocalizeStringBy("zzh_1031"),
    	text_color_n,text_color_h,nil,font,font_size,
    	strokeCor_n,strokeCor_h,nil,stroke_size_n,stroke_size_h,nil)
    _personalMenuItem:setAnchorPoint(ccp(1,0))
    _personalMenuItem:setPosition(ccp(bgSprite:getContentSize().width - 38,_brownSprite:getContentSize().height+50))
    --初始为未选中状态
    _personalMenuItem:unselected()
    _personalMenuItem:registerScriptTapHandler(reportMenuCallBack)
    bgMenu:addChild(_personalMenuItem,1,kPersonalTag)

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

    --创建整体战报的tableView
    local originalTableView = ReportTableView.createWholeTableView(_allReportTable)
	originalTableView:setAnchorPoint(ccp(0,0))
	originalTableView:setPosition(ccp(0,0))
	originalTableView:setTouchPriority(_touchPriority - 1)
	_brownSprite:addChild(originalTableView,1,kWholeTag)
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_ZOrder)
	init()

	_touchPriority = p_touchPriority or -300
	_ZOrder = p_ZOrder or 100

	--触摸屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_ZOrder)

    serviceCallBack = function()
    	--获得战报信息
    	_allReportTable,_personalTable = OlympicData.getAllReportInfo()
    	print("处理后的战报信息")
    	print_t(_allReportTable)
    	print("个人战报信息")
    	print_t(_personalTable)
    	--创建背景UI
		createBgUI()
    end

    require "script/ui/olympic/OlympicService"
    OlympicService.getFightInfo(serviceCallBack)
end

--总感觉在UI层写工具函数怪怪的，不过这个也只能放在这里了吧
----------------------------------------工具函数----------------------------------------
--[[
	@des 	:得到触摸优先级
	@param 	:
	@return :触摸优先级
--]]
function getTouchPriority()
	return _touchPriority
end