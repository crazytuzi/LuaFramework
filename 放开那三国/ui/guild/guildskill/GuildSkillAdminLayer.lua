-- Filename: GuildSkillAdminLayer.lua
-- Author: lgx
-- Date: 2016-03-08
-- Purpose: 军团科技管理界面

module("GuildSkillAdminLayer", package.seeall)

require "script/ui/guild/guildskill/GuildSkillData"

local kBgLayerTag 	= 1000
local kBackItemTag 	= 1001

local _touchPriority 	= nil
local _zOrder 		 	= nil
local _bgLayer 		 	= nil
local _skillTableView 	= nil
local _donateLabel 		= nil

--[[
	@desc:	初始化方法
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_skillTableView  = nil
	_donateLabel 	 = nil
end

--[[
	@desc:	显示界面方法
--]]
function show( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -776
	_zOrder = pZorder or 776
	local scene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer(_touchPriority, _zOrder)
    scene:addChild(layer,_zOrder,kBgLayerTag)
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
	_touchPriority = pTouchPriority or -776
	_zOrder = pZorder or 776

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

	-- 退出管理按钮Menu
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setTouchPriority(_touchPriority-30)
    _bgLayer:addChild(backMenu, 10)

    -- 退出管理按钮
    local backItem = CCMenuItemImage:create("images/guild/guildskill/backskill_btn_n.png","images/guild/guildskill/backskill_btn_h.png")
    backItem:setScale(g_fElementScaleRatio)
    backItem:setAnchorPoint(ccp(0,0.5))
    backItem:setPosition(ccp(20,_bgLayer:getContentSize().height*0.92))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1,kBackItemTag)

    -- 资源信息
 	local fullRect = CCRectMake(0,0,112,29)
	local insertRect = CCRectMake(10,5,92,19)
    local donateBg = CCScale9Sprite:create("images/recharge/feedback_active/time_bg.png",fullRect,insertRect)
    donateBg:setPreferredSize(CCSizeMake(380,50))
    donateBg:setScale(g_fElementScaleRatio)
 	donateBg:setAnchorPoint(ccp(0.5,1))
 	donateBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.86))
 	_bgLayer:addChild(donateBg)

 	-- donateline
	local donateLine = CCScale9Sprite:create("images/common/line02.png")
	donateLine:setContentSize(CCSizeMake(380, 4))
	donateLine:setScale(g_fElementScaleRatio)
	donateLine:setAnchorPoint(ccp(0.5, 0.5))
	donateLine:setPosition(ccp(_bgLayer:getContentSize().width*0.5, donateBg:getPositionY()-donateBg:getContentSize().height*g_fElementScaleRatio))
	_bgLayer:addChild(donateLine)

    -- 总建设度
    local totalDonate = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    totalDonate:setColor(ccc3(0xff, 0xff, 0xff))
    local donateNumber = CCRenderLabel:create(GuildDataCache.getGuildDonate(), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    donateNumber:setColor(ccc3(0x00,0xff,0x18))

    _donateLabel = BaseUI.createHorizontalNode({totalDonate, donateNumber})
    _donateLabel:setAnchorPoint(ccp(0.5, 1))
    _donateLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.85))
    _donateLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_donateLabel,2)

    -- 提示文字
    local noticeLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1018") , g_sFontPangWa,18,1, ccc3(0x00,0x00,0x00), type_stroke)
    noticeLabel:setColor(ccc3(0xff,0xe4,0x00))
    noticeLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,donateLine:getPositionY()-donateLine:getContentSize().height*0.5-10*g_fElementScaleRatio))
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
	local skillListData = GuildSkillData.getGuildSkillInfo(GuildSkillData.kTypeGroup)
	
	local cellSize = CCSizeMake(590,185)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

	local createTableCallback = function(fn, t_table, a1, a2)
		require "script/ui/guild/guildskill/GuildSkillAdminCell"
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = GuildSkillAdminCell.createCell(skillListData[a1 + 1],2)
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #skillListData
		elseif fn == "cellTouched" then
			
		end
		return r
	end
	local bgHeight = _bgLayer:getContentSize().height
	local donateLabelY = _donateLabel:getPositionY()
	local donateLabelH = _donateLabel:getContentSize().height
	local tableViewH = bgHeight-(bgHeight-donateLabelY)-donateLabelH*g_fElementScaleRatio-70*g_fElementScaleRatio
	_skillTableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(_bgLayer:getContentSize().width-50,tableViewH))
	_skillTableView:setBounceable(true)
	_skillTableView:setAnchorPoint(ccp(0, 0))
	_skillTableView:setPosition(ccp(25*g_fScaleX, 20))
	_bgLayer:addChild(_skillTableView)
	_skillTableView:setTouchPriority(_touchPriority-60)
end

--[[
	@desc:	更新总建设度
--]]
function updateUI()
	if(tolua.cast(_bgLayer,"CCLayer") == nil )then 
		return
	end
	if(_donateLabel)then
		_donateLabel:removeFromParentAndCleanup(true)
		_donateLabel = nil
	end
	local totalDonate = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    totalDonate:setColor(ccc3(0xff, 0xff, 0xff))
    local donateNumber = CCRenderLabel:create(GuildDataCache.getGuildDonate(), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    donateNumber:setColor(ccc3(0x00,0xff,0x18))

    _donateLabel = BaseUI.createHorizontalNode({totalDonate, donateNumber})
    _donateLabel:setAnchorPoint(ccp(0.5, 1))
    _donateLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.85))
    _donateLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_donateLabel,2)

    -- 刷新科技列表
    local contentOffset = _skillTableView:getContentOffset()
    _skillTableView:reloadData()
    _skillTableView:setContentOffset(contentOffset)
end

--[[
	@desc:	返回按钮回调,关闭界面
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_bgLayer) then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end
