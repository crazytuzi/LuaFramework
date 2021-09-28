-- Filename：	ChangeEquipLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-7-6
-- Purpose：		更换装备

module ("ChangeEquipLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/model/hero/HeroModel"
require "script/ui/bag/BagUtil"
require "script/ui/formation/FTreasCell"  
require "script/ui/huntSoul/FightSoulCell"
require "script/utils/LevelUpUtil"
require "script/ui/godweapon/GodWeaponData"
require "script/model/hero/HeroAffixFlush"
local bgLayer 

local equipDatas 				= {}		-- 经过处理的装备信息		

local MenuBtnPriority			= -130		-- menuItem的优先级
local Tag_Equip_Base			= 2000		-- 装备cell的起始Tag 
local formationCallbackFunc		= nil		-- 阵容界面的回调 
local curEquioPos				= nil		-- 换装的位置
local curHID 					= nil 		-- 换装的将领		

local seletedItemId 			= nil		-- 更换的装备ID
local s_hid 					= -1 		-- 是否是在哪个武将身上换过来的 
local _isTreasType 				= false		-- 是否是宝物
local _isFightSoulType 			= false 	-- 是否是战魂
local _isGodWeaponType 			= false     -- 是否是神兵

local _firstEquipBtn 			= nil
local myTableView 				= nil

local fightSoulTypesOnHero 		= {} 		-- 武将身上的战魂类型信息
local fightSoulTypesOnHero_t 	= {} 		-- 武将身上的战魂类型信息数据

local godWeaponTypesOnHero 		= {} 		-- 武将身上的神兵类型信息
local godWeaponTypesOnHero_t 	= {} 		-- 武将身上的神兵类型信息数据

local _oldSuitInfo 				= nil       -- 原有套装个数
local _unionProfitCounts 		= {}

function init( )
	fightSoulTypesOnHero 		= {} 		-- 武将身上的战魂类型信息
	fightSoulTypesOnHero_t 		= {} 
	_oldSuitInfo 				= nil
	godWeaponTypesOnHero 		= {} 
	godWeaponTypesOnHero_t 		= {} 	
	_unionProfitCounts 			= {}
end


-- 返回
function backAction( ... )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    
	require "script/ui/main/MainScene"
	require "script/ui/formation/FormationLayer"
	
	bgLayer:removeFromParentAndCleanup(true)
	bgLayer=nil
	local formationType = 1
	if(_isFightSoulType == true)then
		formationType = 2
	elseif(_isGodWeaponType == true)then
		formationType = 3
	else
	end
	local formationLayer = FormationLayer.createLayer(curHID, false, false, nil, formationType)
	MainScene.changeLayer(formationLayer, "formationLayer")
end 

-- 换装备回调
function changeEquipCallback( cbFlag, dictData, bRet )


	
	if (dictData.err == "ok") then
		-- 获得要装备的装备
		local bagInfo = DataCache.getRemoteBagInfo()

		--战斗力信息
		--added by Zhang Zihang
		local _lastFightForce = FightForceModel.dealParticularValues(curHID)

		if(_isTreasType == true)then
			-- 宝物
			local selectedIteminfo = nil
			for i_gid, equipInfo in pairs(bagInfo.treas) do
				if (equipInfo.item_id == seletedItemId) then
					selectedIteminfo = equipInfo
					bagInfo.treas[i_gid] = nil
					DataCache.setBagInfo(bagInfo)
					break
				end
			end
			local allHeros = HeroModel.getAllHeroes()
			local oldHid = nil
			if(selectedIteminfo)then
				-- 更换装备
				allHeros["" .. curHID].equip.treasure[""..curEquioPos] = selectedIteminfo
				HeroModel.setAllHeroes(allHeros)
			else
				for k,v in pairs(equipDatas) do
				  	if(v.item_id == seletedItemId)then
				  		selectedIteminfo = v
				  		break
				  	end
				end
				oldHid = selectedIteminfo.equip_hid
				allHeros["" .. curHID].equip.treasure[""..curEquioPos] = selectedIteminfo
				allHeros["" .. selectedIteminfo.equip_hid].equip.treasure[""..curEquioPos] = "0"
				HeroModel.setAllHeroes(allHeros)
			end
			--刷新宝物相关缓存属性
			HeroAffixFlush.onChangeTreas(curHID)
			if oldHid and tonumber(oldHid) > 0 then
				HeroAffixFlush.onChangeTreas(oldHid)
			end
			--战斗力信息
			--added by Zhang Zihang
			local _nowFightForce = FightForceModel.dealParticularValues(curHID)
			
			local param_1_table = UnionProfitUtil.prepardUnionFly(nil,true)
			if table.isEmpty(param_1_table) then
				ItemUtil.showAttrChangeInfo(_lastFightForce, _nowFightForce)
			else
				local param_2_table = ItemUtil.showAttrChangeInfo(_lastFightForce, _nowFightForce,nil,true)
				local paramTable = {[1] = param_1_table,[2] = param_2_table}
				local connectTable = table.connect(paramTable)

				LevelUpUtil.showConnectFlyTip(connectTable)
			end

		elseif( _isFightSoulType == true )then
			-- 战魂
			local selectedIteminfo = nil
			for i_gid, equipInfo in pairs(bagInfo.fightSoul) do
				if (equipInfo.item_id == seletedItemId) then
					selectedIteminfo = equipInfo
					bagInfo.fightSoul[i_gid] = nil
					DataCache.setBagInfo(bagInfo)
					break
				end
			end
			local allHeros = HeroModel.getAllHeroes()
			local lastFightSoulInfo =  allHeros["" .. curHID].equip.fightSoul[""..curEquioPos]
			local oldHid = nil
			if(selectedIteminfo)then
				-- 更换战魂
				allHeros["" .. curHID].equip.fightSoul[""..curEquioPos] = selectedIteminfo
				HeroModel.setAllHeroes(allHeros)
			else
				for k,v in pairs(equipDatas) do
				  	if(v.item_id == seletedItemId)then
				  		selectedIteminfo = v
				  		break
				  	end
				end
				oldHid = selectedIteminfo.equip_hid
				allHeros["" .. curHID].equip.fightSoul[""..curEquioPos] = selectedIteminfo
				allHeros["" .. selectedIteminfo.equip_hid].equip.fightSoul[""..selectedIteminfo.pos] = "0"
				HeroModel.setAllHeroes(allHeros)
			end
			--刷新战魂相关缓存属性
			HeroAffixFlush.onChangeFightSoul(curHID)
			if oldHid and tonumber(oldHid) > 0 then
				HeroAffixFlush.onChangeFightSoul(oldHid)
			end
			local lastFightSoulAttrs = {}
			require "script/ui/huntSoul/HuntSoulData"
			if( not table.isEmpty(lastFightSoulInfo ) )then
				lastFightSoulAttrs = HuntSoulData.getFightSoulAttrByItem_id(lastFightSoulInfo.item_id, nil, lastFightSoulInfo)
			end
			local curFightSoulAttrs = HuntSoulData.getFightSoulAttrByItem_id(selectedIteminfo.item_id, nil, selectedIteminfo)

			ItemUtil.showFightSoulAttrChangeInfo( lastFightSoulAttrs, curFightSoulAttrs )
		elseif( _isGodWeaponType == true )then 
			-- 神兵
			-- 旧战力
			local lastFightValue = FightForceModel.dealParticularValues(curHID)
			local selectedIteminfo = nil
			for i_gid, equipInfo in pairs(bagInfo.godWp) do
				if (equipInfo.item_id == seletedItemId) then 
					selectedIteminfo = equipInfo
					bagInfo.godWp[i_gid] = nil
					DataCache.setBagInfo(bagInfo)
					break
				end
			end
			local oldHid = nil
			local allHeros = HeroModel.getAllHeroes()
			local lastGodWeaponInfo =  allHeros["" .. curHID].equip.godWeapon[""..curEquioPos]
			if(selectedIteminfo)then
				-- 更换神兵
				allHeros["" .. curHID].equip.godWeapon[""..curEquioPos] = selectedIteminfo
				HeroModel.setAllHeroes(allHeros)
			else
				for k,v in pairs(equipDatas) do
				  	if(v.item_id == seletedItemId)then
				  		selectedIteminfo = v
				  		break
				  	end
				end
				oldHid = selectedIteminfo.equip_hid
				allHeros["" .. curHID].equip.godWeapon[""..curEquioPos] = selectedIteminfo
				allHeros["" .. selectedIteminfo.equip_hid].equip.godWeapon[""..selectedIteminfo.pos] = "0"
				HeroModel.setAllHeroes(allHeros)
			end
			--刷新神兵相关缓存属性
			HeroAffixFlush.onChangeGodWeapon(curHID)
			if oldHid and tonumber(oldHid) > 0 then
				HeroAffixFlush.onChangeGodWeapon(oldHid)
			end
			-- 新战力
			local nowFightValue = FightForceModel.dealParticularValues(curHID)
			ItemUtil.showAttrChangeInfo(lastFightValue,nowFightValue)
			--刷新羁绊信息
			UnionProfitUtil.refreshUnionProfitInfo()
		else
			-- 装备
			local selectedIteminfo = nil
			for i_gid, equipInfo in pairs(bagInfo.arm) do
				if (equipInfo.item_id == seletedItemId) then
					selectedIteminfo = equipInfo
					bagInfo.arm[i_gid] = nil
					DataCache.setBagInfo(bagInfo)
					break
				end
			end
			local allHeros = HeroModel.getAllHeroes()

			-- 之前的装备
			local lastEquipInfo = allHeros["" .. curHID].equip.arming[""..curEquioPos]
			local t_numerial_last = nil
			if( not table.isEmpty(lastEquipInfo))then
				t_numerial_last = ItemUtil.getTop2NumeralByIID( tonumber(lastEquipInfo.item_id))
			end
			local oldHid = nil
			if(selectedIteminfo)then
				-- 更换装备
				allHeros["" .. curHID].equip.arming[""..curEquioPos] = selectedIteminfo
				HeroModel.setAllHeroes(allHeros)
			else
				for k,v in pairs(equipDatas) do
				  	if(v.item_id == seletedItemId)then
				  		selectedIteminfo = v
				  		break
				  	end
				end
				oldHid = selectedIteminfo.equip_hid
				allHeros["" .. curHID].equip.arming[""..curEquioPos] = selectedIteminfo
				allHeros["" .. selectedIteminfo.equip_hid].equip.arming[""..curEquioPos] = "0"
				HeroModel.setAllHeroes(allHeros)
			end
			
			-- 现在装上的装备
			local curEquipInfo = allHeros["" .. curHID].equip.arming[""..curEquioPos]
			-- 获得相关数值
			local t_numerial_cur = ItemUtil.getTop2NumeralByIID( tonumber(curEquipInfo.item_id))
			
			-- 更换完装备后套装最新信息 飘套装激活属性
			local newSuitInfo = ItemUtil.getSuitActivateNumByHid(curHID)
			require "script/ui/tip/AttrTip"
			local flyTipCallBack = function ( ... )
				local showDevelopTip = function ( ... )
					local developActivateInfo = ItemUtil.getEquipDevelopActivateInfoByHid(curHID)
					if developActivateInfo ~= nil then
						AttrTip.showActivateEquipDevelopTip(developActivateInfo)
					end
				end
				if newSuitInfo ~= nil and _oldSuitInfo ~= nil then
					if not AttrTip.showAtrrTipCallBack(newSuitInfo,_oldSuitInfo, showDevelopTip) then
						showDevelopTip()
					end
				else
					showDevelopTip()
				end
			end
			
			local unionCallBack = function()
				ItemUtil.showAttrChangeInfo(t_numerial_last, t_numerial_cur, flyTipCallBack )
			end
			--刷新神兵相关缓存属性
			HeroAffixFlush.onChangeEquip(curHID)
			if oldHid and tonumber(oldHid) > 0 then
				HeroAffixFlush.onChangeEquip(oldHid)
			end
			--战斗力信息
			--added by Zhang Zihang
			local _nowFightForce = FightForceModel.dealParticularValues(curHID)

			require "script/model/hero/HeroModel"
			local heroInfo = HeroModel.getHeroByHid(curHID)
			--如果是主角
			if(HeroModel.isNecessaryHero(heroInfo.htid))then
				require "script/model/utils/UnionProfitUtil"
				local param_1_table = UnionProfitUtil.prepardUnionFly(nil,true)

				if table.isEmpty(param_1_table) then
					unionCallBack()
				else
					--local param_2_table = ItemUtil.showAttrChangeInfo(t_numerial_last, t_numerial_cur,nil,true)
					local param_2_table = ItemUtil.showAttrChangeInfo(_lastFightForce, _nowFightForce,nil,true)
					local paramTable = {[1] = param_1_table,[2] = param_2_table}
					local connectTable = table.connect(paramTable)

					LevelUpUtil.showConnectFlyTip(connectTable,flyTipCallBack)
				end
			else
				unionCallBack()
			end

		end
		backAction()
	end
 	
end 

-- 判断该类型战魂是否已经装备了
function isHasTypeBy( item_template_id )
	local isHas = false
	local itemInfo = ItemUtil.getItemById(item_template_id)

	if( fightSoulTypesOnHero[""..itemInfo.type] and fightSoulTypesOnHero[""..itemInfo.type] == true )then
		isHas = true
	end

	return isHas, itemInfo.type
end

-- 判断该类型神兵是否已经装备了
function isHasGodWeaponTypeBy( item_template_id )
	local isHas = false
	local itemInfo = ItemUtil.getItemById(item_template_id) 

	if( godWeaponTypesOnHero[""..itemInfo.type] and godWeaponTypesOnHero[""..itemInfo.type] == true )then
		isHas = true
	end

	return isHas, itemInfo.type
end

-- 换装备Action
function changeEquipAction( tag, itemBtn )

	--新手引导
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideRobTreasure) then
		RobTreasureGuide.changLayer(0)
	end
	
	seletedItemId = equipDatas[tag-Tag_Equip_Base+1].item_id

	local args = CCArray:create()
	args:addObject(CCInteger:create(curHID))
	args:addObject(CCInteger:create(curEquioPos))
	args:addObject(CCInteger:create(seletedItemId))

	local selectedIteminfo = nil
	for k,v in pairs(equipDatas) do
	  	if(v.item_id == seletedItemId)then
	  		selectedIteminfo = v
	  		break
	  	end
	end 
	if(selectedIteminfo and (selectedIteminfo.equip_hid) and tonumber(selectedIteminfo.equip_hid) > 0 ) then
		args:addObject(CCInteger:create(selectedIteminfo.equip_hid))
	end
	if(_isTreasType == true)then
		RequestCenter.hero_addTreasure(changeEquipCallback, args)
	elseif(_isFightSoulType == true)then
		local isHas,itemDescType = isHasTypeBy(selectedIteminfo.item_template_id)
		if( isHas == true)then
			-- AnimationTip.showTip(GetLocalizeStringBy("key_3371"))
			-- 富文本提示
			local textInfo = {}
			textInfo1 = {tipText=GetLocalizeStringBy("key_3272"), color=ccc3(255, 255, 255)}
			table.insert(textInfo,textInfo1)
			local itemData = fightSoulTypesOnHero_t["" .. itemDescType]
			local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
			local data = {}
			data.tipText = itemData.name
			data.color = name_color
			table.insert(textInfo,data)
			require "script/ui/tip/AnimationTip"
			AnimationTip.showRichTextTip(textInfo)
		else
			RequestCenter.hero_addFightSoul(changeEquipCallback, args)
		end
	elseif(_isGodWeaponType == true)then 
		local isHas,itemDescType = isHasGodWeaponTypeBy(selectedIteminfo.item_template_id)
		if( isHas == true)then
			-- AnimationTip.showTip(GetLocalizeStringBy("key_3371"))
			-- 富文本提示
			local textInfo = {}
			textInfo1 = {tipText=GetLocalizeStringBy("lic_1438"), color=ccc3(255, 255, 255)}
			table.insert(textInfo,textInfo1)
			local itemData = godWeaponTypesOnHero_t["" .. itemDescType].itemDesc
			local item_id = godWeaponTypesOnHero_t["" .. itemDescType].item_id
			local quality,_,_ = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil, item_id)
			local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
			local data = {}
			data.tipText = itemData.name
			data.color = name_color
			table.insert(textInfo,data)
			require "script/ui/tip/AnimationTip"
			AnimationTip.showRichTextTip(textInfo)
		else
			Network.rpc(changeEquipCallback, "hero.addGodWeapon","hero.addGodWeapon", args, true)
		end	
	else
		-- 记录更换装备之前的套装个数
		_oldSuitInfo = ItemUtil.getSuitActivateNumByHid(curHID)
		print("_oldSuitInfo===>")
		print_t(_oldSuitInfo)
		RequestCenter.hero_addArming( changeEquipCallback, args )
	end
end 

-- 创建装备的tableView
local function createEquipTableView( ... )
	local cellBg = nil
	if(_isTreasType)then
		cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	else
		cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	end

	--计算cell大小
	if(_isGodWeaponType == true )then 
		cellSize = CCSizeMake(635,190)
	else
		cellSize = cellBg:getContentSize()			
	end

    local myScale = bgLayer:getContentSize().width/cellBg:getContentSize().width/bgLayer:getElementScale()

    print("equipDatas:")
    print_t(equipDatas)

	require "script/ui/formation/EquipCell"
	require "script/ui/bag/GodWeaponBagCell"
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
				if(_isTreasType == true)then
					a2 = FTreasCell.createEquipCell(equipDatas[a1+1], refreshMyTableView, curHID, curEquioPos, _unionProfitCounts[equipDatas[a1+1].item_id])
				elseif(_isFightSoulType == true )then
					a2 = FightSoulCell.createCell(equipDatas[a1+1], false)
				elseif(_isGodWeaponType == true )then 
					a2 = GodWeaponBagCell.createCell( equipDatas[a1+1], nil, nil, nil, nil, false, true  )
				else
					a2 = EquipCell.createEquipCell(equipDatas[a1+1], refreshMyTableView)
				end
                
                a2:setScale(myScale)
    --             local testLabel = CCLabelTTF:create("Test_" .. (a1+1), g_sFontName, 25)
	   --          testLabel:setColor(ccc3(0,0,0))
				-- a2:addChild(testLabel, 1, 123)
				-- 不得已而为之
				-- 装备按钮Bar
				local cellMenuBar = CCMenu:create()
				cellMenuBar:setPosition(ccp(0,0))
				cellMenuBar:setTouchPriority(MenuBtnPriority)
				a2:addChild(cellMenuBar, 1, 8001)

				-- 装备按钮
				local equipBtn = LuaMenuItem.createItemImage("images/formation/changeequip/btn_equip_n.png",  "images/formation/changeequip/btn_equip_h.png", nil)
				equipBtn:setAnchorPoint(ccp(0.5, 0.5))
				equipBtn:setPosition(ccp(cellSize.width*0.8, cellSize.height*0.5))
				equipBtn:registerScriptTapHandler(changeEquipAction)
				cellMenuBar:addChild(equipBtn, a1+Tag_Equip_Base,Tag_Equip_Base+a1)
				if(#equipDatas == a1+1)then
					_firstEquipBtn = equipBtn
				end
			r = a2
		elseif fn == "numberOfCells" then
			
			r = #equipDatas
		elseif fn == "cellTouched" then
			print("cellTouched: " .. (a1:getIdx()))
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, CCSizeMake(bgLayer:getContentSize().width/bgLayer:getElementScale(),bgLayer:getContentSize().height*(0.87)/bgLayer:getElementScale()))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	myTableView:setTouchPriority(-170)
	bgLayer:addChild(myTableView)
end 

-- 
function refreshMyTableView()
	MainScene.setMainSceneViewsVisible(true, false, true)
	handleEquipData( )
	local contentOffset = myTableView:getContentOffset() 
	myTableView:reloadData()
	myTableView:setContentOffset(contentOffset) 
end

local function create( ... )
	local myScale = bgLayer:getContentSize().width/640/bgLayer:getElementScale()
--	最上面的UI
	-- 背景
	local topSprite = CCSprite:create("images/formation/changeequip/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgLayer:getContentSize().width/2, bgLayer:getContentSize().height))
	topSprite:setScale(myScale)
	bgLayer:addChild(topSprite)

	-- 标题
	local title_png = "title.png"
	if(_isTreasType == true)then
		title_png = "treas_title.png"

	elseif(_isFightSoulType == true)then
		title_png = "fightSoul_title.png"
	elseif(_isGodWeaponType == true)then 
		title_png = "godweapon_title.png"
	end
	local titleSprite = CCSprite:create("images/formation/changeequip/" .. title_png)
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(topSprite:getContentSize().width*0.3, topSprite:getContentSize().height/2))
	topSprite:addChild(titleSprite)

	-- 返回按钮
	local backMenuBar = CCMenu:create()
	backMenuBar:setPosition(ccp(0,0))
	backMenuBar:setTouchPriority(MenuBtnPriority-1)
	topSprite:addChild(backMenuBar)

	local backBtn = LuaMenuItem.createItemImage("images/formation/changeequip/btn_back_n.png",  "images/formation/changeequip/btn_back_h.png")
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(topSprite:getContentSize().width*0.85, topSprite:getContentSize().height*0.5))
	backBtn:registerScriptTapHandler(backAction)
	backMenuBar:addChild(backBtn)	

-- 创建装备的tableView
	createEquipTableView()

end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
        touchBeganPoint = ccp(x, y)
        local vPosition = bgLayer:convertToNodeSpace(touchBeganPoint)
        if (vPosition.y>0) then
        	return true
        else
        	return false
    	end
    elseif (eventType == "moved") then
        
    else

	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -129, true)
		bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		bgLayer:unregisterScriptTouchHandler()
	end
end

function getUnionProfitCounts( treasDatas )
	local unionProfitCounts = {}
	for i = 1, #treasDatas do
		local treasData = treasDatas[i]
		local heroInfo = HeroUtil.getHeroInfoByHid(curHID)
		local itemData = heroInfo.equip.treasure[tostring(curEquioPos)]
		heroInfo.equip.treasure[tostring(curEquioPos)] = "0"
		local unionProfitCount = FormationUtil.getHeroLinkUseNum(curHID)
		heroInfo.equip.treasure[tostring(curEquioPos)] = treasData
		local curUnionProfitCount = FormationUtil.getHeroLinkUseNum(curHID)
		heroInfo.equip.treasure[tostring(curEquioPos)] = itemData
		local addUnionProfitCount = curUnionProfitCount - unionProfitCount
		unionProfitCounts[treasData.item_id] = addUnionProfitCount
	end
	return unionProfitCounts
end

-- 处理背包中的装备信息
function handleEquipData( )
	equipDatas = {}
	local bagInfo = DataCache.getBagInfo()
	if(_isTreasType == true)then
		-- 宝物
		local temp_treas = {}
		if(bagInfo and bagInfo.treas) then
			for k, itemInfo in pairs(bagInfo.treas) do
				if(tonumber(itemInfo.itemDesc.type) == tonumber(curEquioPos) and tonumber(itemInfo.itemDesc.maxStacking) ==1 ) then
					table.insert(equipDatas, itemInfo)
				end
			end
			bagInfo = nil
		end
		local on_equips = ItemUtil.getTreasOnFormationByPos(curEquioPos, curHID)
		for k,v in pairs(on_equips) do
			table.insert(equipDatas, v)
		end
		_unionProfitCounts = getUnionProfitCounts(equipDatas)
		table.sort(equipDatas, function(itemData1, itemData2)
			local value1 = 0
			local value2 = 0
			local ret = BagUtil.treasSort(itemData1, itemData2)
			if ret then
				value1 = value1 - 1
			else
				value2 = value2 - 1
			end

			if _unionProfitCounts[itemData1.item_id] > _unionProfitCounts[itemData2.item_id] then
				value1 = value1 + 2
			elseif _unionProfitCounts[itemData1.item_id]< _unionProfitCounts[itemData2.item_id] then
				value2 = value2 + 2
			end

			if itemData1.equip_hid and tonumber(itemData1.equip_hid) > 0 then
				value1 = value1 + 4
			end

			if itemData2.equip_hid and tonumber(itemData2.equip_hid) > 0 then
				value2 = value2 + 4
			end
			return value1 < value2
		end)
	elseif(_isFightSoulType == true)then
		-- 战魂
		local temp_data= {}
		if( not table.isEmpty(bagInfo) and not table.isEmpty(bagInfo.fightSoul) ) then
			for k, itemInfo in pairs(bagInfo.fightSoul) do
				table.insert(temp_data, itemInfo)
			end
			
			bagInfo = nil
		end

		local on_equips = ItemUtil.getFightSoulOnFormationExeptHid(curHID)
		local temp_on_equips = {}
		for k,v in pairs(on_equips) do
			table.insert(temp_on_equips, v)
		end
		table.sort( temp_on_equips, BagUtil.fightSoulSort )
		for k, v in pairs(temp_on_equips) do
			table.insert(equipDatas, v)
		end
		
		for k,v in pairs(temp_data) do
			table.insert(equipDatas, v)
		end

		fightSoulTypesOnHero = {}
		fightSoulTypesOnHero_t = {}
		local soulOnCurHero = HeroUtil.getFightSoulByHid(curHID) 
		if( not table.isEmpty(soulOnCurHero) )then
			for k,v in pairs(soulOnCurHero) do
				if(tonumber(v.pos) ~= curEquioPos)then
					local itemDesc = ItemUtil.getItemById(v.item_template_id)
					fightSoulTypesOnHero["" .. itemDesc.type] = true
					fightSoulTypesOnHero_t["" .. itemDesc.type] = itemDesc
				end
			end
		end
	elseif(_isGodWeaponType == true)then 
		-- 神兵
		local temp_data = GodWeaponData.getGodWeaponDataForEquipInBag()
		for k,v in pairs(temp_data) do
			if(v.itemDesc[13] == curEquioPos)then
				table.insert(equipDatas, v)
			end
		end
		-- print("equipDatas~~~~")
		-- print_t(equipDatas)
		local on_equips = ItemUtil.getGodWeaponOnFormationExeptHid(curHID)
		table.sort( on_equips, BagUtil.equipGodWeaponSort )
		-- print("on_equips~~~~")
		-- print_t(on_equips)
		for k, v in pairs(on_equips) do
			if (v.itemDesc[13] == curEquioPos)then
				table.insert(equipDatas, v)
			end
		end
		godWeaponTypesOnHero = {}
		godWeaponTypesOnHero_t = {}
		local godWeaponOnCurHero = HeroUtil.getGodWeaponByHid(curHID) 
		if( not table.isEmpty(godWeaponOnCurHero) )then
			for k,v in pairs(godWeaponOnCurHero) do
				if(tonumber(v.pos) ~= curEquioPos)then
					local itemDesc = ItemUtil.getItemById(v.item_template_id)
					godWeaponTypesOnHero["" .. itemDesc.type] = true
					godWeaponTypesOnHero_t["" .. itemDesc.type] = {}
					godWeaponTypesOnHero_t["" .. itemDesc.type].itemDesc = itemDesc
					godWeaponTypesOnHero_t["" .. itemDesc.type].item_id = v.item_id
				end
			end
		end
	else
		-- 装备
		local temp_equips = {}
		if(bagInfo and bagInfo.arm) then
			for k, itemInfo in pairs(bagInfo.arm) do
				if(itemInfo.itemDesc.type == curEquioPos) then
					table.insert(temp_equips, itemInfo)
				end
			end
			table.sort( temp_equips, BagUtil.equipSort)
			bagInfo = nil
		end
		local on_equips = ItemUtil.getEquipsOnFormationByPos(curEquioPos, curHID)
		for k,v in pairs(temp_equips) do
			table.insert(equipDatas, v)
		end
		for k,v in pairs(on_equips) do
			table.insert(equipDatas, v)
		end
	end
end 

--[[
	@desc	创建
	@para 	void
	@return void
--]]
function createLayer( callbackFunc, hid, equipPosition, isTreasType, isFightSoulType, p_isGodWeaponType)
	init()
	_isTreasType = isTreasType or false
	_isFightSoulType = isFightSoulType or false
	_isGodWeaponType = p_isGodWeaponType or false
	curEquioPos = tonumber(equipPosition)
	curHID = hid
	formationCallbackFunc = callbackFunc
	handleEquipData()
	require "script/ui/main/MainScene"
	bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)
	-- bgLayer:registerScriptHandler(onNodeEvent)
	create()
	addNewGuide()
	return bgLayer
end 

-------------------------[[ 新手引导 ]]--------------------------
-- 新手引导
function getGuideObject()
	return _firstEquipBtn
end

function addNewGuide( ... )
	local guideFunc = function ( ... )
		require "script/ui/main/MenuLayer"
	    require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 9) then
            RobTreasureGuide.changLayer()
            local robTreasure =  getGuideObject()
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(10, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            guideFunc()
    end))
    bgLayer:runAction(seq)
end

function closeRobTreasureGuide( ... )

    require "script/guide/RobTreasureGuide"
    if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 10) then
        RobTreasureGuide.cleanLayer()
        NewGuide.guideClass = ksGuideClose
        BTUtil:setGuideState(false)
    end
end




