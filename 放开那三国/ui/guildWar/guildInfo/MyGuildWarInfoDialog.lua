-- FileName: MyGuildWarInfoDialog.lua 
-- Author: bzx
-- Date: 15-1-14 
-- Purpose:  战斗信息

module("MyGuildWarInfoDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/guildWar/guildInfo/MyGuildWarInfoController"
require "script/ui/guildWar/guildInfo/MyGuildWarInfoData"
require "script/libs/LuaCCLabel"
require "script/ui/guildWar/promotion/GuildWarPromotionData"
require "script/ui/guildWar/promotion/GuildWarPromotionService"

local _layer 
local _touchPriority				-- 本层触摸优先级
local _zOrder						-- 本层Z轴
local _dialogBg 					-- 对话框背景
local _cellSize 					-- 每行的尺寸
local _tableView 					
local _menu 						-- 本层的按钮层
local _curFighterCountLabel 		-- 当前出战人数的提示
local _myFightOrderLabel 			-- 我的出战顺序
local _updateFightForceItem 		-- 更新战斗信息
local _updateFightForceCDLabel 		-- 更新战斗信息的冷却时间

--[[
	@desc: 		显示本层
	@return: 	nil
--]]
function show(p_touchPriority, p_zOrder, p_isNoRequest)
    -- 是否已经报名
    if not GuildWarMainData.isSignUp() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8490"))
        return
    end
    -- 报名是否已经过了查看战斗信息的延迟时间300秒
    if not MyGuildWarInfoData.couldLookAfterSignup() then
    	AnimationTip.showTip(GetLocalizeStringBy("key_8491"))
    	return
    end
    -- 是否已经结束
    if GuildWarPromotionData.isEnd() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8492"))
        return
    end

    local requestCallback = function ( ... )
    	-- 是否已经被淘汰
	    if GuildWarPromotionData.myGuildIsEliminated() then
	        AnimationTip.showTip(GetLocalizeStringBy("key_8493"))
	        return
	    end
	    _layer = create(p_touchPriority, p_zOrder)
		CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
	    local requestCallback2 = function ( ... )
	    	loadTitleBar()
			loadTableView()
			refershMyFightOrder()
			refreshUpdateFightForce()
			startRefreshUpdateFightForce()
			refreshFighterCount()
	    end
	    MyGuildWarInfoService.getGuildWarMemberList(requestCallback2)
    end
    if not p_isNoRequest and GuildWarPromotionData.roundIsEnd(GuildWarDef.AUDITION) then
    	GuildWarPromotionService.getGuildWarInfo(requestCallback)
	else
		requestCallback()
	end
end

function init( ... )
	_layer 						= nil
	_touchPriority 				= 0
	_zOrder 					= 0
	_dialogBg 					= nil
	_cellSize 					= nil
	_tableView 					= nil
	_menu 						= nil
	_curFighterCountLabel 		= nil
	_myFightOrderLabel 			= nil
	_updateFightForceItem		= nil
	_updateFightForceCDLabel 	= nil
end

function initData( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -200
	_zOrder = p_zOrder or 200
end

--[[
	@desc: 		创建本层
	@return:	CCLayer
--]]
function create( p_touchPriority, p_zOrder )
	init()
	initData(p_touchPriority, p_zOrder)
	local dialogInfo = {
		title = GetLocalizeStringBy("key_8494"),
		callbackClose = MyGuildWarInfoController.closeCallback,
		size = CCSizeMake(640, 900),
		priority = _touchPriority,
		swallowTouch = true,
		-- LuaCCSprite.createDialog_1(dialogInfo)执行后，dialog为对话框
		dialog = nil		
	}
	_layer = LuaCCSprite.createDialog_1(dialogInfo)
	_dialogBg = dialogInfo.dialog
	loadMenu()
	loadBottomTip()
	return _layer
end

--[[
	@desc: 	   	显示列表的标题栏
	@return:	nil
--]]
function loadTitleBar( ... )
	local titleInfo = {
		width = 576,
		colInfos = {
			{
				image = "images/guild_war/fight_info/fight_order.png",
				positionX = 70, 
				width = 130,
			},
			{
				image = "images/guild_war/fight_info/name.png",
				width = 130,
			},
			{
				image = "images/guild_war/fight_info/fight_force.png",
				width = 100,
			},
			{
				image = "images/guild_war/fight_info/level.png",
				width = 60,
			},
			{
				image = "images/guild_war/fight_info/fight_status.png",
				width = 130,
				positionX = 495,
			}
		}	
	}
	local titleBar = LuaCCSprite.createTableTitleBar(titleInfo)
	_dialogBg:addChild(titleBar, 2)
	titleBar:setAnchorPoint(ccp(0.5, 0.5))
	titleBar:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, _dialogBg:getContentSize().height - 90))
end

--[[
	@desc:		显示列表
	@return:	nil
--]]
function loadTableView( ... )
	local fullRect = CCRectMake(0, 0, 75, 75)
   	local tableViewBg = CCScale9Sprite:create(CCRectMake(30, 30, 15, 10), "images/common/bg/bg_ng_attr.png")
    _dialogBg:addChild(tableViewBg)
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, _dialogBg:getContentSize().height - 94))
    tableViewBg:setPreferredSize(CCSizeMake(565, 600))

    _cellSize = CCSizeMake(550, 58)
	local tableViewEvent = LuaEventHandler:create(function(p_functionName, p_tableView, p_index, p_cell)
		if p_functionName == "cellSize" then
			return _cellSize
		elseif p_functionName == "cellAtIndex" then
            local cell = createCell(p_index + 1)
            return cell
		elseif p_functionName == "numberOfCells" then
			local fighterInfoArray = MyGuildWarInfoData.getFighterInfoArray()
            return #fighterInfoArray
		elseif p_functionName == "cellTouched" then
		elseif p_functionName == "scroll" then
		end
	end)
	_tableView = LuaTableView:createWithHandler(tableViewEvent, CCSizeMake(550, 580))
    tableViewBg:addChild(_tableView)
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setAnchorPoint(ccp(0.5, 1))
	_tableView:setPosition(ccp(tableViewBg:getContentSize().width * 0.5, tableViewBg:getContentSize().height - 20))
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setTouchPriority(_touchPriority - 10)

end

--[[
	@desc:		创建cell
	@return:	CCTableViewCell
--]]
function createCell( p_index )
	local fighterInfoArray = MyGuildWarInfoData.getFighterInfoArray()
	local fighterInfo = fighterInfoArray[p_index]
	local cell = CCTableViewCell:create()
	cell:setContentSize(_cellSize)
	-- 分割线
	local cuttingLine = CCSprite:create("images/common/line02.png")
    cell:addChild(cuttingLine)
    cuttingLine:setAnchorPoint(ccp(0.5, 0.5))
    cuttingLine:setPosition(ccpsprite(0.5, 0, cell))
    cuttingLine:setScaleX(5)
    local fightOrder = p_index
    -- 出场顺序
    local fightOrderSprite = LuaCC.createSpriteOfNumbers("images/main/vip", tostring(p_index), 10)
    cell:addChild(fightOrderSprite)
    fightOrderSprite:setAnchorPoint(ccp(0.5, 0.5))
    fightOrderSprite:setPosition(ccpsprite(0.03, 0.5, cell))
    -- 人物头像
    fighterInfo.dress = fighterInfo.dress or {}
    local heroIcon = HeroUtil.getHeroIconByHTID(tonumber(fighterInfo.htid), tonumber(fighterInfo.dress[1], nil, tonumber(fighterInfo.vip)))
    cell:addChild(heroIcon)
    heroIcon:setAnchorPoint(ccp(0.5, 0.5))
    heroIcon:setPosition(ccpsprite(0.12, 0.5, cell))
    heroIcon:setScale(0.5)
  	--人物名字
  	local heroNameLabel = CCRenderLabel:create(fighterInfo.uname, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
  	cell:addChild(heroNameLabel)
  	heroNameLabel:setAnchorPoint(ccp(0.5, 0.5))
  	heroNameLabel:setPosition(ccpsprite(0.33, 0.5, cell))
  	heroNameLabel:setColor(ccc3(0x00, 0xff, 0x18))
  	-- 战斗力
  	local fightForceLabel = CCRenderLabel:create(fighterInfo.fight_force, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
  	cell:addChild(fightForceLabel)
  	fightForceLabel:setAnchorPoint(ccp(0.5, 0.5))
  	fightForceLabel:setPosition(ccpsprite(0.54, 0.5, cell))
  	fightForceLabel:setColor(ccc3(0xff, 0xf6, 0x00))
  	-- 人物等级
  	local heroLevel = LuaCC.createSpriteOfNumbers("images/battle/anger", fighterInfo.level, 10)
  	cell:addChild(heroLevel)
  	heroLevel:setAnchorPoint(ccp(0.5, 0.5))
  	heroLevel:setPosition(ccpsprite(0.68, 0.5, cell))
 	
 	local menu = BTSensitiveMenu:create()
 	cell:addChild(menu)
 	menu:setPosition(ccp(0, 0))
 	menu:setContentSize(_cellSize)
 	menu:setTouchPriority(_touchPriority - 5)
  	-- 出战状态
  	-- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
  	local isLeader = GuildDataCache.getMineMemberType() == 1
  	local enterFightMaxCount = MyGuildWarInfoData.getEnterFightMaxCount()
  	local enterFightCount = MyGuildWarInfoData.getEnterFighterCount()
  	if enterFightCount < enterFightMaxCount and fighterInfo.state == "0" and isLeader then
  		local enterItem = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png","images/common/btn/green01_h.png", CCSizeMake(130, 64), GetLocalizeStringBy("key_8495"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
  		menu:addChild(enterItem)
  		enterItem:setTag(fightOrder)
  		enterItem:setAnchorPoint(ccp(0.5, 0.5))
  		enterItem:setPosition(ccpsprite(0.89, 0.5, menu))
  		enterItem:registerScriptTapHandler(MyGuildWarInfoController.enterCallback)
  	elseif fighterInfo.state == "1" and not MyGuildWarInfoData.isMustEnterFight(fighterInfo.uid) and isLeader then
  		local outItem = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png","images/common/btn/purple01_h.png", CCSizeMake(130, 64), GetLocalizeStringBy("key_8496"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
  		menu:addChild(outItem)
  		outItem:setTag(fightOrder)
  		outItem:setAnchorPoint(ccp(0.5, 0.5))
  		outItem:setPosition(ccpsprite(0.89, 0.5, menu))
  		outItem:registerScriptTapHandler(MyGuildWarInfoController.outCallback)
  	elseif fighterInfo.state == "1" then
  		local enterTagSprite = CCSprite:create("images/guild_war/fight_info/in_fight.png")
  		cell:addChild(enterTagSprite)
  		enterTagSprite:setAnchorPoint(ccp(0.5, 0.5))
  		enterTagSprite:setPosition(ccpsprite(0.86, 0.5, cell))
  	elseif fighterInfo.state == "0" then
  		local outTagSprite = CCSprite:create("images/guild_war/fight_info/out_fight.png")
  		cell:addChild(outTagSprite)
  		outTagSprite:setAnchorPoint(ccp(0.5, 0.5))
  		outTagSprite:setPosition(ccpsprite(0.86, 0.5, cell))
  	end

	return cell
end

--[[
	@desc:			显示我的示出战顺序
	@return:		nil
--]]
function refershMyFightOrder( ... )
	local myFightOrder = MyGuildWarInfoData.getMyFightOrder()
	local myFightOrderSprite = LuaCC.createSpriteOfNumbers("images/main/vip", tostring(myFightOrder), 10)
	local richInfo = {
		labelDefaultFont = g_sFontPangWa,
		labelDefaultColor = ccc3(0xff, 0xf6, 0x00),
		labelDefaultSize = 21,
		defaultType = "CCRenderLabel",
		defaultRenderType = type_shadow
	}
	if myFightOrder == 0 then
		richInfo.elements = {
			{
				text = GetLocalizeStringBy("key_8497")
			}
		}
	else
		richInfo.elements = {
			{
				["type"] = "CCNode",
				["create"] = function ()
					return myFightOrderSprite
				end
			}
		}
		richInfo = GetNewRichInfo("key_8498", richInfo)
	end
	if _myFightOrderLabel ~= nil then
		_myFightOrderLabel:removeFromParentAndCleanup(true)
	end
	_myFightOrderLabel = LuaCCLabel.createRichLabel(richInfo)
	_dialogBg:addChild(_myFightOrderLabel)
	_myFightOrderLabel:setAnchorPoint(ccp(0.5, 0.5))
	_myFightOrderLabel:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, 180))
end


--[[
	@desc:		显示本层的按钮层
	@return:	nil
--]]
function loadMenu( ... )
	_menu = CCMenu:create()
	_dialogBg:addChild(_menu)
	_menu:setPosition(ccp(0, 0))
	_menu:setContentSize(_dialogBg:getContentSize())
	_menu:setTouchPriority(_touchPriority - 10)
end

--[[
	@desc:				开始刷新战斗信息按钮和CD
	@return：	nil
--]]
function startRefreshUpdateFightForce( ... )
	refreshUpdateFightForce()
	schedule(_dialogBg, refreshUpdateFightForce, 1)
end

--[[
	@desc:				停止刷新战斗信息按钮
	@return:	nil
--]]
function stopRefreshUpdateFightForce( ... )
	_dialogBg:cleanup()
end

--[[
	@desc:		显示更新战斗力的按钮
	@return:	nil
--]]
function refreshUpdateFightForce( ... )
	local remianCD, costCount = MyGuildWarInfoData.getUpdateFormationRemainCDAndCost()
	local richInfo = {
		labelDefaultFont = g_sFontPangWa,
		labelDefaultColor = ccc3(0xfe, 0xdb, 0x1c),
		labelDefaultSize = 35,
		defaultType = "CCRenderLabel",
		lineAlignment = 2,
		defaultRenderType = type_stroke,
		elements = {
			{
				["type"] = "CCSprite",
				["image"] = "images/common/gold.png"
			},
			{
				["text"] = costCount
			}
		}
	}
	local formatText = nil
	local itemWidth = nil
	if costCount > 0 then
		formatText = GetLocalizeStringBy("key_8499")
		itemWidth = 330
	else
		formatText = GetLocalizeStringBy("key_8500")
		stopRefreshUpdateFightForce()
		itemWidth = 270
	end
	local newRichInfo = GetNewRichInfo(formatText, richInfo)
	if _updateFightForceItem ~= nil then
		_updateFightForceItem:removeFromParentAndCleanup(true)
	end
	_updateFightForceItem = LuaCC.create9ScaleMenuItemWithRichInfo("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", nil, CCSizeMake(itemWidth, 73), newRichInfo)
    _menu:addChild(_updateFightForceItem)
    _updateFightForceItem:setAnchorPoint(ccp(0.5, 0.5))
    _updateFightForceItem:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, 125))
    if remianCD <= 0 then
    	_updateFightForceItem:registerScriptTapHandler(MyGuildWarInfoController.updateFightForceCallback)
    else
    	_updateFightForceItem:registerScriptTapHandler(MyGuildWarInfoController.clearFightForceCallback)
    end
    if remianCD > 0 then
	    local timeText = TimeUtil.getTimeString(remianCD)
	    if _updateFightForceCDLabel == nil then
	    	_updateFightForceCDLabel = CCRenderLabel:create(timeText, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    	_dialogBg:addChild(_updateFightForceCDLabel)
	    	_updateFightForceCDLabel:setAnchorPoint(ccp(0, 0.5))
	    	_updateFightForceCDLabel:setPosition(ccp(_dialogBg:getContentSize().width * 0.5 + 180, 125))
	    	_updateFightForceCDLabel:setColor(ccc3(0x00, 0xff, 0x18))
		else
			_updateFightForceCDLabel:setString(timeText)
		end
	elseif _updateFightForceCDLabel ~= nil then
		_updateFightForceCDLabel:removeFromParentAndCleanup(true)
		_updateFightForceCDLabel = nil
	end
end

--[[
	@desc:			显示当前出战成员
	@return:		nil
--]]
function refreshFighterCount( ... )
	local enterFightCountColor = nil
	local enterFightCount = MyGuildWarInfoData.getEnterFighterCount()
	local enterFightMaxCount = MyGuildWarInfoData.getEnterFightMaxCount()
	if enterFightCount < enterFightMaxCount then
		enterFightCountColor = ccc3(0xff, 0x00, 0x00)
	end
	local richInfo = {
		labelDefaultColor = ccc3(0x00, 0xff, 0x18),
		labelDefaultSize = 21,
		defaultType = "CCRenderLabel",
		lineAlignment = 2,
		defaultRenderType = type_shadow,
		elements = {
			{
				["text"] = enterFightCount,
				["color"]= enterFightCountColor
			},
			{
				["text"] = enterFightMaxCount
			}
		}
	}
	if _curFighterCountLabel ~= nil then
		_curFighterCountLabel:removeFromParentAndCleanup(true)
	end
	_curFighterCountLabel = GetLocalizeLabelSpriteBy_2("key_8502", richInfo)
	_dialogBg:addChild(_curFighterCountLabel)
	_curFighterCountLabel:setAnchorPoint(ccp(0.5, 0.5))
	_curFighterCountLabel:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, 75))
end

--[[
	@desc: 			显示最底部提示
	@return:		nil
--]]
function loadBottomTip( ... )
	local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8501"), g_sFontPangWa, 18)
	_dialogBg:addChild(tip)
	tip:setAnchorPoint(ccp(0.5, 0.5))
	tip:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, 40))
	tip:setColor(ccc3(0x78, 0x25, 0x00))
end

--[[
	@desc:					刷新tableView数据显示
	@return:				nil
--]]
function refreshTableView( ... )
	local offset = _tableView:getContentOffset()
	_tableView:reloadData()
	_tableView:setContentOffset(offset)
end

--[[
	@desc:					关闭
	@return:		nil
--]]
function close( ... )
	_layer:removeFromParentAndCleanup(true)
end