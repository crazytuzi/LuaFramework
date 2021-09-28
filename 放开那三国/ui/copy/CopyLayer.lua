-- Filename：	CopyLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-5-22
-- Purpose：		副本的入口

module ("CopyLayer", package.seeall)

require "script/network/RequestCenter"
require "script/ui/copy/FortsLayout"

require "script/model/DataCache"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"


require "script/ui/tip/AnimationTip"
require "script/ui/copy/CopyUtil"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/ui/copy/EliteBorder"

require "script/ui/copy/CopyService"
require "script/battle/BattleLayer"
require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyData"    --增加英雄天命 2016.5.27 zhangqiang
local IMG_PATH = "images/common/"	
local COPY_PATH = "images/copy/"
local bgLayer 
local myTableView 

local canDefeatNumBg = nil

local title_item = {GetLocalizeStringBy("key_2748"), GetLocalizeStringBy("key_3015"), GetLocalizeStringBy("key_2380")}
local menu										-- 按钮Menu

Elite_Copy_Tag	= 1001					--精英副本
Normal_Copy_Tag	= 1002					--普通副本
Active_Copy_Tag	= 1003					--活动副本

local curCopyTag = Normal_Copy_Tag 				--当前副本

local data = {} 								--副本的数据源
local testMax = 20


local visiableCellNum									--当前机型可视的cell个数
local curDisplayCopyIndex = 1							--玩家当前所处的副本 从1开始
local maxDisplayCopyIndex = curDisplayCopyIndex + 2 	--显示的最大副本Index
local minDisplayCopyIndex								--显示的最小副本Index，以及初始时将要滑动的位置 从1开始 

local isNeedCellAnimate   = true 
local eliteBtn_guide = nil


local lastNormalCopyContentOffset = nil 		-- 最后一次点击时的contentOffset

local _curACopyId = nil

local _eliteTipSprite = nil 					-- 精英副本的提示气泡
local _activeTipSprite = nil					-- 活动副本的提示气泡

--add by lichenyang

local didCreateTableViewFunc = nil
local didClickCopyCell 		 = nil
--end

local _numLabel									-- 显示精英副本的次数 aded by zhz 

function init()
	myTableView = nil
	_curACopyId = nil
	_numLabel	= nil
end



--[[
	@desc	计算实际可显示的最大和最小副本index
	@para 	void
	@return void
--]]
local function setMaxMinDisplayIndex( ... )
	if (#data < visiableCellNum) then
		minDisplayCopyIndex = 1
		maxDisplayCopyIndex = #data
	else
		maxDisplayCopyIndex = curDisplayCopyIndex + 2
		if (maxDisplayCopyIndex > #data) then
			maxDisplayCopyIndex = #data
		end
		minDisplayCopyIndex = maxDisplayCopyIndex - visiableCellNum + 1
		if (minDisplayCopyIndex < 1) then
			minDisplayCopyIndex = 1
			maxDisplayCopyIndex = 5
		end
	end
end 

--[[
	@desc	滑动到指定的Cell
	@para 	LuaTableView tTableView
			int tIndex 				--从1开始
			float tCellHeight
	@return void
--]]
local function scrollToIndex( tTableView, tIndex, tCellHeight)
	local contentOffset = tTableView:getContentOffset().y + (tIndex-1) * tCellHeight
	if (contentOffset > 0 ) then				--当滑动到的cell为整个Table最后几个cell时需要特殊处理
		contentOffset = 0			
	end
	if (#data < visiableCellNum) then			--当data的长度小于可显示的个数时需要特殊处理
		contentOffset = (visiableCellNum - #data -1) * tCellHeight
	end
	
	tTableView:setContentOffset(ccp(0, contentOffset))
end


-- 创建信息
function createCanDefeatNum()
	removeCanDefeatNum( )
	canDefeatNumBg = CCScale9Sprite:create("images/copy/ecopy/lefttimesbg.png")
	canDefeatNumBg:setAnchorPoint(ccp(0.5,0))
	canDefeatNumBg:setContentSize(CCSizeMake(240, 55) )
	canDefeatNumBg:setPosition(ccp(bgLayer:getContentSize().width*0.5, 11.5))--canDefeatNumBg:getContentSize().height*0.5))
	bgLayer:addChild(canDefeatNumBg, 10)

	local canDefeatSize = canDefeatNumBg:getContentSize()

	-- 今日剩余次数
	local pLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1373"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    pLabel:setColor(ccc3(0xff, 0xff, 0xff))
    pLabel:setPosition(ccp(canDefeatSize.width*0.1, canDefeatSize.height*0.5+pLabel:getContentSize().height*0.5))
    canDefeatNumBg:addChild(pLabel)
    local number = 0
    if(DataCache.getEliteCopyData().can_defeat_num) then
    	number = DataCache.getEliteCopyData().can_defeat_num
    end
    -- 次数 change by zhz
    _numLabel = CCRenderLabel:create(number, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _numLabel:setColor(ccc3(0x36, 0xff, 0x00))
    _numLabel:setPosition(ccp(pLabel:getContentSize().width + canDefeatSize.width*0.1, canDefeatSize.height*0.5+_numLabel:getContentSize().height*0.4))
    canDefeatNumBg:addChild(_numLabel)

    -- zuihou
    local tiemLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3010"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    tiemLabel:setColor(ccc3(0xff, 0xff, 0xff))
    tiemLabel:setPosition(ccp(pLabel:getContentSize().width + canDefeatSize.width*0.1 +_numLabel:getContentSize().width , canDefeatSize.height*0.5+tiemLabel:getContentSize().height*0.5))
    canDefeatNumBg:addChild(tiemLabel)

    -- 增加次数的按钮
    local menuBar= CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    canDefeatNumBg:addChild(menuBar)

    local addAtkBtn = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
    addAtkBtn:setPosition(ccp(canDefeatNumBg:getContentSize().width -8 , canDefeatNumBg:getContentSize().height/2 ))
    addAtkBtn:setAnchorPoint(ccp(1,0.5))
    addAtkBtn:registerScriptTapHandler(addAtkAction)
    menuBar:addChild(addAtkBtn)

end

function removeCanDefeatNum( )
	if(canDefeatNumBg)then
		canDefeatNumBg:removeFromParentAndCleanup(true)
		canDefeatNumBg = nil
	end
end

-- 刷新 added by zhz
function refreshCanDefeatNum( ... )
	local number = 0
    if(DataCache.getEliteCopyData().can_defeat_num) then
    	number = DataCache.getEliteCopyData().can_defeat_num
    end
	_numLabel:setString("" .. number)


	-- 刷新副本小提示
	refreshCopyTip()


end

function addAtkAction( ... )

	-- if( DataCache.getEliteCopyData().can_defeat_num >0) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_1607"))
	-- 	return
	-- end
	require "script/ui/tip/BuyCopyAtkLayer"

	BuyCopyAtkLayer.showLayer( 1, DataCache.getEliteCopyData().buy_atk_num ,updateAfterSweep )
end

--[[
	@desc	显示选中的副本中据点的信息
	@para 	table fortData 据点的信息
	@return void
--]]
local function showLayoutsByFort( fortData )
	-- 铁匠铺 引导结束
	---[==[铁匠铺 清除新手引导
	---------------------新手引导---------------------------------
	--add by licong 2013.09.26
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideSmithy) then
		require "script/guide/EquipGuide"
		EquipGuide.cleanLayer()
		NewGuide.guideClass = ksGuideClose
		BTUtil:setGuideState(false)
		NewGuide.saveGuideClass()
	end
	---------------------end-------------------------------------
	--]==]

	---[==[副本箱子新手引导清除引导 结束引导
	---------------------新手引导---------------------------------
		--add by licong 2013.09.06
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideCopyBox) then
			require "script/guide/CopyBoxGuide"
			CopyBoxGuide.cleanLayer()
			NewGuide.guideClass = ksGuideClose
			NewGuide.saveGuideClass()
			BTUtil:setGuideState(false)
		end
	---------------------end-------------------------------------
	--]==]

	---[==[强化所新手引导清除引导
	---------------------新手引导---------------------------------
		--add by licong 2013.09.06
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideForge) then
			require "script/guide/StrengthenGuide"
			StrengthenGuide.cleanLayer()
		end
	---------------------end-------------------------------------
	--]==]

	---[==[等级礼包新手引导清除
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift) then
		require "script/guide/LevelGiftBagGuide"
		LevelGiftBagGuide.cleanLayer()
	end
	---------------------end-------------------------------------
	--]==]

	--进阶引导
	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
        GeneralUpgradeGuide.cleanLayer()
    end
	
	-- 增加方法调用前判断 2013.09.08 k
	if(didClickCopyCell~=nil)then
		didClickCopyCell()
	end
	print("createFortsLayout")
	local fortsLayer = FortsLayout.createFortsLayout(fortData)
	MainScene.changeLayer(fortsLayer, "fortsLayer")

end

--[[
 @desc	战斗回调
 @para 	
 @return
 --]]
function doBattleCallback( newData, isVictory, extra_reward )

	print("copylayer  isVictory....==", isVictory)
	if (newData) then
		CopyUtil.hanleNewCopyData(newData)
	end
	if( curCopyTag == Elite_Copy_Tag and isVictory == true )then

		-- DataCache.addCanDefatNum(-1)
		data = DataCache.getEliteCopyData()
		createCanDefeatNum()
	end

	if( curCopyTag == Active_Copy_Tag )then
		if(_curACopyId == 300001)then
			DataCache.addGoldTreeDefeatNum(-1)
		end
		if(_curACopyId == 300002 and isVictory == true)then
			DataCache.addTreasureExpDefeatNum(-1)
		end
		if(_curACopyId == 300004 and isVictory == true)then
			DataCache.addHeroExpDefeatNum(-1)
		end
		if(_curACopyId == HeroDestineyCopyData.kHeroDestineyTid and isVictory == true)then
			HeroDestineyCopyData.addLeftAtkNum(-1)
		end
		data = DataCache.getActiveCopyData()
	end
	if( curCopyTag == Normal_Copy_Tag )then
		data = DataCache.getNormalCopyData()
	end

	-- 全局掉落
	if(not table.isEmpty(extra_reward))then
		
		CopyUtil.showExtraReward(extra_reward)
	end
	-- 刷新副本的提示气泡
	refreshCopyTip()

	refreshMyTableView()
end


-- 摇钱树回调
function goldTreeCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		-- 是否免费挑战摇钱树
		local isFree = CopyUtil.isFreeToAtkGoldTree()
		if(isFree)then

			if(DataCache.getGoldTreeDefeatNum()>0)then
				-- 先减免费次数
				DataCache.addGoldTreeDefeatNum(-1)
			else
				 
			end
		else
			DataCache.addAtkGoldTreeByUseGoldNum(1)
			-- 扣除挑战所花费的金币
			require "script/ui/copy/GoldTreeBorder"
			UserModel.addGoldNumber( -GoldTreeBorder._curTimeCost )
		end
		--先计算获得银币
		local add_siliver = dictData.ret.reward and dictData.ret.reward.silver or 0
		local hurt_num = dictData.ret.hurt or 0
		UserModel.addSilverNumber(tonumber(add_siliver))
		--在计算经验加成
		DataCache.addBossTreeExp(tonumber(dictData.ret.newcopyorbase.add_exp))
		data = DataCache.getActiveCopyData()
		
		-- refreshMyTableView()
		local actionArr = CCArray:create()
		actionArr:addObject(CCDelayTime:create(0.5))
		actionArr:addObject(CCCallFuncN:create(refreshMyTableView))
		bgLayer:runAction(CCSequence:create(actionArr))



		require "script/ui/copy/AfterTreeBoss"
		require "script/ui/common/CafterBattleLayer"
		require "db/DB_Stronghold"
		local strongholdInfo = DB_Stronghold.getDataById(300001)
		require "db/DB_Activitycopy"
		local m_copyInfo = DB_Activitycopy.getDataById(300001)
		UserModel.addEnergyValue(-m_copyInfo.attack_energy)

		--摇钱树结算面板
		local afterBattleLayer = AfterTreeBoss.creteAfterTreeBossLayer(hurt_num, add_siliver, nil,dictData.ret.newcopyorbase.add_exp)
		--摇钱树显示ui
		local treeLevel = DataCache.getTreeBossLevel()
		local treeExp   = DataCache.getTreeBossExp()
		require "script/battle/PlayerMoneyTreeLayer"
		local onBattleView 	   = PlayerMoneyTreeLayer.createMoneyTreeLayer(strongholdInfo.army_ids_simple, treeLevel, treeExp)
       
		BattleLayer.showBattleWithString(dictData.ret.fightRet, nil, afterBattleLayer, "ducheng.jpg", nil, strongholdInfo.army_ids_simple, onBattleView, true, false, BattleLayer.kMoneyTree)


		-- 刷新副本小提示
		refreshCopyTip()
	end
end

--[[
	@desc	副本tableView的创建
	@para 	none
	@return void
--]]
local function createCopyTableView( ... )
	if ( myTableView ) then
		myTableView:removeFromParentAndCleanup(true)
		myTableView = nil
	end
	if(curCopyTag == Elite_Copy_Tag and DataCache.getSwitchNodeState(  ksSwitchEliteCopy  ))then
		createCanDefeatNum()
	else
		removeCanDefeatNum()
	end
	
	local isFirstDisplay = true 				--标记tableView是否第一次显示
	local animateDisplayTimes = 0				--已经播放了几个cell的动画	
	local cellBg = CCSprite:create("images/copy/copyframe.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

    local myScale = bgLayer:getContentSize().width/cellBg:getContentSize().width/bgLayer:getElementScale()

	visiableCellNum = math.floor(bgLayer:getContentSize().height*0.885/bgLayer:getElementScale() /cellSize.height) + 1 --计算可视的有几个cell
	setMaxMinDisplayIndex()

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			local FileLua = nil

			-- 不得已而为之 三种不同的形式副本的处理
			if (curCopyTag == Elite_Copy_Tag) then
				FileLua = "script/ui/copy/ECopyCell"
			elseif (curCopyTag == Normal_Copy_Tag) then
				FileLua = "script/ui/copy/CopyCell"
			elseif (curCopyTag == Active_Copy_Tag) then
				FileLua = "script/ui/copy/ACopyCell"
			end
			package.loaded[FileLua] = nil
			require (FileLua)
			a2 = CopyCell.createCopyCell(data[a1 +1 ], a1 +1, false)
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #data
		elseif fn == "cellTouched" then
			
			print("cellTouched:dddd " .. (a1:getIdx() + 1))
            require "script/ui/hero/HeroPublicUI"
            local tempCopyInfo = data[a1:getIdx() + 1]
            if((curCopyTag == Active_Copy_Tag and tempCopyInfo.copyInfo.id == 300001))then

            else
            	if(ItemUtil.isBagFull() == true )then
					return
				elseif HeroPublicUI.showHeroIsLimitedUI() then
	                return
				end
            end
			
			if ( curCopyTag == Normal_Copy_Tag ) then
				if( tempCopyInfo.isGray and tempCopyInfo.isGray==true )then
					AnimationTip.showTip(GetLocalizeStringBy("key_1423") ..CopyUtil.getOpenNCopyCondition(tempCopyInfo) )
				else
					showLayoutsByFort(tempCopyInfo)
					lastNormalCopyContentOffset = myTableView:getContentOffset()
				end
				
			elseif (curCopyTag == Elite_Copy_Tag) then
				if (tempCopyInfo.copyInfo.status == 0) then
					AnimationTip.showTip(GetLocalizeStringBy("key_3419") .. CopyUtil.getOpenCondition(tempCopyInfo.copyInfo.id) .. GetLocalizeStringBy("key_1292"))
					return
				end
				if(UserModel.getEnergyValue() < tempCopyInfo.copyInfo.energy)then
					-- AnimationTip.showTip(GetLocalizeStringBy("key_2702") .. tempCopyInfo.copyInfo.energy .. GetLocalizeStringBy("key_2927"))
					require "script/ui/item/EnergyAlertTip"
					EnergyAlertTip.showTip()
					return
				end
				
					
				---[==[精英副本 新手引导屏蔽层
				---------------------新手引导---------------------------------
				--add by licong 2013.09.26
				require "script/guide/NewGuide"
				if(NewGuide.guideClass == ksGuideEliteCopy) then
					require "script/guide/EliteCopyGuide"
					EliteCopyGuide.changLayer()
				end
				---------------------end-------------------------------------
				--]==]
				local eliteBorderLayer = EliteBorder.createLayer(tempCopyInfo)

				local runningScene = CCDirector:sharedDirector():getRunningScene()
    			runningScene:addChild(eliteBorderLayer, 999)
				
			elseif (curCopyTag == Active_Copy_Tag) then
				if(tempCopyInfo.copyInfo.id == 300001 )then
					-- 摇钱树
					if(tempCopyInfo.copyInfo.limit_lv and tempCopyInfo.copyInfo.limit_lv>UserModel.getHeroLevel())then
						AnimationTip.showTip(GetLocalizeStringBy("key_2398") .. tempCopyInfo.copyInfo.limit_lv .. GetLocalizeStringBy("key_1526"))
						return
					end
					
					require "script/ui/copy/GoldTreeBorder"
					local goldTreeBorder = GoldTreeBorder.createLayer( tempCopyInfo )
					local runningScene = CCDirector:sharedDirector():getRunningScene()
	    			runningScene:addChild(goldTreeBorder, 999)
	    			_curACopyId = 300001
				elseif(tempCopyInfo.copyInfo.id == 300002)then
					-- 
					if(tempCopyInfo.copyInfo.limit_lv and tempCopyInfo.copyInfo.limit_lv>UserModel.getHeroLevel())then
						AnimationTip.showTip(GetLocalizeStringBy("key_3031") .. tempCopyInfo.copyInfo.limit_lv .. GetLocalizeStringBy("key_1526"))
						return
					end
					if(UserModel.getEnergyValue() < tempCopyInfo.copyInfo.attack_energy)then
						require "script/ui/item/EnergyAlertTip"
						EnergyAlertTip.showTip()
						return
					end
					if(tonumber(tempCopyInfo.can_defeat_num)>0)then

						local battleLayer = BattleLayer.enterBattle(tempCopyInfo.copyInfo.id, tempCopyInfo.copyInfo.fort_ids, 0, CopyLayer.doBattleCallback, 3)
					else
						AnimationTip.showTip(GetLocalizeStringBy("key_3036"))
					end
					_curACopyId = 300002
				elseif(tempCopyInfo.copyInfo.id == 300004)then
					-- 经验熊猫
					if(tempCopyInfo.copyInfo.limit_lv and tempCopyInfo.copyInfo.limit_lv>UserModel.getHeroLevel())then
						AnimationTip.showTip(GetLocalizeStringBy("key_2287") .. tempCopyInfo.copyInfo.limit_lv .. GetLocalizeStringBy("key_1526"))
						return
					end
					if(CopyUtil.isHeroExpCopyOpen() == false)then
						return
					end

					if HeroPublicUI.showHeroIsLimitedUI() then
		                return
					end
					if(UserModel.getEnergyValue() < tempCopyInfo.copyInfo.attack_energy)then
						require "script/ui/item/EnergyAlertTip"
						EnergyAlertTip.showTip()
						return
					end
					if(DataCache.getHeroExpDefeatNum()>0)then

						local battleLayer = BattleLayer.enterBattle(tempCopyInfo.copyInfo.id, tempCopyInfo.copyInfo.fort_ids, 0, CopyLayer.doBattleCallback, 3)
					else
						AnimationTip.showTip(GetLocalizeStringBy("key_2428"))
					end
					_curACopyId = 300004
				elseif(tempCopyInfo.copyInfo.id == 300005)then
					
					if(tempCopyInfo.copyInfo.limit_lv and tempCopyInfo.copyInfo.limit_lv>UserModel.getHeroLevel())then
						AnimationTip.showTip(GetLocalizeStringBy("cl_1025") .. tempCopyInfo.copyInfo.limit_lv .. GetLocalizeStringBy("key_1526"))
						return
					end
					if DataCache.getSwitchNodeState(ksExpCopy, true) then
						require "script/ui/copy/expcopy/ExpCopyLayer"
						ExpCopyLayer.show()
					end
				elseif(tempCopyInfo.copyInfo.id == HeroDestineyCopyData.kHeroDestineyTid) then   --增加英雄天命 2016.5.27 zhangqiang
					local nOpen, sDesc = HeroDestineyCopyData.isOpen()
					if nOpen ~= 0 then
						AnimationTip.showTip(sDesc)
						return
					end

					local nCopyId = tempCopyInfo.copyInfo.id
					local nBaseId = tempCopyInfo.copyInfo.fort_ids

					require "db/DB_Stronghold"
					local tbBase = DB_Stronghold.getDataById(nBaseId)
					local nAmyId = tbBase.army_ids_simple
					local battleLayer = BattleLayer.enterBattle(nCopyId, nBaseId, nAmyId, CopyLayer.doBattleCallback, 3)

					_curACopyId = HeroDestineyCopyData.kHeroDestineyTid
				end
			end
		elseif (fn == "scroll") then


		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, CCSizeMake(bgLayer:getContentSize().width/bgLayer:getElementScale(),bgLayer:getContentSize().height*0.885/bgLayer:getElementScale()))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	bgLayer:addChild(myTableView)


	-- 精英副本 第3步
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addGuideEliteCopyGuide3()
	end))
	bgLayer:runAction(seq)

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addNewGuide()
	end))
	bgLayer:runAction(seq)

	-- 增加方法调用前判断 2013.09.08 k
	if(didCreateTableViewFunc~=nil)then
		--add by lichenyang  -- add new Guide
		local newGuideAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(didCreateTableViewFunc))
		bgLayer:runAction(newGuideAction)
	end

	-- 普通副本
	if( curCopyTag == Normal_Copy_Tag and lastNormalCopyContentOffset and #data > 5)then
		isNeedCellAnimate = false
		myTableView:setContentOffset(lastNormalCopyContentOffset) 
	end

	if ( isNeedCellAnimate == true ) then
		local maxAnimateIndex = 5
		if (maxAnimateIndex > #data) then
			maxAnimateIndex = #data
		end
		for i=1, maxAnimateIndex do
			local officerCell = myTableView:cellAtIndex(#data - i)
			if (officerCell) then
				local cellBg = tolua.cast(officerCell:getChildByTag(1), "CCSprite")
				cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
				cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * i ,ccp(0,0)))
			end
		end
	end
	
	-- 重新修改
	isNeedCellAnimate = true

end

-- 刷新Tableview
function refreshMyTableView()
	if(myTableView)then
		local contentOffset = myTableView:getContentOffset() 
		myTableView:reloadData()
		myTableView:setContentOffset(contentOffset) 
	end
end

-- 通过idnex： ，完整的刷新tableView， index:1,2,3:对应:精英副本，普通副本， 活动副本
function refreshViewByIndex( index)
	if( index==1) then
		data = DataCache.getEliteCopyData()
	elseif(index==2) then
		data = DataCache.getNormalCopyData()
	elseif(index == 3) then
		data= DataCache.getActiveCopyData()
	end	
	refreshMyTableView()
end

-- 刷新活动副本的tableView added by zhz 
function refreshACopyView( ... )
	
	refreshViewByIndex(3)
	
	-- 刷新副本小提示
	refreshCopyTip()
end
--[[
	@desc	精英副本扫荡后刷新界面
	@para 	
	@return
--]]
function updateAfterSweep( ... )
	refreshCanDefeatNum()
	refreshMyTableView()
end

--[[
	@desc	副本按钮切换的Action
	@para 	tag， menuItem
	@return void
--]]
function itemMenuAction( tag, menuItem )
	---[==[精英副本 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.26
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideEliteCopy) then
		require "script/guide/EliteCopyGuide"
		EliteCopyGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	menuItem:selected()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	if( tag ~= curCopyTag) then
		local preMenuItem = tolua.cast(menu:getChildByTag(curCopyTag), "CCMenuItem")
		preMenuItem:unselected()
		curCopyTag = tag
		
		data = {}
		if (tag == Elite_Copy_Tag) then
			data = DataCache.getEliteCopyData()
			if(DataCache.getSwitchNodeState(  ksSwitchEliteCopy  ) ~= true) then
				-- AnimationTip.showTip(GetLocalizeStringBy("key_1425"))
			elseif ( table.isEmpty(data)) then
				RequestCenter.getEliteCopyList(CopyLayer.getEliteCopyCallback)
			end
		elseif(tag == Normal_Copy_Tag) then
			data = DataCache.getNormalCopyData()
			if (table.isEmpty(data)) then
				CopyService.ncopyGetCopyList(CopyLayer.getNormalCopyCallback)
			end
		elseif(tag == Active_Copy_Tag)then
			data = DataCache.getActiveCopyData()
			if(DataCache.getSwitchNodeState(  ksSwitchActivityCopy  ) ~= true) then
				-- AnimationTip.showTip(GetLocalizeStringBy("key_1425"))
			elseif ( table.isEmpty(data)) then
				RequestCenter.getActiveCopyList(CopyLayer.getActiveCopyCallback)
			end
		end
		-- if (table.isEmpty(data) == false) then
		-- 	createCopyTableView()
		-- end
		createCopyTableView()
	end	
end



--[[
	@desc	添加副本的切换按钮
	@para 	void
	@return void
--]]
local function addCopyMenus()
	menu = CCMenu:create()

	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--添加背景
	local btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 0))
	btnFrameSp:setPosition(ccp(bgLayer:getContentSize().width/2 , bgLayer:getContentSize().height*0.88))
	btnFrameSp:setScale(bgLayer:getBgScale()/bgLayer:getElementScale())
	bgLayer:addChild(btnFrameSp)
	

    require "script/ui/main/MainScene"
	
	require "script/ui/common/LuaMenuItem"
	local title_item = {"images/copy/btn_elite_", "images/copy/btn_normal_", "images/copy/btn_active_"}

	for i=1,3 do
		local itemImage = LuaMenuItem.createItemImage(title_item[i] .. "normal.png", title_item[i] .. "lighted.png")

		itemImage:setAnchorPoint(ccp(0.5,0.5))
        itemImage:setPosition(MainScene.getMenuPositionInTruePoint(bgLayer:getContentSize().width*(2*i-1)/6.0,bgLayer:getContentSize().height*0.95))
        itemImage:registerScriptTapHandler(itemMenuAction)
		menu:addChild(itemImage, i, 1000+i)
		if (curCopyTag == 1000+i) then
			itemImage:selected()
			-- itemMenuAction(curCopyTag, itemImage)
		else
			-- itemImage:setVisible(false)
		end 
		if(i==1)then
			eliteBtn_guide = itemImage

			local e_num = DataCache.getEliteCopyLeftNum()
			require "script/utils/ItemDropUtil"
			_eliteTipSprite = ItemDropUtil.getTipSpriteByNum(e_num)
			_eliteTipSprite:setPosition(itemImage:getContentSize().width*0.97, itemImage:getContentSize().height*0.98)
			_eliteTipSprite:setAnchorPoint(ccp(1,1))
			if(e_num<=0)then
				_eliteTipSprite:setVisible(false)
			end
			itemImage:addChild(_eliteTipSprite)	
		end
		if(i == 3)then
			local a_num = DataCache.getActiveCopyLeftNum()
			require "script/utils/ItemDropUtil"
			_activeTipSprite = ItemDropUtil.getTipSpriteByNum(a_num)
			_activeTipSprite:setPosition(itemImage:getContentSize().width*0.97, itemImage:getContentSize().height*0.98)
			_activeTipSprite:setAnchorPoint(ccp(1,1))
			if(a_num <= 0)then
				_activeTipSprite:setVisible(false)
			end
			itemImage:addChild(_activeTipSprite)	
		end
	end
    menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	bgLayer:addChild(menu)
end 

-- 刷新副本的提示气泡
function refreshCopyTip()

	-- 精英副本
	local e_num = DataCache.getEliteCopyLeftNum()
	if(e_num>0)then
		_eliteTipSprite:setVisible(true)
		ItemDropUtil.refreshNum(_eliteTipSprite, e_num)
	else
		_eliteTipSprite:setVisible(false)
	end

	--活动副本
	local a_num = DataCache.getActiveCopyLeftNum()
	if(a_num>0)then
		_activeTipSprite:setVisible(true)
		ItemDropUtil.refreshNum(_activeTipSprite, a_num)
	else
		_activeTipSprite:setVisible(false)
	end

	-- 刷新主界面小气泡
	MenuLayer.refreshMenuItemTipSprite()
end

--[[
	@desc	精英副本的回调
	@para 	void
	@return void
--]]
function getEliteCopyCallback( cbFlag, dictData, bRet )

	if(dictData and dictData.ret) then
		
		DataCache.setEliteCopyData( dictData.ret )
		data = DataCache.getEliteCopyData()
		createCopyTableView()
	end
end

--[[
	@desc	活动的回调
	@para 	void
	@return void
--]]
function getActiveCopyCallback( cbFlag, dictData, bRet )
	if(dictData and dictData.ret) then
		DataCache.setActiveCopyData( dictData.ret )
		data = DataCache.getActiveCopyData()
		createCopyTableView()
	end
end

--[[
	@desc	普通副本的回调
--]]
function getNormalCopyCallback( p_ncopy_data )
	DataCache.setNormalCopyData( p_ncopy_data )
	data = DataCache.getNormalCopyData()
	createCopyTableView()
end


--[[
	@desc	创建
	@para 	void
	@return void
--]]
function createLayer(isAnimate, toIndex)
	init()
	-- ShowNewCopyLayer.showNewCopy(3)
	canDefeatNumBg = nil

	if (isAnimate == nil) then
		isNeedCellAnimate = true
	else
		isNeedCellAnimate = isAnimate
	end

	require "script/ui/main/MainScene"
	bgLayer = MainScene.createBaseLayer("images/main/module_bg.png")
	if(toIndex)then
		curCopyTag = toIndex
	else
		curCopyTag = Normal_Copy_Tag
	end
	addCopyMenus()
    

    if(curCopyTag == Normal_Copy_Tag)then
    	if ( table.isEmpty(DataCache.getNormalCopyData())) then
			CopyService.ncopyGetCopyList(CopyLayer.getNormalCopyCallback)
		else
			data = DataCache.getNormalCopyData()
			createCopyTableView()
	    end 
	elseif(curCopyTag == Elite_Copy_Tag)then
		if ( table.isEmpty(DataCache.getEliteCopyData())) then
			RequestCenter.getEliteCopyList(CopyLayer.getEliteCopyCallback)
		else
			data = DataCache.getEliteCopyData()
			createCopyTableView()
	    end 
	elseif(curCopyTag == Active_Copy_Tag)then
		if(DataCache.getSwitchNodeState(  ksSwitchActivityCopy  ) ~= true) then
				
		elseif ( table.isEmpty(DataCache.getActiveCopyData())) then
			RequestCenter.getActiveCopyList(CopyLayer.getActiveCopyCallback)
		else
			data = DataCache.getActiveCopyData()
			createCopyTableView()
	    end 
    end

	return bgLayer
end 

-- 新手引导
-- 普通副本
function getGuideObject()
	return myTableView:cellAtIndex(#data-2)
end

-- 精英副本
function getGuideObject_3()
	return myTableView:cellAtIndex(0)
end

function getGuideObject_2()
	return eliteBtn_guide
end


------add by lichenyang 2013.09.17
--table view 创建事件
function registerDidTableViewCallBack( callback )
	didCreateTableViewFunc = callback
end

--点击副本事件
function registerSelectCopyCallback( callback )
	didClickCopyCell = callback
end

function addNewGuide( ... )
	 ---[==[ 强化所第10步 
        ---------------------新手引导---------------------------------
            --add by licong 2013.09.07
            require "script/guide/NewGuide"
            require "script/guide/StrengthenGuide"
            if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 9) then
                local strengthenButton = getGuideObject()
                local touchRect = getSpriteScreenRect(strengthenButton)
                StrengthenGuide.show(10, touchRect)
            end
         ---------------------end-------------------------------------
    --]==]

    ---[==[ 等级礼包第18步 副本选择
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        require "script/guide/LevelGiftBagGuide"
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 17) then
            local levelGiftBagGuide_button = getGuideObject()
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(18, touchRect)
        end
        ---------------------end-------------------------------------
   	--]==]

   	---[==[  副本箱子 第8步 副本选择
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 7) then
	    	local copyBox_button = getGuideObject()
            local touchRect = getSpriteScreenRect(copyBox_button)
		    CopyBoxGuide.show(8, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]

	---[==[精英副本 第2步
	---------------------新手引导---------------------------------
	require "script/guide/NewGuide"
	require "script/guide/EliteCopyGuide"
    if(NewGuide.guideClass ==  ksGuideEliteCopy and EliteCopyGuide.stepNum == 1) then
        local eliteButton = getGuideObject_2()
        local touchRect   = getSpriteScreenRect(eliteButton)
        EliteCopyGuide.show(2, touchRect)
    end
	---------------------end-------------------------------------
	--]==]

	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 4) then
       	require "script/ui/main/MainBaseLayer"
     	local equipButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(5,touchRect)
    end

    -- 铁匠铺 7步
    require "script/guide/NewGuide"
	require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 6) then
        local equipButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(7, touchRect)
    end
end

---[==[精英副本 第3步
---------------------新手引导---------------------------------
function addGuideEliteCopyGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/EliteCopyGuide"
    if(NewGuide.guideClass ==  ksGuideEliteCopy and EliteCopyGuide.stepNum == 2) then
        local eliteButton = getGuideObject_3()
        local touchRect   = getSpriteScreenRect(eliteButton)
        EliteCopyGuide.show(3, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


