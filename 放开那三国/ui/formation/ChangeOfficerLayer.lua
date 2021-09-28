-- Filename：	ChangeOfficerLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-7-16
-- Purpose：		更换将领

module ("ChangeOfficerLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/model/hero/HeroModel"
require "script/ui/formation/FOfficerCell"
require "script/ui/formation/FormationUtil"
require "script/ui/tip/AnimationTip"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroFightSimple"
require "script/ui/formation/LittleFriendData"
require "script/ui/formation/secondfriend/SecondFriendData"
require "script/ui/formation/FormationLayer"

local _bgLayer				= nil	-- 背景
local _curHid 				= nil   -- hid 
local _fPosition 			= nil	-- 阵型位置 从0开始
local _herosTableView 		= nil	-- tableView

local _herosData 			= {}	-- 可上阵的将领 
local _f_hid 				= nil	-- 上一个武将

local _isLittleFriend 		= false

local _isSecondFriend 		= false
local _unionProfitCounts 	= {}
local _hids 				= nil

-- 返回
function backAction( ... )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	local formationLayer = FormationLayer.createLayer(_curHid, false, _isLittleFriend, nil,nil,nil,_isSecondFriend,_fPosition)

	require "script/ui/main/MainScene"
	MainScene.changeLayer(formationLayer, "formationLayer")
end 

-- 更换武将回调
function addHeroCallback( cbFlag, dictData, bRet )
	require "script/ui/warcraft/WarcraftData"
	if (dictData.err == "ok" and dictData.ret) then
		--如果原来位置上有人
		--战斗力信息
		--added by Zhang Zihang
		local _lastFightValue
		if _f_hid and tonumber(_f_hid) > 0 then
			_lastFightValue = FightForceModel.dealParticularValues(_f_hid)
		else
			_lastFightValue = nil
		end

		local t_formationInfo = {}
		for k,v in pairs(dictData.ret) do
	        t_formationInfo["" .. (tonumber(k)-1)] = tonumber(v)
	    end
	    local t_squad = DataCache.getSquad()
	    t_squad["" .. _fPosition] = _curHid
	    DataCache.setSquad(t_squad)

		DataCache.setFormationInfo(t_formationInfo)

		if ( _f_hid and tonumber( _f_hid) > 0 )then
			HeroModel.exchangeEquipInfo(_f_hid, _curHid)
		end

		--战斗力信息
		--added by Zhang Zihang
		local _nowFightValue = FightForceModel.dealParticularValues(_curHid)
		
		--刷新英雄属性
		require "script/model/hero/HeroAffixFlush"
		HeroAffixFlush.onChangeHero(_curHid)

		--刷新老的英雄属性
		if ( _f_hid and tonumber( _f_hid) > 0 )then
			require "script/model/hero/HeroAffixFlush"
			HeroAffixFlush.onChangeHero(_f_hid)
		end
		
		require "script/model/utils/UnionProfitUtil"
		require "script/ui/item/ItemUtil"
		require "script/utils/LevelUpUtil"

		local param_1_table = UnionProfitUtil.prepardUnionFly(nil,true)
		
		if table.isEmpty(param_1_table) then
			ItemUtil.showAttrChangeInfo(_lastFightValue, _nowFightValue)
		else
			local param_2_table = ItemUtil.showAttrChangeInfo(_lastFightValue, _nowFightValue,nil,true)
			local paramTable = {[1] = param_1_table,[2] = param_2_table}
			local connectTable = table.connect(paramTable)

			LevelUpUtil.showConnectFlyTip(connectTable)
		end
		backAction()
		--local UnionProfitUtil.prepardUnionFly(nil,true)
	end
end

-- 更换小伙伴回调
function addLittleFriendCallback( pos )
	-- 返回阵容界面
	MainScene.changeLayer(FormationLayer.createLayer(nil, false, true),"formationLayer")
	require "script/model/utils/UnionProfitUtil"
	UnionProfitUtil.prepardUnionFly()

	-- -- 缓存助战军属性
	-- require "script/model/affix/SecondFriendAffixModel"
	-- SecondFriendAffixModel.getAffixByHid(true)
end

-- 更换助威军回调
function addSecFriendCallback( pos )
	-- 更新羁绊
	require "script/model/utils/UnionProfitUtil"
	UnionProfitUtil.prepardUnionFly()

	-- -- 缓存助战军属性
	-- require "script/model/affix/SecondFriendAffixModel"
	-- SecondFriendAffixModel.getAffixByHid(true)

	-- 返回阵容界面
	local formationLayer = FormationLayer.createLayer(nil, false, nil, nil,nil,nil,true,pos)
	MainScene.changeLayer(formationLayer,"formationLayer")

end

-- 选中哪个
function selectedHerosDelegate( s_hid )
	if (s_hid and s_hid>0)then

		if(_isLittleFriend == true)then
			if( LittleFriendData.isSwapHeroOnLittleFriendByHid(s_hid,_fPosition) == false or FormationUtil.isHadSameTemplateOnFormation(s_hid) or SecondFriendData.isHadSameTemplateOnSecondFriend(s_hid) )then
				AnimationTip.showTip(GetLocalizeStringBy("key_2788"))
			else
				_curHid = s_hid
				require "script/ui/formation/LittleFriendService"
				LittleFriendService.addLittleFriendService(_curHid,_fPosition,addLittleFriendCallback)
			end
		elseif(_isSecondFriend == true)then
			if( SecondFriendData.isSwapHeroOnSecFriendByHid(s_hid,_fPosition) == false or FormationUtil.isHadSameTemplateOnFormation(s_hid) or LittleFriendData.isHadSameTemplateOnLittleFriend(s_hid) )then
				AnimationTip.showTip(GetLocalizeStringBy("key_2788"))
			else
				_curHid = s_hid
				require "script/ui/formation/secondfriend/SecondFriendService"
				SecondFriendService.addAttrExtra(_curHid,_fPosition,addSecFriendCallback)
			end
		else
			if( FormationUtil.isSwapHeroOnFormationByHid(s_hid,_fPosition) == false or LittleFriendData.isHadSameTemplateOnLittleFriend(s_hid) or SecondFriendData.isHadSameTemplateOnSecondFriend(s_hid) )then
				AnimationTip.showTip(GetLocalizeStringBy("key_2788"))
			else
				_curHid = s_hid
				
				local args = Network.argsHandler(s_hid, _fPosition)
				RequestCenter.formation_addHero(addHeroCallback, args)
			end
		end
		
	end
end


-- 创建tableview
local function createOfficerTableView(  )
	local cellBg = CCSprite:create("images/formation/changeofficer/cellbg.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

    local myScale = _bgLayer:getContentSize().width/cellBg:getContentSize().width/_bgLayer:getElementScale()

	
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
				local value = _herosData[a1+1]
				-- value.fightDict = HeroFightSimple.getAllForceValuesByHid(value.hid)
                a2 = FOfficerCell.createOfficerCell(value, _unionProfitCounts[value.hid], selectedHerosDelegate)
                a2:setScale(myScale)
    --             local testLabel = CCLabelTTF:create("Test_" .. (a1+1) .. "_herosData[1]==" .. _herosData[a1+1].hid, g_sFontName, 25)
	   --          testLabel:setColor(ccc3(0,0,0))
				-- a2:addChild(testLabel, 1, 123)
			r = a2
		elseif fn == "numberOfCells" then
			
			r = #_herosData
		elseif fn == "cellTouched" then
			print("cellTouched: " .. (a1:getIdx()))
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	herosTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(), _bgLayer:getContentSize().height*(0.87)/_bgLayer:getElementScale()))
    herosTableView:setAnchorPoint(ccp(0,0))
	herosTableView:setBounceable(true)
	herosTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	

	_bgLayer:addChild(herosTableView)
end

-- 开始创建
local function create( ... )
	local bglayerSize = _bgLayer:getContentSize()
	local myScale = bglayerSize.width/640/_bgLayer:getElementScale()
	
	-- 创建topView
	-- 背景
	local topBg = CCSprite:create("images/formation/changeofficer/topbar.png")
	topBg:setAnchorPoint(ccp(0.5, 1))
	topBg:setPosition(ccp(bglayerSize.width/2, bglayerSize.height))
	topBg:setScale(myScale)
	_bgLayer:addChild(topBg)

	-- 标题
	local titleSprite = nil
	if(_isLittleFriend == true)then
		titleSprite = CCSprite:create("images/formation/littlef_title.png")
	else
		titleSprite = CCSprite:create("images/formation/changeofficer/title.png")
	end
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(topBg:getContentSize().width * 0.2, topBg:getContentSize().height*0.6))
	topBg:addChild(titleSprite)

	-- 返回按钮
	local topMenuBar = CCMenu:create()
	topMenuBar:setPosition(ccp(0,0))
	topBg:addChild(topMenuBar)
	local backBtn = LuaMenuItem.createItemImage("images/formation/changeequip/btn_back_n.png",  "images/formation/changeequip/btn_back_h.png", backAction)
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(topBg:getContentSize().width*0.85, topBg:getContentSize().height*0.6))
	-- backBtn:registerScriptTapHandler(backAction)
	topMenuBar:addChild(backBtn)	

	createOfficerTableView()

end

local function init(  )
	_bgLayer		= nil	-- 背景
	_curHid 		= nil   -- hid 
	_fPosition 		= nil	-- 阵型位置
	_herosTableView = nil	-- tableView
	_herosData		= HeroUtil.getFreeHerosInfo()  -- 空闲的将领
	_unionProfitCounts = {}
	initUnionProfitCounts()
	_hids 			= nil
end

--[[
	@desc	创建
	@para 	void
	@return void
--]]
function createLayer(f_position, hid, isLittleFriend, p_isSecondFriend )
	print("f_position",  f_position)
	init()
	_fPosition = f_position
	_f_hid = hid
	_curHid = hid
	_isLittleFriend = isLittleFriend or false
	_isSecondFriend = p_isSecondFriend or false
	sortHeroDatas()
	require "script/ui/main/MainScene"
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)

	create()

	--add by lichenyang  -- add new Guide
	local newGuideAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(addNewGuide))
	_bgLayer:runAction(newGuideAction)
    
	return _bgLayer
end 

function sortHeroDatas( ... )
	table.sort(_herosData, function ( heroData1, heroData2 )
		local value1 = 0
		local value2 = 0
		local potentialWeight = 20
		local evolveLevelWeight = 8
		local levelWeight = 4
		if heroData1.heroDesc.potential > heroData2.heroDesc.potential then
			value1 = value1 + potentialWeight
		elseif heroData1.heroDesc.potential < heroData2.heroDesc.potential then
			value2 = value2 + potentialWeight
		end
		if tonumber(heroData1.evolve_level) > tonumber(heroData2.evolve_level) then
			value1 = value1 + evolveLevelWeight
		elseif tonumber(heroData1.evolve_level) < tonumber(heroData2.evolve_level) then
			value2 = value2 + evolveLevelWeight
		end
		if tonumber(heroData1.level) > tonumber(heroData2.level) then
			value1 = value1 + levelWeight
		elseif tonumber(heroData1.level) < tonumber(heroData2.level) then
			value2 = value2 + levelWeight
		end
		
		if tonumber(heroData1.htid) > tonumber(heroData2.htid) then
			value1 = value1 + 2
		elseif tonumber(heroData1.htid) < tonumber(heroData2.htid) then
			value2 = value2 + 2
		end

		if getUnionProfitActiveCount(heroData1) > getUnionProfitActiveCount(heroData2) then
			value1 = value1 + 40
		elseif getUnionProfitActiveCount(heroData1) < getUnionProfitActiveCount(heroData2) then
			value2 = value2 + 40
		end

		return value1 > value2
	end)
end

function initUnionProfitCounts()
	if _isLittleFriend then
		_hids = LittleFriendData.getLittleFriendeData()
	elseif _isSecondFriend then
		_hids = SecondFriendData.getSecondFriendInfo()
	else
		_hids = DataCache.getFormationInfo()
	end 
	for i = 1, #_herosData do
		local heroData = _herosData[i]
		local positonStr = tostring(_fPosition)
		local hid = _hids[positonStr]
		_hids[positonStr] = "0"
		local unionProfitCount = UnionProfitUtil.getUnionProfitActiveCount()
		_hids[positonStr] = tonumber(heroData.hid)
		local curUnionProfitCount = UnionProfitUtil.getUnionProfitActiveCount()
		_hids[positonStr] = hid
		local addUnionProfitCount = curUnionProfitCount - unionProfitCount
		_unionProfitCounts[heroData.hid] = addUnionProfitCount
	end
end

function getUnionProfitActiveCount( heroData )
	return _unionProfitCounts[heroData.hid]
end

-- 新手引导用
function getGuideObject()
	local cell = herosTableView:cellAtIndex(0)
	local guideBtn = nil
	if(cell)then
		local bgSprite = tolua.cast(cell:getChildByTag(10001), "CCSprite")
		if(bgSprite)then
			local menuBar = tolua.cast(bgSprite:getChildByTag(9), "CCMenu")
			if(menuBar)then
				local heroInfo = _herosData[1]
				guideBtn = tolua.cast(menuBar:getChildByTag(heroInfo.hid), "CCMenuItemImage")
			end
		end
	end
	return guideBtn
end


--add by lichenyang
function addNewGuide( ... )
	------------------------新手引导-------------------------------
    --add by lichenyang 2013.08.29
    require "script/guide/NewGuide"
    if(NewGuide.guideClass ==  ksGuideFormation and FormationGuide.stepNum == 3) then
	    require "script/guide/FormationGuide"
	    local touchRect = getSpriteScreenRect(ChangeOfficerLayer.getGuideObject())
	    FormationGuide.show(4, touchRect)
	end
	--------------------------------------------------------------

	---[==[ 等级礼包第12步 
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
    require "script/guide/LevelGiftBagGuide"
	if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 11) then
       	local levelGiftBagGuide_button = ChangeOfficerLayer.getGuideObject()
    	local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(12, touchRect)
    end
    ---------------------end-------------------------------------
	--]==]

	--------------------10级等级礼包--------------------------
	-- 第11步
	if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 10) then
            TenLevelGiftGuide.changLayer()
            local touchRect       = getSpriteScreenRect(ChangeOfficerLayer.getGuideObject())
            TenLevelGiftGuide.show(11, touchRect)
            print("heroDisplayerLayerCallback")
    end    
    -----------------------------------------------------
end


