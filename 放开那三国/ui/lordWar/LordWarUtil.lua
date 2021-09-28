-- FileName: LordWarUtil.lua 
-- Author: licong 
-- Date: 14-8-4 
-- Purpose: 跨服赛 公用方法 


module("LordWarUtil", package.seeall)

require "script/ui/lordWar/LordWarData"
require "script/ui/lordWar/LordWarService"
require "script/ui/tip/AnimationTip"
require "script/ui/lordWar/LordWarEventDispatcher"

local _roundChangeEvents = {}
local _lastRound         = nil
local _lastStatus        = nil
local _isInitUpateRound  = nil
local _roundChangeAction = nil      

--[[
TimeTitleType = {
    registerEnd,
    innerAuditionStart,
    innerAuditionEnd,
    inner32To16Start1,
    inner32To16Start2,
    inner32To16Start3,
}--]]
--[[
	@des 	:创建第几届群雄争霸赛ui
	@param 	:
	@return : sprite
--]]
function createTitleSprite( ... )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(376,48))
	-- 背景特效
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/kuafuzb/kuafuzb"), -1,CCString:create(""))
    animSprite:setAnchorPoint(ccp(0.5, 0.5))
    animSprite:setPosition(ccpsprite(0.5,0.5,retSprite))
    retSprite:addChild(animSprite)
	-- 第几届
	local num = LordWarData.getLordWarNum()
	local numFont = CCLabelTTF:create(num, g_sFontPangWa,40)
	numFont:setColor(ccc3(0xff,0xf6,0x00))
	numFont:setAnchorPoint(ccp(0.5,0.5))
	numFont:setPosition(ccp(85,retSprite:getContentSize().height*0.5))
	retSprite:addChild(numFont,2)
	return retSprite
end


--[[
	@des 	:得到阶段的描述
	@param 	:p_round:当前round, p_roundStatus:当前阶段状态, p_InnerOrCross 服内 or 跨服
	@return : sprite
--]]
function getTitleStrByCurRound( p_round, p_roundStatus, p_InnerOrCross, p_showFile)
	local strTable = {}
	strTable[LordWarData.kInner32To16] = string.format(GetLocalizeStringBy("lic_1200"), 16)
	strTable[LordWarData.kInner16To8]  = string.format(GetLocalizeStringBy("lic_1200"), 8)
	strTable[LordWarData.kInner8To4]   = string.format(GetLocalizeStringBy("lic_1200"), 4)
	strTable[LordWarData.kInner4To2]   = GetLocalizeStringBy("lic_1183")
	strTable[LordWarData.kInner2To1]   = GetLocalizeStringBy("lic_1185")
	strTable[LordWarData.kCross32To16] = string.format(GetLocalizeStringBy("lic_1201"), 16)
	strTable[LordWarData.kCross16To8]  = string.format(GetLocalizeStringBy("lic_1201"), 8)
	strTable[LordWarData.kCross8To4]   = string.format(GetLocalizeStringBy("lic_1201"), 4)
	strTable[LordWarData.kCross4To2]   = GetLocalizeStringBy("lic_1184")
	strTable[LordWarData.kCross2To1]   = GetLocalizeStringBy("lic_1186")

	--[[
    if(p_round == LordWarData.kInner2To1 and p_roundStatus == LordWarData.kRoundEnd) then
		strTable[LordWarData.kInner2To1] = GetLocalizeStringBy("lic_1202")
	end
	if(p_round == LordWarData.kCross2To1 and p_roundStatus == LordWarData.kRoundEnd) then
		strTable[LordWarData.kCross2To1] = GetLocalizeStringBy("lic_1203")
	end
    --]]

	-- 回顾历史 p_InnerOrCross
	if(p_InnerOrCross ~= nil)then
		if( p_InnerOrCross == LordWarData.kInnerType)then
			-- 服内
			if(p_showFile == "LordWar32Layer")then
				strTable[p_round] = GetLocalizeStringBy("lic_1216")
			elseif(p_showFile == "LordWar4Layer")then
				strTable[p_round] = GetLocalizeStringBy("lic_1215")
			else
				strTable[p_round] = " "
			end
		elseif( p_InnerOrCross == LordWarData.kCrossType)then
			-- 跨服
			if(p_showFile == "LordWar32Layer")then
				strTable[p_round] = GetLocalizeStringBy("lic_1218")
			elseif(p_showFile == "LordWar4Layer")then
				strTable[p_round] = GetLocalizeStringBy("lic_1207")
			else
				strTable[p_round] = " "
			end
		else
			print("erro p_InnerOrCross in getTitleStrByCurRound")
		end
	end

	if( strTable[p_round] == nil )then
		return " "
	end
	return strTable[p_round]
end

--[[
	@des :创建更新战斗信息按钮
--]]
function createUpdateInfoButton( p_norImage, p_higImage, p_size ,p_touchProity )
	local bgNode = CCNode:create()
	bgNode:setContentSize(p_size)

	--更新cd按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(p_touchProity or -128)
	bgNode:addChild(menu)

	local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite:setContentSize(p_size)
	local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite:setContentSize(p_size)

	local menuItem = CCMenuItemSprite:create(norSprite, higSprite)
	menuItem:setPosition(ccpsprite(0.5, 1, bgNode))
	menuItem:setAnchorPoint(ccp(0.5, 1))
	menu:addChild(menuItem)
	menuItem:registerScriptTapHandler(updateInfoButtonCallback)

	local updateLabel = CCRenderLabel:create(GetLocalizeStringBy("key_8305"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	updateLabel:setAnchorPoint(ccp(0.5, 0.5))
	updateLabel:setPosition(ccpsprite(0.5, 0.5, menuItem))
	updateLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	menuItem:addChild(updateLabel)
    local cdTime = LordWarData.getUpdateInfoCDTime()
    local getClearDesNode = function()
        local clearCDLabel = CCRenderLabel:create(GetLocalizeStringBy("key_8304"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        clearCDLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))

        local goldIcon = CCSprite:create("images/common/gold.png")
        local cdTime = LordWarData.getUpdateInfoCDTime()
        local costGold = LordWarData.getCleanCdGoldCount()
        local clearGoldLabel = CCLabelTTF:create(tostring(costGold), g_sFontPangWa, 35)
        clearGoldLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))

        local clearDesNode = BaseUI.createHorizontalNode({clearCDLabel, goldIcon, clearGoldLabel})
        clearDesNode:setAnchorPoint(ccp(0.5, 0.5))
        clearDesNode:setPosition(ccpsprite(0.5, 0.5, menuItem))
        
        return clearDesNode
    end
    local clearDesNode = getClearDesNode()
    menuItem:addChild(clearDesNode,10,1)
    local cdTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_8303") .. TimeUtil.getTimeString(cdTime), g_sFontName, 21)
	cdTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
	cdTimeLabel:setAnchorPoint(ccp(0.5, 1))
	cdTimeLabel:setPosition(ccp(bgNode:getContentSize().width * 0.5, 10))
	bgNode:addChild(cdTimeLabel)

	local updateCDTimer = function ( ... )
        if tolua.cast(bgNode, "CCNode") == nil then
            return
        end
		local cdTime = LordWarData.getUpdateInfoCDTime()
	  	if(cdTime <= 0) then
	    	cdTime = 0
	    	cdTimeLabel:setString(GetLocalizeStringBy("key_8303") .. TimeUtil.getTimeString(cdTime))
	    	cdTimeLabel:setVisible(false)
	    	updateLabel:setVisible(true)
	    	clearDesNode:setVisible(false)
	    else
	    	updateLabel:setVisible(false)
	    	cdTimeLabel:setVisible(true)
	    	clearDesNode:setVisible(true)
	    	cdTimeLabel:setString(GetLocalizeStringBy("key_8303") .. TimeUtil.getTimeString(cdTime))
            clearDesNode:removeFromParentAndCleanup(true)
            clearDesNode = getClearDesNode()
            menuItem:addChild(clearDesNode,10,1)
	    end
	end
	updateCDTimer()
    -- schedule(menuItem,updateCDTimer, 1)
    LordWarEventDispatcher.addListener("lordWarUtil.updateCDTimer", updateCDTimer)
    return bgNode
end

--[[
	des: 更新战斗力按钮回调
--]]
function updateInfoButtonCallback( tag, sender )
    local curRound = LordWarData.getCurRound()
    local curStatus = LordWarData.getCurRoundStatus()
    -- 比赛是否结束
    if curRound >= LordWarData.kCross2To1 and curStatus >= LordWarData.kRoundFighted then
        AnimationTip.showTip(GetLocalizeStringBy("key_8302"))
        return
    end
    -- 是否报名
    if(LordWarData.isRegister() == false) then
        AnimationTip.showTip(GetLocalizeStringBy("key_8301"))
        return
    end
    
    --该玩家是不是已经淘汰
    local requestCallback = function( isSuccess )
        if(isSuccess == "ok") then
            AnimationTip.showTip(GetLocalizeStringBy("key_8300"))
        else
            AnimationTip.showTip(GetLocalizeStringBy("key_8299"))
        end
        return
    end
        
	local cdTime = LordWarData.getUpdateInfoCDTime()
	--清除cd
	local clearCD = function (isConfirm, _argsCB)
        if isConfirm == false then
            return
        end
        local cdTime = LordWarData.getUpdateInfoCDTime()
        if cdTime <= 0 then
            AnimationTip.showTip(GetLocalizeStringBy("key_8298"))
            return
        end
        local curRound = LordWarData.getCurRound()
        local curStatus = LordWarData.getCurRoundStatus()
        if curRound >= LordWarData.kCross2To1 and curStatus >= LordWarData.kRoundFighted then
            AnimationTip.showTip(GetLocalizeStringBy("key_8297"))
            return
        end
		--判断金币是否足够
		local costGold = LordWarData.getCleanCdGoldCount(cdTime)
		if(UserModel.getGoldNumber() < costGold) then
			AnimationTip.showTip(GetLocalizeStringBy("key_8296"))
			return
		end
		--清除cd
		local requestCallback = function( p_costGold )
			AnimationTip.showTip(string.format(GetLocalizeStringBy("key_8295"), LordWarData.getCleanCdGoldCount()))
			return
		end
		LordWarService.clearFmtCd(requestCallback)
	end
	if(cdTime > 0) then
        --判断金币是否足够
		local costGold = LordWarData.getCleanCdGoldCount(cdTime)
        require "script/ui/tip/AlertTip2"
        local others = {}
        AlertTip2.showAlert(nil, nil, clearCD, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, others)
        local tip1 = {}
        tip1[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8294"), g_sFontName, 25)
        tip1[1]:setColor(ccc3(0x78, 0x25, 0x00))
        tip1[2] = CCSprite:create("images/common/gold.png")
        tip1[3] = CCLabelTTF:create(tostring(costGold), g_sFontName, 25)
        tip1[3]:setColor(ccc3(0x78, 0x25, 0x00))
        local tip1Node = BaseUI.createHorizontalNode(tip1)
        others.bg:addChild(tip1Node)
        tip1Node:setAnchorPoint(ccp(0.5, 0.5))
        tip1Node:setPosition(ccp(others.bg:getContentSize().width * 0.5, others.bg:getContentSize().height - 150))
        local tip2Node = CCLabelTTF:create(GetLocalizeStringBy("key_8293"), g_sFontName, 25)
        others.bg:addChild(tip2Node)
        tip2Node:setColor(ccc3(0x78, 0x25, 0x00))
        tip2Node:setAnchorPoint(ccp(0.5, 0.5))
        tip2Node:setPosition(ccp(tip1Node:getPositionX(), others.bg:getContentSize().height - 180))
    else
		LordWarService.updateFightInfo(requestCallback)
	end
end

--[[
	@des : 阶段变化监听器
--]]
function addRoundChangeEvent( p_key, p_callback )
	if(p_callback) then
		_roundChangeEvents[tostring(p_key)]= p_callback
	end
end


--[[
	@des : 阶段变化
--]]
function roundChange( p_round, p_status )
	if(p_round > LordWarData.kCross2To1) then
		return
	end
	LordWarData.setCurRound(p_round)
	LordWarData.setCurStatus(p_status)
	--刷新晋级赛数据
	local excute = function ( ... )
		for k,v in pairs(_roundChangeEvents) do
            print("执行更新方法：", k)
			v(p_round, p_status)
			print("excute :", p_round, p_status)
		end
	end
	-- 发奖状态清除上阶段助威人
	if(p_status >= LordWarData.kRoundReward) then
		LordWarData.setCheerInfo("0", "0")
	end
	excute()
	print(" p_round, p_status",  p_round, p_status)
end

--[[
    @des: 播放胜利的特效
--]]
function playWinEffect(hero_node)
    local  winEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/kuang/kuang"), -1, CCString:create(""))
    winEffect:setAnchorPoint(ccp(0.5,0.5))
    winEffect:setPosition(hero_node:getContentSize().width * 0.5,hero_node:getContentSize().height/2)
    hero_node:addChild(winEffect,11)
    winEffect:retain()
    
    -- 注册代理
    -- 胜利特效
    local winEffectCallBack = function( ... )
        if( winEffect ~= nil )then
            winEffect:release()
            winEffect:removeFromParentAndCleanup(true)
            winEffect = nil
        end
    end
    local downDelegate = BTAnimationEventDelegate:create()
    downDelegate:registerLayerEndedHandler(winEffectCallBack)
    winEffect:setDelegate(downDelegate)
end

function getRoundDes( ... )
	local curRound = LordWarData.getCurRound()
	local curStatus = LordWarData.getCurRoundStatus()
    local curSubRound = LordWarData.getCurSubRound()
    local nextSubRound = curSubRound + 2
    local subRoundTime = LordWarData.getOneTurnIntervalTime()
	local retTable = {}
	local curTime  = BTUtil:getSvrTimeInterval()
    if curTime < LordWarData. getRoundStartTime(LordWarData.kRegister) then
        retTable.des = GetLocalizeStringBy("key_8306") -- "距离群雄争霸报名开始时间："
        retTable.time = LordWarData. getRoundStartTime(LordWarData.kRegister) - curTime
    elseif curTime < LordWarData.getRoundEndTime(LordWarData.kRegister) then
		retTable.des = GetLocalizeStringBy("key_8292") -- "距离群雄争霸报名结束时间："
		retTable.time = LordWarData.getRoundEndTime(LordWarData.kRegister) - curTime
    elseif curTime < LordWarData.getRoundStartTime(LordWarData.kInnerAudition) then
		retTable.des = GetLocalizeStringBy("key_8291") -- "距离群雄争霸服内海选赛开始："
		retTable.time = LordWarData.getRoundStartTime(LordWarData.kInnerAudition) - curTime
	elseif curRound < LordWarData.kInnerAudition
        or (curRound == LordWarData.kInnerAudition and curStatus < LordWarData.kRoundEnd) then
        if curTime < LordWarData.getRoundEndTime(LordWarData.kInnerAudition) then
            retTable.des = GetLocalizeStringBy("key_8290") -- "群雄争霸服内海选赛进行中..."
        else
            retTable.des = GetLocalizeStringBy("key_8281") -- "战斗结果计算中..."
        end
        retTable.isShowTime = false
    elseif curRound < LordWarData.kInner2To1 or (curRound == LordWarData.kInner2To1 and curStatus < LordWarData.kRoundFighted) then
        local titles = {}
        titles[1] = GetLocalizeStringBy("key_8289") -- "服内%d强晋级赛第%d轮开始倒计时："
        titles[2] = GetLocalizeStringBy("key_8288") -- "服内半决赛第%d轮开始倒计时："
        titles[3] = GetLocalizeStringBy("key_8287") -- "服内决赛第%d轮开始倒计时："
        local round = nil
        local status = nil
        if curStatus >= LordWarData.kRoundFighted then
            round = curRound + 1
            status = LordWarData.kRoundFighting
        else
            round = curRound
            status = curStatus
        end
        local curQiang = LordWarData.getRoundRank(round) * 0.5
        if curTime < LordWarData.getRoundStartTime(round) + subRoundTime * (nextSubRound - 1) then
            if round < LordWarData.kInner8To4 or (round == LordWarData.kInner8To4 and status < LordWarData.kRoundFighted) then
                retTable.des = string.format(titles[1], curQiang, nextSubRound)
            elseif round < LordWarData.kInner4To2 or (round == LordWarData.kInner4To2 and status < LordWarData.kRoundFighted) then
                retTable.des = string.format(titles[2], nextSubRound)
            else
                retTable.des = string.format(titles[3], nextSubRound)
            end
            retTable.time = LordWarData.getRoundStartTime(round) + subRoundTime * (nextSubRound - 1) - curTime 
        else
            retTable.des = GetLocalizeStringBy("key_8281") -- "战斗结果计算中..."
            retTable.isShowTime = false
        end
    elseif (curRound == LordWarData.kInner2To1 and curStatus >= LordWarData.kRoundFighted) then
        if curTime < LordWarData.getRoundStartTime(LordWarData.kCrossAudition) then
            retTable.des = GetLocalizeStringBy("key_8286") -- "距离跨服海选开始倒计时："
            retTable.time = LordWarData.getRoundStartTime(LordWarData.kCrossAudition) - curTime
        else
            retTable.des = GetLocalizeStringBy("key_8281") -- "战斗结果计算中..."
            retTable.isShowTime = false
        end
    elseif curRound < LordWarData.kCrossAudition
        or (curRound == LordWarData.kCrossAudition and curStatus < LordWarData.kRoundEnd) then
        if curTime < LordWarData.getRoundEndTime(LordWarData.kCrossAudition) then
            retTable.des = GetLocalizeStringBy("key_8285") -- "群雄争霸跨服海选赛进行中..."
        else
            retTable.des = GetLocalizeStringBy("key_8281") -- "战斗结果计算中..."
        end
        retTable.isShowTime = false
    elseif curRound < LordWarData.kCross2To1 or (curRound == LordWarData.kCross2To1 and curStatus < LordWarData.kRoundFighted) then
        local titles = {}
        titles[1] = GetLocalizeStringBy("key_8284") -- "跨服%d强晋级赛第%d轮开始倒计时："
        titles[2] = GetLocalizeStringBy("key_8283") -- "跨服半决赛第%d轮开始倒计时："
        titles[3] = GetLocalizeStringBy("key_8282") -- "跨服决赛第%d轮开始倒计时："
        local round = nil
        local status = nil
        if curStatus >= LordWarData.kRoundFighted then
            round = curRound + 1
            status = LordWarData.kRoundFighting
        else
            round = curRound
            status = curStatus
        end
        local curQiang = LordWarData.getRoundRank(round) * 0.5
        if curTime < LordWarData.getRoundStartTime(round) + subRoundTime * (nextSubRound - 1) then
            if round < LordWarData.kCross8To4 or (round == LordWarData.kCross8To4 and status < LordWarData.kRoundFighted) then
                retTable.des = string.format(titles[1], curQiang, nextSubRound)
            elseif round < LordWarData.kCross4To2 or (round == LordWarData.kCross4To2 and status < LordWarData.kRoundFighted) then
                retTable.des = string.format(titles[2], nextSubRound)
            else 
                retTable.des = string.format(titles[3], nextSubRound)
            end
            retTable.time = LordWarData.getRoundStartTime(round) + subRoundTime * (nextSubRound - 1) - curTime 
        else
            retTable.des = GetLocalizeStringBy("key_8281") -- "战斗结果计算中..."
            retTable.isShowTime = false
        end
    else
		retTable.des = GetLocalizeStringBy("key_8280") -- "本届群雄争霸赛已结束"
		retTable.time = LordWarData.getRoundEndTime(LordWarData.kCross2To1) - curTime
        retTable.isShowTime = false
        retTable.type = "end"
	end
    return retTable
end

function getTimeTitle(p_type)
    local isRunning = true
    local timeTileNode = CCNode:create()
    local onNodeEvent = function(event)
        if event == "enter" then
            isRunning = true
        elseif event == "exit" then
            isRunning = false
        end
    end
    timeTileNode:registerScriptHandler(onNodeEvent)
    local timeDes = getRoundDes()
    local titleLabel = nil
    if p_type == "LordWarMainLayer" then
        titleLabel = CCRenderLabel:create("", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    else
        titleLabel = CCLabelTTF:create("", g_sFontPangWa, 21)
    end
    timeTileNode:addChild(titleLabel)
    titleLabel:setColor(ccc3(0x00, 0xff, 0x18))
    titleLabel:setAnchorPoint(ccp(0, 0.5))
    titleLabel:setPosition(ccp(0, 0))
    local timeBg = CCSprite:create("images/olympic/time_bg.png")
    timeTileNode:addChild(timeBg)
    timeBg:setAnchorPoint(ccp(0, 0.5))
    local timeLabel = CCLabelTTF:create("00  :  00  :  00", g_sFontPangWa, 21)
    timeBg:addChild(timeLabel)
    timeLabel:setAnchorPoint(ccp(0.5, 0.5))
    timeLabel:setPosition(ccpsprite(0.5, 0.5, timeBg))
    local update = function()
        if isRunning == false then
            return
        end
        local size = CCSizeMake(0, 0)
        local timeDes = getRoundDes()
        titleLabel:setString(timeDes.des)
        size.width = size.width + titleLabel:getContentSize().width
        if timeDes.isShowTime == false then
            timeBg:setVisible(false)
            if timeDes.type == "end" and p_type ~= "LordWarMainLayer" then
                titleLabel:setVisible(false)
            end
        else
            timeBg:setPosition(ccp(size.width, 0))
            local remainTimeStr = TimeUtil.getTimeString(timeDes.time)
            local timeArray = string.split(remainTimeStr, ":")
            local timeStr = string.format("%s  :  %s  :  %s", timeArray[1], timeArray[2], timeArray[3])
            timeLabel:setString(timeStr)
            timeBg:setVisible(true)
            size.width = size.width + timeBg:getContentSize().width
        end
        timeTileNode:setContentSize(size)
    end
    update()
    LordWarEventDispatcher.addListener("LordWarUtil.getTimeTitle", update)
    return timeTileNode
end

function getRoundTitle()
    local titleLabel = CCLabelTTF:create("", g_sFontPangWa, 25)
    titleLabel:setColor(ccc3(0x00, 0xe4, 0xff))
    local isRunning = true
    local onNodeEvent = function(event)
        if event == "enter" then
            isRunning = true
        elseif event == "exit" then
            isRunning = false
        end
    end
    titleLabel:registerScriptHandler(onNodeEvent)
    local update = function()
        if isRunning == false then
            return
        end
        local curRound = LordWarData.getCurRound()
        local curStatus = LordWarData.getCurRoundStatus()
        local curSubRound = LordWarData.getCurSubRound()
        local nextSubRound = curSubRound + 2
        local subRoundTime = LordWarData.getOneTurnIntervalTime()
        local title = nil
        local curTime  = BTUtil:getSvrTimeInterval()
        if curTime < LordWarData.getRoundStartTime(LordWarData.kRegister) then
            title = GetLocalizeStringBy("key_10048")
        elseif curTime < LordWarData.getRoundEndTime(LordWarData.kRegister) then
            title = GetLocalizeStringBy("key_8279") -- "报名中"
        elseif curTime < LordWarData.getRoundStartTime(LordWarData.kInnerAudition) then
            title = GetLocalizeStringBy("key_8278") -- "服内海选赛开始倒计时："
        elseif curRound < LordWarData.kInnerAudition
            or (curRound == LordWarData.kInnerAudition and curStatus < LordWarData.kRoundEnd) then
            title = GetLocalizeStringBy("key_8277") -- "服内海选赛"
        elseif curRound < LordWarData.kInner2To1 or (curRound == LordWarData.kInner2To1 and curStatus < LordWarData.kRoundFighted) then
            local titles = {}
            titles[1] = GetLocalizeStringBy("key_8276") -- "服内%d强晋级赛"
            titles[2] = GetLocalizeStringBy("key_8275") -- "服内半决赛"
            titles[3] = GetLocalizeStringBy("key_8274") -- "服内决赛"
            local round = nil
            local status = nil
            if curStatus >= LordWarData.kRoundFighted then
                round = curRound + 1
                status = LordWarData.kRoundFighting
            else
                round = curRound
                status = curStatus
            end
            local curQiang = LordWarData.getRoundRank(round) * 0.5
            if round < LordWarData.kInner8To4 or (round == LordWarData.kInner8To4 and status < LordWarData.kRoundFighted) then
                title = string.format(titles[1], curQiang)
            elseif round < LordWarData.kInner4To2 or (round == LordWarData.kInner4To2 and status < LordWarData.kRoundFighted) then
                title = titles[2]
            else
                title = titles[3]
            end
        elseif (curRound == LordWarData.kInner2To1 and curStatus >= LordWarData.kRoundFighted) then
            title = GetLocalizeStringBy("key_8273") -- "海选开始倒计时："
        elseif curRound < LordWarData.kCrossAudition
            or (curRound == LordWarData.kCrossAudition and curStatus < LordWarData.kRoundEnd) then
            title = GetLocalizeStringBy("key_8272") -- "跨服海选"
        elseif curRound < LordWarData.kCross2To1 or (curRound == LordWarData.kCross2To1 and curStatus < LordWarData.kRoundFighted) then
            local titles = {}
            titles[1] = GetLocalizeStringBy("key_8271") -- "跨服%d强晋级赛"
            titles[2] = GetLocalizeStringBy("key_8270") -- "跨服半决赛"
            titles[3] = GetLocalizeStringBy("key_8269") -- "跨服决赛"
            local round = nil
            local status = nil
            if curStatus >= LordWarData.kRoundFighted then
                round = curRound + 1
                status = LordWarData.kRoundFighting
            else
                round = curRound
                status = curStatus
            end
            local curQiang = LordWarData.getRoundRank(round) * 0.5
            if round < LordWarData.kCross8To4 or (round == LordWarData.kCross8To4 and status < LordWarData.kRoundFighted) then
                 title = string.format(titles[1], curQiang)
            elseif round < LordWarData.kCross4To2 or (round == LordWarData.kCross4To2 and status < LordWarData.kRoundFighted) then
                title = titles[2]
            else 
                title = titles[3]
            end
        else
            title = GetLocalizeStringBy("key_8268") -- "本届群雄争霸赛已结束"
        end

        titleLabel:setString(title)
    end
    update()
    LordWarEventDispatcher. addListener("LordWarUtil.getRoundTitle", update)
    return titleLabel
end
