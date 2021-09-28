-- Filename：	GoldTreeBorder.lua
-- Author：		Cheng Liang
-- Date：		2013-12-10
-- Purpose：		摇钱树信息

module ("GoldTreeBorder", package.seeall)
require "script/ui/copy/CopyUtil"

local _bgLayer 		= nil
local _bgSprite 	= nil
local _copyInfo 	= nil
local isFree        = nil
_curTimeCost  		= 0         -- 本次挑战所需的金币数

-- added by bzx
local _checkTagSprite = nil
local _checkBtn 	  = nil

local _isUseItem 	= false
function init()
	_bgLayer 		= nil
	_bgSprite 		= nil
	_copyInfo 		= nil
	isFree 			= nil
	_curTimeCost  	= 0
	_isUseItem 		= false
	_checkTagSprite = nil
	_checkBtn 		= nil
end


-- 处理touches事件
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		print("began fortinfoLayer")
		
	    return true
    elseif (eventType == "moved") then
    	
    else
        print("end")
	end
end

--回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -410, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 

-- 挑战
function fightAction( tag, itembtn )
	-- 摇钱树
	if(_copyInfo.copyInfo.limit_lv and _copyInfo.copyInfo.limit_lv>UserModel.getHeroLevel())then
		AnimationTip.showTip(GetLocalizeStringBy("key_2398") .. _copyInfo.copyInfo.limit_lv .. GetLocalizeStringBy("key_1526"))
		return
	end
	if(UserModel.getEnergyValue() < _copyInfo.copyInfo.attack_energy)then
		require "script/ui/item/EnergyAlertTip"
		EnergyAlertTip.showTip()
		return
	end

	-- 使用物品可攻打
	local item_temp_id = CopyUtil.getCanDefeatItemTemplateIdBy(300001)
	local number = ItemUtil.getCacheItemNumBy( item_temp_id )

	---------------------------- 屏蔽金币攻打 ----------------------
	-- 已用金币挑战次数
	-- local usedTimes = DataCache.getAtkGoldTreeByUseGoldNum()
	-- 总共可用金币挑战次数
	-- local allTimes = CopyUtil.getMyselfAtkGoldTreeNum()
	---------------------------------------------------------------
	if(DataCache.getGoldTreeDefeatNum()>0)then
		-- BattleLayer.enterBattle(_copyInfo.copyInfo.id, _copyInfo.copyInfo.fort_ids, 0, CopyLayer.doBattleCallback, 3)
		DataCache.bakBossTreeLevel() --存储战斗前的摇钱树等级
		local args = Network.argsHandler(_copyInfo.copyInfo.id, 0)
		RequestCenter.copy_atkGoldTree(CopyLayer.goldTreeCallback, args)
		_isUseItem 		= false
		closeAction()
	---------------------------- 屏蔽金币攻打 ----------------------
	-- elseif( allTimes > usedTimes )then
	-- 	local args = Network.argsHandler(_copyInfo.copyInfo.id)
	-- 	RequestCenter.copy_atkGoldTreeByGold(CopyLayer.goldTreeCallback, args)
	-- 	closeAction()
	----------------------------------------------------------------
	elseif(number>0)then
		DataCache.bakBossTreeLevel()
		local args = Network.argsHandler(_copyInfo.copyInfo.id, 1)
		RequestCenter.copy_atkGoldTree(CopyLayer.goldTreeCallback, args)
		_isUseItem 		= true
		closeAction()
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_1168"))
	end
end

-- 创建背景
function createBgSprite()
	-- 背景
	_bgSprite = CCScale9Sprite:create("images/copy/goldTree.png", CCRectMake(0, 0, 571, 780), CCRectMake(10, 720, 560, 10))
	_bgSprite:setContentSize(CCSizeMake(571, 820))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setScale(MainScene.elementScale)
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_bgSprite)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-411)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
	closeBtn:registerScriptTapHandler(closeAction)
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.95, _bgSprite:getContentSize().height*0.95))
	closeMenuBar:addChild(closeBtn)

	-- 战斗
	local fightMenuBar = CCMenu:create()
	fightMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(fightMenuBar)
	fightMenuBar:setTouchPriority(-411)
	-- 战斗按钮
	-- local fightBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red2_n.png","images/common/btn/btn_red2_h.png",CCSizeMake(225, 83),GetLocalizeStringBy("key_1676"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- fightBtn:setAnchorPoint(ccp(0.5, 0))
	-- fightBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 23))
	-- fightBtn:registerScriptTapHandler(fightAction)
	-- fightMenuBar:addChild(fightBtn)

	-- 战斗按钮
	local fightBtn = nil
	local normalSprite = CCScale9Sprite:create("images/common/btn/btn_red2_n.png")
    local selectedSprite = CCScale9Sprite:create("images/common/btn/btn_red2_n.png")
	-- 是否免费攻打
    isFree = CopyUtil.isFreeToAtkGoldTree()
    if(isFree)then
	    -- 免费状态
	    normalSprite:setContentSize(CCSizeMake(225,83))
	    selectedSprite:setContentSize(CCSizeMake(225,83))
	 	fightBtn = CCMenuItemSprite:create(normalSprite, selectedSprite)
	 	local itemFont =  CCRenderLabel:create( GetLocalizeStringBy("key_1676") , g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    itemFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    itemFont:setAnchorPoint(ccp(0.5,0.5))
	    itemFont:setPosition(ccp(fightBtn:getContentSize().width*0.5,fightBtn:getContentSize().height*0.5))
	    fightBtn:addChild(itemFont)
	    -- 当前花费0金币
	    _curTimeCost = 0
	else
		-- 金币挑战
		normalSprite:setContentSize(CCSizeMake(275,83))
	    selectedSprite:setContentSize(CCSizeMake(275,83))
	 	fightBtn = CCMenuItemSprite:create(normalSprite, selectedSprite)
	 	local itemFont =  CCRenderLabel:create( GetLocalizeStringBy("key_1676") , g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    itemFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    itemFont:setAnchorPoint(ccp(0,0.5))
	    fightBtn:addChild(itemFont)
	    -- 金币图标
	    local goldSprite = CCSprite:create("images/common/gold.png")
	    goldSprite:setAnchorPoint(ccp(0,0.5))
	    fightBtn:addChild(goldSprite)
	    -- 金币数量
	    -- 计算本次挑战需要的费用
	    local allTimes = CopyUtil.getMyselfAtkGoldTreeNum()
	    local usedTimes = DataCache.getAtkGoldTreeByUseGoldNum()
	    local curTimes = 1
	    if(usedTimes >= allTimes )then
	    	curTimes = usedTimes
	    else
	    	curTimes = usedTimes+1 
	    end
	    local goldNum = CopyUtil.getAtkGoldTreeNeedByAtkNum( curTimes ) 
	    -- 当前花费金币
	    _curTimeCost = goldNum
	    local goldFont = CCRenderLabel:create( goldNum or " ", g_sFontName, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    goldFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    goldFont:setAnchorPoint(ccp(0,0.5))
	    fightBtn:addChild(goldFont)
	    -- 算坐标
	    local x = itemFont:getContentSize().width+5+goldSprite:getContentSize().width+1+goldFont:getContentSize().width
	    itemFont:setPosition(ccp((fightBtn:getContentSize().width-x)*0.5,fightBtn:getContentSize().height*0.5))
	    goldSprite:setPosition(ccp(itemFont:getPositionX()+itemFont:getContentSize().width+5,fightBtn:getContentSize().height*0.5-5))
	    goldFont:setPosition(ccp(goldSprite:getPositionX()+goldSprite:getContentSize().width+1,fightBtn:getContentSize().height*0.5-5))
	end
	fightBtn:setAnchorPoint(ccp(0.5, 0))
	fightBtn:setPosition(ccp(_bgSprite:getContentSize().width * 0.7, 63))
	fightBtn:registerScriptTapHandler(fightAction)
	fightMenuBar:addChild(fightBtn)

	-- added by bzx 摇钱树阵型
	local formationBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png", "images/common/btn/btn_blue2_h.png", CCSizeMake(200, 83), GetLocalizeStringBy("key_8552"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	fightMenuBar:addChild(formationBtn)
	formationBtn:setAnchorPoint(ccp(0.5, 0))
	formationBtn:setPosition(ccp(_bgSprite:getContentSize().width * 0.3, 63))
	formationBtn:registerScriptTapHandler(formationCallback)

	_checkBtn = CCMenuItemImage:create("images/common/checkbg.png", "images/common/checkbg.png")
	fightMenuBar:addChild(_checkBtn)
	_checkBtn:setAnchorPoint(ccp(0.5, 0.5))
	_checkBtn:setPosition(ccp(_bgSprite:getContentSize().width * 0.36, 40))
	_checkBtn:registerScriptTapHandler(checkCallback)
	refreshCheckTagSprite()
	
	local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8553"), g_sFontName, 21)
	_checkBtn:addChild(tip)
	tip:setAnchorPoint(ccp(0, 0.5))
	tip:setPosition(ccpsprite(1, 0.5, _checkBtn))
	tip:setColor(ccc3(0x78, 0x25, 0x00))
end

--[[
	@author:		bzx
	@desc:			刷新选择使用摇钱树的UI标识
	@return:	nil
--]]
function refreshCheckTagSprite( ... )
	if DataCache.isUseTreeFormation() == "1" then
		if _checkTagSprite == nil then
			_checkTagSprite = CCSprite:create("images/common/checked.png")
			_checkBtn:addChild(_checkTagSprite)
			_checkTagSprite:setAnchorPoint(ccp(0.5, 0.5))
			_checkTagSprite:setPosition(ccpsprite(0.5, 0.5, _checkBtn))
		end
	else
		if _checkTagSprite ~= nil then
			_checkTagSprite:removeFromParentAndCleanup(true)
			_checkTagSprite = nil
		end
	end
end

--[[
	@author:	bzx
	@desc:		摇钱树阵型回调
	@return:	nil
--]]
function formationCallback( ... )
	require "script/ui/copy/FormationSettingLayer"
	FormationSettingLayer.show(FormationSettingLayer.LayerType.GoldTree, -450, 1000)
end

--[[
	@author:		bzx
	@desc:			选择使用摇钱树阵型的回调
	@return:		nil
--]]
function checkCallback(p_tag, p_menuItem)
	if DataCache.getTreeFormationInfo() == nil then
		AnimationTip.showTip(GetLocalizeStringBy("key_8554"))
		return
	end
	if DataCache.isUseTreeFormation() ~= "1" then
		local args = Network.argsHandler("1")
		RequestCenter.copy_setBattleInfoValid(setBattleInfoValidCallback, args)
	else
		local args = Network.argsHandler("0")
		RequestCenter.copy_setBattleInfoValid(setBattleInfoValidCallback, args)
	end
end

--[[
	@author:		bzx
	@desc:			选择使用摇钱树阵型的网络回调
	@return:	nil
--]]
function setBattleInfoValidCallback( cbFlag, dictData, bRet )
	if not bRet then
		return 
	end
	if DataCache.isUseTreeFormation() ~= "1" then
		DataCache.setUseTreeFormation("1")
	else
		DataCache.setUseTreeFormation("0")
	end
	refreshCheckTagSprite()
end

-- 创建
function createLayer( copyInfo )
	init()
	_copyInfo = copyInfo
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()

	return _bgLayer
end
