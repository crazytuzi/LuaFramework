-- Filename：	GodWeaponRankLayer.lua
-- Author：		DJN
-- Date：		2014-12-15
-- Purpose：		神兵副本排行榜界面

module("GodWeaponRankLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyService"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/godweapon/godweaponRank/GodWeaponRankCell"


local _bgLayer       --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local tableView_width = 0  -- 滑动列表的宽
local tableView_hight = 0  -- 滑动列表的高
local _allInfo        --后端拉来的全部排行相关数据
----------------------------------------初始化函数
local function init()
	_bgLayer       = nil
	_touchPriority = nil
	_ZOrder		   = nil
    tableView_width = 0  -- 滑动列表的宽
    tableView_hight = 0  -- 滑动列表的高
    _allInfo = nil
    
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
--------奖励预览按钮回调
function previewCallBack( ... )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/godweapon/godweaponRank/GodRewardPreview"
    GodRewardPreview.showLayer(_touchPriority-30,_ZOrder +10)
    -- body
end
----------------------------------------UI函数
--[[
	@des 	:创建排行榜背景
	@param 	:
	@return :
--]]
local function createBgUI()

    _allInfo = GodWeaponCopyData.getRankInfo()
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
    local paihangbang = CCSprite:create("images/match/paihangbang.png")
    paihangbang:setAnchorPoint(ccp(0.5,0.5))
    paihangbang:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(paihangbang)

    --自己排名
    local myRank_sprite = CCSprite:create("images/match/paiming.png")
    myRank_sprite:setAnchorPoint(ccp(1,0.5))
    myRank_sprite:setPosition(ccp(260,bgSprite:getContentSize().height-90))
    bgSprite:addChild(myRank_sprite)
    local personRank = ""
    if(tonumber(_allInfo.myRank) == 0 or _allInfo.myRank == nil)then
        personRank =  GetLocalizeStringBy("key_1054")
    else
        personRank = _allInfo.myRank 
    end
    local myRank_font = CCRenderLabel:create( personRank, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myRank_font:setAnchorPoint(ccp(0,0.5))
    myRank_font:setColor(ccc3(0xff,0xf6,0x00))
    myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+5,myRank_sprite:getPositionY()+2))
    bgSprite:addChild(myRank_font)
    ---积分
    local scoreFont = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    scoreFont:setAnchorPoint(ccp(1,0.5))
    scoreFont:setColor(ccc3(0xff,0xff,0xff))
    scoreFont:setPosition(ccp(460,bgSprite:getContentSize().height-65))
    bgSprite:addChild(scoreFont)

    local personScore = _allInfo.point or ""
    local myForce_font = CCRenderLabel:create( personScore, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myForce_font:setAnchorPoint(ccp(0,0.5))
    myForce_font:setColor(ccc3(0x00,0xff,0x18))
    myForce_font:setPosition(ccp(scoreFont:getPositionX()+7,scoreFont:getPositionY()))
    bgSprite:addChild(myForce_font)
    --最高闯关
    local passFont = CCRenderLabel:create( GetLocalizeStringBy("djn_117"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    passFont:setAnchorPoint(ccp(1,0.5))
    passFont:setColor(ccc3(0xff,0xff,0xff))
    passFont:setPosition(ccp(460,bgSprite:getContentSize().height-90))
    bgSprite:addChild(passFont)

    local personPass= _allInfo.pass_num or ""
    local myPass_font = CCRenderLabel:create(GetLocalizeStringBy("djn_118",personPass), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myPass_font:setAnchorPoint(ccp(0,0.5))
    myPass_font:setColor(ccc3(0x00,0xff,0x18))
    myPass_font:setPosition(ccp(passFont:getPositionX()+7,passFont:getPositionY()))
    bgSprite:addChild(myPass_font)

   
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-20)
    bgSprite:addChild(bgMenu)
   
    --关闭按钮
    local colseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1284"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    colseMenuItem:setAnchorPoint(ccp(0.5,0))
    colseMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.3,35))
    colseMenuItem:registerScriptTapHandler(closeMenuCallBack)
    bgMenu:addChild(colseMenuItem)

    --排行奖励按钮
    local previewMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple_n.png","images/common/btn/btn_purple_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("djn_119"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    previewMenuItem:setAnchorPoint(ccp(0.5,0))
    previewMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.7,35))
    previewMenuItem:registerScriptTapHandler(previewCallBack)
    bgMenu:addChild(previewMenuItem)

    
    
    
end

--[[
    @des    :创建排行榜tabelView
    @param  :
    @return :
--]]
function createRankTabView( ... )
    tableView_hight = 550
    tableView_width = secondBgSprite:getContentSize().width
     
    -- 显示单元格背景的size
    local cell_bg_size = { width = tableView_width, height = 122 } 
    -- 得到列表数据
    m_rankTabViewInfo = _allInfo.top or {}
    require "script/ui/guild/rank/GuildRankCell"
    --require "script/ui/main/MainScene"
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)
        elseif (fn == "cellAtIndex") then
            ----因为后端返回数据用rank作为数组k，返回数据里面没有rank字段，所以自己赋值
            m_rankTabViewInfo[a1+1].rank = a1+1
            a2 = GodWeaponRankCell.createCell(m_rankTabViewInfo[a1+1],a1+1)
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
function getTouchPriority( ... )
    return _touchPriority
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
        
    	GodWeaponCopyService.getRankList(function ( ... )
        --print("开始创建UI")
        --创建背景UI 
        createBgUI()
        
        createRankTabView()
        end)
  
	return _bgLayer


end