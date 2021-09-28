-- Filename: ShowContestReward.lua.
-- Author: zhz.
-- Date: 2013-11-11
-- Purpose: 该文件用于显示比武奖励

module ("ShowContestReward", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/match/ContestRewardCell"

local _bgLayer 				-- 
local _rewardBg				-- 奖励的背景
local closeBtn				-- 关闭按钮
local _myTableViewBg		-- TableView 的背景
local myTableView


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

function createLayer( )
	_bgLayer= CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:setTouchEnabled(true)
	_bgLayer:registerScriptTouchHandler(layerToucCb,false,-551,true)


	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(640,798)

	-- 物品描述beijing
	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _rewardBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _rewardBg:setContentSize(mySize)
    _rewardBg:setScale(myScale)
    _rewardBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _rewardBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_rewardBg)

    -- 关闭按钮
    local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-552)
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
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2295"), g_sFontPangWa,33,1,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	-- 文字：每星期周五发放奖励，不要错过哟~
	require "db/DB_Contest"
	local contestData = DB_Contest.getDataById(1)
	local awardDay = contestData.releaseTime
	-- 休息前一晚23点发奖
	local tableDay = {GetLocalizeStringBy("key_1557"),GetLocalizeStringBy("lic_1247"),GetLocalizeStringBy("key_2665"),GetLocalizeStringBy("key_2579"),GetLocalizeStringBy("key_1504"),GetLocalizeStringBy("key_2645"),GetLocalizeStringBy("lic_1246")}
	local dateStr = nil
	if(tonumber(awardDay) == 0)then
		dateStr = tableDay[7]
	else
		dateStr = tableDay[tonumber(awardDay)]
	end
	local alertContent = {}
	alertContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_3154"), g_sFontPangWa,30,1,ccc3(0xff,0xff,0xff),type_stroke)
	alertContent[1]:setColor(ccc3(0x78,0x25,0x00))
	alertContent[2]= CCRenderLabel:create("" .. dateStr, g_sFontPangWa,30,1,ccc3(0xff,0xff,0xff),type_stroke)
	alertContent[2]:setColor(ccc3(0x08,0x78,0x00))
	alertContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_1340"), g_sFontPangWa,30,1,ccc3(0xff,0xff,0xff),type_stroke)
	alertContent[3]:setColor(ccc3(0x78,0x25,0x00))

	local nodeDesc = BaseUI.createHorizontalNode(alertContent)
    nodeDesc:setPosition(ccp(_rewardBg:getContentSize().width/2 ,714))
    nodeDesc:setAnchorPoint(ccp(0.5,0))
    _rewardBg:addChild(nodeDesc)

    -- 创建myTableView 的背景
    local rect = CCRectMake(0,0,75,75)
	local insert = CCRectMake(28,28,6,6)
	_myTableViewBg = CCScale9Sprite:create("images/sign/tableBg.png",rect,insert)
	--_tableViewSp:setPreferredSize(CCSizeMake(574, 492))
	_myTableViewBg:setPreferredSize(CCSizeMake(571,661))
	_myTableViewBg:setPosition(ccp(_rewardBg:getContentSize().width/2,46))
	_myTableViewBg:setAnchorPoint(ccp(0.5,0))
	_rewardBg:addChild(_myTableViewBg)


	createTableView( )

	return _bgLayer

end

function createTableView( )
	local cellSize = CCSizeMake(563, 208)           --计算cell大小
    local myScale 

    local rewardData = hanleRewardData()
	print_t(rewardData)

    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = ContestRewardCell.createCell(rewardData[a1+1])
           -- a2:setScale(myScale)
            r = a2
        elseif fn == "numberOfCells" then
            r = #rewardData
        elseif fn == "cellTouched" then
            print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then
            
        end
        return r
    end)
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(571,650))
    _myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(1,0))
    _myTableView:setTouchPriority(-552)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewBg:addChild(_myTableView)
end


-- 处理reward的数据
function hanleRewardData( )
	require "db/DB_Contest_reward"
	local tData = {}
	for k,v in pairs(DB_Contest_reward.Contest_reward) do
		table.insert(tData, v)
	end

	local rewardData = {}
	for k,v in pairs(tData) do
		table.insert(rewardData, DB_Contest_reward.getDataById(v[1]))
	end


	local function keySort ( rewardData_1, rewardData_2 )
	   	return tonumber(rewardData_1.id ) < tonumber(rewardData_2.id)
	end
	table.sort( rewardData, keySort)

	return rewardData

end



