-- Filename: ReResourceLayer.lua
-- Author: DJN
-- Date: 2014-12-21
-- Purpose: 资源追回主界面

require "script/ui/rewardCenter/AdaptTool"
require "script/libs/LuaCC"
require "script/libs/LuaCCSprite"
require "script/utils/LuaUtil"
require "script/audio/AudioUtil"
require "script/ui/recover/ReResourceService"
require "script/ui/recover/ReResourceData"
require "db/DB_Resourceback"
require "script/ui/recover/AlertCost"
require "script/ui/recover/ReResourceCell"

module("ReResourceLayer", package.seeall)

local _checkTagSprite = nil
local colorLayer = nil    ----背景层
-- local rewardTable = nil   ----奖励table
local rewardList = nil    ----奖励Id列表
local _checkBtn = nil
local _touchpriority = nil ---触摸优先级
local _ALLSILVER = 1001    ---银币全部补领的tag
local _ALLGOLD = 1002      ---金币全部补领的tag
local _rewardTablView = nil ---奖励tableview
local _allReceiveGold ------金币全部补领按钮
local _midSp          ------“金币补领需要金币数” 精灵
local _totalActiveNum ------当前总共可追回的活动总数

----------------------------[[ ui创建 ]]----------------------------------

local _isEnter = false
local _isClick = false

function init( )
	_checkTagSprite = nil
	_isClick = false
	_checkBtn = nil
	 colorLayer = nil
	 -- rewardTable = nil
	 _rewardList = nil
	 _touchpriority = nil
	 _rewardTablView = nil
	 _allReceiveGold = nil
	 _midSp = nil
	 _totalActiveNum = nil
end

-- layerTouch 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

function create(p_touchpriority)
	init()
    _touchpriority = p_touchpriority or -551
    _isEnter = true
    colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:registerScriptTouchHandler(layerToucCb,false,_touchpriority,true)
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:setTouchEnabled(true)
	colorLayer:setAnchorPoint(ccp(0, 0))

	ReResourceService.getResourceInfo(createUI)
	return colorLayer
end

function checkCallback( ... )
	if(not _isClick)then
		_checkTagSprite = CCSprite:create("images/common/checked.png")
		_checkBtn:addChild(_checkTagSprite)
		_checkTagSprite:setAnchorPoint(ccp(0.5, 0.5))
		_checkTagSprite:setPosition(ccpsprite(0.5, 0.5, _checkBtn))
		_isClick = true
	else
		_checkTagSprite:removeFromParentAndCleanup(true)
		_checkTagSprite = nil
		_isClick = false
	end
	ReResourceData.setIsFirst(_isClick)
end

function createUI( ... )
	--local g_winSize = CCDirector:sharedDirector():getWinSize()
	local background = CCScale9Sprite:create("images/common/viewbg1.png")
	background:setContentSize(CCSizeMake(630, 796))
	background:setAnchorPoint(ccp(0.5, 0.5))
	background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	colorLayer:addChild(background)
	AdaptTool.setAdaptNode(background)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))

	menu:setTouchPriority(_touchpriority - 10)
	background:addChild(menu)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setPosition(background:getContentSize().width * 0.95, background:getContentSize().height * 0.96)
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)


	--标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(background:getContentSize().width/2, background:getContentSize().height - 7 )
	background:addChild(titlePanel)

	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_98"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)
    
    _rewardList = ReResourceData.getResourceInfo()
	_totalActiveNum = CCLabelTTF:create(GetLocalizeStringBy("djn_105",table.count(_rewardList)),g_sFontName,25)
	background:addChild(_totalActiveNum)
	_totalActiveNum:setColor(ccc3(0x78, 0x25, 0x00))
	_totalActiveNum:setPosition(ccp(50,background:getContentSize().height*0.9))

	local doubleLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_106"),g_sFontName,25)
	background:addChild(doubleLabel)
	doubleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	doubleLabel:setPosition(ccp(300,background:getContentSize().height*0.9))
	

	--银币全部领取按钮
	local allReceiveSilver = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(250,73),GetLocalizeStringBy("djn_99"),ccc3(255,222,0))
    allReceiveSilver:setAnchorPoint(ccp(0.5, 0.5))
    allReceiveSilver:setPosition(background:getContentSize().width*0.25, background:getContentSize().height*0.09)
	menu:addChild(allReceiveSilver)
	allReceiveSilver:registerScriptTapHandler(allReceiveCallback)
	allReceiveSilver:setTag(_ALLSILVER)

    

	--金币全部领取按钮
	_allReceiveGold = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png","images/common/btn/btn_purple2_h.png",CCSizeMake(250,73))
    _allReceiveGold:setAnchorPoint(ccp(0.5, 0.5))
    _allReceiveGold:setPosition(background:getContentSize().width*0.75, background:getContentSize().height*0.09)
	menu:addChild(_allReceiveGold)
	_allReceiveGold:registerScriptTapHandler(allReceiveCallback)
	_allReceiveGold:setTag(_ALLGOLD)

	_checkBtn = CCMenuItemImage:create("images/common/checkbg.png", "images/common/checkbg.png")
	menu:addChild(_checkBtn)
	_checkBtn:setAnchorPoint(ccp(0.5, 0))
	_checkBtn:setPosition(ccp(background:getContentSize().width * 0.36, allReceiveSilver:getPositionY() + allReceiveSilver:getContentSize().height*0.5 + 10))
	_checkBtn:registerScriptTapHandler(checkCallback)

	local tip = CCLabelTTF:create(GetLocalizeStringBy("llp_510"), g_sFontPangWa, 21)
	_checkBtn:addChild(tip)
	tip:setAnchorPoint(ccp(0, 0.5))
	tip:setPosition(ccpsprite(1, 0.5, _checkBtn))
	tip:setColor(ccc3(0x78, 0x25, 0x00))
   
    refreshMidSp()

	createTableView(background)
	
end
--------刷新“金币全部补领”按钮上的字
function refreshMidSp( ... )
	local totalGoldNum = ReResourceData.getGoldByParam(ReResourceData.getAllRewardTable())
  
    require "script/libs/LuaCCLabel"
    local richInfo = {lineAlignment = 2,elements = {}}
	    richInfo.elements[1] = {
			    ["type"] = "CCSprite", 
			    newLine = false, 
			    --text = GetLocalizeStringBy("key_1307"),
			    image = "images/common/gold.png"}
	    richInfo.elements[2] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = totalGoldNum,
			    font = g_sFontPangWa, 
			    size = 30, 
			    color = ccc3(255,222,0), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[3] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = GetLocalizeStringBy("djn_100"),
			    font = g_sFontPangWa, 
			    size = 30, 
			    color = ccc3(255,222,0), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
    if(_midSp ~= nil)then
    	_midSp:removeFromParentAndCleanup(true)
    	_midSp = nil
    end
    _midSp = LuaCCLabel.createRichLabel(richInfo)
    _midSp:setAnchorPoint(ccp(0.5,0.5))
    _midSp:setPosition(ccp(_allReceiveGold:getContentSize().width*0.5,_allReceiveGold:getContentSize().height*0.5))
    _allReceiveGold:addChild(_midSp)
end
-----------创建中间奖励的tableview
function createTableView( layer )

	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(575, 545))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(layer:getContentSize().width*0.5, 160))
	layer:addChild(tableBackground)

	local  function rewardTableCallback(fn, t_table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(568, 227)
		elseif fn == "cellAtIndex" then
			a2 = ReResourceCell.create(_rewardList[a1+1],receiveRewardCallback)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_rewardList
			--print("numberOfCells r = " ,r)
		elseif fn == "cellTouched" then
				
		end
		return r
	end
	_rewardTablView = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), CCSizeMake(567,533))
	_rewardTablView:setBounceable(true)
	_rewardTablView:setAnchorPoint(ccp(0, 0))
	_rewardTablView:setPosition(ccp(0, 0))
	tableBackground:addChild(_rewardTablView)
	_rewardTablView:setTouchPriority(_touchpriority - 20)

end
------------本地缓存有变化后刷新UI
function refreshUi( ... )
	_rewardList = ReResourceData.getResourceInfo()	
	print("refreshUi")
	print_t(_rewardList)
	if(table.isEmpty(_rewardList) == true)then
		--print("检测资源追回已经领完，首页删除")
        DataCache.setReResourceStatus(false) 
        closeLayer()
		return
	end
	_totalActiveNum:setString(GetLocalizeStringBy("djn_105",table.count(_rewardList)))
	refreshMidSp()
	_rewardTablView:reloadData()
end


--------全部领取按钮回调
function allReceiveCallback( tag, sender )
    if (tag == _ALLGOLD)then
    	AlertCost.showLayer("gold",ReResourceData.getGoldByParam(ReResourceData.getAllRewardTable()),ReResourceData.getAllCanReviceByGoldTypes(),refreshUi,_touchpriority-30)
    	--花费的类型、花费的数量、奖励列表、触摸优先级、Z轴
    elseif(tag == _ALLSILVER)then
    	-- 判断是否有可以银币追回的资源
    	if (ReResourceData.isCanRetrieveBySilver(ReResourceData.getAllRewardTable())) then
    		AlertCost.showLayer("silver",ReResourceData.getSilverByParam(ReResourceData.getAllRewardTable()),ReResourceData.getAllCanReviceBySilverTypes(),refreshUi,_touchpriority-30)
    	else
    		-- 当前没有可银币追回的东西
    		require "script/ui/tip/AnimationTip"
    		AnimationTip.showTip(GetLocalizeStringBy("lgx_1103"))
    	end
    end
end

--关闭模块
function closeButtonCallback( tag, sender )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeLayer()
end

function closeLayer()
	colorLayer:removeFromParentAndCleanup(true)
	colorLayer = nil
	require "script/ui/main/MainMenuLayer"
    MainMenuLayer.updateMiddleButton()
	--CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(updataTimerFunc)
end


