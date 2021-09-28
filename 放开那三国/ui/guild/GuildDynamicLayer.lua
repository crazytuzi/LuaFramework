-- Filename：	GuildDynamicLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-12-21
-- Purpose：		军团动态列表

module("GuildDynamicLayer", package.seeall)

require "script/ui/guild/GuildDynamicCell"

Tag_MemberList 		= 20001
Tag_CheckedList 	= 20002


local _bgLayer 				= nil

local _memberMenuItem 		= nil 	-- 军团成员
local _checkedMenuItem 		= nil 	-- 审核

local _curMenuItem 			= nil 	-- 当前按钮

local _memberListInfo 		= nil 	-- 成员的相关信息
local _checkedListInfo 		= nil	-- 审核的列表

local _curDynamicData 		= nil 	-- 成员信息数组
local _curMemberTableView 	= nil

local _cur_item_tag 		= nil 	-- 初始的按钮
local _bottomSpite 			= nil 	-- 底层
local _btnFrameSp			= nil 	-- 按钮层


local function init()
	_bgLayer 			= nil
	_memberMenuItem 	= nil 	-- 军团成员
	_checkedMenuItem 	= nil 	-- 审核
	_curMenuItem 		= nil 	-- 当前按钮
	_memberListInfo 	= nil 	-- 成员的相关信息
	_curDynamicData 	= nil	-- 成员信息数组
	_curMemberTableView = nil
	_cur_item_tag 		= nil 	-- 初始的按钮
	_checkedListInfo 	= nil	-- 审核的列表
	_bottomSpite 		= nil 	-- 底层
	_btnFrameSp			= nil 	-- 按钮层
end

-- touch事件处理
local function onTouchesHandler(eventType, x, y)
   
    if (eventType == "began") then
    	print("began")
    	
    	return true
	
    elseif (eventType == "moved") then
    	
		
    else
    	print("end")
	end
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
		-- _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -398, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
	end
end


-- 按钮响应
function menuAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_curMenuItem ~= itemBtn)then
		

	end
end

-- 返回Action
function backAction( tag, itemBtn )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end


-- 创建上部按钮
function createTopMenu()
	--按钮背景
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png")
	_btnFrameSp:setContentSize(CCSizeMake(640, 100))
	_btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	_btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height))
	_btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(_btnFrameSp,10)

	-- 上分界线
	local topSeparator = CCSprite:create( "images/common/separator_top.png" )
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(_btnFrameSp:getContentSize().width*0.5,_btnFrameSp:getContentSize().height))
	_btnFrameSp:addChild(topSeparator)

	-- 创建按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(-400)
	_btnFrameSp:addChild(menuBar)

	-- 成员按钮
	_memberMenuItem = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_2508"),30,30)
	_memberMenuItem:setAnchorPoint(ccp(0, 0))
	_memberMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width*0.02, _btnFrameSp:getContentSize().height*0.08))
	_memberMenuItem:registerScriptTapHandler(menuAction)
	menuBar:addChild(_memberMenuItem, 1, Tag_MemberList)
	-- 默认选中状态
	_memberMenuItem:setEnabled(false)
	_memberMenuItem:selected()

	_curMenuItem = _memberMenuItem

	-- 审核按钮
	-- _checkedMenuItem = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_3208"),30,30)
	-- _checkedMenuItem:setAnchorPoint(ccp(0, 0))
	-- _checkedMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width*0.3, _btnFrameSp:getContentSize().height*0.08))
	-- _checkedMenuItem:registerScriptTapHandler(menuAction)
	-- menuBar:addChild(_checkedMenuItem, 1, Tag_CheckedList)

	-- if(tonumber(GuildDataCache.getMineSigleGuildInfo().member_type) == 0)then
	-- 	_checkedMenuItem:setVisible(false)
	-- end


	-- 创建关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(backAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5))
	menuBar:addChild(closeMenuItem)

end

-- 创建底部
function createBottom()
	if(_bottomSpite)then
		_bottomSpite:removeFromParentAndCleanup(true)
		_bottomSpite = nil
	end
	_bottomSpite = GuildBottomSprite.createBottomSprite(false)
	_bgLayer:addChild(_bottomSpite, 99)
	local myScale = _bgLayer:getContentSize().width/_bottomSpite:getContentSize().width/_bgLayer:getElementScale()
	_bottomSpite:setScale(myScale)
end

-- 创建成员TableView
function createDynamicTableView()
	cellSize = CCSizeMake(640, 180)			--计算cell大小

    local myScale = _bgLayer:getContentSize().width/cellSize.width/_bgLayer:getElementScale()
   
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			
	        a2 = GuildDynamicCell.createCell(_curDynamicData[a1 + 1])
	        
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_curDynamicData
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local bottomSpiteSize = _bottomSpite:getContentSize()
	_curMemberTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(), (_bgLayer:getContentSize().height-(bottomSpiteSize.height + 100)*g_fScaleX)  /_bgLayer:getElementScale()  ) )
    _curMemberTableView:setAnchorPoint(ccp(0,0))
    _curMemberTableView:setPosition(ccp(0, bottomSpiteSize.height*g_fScaleX))
	_curMemberTableView:setBounceable(true)
	_curMemberTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(_curMemberTableView)

end



-- 创建UI
function createUI()
	createTopMenu()
	createBottom()
	-- 创建成员TableView
	createDynamicTableView()
end

-- 
function getDynamicListCallback(cbFlag, dictData, bRet)
	if(dictData.err == "ok")then
		_curDynamicData = dictData.ret
		createUI()
	end
end

--
function createLayer( )
	init()

	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", false, false, true)
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 请求
	RequestCenter.guild_getDynamicList(getDynamicListCallback)

	return _bgLayer
end




