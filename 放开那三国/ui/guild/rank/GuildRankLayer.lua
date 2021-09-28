-- Filename：	GuildRankLayer.lua
-- Author：		DJN
-- Date：		2014-7-7
-- Purpose：		军团排行榜界面

module("GuildRankLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/guild/rank/GuildRankService"
require "script/ui/guild/rank/GuildRankData"


local _bgLayerColor  --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local tableView_width = 0  -- 滑动列表的宽
local tableView_hight = 0  -- 滑动列表的高
local _SumOfRank = 50 --排行榜上榜军团数量
local _rankguildListInfo --军团排行榜用的数据
----------------------------------------初始化函数
local function init()
	_bgLayer       = nil
	_touchPriority = nil
	_ZOrder		   = nil
    tableView_width = 0  -- 滑动列表的宽
    tableView_hight = 0  -- 滑动列表的高
    _rankguildListInfo = nil
    
end

----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
	if eventType == "began" then
		print("onTouchesHandler,began")
	    return true
    elseif eventType == "moved" then
    	print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
local function closeMenuCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

----------------------------------------UI函数
--[[
	@des 	:创建排行榜背景
	@param 	:
	@return :
--]]
local function createBgUI()
	require "script/ui/main/MainScene"
	local bgSize = CCSizeMake(630,800)
	local bgScale = MainScene.elementScale
    
	--主黄色背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	bgSprite:setScale(bgScale)
	_bgLayer:addChild(bgSprite)

 
	--二级棕色背景
	require "script/utils/BaseUI"
	secondBgSprite = BaseUI.createContentBg(CCSizeMake(575,570))
    secondBgSprite:setAnchorPoint(ccp(0.5,0.5))
    secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5))
    bgSprite:addChild(secondBgSprite)

    -- 排行榜图标
    local paihangbang = CCSprite:create("images/guild/rank/guild_rank.png")
    paihangbang:setAnchorPoint(ccp(0.5,0.5))
    paihangbang:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(paihangbang)

     --获取所在军团排名和战斗力
    local guild_rank,guild_fight_force = GuildRankData.getUserGuildRankInfo()

    -- 自己排名
    local myRank_sprite = CCSprite:create("images/guild/rank/current_rank.png")
    myRank_sprite:setAnchorPoint(ccp(1,0.5))
    myRank_sprite:setPosition(ccp(245,bgSprite:getContentSize().height-90))
    bgSprite:addChild(myRank_sprite)
    
    local myRank_font = CCRenderLabel:create( guild_rank, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myRank_font:setAnchorPoint(ccp(0,0.5))
    myRank_font:setColor(ccc3(0xff,0xf6,0x00))
    myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+5,myRank_sprite:getPositionY()+2))
    bgSprite:addChild(myRank_font)

    -- 军团战斗力
    local myForce_sprite = CCSprite:create("images/guild/rank/total_fight_force.png")
    myForce_sprite:setAnchorPoint(ccp(1,0.5))
    require "script/ui/guild/GuildDataCache"
    if(tonumber(GuildDataCache.getMineSigleGuildInfo().rank) == 0 or GuildDataCache.getMineSigleGuildInfo().rank == nil )then
        --没有加入军团，前面的字太长 UI需要向后移动
        myForce_sprite:setPosition(ccp(520,bgSprite:getContentSize().height-90))
    else
        myForce_sprite:setPosition(ccp(470,bgSprite:getContentSize().height-90))
    end
    bgSprite:addChild(myForce_sprite)
    
    local myForce_font = CCRenderLabel:create( guild_fight_force, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myForce_font:setAnchorPoint(ccp(0,0.5))
    myForce_font:setColor(ccc3(0x00,0xff,0x18))
    myForce_font:setPosition(ccp(myForce_sprite:getPositionX()+7,myRank_sprite:getPositionY()))
    bgSprite:addChild(myForce_font)
   
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)
   
    --关闭按钮
    local colseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1284"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    colseMenuItem:setAnchorPoint(ccp(0.5,0))
    colseMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,35))
    colseMenuItem:registerScriptTapHandler(closeMenuCallBack)
    bgMenu:addChild(colseMenuItem)

end

--[[
    @des    :创建排行榜tabelView
    @param  :
    @return :
--]]
function createRankGuildTabView( ... )
    tableView_hight = 550
    tableView_width = secondBgSprite:getContentSize().width
     
    -- 显示单元格背景的size
    local cell_bg_size = { width = tableView_width, height = 122 } 
    -- 得到列表数据
    m_rankTabViewInfo = GuildRankData.getRankGuildListData() or {}
    
    -- print_t(m_ranklistTabViewInfo)
    require "script/ui/guild/rank/GuildRankCell"
    --require "script/ui/main/MainScene"
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)
        elseif (fn == "cellAtIndex") then
            a2 = GuildRankCell.createCell(m_rankTabViewInfo[a1+1])
            r=a2
        elseif (fn == "numberOfCells") then
            r = #m_rankTabViewInfo
        elseif (fn == "cellTouched") then
            -- print ("a1: ", a1, ", a2: ", a2)
            -- print ("cellTouched, index is: ", a1:getIdx())
        elseif (fn == "scroll") then
            -- print ("scroll, index is: ")
        else
            -- print (fn, " event is not handled.")
        end
        return r
    end)

    m_rankTableView = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
    m_rankTableView:setBounceable(true)
    m_rankTableView:setAnchorPoint(ccp(0, 0))
    m_rankTableView:setPosition(ccp(2,7))
    secondBgSprite:addChild(m_rankTableView)
    -- 设置单元格升序排列
    m_rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    m_rankTableView:setTouchPriority(_touchPriority-1)
end

----------------------------------------入口函数
function showLayer(p_touchPriority,p_ZOrder)
	
		init()
		_touchPriority = p_touchPriority or -550
		_ZOrder = p_ZOrder or 999

		_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
		_bgLayer:registerScriptHandler(onNodeEvent)
		local curScene = CCDirector:sharedDirector():getRunningScene()
    	curScene:addChild(_bgLayer,_ZOrder)
        
    	GuildRankService.getInfo(function ( ... )
        --print("开始创建UI")
        --创建背景UI 
        createBgUI()
        -- 创建军团列表tableview
        createRankGuildTabView()
        end)

	return _bgLayer


end