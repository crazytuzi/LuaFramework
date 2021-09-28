
-- Filename：	FortInfoLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-9-22
-- Purpose：		据点的信息

module ("FortInfoLayer", package.seeall)



require "script/utils/LuaUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/copy/CopyUtil"
require "script/ui/copy/FortItemSprite"
require "script/ui/copy/Fight10Border"


local _bgLayer 			= nil
local _bgSprite 		= nil
local _copyInfo 		= nil
local _strongHoldInfo 	= nil
local _dropItems 		= {}			-- 掉落物品

local max_hard_lv		= nil			-- 当前可攻打的最大难度
local curBaseStars 		= nil			-- 当前据点所获得的星数
local curCopyId 		= nil	
local curFortId			= nil

local totalStars 		= 0 			-- 几颗心心
local _progressState 	= nil
local _bodyCost 		= nil
local _simpleSprite 	= nil

local _coolTimeLabelArr = {}
local _coolTitleArr 	= {}
local _coolCostLabelArr = {}
local hardBgSprite 		= nil
local _defeat_num 		= 0
local _displayDefeatNum = 0

local function init()
	_bgLayer 			= nil
	_bgSprite 			= nil
	_copyInfo 			= nil
	_strongHoldInfo 	= nil
	_dropItems 			= {}			-- 掉落物品
	max_hard_lv 		= nil
	curBaseStars 		= nil			-- 当前据点所获得的星数
	curCopyId 			= nil
	curFortId			= nil
	totalStars 			= 0 			-- 几颗心心
	_progressState 		= nil
	_bodyCost 			= nil
	_simpleSprite 		= nil
	_coolTimeLabelArr 	= {}
	_coolTitleArr 		= {}
	_coolCostLabelArr 	= {}
	hardBgSprite 		= nil
	_defeat_num 		= 0
	_displayDefeatNum 	= 0


end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		print("began fortinfoLayer")
		
	    return true
    elseif (eventType == "moved") then
    	
    else
        print("end")
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -410, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local isHaveTalk = false
-- 关闭
function closeAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 


-- 创建奖励
local function createRewardItems()
	-- local item_count = 0
	-- for k,v in pairs(_dropItems) do
	-- 	item_count = item_count + 1
	-- end
	
	local drop_height = 155
	if(#_dropItems > 5 )then
		drop_height = 280
	end

	local bgSpriteSize = _bgSprite:getContentSize()
	-- 掉落物品背景
	local bg_sprite_1 = CCScale9Sprite:create("images/common/bg/9s_1.png")
	bg_sprite_1:setContentSize(CCSizeMake(585, drop_height))
	bg_sprite_1:setAnchorPoint(ccp(0.5, 1))
	-- bg_sprite_1:setScale(MainScene.elementScale)
	bg_sprite_1:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 215))
	_bgSprite:addChild(bg_sprite_1)
	-- 掉落标题
	local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleSprite:setContentSize(CCSizeMake(200, 35))
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- titleSprite:setScale(MainScene.elementScale)
	titleSprite:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5, bg_sprite_1:getContentSize().height))
	bg_sprite_1:addChild(titleSprite)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1322"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
    titleSprite:addChild(titleLabel)

    local xPositionScale = {0.1, 0.3, 0.5, 0.7, 0.9, 0.1, 0.3, 0.5, 0.7, 0.9}
    local yPosition = {70, 70, 70, 70, 70, 200, 200, 200, 200, 200}
    
    -- 物品展示
    for index,item_tmpl_id in pairs(_dropItems) do
    	index = tonumber(index)
    	-- item_tmpl_id = 102322
    	local itemBtn = ItemSprite.getItemSpriteById(tonumber(item_tmpl_id), nil, nil, false, -420)
    	itemBtn:setAnchorPoint(ccp(0.5, 0.5))
    	itemBtn:setPosition(ccp(bg_sprite_1:getContentSize().width*xPositionScale[index], bg_sprite_1:getContentSize().height - yPosition[index]))
    	bg_sprite_1:addChild(itemBtn)

    	local itemDesc = ItemUtil.getItemById(item_tmpl_id)
    	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemDesc.quality)
    	local nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(ccp(itemBtn:getContentSize().width*0.5 - nameLabel:getContentSize().width*0.5, 0))
	    itemBtn:addChild(nameLabel)
	    print("物品名称",itemDesc.name)
	    print("物品id",item_tmpl_id)
    end

end


-- 创建三种难度
local function createHardDegree()

	local height = 400 - (3-totalStars) * 130
	local yDistance = 375
	
	if(#_dropItems > 5 )then
		yDistance = 500
	end

	if(_strongHoldInfo.reward_item_id_simple == nil) then
		yDistance = yDistance - 155
	end


	if(hardBgSprite)then
		hardBgSprite:removeFromParentAndCleanup(true)
		hardBgSprite = nil
	end

	hardBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	hardBgSprite:setContentSize(CCSizeMake(585, height))
	hardBgSprite:setAnchorPoint(ccp(0.5, 1))
	hardBgSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-yDistance))
	_bgSprite:addChild(hardBgSprite)

	_coolTimeLabelArr 	= {}

	local hardBgSpriteSize = hardBgSprite:getContentSize()
	for i=1, totalStars do
		local spriteTemp = FortItemSprite.createSprite( i, _strongHoldInfo, curBaseStars, _defeat_num )
		spriteTemp:setAnchorPoint(ccp(0.5, 1))
		spriteTemp:setPosition(ccp(hardBgSpriteSize.width*0.5, height - (3 + (i-1) * 130)) )
		hardBgSprite:addChild(spriteTemp)
		if(i == 1) then
			_simpleSprite = spriteTemp
		end

		if( (i - curBaseStars) <= 0 and DataCache.getSweepCoolTime() and (DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() ) > 0 )then
	    	-- 连战冷却
	    	local coolLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2266"), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    	coolLabel:setAnchorPoint(ccp(0.5, 0.5))
		    coolLabel:setColor(ccc3(0x8a, 0xff, 0x00))
		    coolLabel:setPosition(ccp( 350, 95))
		    spriteTemp:addChild(coolLabel,2)
	    	-- 倒计时
	    	local time_str = TimeUtil.getTimeString(DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() )

    		local collTimeDownLabel = CCLabelTTF:create(time_str, g_sFontName, 20)
			collTimeDownLabel:setColor(ccc3(0x24, 0xeb, 0xdb))
			collTimeDownLabel:setAnchorPoint(ccp(0.5, 0.5))
			collTimeDownLabel:setPosition(ccp(350, 65))
			spriteTemp:addChild(collTimeDownLabel,2)

			
			-- 金币图标
		    local goldSprite = CCSprite:create("images/common/gold.png")
		    goldSprite:setAnchorPoint(ccp(0,0))
		    goldSprite:setPosition(ccp(350, 15))
		    spriteTemp:addChild(goldSprite)
		    -- cd 花费
	    	local coolCostLabel = CCRenderLabel:create(CopyUtil.getGoldNumForSweepCd(), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    	coolCostLabel:setAnchorPoint(ccp(0, 0.5))
		    coolCostLabel:setColor(ccc3(0x8a, 0xff, 0x00))
		    coolCostLabel:setPosition(ccp( goldSprite:getContentSize().width, goldSprite:getContentSize().height*0.5))
		    goldSprite:addChild(coolCostLabel,2)


			table.insert(_coolTitleArr, coolLabel)
			table.insert(_coolTimeLabelArr, collTimeDownLabel)
			table.insert(_coolCostLabelArr, goldSprite )
		end
	end
	if( DataCache.getSweepCoolTime() and (DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() ) > 0 )then
		cdTimeFunc()
	end

end

-- 刷新
function cdTimeFunc()
	if((DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() ) >= 0)then
		local time_str = TimeUtil.getTimeString(DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() )
		
		local t_label = nil
		for k, coolLabel in pairs(_coolTimeLabelArr) do
			coolLabel:setString(time_str)
			t_label = coolLabel
		end
		if(t_label)then
			local actionArr = CCArray:create()
			actionArr:addObject(CCDelayTime:create(1))
			actionArr:addObject(CCCallFuncN:create(cdTimeFunc))
			t_label:runAction(CCSequence:create(actionArr))
		end
	else
		for k, coolLabel in pairs(_coolTimeLabelArr) do
			coolLabel:removeFromParentAndCleanup(true)
			coolLabel=nil
		end
		for k, coolLabel in pairs(_coolTitleArr) do
			coolLabel:removeFromParentAndCleanup(true)
			coolLabel=nil
		end
		for k, coolSpriteLabel in pairs(_coolCostLabelArr) do
			coolSpriteLabel:removeFromParentAndCleanup(true)
			coolSpriteLabel=nil
		end
		createHardDegree()
	end
end

local function gotoArray()
	require "script/ui/formation/MakeUpFormationLayer"
	MakeUpFormationLayer.showLayer()
end

-- 创建背景
local function createBgSprite()

	local drop_height = 155
	if(#_dropItems > 5 )then
		drop_height = 280
	end

	local height = 665 + drop_height - (3-totalStars) * 130

	if(_strongHoldInfo.reward_item_id_simple == nil) then
		height = height - drop_height
	end

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_bgSprite:setContentSize(CCSizeMake(630, height))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setScale(MainScene.elementScale)
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5-10))
	_bgLayer:addChild(_bgSprite)

	local bgSpriteSize = _bgSprite:getContentSize()

	-- 彩色sprite
	local t_sprite = CCSprite:create("images/copy/border.png")
	t_sprite:setAnchorPoint(ccp(0.5,1))
	t_sprite:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 15))
	_bgSprite:addChild(t_sprite)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-411)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.95, _bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	-- icon
	local copyFileLua = "db/cxmlLua/copy_" .. curCopyId
	require (copyFileLua)
	local pngIndex = nil
	for k,fortInfo in pairs(copy.models.normal) do
		-- print("baseid == " .. curFortId .. " , fortInfo.looks.look.armyID == " .. fortInfo.looks.look.armyID)
		if ( tonumber(curFortId) == tonumber(fortInfo.looks.look.armyID)) then
			pngIndex = string.sub(fortInfo.looks.look.modelURL, 1, 1)
			break
		end
	end
	local potentialSprite = CCSprite:create("images/copy/ncopy/fortpotential/" .. pngIndex .. ".png")
	potentialSprite:setAnchorPoint(ccp(0.5, 1))
	potentialSprite:setPosition(ccp(160, bgSpriteSize.height - 30))
	_bgSprite:addChild(potentialSprite)
	-- 图片 
	local icon_sp = CCSprite:create("images/base/hero/head_icon/" .. _strongHoldInfo.icon)
	icon_sp:setAnchorPoint(ccp(0.5, 0.5))
	icon_sp:setPosition(ccp(potentialSprite:getContentSize().width * 0.5, potentialSprite:getContentSize().height *0.53))
	potentialSprite:addChild(icon_sp)

	-- 名称背景
    local nameBgSprite = CCSprite:create("images/common/namebg.png" )
    nameBgSprite:setAnchorPoint(ccp(0.5, 1))
    nameBgSprite:setPosition(ccp(370, bgSpriteSize.height - 50))
    _bgSprite:addChild(nameBgSprite)
    --副本名称
    local baseNameLabel = CCRenderLabel:create(_strongHoldInfo.name, g_sFontPangWa, 33, 3, ccc3( 0x00, 0x00, 0x00), type_stroke)
    baseNameLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
    baseNameLabel:setPosition(ccp( (nameBgSprite:getContentSize().width - baseNameLabel:getContentSize().width)/2, 
    			(nameBgSprite:getContentSize().height - (nameBgSprite:getContentSize().height - baseNameLabel:getContentSize().height)/2) ))
    nameBgSprite:addChild(baseNameLabel)

	-- 星星背景
	local starBgSprite = CCSprite:create("images/common/line2.png" )
    starBgSprite:setAnchorPoint(ccp(0.5, 1))
    starBgSprite:setPosition(ccp(370, bgSpriteSize.height - 90))
    _bgSprite:addChild(starBgSprite)

    local deployBtn = CCMenuItemImage:create("images/formation/btn_deploy_n.png",  "images/formation/btn_deploy_h.png")
	deployBtn:setAnchorPoint(ccp(0.5, 0.5))
	deployBtn:setPosition(ccp(bgSpriteSize.width - 60,bgSpriteSize.height - 130))
	deployBtn:registerScriptTapHandler(gotoArray)
	closeMenuBar:addChild(deployBtn)

    for i=1,totalStars do
    	local starSprite = nil
    	if (curBaseStars < i) then
	    	starSprite = BTGraySprite:create("images/hero/star.png")
	    else
	    	starSprite = CCSprite:create("images/hero/star.png")
	    end
    	starSprite:setAnchorPoint(ccp(0.5, 0.5))
    	
    	if(totalStars == 1)then
    		starSprite:setPosition(ccp(starBgSprite:getContentSize().width/2 , starBgSprite:getContentSize().height * 0.5))
    	elseif(totalStars == 2)then
    		starSprite:setPosition(ccp(starBgSprite:getContentSize().width/2 - ( 1.5-i ) *starSprite:getContentSize().width* 1.1 , starBgSprite:getContentSize().height * 0.5))
    	else
    		starSprite:setPosition(ccp(starBgSprite:getContentSize().width/2 - ( 2-i ) *starSprite:getContentSize().width* 1.1 , starBgSprite:getContentSize().height * 0.5))
    	end

    	starBgSprite:addChild(starSprite)
    end

    -- 今日挑战次数
    local fightTimesLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1190") .. _displayDefeatNum .."/" ..  _strongHoldInfo.fight_times, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightTimesLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    fightTimesLabel:setAnchorPoint(ccp(0, 0.5))
    fightTimesLabel:setPosition(ccp( 120, bgSpriteSize.height - 170))
    _bgSprite:addChild(fightTimesLabel)

    -- 体力
	local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1299") .. _strongHoldInfo.cost_energy_simple, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    energyLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    energyLabel:setAnchorPoint(ccp(0, 0.5))
    --兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		energyLabel:setPosition(ccp( 450, bgSpriteSize.height - 170))
	else
    	energyLabel:setPosition(ccp( 420, bgSpriteSize.height - 170))
    end

    --兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) and (_strongHoldInfo.reward_item_id_simple == nil) then
		fightTimesLabel:setPosition(ccp(120,bgSpriteSize.height - 210))
		energyLabel:setPosition(ccp(450,bgSpriteSize.height - 210))
		potentialSprite:setPosition(ccp(160, bgSpriteSize.height - 70))
	end
    _bgSprite:addChild(energyLabel)

 --    local arrayFormationBT = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3297"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- arrayFormationBT:setAnchorPoint(ccp(0.5, 0.5))
 --    arrayFormationBT:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 80))
 --    arrayFormationBT:registerScriptTapHandler(gotoArray)
	-- closeMenuBar:addChild(arrayFormationBT)

end

-- 处理数据
local function handleData( )

	-- 据点信息
	_strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))

	-- 当前星数和难度
	if (_progressState <= 2) then
		max_hard_lv = 1
		curBaseStars = 0
	elseif (_progressState == 3) then
		max_hard_lv = 2
		curBaseStars = 1
	elseif (_progressState == 4) then
		max_hard_lv = 3
		curBaseStars = 2
	elseif (_progressState == 5) then
		max_hard_lv = 3
		curBaseStars = 3
	else
		max_hard_lv = 1
		curBaseStars = 0
	end

	-- 算总星星
	if(_strongHoldInfo.npc_army_ids_simple or _strongHoldInfo.army_ids_simple)then
		totalStars = totalStars + 1
	end
	if(_strongHoldInfo.army_num_normal)then
		totalStars = totalStars + 1
	end
	if(_strongHoldInfo.army_ids_hard)then
		totalStars = totalStars + 1
	end

	-- 
	_dropItems = {}
    if(_strongHoldInfo.reward_item_id_simple)then
		_dropItems = CopyUtil.parseItemDropString( _strongHoldInfo.reward_item_id_simple )
	end

end 

local function refreshFortsInfoLayer()
	require "script/ui/copy/CopyUtil"
	require "script/ui/copy/FortsLayout"
	local fortsLayer = FortsLayout.createFortsLayout(CopyUtil.getNormalFortsInfoBy(curCopyId))
	MainScene.changeLayer(fortsLayer, "fortsLayer")
end

-- 战10次回调
function fight10Callback( cbFlag, dictData, bRet )
	if(dictData.err == "ok" and dictData.ret) then

		if(dictData.ret.sweepcd)then

            DataCache.setSweepCoolTime(tonumber(dictData.ret.sweepcd))
            print("UserModel.setSweepCoolTime==",DataCache.getSweepCoolTime(), TimeUtil.getSvrTimeByOffset() , tonumber(dictData.ret.sweepcd))
        end
        DataCache.addDefeatNumByCopyAndFort( curCopyId, curFortId, -tonumber(_defeat_num) )
		UserModel.addEnergyValue(-_bodyCost)

		---------------------------------------- added by bzx
        require "script/ui/rechargeActive/ActiveCache"
        require "script/ui/shopall/MysteryMerchant/MysteryMerchantDialog"
        ActiveCache.MysteryMerchant:setCopyData(dictData.ret.mysmerchant)
        MysteryMerchantDialog.setShowed(false)
        ----------------------------------------
		local fight10Border = Fight10Border.createLayer(_strongHoldInfo.name, dictData.ret.reward, dictData.ret.extra_reward)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(fight10Border, 2001)
		closeAction()
	end
end

-- 战10次
function fight10Action( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 如果体力不够，则打当前能打的次数
	-- 当前选择副本消耗的体力单位
	local curCopyCastUnit = nil
	selectedHardLevel = tag - 20000
	if ( selectedHardLevel == 1 ) then
		curCopyCastUnit = _strongHoldInfo.cost_energy_simple
	elseif( selectedHardLevel == 2 ) then
		curCopyCastUnit = _strongHoldInfo.cost_energy_normal
	elseif( selectedHardLevel == 3 ) then
		curCopyCastUnit = _strongHoldInfo.cost_energy_hard
	end
	local defeat_num = _defeat_num
	_bodyCost = curCopyCastUnit * defeat_num
	if(_bodyCost > UserModel.getEnergyValue()) then
		-- 如果体力不足，就只扫荡当前体力可扫荡的次数
		defeat_num = math.floor(UserModel.getEnergyValue() / curCopyCastUnit)
		-- 如果可扫荡次数为0，提示玩家吃体力丹
		if (defeat_num == 0) then
			require "script/ui/item/EnergyAlertTip"
			EnergyAlertTip.showTip(FortsLayout.refreshExpAndEnergy)
			return
		end
		_defeat_num = defeat_num
		_bodyCost = _defeat_num * curCopyCastUnit
	end
	require "script/ui/hero/HeroPublicUI"
	if(ItemUtil.isBagFull() == true)then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		return
	elseif HeroPublicUI.showHeroIsLimitedUI() then
		return
	elseif(UserModel.getHeroLevel() < 30 )then
		AnimationTip.showTip(GetLocalizeStringBy("key_1906"))
		return
	elseif(_defeat_num<=0)then
		AnimationTip.showTip(GetLocalizeStringBy("key_3028"))
		return
	end
	local args = Network.argsHandler(curCopyId, curFortId, selectedHardLevel, _defeat_num)
	RequestCenter.copy_sweep(fight10Callback, args)
end

-- 战斗回调
function doBattleCallback( newData, isVictory, extra_reward, extra_info )
	
    --------------------------------------- added by bzx 把神秘商人的商品信息保存起来
    require "script/ui/shopall/MysteryMerchant/MysteryMerchantDialog"
    local extra_info_not_empty = not table.isEmpty(extra_info)
    if extra_info_not_empty == true then
        local mysmerchant_not_empty = not table.isEmpty(extra_info.mysmerchant)
        if extra_info_not_empty and mysmerchant_not_empty then
            MysteryMerchantDialog.setShowed(false)
            ActiveCache.MysteryMerchant:setCopyData(extra_info.mysmerchant)
        end
    end
    ---------------------------------------
	local isHadVictory = CopyUtil.isStrongHoldIsVict(curFortId)

	require "script/utils/LuaUtil"
	
	-- 全局掉落
	if(not table.isEmpty(extra_reward))then
		CopyUtil.showExtraReward(extra_reward)
    ---------------------------------------- added by bzx
    else
        MysteryMerchantDialog.checkAndShow()
    ----------------------------------------
    end
	if(isVictory and (not isHadVictory)) then
		-- 对话
	    if(_strongHoldInfo.victor_dialog_id and tonumber(_strongHoldInfo.victor_dialog_id) > 0 and (not CopyUtil.isFortIdVicHadDisplay(_strongHoldInfo.id)))then
	    	
	    	CopyUtil.addHadVicDialogFortId(curFortId)
	    	require "script/ui/talk/talkLayer"
		    local talkLayer = TalkLayer.createTalkLayer(_strongHoldInfo.victor_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10000)
		    TalkLayer.setCallbackFunction(TalkOverCallback)
		    isHaveTalk = true
	    end
	    DataCache.addDefeatNumByCopyAndFort( curCopyId, curFortId, -1 )
	else
		-- 对话
	    if( (not isHadVictory) and _strongHoldInfo.fail_dialog_id and tonumber(_strongHoldInfo.fail_dialog_id) > 0 and (not CopyUtil.isFortIdFailHadDisplay(_strongHoldInfo.id)))then
	    	CopyUtil.addHadFailDialogFortId(_strongHoldInfo.id)
	    	require "script/ui/talk/talkLayer"
		    local talkLayer = TalkLayer.createTalkLayer(_strongHoldInfo.fail_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10000)
		    TalkLayer.setCallbackFunction(TalkOverCallback)
		    isHaveTalk = true
	    end
	end

	if (newData) then
		CopyUtil.hanleNewCopyData(newData)
	end
	closeAction()
	refreshFortsInfoLayer()
	if(isHaveTalk == false) then
		TalkOverCallback()
	end
end

-- 重置cd回调
function resetSweepCdCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok" and dictData.ret)then
		UserModel.addGoldNumber(-CopyUtil.getGoldNumForSweepCd())
		DataCache.addClearSweepNum(1)
		DataCache.setSweepCoolTime(-1)
	end
end

-- 是否确认reset
function confirmCBFunc( isConfirm )
	if(isConfirm == true)then
		if( UserModel.getGoldNumber() >= CopyUtil.getGoldNumForSweepCd() )then
			RequestCenter.copy_clearSweepCd(resetSweepCdCallback)
		else
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
		end

	end
end

-- 重置cd
function resetSweepCdAction()
	if((DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() ) >= 0)then
		local tipText = GetLocalizeStringBy("key_1957") .. CopyUtil.getGoldNumForSweepCd() .. GetLocalizeStringBy("key_1082")
		AlertTip.showAlert( tipText, confirmCBFunc, true)
	end
end

-- 重置攻打次数回调
function resetAtkTimesDelegate()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

	local fortInfoLayer = FortInfoLayer.createLayer(curCopyId, curFortId, _progressState, _strongHoldInfo.fight_times)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(fortInfoLayer, 99)
end

-- 战斗
function fightAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[等级礼包新手引导清除
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	require "script/guide/LevelGiftBagGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 20) then
		LevelGiftBagGuide.cleanLayer()
	end
	if(NewGuide.guideClass == ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 22) then
		LevelGiftBagGuide.cleanLayer()
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		BTUtil:setGuideState(false)
		NewGuide.saveGuideClass()
	end
	---------------------end-------------------------------------
	--]==]

	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
    	GeneralUpgradeGuide.cleanLayer()
    end
    

	require "script/ui/hero/HeroPublicUI"
	if(ItemUtil.isBagFull() == true)then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		return
	elseif HeroPublicUI.showHeroIsLimitedUI() then
		return
	elseif(tonumber(_defeat_num)<=0)then
		-- AnimationTip.showTip(GetLocalizeStringBy("key_2302"))
		require "script/ui/copy/FortDefeatNUmTip"  
		FortDefeatNUmTip.showAlert( curCopyId, curFortId, _strongHoldInfo.fight_times, resetAtkTimesDelegate)
		return
	end
			
	local costBody = 0
	selectedHardLevel = tag - 10000
	if ( selectedHardLevel == 1 ) then
		costBody = _strongHoldInfo.cost_energy_simple
	elseif( selectedHardLevel == 2 ) then
		costBody = _strongHoldInfo.cost_energy_normal

	elseif( selectedHardLevel == 3 ) then
		costBody = _strongHoldInfo.cost_energy_hard
	end

	if(costBody > UserModel.getEnergyValue()) then
		require "script/ui/item/EnergyAlertTip"
		EnergyAlertTip.showTip(FortsLayout.refreshExpAndEnergy)
	else
		require "script/battle/BattleLayer"
		require "script/ui/copy/FortsLayout"
		local battleLayer = BattleLayer.enterBattle(curCopyId, curFortId, selectedHardLevel, doBattleCallback)
	end
end

--[[
	@desc	创建
	@para 	hardLevel 1/2/3  简单/普通/困难
			progressState的取值：0可显示 1可攻击 2npc通关 3简单通关 4普通通关 5困难通关
	@return FortInfoLayer
--]]
function createLayer(copy_id,fortId,progressState, defeat_num)
	-- _copyInfo = copyInfo
	print("copy_id,fortId,progressState==",copy_id,fortId,progressState, defeat_num)

	init()
	_progressState = tonumber(progressState)
	_defeat_num = tonumber(defeat_num)
	_displayDefeatNum = tonumber(defeat_num)

	if(_displayDefeatNum>10)then
		_defeat_num = 10
	end
	curCopyId = copy_id
	curFortId = fortId
	
	handleData()

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 创建背景
	createBgSprite()
	if(_strongHoldInfo.reward_item_id_simple) then
		-- 掉落物品
		createRewardItems()
	end
	
	-- 创建三种难度
	createHardDegree()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		createDidAddNewGuide()
	end))
	_bgLayer:runAction(seq)

	return _bgLayer
end

-- 新手引导用
function getGuideObject( )
	local menuBar = tolua.cast(_simpleSprite:getChildByTag(1002), "CCMenu")
	local fightBtn = tolua.cast(menuBar:getChildByTag(10001), "CCMenuItemSprite")
	return fightBtn
end

--add by lichenyang
function TalkOverCallback( ... )

	-- add by chengliang
	require "script/ui/copy/ShowNewCopyLayer"
	ShowNewCopyLayer.showNewCopy()

	isHaveTalk = false

	require "script/guide/CopyBoxGuide"
	if(CopyUtil.isFirstPassCopy_1 == true) then
		CopyBoxGuide.CopyFirstDidOver()
	end

	print("post TalkOverCallback NC_FightOver")

	-- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local actionNode   = CCNode:create()
	runningScene:addChild(actionNode)

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addNewGuide()
		actionNode:removeFromParentAndCleanup(true)
	end))
	actionNode:runAction(seq)
end



function addNewGuide( ... )


		---[==[ 等级礼包第21步 第6个据点
     ---------------------新手引导---------------------------------
     --add by licong 2013.09.09
     require "script/guide/NewGuide"
     require "script/guide/LevelGiftBagGuide"
     print("LevelGiftBagGuide.stepNum = ", LevelGiftBagGuide.stepNum )
     print("LevelGiftBagGuide.fightTimes = ",LevelGiftBagGuide.fightTimes)
     if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 20 and LevelGiftBagGuide.fightTimes == 1) then
     	require "script/ui/copy/FortsLayout"
        local levelGiftBagGuide_button = FortsLayout.getGuideObject()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(21, touchRect)
     end
     ---------------------end-------------------------------------
     --]==]
end


function createDidAddNewGuide( ... )
	print("createDidAddNewGuide")
			---[==[ 等级礼包第22步 第6个据点战斗面板
    ---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    require "script/guide/NewGuide"
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 21 and LevelGiftBagGuide.fightTimes == 1) then
        require "script/ui/copy/FortInfoLayer"
        local levelGiftBagGuide_button = FortInfoLayer.getGuideObject()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(22, touchRect)
    end
    ---------------------end-------------------------------------
	--]==]

end

