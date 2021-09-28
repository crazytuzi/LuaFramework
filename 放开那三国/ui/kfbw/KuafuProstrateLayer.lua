-- FileName: KuafuProstrateLayer.lua 
-- Author: yangrui
-- Date: 15-09-28
-- Purpose: 跨服比武 膜拜

module("KuafuProstrateLayer", package.seeall)
require "script/ui/title/TitleUtil"

local _bgLayer         = nil
local _layerSize       = nil
local _rewardPanel     = nil  -- 奖励面板
local _tbBg            = nil  -- 奖励tableview背景
local _rewardItemTable = nil  -- 奖励TableView
local _prostrateBtn    = nil  -- 膜拜按钮
local _menu            = nil  -- 膜拜按钮bar

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer         = nil
	_layerSize       = nil
	_rewardPanel     = nil  -- 奖励面板
	_tbBg            = nil  -- 奖励tableview背景
	_rewardItemTable = nil  -- 奖励TableView
	_prostrateBtn    = nil  -- 膜拜按钮
	_menu            = nil  -- 膜拜按钮bar
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
	@des    : 创建被崇拜对象
	@para   : 
	@return : 
--]]
function createProstrateObj( ... )
	local isHaveRankData = true
	-- 从排行榜中获取排名第一的玩家信息
	local userInfo = KuafuData.getChampionData()
	if userInfo == nil or table.isEmpty(userInfo) then
		isHaveRankData = false
		-- 分组中没有玩家比武，返回玩家自己
		userInfo = UserModel.getUserInfo()
	end
 	-- 宝座
 	local baseChairSp = CCSprite:create("images/dress_room/stage.png")
 	baseChairSp:setAnchorPoint(ccp(0.5,0))
 	baseChairSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,(_rewardPanel:getContentSize().height+95)*g_fScaleY))
 	baseChairSp:setScale(MainScene.elementScale)
 	_bgLayer:addChild(baseChairSp)
	-- 冠军
	-- 判断是否有时装
	local dressId = nil
        if userInfo.dress then
            if ( not table.isEmpty(userInfo.dress) and (userInfo.dress["1"]) ~= nil and tonumber(userInfo.dress["1"]) > 0 ) then
                dressId = userInfo.dress["1"]
            end
        end
	local winSp = HeroUtil.getHeroBodySpriteByHTID(userInfo.htid,dressId,HeroModel.getSex(userInfo.htid))
	winSp:setAnchorPoint(ccp(0.5,0))
	winSp:setPosition(ccp(baseChairSp:getContentSize().width*0.5,baseChairSp:getContentSize().height*0.5))
	winSp:setScale(0.85)
	baseChairSp:addChild(winSp)
	-- 皇冠
	local kingHat = CCSprite:create("images/kfbw/win_hat.png")
	kingHat:setAnchorPoint(ccp(0.5,0))
	kingHat:setPosition(ccp(winSp:getContentSize().width*0.5, winSp:getContentSize().height*0.82))
	winSp:addChild(kingHat)
	-- 称号
	local titleId = tonumber(userInfo.title)
	if(titleId ~= nil and titleId > 0) then
		kingHat:setPosition(ccp(winSp:getContentSize().width*0.5, winSp:getContentSize().height*0.9))
	    local titleSp = TitleUtil.createTitleNormalSpriteById(titleId)
	    titleSp:setAnchorPoint(ccp(0.5,0.5))
	    titleSp:setPosition(ccp(kingHat:getContentSize().width*0.5,-winSp:getContentSize().height*0.07))
		kingHat:addChild(titleSp)
	end
	-- 名字
	local nameLabel = CCRenderLabel:create( userInfo.uname,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	nameLabel:setColor(ccc3(0xe4,0x00,0x00))
	-- 等级
	local levelLabel = CCRenderLabel:create(" Lv." .. userInfo.level,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- 名字 等级 背景
	local desNodeBg = CCScale9Sprite:create("images/treasure/name_bg.png")
	desNodeBg:setPreferredSize(CCSizeMake(224,35))
	desNodeBg:setAnchorPoint(ccp(0.5,1))
	desNodeBg:setPosition(ccp(baseChairSp:getContentSize().width*0.5,-2))
	baseChairSp:addChild(desNodeBg)
	-- 名字 等级
	local desNode = BaseUI.createHorizontalNode({nameLabel,levelLabel})
	desNode:setAnchorPoint(ccp(0.5,0.5))
	desNode:setPosition(ccp(desNodeBg:getContentSize().width*0.5,desNodeBg:getContentSize().height*0.5))
	desNodeBg:addChild(desNode)
	-- 加入玩家名字比较长，动态变动 desNodeBg 的宽
	local desNodeWidth = desNode:getContentSize().width
	if desNodeWidth > 224 then
		desNodeBg:setPreferredSize(CCSizeMake(desNodeWidth,35))
	end
	if isHaveRankData then
	    -- 显示服务器名字
	    local serverNameFont = CCRenderLabel:create("『" .. userInfo.server_name .. "』",g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	    serverNameFont:setColor(ccc3(0xff,0xff,0xff))
	    serverNameFont:setAnchorPoint(ccp(0.5,1))
	    serverNameFont:setPosition(ccp(baseChairSp:getContentSize().width*0.5,-desNodeBg:getContentSize().height-4))
	    baseChairSp:addChild(serverNameFont)
	end
end

--[[
	@des    : 创建膜拜按钮
	@para   : 
	@return : 
--]]
function createMenuItem( pNormalString, pSelectedString, pDisabledString, pSize )
	-- normal
    local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite:setContentSize(pSize)
	local norTitle  =  CCRenderLabel:create(pNormalString,g_sFontPangWa,35,1,ccc3( 0x00,0x00,0x00),type_shadow)
	norTitle:setColor(ccc3(0xfe,0xdb,0x1c))
	norTitle:setPosition(ccpsprite(0.5,0.5,norSprite))
	norTitle:setAnchorPoint(ccp(0.5,0.5))
	norSprite:addChild(norTitle)
	-- selected
	local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite:setContentSize(pSize)
    pSelectedString = pSelectedString or pNormalString
	local higTitle  =  CCRenderLabel:create(pSelectedString,g_sFontPangWa,35,1,ccc3( 0x00,0x00,0x00),type_shadow)
	higTitle:setColor(ccc3(0xfe,0xdb,0x1c))
	higTitle:setPosition(ccpsprite(0.5,0.5,higSprite))
	higTitle:setAnchorPoint(ccp(0.5,0.5))
	higSprite:addChild(higTitle)
	-- disabled
	local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	graySprite:setContentSize(pSize)
    pDisabledString = pDisabledString or pNormalString
	local grayTitle  =  CCRenderLabel:create(pDisabledString,g_sFontPangWa,35,1,ccc3( 0x00,0x00,0x00),type_shadow)
	grayTitle:setColor(ccc3(78,78,78))
	grayTitle:setPosition(ccpsprite(0.5,0.5,graySprite))
	grayTitle:setAnchorPoint(ccp(0.5,0.5))
	graySprite:addChild(grayTitle)
	-- create btn
	local button = CCMenuItemSprite:create(norSprite,higSprite,graySprite)
    return button
end

--[[
	@des    : 创建膜拜奖励Tableview
	@para   : 
	@return : 
--]]
function createTableview( ... )
	local rewardData = nil
	local userLevel = UserModel.getHeroLevel()
	local showSecCondition = KuafuData.getShowSecondProstrateLevel()
	if KuafuData.getProstrateTimes() == 0 then
		rewardData = KuafuData.getFirstProstrateReward()
	elseif KuafuData.getProstrateTimes() == 1 then
		if userLevel >= showSecCondition then
			rewardData = KuafuData.getSecondProstrateReward()
		else
			rewardData = KuafuData.getFirstProstrateReward()
		end
	elseif KuafuData.getProstrateTimes() == 2 then
		rewardData = KuafuData.getSecondProstrateReward()
	end
	local rewardList = string.split(rewardData,",")
	local function rewardItemTableCallback( fn, table, a1, a2 )
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110,140)
		elseif fn == "cellAtIndex" then
			a2 = createRewardCell(rewardList[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #rewardList
		elseif fn == "cellTouched" then
		end
		return r
	end
	local tableViewSize = CCSizeMake(590,140)
	if _rewardItemTable ~= nil then
		_rewardItemTable:removeFromParentAndCleanup(true)
		_rewardItemTable = nil
	end
	_rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback),tableViewSize)
	_rewardItemTable:setBounceable(true)
	_rewardItemTable:setAnchorPoint(ccp(0,0))
	_rewardItemTable:setPosition(ccp(5,0))
	_rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	_rewardItemTable:setTouchPriority(-520)
	_tbBg:addChild(_rewardItemTable)
	_rewardItemTable:reloadData()
end

--[[
	@des    : 创建一个膜拜奖励单元格
	@para   : 
	@return : 
--]]
function createRewardCell( pInfo )
	local itemInfo = ItemUtil.getItemsDataByStr(pInfo)[1]
	local icon = ItemUtil.createGoodsIcon(itemInfo)
	local cell = CCTableViewCell:create()
	cell:setContentSize(icon:getContentSize())
	icon:setPosition(ccpsprite(0.2,0.4,cell))
	cell:addChild(icon)
	return cell
end

--[[
	@des    : 创建膜拜奖励按钮
	@para   : 
	@return : 
--]]
function createProstrateBtn( ... )
	-- 膜拜btn  yr_2000 膜拜    yr_2008 再次膜拜    yr_2001 已膜拜
	if _prostrateBtn == nil then
		_prostrateBtn = createMenuItem(GetLocalizeStringBy("yr_2000"),nil,GetLocalizeStringBy("yr_2001"),CCSizeMake(188,70))
		_prostrateBtn:registerScriptTapHandler(prostrateBtnCallFunc)
		_menu:addChild(_prostrateBtn)
	end
	if KuafuData.getProstrateTimes() == 1 then
		local userLevel = UserModel.getHeroLevel()
		local showSecCondition = KuafuData.getShowSecondProstrateLevel()
		-- 是否可以看到第二次膜拜按钮  大于配置的等级才能看到
		if userLevel < showSecCondition then
			_prostrateBtn:setEnabled(false)
			_prostrateBtn:unregisterScriptTapHandler()
		else
			print("创建  再次膜拜")
			if _prostrateBtn ~= nil then
				_prostrateBtn:removeFromParentAndCleanup(true)
				_prostrateBtn = nil
			end
			_prostrateBtn = createMenuItem(GetLocalizeStringBy("yr_2008"),nil,GetLocalizeStringBy("yr_2001"),CCSizeMake(188,70))
			_prostrateBtn:registerScriptTapHandler(prostrateBtnCallFunc)
			_menu:addChild(_prostrateBtn)
		end
	-- 两次膜拜后  显示已膜拜
	elseif KuafuData.getProstrateTimes() == 2 then
		print("两次膜拜已结束")
		_prostrateBtn:setEnabled(false)
		_prostrateBtn:unregisterScriptTapHandler()
	end
	_prostrateBtn:setAnchorPoint(ccp(0.5,0))
	_prostrateBtn:setPosition(ccpsprite(0.5,0.02,_rewardPanel))
end

--[[
	@des    : 膜拜回调
	@para   : 
	@return : 
--]]
function prostrateBtnCallFunc( ... )
	print("膜拜回调")
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local userLevel = UserModel.getHeroLevel()
	local userVipLevel = UserModel.getVipLevel()
	local showSecCondition = KuafuData.getShowSecondProstrateLevel()
	local secProstrateConditionTab = string.split(KuafuData.getSecondProstrateCondition(),"|")
	-- 第一次膜拜
	if KuafuData.getProstrateTimes() == 0 then
		print("第一次膜拜  没有限制")
		-- 等级不满足配置等级  只能进行第一次膜拜且不刷新奖励
		if userLevel < showSecCondition then
			KuafuController.worship(1, true)
		else
			KuafuController.worship(1)
		end
	-- 第二次膜拜
	elseif KuafuData.getProstrateTimes() == 1 then
		if userLevel >= showSecCondition then
			if (userLevel < tonumber(secProstrateConditionTab[1]) and userVipLevel < tonumber(secProstrateConditionTab[2])) then
				-- 大于出现膜拜按钮的等级  小于配置的可以膜拜的等级 且 vip等级 小于 配置的vip等级 不可膜拜  但是提示
				local str = GetLocalizeStringBy("yr_2018",tonumber(secProstrateConditionTab[1]),tonumber(secProstrateConditionTab[2]))
				AnimationTip.showTip(str)
			elseif userLevel >= tonumber(secProstrateConditionTab[1]) or userVipLevel >= tonumber(secProstrateConditionTab[2]) then
				-- 虽然等级不够  但是vip等级满足  依然可以膜拜
				print("等级大于配置等级或者vip等级大于配置vip等级")
				-- 可以二次膜拜
				KuafuController.worship(2)
			end
		end
	end
end

--[[
	@des    : 创建膜拜奖励
	@para   : 
	@return : 
--]]
function createProstrateReward( ... )
	_rewardPanel = CCScale9Sprite:create(CCRectMake(33,35,12,45),"images/recharge/vip_benefit/vipBB.png")
	_rewardPanel:setPreferredSize(CCSizeMake(640,245))
	_rewardPanel:setAnchorPoint(ccp(0.5,0))
	_rewardPanel:setPosition(ccps(0.5,0))
	_rewardPanel:setScale(MainScene.elementScale)
	_bgLayer:addChild(_rewardPanel)
	-- background
	_tbBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_tbBg:setContentSize(CCSizeMake(595,140))
	_tbBg:setAnchorPoint(ccp(0.5,0))
	_tbBg:setPosition(ccp(_rewardPanel:getContentSize().width*0.5,70))
	_rewardPanel:addChild(_tbBg)
	-- nameBg
	local nameBg = CCScale9Sprite:create(CCRectMake(86,30,4,8),"images/dress_room/name_bg.png")
	nameBg:setPreferredSize(CCSizeMake(300,68))
	nameBg:setAnchorPoint(ccp(0.5,0.5))
	nameBg:setPosition(ccp(_rewardPanel:getContentSize().width*0.5,_rewardPanel:getContentSize().height-3))
	_rewardPanel:addChild(nameBg)
	-- name
	local title = GetLocalizeStringBy("yr_2007")  -- 膜拜奖励
	local name = CCRenderLabel:create(title,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	name:setColor(ccc3(0xff,0xf6,0x00))
	name:setAnchorPoint(ccp(0.5,0.5))
	name:setPosition(ccpsprite(0.5,0.5,nameBg))
	nameBg:addChild(name)
	-- create tableview
	createTableview()
	-- 膜拜按钮bar
	_menu = CCMenu:create()
	_menu:setAnchorPoint(ccp(0,0))
	_menu:setPosition(ccp(0,0))
	_rewardPanel:addChild(_menu)
	_menu:setTouchPriority(-504)
	-- create prostrate btn
	createProstrateBtn()
end

--[[
	@des    : 创建UI
	@para   : 
	@return : 
--]]
function createUI( ... )
	print("createUI====")
	_layerSize = _bgLayer:getContentSize()
	print("_layerSize",_layerSize.width,_layerSize.height)
	-- 创建膜拜奖励
	createProstrateReward()
	-- 创建被膜拜对象
	createProstrateObj()
end

--[[
	@des    : 创建膜拜Layer
	@para   : 
	@return : 
--]]
function createKFBWProstrateLayer( pLayerSize )
	print("createKFBWProstrateLayer",pLayerSize.width,pLayerSize.height)
	-- init
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setContentSize(pLayerSize)

	KuafuService.getChampion(function( ... )
		-- 创建UI
		createUI()
	end)

	return _bgLayer
end
