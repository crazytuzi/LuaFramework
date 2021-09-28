-- Filename: WorldCarnivalUtil.lua
-- Author: bzx
-- Date: 2014-08-27
-- Purpose: 跨服嘉年华工具

module("WorldCarnivalUtil", package.seeall)

btimport "script/ui/world_carnival/WorldCarnivalController"
btimport "script/ui/world_carnival/WorldCarnivalEventDispatcher"

local _topSprite = nil 			-- 比赛界面上部


--[[
	@desc:						比赛界面上部的UI
	@param:	p_touchPriority   	按钮优先级
--]]
function createTopSprite(p_touchPriority)
    _topSprite = CCSprite:create()
    _topSprite:setContentSize(CCSizeMake(640, 180))
    
    local vsSprite = CCSprite:create("images/carnival/god_vs_god.png")
    _topSprite:addChild(vsSprite)
    vsSprite:setAnchorPoint(ccp(0.5, 1))
    vsSprite:setPosition(ccpsprite(0.5, 1, _topSprite))

    local vsEffect = XMLSprite:create("images/base/effect/shenvsshen/shenvsshen")
    vsSprite:addChild(vsEffect)
    vsEffect:setPosition(ccpsprite(0.5, 0.5, vsSprite))

    local titleSprite = CCSprite:create("images/carnival/mingxing.png")
    _topSprite:addChild(titleSprite)
    titleSprite:setAnchorPoint(ccp(0.5, 0.5))
    titleSprite:setPosition(ccpsprite(0.5, 0.41, _topSprite))
    
    local titleEffect = XMLSprite:create("images/base/effect/mingxingzhengbasai/mingxingzhengbasai")
    titleSprite:addChild(titleEffect)
    titleEffect:setPosition(ccpsprite(0.5, 0.5, titleSprite))

    local menu = CCMenu:create()
    _topSprite:addChild(menu)
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(_topSprite:getContentSize())
    menu:setTouchPriority(p_touchPriority)

    --布阵
    local formationItem = nil
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
		formationItem = CCMenuItemImage:create("images/copy/array_n.png","images/copy/array_h.png")
	else
		formationItem = CCMenuItemImage:create("images/copy/arraybu_n.png","images/copy/arraybu_h.png")
	end
	formationItem:setAnchorPoint(ccp(1, 0.5))
	formationItem:registerScriptTapHandler(WorldCarnivalController.formationCallback)
	formationItem:setPosition(ccpsprite(0.2, 0.7, _topSprite))
	menu:addChild(formationItem)

    -- -- 说明
    -- local descItem = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
    -- menu:addChild(descItem)
    -- descItem:setAnchorPoint(ccp(0.5, 0.5))
    -- descItem:setPosition(ccp(56, 199))
    -- descItem:registerScriptTapHandler(GuildWarPromotionController.descCallback)
    -- 返回
    local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
    menu:addChild(backItem)
    backItem:setAnchorPoint(ccp(0.5, 0.5))
    backItem:setPosition(ccpsprite(0.9, 0.7, _topSprite))
    backItem:registerScriptTapHandler(WorldCarnivalController.backCallback)

    -- 分割线
    local line = CCSprite:create("images/common/separator_top.png")
    line:setPosition(ccp(320, 0))
    line:setAnchorPoint(ccp(0.5, 0.5))
    _topSprite:addChild(line)

    return _topSprite
end

--[[
	@desc:		比赛界面底部UI
	@param:		p_touchPriority 	按钮优先级
--]]
function createBottomSprite(p_touchPriority)
	local bottomSprite = CCSprite:create()
    bottomSprite:setContentSize(CCSizeMake(640, 95))
    local line = CCSprite:create("images/common/separator_top.png")
    bottomSprite:addChild(line)
    line:setScaleY(-1)
    line:setPosition(ccp(320, bottomSprite:getContentSize().height))
    line:setAnchorPoint(ccp(0.5, 0.5))

    local menu = CCMenu:create()
    bottomSprite:addChild(menu)
    menu:setContentSize(bottomSprite:getContentSize())
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(p_touchPriority)

	local item = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png", CCSizeMake(300, 73), GetLocalizeStringBy("key_8500"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(item)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:setPosition(ccpsprite(0.5, 0.5, bottomSprite))
    item:registerScriptTapHandler(WorldCarnivalController.updateFormationInfoCallback)
    return bottomSprite
end

--[[
	@desc:	倒计时提示
--]]
function getTimeDescData( ... )
	local timeDesc = {}
	local curTime = WorldCarnivalEventDispatcher.getCurTime()
	local curRound = WorldCarnivalData.getCurRound()
	local curStatus = WorldCarnivalData.getCurStatus()
	local curSubRound = WorldCarnivalData.getCurSubRound()
    local subRound = curSubRound
    if curStatus == WorldCarnivalConstant.STATUS_DONE then
        subRound = 0
    end
	local curSubStatus = WorldCarnivalData.getCurSubStatus()
    print("curTime==", curTime, WorldCarnivalData.getNextSubRoundStartTime())
	local subRoundTexts = {GetLocalizeStringBy("zzh_1284"), GetLocalizeStringBy("lic_1458"), GetLocalizeStringBy("lic_1459"), GetLocalizeStringBy("lic_1460"), GetLocalizeStringBy("key_8111")}
	if curSubStatus == WorldCarnivalConstant.STATUS_FIGHTING then
		timeDesc.title = GetLocalizeStringBy("key_10329")
	else
		if curRound < WorldCarnivalConstant.ROUND_1 or 
			(curRound == WorldCarnivalConstant.ROUND_1 and curStatus < WorldCarnivalConstant.STATUS_DONE) then
			timeDesc.title = string.format(GetLocalizeStringBy("key_10330"), subRoundTexts[subRound + 1])
		elseif (curRound == WorldCarnivalConstant.ROUND_1 and curStatus == WorldCarnivalConstant.STATUS_DONE) or
			(curRound == WorldCarnivalConstant.ROUND_2 and curStatus < WorldCarnivalConstant.STATUS_DONE) then
			timeDesc.title = string.format(GetLocalizeStringBy("key_10331"), subRoundTexts[subRound + 1])
		elseif (curRound == WorldCarnivalConstant.ROUND_2 and curStatus == WorldCarnivalConstant.STATUS_DONE) or
			(curRound == WorldCarnivalConstant.ROUND_3 and curStatus < WorldCarnivalConstant.STATUS_DONE) then
			timeDesc.title = string.format(GetLocalizeStringBy("key_10332"), subRoundTexts[subRound + 1])
		else
			timeDesc.title = GetLocalizeStringBy("key_8480")
		end
		local nextSubRoundTime = WorldCarnivalData.getNextSubRoundStartTime()
        if nextSubRoundTime ~= nil then
            timeDesc.remainTime = nextSubRoundTime - curTime
        end
    end
	return timeDesc
end

-- 得到倒计时UI
function getTimeDescSprite()
    local timeTileSprite = CCSprite:create()
    local timeDescData = getTimeDescData()
    local titleLabel = nil
    titleLabel = CCRenderLabel:create("", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    timeTileSprite:addChild(titleLabel)
    titleLabel:setColor(ccc3(0x00, 0xff, 0x18))
    titleLabel:setAnchorPoint(ccp(0, 0.5))
    titleLabel:setPosition(ccp(0, 0))
    local timeBg = CCSprite:create("images/olympic/time_bg.png")
    timeTileSprite:addChild(timeBg)
    timeBg:setAnchorPoint(ccp(0, 0.5))
    timeBg:setScaleY(0.8)
    local timeLabel = CCLabelTTF:create("00  :  00  :  00", g_sFontPangWa, 21)
    timeBg:addChild(timeLabel)
    timeLabel:setAnchorPoint(ccp(0.5, 0.5))
    timeLabel:setPosition(ccpsprite(0.5, 0.5, timeBg))
    local update = function(p_round,p_status, p_subRound, p_subStatus, eventType)
    	if eventType ~= "update" then
    		return
    	end
    	if tolua.isnull(timeTileSprite) then
    		return	
    	end
        local size = CCSizeMake(0, 0)
        local timeDescData = getTimeDescData()
        titleLabel:setString(timeDescData.title)
        print_t(timeDescData)
        size.width = size.width + titleLabel:getContentSize().width
        if timeDescData.remainTime == nil then
            timeBg:setVisible(false)
        else
            timeBg:setPosition(ccp(size.width, 0))
            local remainTimeStr = TimeUtil.getTimeString(timeDescData.remainTime)
            local timeArray = string.split(remainTimeStr, ":")
            local timeStr = string.format("%s  :  %s  :  %s", timeArray[1], timeArray[2], timeArray[3])
            timeLabel:setString(timeStr)
            timeBg:setVisible(true)
            size.width = size.width + timeBg:getContentSize().width
        end
        timeTileSprite:setContentSize(size)
    end
    update(nil, nil, nil, nil, "update")
    WorldCarnivalEventDispatcher.addListener("WorldCarnivalUtil.getTimeDescSprite", update)
    return timeTileSprite
end