-- FileName: KuafuMatchLayer.lua 
-- Author: yangrui
-- Date: 15-09-28
-- Purpose: 跨服比武 比武

module("KuafuMatchLayer", package.seeall)
require "script/ui/title/TitleUtil"

local _bgLayer                    = nil
local _layerSize                  = nil
local _proressBg                  = nil
local _progressBar                = nil  -- 胜场进度条
local _proressFrame               = nil  -- 胜场奖励框
local _progressBarWidth           = nil  -- 胜场进度条宽度
local _menuChestBar               = nil  -- 奖励宝箱
local _titleBg                    = nil  -- 挑战次数Label
local _totayWinTimesLabel         = nil  -- 今日胜利次数
local _richTextLayer              = nil  -- 狂怒说明Label
local _fireEffectSp               = nil  -- 火特效
local _refreshAtkNumFunc          = nil  -- 刷新挑战次数
local _menuRefreshBar             = nil  -- 刷新按钮文字
local _totayFreeRefreshTimesLabel = nil  -- 今日剩余刷新次数
local _furyMenuItem               = nil  -- 狂怒按钮
local _star                       = nil  -- 小星星

-- 比武玩家坐标
local battlePlayerPosX = {0.2,0.5,0.8}
local battlePlayerPosY = {0.45,0.58,0.45}
-- 宝箱的坐标
local chestPosX = {0.18,0.38,0.62,0.82}

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer                    = nil
	_layerSize                  = nil
	_proressBg                  = nil
	_progressBar                = nil  -- 胜场进度条
	_proressFrame               = nil  -- 胜场奖励框
	_progressBarWidth           = nil  -- 胜场进度条宽度
	_menuChestBar               = nil  -- 奖励宝箱
	_titleBg                    = nil  -- 挑战次数Label
	_totayWinTimesLabel         = nil  -- 今日胜利次数
	_richTextLayer              = nil  -- 狂怒说明Label
	_fireEffectSp               = nil  -- 火特效
	_refreshAtkNumFunc          = nil  -- 刷新挑战次数
	_menuRefreshBar             = nil  -- 刷新按钮文字
	_totayFreeRefreshTimesLabel = nil  -- 今日剩余刷新次数
	_furyMenuItem               = nil  -- 狂怒按钮
	_star                       = nil  -- 小星星
end

--[[
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( pEvent )
    if pEvent == "enter" then
    elseif pEvent == "exit" then
       _bgLayer = nil
    end
end

--[[
	@des    : touch事件处理
	@para   : 
	@return : 
--]]
local function countDownLayerTouch( eventType, x, y )
    return true
end

--[[
	@des    : 创建胜场奖励宝箱
	@para   : 
	@return : 
--]]
function createChestBtn( type_str, state, score )
	local menuItem = CCMenuItemImage:create("images/kfbw/" .. type_str .. "_" .. state .. "_n.png","images/kfbw/" .. type_str .. "_" .. state .. "_h.png")

	if tonumber(state) == 2 then
		if("wood" == type_str)then
			-- 木宝箱
			local spellEffectSp = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/woodBox/mubaoxiang"),-1,CCString:create(""));
			spellEffectSp:retain()
			spellEffectSp:setPosition(menuItem:getContentSize().width*0.5+3,menuItem:getContentSize().height*0.5-2)
			menuItem:addChild(spellEffectSp)
			spellEffectSp:release()
		elseif("copper" == type_str)then
			-- 铜宝箱
			local spellEffectSp = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/copperBox/tongxiangzi"),-1,CCString:create(""));
		    spellEffectSp:retain()
		    spellEffectSp:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSp)
		    spellEffectSp:release()
		elseif("silver" == type_str)then
			-- 银宝箱
			local spellEffectSp = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/silverBox/yinxiangzi"),-1,CCString:create(""));
		    spellEffectSp:retain()
		    spellEffectSp:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSp)
		    spellEffectSp:release()
		elseif("gold" == type_str)then
			-- 金宝箱
			local spellEffectSp = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/goldBox/jinxiangzi"),-1,CCString:create(""));
		    spellEffectSp:retain()
		    spellEffectSp:setPosition(menuItem:getContentSize().width*0.5+3,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSp)
		    spellEffectSp:release()
		end
	end
	-- 所需胜场数文本
	local text = tonumber(score) .. GetLocalizeStringBy("key_10333")
	local winTimesSp = CCRenderLabel:create(text,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	winTimesSp:setColor(ccc3(0xff,0xfc,0x00))
	winTimesSp:setAnchorPoint(ccp(0,0))
	local posX = (menuItem:getContentSize().width-winTimesSp:getContentSize().width)*0.5
	winTimesSp:setPosition(ccp(posX,0))
	menuItem:addChild(winTimesSp)

	return menuItem
end

--[[
	@des    : 刷新宝箱状态
	@para   : 
	@return : 
--]]
function refreshChestBtn( pChestId )
	local menuItem = tolua.cast(_menuChestBar:getChildByTag(tonumber(pChestId)),"CCMenuItemImage")
	if menuItem ~= nil then
		menuItem:removeFromParentAndCleanup(true)
		menuItem = nil
	end
	local needWinTimes = KuafuData.getNeedWinTimes(pChestId)
	local nameArr = {"wood","copper","silver","gold",}
 	local chestState,chestNeedWinTimes = KuafuData.getChestStateInfoById(pChestId)
	local chestBtn = createChestBtn(nameArr[tonumber(pChestId)],chestState,chestNeedWinTimes)
 	chestBtn:setAnchorPoint(ccp(0.5,0))
 	chestBtn:setPosition(ccp(_proressFrame:getContentSize().width*chestPosX[pChestId],15))
 	_menuChestBar:addChild(chestBtn,1,tonumber(pChestId))
 	chestBtn:registerScriptTapHandler(chestBtnCallFun)
end

--[[
	@des    : 宝箱的回调
	@para   : 
	@return : 
--]]
function chestBtnCallFun( tag, itemBtn )
	require "script/ui/kfbw/ShowChestLayer"
	ShowChestLayer.showChestRewardLayer(tag,refreshChestBtn)
end

--[[
	@des    : 刷新胜场奖励进度条
	@para   : 
	@return : 
--]]
function refreshRewardProgressBar( ... )
    print("===|||refreshRewardProgressBar|||===")
    -- 已胜利场数
	local curWinTimes = KuafuData.getWinTimes()
	-- 胜场奖励档长度
	local lenArr = {}
	-- 需要胜场数
	local needWinTimesArr = {}
	for i=1,4 do
		if i == 1 then
			table.insert(lenArr,KuafuData.getNeedWinTimes(i))
		else
			table.insert(lenArr,KuafuData.getNeedWinTimes(i)-KuafuData.getNeedWinTimes(i-1))
		end
		table.insert(needWinTimesArr,KuafuData.getNeedWinTimes(i))
	end
	-- 计算处于第几档
	local curStand = 0
	for index,len in pairs(needWinTimesArr) do
		if curWinTimes <= needWinTimesArr[index] then
			curStand = index
			break
		end
		curStand = index
	end
	-- 计算进度条进度
	local width = 0
	if curStand ~= 0 then
		if curStand == 1 then
			width = math.floor(((curWinTimes)/lenArr[curStand])*0.25*curStand*_progressBarWidth)
		else
		    width = math.floor(((curWinTimes-needWinTimesArr[curStand-1])/lenArr[curStand])*0.25*_progressBarWidth+0.25*(curStand-1)*_progressBarWidth)
		end
	end
    if width > _progressBarWidth then
        width = _progressBarWidth
    end
    -- 更新进度条
    _progressBar:setTextureRect(CCRectMake(0,0,width,_progressBar:getContentSize().height))
    -- 小星星
    if width <= _progressBarWidth then
    	_star:setPosition(ccp(width,_progressBar:getContentSize().height*0.5))
	end
	local str = GetLocalizeStringBy("yr_2024",KuafuData.getWinTimes())
	_totayWinTimesLabel:setString(str)
end

--[[
	@des    : 创建胜场奖励进度条
	@para   : 
	@return : 
--]]
function createRewardProgressBar( ... )
	-- 进度条背景
	if _proressBg ~= nil then
		_proressBg:removeFromParentAndCleanup(true)
		_proressBg = nil
	end
	_proressBg = CCSprite:create("images/everyday/progress3.png")
	_proressBg:setAnchorPoint(ccp(0.5,0.5))
	_proressBg:setPosition(ccp(_layerSize.width*0.5,_layerSize.height*0.88))
	_proressBg:setScale(MainScene.elementScale)
	_bgLayer:addChild(_proressBg)
	-- 进度条
	_progressBar = CCSprite:create("images/everyday/progress2.png")
    _progressBar:setAnchorPoint(ccp(0,0))
    _progressBar:setPosition(45,12)
    _proressBg:addChild(_progressBar)
    _progressBarWidth = _progressBar:getContentSize().width
	-- 进度条框
	_proressFrame = CCSprite:create("images/everyday/progress1.png")
	_proressFrame:setAnchorPoint(ccp(0.5,0))
	_proressFrame:setPosition(ccp(_proressBg:getContentSize().width*0.5,4))
	_proressBg:addChild(_proressFrame,3)
 	-- 今日胜利次数  yr_2024
 	local winTimes = KuafuData.getWinTimes()
    local winTimesLabel = GetLocalizeStringBy("yr_2024",winTimes)
    _totayWinTimesLabel = CCRenderLabel:create(winTimesLabel,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_shadow)
    _totayWinTimesLabel:setAnchorPoint(ccp(0.5,1))
    _totayWinTimesLabel:setPosition(ccp(_proressBg:getContentSize().width*0.5,-4))
    _proressBg:addChild(_totayWinTimesLabel)
	-- 小星星
	_star = CCSprite:create("images/everyday/xing.png")
    _star:setAnchorPoint(ccp(0.5,0.5))
    _star:setPosition(ccp(0,_progressBar:getContentSize().height*0.5))
    _progressBar:addChild(_star)
	-- 刷新进度条进度
	refreshRewardProgressBar()
 	-- 奖励宝箱
 	_menuChestBar = CCMenu:create()
 	_menuChestBar:setAnchorPoint(ccp(0,0))
 	_menuChestBar:setPosition(ccp(0,0))
 	_menuChestBar:setTouchPriority(-101)
 	_proressFrame:addChild(_menuChestBar)
 	-- 木 状态 需要胜场数
 	local woodState,woodNeedWinTimes = KuafuData.getChestStateInfoById(1)
 	local woodChestBtn = createChestBtn("wood",woodState,woodNeedWinTimes)
 	woodChestBtn:setAnchorPoint(ccp(0.5,0))
 	woodChestBtn:setPosition(ccp(_proressFrame:getContentSize().width*chestPosX[1],15))
 	_menuChestBar:addChild(woodChestBtn,1,1)
 	woodChestBtn:registerScriptTapHandler(chestBtnCallFun)
 	-- 铜 状态 需要胜场数
 	local copperState,copperNeedWinTimes = KuafuData.getChestStateInfoById(2)
 	local copperChestBtn = createChestBtn("copper",copperState,copperNeedWinTimes)
 	copperChestBtn:setAnchorPoint(ccp(0.5,0))
 	copperChestBtn:setPosition(ccp(_proressFrame:getContentSize().width*chestPosX[2],15))
 	_menuChestBar:addChild(copperChestBtn,1,2)
 	copperChestBtn:registerScriptTapHandler(chestBtnCallFun)
 	-- 银 状态 需要胜场数
 	local silverState,silverNeedWinTimes = KuafuData.getChestStateInfoById(3)
 	local silverChestBtn = createChestBtn("silver",silverState,silverNeedWinTimes)
 	silverChestBtn:setAnchorPoint(ccp(0.5,0))
 	silverChestBtn:setPosition(ccp(_proressFrame:getContentSize().width*chestPosX[3],15))
 	_menuChestBar:addChild(silverChestBtn,1,3)
 	silverChestBtn:registerScriptTapHandler(chestBtnCallFun)
 	-- 金 状态 需要胜场数
 	local goldState,goldNeedWinTimes = KuafuData.getChestStateInfoById(4)
 	local goldChestBtn = createChestBtn("gold",goldState,goldNeedWinTimes)
 	goldChestBtn:setAnchorPoint(ccp(0.5,0))
 	goldChestBtn:setPosition(ccp(_proressFrame:getContentSize().width*chestPosX[4],15))
 	_menuChestBar:addChild(goldChestBtn,1,4)
 	goldChestBtn:registerScriptTapHandler(chestBtnCallFun)
end

--[[
	@des    : 战斗回调
	@para   : 
	@return : 
--]]
function battleFunc( pData, itemBtn )
    -- audio effect
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 剩余挑战次数
    local leftTimes = KuafuData.getFreeChallengeTimes()+KuafuData.getBuyAtkNum()-KuafuData.getAtkTimes()
	-- 通过Htid获取玩家信息
	local enemyData = KuafuData.getEnemyDataByHeroPidAndServerId(pData.pid,pData.server_id)
	-- serverId
	local serverId = tonumber(enemyData.server_id)
	-- pid
	local pid = tonumber(enemyData.pid)
	if tonumber(enemyData.status) == 1 then
	    AnimationTip.showTip(GetLocalizeStringBy("yr_2011"))
	elseif ( leftTimes > 0 ) then
		-- 判断是否开启了狂怒模式
		if KuafuData.getFury() then
			-- 开启
			print("狂怒模式战斗")
			-- 战斗结束后 狂怒模式消失
			KuafuData.setFury(false)
			PreRequest.setIsCanShowAchieveTip(false)
		    -- 限制不能连发两次请求
		    itemBtn:setEnabled(false)

			KuafuController.attack(serverId, pid, 1, 0, enemyData, itemBtn)
		else
			-- 未开启
			print("战斗")
    		PreRequest.setIsCanShowAchieveTip(false)
		    -- 限制不能连发两次请求
		    itemBtn:setEnabled(false)

			KuafuController.attack(serverId, pid, 0, 0, enemyData, itemBtn)
		end
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_1005"))
	end
end

--[[
	@des    : 创建玩家
	@para   : 
	-- pDes        : 获得比武荣誉描述
	-- pColor      : 根据积分给出颜色
	-- pCradIcon   : 卡牌
	-- pData       : 对手信息
	@return : 
--]]
function createMatchPlayerInfo( pDes, pColor, pCradIcon_n, pCradIcon_h, pData)
	-- 对手是否被击败状态
	local state = tonumber(pData.status)
	print("===|state|===",state,type(state))
	local playerNode = CCNode:create()
	playerNode:setContentSize(CCSizeMake(168,318))
	print("可获得荣誉Label")
    -- 玩家卡牌按钮
    local playerCardMenuBar = CCMenu:create()
    playerCardMenuBar:setPosition(ccp(0,0))
    playerNode:addChild(playerCardMenuBar,2)
    local normalSprite = nil
    local selectSprite = nil
    -- 称号
    local titleSp = nil
    local titleId = tonumber(pData.title)
    if state ~= 1 then  -- 未被击败
	    -- 未被击败才显示荣誉    可获得荣誉Label
		local getHonorLabel = CCRenderLabel:create(pDes,g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_shadow)
	    getHonorLabel:setColor(pColor)
	    getHonorLabel:setAnchorPoint(ccp(0.5,1))
	    getHonorLabel:setPosition(ccp(playerNode:getContentSize().width*0.5,80))
	    playerNode:addChild(getHonorLabel,3)
	    normalSprite = CCSprite:create("images/match/card_bg.png")
	    selectSprite = CCSprite:create("images/match/card_bg.png")
	    titleSp = TitleUtil.createTitleNormalSpriteById(titleId)
	else  -- 被击败
		normalSprite = BTGraySprite:create("images/match/card_bg.png")
		selectSprite = BTGraySprite:create("images/match/card_bg.png")
		pCradIcon_n:setColor(ccc3(0x33,0x33,0x33))
		pCradIcon_h:setColor(ccc3(0x33,0x33,0x33))
	    -- 已击败Label
		local failLabel_n = CCSprite:create("images/kfbw/fail.png")
		failLabel_n:setAnchorPoint(ccp(0.5,0))
		failLabel_n:setPosition(ccp(normalSprite:getContentSize().width*0.5,70))
		local failLabel_h = CCSprite:create("images/kfbw/fail.png")
		failLabel_h:setAnchorPoint(ccp(0.5,0))
		failLabel_h:setPosition(ccp(normalSprite:getContentSize().width*0.5,70))
		failLabel_h:setScale(0.8)
		normalSprite:addChild(failLabel_n,1)
		selectSprite:addChild(failLabel_h,1)
	    titleSp = TitleUtil.createTitleGraySpriteById(titleId)
	end
	pCradIcon_n:setAnchorPoint(ccp(0.5,0))
	pCradIcon_n:setPosition(ccp(normalSprite:getContentSize().width*0.5,37))
	normalSprite:addChild(pCradIcon_n)
	pCradIcon_h:setAnchorPoint(ccp(0.5,0))
    pCradIcon_h:setPosition(ccp(selectSprite:getContentSize().width*0.5,37))
    selectSprite:addChild(pCradIcon_h)
    selectSprite:setScale(0.8)
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    item:setAnchorPoint(ccp(0.5,1))
    item:setPosition(ccp(playerNode:getContentSize().width*0.5,playerNode:getContentSize().height-95))
    playerCardMenuBar:addChild(item,1)
    item:registerScriptTapHandler(function( ... )
    	battleFunc(pData, item)
    end)
	-- 称号
	if(titleId ~= nil and titleId > 0 and titleSp ~= nil) then
	    titleSp:setAnchorPoint(ccp(0.5,0.5))
	    titleSp:setPosition(ccp(playerNode:getContentSize().width*0.5,playerNode:getContentSize().height - 78))
		playerNode:addChild(titleSp,4)
	end
    -- 坐标
    normalSprite:setAnchorPoint(ccp(0.5, 0.5))
    selectSprite:setAnchorPoint(ccp(0.5, 0.5))
    normalSprite:setPosition(ccpsprite(0.5, 0.5, item))
    selectSprite:setPosition(ccpsprite(0.5, 0.5, item))
	print("玩家名字")
    -- 玩家名字
    local userName = CCRenderLabel:create(pData.uname,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
    userName:setColor(pColor)
    userName:setAnchorPoint(ccp(0.5,1))
    userName:setPosition(ccp(playerNode:getContentSize().width*0.5,50))
    playerNode:addChild(userName,2)
    -- 战斗力icon
    local forceIcon = CCSprite:create("images/lord_war/fight_bg.png")
    forceIcon:setAnchorPoint(ccp(0.5,1))
    forceIcon:setPosition(ccp(playerNode:getContentSize().width*0.5,30))
    playerNode:addChild(forceIcon,2)
	print("战斗力数值")
    -- 战斗力数值
    local forceFont = CCRenderLabel:create(pData.fight_force,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
    forceFont:setColor(ccc3(0xff,0x00,0x00))
    forceFont:setAnchorPoint(ccp(0,0.5))
    forceFont:setPosition(ccp(35,forceIcon:getContentSize().height*0.5))
    forceIcon:addChild(forceFont)
	print("显示服务器名字")
    -- 显示服务器名字
    local serverNameFont = CCRenderLabel:create("『" .. pData.server_name .. "』",g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
    serverNameFont:setColor(ccc3(0xff,0xff,0xff))
    serverNameFont:setAnchorPoint(ccp(0.5,1))
    serverNameFont:setPosition(ccp(playerNode:getContentSize().width*0.5,-5))
    playerNode:addChild(serverNameFont,2)

	return playerNode
end

--[[
	@des    : 创建三位玩家
	@para   : 
	@return : 
--]]
function createBattlePlayer( ... )
	-- 得到对手信息
	local userInfo = KuafuData.getEnemyData()
	-- 创建
	for k,enemyInfo in pairs(userInfo) do
		local desc,font_color = KuafuData.getHonorAndFontColor(enemyInfo.fight_force,enemyInfo.htid)
		require "script/battle/BattleCardUtil"
        local dressId = nil
        if enemyInfo.dress then
            if ( not table.isEmpty(enemyInfo.dress) and (enemyInfo.dress["1"]) ~= nil and tonumber(enemyInfo.dress["1"]) > 0 ) then
                dressId = enemyInfo.dress["1"]
            end
        end
	    local sprite1 = BattleCardUtil.getFormationPlayerCard(111111111,nil,enemyInfo.htid,dressId)
	    local sprite2 = BattleCardUtil.getFormationPlayerCard(111111111,nil,enemyInfo.htid,dressId)
	    local icon = createMatchPlayerInfo(desc,font_color,sprite1,sprite2,enemyInfo)
	    icon:setAnchorPoint(ccp(0.5,0.5))
	    icon:setPosition(ccp(_layerSize.width*battlePlayerPosX[k],_layerSize.height*battlePlayerPosY[k]))
        icon:setScale(MainScene.elementScale)
	    _bgLayer:addChild(icon,1,100+k)
	end
end

--[[
	@des    : 判断金币是否满足
	@para   : 
	@return : 
--]]
function judgeGold( pGoldCost )
	local goldCost = tonumber(pGoldCost)
    require "script/model/user/UserModel"
	if UserModel.getGoldNumber() < goldCost then
		require "script/ui/tip/LackGoldTip"
    	LackGoldTip.showTip()
    	return
    end
end

--[[
	@des    : 购买挑战次数回调
	@para   : 
	@return : 
--]]
function buyBattleTimesFunc( ... )
    -- audio effect
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 最大购买次数
	local maxBuyNum = KuafuData.getBuyChallengeTimesLimit()
	-- 已购买的次数
	local haveBuyNum = KuafuData.getBuyAtkNum()
	if maxBuyNum-haveBuyNum > 0 then
	    -- show购买面板
	    require "script/ui/kfbw/BuyBattleTimes"
	    BuyBattleTimes.showBatchBuyLayer()
	else
		AnimationTip.showTip(GetLocalizeStringBy("yr_2026"))
	end
end

--[[
	@des    : 刷新挑战次数
	@para   : 
	@return : 
--]]
function refreshAtkNumFunc( ... )
	if _battleTimesLabel ~= nil then
	local leftTimes = KuafuData.getFreeChallengeTimes()+KuafuData.getBuyAtkNum()-KuafuData.getAtkTimes()
	local freeTimes = KuafuData.getFreeChallengeTimes()
		_battleTimesLabel:setString(leftTimes .. "/" .. freeTimes)
	end
end

--[[
	@des    : 创建挑战次数
	@para   : 
	@return : 
--]]
function createBattleTimesLabel( ... )
	-- titleBg
	_titleBg = CCScale9Sprite:create("images/common/purple.png")
	_titleBg:setContentSize(CCSizeMake(290,45))
	_titleBg:setAnchorPoint(ccp(0.5,0))
	_titleBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,20*g_fScaleX))
	_titleBg:setScale(MainScene.elementScale)
	_bgLayer:addChild(_titleBg)
	-- title
	local battleTimesTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3399"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	battleTimesTipLabel:setAnchorPoint(ccp(0,0.5))
	battleTimesTipLabel:setPosition(ccp(20*g_fScaleX,_titleBg:getContentSize().height*0.5))
	_titleBg:addChild(battleTimesTipLabel)
	-- times
	local leftTimes = KuafuData.getFreeChallengeTimes()+KuafuData.getBuyAtkNum()-KuafuData.getAtkTimes()
	local freeTimes = KuafuData.getFreeChallengeTimes()
	_battleTimesLabel = CCRenderLabel:create(leftTimes .. "/" .. freeTimes,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	_battleTimesLabel:setColor(ccc3(0xff,0x00,0x00))
	_battleTimesLabel:setAnchorPoint(ccp(0,0.5))
	_battleTimesLabel:setPosition(ccp(battleTimesTipLabel:getPositionX()+battleTimesTipLabel:getContentSize().width,_titleBg:getContentSize().height*0.5))
	_titleBg:addChild(_battleTimesLabel)
	-- add times btn
	local menuBattleTimesBar = CCMenu:create()
    menuBattleTimesBar:setPosition(ccp(0,0))
    _titleBg:addChild(menuBattleTimesBar)
	menuBattleTimesBar:setTouchPriority(-402)
    local addBattleTimesBtn = CCMenuItemImage:create("images/common/btn/btn_plus_h.png","images/common/btn/btn_plus_n.png")
    addBattleTimesBtn:setAnchorPoint(ccp(0,0.5))
    addBattleTimesBtn:setPosition(ccp(_battleTimesLabel:getPositionX()+_battleTimesLabel:getContentSize().width+10,_titleBg:getContentSize().height*0.5))
    addBattleTimesBtn:registerScriptTapHandler(buyBattleTimesFunc)
    menuBattleTimesBar:addChild(addBattleTimesBtn)
end

--[[
	@des    : 刷新对手
	@para   : 
	@return : 
--]]
function refreshBattlePlayer( ... )
	-- 移除之前的对手
    _bgLayer:removeChildByTag(101,true)
    _bgLayer:removeChildByTag(102,true)
    _bgLayer:removeChildByTag(103,true)
    -- 重新创建
    createBattlePlayer()
end

--[[
	@des    : 刷新对手按钮回调
	@para   : 
	@return : 
--]]
function refreshBtnFunc( ... )
    -- 音效
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 判断是否有免费刷新次数
    local leftRefreshTimes = KuafuData.getFreeRefreshTimes()-KuafuData.getRefreshTimes()
    if leftRefreshTimes > 0 then
    	print("===|免费刷新|===")
    	_totayFreeRefreshTimesLabel:setString(GetLocalizeStringBy("yr_2025",leftRefreshTimes-1))
		-- 网络请求
		KuafuController.refreshRival()
    else
    	print("===|金币刷新|===")
		-- 判断金币是否满足
		local goldCost = KuafuData.getRefreshCost()
		require "script/model/user/UserModel"
		if UserModel.getGoldNumber() < goldCost then
			AnimationTip.showTip(GetLocalizeStringBy("key_3245"))
	    	return
    	end
		-- 弹出提示是否消费面板
		require "script/ui/kfbw/AlertConsumeLayer"
		AlertConsumeLayer.showAlertLayer()
	end
end

--[[
	@des    : 创建刷新按钮文字
	@para   : 
	@return : 
--]]
function createRefreshBtnFont( ... )
	print("===创建刷新按钮文字")
	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(200,70))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(200,70))
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
    disabledSprite:setContentSize(CCSizeMake(200,70))
    local refreshMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    refreshMenuItem:setAnchorPoint(ccp(0.5,0))
    refreshMenuItem:setScale(MainScene.elementScale)
    refreshMenuItem:setPosition(ccp(_layerSize.width*0.5,_titleBg:getPositionY()+(_titleBg:getContentSize().height+50)*g_fScaleY))
    refreshMenuItem:setScale(MainScene.elementScale)
    _menuRefreshBar:addChild(refreshMenuItem)
    -- create refresh font
 	local freeRefreshTimes = 0
    local leftRefreshTimes = KuafuData.getFreeRefreshTimes()-KuafuData.getRefreshTimes()
    local richInfo = {
        width = refreshMenuItem:getContentSize().width, -- 宽度
        linespace = 2,  -- 行间距
        alignment = 2,  -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2,  -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,  -- 默认字体
        labelDefaultColor = ccc3(0xff,0xff,0xff),  -- 默认字体颜色
        labelDefaultSize = 35,  -- 默认字体大小
        defaultType = "CCRenderLabel",
        defaultRenderType = 1,
        defaultStrokeSize = 1,
        defaultStrokeColor = ccc3(0x00,0x00,0x00),
    }
    -- 判断免费刷新次数是否用完
    if leftRefreshTimes > 0 then
    	freeRefreshTimes = leftRefreshTimes
    	richInfo.elements = {
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = GetLocalizeStringBy("yr_2017"),
                color = ccc3(0xff,0xf6,0x00),
                strokeSize = 1,
                strokeColor = ccc3(0x0,0x0,0x0),
                strokeRgb = 0x000000,
                renderType = 1,  -- 1 描边  2 投影
            },
    	}
	else
		local price = KuafuData.getRefreshCost()
		richInfo.elements = {
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = GetLocalizeStringBy("key_1002"),
                color = ccc3(0xff,0xf6,0x00),
                strokeSize = 1,
                strokeColor = ccc3(0x0,0x0,0x0),
                strokeRgb = 0x000000,
                renderType = 1,  -- 1 描边  2 投影
            },
            {
                type = "CCSprite",
                newLine = false,
                image = "images/common/gold.png",
            },
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = price,
                size = 25,
                color = ccc3(0xff,0xf6,0x00),
                strokeSize = 1,
                strokeColor = ccc3(0x0,0x0,0x0),
                strokeRgb = 0x000000,
                renderType = 1,  -- 1 描边  2 投影
            },
        }
	end
    local refreshFont = LuaCCLabel.createRichLabel(richInfo)
    refreshFont:setAnchorPoint(ccp(0.5,0.5))
    refreshFont:setPosition(ccp(refreshMenuItem:getContentSize().width*0.5,refreshMenuItem:getContentSize().height*0.5+2))
    refreshMenuItem:addChild(refreshFont)
    refreshMenuItem:registerScriptTapHandler(refreshBtnFunc)
    -- 今日免费刷新次数 yr_2025
	local freeRefreshTimesLabel = GetLocalizeStringBy("yr_2025",freeRefreshTimes)
	if _totayFreeRefreshTimesLabel ~= nil then
		_totayFreeRefreshTimesLabel:removeFromParentAndCleanup(true)
		_totayFreeRefreshTimesLabel= nil
	end
	_totayFreeRefreshTimesLabel = CCRenderLabel:create(freeRefreshTimesLabel,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_shadow)
    _totayFreeRefreshTimesLabel:setAnchorPoint(ccp(0.5,0))
    _totayFreeRefreshTimesLabel:setPosition(ccp(refreshMenuItem:getContentSize().width*0.5,-refreshMenuItem:getContentSize().height*0.5))
    refreshMenuItem:addChild(_totayFreeRefreshTimesLabel)
end

--[[
	@des    : 创建刷新按钮
	@para   : 
	@return : 
--]]
function createRefreshBtn( ... )
	_menuRefreshBar = CCMenu:create()
    _menuRefreshBar:setPosition(ccp(0,0))
    _bgLayer:addChild(_menuRefreshBar)
	_menuRefreshBar:setTouchPriority(-401)
	createRefreshBtnFont()
end

--[[
	@des    : 创建狂怒Label
	@para   : 
	@return : 
--]]
function createFuryLabel( ... )
	require "script/libs/LuaCCLabel"
    local richInfo = {
            linespace = 2, -- 行间距
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
            labelDefaultFont = g_sFontPangWa,
            labelDefaultColor = ccc3(0xff, 0xff, 0xff),
            labelDefaultSize = 21,
            defaultType = "CCRenderLabel",
            elements =
            {
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_2003"),
                    color = ccc3(0xff, 0x00, 0x00),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_2004"),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_2005"),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = KuafuData.getFuryCostChallengeTimes(),
                    color = ccc3(0x00, 0xf6, 0xff),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_2006"),
                    renderType = 2,-- 1 描边， 2 投影
                },
            }
        }
    _richTextLayer = LuaCCLabel.createRichLabel(richInfo)
    _richTextLayer:setAnchorPoint(ccp(0.5,1))
    _richTextLayer:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_proressBg:getPositionY()-_proressBg:getContentSize().height*1.3*g_fScaleY))
    _richTextLayer:setScale(MainScene.elementScale)
    _bgLayer:addChild(_richTextLayer)
end

--[[
	@des    : 创建狂怒火特效
	@para   : 
	@return : 
--]]
function createFuryFireEffect( ... )
	local spWidth = g_winSize.width/g_fScaleY
	local spHeight = g_winSize.height/g_fScaleX
	_fireEffectSp = CCScale9Sprite:create()
	_fireEffectSp:setPreferredSize(CCSizeMake(spWidth, spHeight))
	_fireEffectSp:setAnchorPoint(ccp(0.5,0.5))
	_fireEffectSp:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	_bgLayer:addChild(_fireEffectSp,-1)
	-- 左边特效
	print("===|左边特效|===")
	local effectLeft = XMLSprite:create("images/kfbw/kuafubiwubian/kuafubiwubian")
	effectLeft:setPosition(ccp(_fireEffectSp:getContentSize().width*0.5,_fireEffectSp:getContentSize().height*0.5))
	_fireEffectSp:addChild(effectLeft)
	-- 右边特效
	print("===|右边特效|===")
	local effectRight = XMLSprite:create("images/kfbw/kuafubiwubian/kuafubiwubian")
	effectRight:setRotation(180)
	effectRight:setPosition(ccp(_fireEffectSp:getContentSize().width*0.5,_fireEffectSp:getContentSize().height*0.5))
	_fireEffectSp:addChild(effectRight)
	-- 下方特效
	print("===|火烧特效|===")
	local effectDown = XMLSprite:create("images/kfbw/kuafubiwuhuo/kuafubiwuhuo")
	effectDown:setPosition(ccp(_fireEffectSp:getContentSize().width*0.5,_fireEffectSp:getContentSize().height*0.5))
	_fireEffectSp:addChild(effectDown)
	-- 适配
	if g_fScaleX >= g_fScaleY then
		_fireEffectSp:setScale(g_fScaleX)
		effectDown:setPosition(ccp(_fireEffectSp:getContentSize().width*0.5,_fireEffectSp:getContentSize().height*0.5+(960-spHeight)*0.5*g_fScaleY/g_fScaleX))
	else
		_fireEffectSp:setScale(g_fScaleY)
		effectLeft:setPosition(ccp(_fireEffectSp:getContentSize().width*0.5+(640-spWidth)*0.5*g_fScaleX/g_fScaleY,_fireEffectSp:getContentSize().height*0.5))
		effectRight:setPosition(ccp(_fireEffectSp:getContentSize().width*0.5-(640-spWidth)*0.5*g_fScaleX/g_fScaleY,_fireEffectSp:getContentSize().height*0.5))
	end
end

--[[
	@des    : 刷新狂怒模式
	@para   : 
	@return : 
--]]
function refreshFuryModelAffterBattle( ... )
	local isFury = KuafuData.getFury()
	if not isFury then
		_richTextLayer:setVisible(false)
		_fireEffectSp:setVisible(false)
		-- 重置狂怒按钮状态
		_furyMenuItem:setSelectedIndex(0)
	end
end

--[[
	@des    : 狂怒按钮回调
	@para   : 
	@return : 
--]]
function furyModelFunc( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 判断挑战次数是否满足
    local leftTimes = KuafuData.getFreeChallengeTimes()+KuafuData.getBuyAtkNum()-KuafuData.getAtkTimes()
    if leftTimes < KuafuData.getFuryCostChallengeTimes() then
    	_furyMenuItem:setSelectedIndex(0)
    	AnimationTip.showTip(GetLocalizeStringBy("key_10073"))
    	return
    end
	local isFury = KuafuData.getFury()
	print("===|isFury|===",isFury)
	if not isFury then
		_richTextLayer:setVisible(true)
		_fireEffectSp:setVisible(true)
		-- 更改狂怒状态
		KuafuData.setFury(true)
	else
		_richTextLayer:setVisible(false)
		_fireEffectSp:setVisible(false)
		-- 更改狂怒状态
		KuafuData.setFury(false)
	end
end

--[[
	@des    : 创建狂怒按钮
	@para   : 
	@return : 
--]]
function createFuryModelBtn( ... )
	local isFury = KuafuData.getFury()
	if isFury == nil then
		KuafuData.setFury(false)
	end
	-- 狂怒
	local menuFuryBar = CCMenu:create()
	menuFuryBar:setPosition(ccp(0,0))
	_bgLayer:addChild(menuFuryBar)
	-- fury btn
	local kuangnuBtn = CCMenuItemImage:create("images/kfbw/kuangnu_n.png", "images/kfbw/kuangnu_h.png")
    local pingxiBtn = CCMenuItemImage:create("images/kfbw/pingxi_n.png", "images/kfbw/pingxi_h.png")
    kuangnuBtn:setAnchorPoint(ccp(0.5,0.5))
    pingxiBtn:setAnchorPoint(ccp(0.5,0.5))
	_furyMenuItem = CCMenuItemToggle:create(kuangnuBtn)
	_furyMenuItem:addSubItem(pingxiBtn)
    _furyMenuItem:setAnchorPoint(ccp(0.5,0.5))
    _furyMenuItem:setPosition(ccp(_bgLayer:getContentSize().width-(_furyMenuItem:getContentSize().width+30)*g_fScaleX,100*g_fScaleX))
    _furyMenuItem:setScale(MainScene.elementScale)
    _furyMenuItem:registerScriptTapHandler(furyModelFunc)
    menuFuryBar:setTouchPriority(-410)
    menuFuryBar:addChild(_furyMenuItem)
    -- 根据狂怒状态创建狂怒Label
    if isFury == true then
    	_richTextLayer:setVisible(true)
		_fireEffectSp:setVisible(true)
    end
    print("createFuryModelBtn  end")
end

--[[
	@des    : 创建UI
	@para   : 
	@return : 
--]]
function createUI( ... )
	print("createUI")
	_layerSize = _bgLayer:getContentSize()
	-- 创建胜场奖励进度条
	print("createRewardProgressBar")
	createRewardProgressBar()
	-- 创建三位玩家
	print("createBattlePlayer")
	createBattlePlayer()
	-- 创建挑战次数
	print("createBattleTimesLabel")
	createBattleTimesLabel()
	-- 创建刷新按钮
	print("createRefreshBtn")
	createRefreshBtn()
	-- 狂怒模式提示文字Label
	createFuryLabel()
	_richTextLayer:setVisible(false)
	-- 狂怒模式火特效
	createFuryFireEffect()
	_fireEffectSp:setVisible(false)
	-- 创建狂怒按钮
	print("createFuryModelBtn")
	createFuryModelBtn()
end

--[[
	@des    : 创建比武Layer
	@para   : 
	@return : 
--]]
function createKFBWMatchLayer( pLayerSize )
	-- init
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setContentSize(pLayerSize)
	-- 创建UI
	createUI()

	return _bgLayer
end