-- Filename: MasterRecordLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-08-07
-- Purpose: 宗师录界面

module("MasterRecordLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/main/BulletinLayer"
require "script/libs/LuaCCLabel"
require "script/ui/replaceSkill/MasterRecord/MasterTableView"
require "script/ui/replaceSkill/ReplaceSkillData"

local _bgLayer 				--背景层
local _curTag 				--当前选择下标
local _secondBgMenu			--二级界面按钮层
local _secondBgSprite 		--二级背景框
local kSelectedTag = 1000	--选择按钮tag
local kTableViewTag = 2000 	--tableView的tag

----------------------------------------初始化函数----------------------------------------
local function init()
	_bgLayer = nil
	_curTag = nil
	_secondBgMenu = nil
	_secondBgSprite = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onNodeEvent(event)
	if (event == "enter") then
		print("enter event")
	elseif (event == "exit") then
		print("exit event")
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:关闭回调
	@param 	:
	@return :
--]]
function closeCallback()
	require "script/ui/replaceSkill/ReplaceSkillLayer"
	ReplaceSkillLayer.showLayer()
end

--[[
	@des 	:选择按钮回调
	@param 	:按钮下标
	@return :
--]]
function selectCallBack(tag)
	--选中被点击的
	--如果放在if条件判断里，则在重复点击时还会点一下闪一下
	--因此挪到外面了
	local curMenuItem = _secondBgMenu:getChildByTag(tag)
	curMenuItem:selected()
	--如果点击的，不是和原来一样的按钮
	if tag ~= _curTag then
		--上一个被点击的还原
		local otherMenuItem = tolua.cast(_secondBgMenu:getChildByTag(_curTag),"CCMenuItemSprite")
		otherMenuItem:unselected() 

		_secondBgSprite:removeChildByTag(_curTag - kSelectedTag + kTableViewTag,true)

		--传入相应国家的宗师信息，进行创建TableView
		local tagTableView = MasterTableView.createTableView(ReplaceSkillData.getMasterByCountry(tag - kSelectedTag))
		tagTableView:setAnchorPoint(ccp(0,0))
		tagTableView:setPosition(ccp(0,0))
		_secondBgSprite:addChild(tagTableView,1,tag - kSelectedTag + kTableViewTag)

		_curTag = tag
	end
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--通知栏和菜单栏大小
	local bulletSize = BulletinLayer.getLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	--背景高度
	local bgHeight = g_winSize.height - bulletSize.height*g_fScaleX - menuLayerSize.height*g_fScaleX

	--背景图
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	local bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png",fullRect,insetRect)
	bgSprite:setContentSize(CCSizeMake(g_winSize.width,bgHeight))
	bgSprite:setAnchorPoint(ccp(0.5,0))
	bgSprite:setPosition(ccp(g_winSize.width/2,menuLayerSize.height*g_fScaleX))
	_bgLayer:addChild(bgSprite)

	--标题背景图
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height))
	topSprite:setScale(g_fScaleX)
	bgSprite:addChild(topSprite)

	--标题文字
	local titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("zz_34"), g_sFontPangWa, 35)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(topSprite:getContentSize().width/2, topSprite:getContentSize().height* 0.6))
	topSprite:addChild(titleLabel)

	--二级背景框
	_secondBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_secondBgSprite:setContentSize(CCSizeMake(bgSprite:getContentSize().width*600/640,bgSprite:getContentSize().height*530/810))
	_secondBgSprite:setAnchorPoint(ccp(0.5,1))
	_secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 130*MainScene.elementScale))
	bgSprite:addChild(_secondBgSprite)

	--5个选择按钮
	--按钮图片
	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	--九宫格参数
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	--按钮明暗大小
	local btn_size_n	= CCSizeMake(110, 50)
	local btn_size_h	= CCSizeMake(115, 55)
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

    --标签按钮层
	_secondBgMenu = CCMenu:create()
	_secondBgMenu:setPosition(ccp(0, 0))
	_secondBgMenu:setAnchorPoint(ccp(0, 0))
	_secondBgSprite:addChild(_secondBgMenu)

	local baseX = 70*MainScene.elementScale
	local gapLength = (_secondBgSprite:getContentSize().width - 2*baseX)/4

	local menuLabelTable = {
								[1] = "zzh_1070",
								[2] = "key_1609",
								[3] = "key_3189",
								[4] = "key_1305",
								[5] = "zzh_1071",
						   }

	--五个标签
	for i = 1,5 do
		local selectMenuItem = LuaCCMenuItem.createMenuItemOfRender2(image_n,image_h,rect_full_n,rect_inset_n,rect_full_h,rect_inset_h,btn_size_n,btn_size_h,GetLocalizeStringBy(menuLabelTable[i]),text_color_n,text_color_h,font,font_size,strokeCor_n,strokeCor_h,stroke_size_n,stroke_size_h)
	    selectMenuItem:setAnchorPoint(ccp(0.5,0))
	    selectMenuItem:setPosition(ccp(baseX + gapLength*(i - 1),_secondBgSprite:getContentSize().height))
	    selectMenuItem:setScale(MainScene.elementScale)
	    --初始化第一个按钮为选中状态
	    if i == 1 then
	    	--当前选中为第一个按钮
	    	_curTag = kSelectedTag + 1
	    	selectMenuItem:selected()
	    else
	    	selectMenuItem:unselected()
	    end
	    selectMenuItem:registerScriptTapHandler(selectCallBack)
	    _secondBgMenu:addChild(selectMenuItem,1,kSelectedTag + i)
	end

	local masterTipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1072"),g_sFontPangWa,23)
	masterTipLabel:setColor(ccc3(0x78,0x25,0x00))
	masterTipLabel:setAnchorPoint(ccp(0.5,0))
	masterTipLabel:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height*110/810))
	masterTipLabel:setScale(MainScene.elementScale)
	bgSprite:addChild(masterTipLabel)

	--创建所有武将预览的TableView
	local allTableView = MasterTableView.createTableView(ReplaceSkillData.getMasterByCountry(1))
	allTableView:setAnchorPoint(ccp(0,0))
	allTableView:setPosition(ccp(0,0))
	_secondBgSprite:addChild(allTableView,1,kTableViewTag + 1)

	--关闭按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setPosition(ccp(0, 0))
	bgMenu:setAnchorPoint(ccp(0, 0))
	bgSprite:addChild(bgMenu)

	--关闭按钮
	local returnMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("zz_36"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	returnMenuItem:setAnchorPoint(ccp(0.5,0))
	returnMenuItem:setPosition(ccp(bgSprite:getContentSize().width/2,30*MainScene.elementScale))
	returnMenuItem:setScale(MainScene.elementScale)
	returnMenuItem:registerScriptTapHandler(closeCallback)
	bgMenu:addChild(returnMenuItem)
end



----------------------------------------入口函数----------------------------------------
function show()
	local replaceLayer = createLayer()
	MainScene.changeLayer(replaceLayer,"MasterRecordLayer")
end

function createLayer()
	init()

	-- --将宗师按照国家分类
	-- if table.isEmpty(ReplaceSkillData.getMasterByCountry(1)) then
	-- 	ReplaceSkillData.dealMasterByCountry()
	-- end

	--主角信息栏不可见，菜单栏可见
	MainScene.getAvatarLayerObj():setVisible(false)

	MenuLayer.getObject():setVisible(true)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	--一个防走光的背景图
	local bottomSprite = CCSprite:create("images/main/module_bg.png")
	bottomSprite:setAnchorPoint(ccp(0.5,0.5))
	bottomSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
	bottomSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bottomSprite)

	--创建背景UI
	createBgUI()

	return _bgLayer
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:返回二级背景大小
	@param 	:
	@return :二级背景大小
--]]
function getSecondBgSize()
	return _secondBgSprite:getContentSize()
end