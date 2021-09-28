-- Filename: GuildSkillLayer.lua
-- Author: lgx
-- Date: 2016-03-02
-- Purpose: 军团科技科技大厅界面

module("GuildSkillLayer", package.seeall)

require "script/ui/guild/guildskill/GuildSkillData"
require "script/ui/guild/guildskill/GuildSkillController"

local kBgLayerTag 	= 1000
local kBackItemTag 	= 1001
local kAdminItemTag = 1002

local _touchPriority 	= nil
local _zOrder 		 	= nil
local _bgLayer 		 	= nil
local _skillTableView 	= nil
local _bookLabel 		= nil

--[[
	@desc:	初始化方法
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_skillTableView  = nil
	_bookLabel 		 = nil
end

--[[
	@desc:	显示界面方法
--]]
function show( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -700
	_zOrder = pZorder or 700
	-- 使用MainSence.changeLayer进入
    local guildSkillLayer = createLayer(_touchPriority, _zOrder)
	MainScene.changeLayer(guildSkillLayer, "GuildSkillLayer")
end

--[[
	@desc:	背景层触摸回调
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc: 回调onEnter和onExit事件
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
	end
end

--[[
	@desc:	创建层级Layer
--]]
function createLayer( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -700
	_zOrder = pZorder or 700

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	local bgSprite = CCSprite:create("images/guild/guildskill/guildskill_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 科技大厅
	local skillTitleSp = CCSprite:create("images/guild/guildskill/guildskill_title.png")
    skillTitleSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.90))
    skillTitleSp:setAnchorPoint(ccp(0.5,0.5))
    skillTitleSp:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(skillTitleSp)

	-- 返回按钮Menu
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setTouchPriority(_touchPriority-30)
    _bgLayer:addChild(backMenu, 10)

   	local isShow = GuildSkillData.getIsGuildAdmin()
   	if (isShow == true) then
   		-- 管理按钮
	   	local adminItem = CCMenuItemImage:create("images/guild/btn_manager_n.png","images/guild/btn_manager_h.png")
	    adminItem:setScale(g_fElementScaleRatio)
	    adminItem:setAnchorPoint(ccp(0,0.5))
	    adminItem:setPosition(ccp(20,_bgLayer:getContentSize().height*0.92))
	    adminItem:registerScriptTapHandler(adminItemCallback)
	    backMenu:addChild(adminItem,1,kAdminItemTag)
   	end

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backItem:setScale(g_fElementScaleRatio)
    backItem:setAnchorPoint(ccp(1,0.5))
    backItem:setPosition(ccp(_bgLayer:getContentSize().width-20,_bgLayer:getContentSize().height*0.92))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1,kBackItemTag)

    -- 资源信息
    local fullRect = CCRectMake(0,0,112,29)
	local insertRect = CCRectMake(10,5,92,19)
    local bookBg = CCScale9Sprite:create("images/recharge/feedback_active/time_bg.png",fullRect,insertRect)
    bookBg:setPreferredSize(CCSizeMake(380,50))
    bookBg:setScale(g_fElementScaleRatio)
 	bookBg:setAnchorPoint(ccp(0.5,1))
 	bookBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.86))
 	_bgLayer:addChild(bookBg)

 	-- bookline
	local bookLine = CCScale9Sprite:create("images/common/line02.png")
	bookLine:setContentSize(CCSizeMake(380, 4))
	bookLine:setScale(g_fElementScaleRatio)
	bookLine:setAnchorPoint(ccp(0.5, 0.5))
	bookLine:setPosition(ccp(_bgLayer:getContentSize().width*0.5, bookBg:getPositionY()-bookBg:getContentSize().height*g_fElementScaleRatio))
	_bgLayer:addChild(bookLine)

    local totalBook = CCRenderLabel:create(GetLocalizeStringBy("lgx_1012"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    totalBook:setColor(ccc3(0xff, 0xff, 0xff))
    local bookNumber = CCRenderLabel:create(UserModel.getBookNum(), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    bookNumber:setColor(ccc3(0x00,0xff,0x18))
    local bookIcon = CCSprite:create("images/common/book_small.png")

    _bookLabel = BaseUI.createHorizontalNode({totalBook,bookIcon,bookNumber})
    _bookLabel:setAnchorPoint(ccp(0.5, 1))
    _bookLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.85))
    _bookLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_bookLabel,2)

    -- 提示文字
    local noticeLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1019") , g_sFontPangWa,18,1, ccc3(0x00,0x00,0x00), type_stroke)
    noticeLabel:setColor(ccc3(0xff,0xe4,0x00))
    noticeLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,bookLine:getPositionY()-bookLine:getContentSize().height*0.5-10*g_fElementScaleRatio))
    noticeLabel:setAnchorPoint(ccp(0.5,1))
    noticeLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(noticeLabel)

    -- 科技列表
    createSkillTableView()

    -- 底部虚化背景
    local bottomSprite = CCSprite:create("images/guild/guildskill/bottom_bg.png")
	bottomSprite:setAnchorPoint(ccp(0.5,0))
	bottomSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	bottomSprite:setScaleX(_bgLayer:getContentSize().width/bottomSprite:getContentSize().width)
	bottomSprite:setScaleY(1.5*g_fElementScaleRatio)
	_bgLayer:addChild(bottomSprite,2)

    return _bgLayer
end

--[[
	@desc:	创建科技列表
--]]
function createSkillTableView()
	-- 根据科技类型获取科技列表
	local skillListData = GuildSkillData.getGuildSkillInfo(GuildSkillData.kTypeMember)

	local cellSize = CCSizeMake(590,185)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

	local createTableCallback = function(fn, t_table, a1, a2)
		require "script/ui/guild/guildskill/GuildSkillCell"
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = GuildSkillCell.createCell(skillListData[a1 + 1])
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #skillListData
		elseif fn == "cellTouched" then
			
		end
		return r
	end
	local bgHeight = _bgLayer:getContentSize().height
	local bookLabelY = _bookLabel:getPositionY()
	local bookLabelH = _bookLabel:getContentSize().height
	local tableViewH = bgHeight-(bgHeight-bookLabelY)-bookLabelH*g_fElementScaleRatio-70*g_fElementScaleRatio
	_skillTableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(_bgLayer:getContentSize().width-50,tableViewH))
	_skillTableView:setBounceable(true)
	_skillTableView:setAnchorPoint(ccp(0, 0))
	_skillTableView:setPosition(ccp(25*g_fScaleX, 20))
	_bgLayer:addChild(_skillTableView)
	_skillTableView:setTouchPriority(_touchPriority-60)
end

--[[
	@desc:	更新天书的数量及科技列表
--]]
function updateUI()
	if(tolua.cast(_bgLayer,"CCLayer") == nil )then 
		return
	end
	if(_bookLabel)then
		_bookLabel:removeFromParentAndCleanup(true)
		_bookLabel = nil
	end
	local totalBook = CCRenderLabel:create(GetLocalizeStringBy("lgx_1012"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    totalBook:setColor(ccc3(0xff, 0xff, 0xff))
    local bookNumber = CCRenderLabel:create(UserModel.getBookNum(), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    bookNumber:setColor(ccc3(0x00,0xff,0x18))
    local bookIcon = CCSprite:create("images/common/book_small.png")

    _bookLabel = BaseUI.createHorizontalNode({totalBook, bookIcon, bookNumber})
    _bookLabel:setAnchorPoint(ccp(0.5, 1))
    _bookLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.85))
    _bookLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_bookLabel,2)

    -- 刷新科技列表
    updateSkillTableView()
end

--[[
	@desc:	更科技列表
--]]
function updateSkillTableView()
	local contentOffset = _skillTableView:getContentOffset()
    _skillTableView:reloadData()
    _skillTableView:setContentOffset(contentOffset)
end

--[[
	@desc:	管理按钮回调,进入军团全队科技界面
--]]
function adminItemCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/guildskill/GuildSkillAdminLayer"
	GuildSkillAdminLayer.show(_touchPriority-100,_zOrder+100)
end

--[[
	@desc:	返回按钮回调,关闭界面
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end