-- Filename: ShowGuangongReward.lua
-- Author: zhang zihang
-- Date: 2014-1-17
-- Purpose: 该文件用于: 关公殿奖励预览

module ("ShowGuangongReward", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/guild/GuangongPreviewCell"

local _bgLayer
local _rewardBg
local closeBtn

local function init( )
	_bgLayer =nil
	_rewardBg = nil
	closeBtn=nil
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

local function closeBtnCallBack(tag,item)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer= nil
end

function hanleRewardData()
	require "db/DB_Legion_feast"
	local showData = {}

	require "script/ui/guild/GuildUtil"

	local guanGongInfo = DB_Legion_feast.getDataById(1)
	for i = 0,tonumber(GuildUtil.getMaxGongyuLevel()) do
		local rewardMessage = {}
		if i == 0 then
			rewardMessage.layerName = GetLocalizeStringBy("key_2783")
		else
			rewardMessage.layerName = i .. GetLocalizeStringBy("key_3254")
		end
		rewardMessage.execution = math.floor(guanGongInfo.baseExecution+guanGongInfo.growExecution*i/100)
		rewardMessage.stamina = math.floor(guanGongInfo.baseStamina+guanGongInfo.growStamina*i/100)
		rewardMessage.prestige = math.floor(guanGongInfo.basePrestige+guanGongInfo.growPrestige*i/100)
		rewardMessage.soul = math.floor(guanGongInfo.baseSoul+guanGongInfo.growSoul*i/100)
		rewardMessage.silver = math.floor(guanGongInfo.baseSilver+guanGongInfo.growSilver*i/100)
		rewardMessage.gold = math.floor(guanGongInfo.baseGold+guanGongInfo.growGold*i/100)
		table.insert(showData,rewardMessage)
	end

	return showData
end

function createTableView()
	local cellSize = CCSizeMake(563, 248)           --计算cell大小
    local myScale 

    local rewardData = hanleRewardData()
	print_t(rewardData)

    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = GuangongPreviewCell.createCell(rewardData[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r = #rewardData
        elseif fn == "cellTouched" then
            print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then
            
        end
        return r
    end)
    local _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(564,708))
    _myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(6,1))
    _myTableView:setTouchPriority(-470)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewBg:addChild(_myTableView)
end

function createLayer( )
	print("创建奖励预览啦~~~~")
	_bgLayer= CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:setTouchEnabled(true)
	_bgLayer:registerScriptTouchHandler(layerToucCb,false,-469,true)


	local mySize = CCSizeMake(640,798)

	-- 物品描述beijing
	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _rewardBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _rewardBg:setContentSize(mySize)
    _rewardBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _rewardBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_rewardBg)

    -- 适配
    setAdaptNode( _rewardBg )

    -- 关闭按钮
    local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-470)
	_rewardBg:addChild(menu,1000)

	closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:setAnchorPoint(ccp(1, 1))
	closeBtn:setPosition(ccp(_rewardBg:getContentSize().width*1.01, _rewardBg:getContentSize().height*1.02))
	closeBtn:registerScriptTapHandler(closeBtnCallBack)
	menu:addChild(closeBtn)

	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_rewardBg:getContentSize().width*0.5,_rewardBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_rewardBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1867"), g_sFontPangWa,33,1,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

    -- 创建myTableView 的背景
    local rect = CCRectMake(0,0,75,75)
	local insert = CCRectMake(28,28,6,6)
	_myTableViewBg = CCScale9Sprite:create("images/sign/tableBg.png",rect,insert)
	--_tableViewSp:setPreferredSize(CCSizeMake(574, 492))
	_myTableViewBg:setPreferredSize(CCSizeMake(571,711))
	_myTableViewBg:setAnchorPoint(ccp(0.5,0))
	_myTableViewBg:setPosition(ccp(_rewardBg:getContentSize().width/2,36))
	_rewardBg:addChild(_myTableViewBg)

	createTableView( )

	return _bgLayer

end
