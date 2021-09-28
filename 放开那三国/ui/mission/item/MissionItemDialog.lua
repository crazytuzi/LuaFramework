-- FileName: MissionItemDialog.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionItemDialog", package.seeall)

require "script/ui/mission/item/MissionItemData"
require "script/ui/mission/item/MissionItemCell"


local _touchPriority = nil
local _zOrder 		 = nil
local _bgLayer 		 = nil
local _backPanel 	 = nil
local _itemListData  = nil	--显示物品列表
local _selectArray   = nil	--已选择物品列表
local _fameCoutLable = nil
local _fameCountNum  = nil
function init(...)
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_backPanel		 = nil
	_selectArray   	 = nil
	_fameCoutLable 	 = nil
	_fameCountNum    = nil
end

function show( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -512
	_zOrder = pZorder or 512
	local scene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer(_touchPriority, _zOrder)
    scene:addChild(layer,_zOrder,1231)
end


local function layerToucCb(eventType, x, y) 
    return true
end

function createLayer(pTouchPriority, pZorder)
	_touchPriority = pTouchPriority or -512
	_zOrder = pZorder or 512

	_bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchPriority,true)
	_bgLayer:setTouchEnabled(true)
	_bgLayer:setAnchorPoint(ccp(0, 0))
	
	local g_winSize = CCDirector:sharedDirector():getWinSize()
	_backPanel = CCScale9Sprite:create("images/common/viewbg1.png")
	_backPanel:setContentSize(CCSizeMake(630, 796))
	_backPanel:setAnchorPoint(ccp(0.5, 0.5))
	_backPanel:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	_bgLayer:addChild(_backPanel)
	AdaptTool.setAdaptNode(_backPanel)

	--标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(_backPanel:getContentSize().width/2, _backPanel:getContentSize().height - 7 )
	_backPanel:addChild(titlePanel)

	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1932"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)
	-- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-10)
    _backPanel:addChild(menuBar, 10)
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccpsprite(1.03, 1.03, _backPanel))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeLayer)
	--已捐物品以及上限
	local donateNum = MissionMainData.getDonateItemNum()
	local donateLimitNum = MissionMainData.getDonateLimit()
	local descriptionLabel = CCLabelTTF:create(GetLocalizeStringBy("lcyx_1933", donateNum, donateLimitNum),g_sFontPangWa, 25)
	descriptionLabel:setPosition(ccpsprite(0.5, 0.92, _backPanel))
	descriptionLabel:setAnchorPoint(ccp(0.5, 0.5))
	descriptionLabel:setColor(ccc3(0xa1,0x35,0x00))
	_backPanel:addChild(descriptionLabel, 10)
	--总计名望
	local fameCoutDesLable = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1934", 10, 100),g_sFontPangWa, 25, 1, ccc3(0,0,0))
	fameCoutDesLable:setPosition(ccp(40, 50))
	fameCoutDesLable:setAnchorPoint(ccp(0, 0))
	fameCoutDesLable:setColor(ccc3(0xff,0xff,0xff))
	_backPanel:addChild(fameCoutDesLable, 10)

	local fameCountBg = CCScale9Sprite:create("images/common/bg/9s_6.png")
	fameCountBg:setContentSize(CCSizeMake(147, 52))
	fameCountBg:setAnchorPoint(ccp(0, 0))
	fameCountBg:setPosition(ccp(150, 40))
	_backPanel:addChild(fameCountBg, 10)
	
	--物品列表
	createTableView()

	local fameBg = CCScale9Sprite:create("images/everyday/score_bg.png")
 	fameBg:setAnchorPoint(ccp(0, 0.5))
 	fameBg:setPosition(ccpsprite(0.05,0.08, _backPanel))
 	fameBg:setContentSize(CCSizeMake(557, 67))
 	_backPanel:addChild(fameBg, 1)
 	--总计名望值
	_fameCoutLable = CCLabelTTF:create("0",g_sFontName, 25)
	_fameCoutLable:setColor(ccc3(255,255,255))
	_fameCoutLable:setPosition(ccpsprite(0.5, 0.5, fameCountBg))
	_fameCoutLable:setAnchorPoint(ccp(0.5, 0.5))
	fameCountBg:addChild(_fameCoutLable, 10)
	--捐献按钮
	local donateButton = MissionMainLayer.createMenuItem(GetLocalizeStringBy("key_10032"),nil,nil,CCSizeMake(188, 70))
	donateButton:setAnchorPoint(ccp(0.5, 0.5))
	donateButton:setPosition(ccpsprite(0.8, 0.08, _backPanel))
	donateButton:registerScriptTapHandler(donateButtonCallback)
	menuBar:addChild(donateButton)
	return _bgLayer
end

--[[
	@des:物品列表
--]]
function createTableView( ... )

	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(575, 595))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(_backPanel:getContentSize().width*0.5, 110))
	_backPanel:addChild(tableBackground)

	_itemListData = MissionItemData.getItemList()
	local createTableCallback = function(fn, t_table, a1, a2)
		require "script/ui/rewardCenter/RewardTableCell"
		local r
		if fn == "cellSize" then
			r = CCSizeMake(500, 150)
		elseif fn == "cellAtIndex" then
			a2 = MissionItemCell.create(_itemListData[a1 + 1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #_itemListData
		elseif fn == "cellTouched" then
			
		end
		return r
	end
	_tableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(567,583))
	_tableView:setBounceable(true)
	_tableView:setAnchorPoint(ccp(0, 0))
	_tableView:setPosition(ccp(5, 10))
	tableBackground:addChild(_tableView)
	_tableView:setTouchPriority(-660)
end

--[[
	@des:捐献按钮回调
--]]	
function donateButtonCallback()
	require "script/ui/mission/item/MissonItemController"
	MissonItemController.doMissionItemCallback(_itemListData,function ( ... )
		--关闭窗口
		closeLayer()
	end)
end

--[[
	@des:关闭窗口
--]]
function closeLayer()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end


--[[
	@des:刷新名望值
--]]
function updateFameLabel()
	local fameCount = MissionItemData.getFameCount(_itemListData)
	_fameCoutLable:setString(tostring(fameCount))
	_fameCountNum = fameCount
end

--[[
	@des:得到当前的总名望
--]]
function getFameCount()
	return _fameCountNum
end
