-- Filename：	HeroLayout.lua
-- Author：		LLP
-- Date：		2014-4-21
-- Purpose：		列传的布局

module ("HeroLayout", package.seeall)

require "db/DB_Stronghold"
require "script/network/RequestCenter"
require "script/ui/copy/CopyRewardBtn"
require "script/ui/copy/CopyRewardLayer"
require "script/ui/copy/CopyUtil"
require "script/model/DataCache"
require "script/ui/star/StarLayer"
require "db/DB_Star"

local IMG_PATH = "images/main/"				-- 主城场景图片主路径

local containerLayer				--scrollView的容器
local fortMenuBar                   --所有据点都做成menuItem

local menuCloseBar

local curCopyForts = {}
local curFortId

local testLevelParams = {}
local testArmyIDsParams = {}

local curRound = 1
local curHardLevel = -1

local fortScrollView

local absY = 0
local rewardMenuBar = nil

local closeMenuItem = nil

local copyFileLua = nil
local _hardLevel = 0

-- 副本奖励
-- 相应的数据
local stars_t, copper_t, silver_t, gold_t
local box_status_t 		= nil
-- 青铜宝箱按钮
local _copperBox 		= nil
-- 白银宝箱按钮
local _silverBox 		= nil
-- 黄金宝箱按钮
local _goldBox			= nil
-- 奖励背景
local rewardSprite

local lastFortMenuItem 	= nil

local _ccExpProgress 	= nil
local _ccLabelExp 		= nil
local _ccEnergyProgress = nil
local _nExpProgressOriWidth = nil
local _energy 			= nil


local _lastCopyIdAndBaseId = {} 	-- 保存最后点击的copy_id和据点

local _openTargetStongholdId = nil

local _htid = nil

local _newData = {}

function init()
	containerLayer		= nil 	--scrollView的容器
	fortMenuBar			= nil 	--所有据点都做成menuItem

	menuCloseBar		= nil
	_hardLevel 			= 0
	curCopyForts 		= {}
	curFortId			= nil

	testLevelParams 	= {}
	testArmyIDsParams 	= {}

	curRound 			= 1
	curHardLevel 		= -1

	fortScrollView		= nil

	absY 				= 0
	rewardMenuBar 		= nil

	closeMenuItem 		= nil
	_openTargetStongholdId = nil


-- 副本奖励
-- 相应的数据
	stars_t, copper_t, silver_t, gold_t = nil, nil, nil, nil
	box_status_t 		= nil
-- 青铜宝箱按钮
	_copperBox 			= nil
-- 白银宝箱按钮
	_silverBox 			= nil
-- 黄金宝箱按钮
	_goldBox			= nil
-- 奖励背景
	rewardSprite		= nil

	lastFortMenuItem 	= nil

	_ccExpProgress 		= nil
	_ccLabelExp 		= nil
	_ccEnergyProgress 	= nil
	_energy 			= nil
	_nExpProgressOriWidth = nil
	_htid 				= nil
	_newData 			= {}
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return
--]]
local function onTouchesHandler( eventType, x, y )
	-- print("eventType=" .. eventType)
	if (eventType == "began") then
        -- touchBeganPoint = ccp(x, y)
        -- print("began.x= " .. touchBeganPoint.x .. ", began.y=" .. touchBeganPoint.y)
        return true
    elseif (eventType == "moved") then
        -- print("scrollView.x=", fortScrollView:getContentOffset().x, "   scrollView.y=", fortScrollView:getContentOffset().y)
    else
        -- print("touchBeganPoint.x= " .. touchBeganPoint.x .. "touchBeganPoint,y=" .. touchBeganPoint.y)
        -- print("end.x= " .. x .. ", end.y= " .. y)
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		-- print("enter")
		containerLayer:registerScriptTouchHandler(onTouchesHandler, false, -130, true)
		containerLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		-- print("exit")
		containerLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@desc	关闭FortsLayout
	@para 	void
	@return void
--]]
function closeFortsLayoutAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	--增加背景音乐
    require "script/audio/AudioUtil"
    AudioUtil.playMainBgm()
	if (containerLayer) then
		containerLayer:removeFromParentAndCleanup(true)
		containerLayer = nil
	end
	menuCloseBar:removeFromParentAndCleanup(true)
	menuCloseBar = nil

	local starInfo = StarUtil.getStarInfoByHtid(_htid)
	local starLayer = StarLayer.createLayer(starInfo.star_id)
	MainScene.changeLayer(starLayer, "starLayer")
end


-- 某个武将的副本难度
function getHardLvByHTidAndHCopyId( h_tid, copy_id )
	hardLevel = nil

	require "db/DB_Heroes"
	local heroInfo = DB_Heroes.getDataById(h_tid)
	if(heroInfo.hero_copy_id)then
		local copy_ids = string.split(heroInfo.hero_copy_id, ",")
		for k,type_copy in pairs(copy_ids) do
			local type_copy_arr = string.split(type_copy, "|")
			if(tonumber(copy_id) == tonumber(type_copy_arr[1])  )then
				hardLevel = tonumber(type_copy_arr[2])
				break
			end
		end
	end

	return hardLevel
end
--[[
	@desc	关闭FortsLayout的按钮
--]]
local function addCloseFortsLayoutMenu( ... )
	menuCloseBar = CCMenu:create()
	menuCloseBar:setPosition(ccp(1,0))
	menuCloseBar:setTouchPriority(-402)
	containerLayer:addChild(menuCloseBar, 1, 1)

	require "script/ui/main/MainScene"
	closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1, 1))
	closeMenuItem:registerScriptTapHandler(closeFortsLayoutAction)
	closeMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(containerLayer:getContentSize().width*0.99, containerLayer:getContentSize().height*0.95))
	menuCloseBar:addChild(closeMenuItem)
end

local function refreshFortsInfoLayer()
	local data = _newData
	if(tonumber(data.hero_copy.finish_num) > 0)then
		require "db/DB_Hero_copy"
		local htid = DB_Hero_copy.getDataById(data.hero_copy.copyid).hero_id
		print("herolayout htid==="..htid)
		print("herolayout _hardLevel===".._hardLevel)
		local hardLevel = _hardLevel
		require "script/ui/star/StarUtil"
		DataCache.addPassHeroCopyTimesBy(htid, data.hero_copy.copyid,_hardLevel)

		local addNum = 0
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		if(heroInfo.hero_copy_id)then
			local copy_ids = string.split(heroInfo.hero_copy_id, ",")
			for k,type_copy in pairs(copy_ids) do
				local type_copy_arr = string.split(type_copy, "|")
				if(tonumber(data.hero_copy.copyid) == tonumber(type_copy_arr[1])  )then
					addNum = tonumber(type_copy_arr[3])
					break
				end
			end
		end
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1103"))
		require "script/ui/heroCpy/PassHeroCopyLayer"
		PassHeroCopyLayer.showLayer(htid,_hardLevel,addNum)
	else
		require "db/DB_Hero_copy"
		local htid = DB_Hero_copy.getDataById(data.hero_copy.copyid).hero_id
		require "script/ui/heroCpy/HeroLayout"
		local fortsLayer = HeroLayout.createFortsLayout(data.hero_copy,htid,_hardLevel)
		MainScene.changeLayer(fortsLayer, "fortsLayer")
	end

end

--[[
 @desc	战斗回调
 @para
 @return
 --]]
function doBattleCallback( newData, isVictory )
	_newData = newData
	local isHaveTalk = false
	local isHadVictory = CopyUtil.isHeroStrongHoldIsVict(curFortId)
	local _strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))
	print("herolayout====curFortId"..curFortId)
	print_t(_strongHoldInfo)
	print("herolayout====curFortId"..curFortId)
	if(isVictory and (not isHadVictory)) then
		-- 对话
		print("herolayout0")
	    if(_strongHoldInfo.victor_dialog_id and tonumber(_strongHoldInfo.victor_dialog_id) > 0 and (not CopyUtil.isFortIdVicHadDisplay(_strongHoldInfo.id)))then
	    	print("herolayout1")
	    	CopyUtil.addHadVicDialogFortId(curFortId)
	    	require "script/ui/talk/talkLayer"
		    local talkLayer = TalkLayer.createTalkLayer(_strongHoldInfo.victor_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10000)
		    TalkLayer.setCallbackFunction(TalkOverCallback)
		    isHaveTalk = true
	    end
	    -- DataCache.addDefeatNumByCopyAndFort( curCopyId, curFortId, -1 )
	else
		-- 对话
		print("herolayout1.5")
	    if( (not isHadVictory) and _strongHoldInfo.fail_dialog_id and tonumber(_strongHoldInfo.fail_dialog_id) > 0 and (not CopyUtil.isFortIdFailHadDisplay(_strongHoldInfo.id)))then
	    	CopyUtil.addHadFailDialogFortId(_strongHoldInfo.id)
	    	require "script/ui/talk/talkLayer"
	    	print("herolayout2")
		    local talkLayer = TalkLayer.createTalkLayer(_strongHoldInfo.fail_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10000)
		    TalkLayer.setCallbackFunction(TalkOverCallback)
		    isHaveTalk = true
	    end
	end

	print("herolayout2.5")
	if(isHaveTalk == false) then
		print("herolayout3")
		TalkOverCallback()
	end
end

local function npcOrNotFunc()
	local enterNPC = 0
	local enterSimple = 1
	local enterNormal = 2
	local enterHard = 3
	print("curFortId===="..curFortId)
	local progressState = curCopyForts.va_copy_info.progress[curFortId .. ""]

	local fortDesc = DB_Stronghold.getDataById(tonumber(curFortId))
-- base_status的取值：0可显示 1可攻击 2npc通关 3简单通关 4普通通关 5困难通关
	if( progressState == 0) then
		print(GetLocalizeStringBy("key_2676"))
		return
	elseif (progressState == "1") then


		if(fortDesc.npc_army_num_simple and fortDesc.npc_army_num_simple > 0) then
			curHardLevel = enterNPC
			level = 0
			require "script/utils/LuaUtil"
			local armyIDs = lua_string_split(fortDesc.npc_army_ids_simple, ",")

			for k,v in pairs(armyIDs) do
				table.insert(testArmyIDsParams,v)
			end
		else
			curHardLevel = enterSimple
		end
	elseif (progressState == "2") then
		curHardLevel = enterSimple
	elseif (progressState == "3") then
		curHardLevel = enterNormal
	elseif (progressState == "4") then
		curHardLevel = enterHard
	elseif (progressState == "5") then
		curHardLevel = enterHard
	else
	end

	print("curHardLevel====")

	if(curHardLevel == enterNPC) then
		print("curHardLevel====")
		-- 检查体力是否足够
		require "script/model/user/UserModel"
		-- if( fortDesc.cost_energy_simple > UserModel.getEnergyValue() )then
		-- 	AnimationTip.showTip(GetLocalizeStringBy("key_3355"))
		-- 	return
		-- end
		require "script/battle/BattleLayer"
		local battleLayer = BattleLayer.enterBattle(curCopyForts.copyid, curFortId, _hardLevel, doBattleCallback, 6)
	else
        require "script/ui/heroCpy/HeroFortInfoLayer"
        -- local hard = getHardLvByHTidAndHCopyId(_htid,curCopyForts.copyid)
        print("htid1====".._htid)
        print("_hardLevelhahaha=====".._hardLevel)
        print("curCopyForts.copyid===="..curCopyForts.copyid)
		local fortInfoLayer = HeroFortInfoLayer.createLayer(curCopyForts.copyid,curFortId, progressState,_hardLevel)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(fortInfoLayer, 99)

	end
end

--[[
 @desc	选中据点的处理
 @para
 @return
 --]]
local function menuAction( tag, menuItem )


	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/start_fight.mp3")
    require "script/ui/hero/HeroPublicUI"
	if(ItemUtil.isBagFull() == true)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		return
	elseif HeroPublicUI.showHeroIsLimitedUI() then
		return
	end

	curFortId = tag
	curRound = 1
	local fortDesc = DB_Stronghold.getDataById(tonumber(curFortId))

	-- -- 对话
    if(fortDesc.pre_dialog_id and fortDesc.pre_dialog_id > 0 and (not CopyUtil.isFortIdHadDisplay(curFortId)) and (not CopyUtil.isStrongHoldIsVict(curFortId)))then
    	CopyUtil.addHadDialogFortId(curFortId)
    	require "script/ui/talk/talkLayer"
	    local talkLayer = TalkLayer.createTalkLayer(fortDesc.pre_dialog_id)
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(talkLayer,999999)
	    isCreateHavaTalk = true
	    TalkLayer.setCallbackFunction(npcOrNotFunc)
    else
    	npcOrNotFunc()
    end

    _lastCopyIdAndBaseId[curCopyForts.copyid] = curFortId

end


local function scrollToPoint( toPoint )
	local scrollY = containerLayer:getContentSize().height/2 - toPoint.y * MainScene.bgScale
	local t_absY = absY * MainScene.bgScale
	if(scrollY>0)then
		scrollY=0
	end
	if(scrollY< -(t_absY - containerLayer:getContentSize().height)) then
		scrollY = -(t_absY - containerLayer:getContentSize().height)
	end
	fortScrollView:setContentOffset(ccp(0, scrollY))
	-- fortScrollView:setContentOffsetInDuration(ccp(0, scrollY), 1)
end

function rewardDelegate( box_index )

end

function rewardBtnAction( tag, itemBtn )

end

-- 副本奖励
local function copyRewardUI( )
end

 function createAnimation( toPoint, k_type, imageIcon )
	k_type = tonumber(k_type)
	local animationNameType = nil
	if(k_type == 1) then
		animationNameType = "fbjdmu"
	elseif(k_type == 2) then
		animationNameType = "fbjdying"
	elseif(k_type == 3) then
		animationNameType = "fbjdjin"
	end

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/" .. animationNameType), -1,CCString:create(""));

    --替换头像
    local replaceXmlSprite = tolua.cast( spellEffectSprite:getChildByTag(1002) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(imageIcon))

    spellEffectSprite:setPosition(toPoint)
    spellEffectSprite:setAnchorPoint(ccp(0, 0));
    fortScrollView:addChild(spellEffectSprite,9999);

     --delegate
    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
        spellEffectSprite:removeFromParentAndCleanup(true)
        lastFortMenuItem:setVisible(true)
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)
end

-- 经验和体力进度条
function createExpAndEnergyProgress()
-- 标题栏
	local titleSprite = CCScale9Sprite:create("images/copy/bg.png")
	--scale changed by zhang zihang
	titleSprite:setContentSize(CCSizeMake(containerLayer:getContentSize().width/g_fElementScaleRatio, 34))
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccp(containerLayer:getContentSize().width*0.5, containerLayer:getContentSize().height))
	containerLayer:addChild(titleSprite)

	local lvSprite = CCSprite:create("images/common/lv.png")
	lvSprite:setAnchorPoint(ccp(0.5, 0.5))
	lvSprite:setPosition(ccp(70, titleSprite:getContentSize().height*0.5))
	titleSprite:addChild(lvSprite)

	-- 等级
	local lvLabel = CCRenderLabel:create(UserModel.getHeroLevel(), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    lvLabel:setAnchorPoint(ccp(0, 0.5))
    lvLabel:setPosition(ccp(90, titleSprite:getContentSize().height*0.5))
    titleSprite:addChild(lvLabel)

	local expProgressBg = CCSprite:create("images/common/progress_bg.png")
	expProgressBg:setPosition(130, titleSprite:getContentSize().height*0.5)
	expProgressBg:setAnchorPoint(ccp(0, 0.5))
	titleSprite:addChild(expProgressBg)
	-- 经验进度条
    _ccExpProgress = CCSprite:create(IMG_PATH .. "progress_blue.png")
    local size = _ccExpProgress:getContentSize()
    _nExpProgressOriWidth = size.width
    _ccExpProgress:setPosition(130, titleSprite:getContentSize().height*0.5)
    _ccExpProgress:setAnchorPoint(ccp(0, 0.5))
    _ccExpProgress:setTextureRect(CCRectMake(0, 0, size.width/2, size.height))
    titleSprite:addChild(_ccExpProgress)
	-- 经验值信息
    _ccLabelExp = CCLabelTTF:create ("1/1", g_sFontName, 18)
    _ccLabelExp:setPosition(size.width/2, size.height/2-2)
    _ccLabelExp:setColor(ccc3(0, 0, 0))
    _ccLabelExp:setAnchorPoint(ccp(0.5, 0.5))
    _ccExpProgress:addChild(_ccLabelExp)


-- 体力
	--position changed by zhang zihang
	local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1032"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    energyLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    energyLabel:setAnchorPoint(ccp(0, 0.5))
    energyLabel:setPosition(ccp(titleSprite:getContentSize().width/2+70, titleSprite:getContentSize().height*0.5))
    titleSprite:addChild(energyLabel)

    local energyProgressBg = CCSprite:create("images/common/progress_bg.png")
    energyProgressBg:setAnchorPoint(ccp(0, 0.5))
	energyProgressBg:setPosition(titleSprite:getContentSize().width/2+115, titleSprite:getContentSize().height*0.5)
	titleSprite:addChild(energyProgressBg)

	-- 体力进度条
    _ccEnergyProgress = CCSprite:create(IMG_PATH .. "progress_yellow.png")
    _ccEnergyProgress:setAnchorPoint(ccp(0, 0.5))
    size = _ccEnergyProgress:getContentSize()
    _nEnergyProgressOriWidth = size.width
    _ccEnergyProgress:setPosition(titleSprite:getContentSize().width/2+115, titleSprite:getContentSize().height*0.5)
    _ccEnergyProgress:setTextureRect(CCRectMake(0, 0, size.width/2, size.height))
    titleSprite:addChild(_ccEnergyProgress)
    -- 体力值信息
    local maxEnergyNum = UserModel.getMaxExecutionNumber()
    _energy = CCLabelTTF:create (maxEnergyNum.."/"..maxEnergyNum, g_sFontName, 18)
    _energy:setColor(ccc3(0, 0, 0))
    _energy:setPosition(ccp(size.width/2, size.height/2-2))
    _energy:setAnchorPoint(ccp(0.5, 0.5))
    _ccEnergyProgress:addChild(_energy)

    refreshExpAndEnergy()
end

function refreshExpAndEnergy()
	updateEnergyValueUI()
	updateExpValueUI()
end

-- 更新体力值方法
function updateEnergyValueUI()
	if not _energy then
        return
    end
    local maxEnergyNum = UserModel.getMaxExecutionNumber()
    -- 体力值信息显示
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    local energyValue = tonumber(userInfo.execution)
    _energy:setString(energyValue.."/"..maxEnergyNum)
    local width = _nEnergyProgressOriWidth
    if energyValue < maxEnergyNum then
        width = math.floor(energyValue*_nEnergyProgressOriWidth/maxEnergyNum)
    end
    _ccEnergyProgress:setTextureRect(CCRectMake(0, 0, width, _ccEnergyProgress:getContentSize().height))
end

-- 更新经验值显示方法及进度条
function updateExpValueUI()
	-- 更新显示数据
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    require "db/DB_Level_up_exp"
    local tUpExp = DB_Level_up_exp.getDataById(2)
    local nLevelUpExp = tUpExp["lv_"..(tonumber(userInfo.level)+1)]
    if not _ccLabelExp then
        return
    end
    _ccLabelExp:setString(math.floor(userInfo.exp_num).."/"..nLevelUpExp)
    -- 更新进度条
    local nExpNum = tonumber(userInfo.exp_num)
    width = _nExpProgressOriWidth
    if nExpNum < nLevelUpExp then
        width = math.floor(nExpNum*_nExpProgressOriWidth/nLevelUpExp)
    end
    _ccExpProgress:setTextureRect(CCRectMake(0, 0, width, _ccExpProgress:getContentSize().height))
end

--[[
 @desc	创建据点的布局
 @para  table fortsData
 @return
 --]]
function createFortsLayout( fortsData, htid,hard_tag)
	init()
	curCopyForts = fortsData
	_htid = htid
	print("herolayout hard_tag==="..hard_tag)
	_hardLevel = hard_tag
	print("herolayout hardLevel===".._hardLevel)
	require "db/DB_Hero_copy"
	curCopyForts.copyInfo = DB_Hero_copy.getDataById(fortsData.copyid)

	containerLayer = MainScene.createBaseLayer(nil ,false, false, false)
	fortScrollView = CCScrollView:create()

	--增加背景音乐
    require "script/audio/AudioUtil"
    AudioUtil.playBgm("audio/bgm/" .. curCopyForts.copyInfo.music_path)

	require "script/utils/LuaUtil"

	-- 特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/miwu/miwu"), 1,CCString:create(""));
	spellEffectSprite:setScale(g_fBgScaleRatio/MainScene.elementScale*1.01)
    spellEffectSprite:setPosition(ccp( containerLayer:getContentSize().width*0.5,containerLayer:getContentSize().height*0.5) )
    containerLayer:addChild(spellEffectSprite,1);

    local animationEnd = function(actionName,xmlSprite)
        spellEffectSprite:cleanup()
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)

	fortMenuBar = CCMenu:create()
	require "script/ui/main/MainScene"

	local starInfo = DB_Star.getDataById(_htid)

	print("111111111111111")
	print_t(starInfo)
	print("2222222")
	if(curCopyForts.copyid~=nil)then
		copyFileLua = "db/heroCXml/hero_" .. curCopyForts.copyid
		_G[copyFileLua] = nil
		package.loaded[copyFileLua] = nil
		require (copyFileLua)
	else
		copyFileLua = "db/heroCXml/hero_" .. curCopyForts.copy_id
		_G[copyFileLua] = nil
		package.loaded[copyFileLua] = nil
		require (copyFileLua)
	end

    local layoutSprite = nil
    if(file_exists("images/copy/ncopy/overallimage/" .. HeroCXml.background))then
        layoutSprite = CCSprite:create("images/copy/ncopy/overallimage/" .. HeroCXml.background)
    else
        layoutSprite = CCSprite:create("images/copy/ncopy/overallimage/" .. string.sub(HeroCXml.background,1,string.len(HeroCXml.background)-4) .. ".webp")
    end
	layoutSprite:setScale(1/MainScene.elementScale)
	absY = layoutSprite:getContentSize().height
	layoutSprite:setScale(MainScene.bgScale)
	fortScrollView:setContainer(layoutSprite)
	fortScrollView:setTouchEnabled(true)
	fortScrollView:setViewSize(g_winSize)
	fortScrollView:setAnchorPoint(ccp(0,0))
	fortScrollView:setBounceable(false)
	fortScrollView:setScale(1/MainScene.elementScale)
	containerLayer:addChild(fortScrollView)
	-- containerLayer:registerScriptHandler(onNodeEvent)
	require "script/ui/copy/FortItem"

	local lastBaseId = 0
	local toPoint = nil
	lastFortMenuItem = nil
	local pngIndex = nil
	local animateIconName = nil

	for baseid,fVal in pairs(curCopyForts.va_copy_info.progress) do
		if( tonumber(baseid) > lastBaseId ) then
			lastBaseId = tonumber (baseid)
		end
	end

	-- 最后点击的据点
	local m_toPoint = nil
	-- 最后点击的据点
	local m_lastBaseId = nil

	-- 是否有最后一次记录
	for m_copyId, m_baseId in pairs(_lastCopyIdAndBaseId) do
		if( tonumber(m_copyId) == tonumber(curCopyForts.copyid) ) then
			m_lastBaseId = tonumber (m_baseId)
			break
		end
	end

	-- 是否能够自动打开据点详情页
	local isNeedOpenBase = false
	local x = 1
	for baseid,fVal in pairs(curCopyForts.va_copy_info.progress) do
		local fortDesc = DB_Stronghold.getDataById(tonumber(baseid))

		if(_openTargetStongholdId and _openTargetStongholdId == tonumber(baseid)  )then
			-- 有要开启的据点
			isNeedOpenBase = true
		end
		fortDesc.progressStatus = fVal

		for k,fortInfo in pairs(HeroCXml.models.normal) do
			print("fortInfo.looks.look.armyID===="..fortInfo.looks.look.armyID)
			print("baseid == " .. baseid .. " , fortInfo.looks.look.armyID == " .. fortInfo.looks.look.armyID)
			if ( baseid == fortInfo.looks.look.armyID) then
				-- local fortDesc = DB_Stronghold.getDataById(tonumber(fortInfo.looks.look.armyID))
				-- fortDesc.progressStatus = "3"
				print("fortDesc")
				fortDesc.fortInfo = fortInfo
				local fortMenuItem = nil

				-- 最后点击的据点
				if(m_lastBaseId and tonumber(m_lastBaseId) == tonumber(baseid) )then
					m_toPoint = ccp(fortInfo.x, absY -fortInfo.y)
				end
				print("44444")
				if( tonumber(baseid) == lastBaseId )then
					lastBaseId = tonumber (baseid)
					print("33333")
					--added by 张梓航
					if tostring(fortDesc.progressStatus) <= "2" then
						print("111111111")
						fortMenuItem = FortItem.createItemImage(fortDesc, true, false)
					else
						print("222222222")
						fortMenuItem = FortItem.createItemImage(fortDesc, false, false)
					end
					toPoint = ccp(fortInfo.x, absY -fortInfo.y)
					lastFortMenuItem = fortMenuItem
					animateIconName = "images/base/hero/head_icon/" .. fortDesc.icon
					pngIndex = string.sub(fortDesc.fortInfo.looks.look.modelURL, 1, 1)
				else
					fortMenuItem = FortItem.createItemImage(fortDesc, false, false)
				end
				fortMenuItem:setAnchorPoint(ccp(0.5, 0))
				fortMenuItem:setPosition(ccp(fortInfo.x, absY -fortInfo.y))
				fortMenuBar:addChild(fortMenuItem, k, fortInfo.looks.look.armyID)
				fortMenuItem:registerScriptTapHandler(menuAction)
				break
			end
		end
	end

	if(m_lastBaseId and m_lastBaseId>0 and m_toPoint)then
		scrollToPoint(m_toPoint)
	elseif(lastBaseId>0 and toPoint ) then
		scrollToPoint(toPoint)
	end

	if( not CopyUtil.isOpendHadDisplay(lastBaseId))then
		CopyUtil.addOpenedFortId(lastBaseId)
		lastFortMenuItem:setVisible(false)
		createAnimation(toPoint, pngIndex, animateIconName)
	end
	fortMenuBar:setPosition(ccp(0,0))
	layoutSprite:addChild(fortMenuBar)

	if(isNeedOpenBase == true)then
		menuAction(_openTargetStongholdId, nil)
	else
		if(_openTargetStongholdId and _openTargetStongholdId >0 )then
			AnimationTip.showTip(GetLocalizeStringBy("key_1561"))
		end
	end


	addCloseFortsLayoutMenu()

------------------------------------------------ 标题--------------------------
	local energyProgressBg = CCSprite:create("images/common/progress_bg.png")
	--副本名字底
	local copyNameBg = CCSprite:create("images/copy/acopy/namebg.png")
	containerLayer:addChild(copyNameBg)
	copyNameBg:setAnchorPoint(ccp(0,0.5))
	copyNameBg:setPosition(ccp(0,g_winSize.height-copyNameBg:getContentSize().height*g_fElementScaleRatio-energyProgressBg:getContentSize().height*g_fElementScaleRatio))
	-- copyNameBg:setScale(g_fElementScaleRatio)

    --副本名称
    local nameSprite = CCSprite:create("images/copy/ncopy/nameimage/" .. curCopyForts.copyInfo.image)
    nameSprite:setAnchorPoint(ccp(0, 0.5))
    nameSprite:setPosition(copyNameBg:getContentSize().width*0.1, copyNameBg:getContentSize().height*0.5);
    copyNameBg:addChild(nameSprite)

 --    require "db/DB_Star"
	-- local starDesc = DB_Star.getDataById(h_tid)

	local bgSprite = CCSprite:create("images/base/potential/officer_" .. starInfo.quality .. ".png")
	local iconFile = "images/base/hero/head_icon/" .. starInfo.icon

    local headSprite = CCSprite:create(iconFile)
    headSprite:setAnchorPoint(ccp(0.5,0.5))
    headSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5))
    bgSprite:addChild(headSprite)
    local scaleSprite = CCScale9Sprite:create("images/common/bg/di.png")
	scaleSprite:setContentSize(CCSizeMake(g_winSize.width*0.8,bgSprite:getContentSize().height+10))
	containerLayer:addChild(scaleSprite)
	scaleSprite:setAnchorPoint(ccp(0,1))
	scaleSprite:setPosition(ccp(20,containerLayer:getContentSize().height*0.95-nameSprite:getContentSize().height*g_fElementScaleRatio))
	scaleSprite:addChild(bgSprite)

	local heroName = CCRenderLabel:create( starInfo.name, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	heroName:setAnchorPoint(ccp(0,1))
	heroName:setColor(ccc3(0xe4,0x00,0xff))
	scaleSprite:addChild(heroName)
	heroName:setPosition(ccp(bgSprite:getContentSize().width,bgSprite:getContentSize().height))

	local progressLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_6"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	progressLabel:setAnchorPoint(ccp(0,1))
	progressLabel:setColor(ccc3(0xff,0xff,0xff))
	scaleSprite:addChild(progressLabel)
	progressLabel:setPosition(ccp(bgSprite:getContentSize().width,bgSprite:getContentSize().height-heroName:getContentSize().height))

	local progressNum = table.count(fortsData.va_copy_info.progress)-1
	local progressStr = progressNum.."/"..curCopyForts.copyInfo.base_sum
	local progressNumLabel = CCRenderLabel:create( progressStr, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	progressNumLabel:setAnchorPoint(ccp(0,1))
	progressNumLabel:setColor(ccc3(0x00,0xff,0x18))
	scaleSprite:addChild(progressNumLabel)
	progressNumLabel:setPosition(ccp(bgSprite:getContentSize().width+progressLabel:getContentSize().width,bgSprite:getContentSize().height-heroName:getContentSize().height))

	local passLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_7"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	passLabel:setAnchorPoint(ccp(0,1))
	passLabel:setColor(ccc3(0xff,0xf6,0x00))
	scaleSprite:addChild(passLabel)
	passLabel:setPosition(ccp(bgSprite:getContentSize().width,bgSprite:getContentSize().height-heroName:getContentSize().height-progressLabel:getContentSize().height))
	local thrLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_4"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	if(hard_tag==1)then
		local easyLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_8"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		easyLabel:setColor(ccc3(0x00,0xff,0x18))
		nameSprite:addChild(easyLabel)
		easyLabel:setAnchorPoint(ccp(0,0))
		easyLabel:setPosition(ccp(nameSprite:getContentSize().width,0))

		local firstLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_2"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		firstLabel:setAnchorPoint(ccp(0,1))
		firstLabel:setColor(ccc3(0x00,0xe4,0xff))
		scaleSprite:addChild(firstLabel)
		firstLabel:setPosition(ccp(bgSprite:getContentSize().width+passLabel:getContentSize().width,bgSprite:getContentSize().height-heroName:getContentSize().height-progressLabel:getContentSize().height))
	elseif(hard_tag==2)then
		local normalLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_9"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		normalLabel:setColor(ccc3(0xff,0xf6,0x00))
		nameSprite:addChild(normalLabel)
		normalLabel:setAnchorPoint(ccp(0,0))
		normalLabel:setPosition(ccp(nameSprite:getContentSize().width,0))

		local secLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_3"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		secLabel:setAnchorPoint(ccp(0,1))
		secLabel:setColor(ccc3(0x00,0xe4,0xff))
		scaleSprite:addChild(secLabel)
		secLabel:setPosition(ccp(bgSprite:getContentSize().width+passLabel:getContentSize().width,bgSprite:getContentSize().height-heroName:getContentSize().height-progressLabel:getContentSize().height))
	elseif(hard_tag==3)then
		local hardLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_10"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		hardLabel:setColor(ccc3(0xe8,0x00,0x00))
		hardLabel:addChild(hardLabel)
		hardLabel:setAnchorPoint(ccp(0,0))
		hardLabel:setPosition(ccp(nameSprite:getContentSize().width,0))

		-- local thrLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_4"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		thrLabel:setAnchorPoint(ccp(0,1))
		thrLabel:setColor(ccc3(0x00,0xe4,0xff))
		scaleSprite:addChild(thrLabel)
		thrLabel:setPosition(ccp(bgSprite:getContentSize().width+passLabel:getContentSize().width,bgSprite:getContentSize().height-heroName:getContentSize().height-progressLabel:getContentSize().height))
	end
	scaleSprite:setContentSize(CCSizeMake(thrLabel:getContentSize().width+bgSprite:getContentSize().width+passLabel:getContentSize().width,bgSprite:getContentSize().height+10))
 --    --英雄头像
 --    local bgSprite = CCSprite:create("images/base/potential/officer_" .. starInfo.quality .. ".png")
	-- local headres= "images/base/hero/head_icon/" .. starInfo.icon

	-- local headSprite = CCSprite:create(headres)
	-- headSprite:setAnchorPoint(ccp(0.5,0.5))
	-- headSprite:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5)
	-- bgSprite:addChild(headSprite)
	-- bgSprite:setAnchorPoint(ccp(0,1))
	-- bgSprite:setPosition(ccp(containerLayer:getContentSize().width*0.03,containerLayer:getContentSize().height*0.95-nameSprite:getContentSize().height))
	-- containerLayer:addChild(bgSprite)
	-- --副本进度汉子label
	-- local finish_cn_label = CCRenderLabel:create( hero.name..GetLocalizeStringBy("key_3426"), g_sFontPangWa, 28, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)

	-- --副本进度数字label

	-- --当前难度汉子label

	-- --当前难度sprite

	-- --通关后可领悟label

	-- --觉醒能力label

	copyRewardUI()
    copy = nil
    package.loaded[copyFileLua] = nil

    -- 该副本的第一个据点是否通过
    local isPassFirst = true
    if(table.count(curCopyForts.va_copy_info.progress)==1 ) then
    	for k,v in pairs(curCopyForts.va_copy_info.progress) do
    		if(tonumber(v) < 2)then
    			isPassFirst = false
    		end
    	end
    end
    -- 对话
    if( (not isPassFirst) and curCopyForts.copyInfo.dialogid and  tonumber(curCopyForts.copyInfo.dialogid)>0 and (not CopyUtil.isCopyIdHadDisplay(curCopyForts.copyid)) ) then
    	CopyUtil.addHadDialogCopyId(curCopyForts.copyid)
    	require "script/ui/talk/talkLayer"
	    local talkLayer = TalkLayer.createTalkLayer(curCopyForts.copyInfo.dialogid)
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(talkLayer,999999)
	    TalkLayer.setCallbackFunction(endTalkCallbackFunc)
	else

    end
    createExpAndEnergyProgress()
	return containerLayer
end

function doBattleOverCallback()

	-- add by chengliang
	require "script/ui/copy/ShowNewCopyLayer"
	ShowNewCopyLayer.showNewCopy()


	require "script/guide/CopyBoxGuide"

	if(CopyUtil.isFirstPassCopy_1 == true) then
		CopyBoxGuide.CopyFirstDidOver()
	end


    -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
end

-- 对话结束回调
function endTalkCallbackFunc()

end


--add by lichenyang
function TalkOverCallback( ... )
	print("herolayout4")
	-- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
	HeroFortInfoLayer.closeAction()
	refreshFortsInfoLayer()
end
