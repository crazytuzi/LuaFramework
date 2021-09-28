-- FileName: RechargeGiftLayer.lua
-- Author: yangrui
-- Date: 15-10-30
-- Purpose: function description of module

module("RechargeGiftLayer", package.seeall)

require "script/ui/rechargeActive/rechargegift/RechargeGiftData"
require "script/ui/rechargeActive/rechargegift/RechargeGiftService"
require "script/ui/rechargeActive/rechargegift/RechargeGiftController"
require "script/ui/bag/UseGiftLayer"
require "script/ui/main/MenuLayer"
require "script/ui/tip/AnimationTip"

local _bgLayer             = nil
local _titleBg             = nil
local _tableViewBg         = nil
local _tableView           = nil
local _goodsBg             = nil
local _curRechargedGoldNum = 0

--[[
    @des    : 初始化
    @param  : 
    @return : 
--]]
function init( ... )
	_bgLayer             = nil
	_titleBg             = nil
	_tableViewBg         = nil
	_tableView           = nil
	_goodsBg             = nil
	_curRechargedGoldNum = 0
end

--[[
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( pEvent )
    if ( pEvent == "enter" ) then
    elseif ( pEvent == "exit" ) then
       _bgLayer = nil
    end
end

--[[
	@des 	: 创建普通奖励tableViewCell
	@param 	: 
	@return : 
--]]
function createRewardTableViewCell( pSingleRewardData, pType, isLast )
	local cell = CCTableViewCell:create()
	local itemSp = ItemUtil.createGoodsIcon(pSingleRewardData)
	itemSp:setAnchorPoint(ccp(0,0.5))
	itemSp:setPosition(ccp(20,_goodsBg:getContentSize().height*0.5+10))
	cell:addChild(itemSp)
	if tonumber(pType) == 2 and not isLast then
		local orSp = CCSprite:create("images/recharge/or.png")
		orSp:setAnchorPoint(ccp(0,0.5))
		orSp:setPosition(ccp(itemSp:getContentSize().width+25,_goodsBg:getContentSize().height*0.5+10))
		cell:addChild(orSp)
	end

	return cell
end

--[[
	@des 	: 创建奖励tableView
	@param 	: 
	@return : 
--]]
function createRewardTableView( pRewardData, pType )
	local tableViewSize = CCSizeMake(_goodsBg:getContentSize().width-11,_goodsBg:getContentSize().height)
	local cellSize = CCSizeMake(140,tableViewSize.height)
	local rewardData = ItemUtil.getItemsDataByStr(pRewardData)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(cellSize.width,cellSize.height)
			elseif fn == "cellAtIndex" then
				if a1+1 == #rewardData then
					ret = createRewardTableViewCell(rewardData[a1+1],pType,true)
				else
					ret = createRewardTableViewCell(rewardData[a1+1],pType,false)
				end
			elseif fn == "numberOfCells" then
				ret = #rewardData
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	local tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	tableView:setTouchPriority(-420)
	tableView:setBounceable(true)
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setAnchorPoint(ccp(0,0))
	tableView:setPosition(ccp(6,2))
	
	return tableView
end

--[[
	@des 	: 领奖按钮回调
	@param 	: 
	@return : 
--]]
function getRewardBenCallback( pRewardData )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if not ActivityConfigUtil.isActivityOpen("rechargeGift") then
		AnimationTip.showTip(GetLocalizeStringBy("yr_3006"))
		return
	end
	-- 背包是否有剩余空间
    require "script/ui/item/ItemUtil"
    if ItemUtil.isBagFull() == true then
        return
    end
	-- 根据奖励类型
	if tonumber(pRewardData.type) == 1 then
		-- 直接领取
		RechargeGiftController.obtainReward(tonumber(pRewardData.id),nil,nil)
	elseif tonumber(pRewardData.type) == 2 then
		-- 弹出奖励选择面板  玩家进行选择
		UseGiftLayer.showTipLayer(nil,pRewardData.reward,function( rewardId )
			RechargeGiftController.obtainReward(tonumber(pRewardData.id),rewardId,nil)
		end)
	end
end

--[[
	@des 	: 创建tableViewCell
	@param 	: 
	@return : 
--]]
function createTableViewCell( pRewardData )
	print("===|createTableViewCell|===")
	local cell = CCTableViewCell:create()
	-- Cell背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create(g_pathCommonImage .. "bg/change_bg.png",fullRect,insetRect)
    cellBg:setContentSize(CCSizeMake(614,203))
    cell:addChild(cellBg)
    -- 物品背景
    local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(30,30,15,10)
    _goodsBg = CCScale9Sprite:create(g_pathCommonImage .. "bg/goods_bg.png",fullRect,insetRect)
    _goodsBg:setContentSize(CCSizeMake(414,150))
    _goodsBg:setAnchorPoint(ccp(0.5,0))
    _goodsBg:setPosition(ccp(cellBg:getContentSize().width*0.4,20))
    cellBg:addChild(_goodsBg)
    -- 充值提示背景
    local tipBg = CCScale9Sprite:create("images/sign/sign_bottom.png")
    tipBg:setContentSize(CCSizeMake(310,50))
    tipBg:setAnchorPoint(ccp(0,1))
    tipBg:setPosition(ccp(0,cellBg:getContentSize().height+4))
    cellBg:addChild(tipBg)
    -- 累积充值%d金币  yr_3002
    local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_3002",tonumber(pRewardData.expenseGold)),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
    tipLabel:setAnchorPoint(ccp(0,0.5))
    tipLabel:setPosition(ccp(34,tipBg:getContentSize().height*0.5+3))
    tipLabel:setColor(ccc3(0xff,0xf6,0x00))
    tipBg:addChild(tipLabel)
    -- 奖励tableview
	local rewardTableView = createRewardTableView(pRewardData.reward,pRewardData.type)
	_goodsBg:addChild(rewardTableView)
    -- 领奖按钮  领取  key_1715
    local menu = CCMenu:create()
    cellBg:addChild(menu)
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-430)
    local tSprite = {normal="images/level_reward/receive_btn_n.png",selected="images/level_reward/receive_btn_h.png"}
	local tLabel = {text=GetLocalizeStringBy("key_1715"),fontsize=30,dColor=ccc3(0xe1,0xe1,0xe1)}
	-- 选择领取奖励的按钮
	if tonumber(pRewardData.type) == 2 then
		tSprite = {normal="images/recharge/rechargegift/receive_btn_n.png",selected="images/recharge/rechargegift/receive_btn_h.png"}
	end
    -- 已经领取奖励
    local isReceivedReward = RechargeGiftData.isReceivedRewardById(pRewardData.id)
    if isReceivedReward then
    	tLabel.text = GetLocalizeStringBy("key_1369")
    end
    local rewardBtn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
    rewardBtn:setAnchorPoint(ccp(0.5,0.5))
    rewardBtn:setPosition(ccp(cellBg:getContentSize().width*0.85,cellBg:getContentSize().height*0.55))
    rewardBtn:registerScriptTapHandler(function( ... )
    	getRewardBenCallback(pRewardData)
    end)
    menu:addChild(rewardBtn)
    -- 已充值金币数/奖励所需金币数 Label
    local curNeedGoldNum = tonumber(pRewardData.expenseGold)
    local curStateLabel = CCRenderLabel:create("(" .. _curRechargedGoldNum .. "/" .. curNeedGoldNum .. ")",g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    curStateLabel:setAnchorPoint(ccp(0.5,1))
    curStateLabel:setPosition(ccp(cellBg:getContentSize().width*0.85,rewardBtn:getPositionY()-rewardBtn:getContentSize().height*0.6))
    curStateLabel:setColor(ccc3(0x00,0xff,0x18))
    cellBg:addChild(curStateLabel)
    -- 未满足奖励所需金币数
    if _curRechargedGoldNum < curNeedGoldNum then
    	curStateLabel:setColor(ccc3(0xff,0x00,0x00))
    	rewardBtn:setEnabled(false)
    end
    -- 被领取
    if isReceivedReward then
    	rewardBtn:setVisible(false)
    	-- isReceivedReward:setVisible(false)
    	local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
        receive_alreadySp:setPosition(ccp(cellBg:getContentSize().width*0.85,cellBg:getContentSize().height*0.55))
        receive_alreadySp:setAnchorPoint(ccp(0.5,0.5))
        cellBg:addChild(receive_alreadySp)
    end

	return cell
end

--[[
	@des 	: 创建tableView
	@param 	: 
	@return : 
--]]
function createTableView( ... )
    local tableViewSize = CCSizeMake(_tableViewBg:getContentSize().width,_tableViewBg:getContentSize().height-4)
	local cellSize = CCSizeMake(tableViewSize.width,210)
	local allRewardData = RechargeGiftData.getAllRewardData()
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(cellSize.width,cellSize.height)
			elseif fn == "cellAtIndex" then
				ret = createTableViewCell(allRewardData[a1+1])
			elseif fn == "numberOfCells" then
				ret = #allRewardData
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	_tableView:setTouchPriority(-410)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setAnchorPoint(ccp(0,0))
	_tableView:setPosition(ccp(10,2))
	_tableViewBg:addChild(_tableView)
end

--[[
	@des 	: 刷新UI
	@param 	: 
	@return : 
--]]
function refreshUI( ... )
	print("===|refreshUI|===")
	local offset = _tableView:getContentOffset()
	if _tableView ~= nil then
		_tableView:removeFromParentAndCleanup(true)
		_tableView = nil
	end
	createTableView()
	_tableView:setContentOffset(offset)
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
	require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	-- 标题背景
	local _titleBg = CCScale9Sprite:create("images/recharge/rechargegift/bg.png") -- 640 429
    _titleBg:setAnchorPoint(ccp(0.5,0.86))
    _titleBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-topMenuHeight))
    _bgLayer:addChild(_titleBg)
    _titleBg:setScale(g_fScaleX)
    -- 活动标题
    local activityTitleSp = CCSprite:create("images/recharge/rechargegift/title.png")
    activityTitleSp:setAnchorPoint(ccp(0.5,1))
    activityTitleSp:setPosition(ccp(_titleBg:getContentSize().width*0.5,_titleBg:getContentSize().height*0.86-5))
    _titleBg:addChild(activityTitleSp)
    -- 活动时间
    local beginTime = TimeUtil.getTimeFormatYMDHMS(RechargeGiftData.getStartTime())
    local endTime = TimeUtil.getTimeFormatYMDHMS(RechargeGiftData.getEndTime())
    local richInfo = {
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
            labelDefaultFont = g_sFontName,
            labelDefaultColor = ccc3(0x00,0xff,0x18),
            labelDefaultSize = 18,
            defaultType = "CCRenderLabel",
            elements =
            {
                {
                    newLine = false,
                    text = GetLocalizeStringBy("yr_1006"),
                    color = ccc3(0x00,0xe4,0xff),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    newLine = false,
                    text = beginTime .. " — " .. endTime,
                    renderType = 2,-- 1 描边， 2 投影
                },
            }
        }
    local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
    richTextLayer:setAnchorPoint(ccp(0.5,0))
    richTextLayer:setPosition(ccp(_titleBg:getContentSize().width*0.5,_titleBg:getContentSize().height*0.56))
    _titleBg:addChild(richTextLayer)
    -- 列表背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(50,50,6,4)
    local titleBgShift = 0.32  -- 标题背景高的偏移量
    _tableViewBg = CCScale9Sprite:create("images/recharge/change/zhong_bg1.png",fullRect, insetRect)
    local tableviewHeight = _titleBg:getPositionY()-_titleBg:getContentSize().height*titleBgShift*g_fScaleX-MenuLayer.getHeight()-20*g_fScaleX
    _tableViewBg:setContentSize(CCSizeMake(630, tableviewHeight/g_fScaleX))
    _tableViewBg:setAnchorPoint(ccp(0.5,1))
    _tableViewBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _titleBg:getPositionY()-_titleBg:getContentSize().height*titleBgShift*g_fScaleX))
    _bgLayer:addChild(_tableViewBg)
    _tableViewBg:setScale(g_fScaleX)
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer()
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
    -- 创建基础UI
    createUI()
    
    RechargeGiftService.getInfo(function( ... )
    	-- 当前已充值金币数
    	_curRechargedGoldNum = RechargeGiftData.getRechargedGoldNum()
        -- 创建列表
        createTableView()
    end )

	return _bgLayer
end

--[[
	@des 	: 充值后调用
	@param 	: 
	@return : 
--]]
function getInfoWhenRecharged( ... )
	if ActivityConfigUtil.isActivityOpen("rechargeGift") then
		RechargeGiftService.getInfo()
	end
end
