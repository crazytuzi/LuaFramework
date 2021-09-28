-- Filename：	AthenaInfoLayer.lua
-- Author：		zhang zihang
-- Date：		2015-4-1
-- Purpose：		星魂普通技能信息面板

module("AthenaInfoLayer",package.seeall)

require "script/ui/athena/AthenaData"
require "script/ui/athena/AthenaUtils"
require "script/ui/hero/HeroPublicLua"
require "script/utils/LevelUpUtil"
require "script/utils/BaseUI"

local _touchPriority
local _zOrder
local _bgLayer
local _costInfo
local _atrrInfo
local _itemId
local _itemLv
local _unLockInfo
local _doneCb    --升级完成后的回调

--[[
	@des 	:初始化
--]]
function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_costInfo = nil
	_atrrInfo = nil
	_itemId = nil
	_itemLv = nil
	_unLockInfo = nil
    _doneCb = nil
end

--[[
	@des 	:触摸回调
	@param  :事件
--]]
function onTouchesHandler(p_eventType)
	if p_eventType == "began" then
	    return true
	end
end

--[[
	@des 	:touch事件
	@param  :事件
--]]
function onNodeEvent(p_event)
	if p_event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif p_event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:关闭回调
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	removeLayer()
end

--[[
	@des 	:删除layer
--]]
function removeLayer()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:升级回调
--]]
function upGradeCallBack()
	print("outoutoutoutoutoutout")
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local curPage = AthenaData.getCurPageNo()

	if not AthenaData.isSkillOpen(_itemId,curPage) then
		local psString
		if table.isEmpty(_unLockInfo) then
			if AthenaData.isSSOpen(curPage - 1) then
	    		local upPageInfo = AthenaData.getTreeDBInfo(curPage - 1)
	    		psString = GetLocalizeStringBy("zzh_1333",tonumber(upPageInfo.level))
	    	else
	    		psString = GetLocalizeStringBy("zzh_1332")
	    	end
	    else
	    	psString = GetLocalizeStringBy("zzh_1305")
	    end
		AnimationTip.showTip(psString)
		return
	--满级了
	elseif AthenaData.isFullLv(_itemId,curPage) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1302"))
		return
	--物品不够
	elseif not AthenaData.isGoodEnough(_itemId,curPage) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1303"))
		return
	end

	--背包回调后调刷新方法
	--PreRequest.setBagDataChangedDelete(refreshMainUI)

	local isSSOpenBefore = AthenaData.isSSOpen(curPage)

	local serviceCallBack = function()
		--扣隐蔽
		AthenaData.costSilver(_itemId,curPage)
		--扣物品
		AthenaData.costItem(_itemId,curPage)
		AthenaData.setSkillLv(_itemId,_itemLv + 1)
        --强制刷新一下属性缓存 
        AthenaData.getAtrrInfoForFightForce(true)
		local isSSOpenNow = AthenaData.isSSOpen(curPage)
		--如果升级前特殊技能没有开，升级后开了
		if isSSOpenBefore == false and isSSOpenNow == true then
			--添加新的技能
			AthenaData.addSSkill(curPage)

			local paramTable = {}
			paramTable[1] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1323"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
			paramTable[1]:setColor(ccc3(0x76,0xfc,0x06))
			local pageInfo = AthenaData.getTreeDBInfo(curPage)
			local SSInfo = AthenaData.getSSDBInfo(AthenaData.getSSkillId(pageInfo)[1])
			paramTable[2] = CCRenderLabel:create("[" .. SSInfo.name .. "]",g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
			paramTable[2]:setColor(ccc3(255,0,0xe1))
			paramTable[3] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1324"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
			paramTable[3]:setColor(ccc3(0x76,0xfc,0x06))

			LevelUpUtil.showFlyNode(BaseUI.createHorizontalNode(paramTable),0.45)

			--如果有下一颗树，且主角等级满足，则创建之
			if AthenaData.getNextTree(curPage) ~= nil and AthenaData.isHeroLvEnough(curPage) then
				--这设置最大开启页数
				AthenaData.setOpenNum(curPage + 1)
				--创建下一个node
				AthenaMainLayer.createNextNode()
				local innerTable = {}
				innerTable[1] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1325"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
				innerTable[1]:setColor(ccc3(0x76,0xfc,0x06))
				LevelUpUtil.showFlyNode(BaseUI.createHorizontalNode(innerTable),0.4)
			end
		end

		LevelUpUtil.showFlyText(AthenaData.getLevelUpAddAtrr(_itemId))

		--刷界面
		AthenaMainLayer.refreshAllSkill(_itemId)
		--刷星魂数
		AthenaMainLayer.refreshStarNum()

		removeLayer()
        
        if(_doneCb ~= nil)then
            _doneCb()
        end
	end

	AthenaService.upGrade(curPage,_itemId,serviceCallBack)
end

--[[
	@des 	:刷新主页面
--]]
-- function refreshMainUI()
-- 	AthenaMainLayer.refreshAllSkill(_itemId)
-- 	AthenaMainLayer.refreshStarNum()
-- 	PreRequest.setBagDataChangedDelete(nil)
-- end

--[[
	@des 	:创建UI
--]]
function createUI()
	--技能信息
    local itemInfo = AthenaData.getSkillDBInfo(_itemId)
    local skillMaxLv = tonumber(itemInfo.maxLevel)
	local isCostVisible = (_itemLv < skillMaxLv)

	local costCondition = (table.count(_costInfo) > 0) and isCostVisible

	--消耗物品所占的高度
	local costHeight = costCondition and 35*(table.count(_costInfo) - 0) or 0
	local atrrHeight = (table.count(_atrrInfo) > 1) and 30*(table.count(_atrrInfo) - 1) or 0
	local curPage = AthenaData.getCurPageNo()
	local isUnlock = AthenaData.isSkillOpen(_itemId,curPage)
	local unLockCondition = (table.count(_unLockInfo) > 1) and (not isUnlock)
	local unLockHeight = unLockCondition and  40*(table.count(_unLockInfo) - 1) or 0

    local addHeight
    if _itemLv <= 0 or _itemLv >= skillMaxLv then
    	addHeight = atrrHeight
    else
    	addHeight = atrrHeight*2 + 60
    end

	--背景大小
	local bgSize = CCSizeMake(555,430 + costHeight + addHeight + unLockHeight)
	--背景图
	local bgSprite = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
	bgSprite:setContentSize(bgSize)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleSprite)

	local titleSize = titleSprite:getContentSize()

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2276"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSize.width*0.5,titleSize.height*0.5))
	titleSprite:addChild(titleLabel)

	--背景按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
	closeMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(closeMenuItem)

	local secBgSize = CCSizeMake(495,205 + costHeight + addHeight)
	-- 黑色的背景
    local secBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    secBgSprite:setContentSize(secBgSize)
    secBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 55))
    secBgSprite:setAnchorPoint(ccp(0.5,1))
    bgSprite:addChild(secBgSprite)
    --技能名称
    local itemNameLabel = CCLabelTTF:create(itemInfo.name,g_sFontPangWa,30)
    itemNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.skillQuality))
    itemNameLabel:setAnchorPoint(ccp(0.5,1))
    itemNameLabel:setPosition(ccp(secBgSize.width*0.5,secBgSize.height - 20))
    secBgSprite:addChild(itemNameLabel)
    --第一层分线
    local firstLineSprite = CCScale9Sprite:create("images/common/line02.png")
    firstLineSprite:setContentSize(CCSizeMake(470,5))
    firstLineSprite:setAnchorPoint(ccp(0.5,0.5))
    firstLineSprite:setPosition(ccp(secBgSize.width*0.5,secBgSize.height - 65))
    secBgSprite:addChild(firstLineSprite)
    --技能图
    local skillSprite = AthenaUtils.getNormalSkillSprite(_itemId,curPage)
    skillSprite:setAnchorPoint(ccp(0,1))
    skillSprite:setPosition(ccp(35,secBgSize.height - 95))
    secBgSprite:addChild(skillSprite)
    --属性table
    local atrrNameTable = { GetLocalizeStringBy("lic_1515"),GetLocalizeStringBy("zzh_1306") }
    local beginYTable = { secBgSize.height - 95,secBgSize.height - 180 - atrrHeight }
    if _itemLv <= 0 then
    	AthenaUtils.addAtrrInfoToBg(secBgSprite,atrrNameTable[2],beginYTable[1],_itemLv + 1,_itemId)
    elseif _itemLv >= skillMaxLv then
    	AthenaUtils.addAtrrInfoToBg(secBgSprite,atrrNameTable[1],beginYTable[1],_itemLv,_itemId)
    else
   		for i = 1,2 do
   			AthenaUtils.addAtrrInfoToBg(secBgSprite,atrrNameTable[i],beginYTable[i],_itemLv + i - 1,_itemId)
   		end
    end
    local i = 0

    if isCostVisible then
	    --消耗
	    for k,v in pairs(_costInfo) do
	    	local firstString = GetLocalizeStringBy("zzh_1308")
	    	local nameString
	    	local spriteString
	    	if k == 0 then
	    		nameString = GetLocalizeStringBy("key_1687")
	    		spriteString = "images/common/coin.png"
	    	else
	    		local costItemInfo = ItemUtil.getItemById(k)
	    		nameString = costItemInfo.name
	    		spriteString = "images/athena/tu.png"
	    	end

	    	local firstLabel = CCLabelTTF:create(firstString .. nameString .. ":",g_sFontName,21)
	    	firstLabel:setColor(ccc3(0x00,0xff,0x18))
	    	local itemSprite = CCSprite:create(spriteString)
	    	local secLabel = CCLabelTTF:create(v,g_sFontName,21)
	    	secLabel:setColor(ccc3(0x00,0xff,0x18))

	    	local sayNode = BaseUI.createHorizontalNode({firstLabel,itemSprite,secLabel})
	    	sayNode:setPosition(ccp(secBgSize.width*0.5,15 + 35*i))
	    	sayNode:setAnchorPoint(ccp(0.5,0))
	    	secBgSprite:addChild(sayNode)

	    	i = i + 1
	    end
	end
    --没有开启的技能才能看到
    if not isUnlock then
    	if table.isEmpty(_unLockInfo) then
    		local psString
    		if AthenaData.isSSOpen(curPage - 1) then
    			local upPageInfo = AthenaData.getTreeDBInfo(curPage - 1)
    			psString = GetLocalizeStringBy("zzh_1333",tonumber(upPageInfo.level))
    		else
    			psString = GetLocalizeStringBy("zzh_1332")
    		end

    		local exLabel = CCRenderLabel:create(psString,g_sFontName,24,1,ccc3(0x00,0x00,0x00),type_stroke)
    		exLabel:setColor(ccc3(0xff,0x00,0x00))
    		exLabel:setAnchorPoint(ccp(0.5,0))
    		exLabel:setPosition(ccp(bgSize.width*0.5,130))
    		bgSprite:addChild(exLabel)
    	else
		    for i = 1,#_unLockInfo do
		    	local curLockInfo = _unLockInfo[i]
		    	local addString
		    	if i == 1 then
		    		addString = " "
		    	else
		    		addString = GetLocalizeStringBy("zzh_1309")
		    	end
		    	local needLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2702"),g_sFontName,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		    	needLabel:setColor(ccc3(0xff,0x00,0x00))
		    	local lockSkillInfo = AthenaData.getSkillDBInfo(curLockInfo.skill)
		    	local skillNameLabel = CCRenderLabel:create(lockSkillInfo.name,g_sFontName,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		    	skillNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(lockSkillInfo.skillQuality))
		    	local otherLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1310",curLockInfo.lv) .. addString,g_sFontName,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		    	otherLabel:setColor(ccc3(0xff,0x00,0x00))

		    	local lockNode = BaseUI.createHorizontalNode({needLabel,skillNameLabel,otherLabel})
		    	lockNode:setAnchorPoint(ccp(0.5,0))
		    	lockNode:setPosition(ccp(bgSize.width*0.5,130 + 40*(i - 1)))
		    	bgSprite:addChild(lockNode)
		    end
    	end
	end
	--两个按钮
	local upGradeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("key_1450"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	upGradeMenuItem:setAnchorPoint(ccp(0.5,0))
	upGradeMenuItem:setPosition(ccp(150,45))
	upGradeMenuItem:registerScriptTapHandler(upGradeCallBack)
	bgMenu:addChild(upGradeMenuItem)

	local killMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("key_2474"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	killMenuItem:setAnchorPoint(ccp(0.5,0))
	killMenuItem:setPosition(ccp(bgSize.width - 150,45))
	killMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(killMenuItem)
end

--[[
	@des 	:入口函数
	@param  :技能id
	@param  :技能等级
	@param  :触摸优先级
	@param  :Z轴
--]]
function showLayer(p_itemId,p_itemLv,p_touchPriority,p_zOrder,p_doneCb)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	_itemId = tonumber(p_itemId)
	_itemLv = tonumber(p_itemLv)
    _doneCb = p_doneCb
	_costInfo = AthenaData.getCostItemInfo(_itemId,AthenaData.getCurPageNo())
	_atrrInfo = AthenaData.getAtrrInfo(_itemId,_itemLv)
	_unLockInfo = AthenaData.getUnlockSkillInfo(_itemId)
  
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    createUI()
end